@isTest
public with sharing class AccountTriggerUtil_Test {
    public AccountTriggerUtil_Test() {

    }

    private static testMethod void testAccountTrigger() {
		List<Account> aList = new List<Account>();
		List<User> uList = [SELECT Id FROM User WHERE IsActive = True LIMIT 12 ];
		
		for(Integer index = 0; index < 12; index++) {
			Account a = new Account();
			a.Name = 'TestRANDOMCHARSnhgsdg'+index;
			a.OwnerId = uList.get(Math.mod(index, uList.size())).Id;
			a.ShippingState = 'UT';
            a.ShippingCountry = 'UT';
			a.ShippingPostalCode = '84121';
			aList.add(a);
		}
		
        Test.startTest();
		insert aList;
		aList = [SELECT Id, OwnerId, Usable_Owner__c FROM Account WHERE Id in :aList];
		
		for(Account a : aList) {
			System.assertEquals(a.OwnerId, a.Usable_Owner__c);
		}
		
		for(Account a : aList) {
			a.OwnerId = uList.get(Math.mod(Math.random().intValue(), uList.size())).Id;
		}
		
		update aList;
        Test.stopTest();

		aList = [SELECT Id, OwnerId, Usable_Owner__c FROM Account WHERE Id in :aList];
		
		for(Account a : aList) {
			System.assertEquals(a.OwnerId, a.Usable_Owner__c);
		}		
	}

	private testMethod static void testUpdateUsableOwner(){
		List<Account> aList = new List<Account>();
		List<User> uList = [SELECT Id FROM User WHERE Name = 'Integration' AND IsActive = True LIMIT 12 ];
		
		for(Integer index = 0; index < 12; index++) {
			Account a = new Account();
			a.Name = 'TestRANDOMCHARSnhgsdg'+index;
			a.OwnerId = uList.get(Math.mod(index, uList.size())).Id;
			a.ShippingState = 'UT';
            a.ShippingCountry = 'UT';
			a.ShippingPostalCode = '84121';
            a.Account_Manager__c = '01 BRIAN THORNBURG';
			aList.add(a);
		}
		insert aList;
        
        

        
        Test.startTest();
		AccountTriggerUtil.updateUsableOwner(aList);
		
        Test.stopTest();
	}

    private testMethod static void testReassignCustomer(){
		List<Account> aList = new List<Account>();
		List<User> uList = [SELECT Id FROM User WHERE IsActive = True LIMIT 12 ];
		
		for(Integer index = 0; index < 12; index++) {
			Account a = new Account();
			a.Name = 'TestRANDOMCHARSnhgsdg'+index;
			a.OwnerId = uList.get(Math.mod(index, uList.size())).Id;
			a.ShippingState = 'UT';
            a.ShippingCountry = 'UT';
			a.ShippingPostalCode = '84121';
            a.Account_Manager__c = '01 BRIAN THORNBURG';
			aList.add(a);
		}
		insert aList;
        
        

        
        Test.startTest();
		AccountTriggerUtil.reassignCustomer(aList);
		
        Test.stopTest();
	}

    private testMethod static void testgetGenericUserForRole(){
		String a = 'Appalachia';
        String b = 'Central Canada';
        String c = 'East Canada';
        String d = 'Iron Range';
        String e = 'Southeast';
        String f = 'West N.A.';
        String g = 'Product Managers';
        
        

        
        Test.startTest();
		AccountTriggerUtil.getGenericUserForRole(a);
        AccountTriggerUtil.getGenericUserForRole(b);
        AccountTriggerUtil.getGenericUserForRole(c);
        AccountTriggerUtil.getGenericUserForRole(d);
        AccountTriggerUtil.getGenericUserForRole(e);
        AccountTriggerUtil.getGenericUserForRole(f);
        AccountTriggerUtil.getGenericUserForRole(g);
		
        Test.stopTest();
	}
}