public with sharing class pm_DefectController {
	public Defect__c defect{get;set;}
	public Defect_Comment__c newComment{get;set;}
	public List<Defect_Comment__c> DefectComments{get;set;}
	public string retURL{get;set;}
	public integer CommentCount{get;set;}
	public boolean EditDescription{get;set;}
	public boolean IS_TEST{get;set;}
	
	public class pmAppException extends Exception{}
	
	public pm_DefectController(ApexPages.StandardController stdController){
		IS_TEST = false;
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		defect = (Defect__c)stdController.getRecord();
		
		if(defect.Defect_Description__c != null){
			EditDescription = false;
		}else{
			EditDescription = true;
		}
		
		if(defect.Project__c == null){
			defect.Project__c = ApexPages.currentPage().getParameters().get('project');
		}
		
		newComment = new Defect_Comment__c();
		
		if(defect.Id != null){
			DefectComments = [Select d.Defect_Comment__c, d.CreatedDate, d.CreatedById 
								From Defect_Comment__c d
								Where d.Defect__c = :defect.Id
								Order by d.CreatedDate desc];
			
			CommentCount = DefectComments.size();
		}else{
			CommentCount = 0;
		}
	}
	
	public void MakeDescriptionEditable(){
		EditDescription = true;
	}
	
	public pageReference ExtSave(){
		try{
			If(IS_TEST){
				throw new pmAppException('Test fail');
			}
			
			upsert defect;
			
			if(newComment.Defect_Comment__c != null){
				newComment.Defect__c = defect.Id;
				insert newComment;
			}
			
			pageReference pr = new pageReference('/' + defect.Id);
			pr.setRedirect(true);
			
			return pr;
		}catch(Exception e){
			return null;	
		}
	}
}