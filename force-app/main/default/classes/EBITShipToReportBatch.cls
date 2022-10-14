global class EBITShipToReportBatch implements Database.Batchable<EBITData.EBITDataHelper>, Database.Stateful {
	global List<EBITData.EBITDataHelper> edhList;
	
	global EBITShipToReportBatch(List<EBITData.EBITDataHelper> edhList) {
		this.edhList = edhList;
		System.debug('end controller::::');
	}
	
	global List<EBITData.EBITDataHelper> start(Database.BatchableContext bc) {
		System.debug('start batch::::');
		return edhList;
	}
	
	global void execute(Database.BatchableContext bc, List<EBITData.EBITDataHelper> edhList) {
		System.debug('execute:::');
		COPA_ShipTos_Temp__c cst = new COPA_ShipTos_Temp__c();
		cst.AccountIds__c = JSON.serialize(edhList[0].accountIds);
		cst.batchId__c = bc.getJobId();
		Account acc = [SELECT Id, Account_Manager__c, Industry FROM Account WHERE Id = :edhList[0].accountIds];
		PandLData pl = EBITData.createEBIT(edhList[0]);
		pl.accountManager = acc.Account_Manager__c;
		pl.industry = acc.Industry;
		
		
		String salesOfficeString = '';
		String salesGroupString = '';
		
		if (edhList[0].siteIds.size() > 0) {
			List<Sales_Site__c> salesSiteList = [SELECT Id, SalesGroup_String__c, SalesOffice_String__c FROM Sales_Site__c WHERE Id IN :edhList[0].siteIds];
			
			Set<String> salesOfficeSet = new Set<String>();
			Set<String> salesGroupSet = new Set<String>();
			
			for(Sales_Site__c ss : salesSiteList) {
				if (ss.SalesOffice_String__c != null && ss.SalesOffice_String__c != '') {
					salesOfficeSet.add(ss.SalesOffice_String__c);
				}
				if (ss.SalesGroup_String__c != null && ss.SalesGroup_String__c != '') {
					salesGroupSet.add(ss.SalesGroup_String__c);
				}
			}
			salesOfficeString = String.valueOf(salesOfficeSet);
			salesOfficeString = salesOfficeString.substring(1,salesOfficeString.length() - 1);
			
			salesGroupString = String.valueOf(salesGroupSet);
			salesGroupString = salesGroupString.substring(1,salesGroupString.length() - 1);
		}
		pl.SalesOffice = salesOfficeString;
		pl.SalesGroup = salesGroupString;
		
		Map<integer, String> valuesMap = new Map<integer, String>();
		
		// If it's a zero value P&L, let's not store everything
		if (pl.netRevenue != null && pl.netRevenue.value != 0) {
			
			valuesMap.put(-1, '1');
		
			valuesMap.put(2, pl.sapCustomerNumber != null ? pl.sapCustomerNumber : '');
			valuesMap.put(3, pl.accountManager != null ? pl.accountManager : '');
			valuesMap.put(4, pl.industry != null ? pl.industry : '');
			valuesMap.put(5, pl.SalesOffice != null ? pl.SalesOffice : '');
			valuesMap.put(6, pl.customerName != null ? pl.customerName : '');
			valuesMap.put(7, pl.SalesGroup != null ? pl.SalesGroup : '');
			valuesMap.put(8, pl.plant != null ? pl.plant : '');
			valuesMap.put(9, pl.validFromDisplay != null ? pl.validFromDisplay : '');
			valuesMap.put(10, pl.validToDisplay != null ? pl.validToDisplay : '');
			valuesMap.put(11, pl.siteName != null ? pl.siteName : '');
			valuesMap.put(12, pl.companyName != null ? pl.companyName : '');
			valuesMap.put(13, pl.regionName != null ? pl.regionName : '');
			valuesMap.put(14, pl.currencyIsoCode != null ? pl.currencyIsoCode : '');
			valuesMap.put(15, pl.scenarioName != null ? pl.scenarioName : '');
			
			valuesMap.put(16, pl.productGmData.PL005.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(17, pl.productGmData.PL030.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(18, pl.productGmData.PL032.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(19, pl.productGmData.PL035.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(20, pl.productGmData.PL040_2.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(21, pl.productGmData.PL045_7.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(22, pl.productGmData.PL048.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(23, pl.productGmData.PL049_50.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(24, pl.productGmData.PL060_1.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(25, pl.productGmData.PL065.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(26, pl.productGmData.PL070.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(27, pl.productGmData.PL080.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(28, pl.productGmData.PL084.netRevenue.value.setScale(2).toPlainString());
			
			valuesMap.put(29, pl.productGmData.PL005.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(30, pl.productGmData.PL030.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(31, pl.productGmData.PL032.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(32, pl.productGmData.PL035.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(33, pl.productGmData.PL040_2.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(34, pl.productGmData.PL045_7.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(35, pl.productGmData.PL048.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(36, pl.productGmData.PL049_50.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(37, pl.productGmData.PL060_1.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(38, pl.productGmData.PL065.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(39, pl.productGmData.PL070.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(40, pl.productGmData.PL080.costOfGoodsSold.value.setScale(2).toPlainString());
			valuesMap.put(41, pl.productGmData.PL084.costOfGoodsSold.value.setScale(2).toPlainString());
			
			valuesMap.put(42, pl.productGmData.PL005.gm.value.setScale(2).toPlainString());
			valuesMap.put(43, pl.productGmData.PL030.gm.value.setScale(2).toPlainString());
			valuesMap.put(44, pl.productGmData.PL032.gm.value.setScale(2).toPlainString());
			valuesMap.put(45, pl.productGmData.PL035.gm.value.setScale(2).toPlainString());
			valuesMap.put(46, pl.productGmData.PL040_2.gm.value.setScale(2).toPlainString());
			valuesMap.put(47, pl.productGmData.PL045_7.gm.value.setScale(2).toPlainString());
			valuesMap.put(48, pl.productGmData.PL048.gm.value.setScale(2).toPlainString());
			valuesMap.put(49, pl.productGmData.PL049_50.gm.value.setScale(2).toPlainString());
			valuesMap.put(50, pl.productGmData.PL060_1.gm.value.setScale(2).toPlainString());
			valuesMap.put(51, pl.productGmData.PL065.gm.value.setScale(2).toPlainString());
			valuesMap.put(52, pl.productGmData.PL070.gm.value.setScale(2).toPlainString());
			valuesMap.put(53, pl.productGmData.PL080.gm.value.setScale(2).toPlainString());
			valuesMap.put(54, pl.productGmData.PL084.gm.value.setScale(2).toPlainString());
			
			valuesMap.put(55, pl.productGmData.PL005.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(56, pl.productGmData.PL030.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(57, pl.productGmData.PL032.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(58, pl.productGmData.PL035.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(59, pl.productGmData.PL040_2.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(60, pl.productGmData.PL045_7.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(61, pl.productGmData.PL048.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(62, pl.productGmData.PL049_50.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(63, pl.productGmData.PL060_1.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(64, pl.productGmData.PL065.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(65, pl.productGmData.PL070.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(66, pl.productGmData.PL080.gmPercentage.setScale(2).toPlainString());
			valuesMap.put(67, pl.productGmData.PL084.gmPercentage.setScale(2).toPlainString());
			
			valuesMap.put(68, pl.productGmData.PL005.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(69, pl.productGmData.PL030.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(70, pl.productGmData.PL032.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(71, pl.productGmData.PL035.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(72, pl.productGmData.PL040_2.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(73, pl.productGmData.PL045_7.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(74, pl.productGmData.PL048.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(75, pl.productGmData.PL049_50.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(76, pl.productGmData.PL060_1.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(77, pl.productGmData.PL065.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(78, pl.productGmData.PL070.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(79, pl.productGmData.PL080.gmSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(80, pl.productGmData.PL084.gmSeeThrough.value.setScale(2).toPlainString());
			
			valuesMap.put(81, pl.productGmData.PL005.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(82, pl.productGmData.PL030.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(83, pl.productGmData.PL032.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(84, pl.productGmData.PL035.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(85, pl.productGmData.PL040_2.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(86, pl.productGmData.PL045_7.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(87, pl.productGmData.PL048.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(88, pl.productGmData.PL049_50.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(89, pl.productGmData.PL060_1.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(90, pl.productGmData.PL065.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(91, pl.productGmData.PL070.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(92, pl.productGmData.PL080.gmSeeThroughPercentage.setScale(2).toPlainString());
			valuesMap.put(93, pl.productGmData.PL084.gmSeeThroughPercentage.setScale(2).toPlainString());
			
			valuesMap.put(94, pl.netRevenue.value.setScale(2).toPlainString());
			valuesMap.put(95, pl.costOfGoodsSold.value.setScale(3).toPlainString());
			valuesMap.put(96, pl.grossMargin.value.setScale(3).toPlainString());
			valuesMap.put(97, pl.grossMarginPercentage.setScale(2).toPlainString());
			valuesMap.put(98, pl.revenueModifier.value.setScale(3).toPlainString());
			valuesMap.put(99, pl.deliveryHours.setScale(2).toPlainString());
			valuesMap.put(100, pl.deliveryHoursRate.value.setScale(3).toPlainString());
			valuesMap.put(101, pl.directCostDeliveryHrs.value.setScale(2).toPlainString());
			valuesMap.put(102, pl.shotHours.setScale(3).toPlainString());
			valuesMap.put(103, pl.shotHoursRate.value.setScale(3).toPlainString());
			valuesMap.put(104, pl.directCostShotHrs.value.setScale(3).toPlainString());
			valuesMap.put(105, pl.costOfGoodsSoldSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(106, pl.grossMarginSeeThrough.value.setScale(2).toPlainString());
			valuesMap.put(107, pl.grossMarginSeeThroughPercentage.setScale(1).toPlainString());
			valuesMap.put(108, pl.directCosts.value.setScale(2).toPlainString());
			valuesMap.put(109, pl.contributionMargin.value.setScale(2).toPlainString());
			valuesMap.put(110, pl.contributionMarginPercentage.setScale(1).toPlainString());
			
			valuesMap.put(111, pl.totalHours.value.setScale(2).toPlainString());
			valuesMap.put(112, pl.siteTotalHrs.value.setScale(2).toPlainString());
			valuesMap.put(113, pl.totalHoursRate.value.setScale(2).toPlainString());
			valuesMap.put(114, pl.regionTotalHrs.value.setScale(2).toPlainString());
			valuesMap.put(115, pl.rateTotalHrs.value.setScale(2).toPlainString());
			valuesMap.put(116, (pl.totalHoursRate.value + pl.rateTotalHrs.value).setScale(2).toPlainString());
			valuesMap.put(117, pl.totalHrsTotal.value.setScale(2).toPlainString());
			
			valuesMap.put(118, pl.distance.value.setScale(2).toPlainString());
			valuesMap.put(119, pl.siteDistance.value.setScale(2).toPlainString());
			valuesMap.put(120, pl.distanceRate.value.setScale(2).toPlainString());
			valuesMap.put(121, pl.regionDistance.value.setScale(2).toPlainString());
			valuesMap.put(122, pl.rateDistance.value.setScale(2).toPlainString());
			valuesMap.put(123, (pl.distanceRate.value + pl.rateDistance.value).setScale(2).toPlainString());
			valuesMap.put(124, pl.distanceTotal.value.setScale(2).toPlainString());
			
			valuesMap.put(125, pl.units.value.setScale(2).toPlainString());
			valuesMap.put(126, pl.siteUnits.value.setScale(2).toPlainString());
			valuesMap.put(127, pl.unitsRate.value.setScale(2).toPlainString());
			valuesMap.put(128, pl.regionUnits.value.setScale(2).toPlainString());
			valuesMap.put(129, pl.rateUnits.value.setScale(2).toPlainString());
			valuesMap.put(130, (pl.unitsRate.value + pl.rateUnits.value).setScale(2).toPlainString());
			valuesMap.put(131, pl.unitsTotal.value.setScale(2).toPlainString());
			
			valuesMap.put(132, pl.invoices.value.setScale(2).toPlainString());
			valuesMap.put(133, pl.siteInvoices.value.setScale(2).toPlainString());
			valuesMap.put(134, pl.invoicesRate.value.setScale(2).toPlainString());
			valuesMap.put(135, pl.regionInvoices.value.setScale(2).toPlainString());
			valuesMap.put(136, pl.rateInvoices.value.setScale(2).toPlainString());
			valuesMap.put(137, (pl.invoicesRate.value + pl.rateInvoices.value).setScale(2).toPlainString());
			valuesMap.put(138, pl.invoicesTotal.value.setScale(2).toPlainString());
			
			valuesMap.put(139, pl.indirectNetRevenue.value.setScale(2).toPlainString());
			valuesMap.put(140, pl.siteNetRev.value.setScale(2).toPlainString());
			valuesMap.put(141, pl.netRevenueRate.value.setScale(2).toPlainString());
			valuesMap.put(142, pl.regionNetRev.value.setScale(2).toPlainString());
			valuesMap.put(143, pl.rateNetRevenue.value.setScale(2).toPlainString());
			valuesMap.put(144, (pl.netRevenueRate.value + pl.rateNetRevenue.value).setScale(2).toPlainString());
			valuesMap.put(145, pl.netRevTotal.value.setScale(2).toPlainString());
			
			valuesMap.put(146, pl.total2.value.setScale(2).toPlainString());
			valuesMap.put(147, pl.total3.value.setScale(2).toPlainString());
			valuesMap.put(148, pl.total5.value.setScale(2).toPlainString());
			
			valuesMap.put(149, pl.ebitWith.value.setScale(2).toPlainString());
			valuesMap.put(150, pl.ebitPercentageWith.setScale(1).toPlainString());
			
			cst.value__c = JSON.serialize(valuesMap);
			System.debug(cst.value__c);
			insert cst;
			
		}
		
	}
	
	global void finish(Database.BatchableContext bc) {
		System.debug('finish batch:::');
		/*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses(new String[] {userEmail});
		//mail.setReplyTo('batch@acme.com');
		mail.setSenderDisplayName('Batch Processing');
		mail.setSubject('Batch Process Completed');
		mail.setPlainTextBody('Batch Process has completed');
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
	}
}