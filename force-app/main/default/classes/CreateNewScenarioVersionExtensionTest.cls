@isTest
public class CreateNewScenarioVersionExtensionTest {
    
	@isTest static void CreateNewScenarioVersionExtensionTest() {
        Test.startTest();
        Account testAcct = TestUtils.createAccount('TA439', null);
        List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC783', 'TR783', 'TS783');
        Opportunity testOpp = TestUtils.createOppty('TO001', testAcct.Id, 'Prospecting');
        testOpp.Sales_Site__c = testSites[2].Id;
        update testOpp;
        Quote__c testQuote = TestUtils.createQuote(testOpp, testOpp.Sales_Site__c);
        Customer_Sales_Site__c testCSS = TestUtils.createCSS(testAcct.Id, testOpp.Sales_Site__c);
    
        Test.setCurrentPage(new PageReference('/apex/CreateNewScenarioVersionPage?reactivate=y&scenarioId=' + testQuote.Id));
        ApexPages.StandardController controller2 = new ApexPages.StandardController(testQuote);
        CreateNewScenarioVersionExtension CNS = new CreateNewScenarioVersionExtension(controller2);
        CNS.scenario.Prev_Price_Valid_From__c = System.today();
        CNS.scenario.Prev_Price_Valid_To__c = System.today();
        CNS.scenario.Price_Valid_From__c = System.today();
        CNS.scenario.Price_Valid_To__c = System.today();
        pageReference p = CNS.create();
        pageReference c = CNS.cancel();
        System.assertNotEquals(p, null);
        System.assertNotEquals(c, null);
        CNS.recreateVersion = false;
        CNS.getRenderAdjustments();
        CNS.AdjustPHL1Prices();
        CNS.AdjustPHL1Quantities();
        CNS.AdjustEmptyPHL1Prices();
        CNS.AdjustEmptyPHL1Quantities();
        
        Test.stopTest();
    }
    
    @isTest static void CreateNewScenarioVersionExtensionTest2() {
        Test.startTest();
        Account testAcct = TestUtils.createAccount('TA439', null);
        List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC783', 'TR783', 'TS783');
        Opportunity testOpp = TestUtils.createOppty('TO001', testAcct.Id, 'Prospecting');
        testOpp.Sales_Site__c = testSites[2].Id;
        update testOpp;
        Quote__c testQuote = TestUtils.createQuote(testOpp, testOpp.Sales_Site__c);
        Customer_Sales_Site__c testCSS = TestUtils.createCSS(testAcct.Id, testOpp.Sales_Site__c);
    
        Test.setCurrentPage(new PageReference('/apex/CreateNewScenarioVersionPage?reactivate=n&scenarioId=' + testQuote.Id));
        ApexPages.StandardController controller2 = new ApexPages.StandardController(testQuote);
        CreateNewScenarioVersionExtension CNS = new CreateNewScenarioVersionExtension(controller2);
        CNS.scenario.Prev_Price_Valid_From__c = System.today();
        CNS.scenario.Prev_Price_Valid_To__c = System.today();
        CNS.scenario.Price_Valid_From__c = System.today();
        CNS.scenario.Price_Valid_To__c = System.today();
        pageReference p = CNS.create();
        pageReference c = CNS.cancel();
        System.assertNotEquals(p, null);
        System.assertNotEquals(c, null);
        CNS.recreateVersion = true;
         Test.stopTest();
        
    }
}