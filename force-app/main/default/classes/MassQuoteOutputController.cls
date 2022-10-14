public without sharing class MassQuoteOutputController {
	
	public Account dummyField {get; set;}
	public Boolean selectAll {get; set;}
	public String ccString {get; set;}
    Public List<PDFLineItem> toDownload {get; set;}
	public Integer currentIndex {get; set;}
	public Integer part {get; set;}
	public Integer max {get; set;}
	public Integer batchSize {get; set;}
	public Boolean batchStarted {get; set;}
	public Boolean includeQ {get; set;}
	public Boolean includeB {get; set;}
	public Boolean includeV {get; set;}
	public Boolean isSysAdmin {get; set;}
	
	public MassQuoteOutputController() {
		dummyField = new Account();
		dummyField.Contract_Expiration__c = null; //Start Date
		dummyField.License_Expiration__c = null; // End Date
		dummyField.OwnerId = UserInfo.getUserId();
		dummyField.Usable_Owner__c = UserInfo.getUserId();
		string contactID = [Select id FROM Contact WHERE User__c = :dummyField.Usable_Owner__c].id;
		dummyField.Account_Owner_Contact__c = contactID;
		toDownload = new List<PDFLineItem>();
		selectAll = false;
		ccString = null;
		currentIndex = 0;
		max = 0;
		part = 1;
		batchSize = 5;
		batchStarted = false;
		includeQ = true;
		includeB = true;
		includeV = true;
		String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
		isSysAdmin = profileName == 'System Administrator' || profileName == '# Custom DNA - Pricing Power User';
	}
	
	private Boolean validateSelection() {
		return (dummyField.OwnerId != null && dummyField.Usable_Owner__c != null && dummyField.Contract_Expiration__c != null && dummyField.License_Expiration__c != null 
		                                   && dummyField.Contract_Expiration__c <= dummyField.License_Expiration__c);
	}
	
	public PageReference generateAllQuotes() {
		if(validateSelection()) {
			Date ymd1 = dummyField.Contract_Expiration__c;
			Date ymd2 = dummyField.License_Expiration__c;
			String idUser = dummyField.Account_Owner_Contact__c;
			String query = 'SELECT Name, Id, Approval_Status__c, Opportunity__r.Opportunity_Owner_Contact__r.Name, Customer__r.Owner.Name, Customer__r.Name FROM Quote__c WHERE Opportunity__r.Opportunity_Owner_Contact__c = \'' + idUser  + '\' AND ' +
			               'Price_Valid_From__c >= :ymd1 AND Price_Valid_To__c <= :ymd2';
			//String query = 'SELECT Name, Id, Approval_Status__c, Opportunity__r.Owner.Name, Customer__r.Owner.Name, Customer__r.Name FROM Quote__c WHERE Opportunity__r.OwnerId = \'' + dummyField.Usable_Owner__c  + '\' AND ' +
			//               'Price_Valid_From__c >= :ymd1 AND Price_Valid_To__c <= :ymd2';
			if(includeQ || includeB || includeV) {
				query += ' AND ( ';
				Integer count = 0;
				if(includeQ) {
					query += 'Quote_Type__c = \'Quoted\'';
					count++;
				}
				if(includeB) {
					if(count > 0) {
				 		query += ' OR ';
				 	}
				 	query += 'Quote_Type__c = \'Bundled\'';
					count++;				 
				}
				if(includeV) {
					if(count > 0) {
				 		query += ' OR ';
				 	}
				 	query += 'Quote_Type__c = \'Volumetric\'';					
				}
				query += ' )';
			}
			
			//System.assertEquals('q', query);
			List<Quote__c> toDownloadTemp = Database.query(query);
			toDownload.clear();
			selectAll = false;
			for(Quote__c currentEntry : toDownloadTemp) {
				PDFLineItem temp = new PDFLineItem();
				temp.theQuote = currentEntry;
				toDownload.add(temp);
			}
			calculateMax();              
		}
		
		return null;
	}
	
    @testVisible
	private void calculateMax() {
		max = toDownload.size()/batchSize;
		if(Math.mod(toDownload.size(), batchSize) != 0) {
			max += 1;
		}
	}
	
	public Integer getUpdatedMax() {
		calculateMax();
		return max;		
	}
	
	public PageReference emailIndividualSelected() {
		//calculateMax();
		//if(validateSelection() && part <= max) {
		
		
		
		if(validateSelection()) {
			
			String toEmail = [SELECT Id, Email FROM User WHERE Id = :dummyField.OwnerId LIMIT 1].Email;
			List<Quote__c> batchPDFs = new List<Quote__c>();
			for(Integer index = 0; index < toDownload.size(); index++) {
				if(toDownload[index].toPrint == true){
					batchPDFs.add(toDownload[index].theQuote);
					//toDownload[index].selected = true;
					toDownload[index].toPrint = false;
				}
			}
			
			if( batchPDFs.size() == 0){
				ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one Scenario to email. Select one or more, and try again.'));
				return null;
			}
			
			BatchPDFGenerator.sendPDFBatch(batchPDFs, toEmail, ccString, part, max);
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'All selected Scenarios have been sent.'));
		}
			
		return null;
	}
	
	public PageReference emailSelected() {
		calculateMax();
		if(validateSelection() && part <= max) {
			batchStarted = true;
			String toEmail = [SELECT Id, Email FROM User WHERE Id = :dummyField.OwnerId LIMIT 1].Email;
			List<Quote__c> batchPDFs = new List<Quote__c>();
			for(Integer index = currentIndex; index < (currentIndex+batchSize) && index < toDownload.size(); index++) {
				batchPDFs.add(toDownload[index].theQuote);
				toDownload[index].selected = true;
			}
			currentIndex += batchSize;
			BatchPDFGenerator.sendPDFBatch(batchPDFs, toEmail, ccString, part, max);
			part++;
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Part ' + (part-1) + ' has completed processing and the email has been sent.  You may proceed.'));
		}
		
		if(part > max) {
			batchStarted = false;
			currentIndex = 0;
			part = 1;
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'All emails have been processed for the selected user.'));
		}
			
		return null;
	}
	
	public class PDFLineItem {
		public Boolean selected {get; set;}
		public Boolean toPrint {get; set;}
		public Quote__c theQuote {get; set;}
		
		public PDFLineItem() {
			selected = false;
		}
	}
	
}