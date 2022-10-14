public with sharing class ContractPermissionsClass {

    public static void CreatePermissions(Set<Id> accountIds) {
/*        
        List<Dyno_Nobel_Contract__c> contracts = [SELECT Id, Parent_Company__c FROM Dyno_Nobel_Contract__c WHERE Parent_Company__c in :accountIds];
        List<AccountShare> accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE AccountId in :accountIds];
        List<Dyno_Nobel_Contract__Share> conShares2 = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Dyno_Nobel_Contract__Share WHERE Parent.Parent_Company__c in :accountIds];
        
        Set<Id> groupIds = new Set<Id>();
        for (AccountShare accSh : accShares) {
            if (getObjectName(accSh.UserOrGroupId) == 'Group') {
                groupIds.add(accSh.UserOrGroupId);
            }
        }
        
        List<Group> groupList = [SELECT Id, Type FROM Group WHERE Id IN :groupIds];
        Map<Id,String> groupTypeMap = new Map<Id,String>(); 
        Set<Id> sharingGroupIds = new Set<Id>();
        for (Group g : groupList) {
            groupTypeMap.put(g.Id, g.Type);
            if (g.Type == 'SharingRuleGroup') {
                sharingGroupIds.add(g.Id);
            }
        }
        
        Map<Id,List<Id>> groupMemberMap = new Map<Id,List<Id>>();
        if (sharingGroupIds.size() > 0) {
            List<GroupMember> groupMemberList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :sharingGroupIds];
            
            for (GroupMember gm : groupMemberList) {
                if (!groupMemberMap.containsKey(gm.GroupId)) {
                    groupMemberMap.put(gm.GroupId, new List<Id>());
                }
                groupMemberMap.get(gm.GroupId).add(gm.UserOrGroupId);
            }
        }
        
        Map<Id, List<Dyno_Nobel_Contract__c>> contractsMap = new Map<Id, List<Dyno_Nobel_Contract__c>>();
        for (Dyno_Nobel_Contract__c contract : contracts) {
            if (!contractsMap.containsKey(contract.Parent_Company__c))
                contractsMap.put(contract.Parent_Company__c, new List<Dyno_Nobel_Contract__c>());
            contractsMap.get(contract.Parent_Company__c).add(contract);
        }
            
        List<Dyno_Nobel_Contract__Share> conShares = new List<Dyno_Nobel_Contract__Share>();
        
        Map<Id, User> inactiveUsers = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = false]);
        
        for (AccountShare accShare : accShares) {
            if (contractsMap.containsKey(accShare.AccountId) && !inactiveUsers.containsKey(accShare.UserOrGroupId)) {
                System.debug('contractsMap:::' + contractsMap.get(accShare.AccountId));
                for (Dyno_Nobel_Contract__c contract : contractsMap.get(accShare.AccountId)) {
                    
                    Dyno_Nobel_Contract__Share conShare = null;
                    for (Dyno_Nobel_Contract__Share cs2 : conShares2) {
                        if (cs2.ParentId == contract.Id && cs2.UserOrGroupId == accShare.UserOrGroupId) {
                            conShare = cs2;
                        }
                    }
                    
                    if (conShare == null && groupTypeMap.get(accShare.UserOrGroupId) != 'SharingRuleGroup') {
                        conShare = new Dyno_Nobel_Contract__Share();
                        conShare.ParentId = contract.Id;
                        System.debug('accShare.UserOrGroupId:::' + accShare.UserOrGroupId);
                        conShare.UserOrGroupId = accShare.UserOrGroupId;
                        
                        if (accShare.AccountAccessLevel == 'All')
                            conShare.AccessLevel = 'Edit';
                        if (accShare.AccountAccessLevel == 'Read')
                            conShare.AccessLevel = 'Read';
                        if (accShare.AccountAccessLevel == 'Edit')
                            conShare.AccessLevel = 'Edit';
                        system.debug(conshare.UserOrGroupId);
                        // upsert conShare;
                        conShares.add(conShare);
                    } else if (conShare == null && groupTypeMap.containsKey(accShare.UserOrGroupId)) {
                        for (Id key : groupMemberMap.get(accShare.UserOrGroupId)) {
                            conShare = new Dyno_Nobel_Contract__Share();
                            conShare.ParentId = contract.Id;
                            System.debug('accShare.UserOrGroupId:::' + accShare.UserOrGroupId);
                            conShare.UserOrGroupId = key;
                            
                            if (accShare.AccountAccessLevel == 'All')
                                conShare.AccessLevel = 'Edit';
                            if (accShare.AccountAccessLevel == 'Read')
                                conShare.AccessLevel = 'Read';
                            if (accShare.AccountAccessLevel == 'Edit')
                                conShare.AccessLevel = 'Edit';
                            system.debug(conshare.UserOrGroupId);
                            // upsert conShare;
                            conShares.add(conShare);
                        }
                    }
                }
            }
        }       
        upsert conShares;*/
    }
    
    /*public static String getObjectName(Id oId){
        String accId = oId;
        String objName = '';
        String keyCode  = accId.subString(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values()){
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode){
                objName = objectInstance.getDescribe().getName();
                System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Id is related to object: '+ objName);
            }
        }
        return objName;
    }*/
    
    public static void CreateContractPermissions(Set<Id> contractIds) {
        
        /*List<Dyno_Nobel_Contract__c> contracts = [SELECT Id, Pricing_Analyst__c, Regional_Sales_Manager__c, General_Manager__c, IS_Product_Manager__c, CEO__c,
                                                        Service_Manager__c, AN_Product_Manager__c, Logistics_manager__c, VP__c, President__c, Financial_Reviewer__c,
                                                        Senior_Financial_Reviewer__c, Legal_Reviewer__c, Senior_Legal_Reviewer__c, Director_of_Strategic_Accounts__c,
                                                        Optional_Reviewer_1__c, Optional_Reviewer_2__c, Optional_Reviewer_3__c, Optional_Reviewer_4__c, Optional_Reviewer_5__c
                                                    FROM Dyno_Nobel_Contract__c WHERE Id in :contractIds];
        
        List<Dyno_Nobel_Contract__Share> oldShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Dyno_Nobel_Contract__Share WHERE ParentId in :contractIds];
        Set<String> oldShareKeys = new Set<String>();
        for (Dyno_Nobel_Contract__Share oldShare : oldShares)
            oldShareKeys.add(oldShare.ParentId + '-' + oldShare.UserOrGroupId);
        List<Dyno_Nobel_Contract__Share> newShares = new List<Dyno_Nobel_Contract__Share>();
        
        for (Dyno_Nobel_Contract__c contract : contracts) {
            List<Id> userIds = new List<Id>();
            
            if (contract.Pricing_Analyst__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Pricing_Analyst__c))
                userIds.add(contract.Pricing_Analyst__c);
                
            if (contract.Regional_Sales_Manager__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Regional_Sales_Manager__c))
                userIds.add(contract.Regional_Sales_Manager__c);
                
            if (contract.General_Manager__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.General_Manager__c))
                userIds.add(contract.General_Manager__c);
                
            if (contract.IS_Product_Manager__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.IS_Product_Manager__c))
                userIds.add(contract.IS_Product_Manager__c);
                
            if (contract.CEO__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.CEO__c))
                userIds.add(contract.CEO__c);
                
            if (contract.Service_Manager__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Service_Manager__c))
                userIds.add(contract.Service_Manager__c);
                
            if (contract.AN_Product_Manager__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.AN_Product_Manager__c))
                userIds.add(contract.AN_Product_Manager__c);
                
            if (contract.Logistics_manager__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Logistics_manager__c))
                userIds.add(contract.Logistics_manager__c);
                
            if (contract.VP__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.VP__c))
                userIds.add(contract.VP__c);
                
            if (contract.President__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.President__c))
                userIds.add(contract.President__c);
                
            if (contract.Financial_Reviewer__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Financial_Reviewer__c))
                userIds.add(contract.Financial_Reviewer__c);
                
            if (contract.Senior_Financial_Reviewer__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Senior_Financial_Reviewer__c))
                userIds.add(contract.Senior_Financial_Reviewer__c);
                
            if (contract.Legal_Reviewer__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Legal_Reviewer__c))
                userIds.add(contract.Legal_Reviewer__c);
            
            if (contract.Senior_Legal_Reviewer__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Senior_Legal_Reviewer__c))
                userIds.add(contract.Senior_Legal_Reviewer__c);
                
            if (contract.Director_of_Strategic_Accounts__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Director_of_Strategic_Accounts__c))
                userIds.add(contract.Director_of_Strategic_Accounts__c);
            
            if (contract.Optional_Reviewer_1__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Optional_Reviewer_1__c))
                userIds.add(contract.Optional_Reviewer_1__c);
                
            if (contract.Optional_Reviewer_2__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Optional_Reviewer_2__c))
                userIds.add(contract.Optional_Reviewer_2__c);
            
            if (contract.Optional_Reviewer_3__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Optional_Reviewer_3__c))
                userIds.add(contract.Optional_Reviewer_3__c);
                
            if (contract.Optional_Reviewer_4__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Optional_Reviewer_4__c))
                userIds.add(contract.Optional_Reviewer_4__c);

            if (contract.Optional_Reviewer_5__c != null && !oldShareKeys.contains(contract.Id + '-' + contract.Optional_Reviewer_5__c))
                userIds.add(contract.Optional_Reviewer_5__c);
            
            for (Id userId : userIds) {
                Dyno_Nobel_Contract__Share conShare = new Dyno_Nobel_Contract__Share();
                conShare.ParentId = contract.Id;
                conShare.UserOrGroupId = userId;
                conShare.AccessLevel = 'Edit';
                newShares.add(conShare);
            }
        }
        insert newShares;*/
    }
    
     /*public static testMethod void test1() {
        
        Account a = new Account();
        a.Name = 'Lucian447745';
        insert a;
        
       User otherUser = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive=True LIMIT 1];
        
        Dyno_Nobel_Contract__c dnc = new Dyno_Nobel_Contract__c();
        dnc.VP__c = otherUser.Id;
        dnc.CEO__c = otherUser.Id;
        dnc.President__c = otherUser.Id;
        dnc.General_Manager__c = otherUser.Id;
        dnc.Financial_Reviewer__c = otherUser.Id;
        dnc.Optional_Reviewer_1__c = otherUser.Id;
        dnc.Optional_Reviewer_2__c = otherUser.Id;
        dnc.Optional_Reviewer_3__c = otherUser.Id;
        dnc.Optional_Reviewer_4__c = otherUser.Id;
        dnc.Optional_Reviewer_5__c = otherUser.Id;
        dnc.Parent_Company__c = a.Id;

        dnc.Commencement_Date__c = Date.today();
        dnc.Contract_Expires_on__c = Date.today();
        dnc.Customer_Name__c = 'Lucian448567';
        dnc.Distributors_JVs__c = 'Lucian446734';
        dnc.Hedging_Remedy_Clause__c = 'Yes';
        dnc.How_Could_we_have_done_Better__c = 'Lucian100548';
        dnc.Maximum_Amount__c = 100;
        dnc.Minimum_Amount__c = 10;
        dnc.What_did_we_learn__c = 'Lucian000429';
        dnc.Services_to_Be_Supplied__c = 'Lucian332478';
        dnc.Term_In_Months__c = 12;

        insert dnc;
        
    }*/

}