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
private class SLIAdvancedAddTests {


    @isTest static void testConstructorForNewSLI() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        System.assertNotEquals(null, advancedAdder.currentLine); 	
    }
    
    @isTest static void testGetPHL3Options() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        System.assertEquals(1, advancedAdder.getPHL3Options().size());    	
    }
    
    @isTest static void testGetFormulas() {
    	Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('TC872', 'TR872', 'TS872');
		Account          testAcct = TestUtils.createAccount('TA872', null);
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, sites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, sites.get(2).Id);		
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', sites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		update testItem;
		Formula_Component__c testFC = TestUtils.createFormulaComponent('TFC398', 'TBD2', 15);
		Formula__c testFormula = TestUtils.createFormula('TF398', testItem.Id, 50, 50);
		testFormula.Formula_Text__c = 'TFC398*TFC398';
		update testFormula;		
		Formula_Line_Item__c testFLI = TestUtils.createFormulaLineItem(testFormula.Id, testFC.Id);
		Formula_Mapping__c testMapping = TestUtils.createFormulaMapping(testFormula.Id, testAcct.Id, sites.get(2).Id, sites.get(2).Id, 10, 'KG');
		Test.stopTest();
		
		Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
		SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
		System.assertEquals(advancedAdder.getFormulas().size(), 1);
		System.assertEquals(advancedAdder.getFormulas()[0].getValue(), '--None--');
		testMapping = [SELECT Formula__c, Formula__r.Formula_Text__c FROM Formula_Mapping__c WHERE Id = :testMapping.Id LIMIT 1];
		advancedAdder.formulaList.add(testMapping);
		System.assertEquals(advancedAdder.getFormulas().size(), 1);
		System.assertNotEquals(advancedAdder.getFormulas()[0].getValue(), '--None--');
    }
    
    @isTest static void testOnFormulaCheck() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        PageReference pr = advancedAdder.onFormulaCheck();
        System.assertEquals(null, pr);
        System.assertEquals('--None--', advancedAdder.selectedPHL1);  	
    }

    @isTest static void testConstructorForExistingSLI() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Customer_Sales_Site__c css = TestUtils.createCSS(testAcct.Id, testSites.get(2).Id);
		Opportunity      testQuote  = TestUtils.createOppty('TO872', testAcct.Id, 'Proposal/Price Quote', css);
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', testSites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		testItem.PHL2__c = '00000001';
		testItem.PHL3__c = '00044';
		update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today(), System.today().addDays(30));    	
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5, testSites.get(2));
        testSLI.Formula_Flag__c = true;
        update testSLI;
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id + '&sliID=' + testSLI.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        advancedAdder.getMaterialCodes();
        advancedAdder.getPHL2Options();
        System.assertEquals(testSLI.Id, advancedAdder.currentLine.Id); 	
    }    
   
    @isTest static void testSelectItemByPHL3() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TMI382', 'PL0001111111100000', 'PL0001111111100000');
    	testItem.PHL1__c = 'PL000';
    	testItem.PHL2__c = '11111111';
    	testItem.PHL3__c = '00000';
    	update testItem;
    	Pricing_Rule__c testPr = TestUtils.createPricingRule(testSites[2].Id, testAcct.Id, testSites[1].Id, testSites[0].Id, true, testItem.Id, 1, 'LB', 10.00, 20.00, System.today(), System.today());
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id + '&materialHierarchy=' + testItem.Product_Hierarchy__c));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        advancedAdder.selectItemByPHL3();
        System.assertEquals(testItem.PHL1__c, advancedAdder.selectedPHL1);
    } 
    
    @isTest static void testSelectItem() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	testQuote.Customer_Sales_Site__c = TestUtils.createCSS(testAcct.Id, testSites.get(2).Id).Id;
    	update testQuote;
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TMI382', 'PL0001111111100000', 'JDK61');
    	testItem.PHL1__c = 'PL000';
    	testItem.PHL2__c = '11111111';
    	testItem.PHL3__c = '00000';
    	update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));       	
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id + '&materialId=' + testItem.Id + '&materialName=' + testItem.Name + '&materialPHL1=' + testItem.PHL1__c + '&materialSite=' + testSites.get(2).Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        advancedAdder.selectItem();
        advancedAdder.selectedPHL1Advanced = 'PL000';
        advancedAdder.selectedPHL2Advanced = '11111111';
        advancedAdder.getPHL3OptionsAdvanced();
        advancedAdder.getMaterialCodes();
        
        System.assertEquals(testItem.Id, advancedAdder.selectedCode);        	
    }

    @isTest static void testSelectPHL1() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	testQuote.Customer_Sales_Site__c = TestUtils.createCSS(testAcct.Id, testSites.get(2).Id).Id;
    	update testQuote;
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TMI382', 'PL0001111111100000', 'JDK61');
    	testItem.PHL1__c = 'PL000';
    	testItem.PHL2__c = '11111111';
    	testItem.PHL3__c = '00000';
    	update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));       	
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        PageReference pr = advancedAdder.selectPHL1();
        advancedAdder.selectedPHL1 = 'PL000';
        PageReference pr2 = advancedAdder.selectPHL2();
        System.assertEquals(null, pr2);
    }

    @isTest static void testGetCustomerSites() {
    	Test.startTest();
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id;
    	Account testCust = TestUtils.createAccount('TestAcct25643', null);
    	Account testCust2 = TestUtils.createAccount('TestAcct38932', null);
    	Sales_Site__c theCompany = TestUtils.createSalesSite('ATestCompany878', null, null);
    	Sales_Site__c theRegion = TestUtils.createSalesSite('ATestRegion878', theCompany.Id, null);
    	Sales_Site__c theSite = TestUtils.createSalesSite('ATestSite878', theCompany.Id, theRegion.Id);
    	Customer_Sales_Site__c testCSS1 = TestUtils.createCSS(testCust.Id, theSite.Id);
    	Opportunity testOpp = TestUtils.createOppty('TestOppName721', testCust.Id, 'Proposal/Price Quote', typeNeeded, testCust.Id);
    	Quote__c testScenario = TestUtils.createQuote(testOpp, theSite.Id);
    	Test.stopTest();   
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
    	System.runAs(TestUtils.createUserNoInsert(theCompany.Name)) {
        	SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        	List<SelectOption> soList = advancedAdder.getCustomerSites();
        	SelectOption so = soList.get(1);
        	SelectOption so1 = soList.get(0);
        	System.assertEquals('--None--', so1.getLabel());
        	System.assertEquals('--None--', so1.getValue());
        	System.assertEquals(theSite.Name, so.getLabel());
        	System.assertEquals(testCSS1.Sales_Site__c, so.getValue());
    	}       
    }    
    
    @isTest static void testPerformCancel() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        System.assertEquals(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id).getUrl(), advancedAdder.performCancel().getUrl()); 	    	
    }

    @isTest static void testPerformSave2() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Material_Item__c testItem = TestUtils.createMaterialItem('TMI382', 'PL0001111111100000', 'JDK61');
    	testItem.PHL1__c = 'PL000';
    	testItem.PHL2__c = '11111111';
    	testItem.PHL3__c = '00000';
    	update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60)); 
    	Material_Item__c testItem2 = TestUtils.createMaterialItem('TMI383', 'PL0001111111100001', 'JDK62');
    	testItem2.PHL1__c = 'PL000';
    	testItem2.PHL2__c = '11111111';
    	testItem2.PHL3__c = '00001';
    	update testItem2;
		Alternate_Unit_of_Measure__c testAUM2 = TestUtils.createAUM(testItem2.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost2 = TestUtils.createMaterialCost(testItem2, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule2 = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem2.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60)); 		    	
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5, testSites.get(2));
        testSLI.Formula_Flag__c = true;
        update testSLI;
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        PageReference pr2 = advancedAdder.selectPHL2();
        advancedAdder.setMaterialFromCode();
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Discount_Surcharge__c = true;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Discount_Amount__c = 5;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.UoM__c = 'LB';
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Material_Item__c = testItem2.Id;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Floor_Price__c = 5.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Target_Price__c = 15.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Actual_Price__c = 0.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Actual_Price__c = 10.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Quantity__c = -2;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Per__c = 10;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Cost_Adjustment__c = 0;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Cost_Adjustment_Reason__c = ' ';
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Cost_Adjustment_Reason__c = 'kitten';
        System.assertEquals(null, advancedAdder.performSave());        
        advancedAdder.currentLine.Quantity__c = 2;
        System.assertEquals(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id).getUrl(), advancedAdder.performSave().getUrl());
        
        Integer count = [SELECT count() FROM Quote_Line_Item__c WHERE Quote__c = :testScenario.Id];
        System.assertEquals(2, count);
    }
    
    @isTest static void testPerformSave() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenarioA = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	testScenarioA.Previously_Approved__c = true;
    	testScenarioA.Version_Number__c = '1';
    	update testScenarioA;
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	testScenario.Version_Number__c = '2';
    	update testScenario;
    	Material_Item__c testItem = TestUtils.createMaterialItem('TMI382', 'PL0001111111100000', 'JDK61');
    	testItem.PHL1__c = 'PL000';
    	testItem.PHL2__c = '11111111';
    	testItem.PHL3__c = '00000';
    	update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60)); 
    	Material_Item__c testItem2 = TestUtils.createMaterialItem('TMI383', 'PL0001111111100001', 'JDK62');
    	testItem2.PHL1__c = 'PL000';
    	testItem2.PHL2__c = '11111111';
    	testItem2.PHL3__c = '00001';
    	update testItem2;
		Alternate_Unit_of_Measure__c testAUM2 = TestUtils.createAUM(testItem2.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost2 = TestUtils.createMaterialCost(testItem2, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule2 = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem2.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60)); 		    	
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5, testSites.get(2));
    	Quote_Line_Item__c testSLI2 = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenarioA, 5, testSites.get(2));
        testSLI.Formula_Flag__c = true;
        update testSLI;
        testSLI2.Formula_Flag__c = true;
        update testSLI2;
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Discount_Surcharge__c = true;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Discount_Amount__c = 5;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.UoM__c = 'LB';
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Material_Item__c = testItem2.Id;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Floor_Price__c = 5.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Target_Price__c = 15.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Actual_Price__c = 0.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Actual_Price__c = 10.00;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Quantity__c = -2;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Per__c = 10;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Cost_Adjustment__c = 0;
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Cost_Adjustment_Reason__c = ' ';
        System.assertEquals(null, advancedAdder.performSave());
        advancedAdder.currentLine.Cost_Adjustment_Reason__c = 'kitten';
        System.assertEquals(null, advancedAdder.performSave());        
        advancedAdder.currentLine.Quantity__c = 2;
        System.assertEquals(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id).getUrl(), advancedAdder.performSave().getUrl());
        
        Integer count = [SELECT count() FROM Quote_Line_Item__c WHERE Quote__c = :testScenario.Id];
        System.assertEquals(2, count);
    }
     
    @isTest private static void testDigitsToWords() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        
        System.assertEquals(System.Label.Digit_Zero, advancedAdder.digitsToWords('0'));
        System.assertEquals(System.Label.Digit_One, advancedAdder.digitsToWords('1'));
        System.assertEquals(System.Label.Digit_Two, advancedAdder.digitsToWords('2'));
        System.assertEquals(System.Label.Digit_Three, advancedAdder.digitsToWords('3'));
        System.assertEquals(System.Label.Digit_Four, advancedAdder.digitsToWords('4'));
        System.assertEquals(System.Label.Digit_Five, advancedAdder.digitsToWords('5'));
        System.assertEquals(System.Label.Digit_Six, advancedAdder.digitsToWords('6'));
        System.assertEquals(System.Label.Digit_Seven, advancedAdder.digitsToWords('7'));
        System.assertEquals(System.Label.Digit_Eight, advancedAdder.digitsToWords('8'));
        System.assertEquals(System.Label.Digit_Nine, advancedAdder.digitsToWords('9'));
    }
    
    @isTest private static void testWordsToDigits() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        System.assertEquals('0', advancedAdder.wordsToDigits(System.Label.Digit_Zero));
        System.assertEquals('1', advancedAdder.wordsToDigits(System.Label.Digit_One));
        System.assertEquals('2', advancedAdder.wordsToDigits(System.Label.Digit_Two));
        System.assertEquals('3', advancedAdder.wordsToDigits(System.Label.Digit_Three));
        System.assertEquals('4', advancedAdder.wordsToDigits(System.Label.Digit_Four));
        System.assertEquals('5', advancedAdder.wordsToDigits(System.Label.Digit_Five));
        System.assertEquals('6', advancedAdder.wordsToDigits(System.Label.Digit_Six));
        System.assertEquals('7', advancedAdder.wordsToDigits(System.Label.Digit_Seven));
        System.assertEquals('8', advancedAdder.wordsToDigits(System.Label.Digit_Eight));
        System.assertEquals('9', advancedAdder.wordsToDigits(System.Label.Digit_Nine));
    }
    
    @isTest private static void testSearch() {
    	Test.startTest();
        Account testCustomer = TestUtils.createAccount('TestCust001', null);
        Sales_Site__c testSite = TestUtils.createSalesSiteHierarchy('TC030', 'TR030', 'TS030').get(2);
        Material_Item__c mi = TestUtils.createMaterialItem('TestMaterialItem001', 'PREF0', 'PL0001111111100000', testSite.Id);
        mi.Material_Description__c = 'TestMaterialItem001';
        mi.PHL1__c = 'PL000';
        mi.PHL2__c = '11111111';
        mi.PHL3__c = '00000';
        mi.Preferred__c = true;
        update mi;
        Material_Cost__c testMatCost = TestUtils.createMaterialCost(mi, testSite, 10, 'Medium');
        Opportunity testOpp = TestUtils.createOppty('TO001', testCustomer.Id, 'Prospecting');
        Quote__c testQuote = TestUtils.createQuote(testOpp, testSite.Id);
        Quote_Line_Item__c qliTest = TestUtils.createQli(mi, 10, null, testQuote, 5, testSite);
        qliTest.Formula_Flag__c = true;
        update qliTest;
      
        Test.stopTest();
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testQuote.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
 
        // search failure test 
        advancedAdder.searchDescription = null;
        advancedAdder.searchCode = null;
        advancedAdder.selectedPHL1Advanced = null;
        advancedAdder.selectedPHL3Advanced = null;
        advancedAdder.sourceSalesSite = null;
        advancedAdder.dummyOpp.AccountId = null;
        advancedAdder.searchPreferred = false;
        advancedAdder.searchRecords();
        System.assertEquals(0, advancedAdder.results.size());        
            
        //advancedAdder.qliRecord.Material_Item__c = mi.Id;
        advancedAdder.searchDescription = '%M%';
        advancedAdder.searchCode = 'PREF0';
        advancedAdder.selectedPHL1Advanced = 'PL000';
        advancedAdder.selectedPHL3Advanced = 'PL0001111111100000';
        advancedAdder.sourceSalesSite = testSite.Id;
        advancedAdder.dummyOpp.AccountId = testCustomer.Id;
        advancedAdder.searchPreferred = true;
        System.assertEquals(null, advancedAdder.searchRecords());
        
        // search tests
        System.assertEquals(1, advancedAdder.results.size());  
    }
   
    private static testMethod void testGetPHL1Options() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
    	System.assert(advancedAdder.getPHL1Options().size() > 0);
    	System.assert(advancedAdder.getPHL1OptionsAdvanced().size() > 0);
    }
    
    @isTest private static void testGetPHL3OptionsAdvanced() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        advancedAdder.selectedPHL1Advanced = 'PL005';
        advancedAdder.selectedPHL2Advanced = 'PL099';
        System.assert(advancedAdder.getPHL3OptionsAdvanced().size() > 0);    	
    }
    
    @isTest private static void testPerformConversion() {
        Test.startTest();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Customer_Sales_Site__c css = TestUtils.createCSS(testAcct.Id, testSites.get(2).Id);
		Opportunity      testQuote  = TestUtils.createOppty('TO872', testAcct.Id, 'Proposal/Price Quote', css);
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', testSites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		testItem.PHL2__c = '00000001';
		testItem.PHL3__c = '00044';
		update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Alternate_Unit_of_Measure__c testAUM2 = TestUtils.createAUM(testItem.Id, 'KG', 'LB', 2, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today(), System.today().addDays(30));    	
    	Quote_Line_Item__c testSLI = TestUtils.createQli(testItem, 100, '1: Half Cent', testScenario, 5, testSites.get(2));
    	testSLI.Formula_Flag__c = false;
    	testSLI.UoM__c = 'LB';
    	update testSLI;
    	PricingEngine.PricingData pepd = new PricingEngine.PricingData(testRule, null);
    	pepd.uom = 'LB';
    	pepd.per = 1;
    	Test.stopTest();
    	
    	Test.setCurrentPage(new PageReference('/apex/SLIAdvancedAdd?scenarioId=' + testScenario.Id + '&sliID=' + testSLI.Id));
        SLIAdvancedAddController advancedAdder = new SLIAdvancedAddController();
        advancedAdder.pd = pepd;
        advancedAdder.currentLine.Base_Floor__c = 5;
        advancedAdder.currentLine.Base_Target__c = 15;
        advancedAdder.currentLine.UoM__c = 'KG';
        advancedAdder.currentLine.Floor_Price__c = 5;
        advancedAdder.currentLine.Target_Price__c = 15;
        advancedAdder.currentLine.Actual_Price__c = 15;
        advancedAdder.currentLine.Per__c = 1;
        advancedAdder.currentLine.Base_Cost__c = 0.00;
        advancedAdder.currentLine.Base_Cost_ST__c = 0.00;
        System.assertEquals(null, advancedAdder.performConversion());
        PageReference pr = advancedAdder.changePer();
        System.assertEquals(null, pr);
    }
}