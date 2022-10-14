global class RealizationReportBatchStep1 implements Database.Batchable<sObject>, Database.Stateful {

    private String qQuery;
    private String lQuery;
    
    global RealizationReportBatchStep1(String quoteQuery, String linesQuery) {
        qQuery = quoteQuery;
        lQuery = linesQuery;
    }
    
    global List<Quote__c> start(Database.BatchableContext bc) {
        List<Quote__c> fromQuotes = database.query(qQuery);
        Map<Id, Quote__c> fromQuotesMap = new Map<Id, Quote__c>();
			for (Quote__c q : fromQuotes)
				if (fromQuotesMap.containsKey(q.Customer__c)) {
					if (fromQuotesMap.get(q.Customer__c).Date_Published_to_SAP__c < q.Date_Published_to_SAP__c)
						fromQuotesMap.put(q.Customer__c, q);
				} else
					fromQuotesMap.put(q.Customer__c, q);
		if (Test.isRunningTest()) {
			List<Quote__c> toRet = new List<Quote__c>();
			if (fromQuotesMap.values().size() > 0)
				toRet.add(fromQuotesMap.values().get(0));
			return toRet;
		} else
        	return fromQuotesMap.values();
    }
    
    global void execute(Database.BatchableContext BC, list<Quote__c> quotes) {
    	Id batchId = BC.getJobId();
    	List<Quote_Line_Item__c> qlis = database.query(lQuery);
    	List<String> keys = new List<String>();
    	for (Quote_Line_Item__c qli : qlis)
    		keys.add(qli.Material_Item__c + '-' + qli.Quote__r.Sales_Organization_Primary__c + '-' + qli.Quote__r.Customer__c);
        List<RealizationReportAux__c> rras = [SELECT Id, BatchJob__c, Key__c, Quote_SLI__c, Actual_SLI__c FROM RealizationReportAux__c WHERE Key__c in :keys AND BatchJob__c = :batchId];
        Map<String, RealizationReportAux__c> rraMap = new Map<String, RealizationReportAux__c>();
        for (RealizationReportAux__c rra : rras)
        	rraMap.put(rra.Key__c, rra);
        for (Quote_Line_Item__c qli : qlis) {
        	string key = qli.Material_Item__c + '-' + qli.Quote__r.Sales_Organization_Primary__c + '-' + qli.Quote__r.Customer__c; 
        	if (rraMap.containskey(key)) 
            	rraMap.get(key).Actual_SLI__c = qli.Id;
        	else
            	rraMap.put(key, new RealizationReportAux__c(BatchJob__c = batchId, Key__c = key, Actual_SLI__c = qli.Id));
        }
        upsert rraMap.values();
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

}