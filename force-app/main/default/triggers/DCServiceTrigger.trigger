trigger DCServiceTrigger on DynoConsult_Service__c (
before insert, after insert, 
  before update, after update, 
  before delete, after delete,
  after undelete
) {


    if (Trigger.isBefore) {
        if (Trigger.isInsert) {      

            Set<String> dcsKeys = new Set<String>();
               
            for (DynoConsult_Service__c dcs: Trigger.new) {
              dcsKeys.add(dcs.Key_Prefix__c);
            }
               
            List<AggregateResult> dcsAll = [SELECT Key_Prefix__c theKey, MAX(Count__c) theCount FROM DynoConsult_Service__c WHERE Key_Prefix__c in: dcsKeys Group BY Key_Prefix__c];
           
            Map<String, Decimal> m1 = new Map<String, Decimal>();
          
            for(AggregateResult ag: dcsAll){
                m1.put((String)ag.Get('theKey'), (Decimal)ag.Get('theCount'));
            }
        
            for (DynoConsult_Service__c dcs: Trigger.new) {
                if (m1.containsKey(dcs.Key_Prefix__c)){
                    dcs.Count__c = m1.Get(dcs.Key_Prefix__c) + 1;
                }else{
                    dcs.Count__c = 1;
                }
                dcs.Key__c = dcs.Key_Prefix__c + '-' + string.valueof(dcs.Count__c);
            }
          }    
        }

    if (Trigger.isAfter) {
        //Purpose of this code is to do a Rollup Formula on 2 fields to the related Account as it is not a Master Detail relationship.
        //We are getting a list of accounts we need to recalculate the 2 rollup fields
        Set<String> accountKeys = new Set<String>();
        
        if (Trigger.isDelete ) {
                
           for (DynoConsult_Service__c dcs: Trigger.old) {
               accountKeys.add(dcs.Account__c);
           }
        }
        
        if (Trigger.isUndelete ){
            for (DynoConsult_Service__c dcs: Trigger.new) {
               accountKeys.add(dcs.Account__c);
           }
        }

        if (Trigger.isUpdate  ) {
    
           for (DynoConsult_Service__c dcs: Trigger.new) {
               //is old account different than new account (account was changed on Service) -- if so add both Account numbers
               DynoConsult_Service__c oldDcs = Trigger.oldMap.get(dcs.Id);
               if( dcs.account__c <> oldDcs.account__c){
                   accountKeys.add(dcs.Account__c);
                   accountKeys.add(OldDcs.Account__c);
               }else{
                 
                    //have the numbers changed at all - if so, add the account number to list to update.
                    if( (dcs.Total_Customer_Value__c <> oldDcs.Total_Customer_Value__c) || (dcs.Total_Dyno_Value__c <> oldDcs.Total_Dyno_Value__c) ||(dcs.Total_Value__c <> oldDcs.Total_Value__c) ){
                        accountKeys.add(dcs.Account__c);
                    }
               }
           }
                      
        }
        
        if( accountKeys.IsEmpty()){
            return;
        }
        
        
        // get a map of the Accounts that need to update
        List<Account> accountList = new List<Account>([select id, DynoConsult_Dyno_Value__c, DynoConsult_Customer_Value__c from Account where id IN :accountKeys]);
        List<Account> accountsToUpdate = new List<Account>();
        
        // The calucations of the rollups on the Dyno Consult Service
       Map<Id,AggregateResult> results = new Map<id,AggregateResult>([SELECT Account__c Id, SUM(Total_Dyno_Value__c)TotDynoVal, SUM(Total_Customer_Value__c)TotCustVal FROM DynoConsult_Service__c WHERE account__c IN :accountKeys GROUP BY account__c]);

        for( Account acc: accountList){
            if(results.containsKey(acc.id)){

                 if( (acc.DynoConsult_Dyno_Value__c != results.get(acc.id).get('TotDynoVal')) || (acc.DynoConsult_Dyno_Value__c != results.get(acc.id).get('TotCustVal'))){
                     //Apply rollup fields to the account and add it to the collection to update
                     acc.DynoConsult_Dyno_Value__c = (Decimal)results.get(acc.id).get('TotDynoVal');
                     acc.DynoConsult_Customer_Value__c = (Decimal)results.get(acc.id).get('TotCustVal');
                     accountsToUpdate.add(acc);

                 }
             } 
        }
        
        if( ! accountsToUpdate.IsEmpty()){
            update accountsToUpdate;
        }
        
   }

}