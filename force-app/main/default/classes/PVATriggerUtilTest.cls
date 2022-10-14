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
private class PVATriggerUtilTest {

    static testMethod void myUnitTest() {
        Profile p = [select id from profile where name='Standard User']; 
        User VP_user = new User(alias = 'standt3', email='standarduser@testorg.com3', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='abc@testorg.com', 
            State = 'UT', PostalCode = '84121');
            insert VP_user;
        User PM_User = new User(alias = 'standt2', email='standarduser@testorg.com2', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='def@testorg.com', 
            State = 'UT', PostalCode = '84121');   
            insert PM_User;
        User u = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='fgi@testorg.com3', Vice_President__c = VP_user.Id,
            Product_Manager__c = PM_User.Id, State = 'UT', PostalCode = '84121');
         insert u;
        
        Account testAccount = new Account();
    	testAccount.Name = 'PVA Account Test';
    	testAccount.SAP_Account_Number__c = '34401';
    	testAccount.OwnerId = u.Id;
        testAccount.ShippingCountry = 'US';
    	testAccount.ShippingState = 'UT';
    	testAccount.ShippingPostalCode = '84121';
    	insert testAccount;
       
        Test.StartTest();
        
        PVA__c pvaTest = new PVA__c();
       	pvaTest.Account__c = testAccount.Id;
       	//pvaTest.Name = 'Test PVA';
       	pvaTest.PVA_End_Date__c = Date.today();
       	insert pvaTest;
       	
       	PVA__c pvaAssert = [SELECT Id, PM__c, VP__c FROM PVA__c WHERE Id=:pvaTest.Id]; 
       	System.assertEquals(pvaAssert.PM__c, PM_User.Id);
       	System.assertEquals(pvaAssert.VP__c, VP_User.Id);
       	System.debug('PVA Trigger Test Complete');
        Test.StopTest();
    }
}