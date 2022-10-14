trigger ContractActionLastUpdate on Contract_Action__c (before update) {

	for (Contract_Action__c ca2 : Trigger.new) {
		Contract_Action__c ca1 = Trigger.oldMap.get(ca2.Id);
		if (ca1.Status__c != 'Complete' && ca2.Status__c == 'Complete')
			ca2.Last_Update_Date__c = DateTime.now();
	}

}