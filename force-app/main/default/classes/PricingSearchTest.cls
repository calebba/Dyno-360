@isTest
private class PricingSearchTest {
	
	testmethod static void testPricingSearchControllerOne() {
        User u1 = new User();
        u1.FirstName = 'Test';
        u1.LastName = 'U\'Ser';
        u1.Alias = 'tuser';
        u1.Email = 'tu2@tus.com';
        u1.Username = 'tu2@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
        u1.CommunityNickname = 't2user';
        u1.TimeZoneSidKey = 'America/Chicago';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        u1.LanguageLocaleKey = 'en_US';
        u1.Company_Codes__c = 'TC402';
        u1.State = 'UT';
        u1.Employee__c = True;
        u1.PostalCode = '84121';
        u1.IsActive = True;
            
        System.runAs(u1) {
		Account testCustomer = TestUtils.createAccount('Big Test Corp', null);
		Sales_Site__c testCompany = TestUtils.createSalesSite('TC402', null, null);
		Sales_Site__c testRegion = TestUtils.createSalesSite('TR402', testCompany.Id, null);
		Sales_Site__c testSite = TestUtils.createSalesSite('TS402', testCompany.Id, testRegion.Id);
        Customer_Sales_Site__c testcss = TestUtils.createCSS(testCustomer.Id, testSite.Id);
        system.debug('css:'+ testcss);
		Material_Item__c testMi = TestUtils.createMaterialItem('TMI402', 'TMC402', 'PL001', testSite.Id);
		Pricing_Rule__c testPr1 = TestUtils.createPricingRule(testSite.Id, testCustomer.Id, testRegion.Id, true, testMi.Id, 1, 'LB', 10.00, 20.00, System.today(), System.today().addDays(365));
	    //system.debug('trying all:'+ testCompany.Id + ' '+  );
        Opportunity testOpp = TestUtils.createOppty('TO002', testCustomer.Id, 'Prospecting');
		Quote__c quote = TestUtils.createQuote(testOpp, testSite.Id);
		Test.startTest();
        Product_Grouping__c newgroup = new Product_Grouping__c(Name='First',Product_Line__c = testSite.Id,Description__c = 'This is a test');
        insert newgroup;
		PricingSearchController psc = new PricingSearchController();
		psc.dummyPr.Account__c = testCustomer.Id;
		psc.dummyPr.Material_Item__c = testMi.Id;
		psc.dummyPr.Customer_Group__c = '02 Retail';
		//psc.dummyAccountObject.ParentId = testCustomer.Id;
		psc.searchRecords();
		System.assertEquals(1, psc.resultSetRecords.size());
		List<SelectOption> testOpt = psc.getPHL1Options();
		List<SelectOption> testOpt2 = psc.getCustomerSites();
		pageReference p = psc.determineNewTargetAndFloor();
		psc.clearSearchResults();
		Test.stopTest();
            }
	}
	
	testmethod static void testViewPriceChange() {
		Account testCustomer = TestUtils.createAccount('Big Test Corp', null);
		Sales_Site__c testCompany = TestUtils.createSalesSite('TC402', null, null);
		Sales_Site__c testRegion = TestUtils.createSalesSite('TR402', testCompany.Id, null);
		Sales_Site__c testSite = TestUtils.createSalesSite('TS402', testCompany.Id, testRegion.Id);
		Material_Item__c testMi = TestUtils.createMaterialItem('TMI402', 'TMC402', 'PL001', testSite.Id);
		Pricing_Rule__c testPr1 = TestUtils.createPricingRule(testSite.Id, testCustomer.Id, testRegion.Id, true, testMi.Id, 1, 'LB', 10.00, 20.00, System.today(), System.today().addDays(365));
		Opportunity testOpp = TestUtils.createOppty('TO003', testCustomer.Id, 'Prospecting');
		Quote__c quote = TestUtils.createQuote(testOpp, testSite.Id);
		Test.startTest();
		PricingSearchController psc = new PricingSearchController();
		psc.dummyPr.Account__c = testCustomer.Id;
		psc.dummyPr.Material_Item__c = testMi.Id;
		psc.dummyPr.Customer_Group__c = '01 Retail';
		psc.dummyAccountObject.ParentId = testCustomer.Id;
		psc.searchRecords();
		psc.selectAll = true;
		psc.selectAllRecords();
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item2.modifyFieldValue = '100';
		//}
		for(Integer o=0; o<psc.resultSetRecords.size(); o++) {
			psc.resultSetRecords.get(o).selectForSaving = true;
		}
		System.assertEquals(null, psc.determineNewTargetAndFloor());
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item1.percentOf = 'Target_Price__c';
			psc.item1.percentChange = true;
			psc.item2.modifyFieldValue = '100';
			psc.item2.percentOf = 'Target_Price__c';
			psc.item2.percentChange = true;			
		//}
		System.assertEquals(null, psc.determineNewTargetAndFloor());
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item1.percentOf = 'Floor_Price__c';
			psc.item1.percentChange = true;
			psc.item2.modifyFieldValue = '100';
			psc.item2.percentOf = 'Floor_Price__c';
			psc.item2.percentChange = true;			
		//}
		System.assertEquals(null, psc.determineNewTargetAndFloor());
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item1.percentOf = 'Avg_Sell_Price__c';
			psc.item1.percentChange = true;
			psc.item2.modifyFieldValue = '100';
			psc.item2.percentOf = 'Avg_Sell_Price__c';
			psc.item2.percentChange = true;			
		//}
		System.assertEquals(null, psc.determineNewTargetAndFloor());								
		Test.stopTest();		
	}
	
