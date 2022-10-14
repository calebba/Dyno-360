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
private class ConsultingServicesTriggerTestClass {

    static testMethod void testConServ() {
    Test.startTest();
    Id ownerId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
    Account acct1 = new Account();
    acct1.Name = 'Test Method Account';
    acct1.ShippingState = 'UT';
    acct1.ShippingPostalCode = '84121';
    acct1.Account_Manager__c = '05 JEFF BURTON';
    acct1.OwnerId = ownerId;
         
    insert acct1;
    Consulting_Services__c cs = new Consulting_Services__c();
    cs.Name = 'Test Record1';
    cs.Consultant_Name__c = 'Rick Nash';
    cs.Consultant_Type__c = 'Consultant';
    cs.Full_Account_Name__c = acct1.id;
    cs.Consulting_Description__c = 'my description';
    cs.Customer_PO__c = 'my po';
    cs.Date_Of_Project__c = System.today();
    
    insert cs;
    Test.stopTest();
    }
}