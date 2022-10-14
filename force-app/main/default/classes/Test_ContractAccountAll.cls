@isTest
public class Test_ContractAccountAll {
    public static testmethod void test1() {
        Account acc = TestUtils.createAccount('TestAccount', null);
        Dyno_Nobel_Contract__c c = new Dyno_Nobel_Contract__c();
        insert c;
        
        Contract_Account__c ca = new Contract_Account__c();
        ca.Account__c = acc.Id;
        ca.Contract__c = c.Id;
        insert ca;
    }
}