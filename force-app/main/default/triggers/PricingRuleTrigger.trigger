trigger PricingRuleTrigger on Pricing_Rule__c (before insert, before update) {
	if(Trigger.isInsert) {
		PricingRuleUtil.updateDataHoles(Trigger.new);
		PricingRuleUtil.checkForDuplicatePricingRules(Trigger.new);
	} else if(Trigger.isUpdate) {
		PricingRuleUtil.updateDataHoles(Trigger.new);
	}
}