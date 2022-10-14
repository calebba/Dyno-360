trigger PVATrigger on PVA__c (before insert) {
	if(Trigger.isInsert) {
		if(Trigger.isBefore) {
				PVATriggerUtil.InsertManagerReferences(Trigger.new);
		}
	}

}