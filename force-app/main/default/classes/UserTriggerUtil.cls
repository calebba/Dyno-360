public with sharing class UserTriggerUtil {
	static final string EmpRecTypeId = '01230000000mTze';
	static final string DynoInternalAccount = '0013000000eRvfD';
	
	@future
	public static void CreateUserContactRecord(List<Id> UserIds){
		CreateUserContactRecordSYNC(UserIds);
	}
		
	public static void CreateUserContactRecordSYNC(List<Id> UserIds){
		List<User> Users = [Select Id, FirstName, LastName, Email, Title, Street,
									City, State, PostalCode, IsActive, Phone, Fax,
									MobilePhone, Employee__c
							From User
							Where Id in :UserIds];
		List<Contact> NewContacts = new List<Contact>();
		Contact con;
		
		for(User u : Users){
			con = new Contact();
			con.FirstName = u.FirstName;
			con.LastName = u.LastName;
			con.Email = u.Email;
			con.Title = u.Title;
			con.MailingStreet = u.Street;
			con.MailingCity = u.City;
			con.MailingState = u.State;
			con.MailingPostalCode = u.PostalCode;
			con.Active__c = u.IsActive;
			con.User__c = u.Id;
			con.Phone = u.Phone;
			con.Fax = u.Fax;
			con.MobilePhone = u.MobilePhone;
			con.AccountId = DynoInternalAccount;
			con.RecordTypeId = EmpRecTypeId;
			con.Updated_by_User__c = true;
			con.Employee__c = u.Employee__c;
			
			NewContacts.add(con);
		}
		
		insert NewContacts;
	}
	
	/* UserContactSync makes this unnecessary
	@future
	public static void UpdateUserContactRecord(List<Id> UserIds){
		boolean conFound;
		List<User> Users = [Select Id, FirstName, LastName, Email, Title, Street,
									City, State, PostalCode, IsActive, Phone, Fax,
									MobilePhone
							From User
							Where Id in :UserIds];
		
		Map<Id,User> UserMap = new Map<Id,User>();
		UserMap.putAll(Users);
		
		List<Contact> ExistingContacts = [Select Id, FirstName, LastName, Email, Title, MailingStreet, MailingCity,
												MailingState, MailingPostalCode, Active__c, Phone, Fax,
												MobilePhone, User__c
											From Contact
											Where User__c in :UserMap.keySet()];
		List<Id> ContactNotFound = new List<Id>();
		
		for(Id u : UserMap.keySet()){
			conFound = false;
			
			for(Contact con : ExistingContacts){
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
					
					break;
				}
			}
			
			if(!conFound){
				ContactNotFound.add(u);
			}
		}
		
		update ExistingContacts;
		
		if(ContactNotFound.size() > 0){
			CreateUserContactRecordSYNC(ContactNotFound);
		}
	}
	*/
}