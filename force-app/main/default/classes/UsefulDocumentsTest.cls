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
private class UsefulDocumentsTest {

    static testMethod void testConstructor() {
        Account testCust = TestUtils.createAccount('TA298', null);
        testCust.Language__c = 'EN';
        Sales_Site__c testSite = TestUtils.createPlant('TP092');
        Sales_Site__c testSite2 = TestUtils.createPlant('TPFAKE092');
        Opportunity testDeal = TestUtils.createOppty('TD276', testCust.Id, 'Prospecting', [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Quoted' LIMIT 1].Id);
        Quote__c testQuote = TestUtils.createQuote(testDeal);
        testQuote.Sales_Organization_Primary__c = testSite.Id;
        update testQuote;
        Material_Item__c testMi = TestUtils.createMaterialItem('TM284', 'TM284', 'TM372', testSite.Id);
        Material_Cost__c testCost = TestUtils.createMaterialCost(testMi, testSite, 10, 'Medium');
        Quote_Line_Item__c testQli = TestUtils.createQli(testMi, 12, '1: Half Cent', testQuote, 5, testSite);
        
        Test.startTest();
        Test.setCurrentPage(new PageReference('/apex/UsefulDocumentPage?quoteID=' + testQuote.Id));
        UsefulDocumentsController udc = new UsefulDocumentsController();
        List<Document> docList = udc.docList;
   //     System.assertEquals(1, docList.size());
        
        testCust.Language__c = 'FR';
        testCust.ShippingCountry = 'CA';
        testCust.ShippingPostalCode = 'A9A 9A9';
        update testCust;
        Test.setCurrentPage(new PageReference('/apex/UsefulDocumentPage?quoteID=' + testQuote.Id));
        UsefulDocumentsController udc1 = new UsefulDocumentsController();
        
        testCust.Language__c = 'EN';
        update testCust;
        Test.setCurrentPage(new PageReference('/apex/UsefulDocumentPage?quoteID=' + testQuote.Id));
        UsefulDocumentsController udc2 = new UsefulDocumentsController();
        Test.stopTest();
    }
}