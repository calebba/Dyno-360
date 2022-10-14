trigger UserTrigger on User (after insert) {
	List<Id> UserIds = new List<Id>();
		
	for(User u : Trigger.new){
		UserIds.add(u.Id);
	}
	
	//if(trigger.isInsert){
		UserTriggerUtil.CreateUserContactRecord(UserIds);
	//}else{
	//	UserTriggerUtil.UpdateUserContactRecord(UserIds);
	//}
	//UserContactSync.cls makes the after update version of this trigger unnecessary
}