global class BatchCopa implements Database.Batchable<sObject>{
    
    global BatchCopa() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Copa__c');
    } 
    
    global void execute(Database.BatchableContext BC, list<Copa__c> copas) {
                
        update copas;
              
    }
       
    global void finish(Database.BatchableContext BC){
    }
}