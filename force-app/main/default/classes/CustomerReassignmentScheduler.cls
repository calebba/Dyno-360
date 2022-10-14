global with sharing class CustomerReassignmentScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Id ownerId = [SELECT Id FROM User WHERE Name = 'Integration'].Id;
		CustomerReassignment cr = new CustomerReassignment('Select Sales_Manager__c, OwnerId, Name, Id, Account_Manager__c From Account Where OwnerId = \'' + ownerId + '\'');
		database.executeBatch(cr); 
	}
	
	static testMethod void Test_CustomerReassignmentScheduler() {
        Test.startTest();
        
        String jobId = System.schedule('testScheduledApex', '0 0 0 3 9 ? 2022', new CustomerReassignmentScheduler());
        
        CronTrigger ct = [Select Id, CronExpression, TimesTriggered, NextFireTime
        					From CronTrigger WHERE id = :jobId];
        
        //verify expressions
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        
        // Verify the job has not run  
      	System.assertEquals(0, ct.TimesTriggered);

   		// Verify the next time the job will run  
      	System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

   		Test.stopTest();
    }
}