	testMethod static void testGetNewValueAsPercentage() {
		PricingSearchController psc = new PricingSearchController();
		Decimal result = psc.getNewValueAsPercentage('65', '315.32', 'Deprecated');
		System.assertEquals(204.958, result);
	}
	
	testmethod static void testSaveEdits() {
		Account testCustomer = TestUtils.createAccount('Big Test Corp', null);
		Sales_Site__c testCompany = TestUtils.createSalesSite('TC402', null, null);
		Sales_Site__c testRegion = TestUtils.createSalesSite('TR402', testCompany.Id, null);
		Sales_Site__c testSite = TestUtils.createSalesSite('TS402', testCompany.Id, testRegion.Id);
		Material_Item__c testMi = TestUtils.createMaterialItem('TMI402', 'TMC402', 'PL001', testSite.Id);
		Pricing_Rule__c testPr1 = TestUtils.createPricingRule(testSite.Id, testCustomer.Id, testRegion.Id, true, testMi.Id, 1, 'LB', 10.00, 20.00, System.today(), System.today().addDays(365));
		Opportunity testOpp = TestUtils.createOppty('TO001', testCustomer.Id, 'Prospecting');
		Quote__c quote = TestUtils.createQuote(testOpp, testSite.Id);
		Test.startTest();
		PricingSearchController psc = new PricingSearchController();
		psc.dummyPr.Account__c = testCustomer.Id;
		psc.dummyPr.Material_Item__c = testMi.Id;
		psc.dummyPr.Customer_Group__c = '02 Retail';
		//psc.dummyAccountObject.ParentId = testCustomer.Id;
		psc.searchRecords();

		
		psc.selectAll = true;
		psc.selectAllRecords();
		Integer dayCounter = 1;
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item2.modifyFieldValue = '100';
			pageReference p = psc.determineNewTargetAndFloor();
		//}
		for(Integer o=0; o<psc.resultSetRecords.size(); o++) {
			psc.resultSetRecords.get(o).selectForSaving = true;
		}
		psc.dummyPr.Price_Valid_From__c = System.today().addDays(dayCounter++);
		System.assertEquals(null, psc.saveEdits());
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item1.percentOf = 'Target_Price__c';
			psc.item1.percentChange = true;
			psc.item2.modifyFieldValue = '100';
			psc.item2.percentOf = 'Target_Price__c';
			psc.item2.percentChange = true;			
		//}
		psc.dummyPr.Price_Valid_From__c = System.today().addDays(dayCounter++);
		System.assertEquals(null, psc.saveEdits());
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item1.percentOf = 'Floor_Price__c';
			psc.item1.percentChange = true;
			psc.item2.modifyFieldValue = '100';
			psc.item2.percentOf = 'Floor_Price__c';
			psc.item2.percentChange = true;
		//}
		psc.dummyPr.Price_Valid_From__c = System.today().addDays(dayCounter++);
		System.assertEquals(null, psc.saveEdits());
		//for(Integer l=0; l<psc.editFields.size(); l++) {
			psc.item1.modifyFieldValue = '100';
			psc.item1.percentOf = 'Avg_Sell_Price__c';
			psc.item1.percentChange = true;
			psc.item2.modifyFieldValue = '100';
			psc.item2.percentOf = 'Avg_Sell_Price__c';
			psc.item2.percentChange = true;			
		//}
		psc.dummyPr.Price_Valid_From__c = System.today().addDays(dayCounter++);
		System.assertEquals(null, psc.saveEdits());		
								
		Test.stopTest();		
	}	
	
}