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
private class CustomerSalesSiteTest {

    @isTest static void myUnitTest() {
    	Account testAccount = new Account();
		testAccount.Name = 'Test Account 1';
		testAccount.ShippingState = 'UT';
        testAccount.ShippingCountry = 'US';
		testAccount.ShippingPostalCode = '84121';
		insert testAccount;
		
		Sales_Site__c salesRecord = new Sales_Site__c();
		salesRecord.Name = 'Sales Record';
		insert salesRecord;
		
		Account testAccount2 = new Account();
		testAccount2.Name = 'Test Account 2';
		testAccount2.ShippingState = 'UT';
        testAccount2.ShippingCountry = 'US';
		testAccount2.ShippingPostalCode = '84121';
		insert testAccount2;
		
		Sales_Site__c salesRecord2 = new Sales_Site__c();
		salesRecord2.Name = 'Sales Record 2';
		insert salesRecord2;
		
		RecordType record_SAP 		= [SELECT Id FROM RecordType WHERE DeveloperName = 'SAP_Integrated' ];
		RecordType record_Non_SAP 	= [SELECT Id FROM RecordType WHERE DeveloperName = 'SAP_Non_Integration' ];
		
		Test.startTest();
		List<Sales_Site__c> salesSiteRecords = TestUtils.createSalesSiteHierarchy('Company', 'Region','Site');
		
		
		Customer_Sales_Site__c testCSS = new Customer_Sales_Site__c();
		testCSS.Customer__c = testAccount.Id;
		testCSS.Sales_Site__c = salesSiteRecords[2].Id;
		
		
		insert testCSS;
	
		Customer_Sales_Site__c assertCSS = [SELECT Id, RecordTypeId FROM Customer_Sales_Site__c WHERE Id =: testCSS.Id];
		System.assertEquals( record_Non_SAP.Id, assertCSS.RecordTypeId);
		
		Customer_Sales_Site__c testCSS2 = new Customer_Sales_Site__c();
		testCSS2.Customer__c = testAccount2.Id;
		testCSS2.Sales_Site__c = salesSiteRecords[2].Id;
		testCSS2.SAPAccountSiteId__c = 'ITS SAP FANTASTIC';
		insert testCSS2;
		
		Customer_Sales_Site__c assertCSS2 = [SELECT Id, RecordTypeId FROM Customer_Sales_Site__c WHERE Id =: testCSS2.Id];
		System.assertEquals(record_SAP.Id, assertCSS2.RecordTypeId);
		
		Customer_Sales_Site__c testCSS3 = new Customer_Sales_Site__c();
		testCSS3.Customer__c = testAccount.Id;
		testCSS3.Sales_Site__c = salesSiteRecords[2].Id;
		
		String cssAlreadyIn = assertCSS.Id;
		cssAlreadyIn = cssAlreadyIn.substring(0,15);
		 try{
        	insert testCSS3;
   		 }
   		catch (DMLException e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []');
   		//System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: unknown duplicates value on record with id: ' + cssAlreadyIn + ': []');
        // Exit the test if the expected NullValueNotAllowedException is thrown.
       
    	}
    	Test.StopTest();	
		
    }
}