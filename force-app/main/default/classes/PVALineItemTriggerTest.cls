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
private class PVALineItemTriggerTest {

    static testMethod void myUnitTest() {
        Test.startTest();
        Account testAccount = TestUtils.createAccount('ATestAcct34', null, '0006');
    	Material_Item__c testMi = TestUtils.createMaterialItem('TMI34', 'TMI34', 'PL1231234512345678');
        //Insert 1 PVA
        PVA__c pvaTest = new PVA__c();
       	pvaTest.Account__c = testAccount.Id;
       	pvaTest.Price_List_Date__c = Date.today();
       	pvaTest.PVA_Start_Date__c = Date.today();
       	pvaTest.PVA_End_Date__c = Date.today();
       	pvaTest.Date_of_Agreement__c = Date.today();
       	insert pvaTest;
       	        
        //Insert 2 PVA LI
        PVA_Line_Item__c pvaLI1 = new PVA_Line_Item__c();
        pvaLI1.Material_Item__c = testMi.Id;
        pvaLI1.Per__c = 1;
        pvaLI1.UoM__c = 'LB';
        pvaLI1.Estimated_Annual_Quantity__c = 1;
        pvaLI1.Total_Quantity_Requested__c = 1;
        pvaLI1.PVA_Est_Retail_Floor_Price__c = 1;
        pvaLI1.PVA_Est_Retail_Target_Price__c = 1;
        pvaLI1.PVA_Est_Wholesale_Floor_Price__c = 1;
        pvaLI1.PVA_Est_Wholesale_Target_Price__c = 1;
        pvaLI1.Distributor_Current_Price__c = 1;
        pvaLI1.Requested_Price__c = 1;
        pvaLI1.Actual_Price__c = 1;
        pvaLI1.PVA__c = pvaTest.Id;
        insert pvaLI1;
        PVA_Line_Item__c pvaLI2 = new PVA_Line_Item__c();
        pvaLI2.Material_Item__c = testMi.Id;
        pvaLI2.Per__c = 1;
        pvaLI2.UoM__c = 'LB';
        pvaLI2.Estimated_Annual_Quantity__c = 1;
        pvaLI2.Total_Quantity_Requested__c = 1;
        pvaLI2.PVA_Est_Retail_Floor_Price__c = 1;
        pvaLI2.PVA_Est_Retail_Target_Price__c = 1;
        pvaLI2.PVA_Est_Wholesale_Floor_Price__c = 1;
        pvaLI2.PVA_Est_Wholesale_Target_Price__c = 1;
        pvaLI2.Distributor_Current_Price__c = 1;
        pvaLI2.Requested_Price__c = 1;
        pvaLI2.Actual_Price__c = 1; 
        pvaLI2.PVA__c = pvaTest.Id;       
        insert pvaLI2;        
        Test.stopTest();
        
        //Verify the names of the 2 PVA LI are correct.
        PVA__c thePVA = [SELECT Name FROM PVA__c WHERE Id = :pvaTest.Id LIMIT 1];
        List<PVA_Line_Item__c> theList = [SELECT PVA_Name__c FROM PVA_Line_Item__c WHERE PVA__r.Account__c = :testAccount.Id ORDER By PVA_Name__c];
        System.assertEquals(theList[0].PVA_Name__c, thePVA.Name + '-001');
        System.assertEquals(theList[1].PVA_Name__c, thePVA.Name + '-002');
        //Insert a third
        PVA_Line_Item__c pvaLI3 = new PVA_Line_Item__c();
        pvaLI3.Material_Item__c = testMi.Id;
        pvaLI3.Per__c = 1;
        pvaLI3.UoM__c = 'LB';
        pvaLI3.Estimated_Annual_Quantity__c = 1;
        pvaLI3.Total_Quantity_Requested__c = 1;
        pvaLI3.PVA_Est_Retail_Floor_Price__c = 1;
        pvaLI3.PVA_Est_Retail_Target_Price__c = 1;
        pvaLI3.PVA_Est_Wholesale_Floor_Price__c = 1;
        pvaLI3.PVA_Est_Wholesale_Target_Price__c = 1;
        pvaLI3.Distributor_Current_Price__c = 1;
        pvaLI3.Requested_Price__c = 1;
        pvaLI3.Actual_Price__c = 1; 
        pvaLI3.PVA__c = pvaTest.Id;       
        insert pvaLI3;           
        //Verify its name is correct
        theList = [SELECT PVA_Name__c FROM PVA_Line_Item__c WHERE PVA__r.Account__c = :testAccount.Id ORDER By PVA_Name__c];
        System.assertEquals(theList[0].PVA_Name__c, thePVA.Name + '-001');
        System.assertEquals(theList[1].PVA_Name__c, thePVA.Name + '-002');  
        System.assertEquals(theList[2].PVA_Name__c, thePVA.Name + '-003');        
    }
}