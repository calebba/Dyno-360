global class UserContactSync implements Database.Batchable<sObject> {
	global final String Query;
	
	global UserContactSync(String q){
		Query = q;
		//unless we're running a test, query should be:
		//'Select Id,FirstName,LastName,Email,Title,Street,City,State,PostalCode,IsActive,Phone,Fax,MobilePhone From User'
	}
	
	global Database.Querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(Query);
	}
	
	global void execute(Database.BatchableContext BC, List<User> scope){
		List<Id> UserIds = new List<Id>();
		List<Contact> Employees;
		Map<Id,User> UserMap = new Map<Id,User>();
		boolean conFound;
		List<Id> ContactNotFound = new List<Id>();
		
		UserMap.putAll(scope);
		
		Employees = [Select Id, FirstName, LastName, Email, Title, MailingStreet, MailingCity,
							MailingState, MailingPostalCode, Active__c, Phone, Fax,
							MobilePhone, User__c
						From Contact
						Where User__c in :UserMap.keySet()];
		
		for(Id u : UserMap.keySet()){
			conFound = false;
			
			for(Contact con : Employees){
				if(con.User__c == u){
					conFound = true;
					
					con.FirstName = UserMap.get(u).FirstName;
					con.LastName = UserMap.get(u).LastName;
					con.Email = UserMap.get(u).Email;
					con.Title = UserMap.get(u).Title;
					con.MailingStreet = UserMap.get(u).Street;
					con.MailingCity = UserMap.get(u).City;
					con.MailingState = UserMap.get(u).State;
					con.MailingPostalCode = UserMap.get(u).PostalCode;
					con.Active__c = UserMap.get(u).IsActive;
					con.Phone = UserMap.get(u).Phone;
					con.Fax = UserMap.get(u).Fax;
					con.MobilePhone = UserMap.get(u).MobilePhone;
					con.Updated_by_User__c = true;
					con.Employee__c = UserMap.get(u).Employee__c;
					
					break;
				}
			}
			
			if(!conFound){
				ContactNotFound.add(u);
			}
		}
		
		update Employees;
		
		if(ContactNotFound.size() > 0){
			UserTriggerUtil.CreateUserContactRecordSYNC(ContactNotFound);
		}
	}

	global void finish(Database.BatchableContext BC){}
}