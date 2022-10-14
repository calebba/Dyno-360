trigger CopaTrigger on Copa__c (after insert, after update) {
	
	List<Id> ids = new List<Id>();
	for (Copa__c cp : Trigger.new) {
		ids.add(cp.Id);
	}
	
	if(Trigger.isInsert) {
		if(Trigger.isAfter) {
			CopaToCDE.sumAndInsertToCDE(ids);
		}
	} else if(Trigger.isUpdate) {
		if(Trigger.isAfter) {
			CopaToCDE.sumAndInsertToCDE(ids);
		}
	}
}