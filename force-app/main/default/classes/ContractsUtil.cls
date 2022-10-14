public with sharing class ContractsUtil {

    public static void UpdateContractFields(Set<Id> ids) {
    /* Commented out to remove fields
        List<Dyno_Nobel_Contract__c> contracts = [SELECT Id, OwnerId,
                                                    Pricing_Analyst__c,
                                                    Regional_Sales_Manager__c,        
                                                    General_Manager__c,
                                                    VP__c,
                                                    President__c,
                                                    CEO__c,
                                                    IS_Product_Manager__c,
                                                    AN_Product_Manager__c,  //Added by JT 6/13                                                 
                                                    Service_Manager__c,
                                                    Logistics_Manager__c,
                                                    Financial_Reviewer__c,
                                                    Senior_Financial_Reviewer__c,
                                                    Legal_Reviewer__c,
                                                    Senior_Legal_Reviewer__c,
                                                    Director_Of_Strategic_Accounts__c
                                                  FROM Dyno_Nobel_Contract__c WHERE Id in :ids];
        
        Set<Id> ownerIds = new Set<Id>();
        for (Dyno_Nobel_Contract__c contract : contracts)
            ownerIds.add(contract.OwnerId);
            
        Map<Id, User> users = new Map<Id, User>([SELECT Id,
                                                    Pricing_Manager__c,
                                                    RSM__c,
                                                    General_Manager__c,
                                                    Vice_President__c,
                                                    President__c,
                                                    CEO__c,
                                                    IS_Product_Manager__c,
                                                    AN_Product_Manager__c, // Added by JT (6/13/2012)
                                                    Service_Manager__c,
                                                    Transportation_Manager__c,
                                                    Financial_Reviewer__c,
                                                    Senior_Financial_Reviewer__c,
                                                    Legal_Reviewer__c,
                                                    Senior_Legal_Reviewer__c,
                                                    Director_Of_Strategic_Accounts__c
                                                  FROM User WHERE Id in :ownerIds]);
            
        List<Dyno_Nobel_Contract__c> toUpdate = new List<Dyno_Nobel_Contract__c>();                                   
        for (Dyno_Nobel_Contract__c contract : contracts) {
            boolean changed = false;
            if (contract.Pricing_Analyst__c != users.get(contract.OwnerId).Pricing_Manager__c) {
                contract.Pricing_Analyst__c = users.get(contract.OwnerId).Pricing_Manager__c;
                changed = true;
            }
            if (contract.Regional_Sales_Manager__c != users.get(contract.OwnerId).RSM__c) {
                contract.Regional_Sales_Manager__c = users.get(contract.OwnerId).RSM__c;
                changed = true;
            }
            if (contract.General_Manager__c != users.get(contract.OwnerId).General_Manager__c) {
                contract.General_Manager__c = users.get(contract.OwnerId).General_Manager__c;
                changed = true;
            }
            if (contract.VP__c != users.get(contract.OwnerId).Vice_President__c) {
                contract.VP__c = users.get(contract.OwnerId).Vice_President__c;
                changed = true;
            }
            if (contract.President__c != users.get(contract.OwnerId).President__c) {
                contract.President__c = users.get(contract.OwnerId).President__c;
                changed = true;
            }
            if (contract.CEO__c != users.get(contract.OwnerId).CEO__c) {
                contract.CEO__c = users.get(contract.OwnerId).CEO__c;
                changed = true;
            }
            if (contract.IS_Product_Manager__c != users.get(contract.OwnerId).IS_Product_Manager__c) {
                contract.IS_Product_Manager__c = users.get(contract.OwnerId).IS_Product_Manager__c;
                changed = true;
            }
            //Added by Jason 6/13/2012
            if (contract.AN_Product_Manager__c != users.get(contract.OwnerId).AN_Product_Manager__c) {
                contract.AN_Product_Manager__c = users.get(contract.OwnerId).AN_Product_Manager__c;
                changed = true;
            }            
            if (contract.Service_Manager__c != users.get(contract.OwnerId).Service_Manager__c) {
                contract.Service_Manager__c = users.get(contract.OwnerId).Service_Manager__c;
                changed = true;
            }
            if (contract.Logistics_Manager__c != users.get(contract.OwnerId).Transportation_Manager__c) {
                contract.Logistics_Manager__c = users.get(contract.OwnerId).Transportation_Manager__c;
                changed = true;
            }
            if (contract.Financial_Reviewer__c != users.get(contract.OwnerId).Financial_Reviewer__c) {
                contract.Financial_Reviewer__c = users.get(contract.OwnerId).Financial_Reviewer__c;
                changed = true;
            }
            if (contract.Senior_Financial_Reviewer__c != users.get(contract.OwnerId).Senior_Financial_Reviewer__c) {
                contract.Senior_Financial_Reviewer__c = users.get(contract.OwnerId).Senior_Financial_Reviewer__c;
                changed = true;
            }
            if (contract.Legal_Reviewer__c != users.get(contract.OwnerId).Legal_Reviewer__c) {
                contract.Legal_Reviewer__c = users.get(contract.OwnerId).Legal_Reviewer__c;
                changed = true;
            }
            if (contract.Senior_Legal_Reviewer__c != users.get(contract.OwnerId).Senior_Legal_Reviewer__c) {
                contract.Senior_Legal_Reviewer__c = users.get(contract.OwnerId).Senior_Legal_Reviewer__c;
                changed = true;
            }
            if (contract.Director_Of_Strategic_Accounts__c != users.get(contract.OwnerId).Director_Of_Strategic_Accounts__c) {
                contract.Director_Of_Strategic_Accounts__c = users.get(contract.OwnerId).Director_Of_Strategic_Accounts__c;
                changed = true;
            }
            
            if (changed)
                toUpdate.add(contract);
        }
        
        if (toUpdate.size() > 0)
            update toUpdate;
    }
    
    public static testMethod void test1() {
    
        Account a = new Account();
        a.Name = 'Lucian447745';
        insert a;
        
        Dyno_Nobel_Contract__c c = new Dyno_Nobel_Contract__c();
        //c.Status__c = 'Tender Under Review';
        c.Contract_Type__c = 'New Business';
        c.Pricing_Analyst__c = UserInfo.getUserId();
        c.Regional_Sales_Manager__c = UserInfo.getUserId();
        c.General_Manager__c = UserInfo.getUserId();
        //c.Vice_President__c = UserInfo.getUserId();
        //c.COO__c = UserInfo.getUserId();
        c.President__c = UserInfo.getUserId();
        c.CEO__c = UserInfo.getUserId();
        c.IS_Product_Manager__c = UserInfo.getUserId();
        c.AN_Product_Manager__c = UserInfo.getUserId(); //Added by Jason 6/13        
        c.Service_Manager__c = UserInfo.getUserId();
        //c.Logistics_Manager__c = UserInfo.getUserId();
        c.Financial_Reviewer__c = UserInfo.getUserId();
        c.Senior_Financial_Reviewer__c = UserInfo.getUserId();
        c.Legal_Reviewer__c = UserInfo.getUserId();
        c.Senior_Legal_Reviewer__c = UserInfo.getUserId();
        c.Director_Of_Strategic_Accounts__c = UserInfo.getUserId();
        c.Commencement_Date__c = Date.today();
        c.Contract_Expires_on__c = Date.today();
        c.Customer_Name__c = 'Lucian448567';
        c.Distributors_JVs__c = 'Lucian446734';
        c.Hedging_Remedy_Clause__c = 'Yes';
        c.How_Could_we_have_done_Better__c = 'Lucian100548';
        c.Maximum_Amount__c = 100;
        c.Minimum_Amount__c = 10;
        c.What_did_we_learn__c = 'Lucian000429';
        c.Services_to_Be_Supplied__c = 'Lucian332478';
        c.Term_In_Months__c = 12;
        c.Parent_Company__c = a.Id;
        insert c;
        */
    }

}