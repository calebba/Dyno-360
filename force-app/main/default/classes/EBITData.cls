global class EBITData {
	
	global class EBITDataHelper {
		public Set<Id> accountIds { get; set; }
		public Set<Id> siteIds { get; set; }
		public date dateFrom { get; set; }
		public date dateTo { get; set; }
		public String currencyUsed { get; set; }
		public String plant { get; set; }
		//public String salesGroup { get; set; }
		public Boolean isMainReport { get; set; }
		
		public EBITDataHelper() {}
	}
	
	public static PandLData createEBIT(EBITDataHelper edh) {
		PandLData data = new PandLData();
		data.inGenerator = true;
		String currencyIsoCode = edh.currencyUsed;
		data.currencyIsoCode = currencyIsoCode;
		

		// All the salessites we're looking for
		if (edh.siteIds.size() == 1) {
			data.SiteId = new list<Id>(edh.siteIds)[0];
		}
			
		// After finidng all the search criteria, create the query string
		Date dateFrom = edh.dateFrom;
		Date dateTo = edh.dateTo;
		
		String query = 'SELECT ' +
						 'c.Material_PHL1__c PHL1__c, ' +
						 'c.Sales_Site__c salesSiteId,' +
						 'SUM(c.DELHRS__c) deliveryHours, ' +
						 'SUM(c.SHOTHRS__c) shotHours, ' +
						 'SUM(c.MILES__c) distance, ' +
						 'SUM(c.LBS__c) units, ' +
						 'SUM(c.INVOICES__c) invoices, ' +
						 'SUM(c.Net_Revenue__c) netRevenue, ' +
						 'SUM(c.True_Total_Cogs__c) costOfGoodsSold, ' +
						 'SUM(c.COGS_See_Through__c) costOfGoodsSoldST ' +
						 'FROM COPA_Aggregate__c c';
						 
		query += ' WHERE c.Current_Month__c >= :dateFrom AND c.Current_Month__c <= :dateTo';
		data.validFrom = edh.dateFrom;
		data.validFromDisplay = edh.dateFrom.format().split(' ').get(0);
		data.validTo = edh.dateTo;
		data.validToDisplay = edh.dateTo.format().split(' ').get(0);
		
		Set<Id> accountIds = edh.accountIds;
		if(edh.accountIds.size() > 0) {
			query += ' AND c.Customer__c in :accountIds';
		}
		Set<Id> siteIds = edh.siteIds;
		if (edh.siteIds.size() > 0) {
			query += ' AND c.Sales_Site__c in :siteIds';
		}
		
		if (!edh.isMainReport) {
			String plant = edh.plant;
			data.plant = plant;
			query += ' AND c.Plant__c = :plant';
			//String salesGroup = edh.salesGroup;
			//data.salesGroup = salesGroup;
			//query += ' AND c.Sales_Site__r.SalesGroup_String__c = :salesGroup';
			query += ' GROUP BY c.Customer__c, c.Sales_Site__c, c.Material_PHL1__c, c.Plant__c';
		} else {
			query += ' GROUP BY c.Customer__c, c.Sales_Site__c, c.Material_PHL1__c';
		}
		System.debug('::' + dateFrom + ',' + dateTo + ',' + accountIds + ',' + siteIds + ',' + data.plant);
		System.debug('query:::' + query);
		Set<Id> salesSiteMap = new Set<Id>();
		// Query the COPA_Aggregates
		List<AggregateResult> qas = Database.query(query);
		System.debug('query result:::' + qas);
		Map<String, decimal> q = new Map<String, decimal>();
		q.put('deliveryHours', 0);
		q.put('shotHours', 0);
		q.put('distance', 0);
		q.put('units', 0);
		q.put('invoices', 0);
		q.put('netRevenue', 0);
		q.put('costOfGoodsSold', 0);
		q.put('costOfGoodsSoldST', 0);
		for (AggregateResult qa : qas) {
			q.put('deliveryHours', q.get('deliveryHours') + (decimal)qa.get('deliveryHours'));
			q.put('shotHours', q.get('shotHours') + (decimal)qa.get('shotHours'));
			q.put('distance', q.get('distance') + (decimal)qa.get('distance'));
			q.put('units', q.get('units') + (decimal)qa.get('units'));
			q.put('invoices', q.get('invoices') + (decimal)qa.get('invoices'));
			q.put('netRevenue', q.get('netRevenue') + (decimal)qa.get('netRevenue'));
			q.put('costOfGoodsSold', q.get('costOfGoodsSold') + (decimal)qa.get('costOfGoodsSold'));
			q.put('costOfGoodsSoldST', q.get('costOfGoodsSoldST') + (decimal)qa.get('costOfGoodsSoldST'));
			salesSiteMap.add((String)qa.get('salesSiteId'));
		}
		//system.debug('Lucian hideZero: ->' + hideZero + '<->' + q.get('netRevenue') + '<-');
		//if (hideZero && q.get('netRevenue') == 0) {
		//	data.netRevenue = new CurrencyData(currencyIsoCode, 0);
		//	return data;
		//}
		
		Account customer = null;
		if (accountIds.size() == 1) {
			customer = [SELECT Id, Account_Group__c, Name, Name_2__c, SAP_Account_Number__c, ParentId, Parent.Name FROM Account WHERE Id IN :accountIds LIMIT 1];
			if(accountIds.size() > 0) {
				if(data.customerName == null) {
					data.customerName = customer.Name;
					data.customerName2 = customer.Name_2__c;
					data.sapCustomerNumber = customer.SAP_Account_Number__c;
					if (customer.ParentId != null) {
						data.customerParentId = customer.ParentId;
						data.parentName = customer.Parent.Name;
					} else {
						data.customerParentId = '';
						data.parentName = '';
					}
				}
			}
		} else if (accountIds.size() > 1) {
			List<Account> customersList = [SELECT Id, Account_Group__c, Name, Name_2__c, SAP_Account_Number__c, ParentId, Parent.Name FROM Account WHERE Id IN :accountIds];
			String customersNames = '';
			for (Account a : customersList) {
				if (customersNames != '') {
					customersNames += ', ' + a.Name;
				} else {
					customersNames += a.Name;
				}
			}
			data.customerName = customersNames;
		}
		
		
		Sales_Site__c site = null;
		if (siteIds.size() == 1) {
			site = [Select Name, Delivery_Hours_Rate__c, Shot_Service_Hours_Rate__c, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id IN :siteIds];
			if (data.siteName == null || data.regionName == null || data.companyName == null) {
				data.companyName = site.Company_Site__r.Name;
				data.regionName = site.Region_Site__r.Name;
				data.siteName = site.Name;
				data.RegionId = site.Region_Site__c;
				data.CompanyId = site.Company_Site__c;
			}
		} else if (siteIds.size() > 0) {
			site = [Select Name, Region__c, Delivery_Hours_Rate__c, Shot_Service_Hours_Rate__c, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id = :new list<Id>(siteIds)[0]];
			List<Sales_Site__c> sitesList = [Select Name, Region__c, Delivery_Hours_Rate__c, Shot_Service_Hours_Rate__c, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id IN :siteIds];
			String salesSiteNames = '';
			Set<String> sitesNamesSet = new Set<String>();
			for (Sales_Site__c ss : sitesList) {
				sitesNamesSet.add(ss.Name);
			}
			salesSiteNames = String.valueOf(sitesNamesSet);
			salesSiteNames = salesSiteNames.substring(1,salesSiteNames.length() - 1);
			data.siteName= salesSiteNames;
		}
		
		// Sites for PCA / Cost_Driver_Entry__c
		List<Id> aggSites = new List<Id>();
		if (siteIds.size() == 1)
			aggSites = new list<Id>(edh.siteIds);
		else
			//aggSites.addAll(salesSiteIds);
			aggSites.addAll(salesSiteMap);
		
		// Get the regionIds			
		List<Id> regionIds = new List<Id>();
		for (Sales_Site__c ssc : [SELECT Region_Site__c FROM Sales_Site__c WHERE Id in :salesSiteMap]) {
			if (ssc.Region_Site__c != null) {
				regionIds.add(ssc.Region_Site__c);
			}
		}
		
		// Query the PCAs
		AggregateResult pcas = null;
		try {
			pcas = [SELECT
					  SUM(c.Invoice_Total__c) invoices,
					  SUM(c.Miles_Total__c) miles,
					  SUM(c.Rev_Exp_Total__c) netRevenue,
					  SUM(c.Total_Hrs_Total__c) totalHours,
					  SUM(c.Pounds_Total__c) pounds,
					  SUM(c.MHrs__c) mHrs,
					  SUM(c.Total_Hrs__c) tHrs,
					  // part 2
					  SUM(c.Miles__c) sumMiles,
					  SUM(c.Pounds__c) sumLbs,
					  SUM(c.Invoice__c) sumInv,
					  SUM(c.Rev_Exp__c) sumNr,
					  SUM(c.Total_Hrs_Reg__c) totalHrsReg,
					  SUM(c.Miles_Reg__c) milesReg,
					  SUM(c.Pounds_Reg__c) poundsReg,
					  SUM(c.Invoice_Reg__c) invoicesReg,
					  SUM(c.Rev_Exp_Reg__c) nrReg
					FROM PCA__c c
					WHERE c.Post_Month__c >= :dateFrom
					  AND c.Post_Month__c <= :dateTo
					  AND c.Sales_Site__c in :aggSites];
		} catch (Exception ex) { }
		
		AggregateResult spcas = null;
		try {
			string spcasQ = 'SELECT ' +
					 'SUM(c.Invoice_Total__c) invoices, ' +
					 'SUM(c.Miles_Total__c) miles, ' +
					 'SUM(c.Rev_Exp_Total__c) netRevenue, ' +
					 'SUM(c.Total_Hrs_Total__c) totalHours, ' +
					 'SUM(c.Pounds_Total__c) pounds, ' +
					 'SUM(c.MHrs__c) mHrs, ' +
					 'SUM(c.Total_Hrs__c) tHrs, ' +
					  // part 2
					 'SUM(c.Miles__c) sumMiles, ' +
					 'SUM(c.Pounds__c) sumLbs, ' +
					 'SUM(c.Invoice__c) sumInv, ' +
					 'SUM(c.Rev_Exp__c) sumNr, ' +
					 'SUM(c.Total_Hrs_Reg__c) totalHrsReg, ' +
					 'SUM(c.Miles_Reg__c) milesReg, ' +
					 'SUM(c.Pounds_Reg__c) poundsReg, ' +
					 'SUM(c.Invoice_Reg__c) invoicesReg, ' +
					 'SUM(c.Rev_Exp_Reg__c) nrReg ' +
					 'FROM PCA__c c ' +
					 'WHERE c.Post_Month__c >= :dateFrom ' +
					 'AND c.Post_Month__c <= :dateTo '+
					 'AND c.Sales_Site__c in :salesSiteMap';
			spcas = database.query(spcasQ);
		} catch (Exception ex) { }
		
		AggregateResult rpcas = null;
		try {
			rpcas = [SELECT
					  SUM(c.Invoice_Total__c) invoices,
					  SUM(c.Miles_Total__c) miles,
					  SUM(c.Rev_Exp_Total__c) netRevenue,
					  SUM(c.Total_Hrs_Total__c) totalHours,
					  SUM(c.Pounds_Total__c) pounds,
					  SUM(c.MHrs__c) mHrs,
					  SUM(c.Total_Hrs__c) tHrs,
					  // part 2
					  SUM(c.Miles__c) sumMiles,
					  SUM(c.Pounds__c) sumLbs,
					  SUM(c.Invoice__c) sumInv,
					  SUM(c.Rev_Exp__c) sumNr,
					  SUM(c.Total_Hrs_Reg__c) totalHrsReg,
					  SUM(c.Miles_Reg__c) milesReg,
					  SUM(c.Pounds_Reg__c) poundsReg,
					  SUM(c.Invoice_Reg__c) invoicesReg,
					  SUM(c.Rev_Exp_Reg__c) nrReg
					FROM PCA__c c
					WHERE c.Post_Month__c >= :dateFrom
					  AND c.Post_Month__c <= :dateTo
					  AND c.Sales_Site__c in :regionIds];
		} catch (Exception ex) { }
		
		// Query for Cost_Driver_Entry__c (for rates)
		AggregateResult cdes = null;
		try {
			cdes = [SELECT
					  SUM(c.DELHRS__c) delSum,
					  SUM(c.DISTANCE__C) milesSum,
					  SUM(c.SHOTHRS__c) sumShot,
					  SUM(c.INVOICES__c) invSum,
					  SUM(c.REVENUE__C) nrSum,
					  SUM(c.Total_Cogs__c) sumCOGS,
					  SUM(c.UNITS__c) lbsSum
					 FROM Cost_Driver_Entry__c c
					WHERE c.Current_Month__c >= :dateFrom
					  AND c.Current_Month__c <= :dateTo
					  AND c.Sales_Site__c in :aggSites];
		} catch (Exception ex) {}
		
		AggregateResult scdes = null;
		try {
			string scdesQ = 'SELECT ' +
					  'SUM(c.DELHRS__c) delSum, ' +
					  'SUM(c.DISTANCE__C) milesSum, ' +
					  'SUM(c.SHOTHRS__c) sumShot, ' +
					  'SUM(c.INVOICES__c) invSum, ' +
					  'SUM(c.REVENUE__C) nrSum, ' +
					  'SUM(c.Total_Cogs__c) sumCOGS, ' +
					  'SUM(c.UNITS__c) lbsSum ' +
					 'FROM Cost_Driver_Entry__c c ' +
					'WHERE c.Current_Month__c >= :dateFrom ' +
					  'AND c.Current_Month__c <= :dateTo '+
					'AND c.Sales_Site__c in :salesSiteMap';
			scdes = database.query(scdesQ);
		} catch (Exception ex) {}
		
		AggregateResult rcdes = null;
		try {
			rcdes = [SELECT
					  SUM(c.DELHRS__c) delSum,
					  SUM(c.DISTANCE__C) milesSum,
					  SUM(c.SHOTHRS__c) sumShot,
					  SUM(c.INVOICES__c) invSum,
					  SUM(c.REVENUE__C) nrSum,
					  SUM(c.Total_Cogs__c) sumCOGS,
					  SUM(c.UNITS__c) lbsSum
					 FROM Cost_Driver_Entry__c c
					WHERE c.Current_Month__c >= :dateFrom
					  AND c.Current_Month__c <= :dateTo
					  AND c.Sales_Site__r.Region_Site__c in :regionIds];
		} catch (Exception ex) {}
		
		System.debug('Lucian rates (scdes):' + scdes);
		System.debug('Lucian rates (rcdes):' + rcdes);
		System.debug('Lucian rates (spcas):' + spcas);
		System.debug('Lucian rates (rpcas):' + rpcas);

		// Chunk 1
		data.deliveryHours = (q.get('deliveryHours') == null)?0:(Decimal)q.get('deliveryHours');
		data.shotHours = (q.get('shotHours') == null)?0:(Decimal)q.get('shotHours');
		data.totalHours = new CurrencyData(' ', data.deliveryHours + data.shotHours);
		data.distance = new CurrencyData(' ', (q.get('distance') == null)?0:(Decimal)q.get('distance'));
		data.units = new CurrencyData(' ', (q.get('units') == null)?0:(Decimal)q.get('units'));
		data.invoices = new CurrencyData(' ', (q.get('invoices') == null)?0:(Decimal)q.get('invoices'));
		data.indirectNetRevenue = new CurrencyData(' ', (q.get('netRevenue') == null)?0:(Decimal)q.get('netRevenue'));

		// Chunk 2
		data.revenueModifier = new CurrencyData(currencyIsoCode, 0);
		data.netRevenue = new CurrencyData(currencyIsoCode, (q.get('netRevenue') == null)?0:(Decimal)q.get('netRevenue'));
		data.costOfGoodsSold = new CurrencyData(currencyIsoCode, (q.get('costOfGoodsSold') == null)?0:(-(Decimal)q.get('costOfGoodsSold')));
		data.costOfGoodsSoldSeeThrough = new CurrencyData(currencyIsoCode, (q.get('costOfGoodsSoldST') == null)?0:-(Decimal)q.get('costOfGoodsSoldST'));
		
		// Chunk 3
		// If we calculate rates, calculate totals here
		data.indirectCostInvoices = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('invoices') == null)?0:(Decimal)pcas.get('invoices'));
		data.indirectCostMiles = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('miles') == null)?0:(Decimal)pcas.get('miles'));
		data.indirectCostNetRevenue = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('netRevenue') == null)?0:(Decimal)pcas.get('netRevenue'));
		data.indirectCostTotalHours = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('totalHours') == null)?0:(Decimal)pcas.get('totalHours'));
		data.indirectCostUnits = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('pounds') == null)?0:(Decimal)pcas.get('pounds'));
		data.indirectCosts = new CurrencyData(currencyIsoCode, data.indirectCostInvoices.value + data.indirectCostMiles.value + data.indirectCostNetRevenue.value + data.indirectCostTotalHours.value + data.indirectCostUnits.value);

		// Chunk 4
		data.grossMargin = new CurrencyData(currencyIsoCode, data.netRevenue.value - data.costOfGoodsSold.value);
		data.grossMarginPercentage = (data.netRevenue.value == 0)?0:((data.grossMargin.value/data.netRevenue.value)*100).setScale(2);
		data.grossMarginSeeThrough = new CurrencyData(currencyIsoCode, data.netRevenue.value - data.costOfGoodsSoldSeeThrough.value);
		data.grossMarginSeeThroughPercentage = (data.netRevenue.value == 0)?0:((data.grossMarginSeeThrough.value/data.netRevenue.value)*100).setScale(2);
		
		// Chunk 5
		decimal totalsts = 0;
		decimal unitssts = 0;
		/*if (shipToDatas != null)
			for (PandLData shipToData : shipToDatas) {
				if (shipToData != null) {
					if (shipToData.totalst != null)
						totalsts += shipToData.totalst;
					if (shipToData.unitsst != null)
						unitssts += shipToData.unitsst;
				}
			}
		*/
		try {
			data.totalst = (decimal)pcas.get('mHrs') + (decimal)pcas.get('tHrs');
		} catch (Exception ex) {
			data.totalst = 0;
		}
		try {
			data.unitsst = (decimal)cdes.get('delSum') + (decimal)cdes.get('sumShot');
		} catch (Exception ex) {
			data.unitsst = 0;
		}
		
		// Delivery rate
		decimal rVal = 0;
		try {
			/*if (salesSiteId == null && customerId == null && regionId != null)
				rVal = ((decimal)spcas.get('mHrs') + (decimal)spcas.get('tHrs') + totalsts) / ((decimal)scdes.get('delSum') + (decimal)scdes.get('sumShot') + unitssts);
			else*/
				rVal = ((decimal)pcas.get('mHrs') + (decimal)pcas.get('tHrs') + totalsts) / ((decimal)cdes.get('delSum') + (decimal)cdes.get('sumShot') + unitssts);
		} catch (Exception ex) {}
		if (rVal < 40)
			rVal = 40;
		data.deliveryHoursRate = new CurrencyData(currencyIsoCode, rVal);
		
		// Shot rate
		rVal = 0;
		try {
			/*if (salesSiteId == null && customerId == null && regionId != null)
				rVal = ((decimal)spcas.get('mHrs') + (decimal)spcas.get('tHrs') + totalsts) / ((decimal)scdes.get('delSum') + (decimal)scdes.get('sumShot') + unitssts);
			else*/
				rVal = ((decimal)pcas.get('mHrs') + (decimal)pcas.get('tHrs') + totalsts) / ((decimal)cdes.get('delSum') + (decimal)cdes.get('sumShot') + unitssts);
		} catch (Exception ex) {}
		if (rVal < 40)
			rVal = 40;
		data.shotHoursRate = new CurrencyData(currencyIsoCode, rVal);
		
		// Total Hours rate
		data.totalHoursRate = new CurrencyData(currencyIsoCode, 0);
		
		// Now, calculate totals
		data.directCostShotHrs = new CurrencyData(currencyIsoCode, data.shotHours * data.shotHoursRate.value);
		data.directCostDeliveryHrs = new CurrencyData(currencyIsoCode, data.deliveryHours * data.deliveryHoursRate.value);

		data.directCosts = new CurrencyData(currencyIsoCode, data.directCostShotHrs.value + data.directCostDeliveryHrs.value);
		data.contributionMargin = new CurrencyData(currencyIsoCode, data.grossMargin.value - data.directCosts.value);
		data.contributionMarginPercentage = (data.netRevenue.value == 0)?0:((data.contributionMargin.value/data.netRevenue.value)*100).setScale(2);

		// Materials		
		data.productGmData = new PandLData.ProductGMData(qas, currencyIsoCode);
		System.debug('data.productGmData:::' + data.productGmData);

		// Chunk 6

		// data.totalHoursRate is calculated
		data.siteTotalHrs = new CurrencyData(currencyIsoCode, data.totalHoursRate.value * data.totalHours.value);
		if (rcdes != null && rpcas != null && rpcas.get('tHrs') != null && rpcas.get('mHrs') != null && rcdes.get('delSum') != null && rcdes.get('sumShot') != null && ((decimal)rcdes.get('delSum') + (decimal)rcdes.get('sumShot') != 0)) 
			data.rateTotalHrs = new CurrencyData(currencyIsoCode, ((decimal)rpcas.get('tHrs') + (decimal)rpcas.get('mHrs')) / ((decimal)rcdes.get('delSum') + (decimal)rcdes.get('sumShot')));
		else
			data.rateTotalHrs = new CurrencyData(currencyIsoCode, 0);
		data.regionTotalHrs = new CurrencyData(currencyIsoCode, data.rateTotalHrs.value * data.totalHours.value);

		if (scdes != null && spcas != null && spcas.get('sumMiles') != null && scdes.get('milesSum') != null && (decimal)scdes.get('milesSum') != 0)
			data.distanceRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumMiles') / (decimal)scdes.get('milesSum'));
		else
			data.distanceRate = new CurrencyData(currencyIsoCode, 0);
		data.siteDistance = new CurrencyData(currencyIsoCode, data.distanceRate.value * data.distance.value);
		if (rcdes != null && rpcas != null && rpcas.get('sumMiles') != null && rcdes.get('milesSum') != null && (decimal)rcdes.get('milesSum') != 0)
			data.rateDistance = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumMiles') / (decimal)rcdes.get('milesSum'));
		else
			data.rateDistance = new CurrencyData(currencyIsoCode, 0);
		data.regionDistance = new CurrencyData(currencyIsoCode, data.rateDistance.value * data.distance.value);
	
		if (scdes != null && spcas != null && spcas.get('sumLbs') != null && scdes.get('lbsSum') != null && (decimal)scdes.get('lbsSum') != 0)
			data.unitsRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumLbs') / (decimal)scdes.get('lbsSum'));
		else
			data.unitsRate = new CurrencyData(currencyIsoCode, 0);
		data.siteUnits = new CurrencyData(currencyIsoCode, data.unitsRate.value * data.units.value);
		if (rcdes != null && rpcas != null && rpcas.get('sumLbs') != null && rcdes.get('lbsSum') != null && (decimal)rcdes.get('lbsSum') != 0)
			data.rateUnits = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumLbs') / (decimal)rcdes.get('lbsSum'));
		else
			data.rateUnits = new CurrencyData(currencyIsoCode, 0);
		data.regionUnits = new CurrencyData(currencyIsoCode, data.rateUnits.value * data.units.value);
	
		if (scdes != null && spcas != null && spcas.get('sumInv') != null && scdes.get('invSum') != null && (decimal)scdes.get('invSum') != 0)
			data.invoicesRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumInv') / (decimal)scdes.get('invSum'));
		else
			data.invoicesRate = new CurrencyData(currencyIsoCode, 0);
		data.siteInvoices = new CurrencyData(currencyIsoCode, data.invoicesRate.value * data.invoices.value);
		if (rcdes != null && rpcas != null && rpcas.get('sumInv') != null && rcdes.get('invSum') != null && (decimal)rcdes.get('invSum') != 0)
			data.rateInvoices = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumInv') / (decimal)rcdes.get('invSum'));
		else
			data.rateInvoices = new CurrencyData(currencyIsoCode, 0);
		data.regionInvoices = new CurrencyData(currencyIsoCode, data.rateInvoices.value * data.invoices.value);
	
		if (scdes != null && spcas != null && spcas.get('sumNr') != null && scdes.get('nrSum') != null && (decimal)scdes.get('nrSum') != 0)
			data.netRevenueRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumNr') / (decimal)scdes.get('nrSum'));
		else
			data.netRevenueRate = new CurrencyData(currencyIsoCode, 0);
		data.siteNetRev = new CurrencyData(currencyIsoCode, data.netRevenueRate.value * data.indirectNetRevenue.value);
		if (rcdes != null && rpcas != null && rpcas.get('sumNr') != null && rcdes.get('nrSum') != null && (decimal)rcdes.get('nrSum') != 0)
			data.rateNetRevenue = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumNr') / (decimal)rcdes.get('nrSum'));
		else
			data.rateNetRevenue = new CurrencyData(currencyIsoCode, 0);
		data.regionNetRev = new CurrencyData(currencyIsoCode, data.rateNetRevenue.value * data.indirectNetRevenue.value);

		// Chunk 7	  
		data.totalHrsTotal = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.regionTotalHrs.value);
		data.distanceTotal = new CurrencyData(currencyIsoCode, data.siteDistance.value + data.regionDistance.value);
		data.unitsTotal	= new CurrencyData(currencyIsoCode, data.siteUnits.value + data.regionUnits.value);
		data.invoicesTotal = new CurrencyData(currencyIsoCode, data.siteInvoices.value + data.regionInvoices.value);
		data.netRevTotal   = new CurrencyData(currencyIsoCode, data.siteNetRev.value + data.regionNetRev.value);
		
		data.total1 = new CurrencyData(currencyIsoCode, data.totalHours.value + data.distance.value + data.units.value + data.invoices.value + data.netRevenue.value);
		data.total2 = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
		data.total3 = new CurrencyData(currencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
		data.total4 = new CurrencyData(currencyIsoCode, 0);//data.companyTotalHrs.value + data.companyDistance.value + data.companyUnits.value + data.companyInvoices.value + data.companyNetRev.value);
		data.total5 = new CurrencyData(currencyIsoCode, data.totalHrsTotal.value + data.distanceTotal.value + data.unitsTotal.value + data.invoicesTotal.value + data.netRevTotal.value);
								   
		data.ebit = new CurrencyData(currencyIsoCode, data.contributionMargin.value - data.total5.value);
		data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;
		data.ebitWith = new CurrencyData(currencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
		data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;

		data.ConvertToCurrency(edh.currencyUsed);
		
		System.debug('Lucian data:' + data);

		return data;
	}
	
	
	
	public static String createCopaAggregateResults(EBITDataHelper edh) {
		// After finidng all the search criteria, create the query string
		Date dateFrom = edh.dateFrom;
		Date dateTo = edh.dateTo;
		
		String query = 'SELECT Id,' +
						 'customer__r.Account_manager__c, customer__r.Industry,' +
						 'sales_site__r.sales_office__r.name, sales_site__r.Company_Site__r.Name,' +
						 'Material_PHL1__c, ' +
						 'Sales_Site__c, Sales_Site__r.Name,' +
						 'DELHRS__c, ' +
						 'SHOTHRS__c, ' +
						 'MILES__c, ' +
						 'LBS__c, ' +
						 'INVOICES__c, ' +
						 'Net_Revenue__c, ' +
						 'True_Total_Cogs__c, ' +
						 'COGS_See_Through__c ' +
						 'FROM COPA_Aggregate__c c';
						 
		query += ' WHERE c.Current_Month__c >= :dateFrom AND c.Current_Month__c <= :dateTo';
		
		Set<Id> accountIds = edh.accountIds;
		if(edh.accountIds.size() > 0) {
			query += ' AND c.Customer__c in :accountIds';
		}
		Set<Id> siteIds = edh.siteIds;
		if (edh.siteIds.size() > 0) {
			query += ' AND c.Sales_Site__c in :siteIds';
		}
		
		System.debug('qas:dateFrom' + dateFrom);
		System.debug('qas:dateTo' + dateTo);
		System.debug('qas:accountIds' + accountIds);
		System.debug('qas:siteIds' + siteIds);
		
		return query;
	}
	
	public static List<PCA__c> createPCAResults(EBITDataHelper edh) {
		// After finidng all the search criteria, create the query string
		Date dateFrom = edh.dateFrom;
		Date dateTo = edh.dateTo;
		List<PCA__c> pcas = [SELECT
					  Invoice_Total__c,
					  Miles_Total__c,
					  Rev_Exp_Total__c,
					  Total_Hrs_Total__c,
					  Pounds_Total__c,
					  MHrs__c,
					  Total_Hrs__c,
					  // part 2
					  Miles__c,
					  Pounds__c,
					  Invoice__c,
					  Rev_Exp__c,
					  Total_Hrs_Reg__c,
					  Miles_Reg__c,
					  Pounds_Reg__c,
					  Invoice_Reg__c,
					  Rev_Exp_Reg__c,
					  Sales_Site__r.Name
					FROM PCA__c c
					WHERE c.Post_Month__c >= :dateFrom
					  AND c.Post_Month__c <= :dateTo
					  AND c.Sales_Site__c in :getIdsForPCA_CDE(edh)];

		return pcas;
	}
	
	public static List<Cost_Driver_Entry__c> createCDEResults(EBITDataHelper edh) {
		// After finidng all the search criteria, create the query string
		Date dateFrom = edh.dateFrom;
		Date dateTo = edh.dateTo;
		
		List<Cost_Driver_Entry__c> cdes = [SELECT
					  c.DELHRS__c,
					  c.DISTANCE__c,
					  c.SHOTHRS__c,
					  c.INVOICES__c,
					  c.REVENUE__c,
					  c.Total_Cogs__c,
					  c.UNITS__c,
					  c.Sales_Site__r.Name
					 FROM Cost_Driver_Entry__c c
					WHERE c.Current_Month__c >= :dateFrom
					  AND c.Current_Month__c <= :dateTo
					  AND c.Sales_Site__c in :getIdsForPCA_CDE(edh)];
		System.debug('cde11::' + cdes);
		return cdes;
	}
	
	public static Set<Id> getIdsForPCA_CDE(EBITDataHelper edh) {
		Date dateFrom = edh.dateFrom;
		Date dateTo = edh.dateTo;
		
		Set<Id> accountIds = edh.accountIds;
		Set<Id> siteIds = edh.siteIds;

		
		String qasString = createCopaAggregateResults(edh);
		
		Set<Id> caIds = new Set<Id>();
		for (List<COPA_Aggregate__c> qas : Database.query(qasString)) {
			for (COPA_Aggregate__c ca : qas) {
				caIds.add(ca.Sales_Site__c);
			}
		}
		
		// Sites for PCA / Cost_Driver_Entry__c
		Set<Id> aggSites = new Set<Id>();
		if (siteIds.size() == 1)
			aggSites = siteIds;
		else
			//aggSites.addAll(salesSiteIds);
			aggSites.addAll(caIds);
		
		// Get the regionIds			
		List<Id> regionIds = new List<Id>();
		for (Sales_Site__c ssc : [SELECT Region_Site__c FROM Sales_Site__c WHERE Id in :caIds]) {
			if (ssc.Region_Site__c != null) {
				regionIds.add(ssc.Region_Site__c);
			}
		}
		
		Set<Id> allIds = new Set<Id>();
		allIds.addAll(caIds);
		allIds.addAll(aggSites);
		allIds.addAll(regionIds);
		
		System.debug('caIds::' + caIds);
		System.debug('aggSites11:' + aggSites);
		System.debug('regionIds11:' + regionIds);
		System.debug('allIds11:::' + allIds);
		return allIds;
	}

}