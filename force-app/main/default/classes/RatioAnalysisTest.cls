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
private class RatioAnalysisTest {

    static testMethod void testConstructor() {
        Account testCust = TestUtils.createAccount('TA298', null);
        //Sales_Site__c testSite = TestUtils.createPlant('TP092');
        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'TP092');
        Cost_Driver_Entry__c testCDE = TestUtils.createCDE(testCust, sites[2], 8, 12, 9, 20, 7, 9, System.today().toStartOfMonth());
        PCA__c testPCA = TestUtils.createPCA(sites[2], System.today().toStartOfMonth(), 5, 12, 18, 20, 4, 13);
        Sales_Site__c testSite2 = TestUtils.createPlant('TPFAKE092');
        Opportunity testDeal = TestUtils.createOppty('TD276', testCust.Id, 'Prospecting', [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Quoted' LIMIT 1].Id);
        Quote__c testQuote = TestUtils.createQuote(testDeal);
        testQuote.Sales_Organization_Primary__c = sites[2].Id;
        update testQuote;
        //Blast_Pattern__c testBp = TestUtils.createBlastPattern('TBP982', testQuote, 6.00, 8.00, 7.00, 15.00, 8.00, 14.00, 6.00, 9.00, 4.00, 8.00, 2.00, 9.81, 2.00);
        Material_Item__c testMi = TestUtils.createMaterialItem('TM284', 'TM284', 'TM372', sites[2].Id);
        Material_Item__c testMi2 = TestUtils.createMaterialItem('TM285', 'TM285', 'TM373', sites[2].Id);
        Material_Cost__c testCost = TestUtils.createMaterialCost(testMi, sites[2], 10, 'Medium');
        Material_Cost__c testCost2 = TestUtils.createMaterialCost(testMi2, sites[2], 10, 'Medium');        
        Pricing_Rule__c testPr = TestUtils.createPricingRule(sites[2], sites[2], testMi, 1, 2);
        Pricing_Rule__c testPr2 = TestUtils.createPricingRule(sites[2], sites[2], testMi2, 1, 2);
        Quote_Line_Item__c testQli = TestUtils.createQli(testMi, 12, '1: Half Cent', testQuote, 5, sites[2]);
        Quote_Line_Item__c testQli2 = TestUtils.createQli(testMi2, 11, '1: Half Cent', testQuote, 5, sites[2]);
        
        Test.startTest();       
        RatioAnalysisController rac = new RatioAnalysisController();
        rac.dummyOpp.AccountId = testCust.Id;
        rac.dummyQuote.Sales_Organization_Primary__c = sites[2].Id;
        rac.dummyQuote.Price_Valid_From__c =  date.newinstance(2010, 1, 1);
        rac.dummyQuote.Price_Valid_To__c =    date.newinstance(2012, 1, 1);
        rac.performAnalyzation();
   
        //System.assertEquals(rac.fancyRevenue, '115');
        Test.stopTest();
    }
}