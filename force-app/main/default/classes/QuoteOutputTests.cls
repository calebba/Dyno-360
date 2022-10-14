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
private class QuoteOutputTests {

    static testMethod void testConstructor() {
    	Id typeNeeded = [SELECT Id From RecordType WHERE DeveloperName = 'Deal_Quoted' LIMIT 1].Id;
        Opportunity testOpp = TestUtils.createOppty('TO001', null, 'Prospecting', typeNeeded);
		Quote__c testQuote = TestUtils.createQuote(testOpp);
		Product_Grouping__c testPg = TestUtils.createProductGrouping('PG000', 'A Grouping', 'Test');
		Sales_Site__c testSite = TestUtils.createPlant('TP592');
		Material_Item__c testMat = TestUtils.createMaterialItem('TMI001', 'TMIC01', 'PG000', testSite.Id);
		Material_Item__c testMat2 = TestUtils.createMaterialItem('TMI001', 'TMIC02ye', 'PG123', testSite.Id);
		Material_Cost__c testCost = TestUtils.createMaterialCost(testMat, testSite, 5, 'Medium');
		Material_Cost__c testCost2 = TestUtils.createMaterialCost(testMat2, testSite, 5, 'Medium');
		Quote_Line_Item__c testQli = TestUtils.createQli(testMat, 1, 'Nearest Cent', testQuote, 1, testSite); 
		Quote_Line_Item__c testQli2 = TestUtils.createQli(testMat2, 1, 'Nearest Cent', testQuote, 1, testSite);
        testQli2.Lock_Expiration_Date__c = true;
        testQli2.Is_Bundled__c = true;
        update testQli2;
		QuoteOutputController testcomponentquoteId = new QuoteOutputController();
        testcomponentquoteId.setcomponentQuoteId(testQuote.Id);
        testcomponentquoteId.getHasLockedDates();
        testcomponentquoteId.getBlastPatterns();
		Test.startTest();
		Test.setCurrentPage(new PageReference(Page.QuoteOutputPDF.getUrl() + '?quoteID=' + testQuote.Id));
		QuoteOutputController qoc = new QuoteOutputController();
		/* Constructor Tests */
		System.assertEquals(testQuote.Id, ApexPages.currentPage().getParameters().get('quoteID'));
		System.assertEquals(testQuote.Id, qoc.theQuote.Id);
		System.assertEquals(true, qoc.isNew);
		System.assertEquals(System.today().format(), qoc.validDate);
		System.assertEquals(System.today().format(), qoc.currentDate);
		testQuote.On__c = 'No';
		testQuote.Price_Valid_To__c = System.today().addDays(+1);
		update testQuote;
		Test.setCurrentPage(new PageReference(Page.QuoteOutputPDF.getUrl() + '?quoteID=' + testQuote.Id));
		qoc = new QuoteOutputController();
		System.assertEquals(false, qoc.isNew);
				
		/* getItems Tests */
		List<Object> qliList = qoc.getItems();
		System.assertEquals(1, qliList.size());
		Test.setCurrentPage(Page.QuoteOutputPDF);
		qoc = new QuoteOutputController();
		qliList = qoc.getItems();
		System.assertEquals(null, qliList);
		
		Test.stopTest();
    }
}