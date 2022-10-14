@isTest
public class PandLExtensionTest {
    
    @isTest static void pandLExtTest() {
		Test.startTest();
		Date edt = Date.today();
		Date edf = Date.today();
		String dt =  edt.format().replaceAll(' ', 'T');
		String df =  edf.format().replaceAll(' ', 'T');
		Opportunity testOpp = TestUtils.createOppty('TO001', null, 'Prospecting');
		Quote__c testQuote = TestUtils.createQuote(testOpp);
		List <Sales_Site__c> SS = TestUtils.createSalesSiteHierarchy('One', 'Two', 'Three');
		Test.setCurrentPage( new PageReference('/apex/PandLPDF?salesSiteId='+ SS[2].Id + '&fd=' + df + '&td=' + dt));
		ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
		PandLExtension plx = new PandLExtension(controller);
		
	}
    
    @isTest static void pandLExtTestAcct() {
		Test.startTest();
		Date edt = Date.today();
		Date edf = Date.today();
		String dt =  edt.format().replaceAll(' ', 'T');
		String df =  edf.format().replaceAll(' ', 'T');
		Opportunity testOpp = TestUtils.createOppty('TO001', null, 'Prospecting');
		Quote__c testQuote2 = TestUtils.createQuote(testOpp);
		Account acct = TestUtils.createAccount('TA930', null);
		Test.setCurrentPage( new PageReference('/apex/PandLPDF?accountId='+ acct.Id + '&fd=' + df + '&td=' + dt));
		ApexPages.StandardController controller = new ApexPages.StandardController(testQuote2);
		PandLExtension plx = new PandLExtension(controller);
		
	}

}