public with sharing class hd_FORCEHelpdeskExtension {
	public Case newCase{get;set;}
	public Contact userContact{get;set;}
	public Blob newAttachment{get;set;}
	public String contentType{get;set;}
	public String fileName{get;set;}
	public boolean IS_TEST{get;set;}
	
	public class hdAppException extends Exception{}
	
//initializer	
	public hd_FORCEHelpdeskExtension(ApexPages.StandardController con){
		IS_TEST = false;
		newCase = (Case)con.getRecord();
		
		//set defaults
		newCase.OwnerId = Userinfo.getUserId();
		newCase.Status = 'New';
		newCase.Priority = 'Medium';
		newCase.Origin = 'Web';
		
		//see if user has a contact record
		try{
			userContact = [Select Id From Contact Where User__c = :Userinfo.getUserId()];
			newCase.ContactId = userContact.Id;
		}catch(Exception e){/*future dev: create the missing contact record here*/}
	}
	
//button actions
	public PageReference Save() {
		pageReference pr;
		
		try{
			if(IS_TEST){
				throw new hdAppException('Fail Test');
			}
			
			Database.DMLOptions dmlOptn = new Database.DMLOptions();
			dmlOptn.assignmentRuleHeader.useDefaultRule = true;
			dmlOptn.EmailHeader.triggerAutoResponseEmail = true;
			dmlOptn.EmailHeader.triggerUserEmail = true;
			
			newCase.setOptions(dmlOptn);
			insert newCase;
			
			if (newAttachment != null) {
				Attachment doc = new Attachment();
				doc.Body = newAttachment;
				doc.Name = fileName;
				doc.ContentType = contentType;
				doc.ParentId = newCase.Id;
				
				insert(doc);
			}			
			
			pr = new pageReference('/' + newCase.Id);
			pr.setRedirect(true);
			
			return pr;
		}catch(Exception e){
			ApexPages.addMessages(e);
			return null;
		}
	}
	
	public PageReference Cancel(){
		PageReference pageRef = new PageReference('/home/home.jsp');
		pageRef.setRedirect(true);
		
		return pageRef;
	}
}