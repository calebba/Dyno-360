trigger QuoteTrigger on Quote__c (before insert, before update, after update) {
    
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            QuoteTriggerUtil.generateQuoteName(Trigger.new);
            QuoteTriggerUtil.setCostDriverRates(Trigger.new);
        }
    }else if (Trigger.isUpdate) {
        
         if(Trigger.isBefore){
            for(Quote__c q : Trigger.new) {
                q.Opportunity_Owner_User_Email__c = q.Opportunity_Owner_User_Email_Lookup__c;
            }
         }else if(Trigger.isAfter) {
            if (!OpportunityTriggerUtils.isRunning){
                QuoteTriggerUtil.updateQuotePrice(Trigger.new);
            }
         }
    }
    
}