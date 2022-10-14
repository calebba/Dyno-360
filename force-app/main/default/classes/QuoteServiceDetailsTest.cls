@isTest
private class QuoteServiceDetailsTest {

    static testMethod void testQuoteServiceDetailOne() {
		Account testAccount = new Account();
		testAccount.Name = 'Test Account 1';
		testAccount.ShippingState = 'UT';
		testAccount.ShippingPostalCode = '84121';
        testAccount.ShippingCountry = 'US';
		insert testAccount;
    	Id typeNeeded = [SELECT Id From RecordType WHERE DeveloperName = 'Deal_Quoted' LIMIT 1].Id;
        Opportunity testOpp = TestUtils.createOppty('TO001', testAccount.Id, 'Prospecting', typeNeeded);
		Quote__c testQuote = TestUtils.createQuote(testOpp);
		Sales_Site__c testSite = TestUtils.createPlant('TP938');
		Product_Grouping__c testPg = TestUtils.createProductGrouping('PG000', 'A Grouping Explosive', 'Test');
		Material_Item__c testMat = TestUtils.createMaterialItem('TMI001', 'TMIC01', 'PG000', testSite.Id);
		Material_Item__c testMat2 = TestUtils.createMaterialItem('TMI001', 'TMIC012', 'PG123', testSite.Id);
		Material_Cost__c testCost1 = TestUtils.createMaterialCost(testMat, testSite, 5, 'Medium');
		Material_Cost__c testCost2 = TestUtils.createMaterialCost(testMat2, testSite, 5, 'Medium');		
		testQuote.Shot_Service_Hours__c = 5.00;
		testQuote.Round_Trip_Truck_Distance__c = 5.00;
		testQuote.Total_Number_of_Invoices__c = 5.00;
		testQuote.Annual_Number_of_Events__c = 1;
		update testQuote;
		Quote_Line_Item__c testQli = TestUtils.createQli(testMat, 1, 'Nearest Cent', testQuote, 1, testSite); 
		Quote_Line_Item__c testQli2 = TestUtils.createQli(testMat2, 1, 'Nearest Cent', testQuote, 1, testSite);   
		Test.startTest();
		Test.setCurrentPage(new PageReference(Page.QuoteServiceDetailsPDF.getUrl() + '?quoteID=' + testQuote.Id));
		QuoteServiceDetailsController controller = new QuoteServiceDetailsController();
    }
}