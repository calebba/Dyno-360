public without sharing class BatchPDFGenerator {
    
    public static void sendPDFBatch(List<Quote__c> quotes, String toEmail, String ccEmail, Integer part, Integer max) {
        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{toEmail});
        if(ccEmail != null && ccEmail.trim() != '') {
            List<String> tempSplit = ccEmail.split(',');
            List<String> ccSplit = new List<String>();
            for(String s : tempSplit) {
                ccSplit.add(s.trim());
            }
            mail.setCcAddresses(ccSplit);
        }

        mail.setSenderDisplayName('Salesforce (No Reply)');
        // mail.setSubject('Your 2012 DRAFT Scenarios PDFs are Ready for Review');
        mail.setSubject('Your requested Scenarios PDF(s)');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        // mail.setHtmlBody('Your 2012 DRAFT Quotes are attached and ready for your review.<br /><br />Once ALL your 2011 Quotes are ready to be submitted for approval, please email your Pricing Team Contact to start the approval process.<br /><br />US Retail--Angie Walpole<br />CA Retail--Karen Dion<br />Wholesale--Heather Carothers<br />');
        mail.setHtmlBody('Your Quote(s) you requested is/are attached below.<br /> <br />Please review for accuracy. <br /><br />');
       
        for(Quote__c currQuote : quotes) {
        	PageReference pdf = Page.QuoteOutputPDFDraft;
        	if (currQuote.Approval_Status__c == 'Approved' || currQuote.Approval_Status__c == 'None Needed'){
        	pdf = Page.QuoteOutputPDF;	
        	}
            pdf = Page.QuoteOutputPDF;    // rpn 11/12/2013 put in place so that all pdfs from pdf generator are 'approved' (no draft) type  	
        	
             //PageReference pdf = Page.QuoteOutputPDFDraft;
            pdf.getParameters().put('quoteID', (String) currQuote.Id);
            pdf.setRedirect(true);
            //Blob b = pdf.getContent(); //original code changed because this now cuases failure when promoting code
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            
            Blob b; 
            if(!test.isRunningTest()){
            	b = pdf.getContent();
            	efa.setFileName(currQuote.Customer__r.Name.replace('.','') + '_' + currQuote.Approval_Status__c + '_' + currQuote.Name + '.pdf');
            }else{
            	String pdfContent = 'This is a test string';
            	b = blob.toPDF(pdfContent);
            	efa.setFileName('test.pdf');
            }
              
            efa.setBody(b);
            efaList.add(efa);           
        }
        
        mail.setFileAttachments(efaList);
        Messaging.sendEmail(new List<Messaging.Singleemailmessage> {mail}); 
    }
    
    private static testMethod void testSendPDFBatch() {
        Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
        Account testAcct = TestUtils.createAccount('TA930', null);
        List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
        Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
        Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
        
        List<Quote__c> qList = new List<Quote__c>{testScenario};
                
        BatchPDFGenerator.sendPDFBatch(qList, 'prymek12344321@afakedomain.com', 'prymek12344321@afakedomain.com', 1, 1);
        //Nothing for me to assert...
    }
    
}