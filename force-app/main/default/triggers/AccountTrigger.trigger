trigger AccountTrigger on Account (before insert, before update) {
    
    Contact ownerContact = Null;
    Id IntegId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
    
    if(Trigger.isInsert) {
        for(Account a : Trigger.new) {
            a.Usable_Owner__c = a.OwnerId;
        }
        //************  Below added by RPN July 19 2011 for changing customer owner from Integration to Acct Manager
        List<User> AllUsers1 = [SELECT Name, IsActive, UserRole.Name, UserRoleId from User order by name];
        Map<String, ID>UserNametoID1 = new Map<String,ID>();
        Map<String, String>UserIDtoRole = new Map<String,String>();
        
        List<Contact> DynoContacts =  [SELECT Name from Contact WHERE Account.Name = 'Dyno Nobel Inc.' and Employee__c = TRUE order by name];
        Map<String, ID>ContactNametoID = new Map<String,ID>();
         
        String amName1;
        String idContact;
        
        for(User u : AllUsers1) {
            UserNameToId1.put(u.Name.toUpperCase(),u.Id);
            UserIDtoRole.put(u.Id, u.UserRole.Name);
        }
        
        for(Contact c : DynoContacts) {
          ContactNametoID.put(c.Name.toUpperCase(), c.Id);
        }

//        Id IntegId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
        for(Account a : Trigger.new){
            if(a.Account_Manager__c != null&&a.Account_Manager__c.length()>2){
                    //amName1 = a.Account_Manager__c.replaceAll('[0-9]','').trim().toUpperCase();
                    Integer thelength = a.Account_Manager__c.length();
                    amName1 = a.Account_Manager__c.right(thelength-2).trim().toUpperCase();
                    if(UserNameToId1.containsKey(amName1)){
                        id theid;
                        theid = UserNameToId1.get(amName1);
                        Boolean isAct = [SELECT Id, IsActive FROM User WHERE Id = :theid].IsActive;
                        
                        If (isAct) {
                            a.OwnerId = theid; 
                            a.Account_Owner_Contact__c = ContactNametoID.get(amName1);
                            a.Account_Owner_User__c = a.OwnerId;
                           
                        }else{
                          
                          //is there a contact record who is employee?
                          if (UserNameToId1.containsKey(amName1)){
                                                        
                            String theRole = UserIDtoRole.get(UserNameToId1.get(amName1));
                            
                            if (theRole <> ''){
                              String sUser = AccountTriggerUtil.getGenericUserForRole(theRole);
                              //
                                //a.OwnerId = UserNameToId1.get('SCOTT LEE'); 
                                if (sUser<>''){  
                                  a.Account_Owner_Contact__c = ContactNametoID.get(amName1);
                                  a.OwnerId = UserNameToId1.get(sUser.toUpperCase());  
                                  a.Account_Owner_User__c = theid;
                                }
                            } 
                          }            
                        }
                    }
            }
        }
    } else if(Trigger.IsUpdate) {
        for(Account a : Trigger.new) {
            a.Usable_Owner__c = a.OwnerId;
        }
        //************  Below added by RPN July 19 2011 for changing customer owner from Integration to Acct Manager
        List<User> AllUsers1 = [SELECT Name, IsActive, UserRole.Name, UserRoleId from User order by name];
        Map<String, ID>UserNametoID1 = new Map<String,ID>();
        Map<Id, String>ActiveUsers = new Map<Id, String>();
        Map<Id, String>UserIDtoRole = new Map<Id,String>();
        String amName1;
        
        List<Contact> DynoContacts =  [SELECT Name from Contact WHERE Account.Name = 'Dyno Nobel Inc.' and Employee__c = TRUE order by name];
        Map<String, ID>ContactNametoID = new Map<String,ID>();
        
        for(User u : AllUsers1) {
            UserNameToId1.put(u.Name.toUpperCase(),u.Id);
            //system.debug('scott---' + u.Name + ':' + u.UserRole.Name);
            UserIDtoRole.put(u.Id, u.UserRole.Name);
            if (u.IsActive==True){
              ActiveUsers.put(u.Id, u.Name);
            }
        }
        
        for(Contact c : DynoContacts) {
          ContactNametoID.put(c.Name.toUpperCase(), c.Id);
        }
        
//        Id IntegId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
        for(Account a : Trigger.new){
//            Account beforeUpdate = System.Trigger.oldMap.get(a.Id);
//            if((a.Account_Manager__c != null && IntegId == a.OwnerId)||(a.Account_Manager__c!=Null && a.Account_Manager__c != beforeupdate.Account_Manager__c)){
              if (a.Account_Manager__c != Null&&a.Account_Manager__c.length()>2){ 
                    //amName1 = a.Account_Manager__c.replaceAll('[0-9]','').trim().toUpperCase();
                    Integer thelength = a.Account_Manager__c.length();
                    amName1 = a.Account_Manager__c.right(thelength-2).trim().toUpperCase();
                    if(UserNameToId1.containsKey(amName1)){
                       id theid = UserNameToId1.get(amName1);
                      
//                        Boolean isAct = [SELECT Id, IsActive FROM User WHERE Id = :theid].IsActive;
                        If (ActiveUsers.containsKey(theid)) {
                            a.OwnerId = theid; 
                            a.Account_Owner_Contact__c = ContactNametoID.get(amName1);
                            a.Account_Owner_User__c = a.OwnerId;
                        }else{
              
             			if (ContactNametoID.containsKey(amName1)){
                            a.Account_Owner_Contact__c = ContactNametoID.get(amName1);
                			String theRole = UserIDtoRole.get(theid);
                			String sUser = AccountTriggerUtil.getGenericUserForRole(theRole);
                			a.OwnerId = UserNameToId1.get(sUser.toUpperCase());
                            a.Account_Owner_User__c = theid;
              			}               
 
                        }
                    }
            }
        }
     }
}