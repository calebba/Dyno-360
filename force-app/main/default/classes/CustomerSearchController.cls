public without sharing class CustomerSearchController {
	
	public String searchString {get; set;}
	public List<Account> customerList {get; set;}
	public String sortOrder {get; set;}
	public String sortType {get; set;}
	public Boolean includeNulls {get; set;}
	
	public CustomerSearchController() {
		searchString = '';
		customerList = new List<Account>();
		sortOrder = 'Name';
		sortType = 'asc';
		includeNulls = true;
	}
	
	public PageReference searchCustomers() {
		String tempStr = '%' + searchString + '%';
		String query;
		if(includeNulls) {
			query = 'SELECT Owner.Name, Name, Id, Valid_Sites__c, SAP_Account_Number__c, ShippingCity, ShippingState, Account_Group__c, Parent.Name, ParentId, SAPParentId__c, RecordType.Name, Account_Manager__c, Sales_Manager__c FROM Account WHERE Name like :tempStr OR SAP_Account_Number__c like :tempStr OR Parent.Name like :tempStr OR SAPParentId__c like :tempStr order by ';
		} else {
			query = 'SELECT Owner.Name, Name, Id, Valid_Sites__c, SAP_Account_Number__c, ShippingCity, ShippingState, Account_Group__c, Parent.Name, ParentId, SAPParentId__c, RecordType.Name, Account_Manager__c, Sales_Manager__c FROM Account WHERE (Name like :tempStr OR SAP_Account_Number__c like :tempStr OR Parent.Name like :tempStr OR SAPParentId__c like :tempStr) AND Name <> null AND SAP_Account_Number__c <> null AND Parent.Name <> null order by ';
		}
		customerList = Database.query(query + sortOrder + ' ' + sortType + ' LIMIT 500');
		if(customerList.size() > 499) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Advanced_Add_Too_Many_Results));
		}
		return null;
	}
}