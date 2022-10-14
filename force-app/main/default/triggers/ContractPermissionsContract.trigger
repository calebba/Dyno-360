trigger ContractPermissionsContract on Dyno_Nobel_Contract__c (after insert, after update) {

	Set<Id> accountIds = new Set<Id>();
	Set<Id> forApproval = new Set<Id>();

	if (Trigger.isUpdate) {
		for (Dyno_Nobel_Contract__c oldContract : Trigger.old) {
			Dyno_Nobel_Contract__c newContract = Trigger.newMap.get(oldContract.Id);
			//if (oldContract.Parent_Company__c != newContract.Parent_Company__c)
			//	accountIds.add(newContract.Parent_Company__c);
			if (newContract.Status__c == 'Tender Under Review' || newContract.Status__c == 'Tender Ready for Approval' || newContract.Status__c == 'Contract Ready for Approval')
				forApproval.add(newContract.Id);
		}
	} else {
		for (Dyno_Nobel_Contract__c newContract : Trigger.new) {
			//accountIds.add(newContract.Parent_Company__c);
			//if (newContract.Status__c == 'Tender Under Review' || newContract.Status__c == 'Tender Ready for Approval' || newContract.Status__c == 'Contract Ready for Approval')
			//	forApproval.add(newContract.Id);
		}
	}
	
	ContractPermissionsClass.CreatePermissions(accountIds);

	ContractPermissionsClass.CreateContractPermissions(Trigger.newMap.keyset());
	
	// Submit for approval
	if (forApproval.size() > 0) {
		for (Id contractId : forApproval) {
			try {
				Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
		        appReq.setComments('Automatically submitting request for approval.');
		        appReq.setObjectId(contractId);
		        Approval.ProcessResult result = Approval.process(appReq);
	        } catch (Exception ex) {}
		}
	}
}