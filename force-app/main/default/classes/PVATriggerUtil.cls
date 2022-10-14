public with sharing class PVATriggerUtil {


	public static void InsertManagerReferences(List<PVA__c> incPVA){
		List<Id> createdUser = new List<Id>();
		List<Id> accountIds  = new List<Id>();
		Map<Id,Account> accountPvaMap = new Map<Id,Account>();
		
		for (PVA__c a: incPVA){
			accountIds.add(a.Account__c);
			
		}
		
		List<Account> pvaOwner = [SELECT Id,OwnerId FROM Account WHERE Id in: accountIds];
		
		for (Account u: pvaOwner){
			createdUser.add(u.OwnerId);
			accountPvaMap.put(u.Id, u);
		}
		
		Map<Id, User> userRecords = new Map<Id, User>([SELECT Id, Vice_President__c, Product_Manager__c FROM User WHERE Id in: createdUser]);
		
		for(PVA__c p: incPVA){
			if (userRecords.size() > 0){
				Account accountMatch = accountPvaMap.get(p.Account__c);
				if (accountMatch != null){
					User newOwnerData = userRecords.get(accountMatch.OwnerId);
					
					if(newOwnerData != null){
						p.PM__c = newOwnerData.Product_Manager__c;
						p.VP__c = newOwnerData.Vice_President__c;
					}
				}
				
				
				
				
			}
		}
		
	
	}
}