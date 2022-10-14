trigger CustomerSalesSiteTrigger on Customer_Sales_Site__c (before insert, before update) {

	if(Trigger.isInsert) {
		
		if(Trigger.isBefore) {
			//CustomerSalesSiteTriggerUtil.CheckUniqueRequest(Trigger.new);
			CustomerSalesSiteTriggerUtil.setUniqueConstraintKey(Trigger.new);
			CustomerSalesSiteTriggerUtil.CheckRecordTypeChange(Trigger.new);
			CustomerSalesSiteTriggerUtil.updateCSSListOnAccount(Trigger.new);
		}
		
	}
	
	if(Trigger.isUpdate){
		if(Trigger.isBefore){
			CustomerSalesSiteTriggerUtil.CheckRecordTypeChange(Trigger.new);
		}
	}
}