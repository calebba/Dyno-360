public with sharing class AccountTriggerUtil {

	public static void updateUsableOwner(List<Account> acctList) {
		for(Account a : acctList) {
			a.Usable_Owner__c = a.OwnerId;
		}
		//************  Below added by RPN July 19 2011 for changing customer owner from Integration to Acct Manager
		List<User> AllUsers1 = [SELECT Name, IsActive from User order by name];
		Map<String, ID>UserNametoID1 = new Map<String,ID>();
		String amName1;
		
		for(User u : AllUsers1) {
			UserNameToId1.put(u.Name.toUpperCase(),u.Id);
		}
		
		Id IntegId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
		for(Account a : acctList){
			if(a.Account_Manager__c != null && IntegId == a.OwnerId){
					amName1 = a.Account_Manager__c.replaceAll('[0-9]','').trim().toUpperCase();
					if(UserNameToId1.containsKey(amName1)){
						id theid;
						theid = UserNameToId1.get(amName1);
						Boolean isAct = [SELECT Id, IsActive FROM User WHERE Id = :theid].IsActive;
						If (isAct) {
							a.OwnerId = UserNameToId1.get(amName1);
						}
					}
			}
		}
		
	}	
		// ***********  End of change by RPN July 19 2011
	
	public static void reassignCustomer(List<Account> accts) {
		//List<Account> UpdatedAccounts = new List<Account>();
		List<User> AllUsers = [Select Name, Alternate_Name__c From User order by name];
		Map<String,Id> UserNameToId = new Map<String,Id>();
		Map<String,Id> AltUserNameToId = new Map<String,Id>();
		String amName;
		String smName;
		
		for(User u : AllUsers){
			UserNameToId.put(u.Name.toUpperCase(),u.Id);
			
			if(u.Alternate_Name__c != null){
				AltUserNameToId.put(u.Alternate_Name__c.toUpperCase(),u.Id);
			}
		}
		
		for(Account a : accts){
			if(a.Account_Manager__c != null){
				amName = a.Account_Manager__c.replaceAll('[0-9]','').trim().toUpperCase();
			}else{
				amName = '';
			}
			
			if(a.Sales_Manager__c != null){
				smName = a.Sales_Manager__c.replaceAll('[0-9]','').trim();
			}else{
				smName = '';
			}
			
			if(amName != '' || smName != ''){
				if(UserNameToId.containsKey(amName)){
					a.OwnerId = UserNameToId.get(amName);
					//UpdatedAccounts.add(a);
				}else if(AltUserNameToId.containsKey(amName)){
					a.OwnerId = AltUserNameToId.get(amName);
					//UpdatedAccounts.add(a);
				}else if(UserNameToId.containsKey(smName)){
					a.OwnerId = UserNameToId.get(smName);
					//UpdatedAccounts.add(a);
				}else if(AltUserNameToId.containsKey(smName)){
					a.OwnerId = AltUserNameToId.get(smName);
					//UpdateAccounts.add(a);
				}
			}
		}
	}
	
	public static String getGenericUserForRole(String roleName) {
		String sUser = '';
		if( roleName.startswith('Appalachia')  ){
			sUser = 'Generic Appalachia';
        }else if(roleName.startswith('Central Canada')){
        		sUser = 'Generic Central Canada';
        }else if(roleName.startswith('East Canada')){
        		sUser = 'Generic East Canada';
        		
        }else if(roleName.startswith('Iron Range')){
        		sUser = 'Genric Iron Range';
        }else if(roleName.startswith('Southeast')){
        		sUser = 'Generic Southeast';
        }else if(roleName.startswith('West N.A.')){
        		sUser = 'Generic West N';
        }else if(roleName.startswith('Product Managers')){
        		sUser = 'Generic Product Managers';
        }else{
        		sUser = 'Generic';
        }
		return sUser + ' Owner';
		
	}
	
	
}