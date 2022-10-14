global class TaskEmailNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {

	String query;
  	Date currdt = date.today();
  	string thestatus = 'Completed';
    global user devuser;
    global Integer emailListSize = 0;
    
  	global TaskEmailNotificationBatch(){
    	query = 'SELECT Id, What.Name, OwnerId, Owner.FirstName, Owner.Email, Owner.IsActive, Record_Type_Name__c, Subject, ActivityDate, ReminderDateTime, IsReminderSet, Status, Description from Task Where ActivityDate = :currdt AND Status <> :thestatus';
    	// Get the dev user here - execute may not run to get the user
  		globalProperties__c gpDeveloperUser = globalProperties__c.getInstance('DeveloperToSendEmail');
        system.debug('Developer to send email ' + gpDeveloperUser.Value__c);
        devuser = [SELECT Id, Email from User Where Name = :gpDeveloperUser.Value__c limit 1];
  	}
  	
  	global Database.Querylocator start(Database.BatchableContext BC){
  		return Database.getQueryLocator(query);
  	}
  	
  	global void execute(Database.BatchableContext BC, List<Task> tasks){

    	List<Id> taskids = New List<Id>();
    	       	
       	system.debug( 'size of task list is: ' + tasks.size());
       	if (tasks.size() > 0){
       		List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
       		
        	String reviewTemplateID;
        	String reviewTemplateBody;
        	String reviewTemplateSubject;
        	
        	String reminderTemplateID;
        	String reminderTemplateBody;
        	String reminderTemplateSubject;
        	        	
        	//Get this so we can set the From address in the emails that get sent out
        	List<OrgWideEmailAddress> lstOrgWideEmailId = [Select id from OrgWideEmailAddress];
        	
        	List<EmailTemplate> emailtmps = [SELECT Id, BODY, SUBJECT, DeveloperName from EmailTemplate];
        	
        	for (EmailTemplate et : emailtmps){
           		if (et.DeveloperName == 'TaskDueDateNotification'){
                	reviewTemplateID = et.id;
                	reviewTemplateBody = et.BODY;
                	reviewTemplateSubject = et.SUBJECT;
           		}else if (et.DeveloperName == 'TaskDueDateReminder' ){
           			reminderTemplateID = et.id;
           			reminderTemplateBody = et.BODY;
           			reminderTemplateSubject = et.SUBJECT;
           		}	
        	}
   			User tskowner;
        	List<User> allusers = new List<User>();
        	Map<Id, User> allusermap = new Map<Id,User>();
        	allusers = [SELECT id, Name, IsActive, Email, FirstName from User];
        	for (User usr1 : allusers){
          		allusermap.put(usr1.Id, usr1);
        	}
        	system.debug('devtest: 1');
        	List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        	system.debug('number of tasks:' + tasks.size());
       	 	for (Task tk : tasks){
       	 		system.debug('2: ' + tk.OwnerID);
        		if (tk.OwnerId <> Null && tk.Record_Type_Name__c == 'Contract'){
        			tskowner = allusermap.get(tk.OwnerId);
        			system.debug('22a:' + tskowner.Name);
        			if (tskowner.IsActive == True){
        				if (tk.Subject <> Null && tk.Subject.Left(9) == 'Reminder:'){
        					Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
              				system.debug('2aReminder: ' + tskowner.Email);
              				msg.setPlainTextBody(tskowner.FirstName + ',\n\nContract: ' + tk.What.Name + '\n\n' + reminderTemplateBody + '\n\n' + 'Link to task -> ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + tk.id  + '\n\nTask Subject-  ' + tk.Subject + '\nTask Details-\n' + tk.Description + '\n\n');
              				msg.setSubject(reminderTemplateSubject + ' (' + tk.What.Name + ')');
              				msg.setToAddresses(new List<String>{tskowner.Email});
              				msg.setBccAddresses(new List<String>{devuser.Email});
              				if(lstOrgWideEmailId.size() > 0){
              					msg.setOrgWideEmailAddressId(lstOrgWideEmailId[0].id);	
              				}             				
              				lstMsgs.add(msg);
        				
        				}else if (tk.Subject <> Null){
        					Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
              				system.debug('2aReview: ' + tskowner.Email);
              				msg.setPlainTextBody(tskowner.FirstName + ',\n\nContract: ' + tk.What.Name + '\n\n' + reviewTemplateBody + '\n\n' + 'Link to task -> ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + tk.id + '\n\nTask Subject-  ' + tk.Subject + '\nTask Details-\n' + tk.Description + '\n\n');
              				msg.setSubject(reviewTemplateSubject + ' (' + tk.What.Name + ')');
              				msg.setToAddresses(new List<String>{tskowner.Email});
              				msg.setBccAddresses(new List<String>{devuser.Email});
              				if(lstOrgWideEmailId.size() > 0){
              					msg.setOrgWideEmailAddressId(lstOrgWideEmailId[0].id);	
              				}     
              				lstMsgs.add(msg);

        				}
        			}  //end of if tskowner.isactive
        		}  //end of if tk.assignedto is null
        	}   //end of for task tk loop
        	system.debug('lstmsgs size: ' + lstMsgs.size());
        	if (lstMsgs.size() > 0){
        		emailListSize = lstMsgs.size();
           		Messaging.sendEmail(lstMsgs);

       		}  //end of if lstmsgs.size
       	} //end of if tasks.size > 0
      
  	}  //end of global void execute
  
  global void finish(Database.BatchableContext BC){
    // Send an email to Developer notifying of job completion.
    // Get the ID of the AsyncApexJob representing this batch job
    // from Database.BatchableContext.
    // Query the AsyncApexJob object to retrieve the current job's information.
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id =:BC.getJobId()];
    
    system.debug('Single email');
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {devuser.Email};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Task Due Date notification emails sent:' + a.Status);
    mail.setPlainTextBody
    ('The TaskEmailNotificationBatch job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\nEmails sent: ' + emailListSize);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
  	
}