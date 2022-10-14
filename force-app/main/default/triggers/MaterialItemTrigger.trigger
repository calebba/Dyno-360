trigger MaterialItemTrigger on Material_Item__c (before insert, after insert, before update) {
	
	if(Trigger.isInsert) {
		
		if(Trigger.isBefore) {
			MaterialItemTriggerUtils.setDefaultRecordType(Trigger.new);
		} else if(Trigger.isAfter) {
			MaterialItemTriggerUtils.CreateProductInfo(Trigger.new);
		}
		
	} else if(Trigger.isUpdate) {
		
		if(Trigger.isBefore) {
			MaterialItemTriggerUtils.setIfFormulaExists(Trigger.new);
		} else if(Trigger.isAfter) {
			
		}
	}
}