global class UserContactSyncScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		UserContactSync us = new UserContactSync('Select Id,FirstName,LastName,Email,Title,Street,City,State,PostalCode,IsActive,Phone,Fax,MobilePhone,Employee__c From User');
		database.executeBatch(us); 
	}
}