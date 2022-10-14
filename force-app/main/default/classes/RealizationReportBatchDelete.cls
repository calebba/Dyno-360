global class RealizationReportBatchDelete implements Database.Batchable<sObject> {

    private String batchId;
    
    global RealizationReportBatchDelete(String bId) {
        batchId = bId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	if (test.isRunningTest())
    		return Database.getQueryLocator('SELECT Id FROM RealizationReportAux__c LIMIT 1000');
    	else
        	return Database.getQueryLocator('SELECT Id FROM RealizationReportAux__c WHERE BatchJob__c = \'' + batchId + '\'');
    }
    
    global void execute(Database.BatchableContext BC, List<RealizationReportAux__c> records) {
    	delete records;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

}