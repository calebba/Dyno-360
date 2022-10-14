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
private class SLIPaginatorTests {

    static testMethod void testConstructor() {
        SLIPaginator paginator = new SLIPaginator();
        System.assertEquals(paginator.slList.size(), 0);
        System.assertNotEquals(paginator.paginator, null);
    }

    static testMethod void testSetRecords() {
    	SLIPaginator paginator = new SLIPaginator();
    	SLIQuickAddController.ScenarioLine aLine = new SLIQuickAddController.ScenarioLine();
    	paginator.setRecords(new List<SLIQuickAddController.ScenarioLine> {aLine});
    	System.assertEquals(paginator.slList.size() , 1);
    }    
    
    static testMethod void testHandlePageChange() {
    	SLIPaginator paginator = new SLIPaginator();
    	SLIQuickAddController.ScenarioLine aLine = new SLIQuickAddController.ScenarioLine();
    	List<SLIQuickAddController.ScenarioLine> theList = new List<SLIQuickAddController.ScenarioLine>();
    	for(Integer index = 0; index < 175; index++) {
    		theList.add(aLine);
    	}
    	paginator.setRecords(theList);
    	System.assertEquals(paginator.slList.size() , 100);
    	paginator.paginator.next();
    	System.assertEquals(paginator.slList.size() , 75);
    	paginator.handlePageChange(theList);
    	System.assertEquals(paginator.slList.size() , 175);
    }    

    static testMethod void testGetAll() {
    	SLIPaginator paginator = new SLIPaginator();
    	SLIQuickAddController.ScenarioLine aLine = new SLIQuickAddController.ScenarioLine();
    	List<SLIQuickAddController.ScenarioLine> theList = new List<SLIQuickAddController.ScenarioLine>();
    	for(Integer index = 0; index < 175; index++) {
    		theList.add(aLine);
    	}
    	paginator.setRecords(theList);
    	System.assertEquals(paginator.getAll().size() , 175);
    }
    
