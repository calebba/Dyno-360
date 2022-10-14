@isTest

public with sharing class Test_TaskEmailNotificationBatch {

    static testmethod void test() {
        // The query used by the batch job.
        String query = 'SELECT Id,CreatedDate FROM Merchandise__c ' + 
                   'WHERE Id NOT IN (SELECT Merchandise__c FROM Line_Item__c)';

       // Create some action items that the test will pick up
       //   by the batch job.
       
       //query = 'SELECT Id, What.Name, OwnerId, Owner.FirstName, Owner.Email, Owner.IsActive, Record_Type_Name__c, Subject, 
       //ActivityDate, ReminderDateTime, IsReminderSet, Status, Description from Task Where ActivityDate = :currdt AND Status <> :thestatus';
       
       
       //create the user global properties with user to send dev email to 
       
       Task[] tasks = new List<Task>();
              
      User testUser = createUser(1);
      
      Insert testUser;
      
      globalProperties__c gp = new globalProperties__c(
      	Description__c = 'DeveloperToSendEmail',
      	Value__c = 'Test1 User',
      	Name = 'DeveloperToSendEmail'
      );
        
        Insert gp;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Task' and Name='Contract' Limit 1];
                  
       for (Integer i=0;i<10;i++) {

           Task singleTask = new Task(
               //Name = 'Task ' + i,
               OwnerId = testUser.Id,
               Subject = 'Test ' + i,
               ActivityDate = System.today(),
               ReminderDateTime = System.today(),
               IsReminderSet = True,
               Status = 'Not Started',
               recordTypeId=rt.id,
               Description = 'Test ' + i);
           tasks.add(singleTask);
       }
       
       for (Integer i=0;i<2;i++) {

           Task singleTask = new Task(
               //Name = 'Task ' + i,
               OwnerId = testUser.Id,
               Subject = 'Reminder: ' + i,
               ActivityDate = System.today(),
               ReminderDateTime = System.today(),
               IsReminderSet = True,
               Status = 'Not Started',
               recordTypeId=rt.id,
               Description = 'Test ' + i);
           tasks.add(singleTask);
       }
             
       insert tasks;

       Test.startTest();
       TaskEmailNotificationBatch M = new TaskEmailNotificationBatch();
       Database.executeBatch(M); 
       Test.stopTest();

       // Verify merchandise items got deleted 
       //Integer i = [SELECT COUNT() FROM Merchandise__c];
       //System.assertEquals(i, 0);
    }


	public static User createUser(Integer i) {
				
		User u = new User();
		u.FirstName = 'Test' + i;
		u.LastName = 'User';
		u.Alias = 'tuser' + i;
		u.Email = 'tu' + i + '@tus.com';
		u.Username = 'tu' + i + '@tus.com';
		u.CommunityNickname = 'tuser' + i;
		u.TimeZoneSidKey = 'America/Chicago';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		u.LanguageLocaleKey = 'en_US';
		u.State = 'UT';
		u.PostalCode = '84121';
		return u;		
	}

}