global with sharing class CustomerReassignment implements Database.Batchable<sObject> {
	global final String Query;
	
	global CustomerReassignment(String q){
		Query = q;
		//unless we're running a test, query should be:
		//Select Sales_Manager__c, OwnerId, Name, Id, Account_Manager__c From Account Where OwnerId = '00530000003zGOT'
	}
	
	global Database.Querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(Query);
	}
	
	global void execute(Database.BatchableContext BC, List<Account> scope){
		List<Account> UpdatedAccounts = new List<Account>();
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
		
		for(Account a : scope){
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
					UpdatedAccounts.add(a);
				}else if(AltUserNameToId.containsKey(amName)){
					a.OwnerId = AltUserNameToId.get(amName);
					UpdatedAccounts.add(a);
				}else if(UserNameToId.containsKey(smName)){
					a.OwnerId = UserNameToId.get(smName);
					UpdatedAccounts.add(a);
				}else if(AltUserNameToId.containsKey(smName)){
					a.OwnerId = AltUserNameToId.get(smName);
					UpdatedAccounts.add(a);
				}
				
				a.Usable_Owner__c = a.OwnerId;
			}
		}
		
		if(UpdatedAccounts.size() > 0){
			update UpdatedAccounts;
		}
	}

	global void finish(Database.BatchableContext BC){}
	
	testMethod static void testCustomerReassignment(){
		test.startTest();
		Id ownerId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
		Account acct1 = new Account();
		acct1.Name = 'Test Method Account';
		acct1.ShippingState = 'UT';
		acct1.ShippingPostalCode = '84121';
		acct1.Account_Manager__c = '05 JEFF BURTON';
		acct1.OwnerId = ownerId;
		insert acct1;
		
		Account acct2 = new Account();
		acct2.Name = 'Test Method Account';
		acct2.ShippingState = 'UT';
		acct2.ShippingPostalCode = '84121';
		acct2.Sales_Manager__c = '03 KELLY ARNOLD';
		acct2.OwnerId = ownerId;
		insert acct2;
		
		Account acct3 = new Account();
		acct3.Name = 'Test Method Account';
		acct3.ShippingState = 'UT';
		acct3.ShippingPostalCode = '84121';
		acct3.OwnerId = ownerId;
		insert acct3;
		
		
		
		CustomerReassignment cr = new CustomerReassignment('Select Sales_Manager__c, OwnerId, Name, Id, Account_Manager__c From Account Where Name = \'Test Method Account\'');
		System.assertNotEquals(null, cr);
		
		ID BatchProcessId = Database.executeBatch(cr);
		
		test.stopTest();
	}
}