    static testMethod void testChangePer() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id); 
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', testSites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));    	   	
    	Test.stopTest();
    	
    	SLIQuickAddController.ScenarioLine aLine = new SLIQuickAddController.ScenarioLine();
    	aLine.sli = new Quote_Line_Item__c();
    	aLine.sli.Target_Price__c = 1;
    	aLine.sli.Floor_Price__c = 1;
    	aLine.sli.Cost__c = 0.50;
    	aLine.sli.Cost_See_Through__c = 0.50;
    	aLine.sli.Actual_Price__c = 1;
    	aLine.id = testRule.Id;
    	aLine.per = 10;
    	aLine.sli.Base_Cost__c = 0.50;
    	aLine.sli.Base_Cost_ST__c = 0.50;
    	aLine.sli.Base_Floor__c = 1;
    	aLine.sli.Base_Target__c = 1;
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&ruleID=' + testRule.Id));
    	SLIPaginator paginator = new SLIPaginator();
    	paginator.setRecords(new List<SLIQuickAddController.ScenarioLine> {aLine});
    	System.assertEquals(null, paginator.changePer());
    	System.assertEquals(0.10, aLine.sli.Target_Price__c);
    	System.assertEquals(0.10, aLine.sli.Floor_Price__c);
    	System.assertEquals(0.10, aLine.sli.Actual_Price__c);
    }    
    
    static testMethod void testObtainAUMForSelectedStandard() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id); 
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', testSites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));    	   	
    	Test.stopTest();
    	
    	SLIQuickAddController.ScenarioLine aLine = new SLIQuickAddController.ScenarioLine();
    	aLine.sli = new Quote_Line_Item__c();
    	aLine.sli.Target_Price__c = 1;
    	aLine.sli.Floor_Price__c = 1;
    	aLine.sli.Cost__c = 0.50;
    	aLine.sli.Cost_See_Through__c = 0.50;
    	aLine.sli.Actual_Price__c = 1;
    	aLine.id = testRule.Id;
    	aLine.per = 10;
    	aLine.sli.Base_Cost__c = 0.50;
    	aLine.sli.Base_Cost_ST__c = 0.50;
    	aLine.sli.Base_Floor__c = 1;
    	aLine.sli.Base_Target__c = 1;
    	aLine.isSelected = true;
    	aLine.miRecord = testItem;
    	aLine.uom = 'LB';
    	aLine.aumRecords = new List<Alternate_Unit_of_Measure__c>();
    	aLine.availableUoMs = new List<SelectOption>();
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&materialID=' + testItem.Id));
    	SLIPaginator paginator = new SLIPaginator();
    	paginator.setRecords(new List<SLIQuickAddController.ScenarioLine> {aLine});
    	System.assertEquals(null, paginator.obtainAUMForSelectedStandard());
    	System.assertEquals(1, aLine.aumRecords.size());
    	System.assertEquals(1, aLine.availableUoMs.size());
    }    

    static testMethod void testPerformConversion() {
    	Test.startTest();
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', null, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id); 
		Material_Item__c testItem = TestUtils.createMaterialItem('TMI872', 'TMI872', 'PL0990000000100044', testSites.get(2).Id);
		testItem.PHL1__c = 'PL099';
		update testItem;
		Alternate_Unit_of_Measure__c testAUM1 = TestUtils.createAUM(testItem.Id, 'LB', 'LB', 1, 1);
		Alternate_Unit_of_Measure__c testAUM2 = TestUtils.createAUM(testItem.Id, 'KG', 'LB', 23, 10);
		List<Alternate_Unit_of_Measure__c> aumList = new List<Alternate_Unit_of_Measure__c>{testAUM1, testAUM2};
		Material_Cost__c testCost = TestUtils.createMaterialCost(testItem, testSites.get(2), 10, 'Zero');
		Pricing_Rule__c  testRule = TestUtils.createPricingRule(testSites.get(2).Id, testAcct.Id, testSites.get(1).Id, testSites.get(0).Id, true, testItem.Id, 1, 'LB', 5.00, 15.00, System.today().addDays(-60), System.today().addDays(60));    	   	
    	Test.stopTest();
    	
    	SLIQuickAddController.ScenarioLine aLine = new SLIQuickAddController.ScenarioLine();
    	aLine.sli = new Quote_Line_Item__c();
    	aLine.sli.Target_Price__c = 1;
    	aLine.sli.Floor_Price__c = 1;
    	aLine.sli.Cost__c = 0.50;
    	aLine.sli.Cost_See_Through__c = 0.50;
    	aLine.sli.Actual_Price__c = 1;
    	aLine.id = testRule.Id;
    	aLine.per = 10;
    	aLine.sli.Base_Cost__c = 0.50;
    	aLine.sli.Base_Cost_ST__c = 0.50;
    	aLine.sli.Base_Floor__c = 1;
    	aLine.sli.Base_Target__c = 1;
    	aLine.sli.UoM__c = 'KG';
    	aLine.sli.Per__c = 1;
    	aLine.isSelected = true;
    	aLine.miRecord = testItem;
    	aLine.uom = 'LB';
    	aLine.aumRecords = aumList;
    	aLine.availableUoMs = new List<SelectOption>();
    	Test.setCurrentPage(new PageReference('/apex/SLIQuickAdd?id=' + testScenario.Id + '&ruleID=' + testRule.Id + '&prevUoM=LB'));
    	SLIPaginator paginator = new SLIPaginator();
    	paginator.setRecords(new List<SLIQuickAddController.ScenarioLine> {aLine});
    	System.assertEquals(null, paginator.performConversion());
    	System.assertEquals(0.23, aLine.sli.Target_Price__c);
    	System.assertEquals(0.23, aLine.sli.Floor_Price__c);
		System.assertEquals(0.23, aLine.sli.Actual_Price__c);    	
    }
    
}