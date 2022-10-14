global class QuoteToActualBatch implements Database.Batchable<sObject>, Database.Stateful {

	private Quote__c scenario;
	private Date validFrom;
	private Date validTo;
	private String curren;
	
	global QuoteToActualBatch(Quote__c scen, Date vFrom, Date vTo, String curr) {
        scenario = scen;
        validFrom = vFrom;
        validTo = vTo;
        curren = curr;
    } 
    
    global Database.Querylocator start(Database.BatchableContext bc) {
    	if (Test.isRunningTest())
    		return Database.getQueryLocator('SELECT Id FROM Account WHERE ParentId = \'' + scenario.Customer__c + '\' LIMIT 1');
    	else
    		return Database.getQueryLocator('SELECT Id FROM Account WHERE ParentId = \'' + scenario.Customer__c + '\'');
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accounts) {
    	Account account = accounts[0];
    	PandLData actualData = PandLData.createForPandLGenerator2(validFrom, validTo, 
															account.Id, false, scenario.Sales_Organization_Primary__c, 
															scenario.Sales_Organization_Primary__r.Region_Site__c,
															scenario.Sales_Organization_Primary__r.Company_Site__c,
															null, null, null, curren, null, false);
		QuoteToActualAux__c qaa = new QuoteToActualAux__c();
		qaa.BatchJob__c = BC.getJobId();
		qaa.totalst__c = actualData.totalst;
		qaa.unitsst__c = actualData.unitsst;
		insert qaa;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}