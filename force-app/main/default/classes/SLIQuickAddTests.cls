/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SLIQuickAddTests {
	
    static testMethod void testController() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
        ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
        SLIQuickAddController quickAdder = new SLIQuickAddController(controller);
        
        System.assertEquals(false, quickAdder.volumetricDeal);
        System.assertEquals(false, quickAdder.renderQC);
     
    }
    
    static testMethod void testGetCustomerSites() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Customer_Sales_Site__c testCSS1 = TestUtils.createCSS(testAcct.Id, testSites.get(2).Id);
    	User testUser = TestUtils.createUserNoInsert('TC930');
    	Test.stopTest();
    	
    	List<SelectOption> selectOptions = new List<SelectOption>();
    	System.runAs(testUser) {
		    ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
		    SLIQuickAddController quickAdder = new SLIQuickAddController(controller);    
		    selectOptions = quickAdder.getCustomerSites();	
		}
		
		System.assertEquals(1, selectOptions.size());
		System.assertEquals(testCSS1.Sales_Site__c, selectOptions.get(0).getValue());
		System.assertEquals('TS930', selectOptions.get(0).getLabel());
    }
    
    static testMethod void testGoToAdvancedAdd() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
	    ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
	    SLIQuickAddController quickAdder = new SLIQuickAddController(controller);        	
    	System.assertEquals('/apex/SLIAdvancedAdd?scenarioID=' + testScenario.Id, quickAdder.goToAdvancedAdd().getUrl());
    }
    
    static testMethod void testQueryForQuote() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
	    ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
	    SLIQuickAddController quickAdder = new SLIQuickAddController(controller);
	    System.assertEquals(testScenario.Id, quickAdder.queryForQuote(testScenario.Id).Id);    	
    }
    
    /*
    static testMethod void testPublishToSAP() {
    	Test.startTest();
    	Id existingRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Existing_Customer' LIMIT 1].Id;
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	testAcct.RecordTypeId = existingRT;
    	update testAcct;
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
	    ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
	    SLIQuickAddController quickAdder = new SLIQuickAddController(controller);
	    System.assertNotEquals(null, quickAdder.publishToSAP());
	    
    }
    */
    static testMethod void testAllocatePriceAcrossSLI() {
    	Test.startTest();
    	Id volumetricRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', volumetricRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	testScenario.Volume_to_be_Blasted__c = 50;
    	update testScenario;
    	Material_Item__c testItem = TestUtils.createMaterialItem('TM930', 'TM930', 'PL0000000000000000');
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5);
    	testScenario = [SELECT Id,Active_Quote__c, Opportunity__r.Customer_Group__c, Opportunity__r.account.recordtype.developername, Opportunity__c, Quote_Amount__c, Approval_Status__c, CurrencyIsoCode, Country__c, Name, Price_Valid_From__c, Price_Valid_To__c, Opportunity__r.AccountId, Opportunity__r.RecordTypeId, Sales_Organization_Primary__r.Name, Sales_Organization_Primary__r.Company_Site__c, Sales_Organization_Primary__c, Volume_Produced__c, Volume_UoM__c, Calculated_Price__c, Quote_Description__c FROM Quote__c WHERE Id = :testScenario.Id];
    	Test.stopTest();
    	
        ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
        SLIQuickAddController quickAdder = new SLIQuickAddController(controller);
        System.assertEquals(true, quickAdder.volumetricDeal);
        System.assertEquals(null, quickAdder.allocatePriceAcrossQLI());
        quickAdder.allocatedPrice = '1.00';
        System.assertEquals(null, quickAdder.allocatePriceAcrossQLI());
    }
    
    static testMethod void testReactivateVersionOfQuote() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
	    ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
	    SLIQuickAddController quickAdder = new SLIQuickAddController(controller);        	
    	System.assertEquals('/apex/CreateNewScenarioVersionPage?reactivate=y&scenarioId=' + testScenario.Id, quickAdder.reactivateVersionOfQuote().getUrl());
    }
    
    /*
	static testmethod void testGetMaterialsAndAddSelected() {
		Test.startTest();
		//Create 1 material item, 1 pricing rule, 1 material cost
		List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('TC872', 'TR872', 'TS872');
		Account          testAcct = TestUtils.createAccount('TA872', null);
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', sites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		update testItem;
		Material_Item__c testItem2 = TestUtils.createMaterialItem('TMI873', 'TMI873', 'PL0990000000100045', sites.get(2).Id);
		testItem2.PHL1__c = 'PL099';
		update testItem2;
		Material_Item__c testItem3 = TestUtils.createMaterialItem('TMI874', 'TMI874', 'PL0990000000100046', sites.get(2).Id);
		testItem3.PHL1__c = 'PL099';
		update testItem3;
		Material_Item__c testItem4 = TestUtils.createMaterialItem('TMI875', 'TMI875', 'PL0990000000100047', sites.get(2).Id);
		testItem4.PHL1__c = 'PL099';
		update testItem4;
		Material_Item__c testItem5 = TestUtils.createMaterialItem('TMI876', 'TMI876', 'PL0990000000100048', sites.get(2).Id);
		testItem5.PHL1__c = 'PL099';
		update testItem5;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Alternate_Unit_of_Measure__c testAUM2 = TestUtils.createAUM(testItem2.Id, 'LB', 'LB', 1, 1);	
		Alternate_Unit_of_Measure__c testAUM3 = TestUtils.createAUM(testItem3.Id, 'LB', 'LB', 1, 1);	
		Alternate_Unit_of_Measure__c testAUM4 = TestUtils.createAUM(testItem4.Id, 'LB', 'LB', 1, 1);	
		Alternate_Unit_of_Measure__c testAUM5 = TestUtils.createAUM(testItem5.Id, 'LB', 'LB', 1, 1);						
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, sites.get(2), 10, 'Zero');
		Material_Cost__c testCost2 = TestUtils.createMaterialCost(testItem2, sites.get(2), 10, 'Zero');
		Material_Cost__c testCost3 = TestUtils.createMaterialCost(testItem3, sites.get(2), 10, 'Zero');
		Material_Cost__c testCost4 = TestUtils.createMaterialCost(testItem4, sites.get(2), 10, 'Zero');
		Material_Cost__c testCost5 = TestUtils.createMaterialCost(testItem5, sites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(sites.get(2).Id, testAcct.Id, sites.get(1).Id, sites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));
		Pricing_Rule__c  testRule2 = TestUtils.createPricingRule(sites.get(2).Id, testAcct.Id, sites.get(1).Id, sites.get(0).Id, true, testItem2.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));
		Pricing_Rule__c  testRule3 = TestUtils.createPricingRule(sites.get(2).Id, testAcct.Id, sites.get(1).Id, sites.get(0).Id, true, testItem3.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));
		Pricing_Rule__c  testRule4 = TestUtils.createPricingRule(sites.get(2).Id, testAcct.Id, sites.get(1).Id, sites.get(0).Id, true, testItem4.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));
		Pricing_Rule__c  testRule5 = TestUtils.createPricingRule(sites.get(2).Id, testAcct.Id, sites.get(1).Id, sites.get(0).Id, true, testItem5.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));
		Opportunity      testOpp  = TestUtils.createOppty('TO872', testAcct.Id, 'Proposal/Price Quote');
		testOpp.Customer_Sales_Site__c = TestUtils.createCSS(testAcct.Id, sites.get(2).Id).Id;
		update testOpp;
		Quote__c        testQuoteA = TestUtils.createQuote(testOpp, sites.get(2).Id);
		testQuoteA.Version_Number__c = '1';
		testQuoteA.Previously_Approved__c = true;
		update testQuoteA;
		Quote__c        testQuote = TestUtils.createQuote(testOpp, sites.get(2).Id);
		testQuote.Version_Number__c = '2';
		update testQuote;
		Quote_Line_Item__c qli1 = TestUtils.createQli(testItem, 100, '1: Half Cent', testQuote, 5);
		Quote_Line_Item__c qli2 = TestUtils.createQli(testItem2, 100, '1: Half Cent', testQuote, 5);
		Quote_Line_Item__c qli3 = TestUtils.createQli(testItem3, 100, '1: Half Cent', testQuote, 5);
		Quote_Line_Item__c qli4 = TestUtils.createQli(testItem4, 100, '1: Half Cent', testQuoteA, 5);
		Formula_Component__c testFC = TestUtils.createFormulaComponent('TFC398', 'TBD2', 15);
		Formula__c testFormula = TestUtils.createFormula('TF398', testItem4.Id, 50, 50);
		Formula_Line_Item__c testFLI = TestUtils.createFormulaLineItem(testFormula.Id, testFC.Id);
		Formula_Mapping__c testMapping = TestUtils.createFormulaMapping(testFormula.Id, testAcct.Id, sites.get(2).Id, sites.get(2).Id, 10, 'KG');
		testFormula.Formula_Text__c = 'TFC398*TFC398';
		update testFormula;
		Test.stopTest();
		
		ApexPages.StandardController myController = new ApexPages.StandardController(testQuote);
		SLIQuickAddController quickAdd = new SLIQuickAddController(myController);
		
		// Test getByPHL1 
		quickAdd.selectedPHL1 = 'PL099';
		quickAdd.getMaterialsByPHL1();
		System.assertEquals(2, quickAdd.paginator.getAll().size());
		
		// Test getBySite 
		quickAdd.siteChoice = sites.get(2).Id;
		quickAdd.getMaterialsBySite();
		System.assertEquals(1, quickAdd.formulaList.size());
		
		//Test Add Selected 
		for(SLIQuickAddController.ScenarioLine sl : quickAdd.paginator.getAll()) {
			sl.isSelected = true;
		}
		quickAdd.formulaList.get(0).isSelected = true;
		System.assertEquals(null, quickAdd.addSelected());
		System.assertEquals(6, quickAdd.quoteLineRecords.size());
		quickAdd.init();
	}*/
	
	static testMethod void testEditQLI() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TM930', 'TM930', 'PL0000000000000000');
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5);
    	Test.stopTest();
    	
    	ApexPages.StandardController myController = new ApexPages.StandardController(testScenario);
		SLIQuickAddController quickAdd = new SLIQuickAddController(myController);
		System.assertEquals(null, quickAdd.editQLI());
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&editQLI=' + testSLI.Id));
    	System.assertEquals(new PageReference('/apex/SLIAdvancedAdd?scenarioID=' + testScenario.Id + '&sliID=' + testSLI.Id).getUrl(), quickAdd.editQLI().getUrl());		
		

	}
	
	static testMethod void testDeleteQLI() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TM930', 'TM930', 'PL0000000000000000');
    	testItem.PHL1__c = 'PL000';
    	update testItem;
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5);
    	Test.stopTest();
    	
    	ApexPages.StandardController myController = new ApexPages.StandardController(testScenario);
		SLIQuickAddController quickAdd = new SLIQuickAddController(myController);
		System.assertEquals(null, quickAdd.deleteQLI());
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&deleteQLI=' + testSLI.Id));
    	System.assertEquals(null, quickAdd.deleteQLI());
    	List<Quote_Line_Item__c> quoteLineRecords = QuoteUtil.queryForChildRecordsByQuote(testScenario.Id);
    	System.assertEquals(0, quoteLineRecords.size());
	}	

	static testMethod void testGetBSGetMatGetPHL1() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TM930', 'TM930', 'PL0000000000000000');
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5);
    	Quote_Line_Item__c testSLI2 = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5);
    	testSLI2.Is_Bundled__c = true;
    	update testSLI2;
    	Test.stopTest();
    	
    	ApexPages.StandardController myController = new ApexPages.StandardController(testScenario);
		SLIQuickAddController quickAdd = new SLIQuickAddController(myController);
		System.assertEquals(1, quickAdd.getBundledServices().size());
		System.assertEquals(1, quickAdd.getMaterials().size());
		System.assert(quickAdd.getPHL1Options().size() > 0);	
	}
	
	static testMethod void testObtainAUMForSelectedStandard() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TM930', 'TM930', 'PL0000000000000000');
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5);
    	List<Alternate_Unit_of_Measure__c> aumList = new List<Alternate_Unit_of_Measure__c>();
    	aumList.add(new Alternate_Unit_of_Measure__c(AUn__c = 'KG', BUn__c = 'LB', X__c = 5, Y__c = 2, Material_Item__c = testItem.Id));
    	insert aumList;
    	SLIQuickAddController.ScenarioLine sl = new SLIQuickAddController.ScenarioLine();
    	sl.isSelected = true;
    	sl.miRecord = testItem;
    	sl.aumRecords = new List<Alternate_Unit_of_Measure__c>();
    	sl.availableUoMs = new List<SelectOption>();
    	sl.sli = new Quote_Line_Item__c();
    	sl.uom = 'LB';
    	List<SLIQuickAddController.ScenarioLine> slList = new List<SLIQuickAddController.ScenarioLine>();
    	slList.add(sl);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&materialID=' + testItem.Id));
    	ApexPages.StandardController myController = new ApexPages.StandardController(testScenario);
		SLIQuickAddController quickAdd = new SLIQuickAddController(myController);
		quickAdd.paginator.setRecords(slList);
		System.assertEquals(1, quickAdd.paginator.getAll().size());
		PageReference pr = quickAdd.obtainAUMForSelectedStandard();
		System.assertEquals(null, pr);
		System.assertEquals(1, quickAdd.paginator.getAll().get(0).aumRecords.size());
		
		
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&ruleId=' + 'null'));
		quickAdd.paginator.changePer(); 
   
	}
	
	static testMethod void testMarkAccepted() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
        ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
        SLIQuickAddController quickAdder = new SLIQuickAddController(controller);
        PageReference pr = quickAdder.markAccepted();
        testScenario = [SELECT Id, Quote_Accepted_By_Customer__c FROM Quote__c WHERE Id = :testScenario.Id];
        System.assertEquals('Yes', testScenario.Quote_Accepted_By_Customer__c);    
        System.assertEquals('/apex/SLIQuickAdd?id=' + testScenario.Id, pr.getUrl());
	}
	
	static testMethod void testLinks() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
        ApexPages.StandardController controller = new ApexPages.StandardController(testScenario);
        SLIQuickAddController quickAdder = new SLIQuickAddController(controller);
        System.assertEquals(new PageReference('/apex/UsefulDocumentPage?quoteID=' + testScenario.Id).getUrl(), quickAdder.goToDocumentPage().getUrl());
        System.assertEquals(new PageReference('/apex/ScenarioContactPage?id=' + testScenario.Id).getUrl(), quickAdder.goToQCCreate().getUrl());		
	}
}