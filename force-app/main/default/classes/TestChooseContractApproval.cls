@isTest(SeeAllData=true)
public class TestChooseContractApproval {
	
	public static testmethod void test1() {
		Id userLicenseId = [select id, name from userlicense where name = 'Salesforce'].Id;
		List<Profile> profileIdList = [select userLicenseId from Profile where userlicenseId = :userLicenseId];
		List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true AND profileId IN :profileIdList limit 10];
		
		Account acc = TestUtils.createAccount('TestAccount', null);
		Dyno_Nobel_Contract__c c = new Dyno_Nobel_Contract__c();
		c.Status__c = 'Tender Under Review';
		insert c;
		
		ApexPages.currentPage().getParameters().put('contractId',c.Id);
		
		ChooseContractApprovals cca = new ChooseContractApprovals();
		initTest(cca);
		
		c.Tender_Approval_Ids__c = users[0].Id + ',' + users[1].Id;
		c.Tender_Review_Ids__c = users[2].Id + ',' + users[3].Id;
		c.Contract_Approval_Ids__c = users[4].Id + ',' + users[5].Id;
		update c;
		
		ChooseContractApprovals cca2 = new ChooseContractApprovals();
		initTest(cca2);
	}
	
	public static void initTest(ChooseContractApprovals cca) {
		cca.addContractApp();
		cca.addTenderApp();
		cca.addTenderRev();
		cca.removeContractApp();
		cca.removeTenderApp();
		cca.removeTenderRev();
		cca.Save();
		cca.Cancel();
	}
}