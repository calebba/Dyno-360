trigger PVALineItemTrigger on PVA_Line_Item__c (before insert) {
	
	if(Trigger.isInsert) {
		if(Trigger.isBefore) {
			PVALineItemTriggerUtil.generateNames(Trigger.new);
		}
	}
	
}