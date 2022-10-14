public with sharing class RealizationReport {
	
	public Quote__c dummyQuote { get; set; }
	
	public boolean PricesGenerated { get; set; }
	
	public String customerNumber { get; set; }
	
	private List<LineItem> auxLines = new List<LineItem>();
	
	public List<SelectOption> availableAccReps { get; set; }
	public List<String> accReps { get; set; }
	public List<SelectOption> availableSalesMs { get; set; }
	public List<String> salesMs { get; set; }
	
	public boolean accountEditable {
		get {
			return ((accReps == null || accReps.size() == 0) && 
					(salesMs == null || salesMs.size() == 0) &&  
					(CompanyId == null || CompanyId == '') && 
					(RegionId == null || RegionId == '') && 
					(SalesSiteId == null || SalesSiteId == ''));
		}
	}
	
	public void ClearAccount() {
		if (!accountEditable)
		{
			dummyQuote.Customer__c = null;
			customerNumber = '';
		}
	}
	
	public void ClearRest() {
		if (dummyQuote.Customer__c != null)
		{
			accReps = new List<String>();
			salesMs = new List<String>();
			CompanyId = '';
			RegionId = '';
			SalesSiteId = '';
		}
	}
	
	public void ResetFilters() {
		dummyQuote.Price_Valid_From__c = Date.today().addyears(-1);
		dummyQuote.Price_Valid_To__c = Date.today();
		dummyQuote.Customer__c = null;
		customerNumber = '';
		accReps = new List<String>();
		salesMs = new List<String>();
		CompanyId = '';
		RegionId = '';
		SalesSiteId = '';
		PHL1Id = '';
		PHL2Id = '';
		PHL3Id = '';
		MaterialId = '';
	}
	
	public RealizationReport() {
		PricesGenerated = false; 
		dummyQuote = new Quote__c();
		dummyQuote.Price_Valid_From__c = Date.today().addyears(-1);
		dummyQuote.Price_Valid_To__c = Date.today();
		
		availableAccReps = new List<SelectOption>();
		for (Schema.PicklistEntry spe : Account.Account_Manager__c.getDescribe().getPicklistValues())
			availableAccReps.add(new SelectOption(spe.getLabel(), spe.getValue()));
			
		availableSalesMs = new List<SelectOption>();
		for (Schema.PicklistEntry spe : Account.Sales_Manager__c.getDescribe().getPicklistValues())
			availableSalesMs.add(new SelectOption(spe.getLabel(), spe.getValue()));
			
		CompanyId = ''; 
		companyIdsP = new List<SelectOption>();
		companyIdsP.add(new SelectOption('', '-- Any --'));
		List<Sales_Site__c> companies = [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = null AND Company_Site__c = null ORDER BY Name];
		for (Sales_Site__c company : companies)
			companyIdsP.add(new SelectOption(company.Id, company.Name));
			
		GetRegions();
		
		PHL1Id = ''; 
		PHL1IdsP = new List<SelectOption>();
		PHL1IdsP.add(new SelectOption('', '-- Any --'));
		List<Product_Grouping__c> PHL1s = [SELECT Id, Name FROM Product_Grouping__c ORDER BY Name];
		for (Product_Grouping__c PHL1 : PHL1s)
			PHL1IdsP.add(new SelectOption(PHL1.Name, PHL1.Name));
			
		GetPHL2s();
		
		GroupByFirst = 'Organization';
		GroupBySecond = '';
		GroupByThird = '';
		
		StepNumber = 0;
		ShowCriteriaButton = true;
	}
	
	public String PHL1Id { get; set; }
	private List<SelectOption> PHL1IdsP;
	public List<SelectOption> PHL1Ids {
		get { return PHL1IdsP; }
	}
	
	public void GetPHL2s() {
		PHL2Id = '';
		PHL2IdsP = new List<SelectOption>();
		PHL2IdsP.add(new SelectOption('', '-- Any --'));
		if (PHL1Id != null && PHL1Id != '') {
			List<PHL2__c> PHL2s = [SELECT Id, PHL2__c, Full_PHL2__c FROM PHL2__c WHERE PHL1__c = :PHL1Id ORDER BY Full_PHL2__c];
			for (PHL2__c PHL2 : PHL2s)
				PHL2IdsP.add(new SelectOption(PHL2.PHL2__c, PHL2.Full_PHL2__c));
		}
		GetPHL3s();
	}
	
	public String PHL2Id { get; set; }
	private List<SelectOption> PHL2IdsP;
	public List<SelectOption> PHL2Ids {
		get { return PHL2IdsP; }
	}
	
	public void GetPHL3s() {
		PHL3Id = '';
		PHL3IdsP = new List<SelectOption>();
		PHL3IdsP.add(new SelectOption('', '-- Any --'));
		if (PHL2Id != null && PHL2Id != '') {
			List<PHL3__c> PHL3s = [SELECT Id, PHL3__c, Full_PHL3__c FROM PHL3__c WHERE PHL2__c = :PHL2Id AND PHL1__c = :PHL1Id ORDER BY Full_PHL3__c];
			for (PHL3__c PHL3 : PHL3s)
				PHL3IdsP.add(new SelectOption(PHL3.PHL3__c, PHL3.Full_PHL3__c));
		}
		GetMaterials();
	}
	
	public String PHL3Id { get; set; }
	private List<SelectOption> PHL3IdsP;
	public List<SelectOption> PHL3Ids {
		get { return PHL3IdsP; }
	}

	public void GetMaterials() {
		MaterialId = '';
		MaterialIdsP = new List<SelectOption>();
		MaterialIdsP.add(new SelectOption('', '-- Any --'));
		if (PHL3Id != null && PHL3Id != '') {
			List<Material_Item__c> Materials = [SELECT Id, Name FROM Material_Item__c WHERE PHL3__c = :PHL3Id AND PHL2__c = :PHL2Id AND PHL1__c = :PHL1Id ORDER BY Name];
			for (Material_Item__c Material : Materials)
				MaterialIdsP.add(new SelectOption(Material.Id, Material.Name));
		}
	}
	
	public String MaterialId { get; set; }
	private List<SelectOption> MaterialIdsP;
	public List<SelectOption> MaterialIds {
		get { return MaterialIdsP; }
	}
	
	public String materialCode { get; set; }
	public void MaterialCodeSet() {
		if (materialCode == null || materialCode == '')
			MaterialId = '';
		else {
			List<Material_Item__c> mi = [SELECT Id FROM Material_Item__c WHERE Material_Code__c = :materialCode];
			if (mi.size() == 0)
				MaterialId = '';
			else
				MaterialId = mi[0].Id;
		}
	}

	public String CompanyId { get; set; }
	private List<SelectOption> companyIdsP;
	public List<SelectOption> CompanyIds {
		get { return companyIdsP; }
	}
	
	public void GetRegions() {
		RegionId = '';
		regionIdsP = new List<SelectOption>();
		regionIdsP.add(new SelectOption('', '-- Any --'));
		if (CompanyId != null && CompanyId != '') {
			List<Sales_Site__c> regions = [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = null AND Company_Site__c = :CompanyId ORDER BY Name];
			for (Sales_Site__c region : regions)
				regionIdsP.add(new SelectOption(region.Id, region.Name));
		}
		GetSalesSites();
	}
	
	public String RegionId { get; set; }
	private List<SelectOption> regionIdsP;
	public List<SelectOption> RegionIds {
		get { return regionIdsP; }
	}
	
	public void GetSalesSites() {
		SalesSiteId = '';
		salesSiteIdsP = new List<SelectOption>();
		salesSiteIdsP.add(new SelectOption('', '-- Any --'));
		if (RegionId != null && RegionId != '') {
			List<Sales_Site__c> salesSites = [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = :RegionId AND Company_Site__c = :CompanyId ORDER BY Name];
			for (Sales_Site__c salesSite : salesSites)
				salesSiteIdsP.add(new SelectOption(salesSite.Id, salesSite.Name));
		}
		ClearAccount();
	}
	
	public String SalesSiteId { get; set; }
	private List<SelectOption> salesSiteIdsP;
	public List<SelectOption> SalesSiteIds {
		get { return salesSiteIdsP; }
	}
	
	public void CustomerNumberChanged() {
		if (customerNumber == null || customerNumber == '')
			dummyQuote.Customer__c = null;
		else {
			List<Account> accounts = [SELECT Id FROM Account WHERE SAP_Account_Number__c = :customerNumber];
			if (accounts.size() > 0) 
				dummyQuote.Customer__c = accounts[0].Id;
			else
				dummyQuote.Customer__c = null;
		}
		ClearRest();
	}
	
	public void CustomerChanged() {
		if (dummyQuote.Customer__c != null) {
			Account account = [SELECT SAP_Account_Number__c FROM Account WHERE Id = :dummyQuote.Customer__c];
			customerNumber = account.SAP_Account_Number__c;
		} else {
			customerNumber = '';
		}
		ClearRest();
	}
	
	public List<SelectOption> GetGroupByProductList() {
		List<SelectOption> sos = new List<SelectOption>();
		sos.add(new SelectOption('PHL1', 'PHL1'));
		sos.add(new SelectOption('PHL2', 'PHL2'));
		sos.add(new SelectOption('PHL3', 'PHL3'));
		sos.add(new SelectOption('Material Code', 'Material Code'));
		return sos;
	}
	public string GroupByProduct { get; set; }
	
	public List<SelectOption> GetGroupByOrganizationList() {
		List<SelectOption> sos = new List<SelectOption>();
		sos.add(new SelectOption('Company', 'Company'));
		sos.add(new SelectOption('Region', 'Region'));
		sos.add(new SelectOption('Sales Site', 'Sales Site'));
		return sos;
	}
	public string GroupByOrganization { get; set; }

	public List<SelectOption> GetGroupBySalesList() {
		List<SelectOption> sos = new List<SelectOption>();
		sos.add(new SelectOption('Sales Manager', 'Sales Manager'));
		sos.add(new SelectOption('Account Manager', 'Account Manager'));
		return sos;
	}
	public string GroupBySales { get; set; }
	
	public List<SelectOption> GetGroupByFirstList() {
		List<SelectOption> sos = new List<SelectOption>();
		sos.add(new SelectOption('Organization', 'Organization'));
		sos.add(new SelectOption('Product', 'Product'));
		sos.add(new SelectOption('Sales Structure', 'Sales Structure'));
		return sos;
	}
	public string GroupByFirst { get; set; }
	public void FirstSelected() {
		GroupBySecond = '';
		GroupByThird = '';
	}
	
	public List<SelectOption> GetGroupBySecondList() {
		List<SelectOption> sos = new List<SelectOption>();
		sos.add(new SelectOption('', '-- None --'));
		if (GroupByFirst != 'Sales Structure')
			sos.add(new SelectOption('Sales Structure', 'Sales Structure'));
		if (GroupByFirst != 'Organization')
			sos.add(new SelectOption('Organization', 'Organization'));
		if (GroupByFirst != 'Product')
			sos.add(new SelectOption('Product', 'Product'));
		return sos;
	}
	public string GroupBySecond { get; set; }
	public void SecondSelected() {
		GroupByThird = '';
	}
	
	public List<SelectOption> GetGroupByThirdList() {
		List<SelectOption> sos = new List<SelectOption>();
		sos.add(new SelectOption('', '-- None --'));
		if (GroupByFirst != 'Sales Structure' && GroupBySecond != 'Sales Structure')
			sos.add(new SelectOption('Sales Structure', 'Sales Structure'));
		if (GroupByFirst != 'Organization' && GroupBySecond != 'Organization')
			sos.add(new SelectOption('Organization', 'Organization'));
		if (GroupByFirst != 'Product' && GroupBySecond != 'Product')
			sos.add(new SelectOption('Product', 'Product'));
		return sos;
	}
	public string GroupByThird { get; set; }
	
	public boolean ShowCriteriaButton { get; set; }
	
	public void Generate() {
		
		if (dummyQuote.Customer__c == null) {
			GenerateBatch();
			return;
		}
		
		StepNumber = 0;
		try {

			Date fromDate = dummyQuote.Price_Valid_From__c;
			Date toDate = dummyQuote.Price_Valid_To__c;
			// Get the quotes
			string fromQuotesQuery = 'SELECT Id, Customer__c, Date_Published_to_SAP__c FROM Quote__c WHERE Price_Valid_From__c <= :fromDate AND Price_Valid_To__c >= :fromDate';
			string toQuotesQuery = 'SELECT Id, Customer__c, Date_Published_to_SAP__c FROM Quote__c WHERE Price_Valid_From__c <= :toDate AND Price_Valid_To__c >= :toDate';
			if (SalesSiteId != null && SalesSiteId != '') {
				fromQuotesQuery += ' AND Sales_Organization_Primary__c = :SalesSiteId';
				toQuotesQuery += ' AND Sales_Organization_Primary__c = :SalesSiteId';
			} else if (RegionId != null && RegionId != '') {
				fromQuotesQuery += ' AND Sales_Organization_Primary__r.Region_Site__c = :RegionId';
				toQuotesQuery += ' AND Sales_Organization_Primary__r.Region_Site__c = :RegionId';
			} else if (CompanyId != null && CompanyId != '') {
				fromQuotesQuery += ' AND Sales_Organization_Primary__r.Company_Site__c = :CompanyId';
				toQuotesQuery += ' AND Sales_Organization_Primary__r.Company_Site__c = :CompanyId';
			}
			if (dummyQuote.Customer__c != null) {
				Id cust = dummyQuote.Customer__c;
				fromQuotesQuery += ' AND Customer__c = :cust';
				toQuotesQuery += ' AND Customer__c = :cust';
			}
			if (salesMs != null && salesMs.size() > 0) {
				fromQuotesQuery += ' AND Customer__r.Sales_Manager__c in :salesMs';
				toQuotesQuery += ' AND Customer__r.Sales_Manager__c in :salesMs';
			}
			if (accReps != null && accReps.size() > 0) {
				fromQuotesQuery += ' AND Customer__r.Account_Manager__c in :accReps';
				toQuotesQuery += ' AND Customer__r.Account_Manager__c in :accReps';
			}
			List<Quote__c> fromQuotes = database.query(fromQuotesQuery);
			List<Quote__c> toQuotes = database.query(toQuotesQuery);
			
			Map<Id, Quote__c> fromQuotesMap = new Map<Id, Quote__c>();
			for (Quote__c q : fromQuotes)
				if (fromQuotesMap.containsKey(q.Customer__c)) {
					if (fromQuotesMap.get(q.Customer__c).Date_Published_to_SAP__c < q.Date_Published_to_SAP__c)
						fromQuotesMap.put(q.Customer__c, q);
				} else
					fromQuotesMap.put(q.Customer__c, q);
					
			Map<Id, Quote__c> toQuotesMap = new Map<Id, Quote__c>();
			for (Quote__c q : toQuotes)
				if (toQuotesMap.containsKey(q.Customer__c)) {
					if (toQuotesMap.get(q.Customer__c).Date_Published_to_SAP__c < q.Date_Published_to_SAP__c)
						toQuotesMap.put(q.Customer__c, q);
				} else
					toQuotesMap.put(q.Customer__c, q);
					
			fromQuotes = fromQuotesMap.values();
			toQuotes = toQuotesMap.values();
			// Get the code line items
			string fromLinesQuery = 'SELECT Id, Material_Item__c, Material_Item__r.Material_Code__c, Quote__r.Sales_Organization_Primary__c, Quote__r.Customer__c, UOM__c,' +
									' Quote__r.Customer__r.SAP_Account_Number__c, Actual_Price__c, Quantity__c, Per__c, PHL1__c, PHL2__c, PHL3__c, Material_Item__r.Base_Unit_of_Measue__c,' +
									' Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, Quote__r.Customer__r.Account_Manager__c,' +
									' Quote__r.RSM__r.Name, Quote__r.Opportunity__r.Owner.Name, Quote__r.Sales_Organization_Primary__r.Name, Material_Item__r.Name, Quote__r.Customer__r.Sales_Manager__c' +
									' FROM Quote_Line_Item__c WHERE Quote__c in :fromQuotes';
			string toLinesQuery  =  'SELECT Id, Material_Item__c, Material_Item__r.Material_Code__c, Quote__r.Sales_Organization_Primary__c, Quote__r.Customer__c, UOM__c,' + 
									' Quote__r.Customer__r.SAP_Account_Number__c, Actual_Price__c, Quantity__c, Per__c, PHL1__c, PHL2__c, PHL3__c, Material_Item__r.Base_Unit_of_Measue__c,' +
									' Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, Quote__r.Customer__r.Account_Manager__c,' +
									' Quote__r.RSM__r.Name, Quote__r.Opportunity__r.Owner.Name, Quote__r.Sales_Organization_Primary__r.Name, Material_Item__r.Name, Quote__r.Customer__r.Sales_Manager__c' +
									' FROM Quote_Line_Item__c WHERE Quote__c in :toQuotes';
			if (MaterialId != null && MaterialId != '') {
				fromLinesQuery += ' AND Material_Item__c = :MaterialId';
				toLinesQuery += ' AND Material_Item__c = :MaterialId';
			} else if (PHL3Id != null && PHL3Id != '') {
				fromLinesQuery += ' AND PHL3__c = :PHL3Id AND PHL2__c = :PHL2Id AND PHL1__c = :PHL1Id';
				toLinesQuery += ' AND PHL3__c = :PHL3Id AND PHL2__c = :PHL2Id AND PHL1__c = :PHL1Id';
			} else if (PHL2Id != null && PHL2Id != '') {
				fromLinesQuery += ' AND PHL2__c = :PHL2Id AND PHL1__c = :PHL1Id';
				toLinesQuery += ' AND PHL2__c = :PHL2Id AND PHL1__c = :PHL1Id';
			} else if (PHL1Id != null && PHL1Id != '') {
				fromLinesQuery += ' AND PHL1__c = :PHL1Id';
				toLinesQuery += ' AND PHL1__c = :PHL1Id';
			}
			Map<Id, Quote_Line_Item__c> fromLines = new Map<Id, Quote_Line_Item__c>((List<Quote_Line_Item__c>)database.query(fromLinesQuery));
			Map<Id, Quote_Line_Item__c> toLines = new Map<Id, Quote_Line_Item__c>((List<Quote_Line_Item__c>)database.query(toLinesQuery));
			
			// Generate list
			List<String> toUoms = new List<String>();
			List<Id> mItems = new List<Id>();
			Map<String, Quote_Line_Item__c> fromQLIMap = new Map<String, Quote_Line_Item__c>();
			Map<String, Quote_Line_Item__c> toQLIMap = new Map<String, Quote_Line_Item__c>();
			for (Quote_Line_Item__c fromQLI : fromLines.values())
				fromQLIMap.put(fromQLI.Material_Item__c + '-' + fromQLI.Quote__r.Sales_Organization_Primary__c + '-' + fromQLI.Quote__r.Customer__c, fromQLI);
			for (Quote_Line_Item__c toQLI : toLines.values())
				toQLIMap.put(toQLI.Material_Item__c + '-' + toQLI.Quote__r.Sales_Organization_Primary__c + '-' + toQLI.Quote__r.Customer__c, toQLI);
			
			Map<Id, Quote_Line_Item__c> associations = new Map<Id, Quote_Line_Item__c>();
			for (string qliKey : fromQLIMap.keyset()) {
				if (toQLIMap.containsKey(qliKey)) {
					Quote_Line_Item__c fromQLI = fromQLIMap.get(qliKey);
					Quote_Line_Item__c toQLI = toQLIMap.get(qliKey);
					if (fromQLI.UoM__c != toQLI.UoM__c)
					{
						toUoms.add(toQLI.UoM__c);
						mItems.add(fromQLI.Material_Item__c);
					}
					associations.put(fromQLI.Id, toQLI);
				}
			}
						
			System.debug('Lucian [317] : ' + associations);
			
			List<Alternate_Unit_of_Measure__c> aums = [SELECT AUn__c, BUn__c, X__c, Y__c, Material_Item__c FROM Alternate_Unit_of_Measure__c WHERE AUn__c in :toUoms AND Material_Item__c in :mItems];
			auxLines = new List<LineItem>();
			for (Id fromId : associations.keyset()) {
				LineItem li = new LineItem();
				li.AccountNumber = associations.get(fromId).Quote__r.Customer__r.SAP_Account_Number__c;
				li.CurrentVolume = associations.get(fromId).Quantity__c;
				li.MaterialCode = associations.get(fromId).Material_Item__r.Material_Code__c;
				li.PHL1 = associations.get(fromId).PHL1__c;
				li.PHL2 = associations.get(fromId).PHL2__c;
				li.PHL3 = associations.get(fromId).PHL3__c;
				if (associations.get(fromId).UOM__c == fromLines.get(fromId).UOM__c) {
					li.UOM = associations.get(fromId).UOM__c;
					li.Per = associations.get(fromId).Per__c;
					if (fromLines.get(fromId).Actual_Price__c != null && associations.get(fromId).Per__c != null && fromLines.get(fromId).Per__c != null)
						li.PreviousPrice = fromLines.get(fromId).Actual_Price__c * associations.get(fromId).Per__c / fromLines.get(fromId).Per__c;
					if (associations.get(fromId).Actual_Price__c != null)
						li.CurrentPrice = associations.get(fromId).Actual_Price__c;
				} else {
					li.UOM = associations.get(fromId).Material_Item__r.Base_Unit_of_Measue__c;
					li.Per = associations.get(fromId).Per__c;
					for (Alternate_Unit_of_Measure__c aum : aums) {
						if (aum.Material_Item__c == associations.get(fromId).Material_Item__c && aum.BUn__c == li.UOM && aum.AUn__c == fromLines.get(fromId).UOM__c) {
							li.PreviousPrice = fromLines.get(fromId).Actual_Price__c * aum.X__c / aum.Y__c * associations.get(fromId).Per__c / fromLines.get(fromId).Per__c;
						}
						if (aum.Material_Item__c == associations.get(fromId).Material_Item__c && aum.BUn__c == li.UOM && aum.AUn__c == associations.get(fromId).UOM__c) {
							li.CurrentPrice = associations.get(fromId).Actual_Price__c * aum.X__c / aum.Y__c;
						}
					}
				}
				li.newQLI = associations.get(fromId);
				if (li.PreviousPrice != 0 && li.CurrentPrice != 0 && li.CurrentVolume != 0)
					auxLines.add(li);
			}
			
			System.debug('Lucian [336] : ' + auxLines);
			
			// First level of grouping
			Map<String, GroupingLevel> auxGroupings = new Map<String, GroupingLevel>();
			if (GroupByFirst == 'Organization') {
				if (GroupByOrganization == 'Company') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name)) {
							auxGroupings.put('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, new GroupingLevel());
							auxGroupings.get('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name).Name = 'Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name;
						}
						auxGroupings.get('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name).Lines.add(li);
					}
				}
				if (GroupByOrganization == 'Region') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name)) {
							auxGroupings.put('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, new GroupingLevel());
							auxGroupings.get('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name).Name = 'Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name; 
						}
						auxGroupings.get('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name).Lines.add(li);
					}
				}
				if (GroupByOrganization == 'Sales Site') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name)) {
							auxGroupings.put('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name, new GroupingLevel());
							auxGroupings.get('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name).Name = 'Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name; 
						}
						auxGroupings.get('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name).Lines.add(li);
					}
				}
			}
			if (GroupByFirst == 'Product') {
				if (GroupByProduct == 'PHL1') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('PHL1: ' + li.newQLI.PHL1__c)) {
							auxGroupings.put('PHL1: ' + li.newQLI.PHL1__c, new GroupingLevel());
							auxGroupings.get('PHL1: ' + li.newQLI.PHL1__c).Name = 'PHL1: ' + li.newQLI.PHL1__c;
						}
						auxGroupings.get('PHL1: ' + li.newQLI.PHL1__c).Lines.add(li);
					}
				}
				if (GroupByProduct == 'PHL2') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c)) {
							auxGroupings.put('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c, new GroupingLevel());
							auxGroupings.get('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c).Name = 'PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c;
						}
						auxGroupings.get('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c).Lines.add(li);
					}
				}
				if (GroupByProduct == 'PHL3') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c)) {
							auxGroupings.put('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c, new GroupingLevel());
							auxGroupings.get('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c).Name = 'PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c;
						}
						auxGroupings.get('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c).Lines.add(li);
					}
				}
				if (GroupByProduct == 'Material Code') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('Material Item: ' + li.newQLI.Material_Item__r.Name)) {
							auxGroupings.put('Material Item: ' + li.newQLI.Material_Item__r.Name, new GroupingLevel());
							auxGroupings.get('Material Item: ' + li.newQLI.Material_Item__r.Name).Name = 'Material Item: ' + li.newQLI.Material_Item__r.Name; 
						}
						auxGroupings.get('Material Item: ' + li.newQLI.Material_Item__r.Name).Lines.add(li);
					}
				}
			}
			if (GroupByFirst == 'Sales Structure') {
				if (GroupBySales == 'Sales Manager') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c)) {
							auxGroupings.put('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c, new GroupingLevel());
							auxGroupings.get('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c).Name = 'Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c;
						} 
						auxGroupings.get('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c).Lines.add(li);
					}
				}
				if (GroupBySales == 'Account Manager') {
					for (LineItem li : auxLines) {
						if (!auxGroupings.containsKey('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c)) {
							auxGroupings.put('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c, new GroupingLevel());
							auxGroupings.get('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c).Name = 'Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c;
						}
						auxGroupings.get('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c).Lines.add(li);
					}
				}
			}
			Lines = auxGroupings.values();
			
			// Second level of grouping
			if (GroupBySecond != null && GroupBySecond != '') {
				string GroupBy = '';
				if (GroupBySecond == 'Product')
					GroupBy = GroupByProduct;
				if (GroupBySecond == 'Sales Structure')
					GroupBy = GroupBySales;
				if (GroupBySecond == 'Organization')
					GroupBy = GroupByOrganization;
				for (GroupingLevel gl : Lines)
					gl.GroupLines(GroupBySecond, GroupBy, false);
					
				// Third level of grouping
				if (GroupByThird != null && GroupByThird != '') {
					GroupBy = '';
					if (GroupByThird == 'Product')
						GroupBy = GroupByProduct;
					if (GroupByThird == 'Sales Structure')
						GroupBy = GroupBySales;
					if (GroupByThird == 'Organization')
						GroupBy = GroupByOrganization;
					for (GroupingLevel gl : Lines)
						gl.GroupLines(GroupByThird, GroupBy, true);
				}
			}
			
			// Wrap up
			CalculateAggregates();
			PricesGenerated = true;
			
			System.debug('Lucian [459] : ' + Lines);
		} catch (Exception ex) {
			ApexPages.addMessages(ex);
		}
	}
	
	public integer StepNumber { get; set; }
	public boolean StepNumber0 { get { return StepNumber == 0; } }
	public boolean StepNumber1 { get { return StepNumber == 1; } }
	public boolean StepNumber2 { get { return StepNumber == 2; } }
	public boolean StepNumber3 { get { return StepNumber == 3; } }
	public boolean StepNumber4 { get { return StepNumber == 4; } }
	 
	private Id BatchJob1Id = null;
	private Id BatchJob2Id = null;
	private Id BatchJob3Id = null;
	
	public String Step1Text { get; set; }
	public String Step2Text { get; set; }
	public String Step3Text { get; set; }
	public String Step4Text { get; set; }
	
	public void GenerateBatch() {
		PricesGenerated = false;
		BatchJob1Id = null;
		BatchJob2Id = null;
		BatchJob3Id = null;
		Date fromDate = dummyQuote.Price_Valid_From__c;
		
		string fromQuotesQuery = 'SELECT Id, Customer__c, Date_Published_to_SAP__c FROM Quote__c WHERE Price_Valid_From__c <= ' + string.valueOf(fromDate) + ' AND Price_Valid_To__c >= ' + string.valueOf(fromDate);
		if (SalesSiteId != null && SalesSiteId != '')
			fromQuotesQuery += ' AND Sales_Organization_Primary__c = \'' + SalesSiteId + '\'';
		else if (RegionId != null && RegionId != '')
			fromQuotesQuery += ' AND Sales_Organization_Primary__r.Region_Site__c = \'' + RegionId + '\'';
		else if (CompanyId != null && CompanyId != '')
			fromQuotesQuery += ' AND Sales_Organization_Primary__r.Company_Site__c = \'' + CompanyId + '\'';
		if (dummyQuote.Customer__c != null) {
			Id cust = dummyQuote.Customer__c;
			fromQuotesQuery += ' AND Customer__c = \'' + dummyQuote.Customer__c + '\'';
		}
		if (salesMs != null && salesMs.size() > 0) {
			string salesMsX = '';
			for (String sMs : salesMs) {
				if (salesMsX != '')
					salesMsX += ',';
				salesMsX += '\'' + sMs + '\'';
			}
			fromQuotesQuery += ' AND Customer__r.Sales_Manager__c in (' + salesMsX + ')';
		}
		if (accReps != null && accReps.size() > 0) {
			string accRepsX = '';
			for (String sMs : accReps) {
				if (accRepsX != '')
					accRepsX += ',';
				accRepsX += '\'' + sMs + '\'';
			}
			fromQuotesQuery += ' AND Customer__r.Account_Manager__c in (' + accRepsX + ')';
		}
		
		string fromLinesQuery = 'SELECT Id, Material_Item__c, Material_Item__r.Material_Code__c, Quote__r.Sales_Organization_Primary__c, Quote__r.Customer__c, UOM__c,' +
								' Quote__r.Customer__r.SAP_Account_Number__c, Actual_Price__c, Quantity__c, Per__c, PHL1__c, PHL2__c, PHL3__c, Material_Item__r.Base_Unit_of_Measue__c,' +
								' Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, Quote__r.Customer__r.Account_Manager__c,' +
								' Quote__r.RSM__r.Name, Quote__r.Opportunity__r.Owner.Name, Quote__r.Sales_Organization_Primary__r.Name, Material_Item__r.Name, Quote__r.Customer__r.Sales_Manager__c' +
								' FROM Quote_Line_Item__c WHERE Quote__c in :quotes';
			if (MaterialId != null && MaterialId != '')
				fromLinesQuery += ' AND Material_Item__c = \'' + MaterialId + '\'';
			else if (PHL3Id != null && PHL3Id != '')
				fromLinesQuery += ' AND PHL3__c = \'' + PHL3Id + '\' AND PHL2__c = \'' + PHL2Id + '\' AND PHL1__c = \'' + PHL1Id + '\'';
			else if (PHL2Id != null && PHL2Id != '')
				fromLinesQuery += ' AND PHL2__c = \'' + PHL2Id + '\' AND PHL1__c = \'' + PHL1Id + '\'';
			else if (PHL1Id != null && PHL1Id != '')
				fromLinesQuery += ' AND PHL1__c = \'' + PHL1Id + '\'';
				
		BatchJob1Id = Database.executeBatch(new RealizationReportBatchStep1(fromQuotesQuery, fromLinesQuery), 1);
		StepNumber = 1;
		Step1Text = 'Step 1/3, 0% completed';
		ShowCriteriaButton = false;
	}
	
	public void GenerateBatchStep2() {
		BatchJob2Id = null;
		BatchJob3Id = null;
		AsyncApexJob a;
		try {
			a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BatchJob1Id];
		} catch (Exception ex) {
			Step2Text = 'Step 1/3 has failed or was aborted by user.';
			ShowCriteriaButton = true;
			return;
		}
		if (a.Status != 'Completed' && (!Test.isRunningTest())) {
			if (a.Status == 'Failed' || a.Status == 'Aborted') {
				Step1Text = 'Step 1/3 has failed or was aborted by user.';
				ShowCriteriaButton = true;
				return;
			}
			if (a.TotalJobItems == 0)
				Step1Text = 'Step 1/3, 0% completed';
			else
				Step1Text = 'Step 1/3, ' + (a.JobItemsProcessed * 100 / a.TotalJobItems) + '% completed';
			return;
		}
			
		Date toDate = dummyQuote.Price_Valid_To__c;
		
		string fromQuotesQuery = 'SELECT Id, Customer__c, Date_Published_to_SAP__c FROM Quote__c WHERE Price_Valid_From__c <= ' + string.valueOf(toDate) + ' AND Price_Valid_To__c >= ' + string.valueOf(toDate);
		if (SalesSiteId != null && SalesSiteId != '')
			fromQuotesQuery += ' AND Sales_Organization_Primary__c = \'' + SalesSiteId + '\'';
		else if (RegionId != null && RegionId != '')
			fromQuotesQuery += ' AND Sales_Organization_Primary__r.Region_Site__c = \'' + RegionId + '\'';
		else if (CompanyId != null && CompanyId != '')
			fromQuotesQuery += ' AND Sales_Organization_Primary__r.Company_Site__c = \'' + CompanyId + '\'';
		if (dummyQuote.Customer__c != null) {
			Id cust = dummyQuote.Customer__c;
			fromQuotesQuery += ' AND Customer__c = \'' + dummyQuote.Customer__c + '\'';
		}
		if (salesMs != null && salesMs.size() > 0) {
			string salesMsX = '';
			for (String sMs : salesMs) {
				if (salesMsX != '')
					salesMsX += ',';
				salesMsX += '\'' + sMs + '\'';
			}
			fromQuotesQuery += ' AND Customer__r.Sales_Manager__c in (' + salesMsX + ')';
		}
		if (accReps != null && accReps.size() > 0) {
			string accRepsX = '';
			for (String sMs : accReps) {
				if (accRepsX != '')
					accRepsX += ',';
				accRepsX += '\'' + sMs + '\'';
			}
			fromQuotesQuery += ' AND Customer__r.Account_Manager__c in (' + accRepsX + ')';
		}
		
		string fromLinesQuery = 'SELECT Id, Material_Item__c, Material_Item__r.Material_Code__c, Quote__r.Sales_Organization_Primary__c, Quote__r.Customer__c, UOM__c,' +
								' Quote__r.Customer__r.SAP_Account_Number__c, Actual_Price__c, Quantity__c, Per__c, PHL1__c, PHL2__c, PHL3__c, Material_Item__r.Base_Unit_of_Measue__c,' +
								' Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, Quote__r.Customer__r.Account_Manager__c,' +
								' Quote__r.RSM__r.Name, Quote__r.Opportunity__r.Owner.Name, Quote__r.Sales_Organization_Primary__r.Name, Material_Item__r.Name, Quote__r.Customer__r.Sales_Manager__c' +
								' FROM Quote_Line_Item__c WHERE Quote__c in :quotes';
			if (MaterialId != null && MaterialId != '')
				fromLinesQuery += ' AND Material_Item__c = \'' + MaterialId + '\'';
			else if (PHL3Id != null && PHL3Id != '')
				fromLinesQuery += ' AND PHL3__c = \'' + PHL3Id + '\' AND PHL2__c = \'' + PHL2Id + '\' AND PHL1__c = \'' + PHL1Id + '\'';
			else if (PHL2Id != null && PHL2Id != '')
				fromLinesQuery += ' AND PHL2__c = \'' + PHL2Id + '\' AND PHL1__c = \'' + PHL1Id + '\'';
			else if (PHL1Id != null && PHL1Id != '')
				fromLinesQuery += ' AND PHL1__c = \'' + PHL1Id + '\'';
				
		BatchJob2Id = Database.executeBatch(new RealizationReportBatchStep2(fromQuotesQuery, fromLinesQuery, BatchJob1Id), 1);
		StepNumber = 2;
		Step2Text = 'Step 2/3, 0% completed';
		ShowCriteriaButton = false;
	}
	
	public void GenerateBatchStep3() {
		BatchJob3Id = null;
		AsyncApexJob a;
		try {
			a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BatchJob2Id];
		} catch (Exception ex) {
			Step2Text = 'Step 2/3 has failed or was aborted by user.';
			ShowCriteriaButton = true;
			return;
		}
		if (a.Status != 'Completed' && (!Test.isRunningTest())) {
			if (a.Status == 'Failed' || a.Status == 'Aborted') {
				Step2Text = 'Step 2/3 has failed or was aborted by user.';
				ShowCriteriaButton = true;
				return;
			}
			if (a.TotalJobItems == 0)
				Step2Text = 'Step 2/3, 0% completed';
			else
				Step2Text = 'Step 2/3, ' + (a.JobItemsProcessed * 100 / a.TotalJobItems) + '% completed';
			return;
		}		
				
		User user = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()];
		
		RealizationReportBatchStep3.GroupingStructure gs = new RealizationReportBatchStep3.GroupingStructure();
		
		gs.FirstGroupSe = GroupByFirst;
		if (GroupByFirst == 'Organization')
			gs.FirstGroupBy = GroupByOrganization;
		if (GroupByFirst == 'Product')
			gs.FirstGroupBy = GroupByProduct;
		if (GroupByFirst == 'Sales Structure')
			gs.FirstGroupBy = GroupBySales;
			
		gs.SecondGroupSe = GroupBySecond;
		if (GroupBySecond == 'Organization')
			gs.SecondGroupBy = GroupByOrganization;
		if (GroupBySecond == 'Product')
			gs.SecondGroupBy = GroupByProduct;
		if (GroupBySecond == 'Sales Structure')
			gs.SecondGroupBy = GroupBySales;
			
		gs.ThirdGroupSe = GroupByThird;
		if (GroupByThird == 'Organization')
			gs.ThirdGroupBy = GroupByOrganization;
		if (GroupByThird == 'Product')
			gs.ThirdGroupBy = GroupByProduct;
		if (GroupByThird == 'Sales Structure')
			gs.ThirdGroupBy = GroupBySales;
			
		BatchJob3Id = Database.executeBatch(new RealizationReportBatchStep3(BatchJob1Id, user.Email, gs), 100);
		StepNumber = 3;
		Step3Text = 'Step 3/3, 0% completed';
		ShowCriteriaButton = false;
	}
	
	public void GenerateBatchStep4() {
		
		AsyncApexJob a;
		try {
			a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BatchJob3Id];
		} catch (Exception ex) {
			Step2Text = 'Step 3/3 has failed or was aborted by user.';
			ShowCriteriaButton = true;
			return;
		}
		if (a.Status != 'Completed' && (!Test.isRunningTest())) {
			if (a.Status == 'Failed' || a.Status == 'Aborted') {
				Step3Text = 'Step 3/3 has failed or was aborted by user.';
				ShowCriteriaButton = true;
				return;
			}
			if (a.TotalJobItems == 0)
				Step3Text = 'Step 3/3, 0% completed';
			else
				Step3Text = 'Step 3/3, ' + (a.JobItemsProcessed * 100 / a.TotalJobItems) + '% completed';
			return;
		}	
			
		StepNumber = 4;
		Step4Text = 'Completed. Check your email.';
		ShowCriteriaButton = true;
	}
	
	public void CancelBatch1() {
		try {
			System.abortJob(BatchJob1Id);
		} catch (Exception ex) {}
		ShowCriteriaButton = true;
		StepNumber = 0;
		Database.executeBatch(new RealizationReportBatchDelete(BatchJob1Id), 1000);
	}
	
	public void CancelBatch2() {
		try {
			System.abortJob(BatchJob1Id);
		} catch (Exception ex) {}
		try {
			System.abortJob(BatchJob2Id);
		} catch (Exception ex) {}
		ShowCriteriaButton = true;
		StepNumber = 0;
		Database.executeBatch(new RealizationReportBatchDelete(BatchJob1Id), 1000);
	}
	
	public void CancelBatch3() {
		try {
			System.abortJob(BatchJob1Id);
		} catch (Exception ex) {}
		try {
			System.abortJob(BatchJob2Id);
		} catch (Exception ex) {}
		try {
			System.abortJob(BatchJob3Id);
		} catch (Exception ex) {}
		ShowCriteriaButton = true;
		StepNumber = 0;
		Database.executeBatch(new RealizationReportBatchDelete(BatchJob1Id), 1000);
	}
	
	public List<GroupingLevel> Lines { get; set; }
	
	private void CalculateAggregates() {
		for (GroupingLevel line : Lines)
			line.CalculateAggregates();
	}
	
	public string ExportResult { get; set; }
	
	public PageReference ExportDetails() {
		ExportResult = '"Account Number","PHL1","PHL2","PHL3","Material","Previous Price","Current Price","Per","UOM","Current Volume","Price Change($)","Previous Price Rev($)","Current Price Rev($)","Realization(%)","Realization($)"\n';
		
		for (LineItem li : auxLines) {
			ExportResult += '"' + li.AccountNumber + '",';
			ExportResult += '"' + li.PHL1 + '",';
			ExportResult += '"' + li.PHL2 + '",';
			ExportResult += '"' + li.PHL3 + '",';
			ExportResult += '"' + li.MaterialCode + '",';
			ExportResult += '' + li.PreviousPrice + ',';
			ExportResult += '' + li.CurrentPrice + ',';
			ExportResult += '' + li.Per + ',';
			ExportResult += '"' + li.UOM + '",';
			ExportResult += '' + li.CurrentVolume + ',';
			ExportResult += '' + li.PriceChange + ',';
			ExportResult += '' + li.PreviousPriceRev + ',';
			ExportResult += '' + li.CurrentPriceRev + ',';
			if (li.RealizationPercent == null)
				ExportResult += '0,';
			else
				ExportResult += '' + (li.RealizationPercent * 100) + ',';
			ExportResult += '' + li.Realization + '\n';
		}
		
		PageReference pr = Page.RealizationReportExport;
		pr.setRedirect(false);
		return pr;
	}
	
	public PageReference ExportSummary() {
		ExportResult = '"Grouping Type : Value : Level","Previous Price Rev ($)","Current Price Rev ($)","Realization (%)","Realization ($)"\n';
		
		for (GroupingLevel gl1 : Lines) {
			ExportResult += '"' + gl1.Name + ' : 1",';
			ExportResult += '' + gl1.PreviousPriceRev + ',';
			ExportResult += '' + gl1.CurrentPriceRev + ',';
			if (gl1.RealizationPercent != null)
				ExportResult += '' + (gl1.RealizationPercent * 100) + ',';
			else
				ExportResult += ',';
			ExportResult += '' + gl1.Realization + '\n';
			if (gl1.isDeeper) {
				for (GroupingLevel gl2 : gl1.Groups) {
					ExportResult += '"' + gl2.Name + ' : 2",';
					ExportResult += '' + gl2.PreviousPriceRev + ',';
					ExportResult += '' + gl2.CurrentPriceRev + ',';
					if (gl2.RealizationPercent != null)
						ExportResult += '' + (gl2.RealizationPercent * 100) + ',';
					else
						ExportResult += ',';
					ExportResult += '' + gl2.Realization + '\n';
					if (gl2.isDeeper) {
						for (GroupingLevel gl3 : gl2.Groups) {
							ExportResult += '"' + gl3.Name + ' : 2",';
							ExportResult += '' + gl3.PreviousPriceRev + ',';
							ExportResult += '' + gl3.CurrentPriceRev + ',';
							if (gl3.RealizationPercent != null)
								ExportResult += '' + (gl3.RealizationPercent * 100) + ',';
							else
								ExportResult += ',';
							ExportResult += '' + gl3.Realization + '\n';
						}
					}
				}
			}
		}
		
		PageReference pr = Page.RealizationReportExport;
		pr.setRedirect(false);
		return pr;
	}
	
	public class GroupingLevel {
		
		public string Name { get; set; }
		public boolean isDeeper { get; set; }

		public List<GroupingLevel> Groups { get; set; }
		public List<LineItem> Lines { get; set; }
		
		public integer Count { get; set; }
		public decimal PreviousPriceRev { get; set; }
		public decimal CurrentPriceRev { get; set; }
		public decimal RealizationPercent { 
			get {
				if (PreviousPriceRev == 0)
					return null;
				return CurrentPriceRev / PreviousPriceRev - 1;
			}
		}
		public decimal Realization {
			get {
				return CurrentPriceRev - PreviousPriceRev;
			}
		}
		
		public void CalculateAggregates() {
			Count = 0;
			PreviousPriceRev = 0;
			CurrentPriceRev = 0;
			if (isDeeper) {
				for (GroupingLevel grp : Groups) {
					grp.CalculateAggregates();
					Count += grp.Count;
					PreviousPriceRev += grp.PreviousPriceRev;
					CurrentPriceRev += grp.CurrentPriceRev;
				}
			} else {
				Count = Lines.size();
				for (LineItem line : Lines) {
					PreviousPriceRev += line.PreviousPriceRev;
					CurrentPriceRev += line.CurrentPriceRev;
				}
			}
		}
		
		public void GroupLines(string GroupFor, string GroupBy, boolean nextlevel) {
			isDeeper = true;
			if (nextlevel) {
				for (GroupingLevel gl : Groups) {
					gl.GroupLines(GroupFor, GroupBy, false);
				}
			} else {
				Map<String, GroupingLevel> auxGroupings = new Map<String, GroupingLevel>();
				if (GroupFor == 'Organization') {
					if (GroupBy == 'Company') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name)) {
								auxGroupings.put('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, new GroupingLevel());
								auxGroupings.get('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name).Name = 'Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name; 
							}
							auxGroupings.get('Company: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name).Lines.add(li);
						}
					}
					if (GroupBy == 'Region') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name)) {
								auxGroupings.put('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, new GroupingLevel());
								auxGroupings.get('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name).Name = 'Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name; 
							}
							auxGroupings.get('Region: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name).Lines.add(li);
						}
					}
					if (GroupBy == 'Sales Site') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name)) {
								auxGroupings.put('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name, new GroupingLevel());
								auxGroupings.get('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name).Name = 'Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name; 
							}
							auxGroupings.get('Sales Site: ' + li.newQLI.Quote__r.Sales_Organization_Primary__r.Name).Lines.add(li);
						}
					}
				}
				if (GroupFor == 'Product') {
					if (GroupBy == 'PHL1') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('PHL1: ' + li.newQLI.PHL1__c)) {
								auxGroupings.put('PHL1: ' + li.newQLI.PHL1__c, new GroupingLevel());
								auxGroupings.get('PHL1: ' + li.newQLI.PHL1__c).Name = 'PHL1: ' + li.newQLI.PHL1__c;
							}
							auxGroupings.get('PHL1: ' + li.newQLI.PHL1__c).Lines.add(li);
						}
					}
					if (GroupBy == 'PHL2') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c)) {
								auxGroupings.put('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c, new GroupingLevel());
								auxGroupings.get('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c).Name = 'PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c; 
							}
							auxGroupings.get('PHL2: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c).Lines.add(li);
						}
					}
					if (GroupBy == 'PHL3') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c)) {
								auxGroupings.put('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c, new GroupingLevel());
								auxGroupings.get('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c).Name = 'PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c;
							}
							auxGroupings.get('PHL3: ' + li.newQLI.PHL1__c + li.newQLI.PHL2__c + li.newQLI.PHL3__c).Lines.add(li);
						}
					}
					if (GroupBy == 'Material Code') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('Material Item: ' + li.newQLI.Material_Item__r.Name)) {
								auxGroupings.put('Material Item: ' + li.newQLI.Material_Item__r.Name, new GroupingLevel());
								auxGroupings.get('Material Item: ' + li.newQLI.Material_Item__r.Name).Name = 'Material Item: ' + li.newQLI.Material_Item__r.Name;
							}
							auxGroupings.get('Material Item: ' + li.newQLI.Material_Item__r.Name).Lines.add(li);
						}
					}
				}
				if (GroupFor == 'Sales Structure') {
					if (GroupBy == 'Sales Manager') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c)) {
								auxGroupings.put('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c, new GroupingLevel());
								auxGroupings.get('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c).Name = 'Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c; 
							}
							auxGroupings.get('Sales Manager: ' + li.newQLI.Quote__r.Customer__r.Sales_Manager__c).Lines.add(li);
						}
					}
					if (GroupBy == 'Account Manager') {
						for (LineItem li : Lines) {
							if (!auxGroupings.containsKey('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c)) {
								auxGroupings.put('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c, new GroupingLevel());
								auxGroupings.get('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c).Name = 'Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c; 
							}
							auxGroupings.get('Account Manager: ' + li.newQLI.Quote__r.Customer__r.Account_Manager__c).Lines.add(li);
						}
					}
				}
				Groups = auxGroupings.values();
			}
		}
		
		public GroupingLevel() {
			Lines = new List<LineItem>();
			Groups = new List<GroupingLevel>();
			isDeeper = false;
		}
		
	}
	
	public class LineItem {
		public Quote_Line_Item__c newQLI;
		public string AccountNumber { get; set; }
		public string PHL1 { get; set; }
		public string PHL2 { get; set; }
		public string PHL3 { get; set; }
		public string MaterialCode { get; set; }
		public decimal PreviousPrice { get; set; }
		public decimal CurrentPrice { get; set; }
		public decimal Per { get; set; }
		public string UOM { get; set; }
		public decimal CurrentVolume { get; set; }
		public decimal PriceChange {
			get {
				if (CurrentPrice == null || PreviousPrice == null)
					return 0;
				return CurrentPrice - PreviousPrice;
			}
		}
		public decimal PreviousPriceRev { 
			get {
				if (CurrentVolume == null || PreviousPrice == null)
					return 0;
				return CurrentVolume * PreviousPrice;
			}
		}
		public decimal CurrentPriceRev { 
			get {
				if (CurrentVolume == null || CurrentPrice == null)
					return 0;
				return CurrentVolume * CurrentPrice;
			}
		}
		public decimal RealizationPercent { 
			get {
				if (PreviousPriceRev == 0)
					return null;
				return CurrentPriceRev / PreviousPriceRev - 1;
			}
		}
		public decimal Realization {
			get {
				return CurrentPriceRev - PreviousPriceRev;
			}
		}
	}
	
	public static testMethod void test1() {
		
		
		Account a = new Account();
		a.Name = 'Lucian664523';
		insert a;
		
		Opportunity o = new Opportunity();
		o.AccountId = a.Id;
		o.StageName = 'Proposal/Price Quote';
		o.CloseDate = Date.today();
		insert o;
		
		Sales_Site__c com = new Sales_Site__c();
		insert com;
		
		Sales_Site__c reg = new Sales_Site__c();
		reg.Company_Site__c = com.Id;
		insert reg;
		
		Sales_Site__c sst = new Sales_Site__c();
		sst.Company_Site__c = com.Id;
		sst.Region_Site__c = reg.Id;
		insert sst;
		
		Material_Item__c mi = new Material_Item__c();
		insert mi; 
		
		Quote__c q1 = new Quote__c();
		q1.Customer__c = a.Id;
		q1.Opportunity__c = o.Id;
		q1.Sales_Organization_Primary__c = sst.Id;
		q1.Price_Valid_From__c = Date.today().adddays(-10);
		q1.Quote_Valid_From__c = Date.today().adddays(-10);
		q1.Price_Valid_To__c = Date.today().adddays(10);
		q1.Quote_Valid_To__c = Date.today().adddays(10);
		insert q1;
		
		Quote_Line_Item__c qli1 = new Quote_Line_Item__c();
		qli1.Quote__c = q1.Id;
		qli1.Material_Item__c = mi.Id;
		insert qli1;
		
		Quote__c q2 = new Quote__c();
		q2.Customer__c = a.Id;
		q2.Opportunity__c = o.Id;
		q2.Sales_Organization_Primary__c = sst.Id;
		q2.Price_Valid_From__c = Date.today().addyears(-1).adddays(-10);
		q2.Quote_Valid_From__c = Date.today().addyears(-1).adddays(-10);
		q2.Price_Valid_To__c = Date.today().addyears(-1).adddays(10);
		q2.Quote_Valid_To__c = Date.today().addyears(-1).adddays(10);
		insert q2;
		
		Quote_Line_Item__c qli2 = new Quote_Line_Item__c();
		qli2.Quote__c = q2.Id;
		qli2.Material_Item__c = mi.Id;
		insert qli2;
		
		Test.startTest();
		
		RealizationReport rr = new RealizationReport();
		rr.CustomerNumberChanged();
		rr.CustomerChanged();
		rr.GetGroupByProductList();
		rr.GetGroupByOrganizationList();
		rr.GetGroupBySalesList();
		rr.GetGroupByFirstList();
		rr.FirstSelected();
		rr.GetGroupBySecondList();
		rr.SecondSelected();
		rr.GetGroupByThirdList();
		rr.ResetFilters();
		
		rr.dummyQuote.Customer__c = a.Id;
		rr.SalesSiteId = sst.Id;
		rr.MaterialId = mi.Id;
		
		rr.GroupByFirst = 'Organization';
		rr.GroupByOrganization = 'Sales Site';
		rr.GroupBySecond = 'Product';
		rr.GroupByProduct = 'Material Code';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupByFirst = 'Organization';
		rr.GroupByOrganization = 'Region';
		rr.GroupBySecond = 'Product';
		rr.GroupByProduct = 'PHL1';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupByFirst = 'Organization';
		rr.GroupByOrganization = 'Company';
		rr.GroupBySecond = 'Product';
		rr.GroupByProduct = 'PHL2';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupBySecond = 'Organization';
		rr.GroupByOrganization = 'Sales Site';
		rr.GroupByFirst = 'Product';
		rr.GroupByProduct = 'Material Code';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupBySecond = 'Organization';
		rr.GroupByOrganization = 'Region';
		rr.GroupByFirst = 'Product';
		rr.GroupByProduct = 'PHL1';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupBySecond = 'Organization';
		rr.GroupByOrganization = 'Company';
		rr.GroupByFirst = 'Product';
		rr.GroupByProduct = 'PHL2';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupByFirst = 'Sales Structure';
		rr.GroupBySales = 'Account Manager';
		rr.GroupBySecond = 'Product';
		rr.GroupByProduct = 'PHL3';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GroupBySecond = 'Sales Structure';
		rr.GroupBySales = 'Account Manager';
		rr.GroupByFirst = 'Product';
		rr.GroupByProduct = 'PHL3';
		rr.GroupByThird = '';
		rr.Generate();
		
		rr.GenerateBatch();
		rr.GenerateBatchStep2();
		rr.GenerateBatchStep3();
		rr.GenerateBatchStep4();
		rr.CancelBatch1();
		rr.CancelBatch2();
		//rr.CancelBatch3();
		rr.ExportDetails();
		rr.ExportSummary();
		
		rr.ClearRest();
		rr.PHL1Id = 'PL030';
		rr.GetPHL2s();
		rr.PHL2Id = 'PL03000100';
		rr.GetPHL3s();
		rr.PHL3Id = 'PL0300010000001';
		rr.GetMaterials();
		rr.MaterialCodeSet();
		
		if (rr.CompanyIds.size() > 1) {
			rr.CompanyId = rr.CompanyIds.get(1).getvalue();
			rr.GetRegions();
			if (rr.RegionIds.size() > 1) {
				rr.RegionId = rr.RegionIds.get(1).getvalue();
				rr.GetSalesSites();
			}
		}
		
		Test.stopTest();
		
	}
	
	public static testMethod void testbatch1() {
		
		Account a = new Account();
		a.Name = 'Lucian664523';
		insert a;
		
		Opportunity o = new Opportunity();
		o.AccountId = a.Id;
		o.StageName = 'Proposal/Price Quote';
		o.CloseDate = Date.today();
		insert o;
		
		Sales_Site__c com = new Sales_Site__c();
		insert com;
		
		Sales_Site__c reg = new Sales_Site__c();
		reg.Company_Site__c = com.Id;
		insert reg;
		
		Sales_Site__c sst = new Sales_Site__c();
		sst.Company_Site__c = com.Id;
		sst.Region_Site__c = reg.Id;
		insert sst;
		
		Material_Item__c mi = new Material_Item__c();
		insert mi; 
		
		Quote__c q1 = new Quote__c();
		q1.Customer__c = a.Id;
		q1.Opportunity__c = o.Id;
		q1.Sales_Organization_Primary__c = sst.Id;
		q1.Price_Valid_From__c = Date.today().adddays(-10);
		q1.Quote_Valid_From__c = Date.today().adddays(-10);
		q1.Price_Valid_To__c = Date.today().adddays(10);
		q1.Quote_Valid_To__c = Date.today().adddays(10);
		insert q1;
		
		Quote_Line_Item__c qli1 = new Quote_Line_Item__c();
		qli1.Quote__c = q1.Id;
		qli1.Material_Item__c = mi.Id;
		qli1.Actual_Price__c = 0;
		qli1.Per__c = 1;
		insert qli1;
		
		Quote__c q2 = new Quote__c();
		q2.Customer__c = a.Id;
		q2.Opportunity__c = o.Id;
		q2.Sales_Organization_Primary__c = sst.Id;
		q2.Price_Valid_From__c = Date.today().addyears(-1).adddays(-10);
		q2.Quote_Valid_From__c = Date.today().addyears(-1).adddays(-10);
		q2.Price_Valid_To__c = Date.today().addyears(-1).adddays(10);
		q2.Quote_Valid_To__c = Date.today().addyears(-1).adddays(10);
		insert q2;
		
		Quote_Line_Item__c qli2 = new Quote_Line_Item__c();
		qli2.Quote__c = q2.Id;
		qli2.Material_Item__c = mi.Id;
		qli2.Actual_Price__c = 0;
		qli2.Per__c = 1;
		insert qli2;
	
		string fromQuotesQuery = 'SELECT Id, Customer__c, Date_Published_to_SAP__c FROM Quote__c LIMIT 1';
		
		string fromLinesQuery = 'SELECT Id, Material_Item__c, Material_Item__r.Material_Code__c, Quote__r.Sales_Organization_Primary__c, Quote__r.Customer__c, UOM__c,' +
								' Quote__r.Customer__r.SAP_Account_Number__c, Actual_Price__c, Quantity__c, Per__c, PHL1__c, PHL2__c, PHL3__c, Material_Item__r.Base_Unit_of_Measue__c,' +
								' Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, Quote__r.Customer__r.Account_Manager__c,' +
								' Quote__r.RSM__r.Name, Quote__r.Opportunity__r.Owner.Name, Quote__r.Sales_Organization_Primary__r.Name, Material_Item__r.Name, Quote__r.Customer__r.Sales_Manager__c' +
								' FROM Quote_Line_Item__c WHERE Quote__c in :quotes';
				
		Test.startTest();
		string BatchJob1Id = Database.executeBatch(new RealizationReportBatchStep1(fromQuotesQuery, fromLinesQuery), 1);
		
		RealizationReportAux__c rra = new RealizationReportAux__c();
		rra.BatchJob__c = BatchJob1Id;
		rra.Key__c = '';
		rra.Quote_SLI__c = qli1.Id;
		rra.Actual_SLI__c = qli2.Id;
		insert rra;
		
		string BatchJob2Id = Database.executeBatch(new RealizationReportBatchStep2(fromQuotesQuery, fromLinesQuery, BatchJob1Id), 1);
		RealizationReportBatchStep3.GroupingStructure gs = new RealizationReportBatchStep3.GroupingStructure();
		gs.FirstGroupSe = 'Organization'; gs.FirstGroupBy = 'Company';
		gs.SecondGroupSe = 'Product'; gs.SecondGroupBy = 'PHL1';
		gs.ThirdGroupSe = 'Sales Structure'; gs.ThirdGroupBy = 'Sales Manager';
		string BatchJob3Id = Database.executeBatch(new RealizationReportBatchStep3(BatchJob1Id, 'lucian@vertiba.com', gs), 100);
		Test.stopTest();
	
	}
	
	public static testMethod void testbatch2() {
		
		Account a = new Account();
		a.Name = 'Lucian664523';
		insert a;
		
		Opportunity o = new Opportunity();
		o.AccountId = a.Id;
		o.StageName = 'Proposal/Price Quote';
		o.CloseDate = Date.today();
		insert o;
		
		Sales_Site__c com = new Sales_Site__c();
		insert com;
		
		Sales_Site__c reg = new Sales_Site__c();
		reg.Company_Site__c = com.Id;
		insert reg;
		
		Sales_Site__c sst = new Sales_Site__c();
		sst.Company_Site__c = com.Id;
		sst.Region_Site__c = reg.Id;
		insert sst;
		
		Material_Item__c mi = new Material_Item__c();
		insert mi; 
		
		Quote__c q1 = new Quote__c();
		q1.Customer__c = a.Id;
		q1.Opportunity__c = o.Id;
		q1.Sales_Organization_Primary__c = sst.Id;
		q1.Price_Valid_From__c = Date.today().adddays(-10);
		q1.Quote_Valid_From__c = Date.today().adddays(-10);
		q1.Price_Valid_To__c = Date.today().adddays(10);
		q1.Quote_Valid_To__c = Date.today().adddays(10);
		insert q1;
		
		Quote_Line_Item__c qli1 = new Quote_Line_Item__c();
		qli1.Quote__c = q1.Id;
		qli1.Material_Item__c = mi.Id;
		qli1.Actual_Price__c = 0;
		qli1.Per__c = 1;
		insert qli1;
		
		Quote__c q2 = new Quote__c();
		q2.Customer__c = a.Id;
		q2.Opportunity__c = o.Id;
		q2.Sales_Organization_Primary__c = sst.Id;
		q2.Price_Valid_From__c = Date.today().addyears(-1).adddays(-10);
		q2.Quote_Valid_From__c = Date.today().addyears(-1).adddays(-10);
		q2.Price_Valid_To__c = Date.today().addyears(-1).adddays(10);
		q2.Quote_Valid_To__c = Date.today().addyears(-1).adddays(10);
		insert q2;
		
		Quote_Line_Item__c qli2 = new Quote_Line_Item__c();
		qli2.Quote__c = q2.Id;
		qli2.Material_Item__c = mi.Id;
		qli2.Actual_Price__c = 0;
		qli2.Per__c = 1;
		insert qli2;
	
		string fromQuotesQuery = 'SELECT Id, Customer__c, Date_Published_to_SAP__c FROM Quote__c LIMIT 1';
		
		string fromLinesQuery = 'SELECT Id, Material_Item__c, Material_Item__r.Material_Code__c, Quote__r.Sales_Organization_Primary__c, Quote__r.Customer__c, UOM__c,' +
								' Quote__r.Customer__r.SAP_Account_Number__c, Actual_Price__c, Quantity__c, Per__c, PHL1__c, PHL2__c, PHL3__c, Material_Item__r.Base_Unit_of_Measue__c,' +
								' Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, Quote__r.Customer__r.Account_Manager__c,' +
								' Quote__r.RSM__r.Name, Quote__r.Opportunity__r.Owner.Name, Quote__r.Sales_Organization_Primary__r.Name, Material_Item__r.Name, Quote__r.Customer__r.Sales_Manager__c' +
								' FROM Quote_Line_Item__c WHERE Quote__c in :quotes';
				
		Test.startTest();
		string BatchJob1Id = Database.executeBatch(new RealizationReportBatchStep1(fromQuotesQuery, fromLinesQuery), 1);
		
		RealizationReportAux__c rra = new RealizationReportAux__c();
		rra.BatchJob__c = BatchJob1Id;
		rra.Key__c = '';
		rra.Quote_SLI__c = qli1.Id;
		rra.Actual_SLI__c = qli2.Id;
		insert rra;
		
		string BatchJob2Id = Database.executeBatch(new RealizationReportBatchStep2(fromQuotesQuery, fromLinesQuery, BatchJob1Id), 1);
		RealizationReportBatchStep3.GroupingStructure gs = new RealizationReportBatchStep3.GroupingStructure();
		gs.FirstGroupSe = 'Product'; gs.FirstGroupBy = 'PHL2';
		gs.SecondGroupSe = 'Sales Structure'; gs.SecondGroupBy = 'Account Manager';
		gs.ThirdGroupSe = 'Organization'; gs.ThirdGroupBy = 'Region';
		string BatchJob3Id = Database.executeBatch(new RealizationReportBatchStep3(BatchJob1Id, 'lucian@vertiba.com', gs), 100);
		Test.stopTest();
	
	}
	
	public static testMethod void testbatchdel() {
	
		RealizationReportAux__c rra = new RealizationReportAux__c();
		rra.BatchJob__c = 'LucianTest';
		rra.Key__c = '';
		insert rra;
				
		Test.startTest();
		string BatchJob1Id = Database.executeBatch(new RealizationReportBatchDelete('LucianTest'), 1000);
		Test.stopTest();
	
	}
	
}