@isTest
public with sharing class TestContractActionRenew {

    public static testMethod void test1() {
    
        Account a = new Account();
        a.Name = 'Lucian447745';
        insert a;
        
        Dyno_Nobel_Contract__c dnc = new Dyno_Nobel_Contract__c();
        dnc.Commencement_Date__c = Date.today();
        dnc.Contract_Expires_on__c = Date.today();
        dnc.Customer_Name__c = 'Lucian448567';
        dnc.Distributors_JVs__c = 'Lucian446734';
        //dnc.Hedging_Remedy_Clause__c = 'Lucian319845';
        dnc.How_Could_we_have_done_Better__c = 'Lucian100548';
        //dnc.Maximum_Amount__c = 100;
        //dnc.Minimum_Amount__c = 10;
        dnc.What_did_we_learn__c = 'Lucian000429';
        dnc.Services_to_Be_Supplied__c = 'Lucian332478';
        dnc.Term_In_Months__c = 12;
        //dnc.Parent_Company__c = a.Id;
        insert dnc;
        
        Contract_Action__c ca = new Contract_Action__c();
        ca.Dyno_Nobel_Contract__c = dnc.Id;
        ca.Status__c = 'Pending';
        ca.Action_Type__c = 'Labor';
        ca.Adjustment_Frequency__c = 'Monthly';
        ca.Last_Update_Date__c = null;
        ca.Start_Date__c = Date.today();
        ca.Valid_To_Date__c = Date.today().addMonths(2);
        ca.Next_Due_Date__c = Date.today().addDays(7);
        insert ca;      
        System.assertEquals(1, [SELECT COUNT() FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id]);

        ca.Action_Type__c = 'Labor';
        update ca;
        System.assertEquals(1, [SELECT COUNT() FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id]);
        
        ca.Status__c = 'Complete';
        update ca;
        System.assertEquals(2, [SELECT COUNT() FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id]);
        
        ca = [SELECT Last_Update_Date__c FROM Contract_Action__c WHERE Id = :ca.Id];
        System.assertEquals(Date.today(), ca.Last_Update_Date__c.date());
        
        Contract_Action__c ca2 = [SELECT Id, Next_Due_Date__c FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id AND Id <> :ca.Id];
        System.assertEquals(Date.today().addDays(7).addMonths(1), ca2.Next_Due_Date__c);
        
        ca2.Valid_To_Date__c = Date.today().addDays(-1);
        update ca2;
        System.assertEquals(2, [SELECT COUNT() FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id]);
        
        ca2.Status__c = 'Complete';
        update ca2;
        System.assertEquals(2, [SELECT COUNT() FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id]);
        
    } 

}