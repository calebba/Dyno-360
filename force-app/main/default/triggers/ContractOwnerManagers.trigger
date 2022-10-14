trigger ContractOwnerManagers on Dyno_Nobel_Contract__c (before insert, before update) {
	System.debug('ContractOwnerManagers.trigger');
/*
    List<Id> ownerIds = new List<Id>();
    
    for (Dyno_Nobel_Contract__c newContract : Trigger.New)
        ownerIds.add(newContract.OwnerId);
        
    Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, CEO__c, Director_of_Strategic_Accounts__c, Financial_Reviewer__c,
                                                    General_Manager__c, Pricing_Manager__c, RSM__c, IS_Product_Manager__c, 
                                                    AN_Product_Manager__c, Transportation_Manager__c, Vice_President__c, 
                                                    Senior_Financial_Reviewer__c, Legal_Reviewer__c, Senior_Legal_Reviewer__c,
                                                    Service_Manager__c, President__c FROM User WHERE Id in :ownerIds]);
    
    for (Dyno_Nobel_Contract__c newContract : Trigger.New) {
        User newUser = usersMap.get(newContract.OwnerId);
        newContract.CEO__c = newUser.CEO__c;
        newContract.Director_of_Strategic_Accounts__c = newUser.Director_of_Strategic_Accounts__c;
        newContract.General_Manager__c = newUser.General_Manager__c;
        newContract.Pricing_Analyst__c = newUser.Pricing_Manager__c;
        newContract.Regional_Sales_Manager__c = newUser.RSM__c;
        newContract.IS_Product_Manager__c = newUser.IS_Product_Manager__c;
        newContract.Service_Manager__c = newUser.Service_Manager__c;
        newContract.AN_Product_Manager__c = newUser.AN_Product_Manager__c;
        newContract.Logistics_manager__c = newUser.Transportation_Manager__c;
        newContract.VP__c = newUser.Vice_President__c;
        newContract.President__c = newUser.President__c;
        newContract.Financial_Reviewer__c = newUser.Financial_Reviewer__c;
        newContract.Senior_Financial_Reviewer__c = newUser.Senior_Financial_Reviewer__c;
        newContract.Legal_Reviewer__c = newUser.Legal_Reviewer__c;
        newContract.Senior_Legal_Reviewer__c = newUser.Senior_Legal_Reviewer__c;
    }
*/
}