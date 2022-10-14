trigger DynoNobelContractAll on Dyno_Nobel_Contract__c (before update) {
    if (trigger.isBefore && trigger.isUpdate) {
        setPermission();
    }
    
    public void setPermission() {
        Map<Id,Dyno_Nobel_Contract__c> dncMap = new Map<Id, Dyno_Nobel_Contract__c>();
        Set<String> usersIds = new Set<String>();
        for (Dyno_Nobel_Contract__c dnc : trigger.new) {
            if (trigger.oldMap.get(dnc.Id).Status__c != dnc.Status__c) {
                dncMap.put(dnc.Id, dnc);
            }
        }
        
        List<Dyno_Nobel_Contract__Share> permissionsList = new List<Dyno_Nobel_Contract__Share>();
        Dyno_Nobel_Contract__Share newPermission;
        for (String key : dncMap.keySet()) {
            if (dncMap.get(key).Status__c == 'Tender Notification') {
                System.debug('Tender Under Review:::' + dncMap.get(key).Tender_Review_Ids__c);
                if (dncMap.get(key).Tender_Review_Ids__c != null) {
                    List<String> idsList = dncMap.get(key).Tender_Review_Ids__c.split(',');
                    setApproversIds(idsList, dncMap.get(key));
                    usersIds.addAll(idsList);
                } else {
                    setClearApproversIds(dncMap.get(key));
                }
            } else if (dncMap.get(key).Status__c == 'Tender Approval') {
                System.debug('Tender Ready for Approval:::' + dncMap.get(key).Tender_Approval_Ids__c);
                if (dncMap.get(key).Tender_Approval_Ids__c != null) {
                    List<String> idsList = dncMap.get(key).Tender_Approval_Ids__c.split(',');
                    setApproversIds(idsList, dncMap.get(key));
                    usersIds.addAll(idsList);
                } else {
                    setClearApproversIds(dncMap.get(key));
                }
            } else if (dncMap.get(key).Status__c == 'Contract Approval') {
                System.debug('Contract Ready for Approval:::' + dncMap.get(key).Contract_Approval_Ids__c);
                if (dncMap.get(key).Contract_Approval_Ids__c != null) {
                    List<String> idsList = dncMap.get(key).Contract_Approval_Ids__c.split(',');
                    setApproversIds(idsList, dncMap.get(key));
                    usersIds.addAll(idsList);
                } else {
                    setClearApproversIds(dncMap.get(key));
                }
            }
        }
        List<Dyno_Nobel_Contract__Share> existingPermissionsList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Dyno_Nobel_Contract__Share 
                                                                WHERE ParentId IN :dncMap.keySet() and UserOrGroupId IN :usersIds];
        List<Dyno_Nobel_Contract__Share> permListToUpdate = new List<Dyno_Nobel_Contract__Share>();
        Map<String,String> existingIds = new Map<String,String>();
        for (Dyno_Nobel_Contract__Share perm : existingPermissionsList) {
            if (perm.AccessLevel == 'Read') {
                perm.AccessLevel = 'Edit';
                permListToUpdate.add(perm);
            }
            existingIds.put(perm.UserOrGroupId, perm.UserOrGroupId);
        }
        update permListToUpdate;
        //set permission
        for (String key : dncMap.keySet()) {
            if (dncMap.get(key).Status__c == 'Tender Notification' && dncMap.get(key).Tender_Review_Ids__c != null) {
                permissionsList.addAll(createPermissions(dncMap.get(key).Tender_Review_Ids__c.split(','), existingIds, dncMap.get(key).Id));
            } else if (dncMap.get(key).Status__c == 'Tender Approval' && dncMap.get(key).Tender_Approval_Ids__c != null) {
                permissionsList.addAll(createPermissions(dncMap.get(key).Tender_Approval_Ids__c.split(','), existingIds, dncMap.get(key).Id));
            } else if (dncMap.get(key).Status__c == 'Contract Approval' && dncMap.get(key).Contract_Approval_Ids__c != null) {
                permissionsList.addAll(createPermissions(dncMap.get(key).Contract_Approval_Ids__c.split(','), existingIds, dncMap.get(key).Id));
            }
        }
        upsert permissionsList;
    }
    
    private List<Dyno_Nobel_Contract__Share> createPermissions(List<String> idsList, Map<String,String> existingIds, String ParentId) {
        List<Dyno_Nobel_Contract__Share> permissionsList = new List<Dyno_Nobel_Contract__Share>();
        Dyno_Nobel_Contract__Share newPermission;
        for (String i : idsList) {
                if (!existingIds.containsKey(i)) {
                        newPermission = new Dyno_Nobel_Contract__Share();
                        newPermission.AccessLevel = 'Edit';
                        newPermission.ParentId = ParentId;
                        newPermission.UserOrGroupId = i;
                        //newPermission.RowCause = Schema.Dyno_Nobel_Contract__Share.RowCause.Owner;
                        
                        permissionsList.add(newPermission);
                    }
                }
        return permissionsList;
    }
    
    private void setClearApproversIds(Dyno_Nobel_Contract__c dncMap) {
        for (integer i=0; i < 24; i++) {
            dncMap.put('Approver_' + (i+1) + '__c', null);
        }
    }
    
    private void setApproversIds(List<String> idsList, Dyno_Nobel_Contract__c dncMap) {
        for (integer i=0; i < 24; i++) {
            dncMap.put('Approver_' + (i+1) + '__c', null);
        }
        for (integer i=0; i < idsList.size(); i++) {
            dncMap.put('Approver_' + (i+1) + '__c', idsList.get(i));
        }
        dncMap.put('Number_of_Approvers__c', idsList.size());
    }
}