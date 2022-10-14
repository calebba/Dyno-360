public with sharing class UsefulDocumentsController {   

    public List<Document> docList {get; set;}
    public Quote__c theQuote {get; set;}
    
    public UsefulDocumentsController() {
        docList = new List<Document>();
        String quoteId = null;
        if(ApexPages.currentPage().getParameters().get('quoteID') != null) {
            quoteId = ApexPages.currentPage().getParameters().get('quoteID');
            theQuote = [SELECT Id, Name, Quote_Valid_From__c, CurrencyIsoCode, Opportunity__r.Account.Id, Opportunity__r.Account.Name, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.ParentId,
                        Opportunity__r.Account.ShippingCity, Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingPostalCode, Price_Adjustment__c, Opportunity__r.Account.Parent.Name,
                        Opportunity__r.Account.ShippingCountry, Price_Valid_From__c, Country__c, Price_Valid_To__c, Quote_Acceptance_Period__c, On__c, Opportunity__r.RecordTypeId, Opportunity__r.Account.Language__c,
                        Approval_Status__c, Sales_Organization_Primary__r.Name FROM Quote__c WHERE Id = :quoteId LIMIT 1];
                        
                //Language & Country 
                
            if(theQuote.Opportunity__r.Account.Language__c == 'FR' && theQuote.Opportunity__r.Account.ShippingCountry == 'CA') {
                docList = [SELECT Id, Name FROM Document WHERE Folder.DeveloperName = 'Quote_Documents_Canadienne'];
            } else if (theQuote.Opportunity__r.Account.Language__c == 'EN' && theQuote.Opportunity__r.Account.ShippingCountry == 'CA'){
                docList = [SELECT Id, Name FROM Document WHERE Folder.DeveloperName = 'Quote_Documents_Canada'];
            } else if(theQuote.Opportunity__r.Account.ShippingCountry == 'MX') { 
            	docList = [SELECT Id, Name FROM Document WHERE Folder.DeveloperName = 'Quote_Documents_Mexico'];
            } else {
                //USA - English
                docList = [SELECT Id, Name, DeveloperName FROM Document WHERE Folder.DeveloperName = 'Quote_Documents_US'];
            }
        }       
    } 
}