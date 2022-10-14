public with sharing class UpdateContractInfo {

    public PageReference UpdateInfo() { 
        String cId = ApexPages.currentPage().getParameters().get('id');
        try {
            Set<Id> ids = new Set<Id>();
            ids.add(cId);
            ContractsUtil.UpdateContractFields(ids);
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        } 
        return new PageReference('/' + cId); 
    }
     
    public PageReference BackToContract() {
        String cId = ApexPages.currentPage().getParameters().get('id');
        return new PageReference('/' + cId); 
    }

    public static testMethod void test1() {
        
        Account a = new Account();
        a.Name = 'Lucian447745';
        insert a;
        
        Dyno_Nobel_Contract__c c = new Dyno_Nobel_Contract__c();
        c.Commencement_Date__c = Date.today();
        c.Contract_Expires_on__c = Date.today();
        c.Customer_Name__c = 'Lucian448567';
        c.Distributors_JVs__c = 'Lucian446734';
        //c.Hedging_Remedy_Clause__c = 'Lucian319845';
        c.How_Could_we_have_done_Better__c = 'Lucian100548';
        //c.Maximum_Amount__c = 100;
        //c.Minimum_Amount__c = 10;
        c.What_did_we_learn__c = 'Lucian000429';
        c.Services_to_Be_Supplied__c = 'Lucian332478';
        c.Term_In_Months__c = 12;
        //c.Parent_Company__c = a.Id;
        insert c;
        
        ApexPages.currentPage().getParameters().put('id', c.Id);
        UpdateContractInfo uci = new UpdateContractInfo();
        uci.BackToContract();
        uci.UpdateInfo();
    }
}