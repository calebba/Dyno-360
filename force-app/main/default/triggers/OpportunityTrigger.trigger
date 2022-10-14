trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    
    
    if(!OpportunityTriggerUtils.isRunning) {
        if(Trigger.isInsert) {
            if(Trigger.isBefore) {
                OpportunityTriggerUtils.generateOpportunityName(Trigger.new);
                OpportunityTriggerUtils.checkDeletionFlag(Trigger.new);
                
                List<Contact> DynoContacts =  [SELECT Name, User__c from Contact WHERE Account.Name = 'Dyno Nobel Inc.' and Employee__c = TRUE order by name];
        		Map<String, ID>ContactNametoID = new Map<String,ID>();
        		
        		for(Contact c : DynoContacts) {
        			ContactNametoID.put(c.User__c, c.Id);
        		}
                                
                // added RPN Feb 23 2012
                for(Opportunity o : Trigger.New){
                // no need to check for queue as we don't use queues: ((String)o.OwnerID).substring(0,3) == '005'
                    if( o.OwnerID != o.Owner_Copy__c){
                    	o.Owner_Copy__c = o.OwnerID;
                    }
                    // This is where we set the owner contact record.
                    if( o.Opportunity_Owner_Contact__c == NULL ){
                    	o.Opportunity_Owner_Contact__c = ContactNametoID.get(o.OwnerID);
                    	o.Opportunity_Owner_User__c = o.OwnerID;
                    }
                }
                
                //ended added RPN Feb 23 2012
            } else if(Trigger.isAfter) {
                OpportunityTriggerUtils.pullApproversToQuote(Trigger.new);
            }
        }
        
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
            	
            	List<User> AllUsers1 = [SELECT Name, IsActive, UserRole.Name from User order by name];
        		Map<String, Boolean>UserActiveStatus = new Map<String,Boolean>();
        		String amName1;
        
        		List<Contact> DynoContacts =  [SELECT Name, User__c from Contact WHERE Account.Name = 'Dyno Nobel Inc.' and Employee__c = TRUE order by name];
        		Map<String, ID>ContactIdToUserId = new Map<String,ID>();
        		Map<Id, String>UserIDtoRole = new Map<Id,String>();
        		Map<String, ID>UserNametoID1 = new Map<String,ID>();
        
        		for(User u : AllUsers1) {
            		UserActiveStatus.put(u.Id,u.IsActive);
            		UserIDtoRole.put(u.Id, u.UserRole.Name);
            		UserNameToId1.put(u.Name.toUpperCase(),u.Id);
            	}
        		
        		for(Contact c : DynoContacts) {
        			ContactIdToUserId.put(c.Id,c.User__c);
        		}
            	            	
                // added RPN Feb 23 2012
                for(Opportunity o : Trigger.New){
                // no need to check for queue as we don't use queues: ((String)o.OwnerID).substring(0,3) == '005'
       
                    if (o.Opportunity_Owner_Contact__c <> NULL){
                    	//need to have a value selected
                    	Id selectedOwnerContact = o.Opportunity_Owner_Contact__c;
                    	
						//Check if the owner that is selected on the Quote is a contact marked as active for quotes                    
                    	if (ContactIdToUserId.containskey(selectedOwnerContact)){
                    		
                    		Id selectedOwnerUser = ContactIdToUserId.get(selectedOwnerContact);
                    		
                    		//check if there is a user (active or inactive for selected user)		            	
	                    	if (UserActiveStatus.containskey(selectedOwnerUser)){
	                    		if(UserActiveStatus.get(selectedOwnerUser)){ 
	                    			//the selected owner is Active
	                    			o.OwnerID = selectedOwnerUser;
	                    			o.Opportunity_Owner_User__c = selectedOwnerUser;
	                    		}else{
	                    			//There is a user that is in active.
	                    			if (selectedOwnerUser <> NULL){
                  						//Need to add the user one of the generic users 
										String theRole = UserIDtoRole.get(selectedOwnerUser);
										String sUser = AccountTriggerUtil.getGenericUserForRole(theRole);
										if (sUser<>''){
											system.debug( sUser);
											o.Opportunity_Owner_User__c = selectedOwnerUser;
	          	                			o.OwnerId = UserNameToId1.get(sUser.toUpperCase());
										}
									} 
	                    		}
	                    	}else{
			                    //doesn't have any User record.
	                    	}	
                    	}
                    }	
                 if( o.OwnerID != o.Owner_Copy__c){
                    o.Owner_Copy__c = o.OwnerID;
                    }
                }
                //ended added RPN Feb 23 2012   
            } 
            else if(Trigger.isAfter) {
            //  OpportunityTriggerUtils.createPricingConditions(Trigger.new);
                OpportunityTriggerUtils.setClosedWon(Trigger.new);
                OpportunityTriggerUtils.pullApproversToQuote(Trigger.new);
            }
        }
       
    }
    
}