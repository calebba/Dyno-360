@isTest(SeeAllData=true)
public with sharing class Test_DynoNobelContractAll {
	public static testmethod void test1() {
		Id userLicenseId = [select id, name from userlicense where name = 'Salesforce'].Id;
		List<Profile> profileIdList = [select userLicenseId from Profile where userlicenseId = :userLicenseId];
		List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true AND profileId IN :profileIdList limit 10];
		
		Account acc = TestUtils.createAccount('TestAccount', null);
		Dyno_Nobel_Contract__c c = new Dyno_Nobel_Contract__c();
		insert c;
		c = [SELECT Id, Status__c, Tender_Approval_Ids__c, Tender_Review_Ids__c, Contract_Approval_Ids__c FROM Dyno_Nobel_Contract__c WHERE Id = :c.Id];
		c.Tender_Approval_Ids__c = users[0].Id + ',' + users[1].Id;
		c.Tender_Review_Ids__c = users[2].Id + ',' + users[3].Id;
		c.Contract_Approval_Ids__c = users[4].Id + ',' + users[5].Id;
		update c;
		
		c = [SELECT Id, Status__c, Tender_Approval_Ids__c, Tender_Review_Ids__c, Contract_Approval_Ids__c FROM Dyno_Nobel_Contract__c WHERE Id = :c.Id];
		c.Status__c = 'Tender Approval';
		update c;
		
		c = [SELECT Id, Status__c, Tender_Approval_Ids__c, Tender_Review_Ids__c, Contract_Approval_Ids__c FROM Dyno_Nobel_Contract__c WHERE Id = :c.Id];
		c.Status__c = 'Tender Notification';
		update c;
		
		c = [SELECT Id, Status__c, Tender_Approval_Ids__c, Tender_Review_Ids__c, Contract_Approval_Ids__c FROM Dyno_Nobel_Contract__c WHERE Id = :c.Id];
		c.Status__c = 'Contract Approval';
		update c;
	}
}