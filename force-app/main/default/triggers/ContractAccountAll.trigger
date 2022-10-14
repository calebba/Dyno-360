trigger ContractAccountAll on Contract_Account__c (after insert) {
	if (trigger.isInsert && trigger.isAfter) {
		createUserPermissionsOnContract();
	}
	
	private void createUserPermissionsOnContract() {
		Set<Id> accountIds = new Set<Id>();
		for (Contract_Account__c ca : trigger.new) {
			accountIds.add(ca.Account__c);
		}
		
		List<User> usersList = [SELECT Id FROM User WHERE AccountId IN :accountIds];
		List<AccountShare> accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE AccountId in :accountIds];
	}
}