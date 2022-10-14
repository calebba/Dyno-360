public with sharing class OpportunityClosedDeal {
	
	/*
	THIS CLASS NEEDS TO BE REMOVED ENTIRELY
	IT IS NOT USED ANYWHERE
	*/
	
	
	/*
    private List<Quote__c> closedQuotes;
    private Map<Id, Opportunity> opportunityRecords;
    private List<Product2> allProducts;
    private Pricebook2 standardPriceBook;
    private List<PricebookEntry> newPriceBookRecords;
        
    public OpportunityClosedDeal(List<Id> opportunityIds) {
        closedQuotes = QuoteUtil.queryForQuoteAndChildRecordsByOppyAndActive(opportunityIds);
        opportunityRecords = new Map<Id, Opportunity>([select Id, AccountId, Account.SAP_Account_Number__c from Opportunity where Id in: opportunityIds]);
        List<Quote_Line_Item__c> qlis = [Select Material_Item__c from Quote_Line_Item__c where Quote__r.Opportunity__c in :opportunityIds];
        List<Id> materialIds = new List<Id>();
        for (Quote_Line_Item__c qli : qlis) {
            materialIds.add(qli.Material_Item__c);
        }
        allProducts = [select Id, Material_Item__c, Material_Item__r.Material_Code__c, ProductCode from Product2 where Material_Item__c in :materialIds];
        standardPriceBook = [select Id From Pricebook2 where Name = 'Standard Price Book' and IsStandard = true limit 1];
        newPriceBookRecords = [select Id, Pricebook2Id, Product2Id from PriceBookEntry where Product2Id in :allProducts];
    }
    
    public void executeCopyOfRecords() {
        List<OppLineItem> oppLineItems = new List<OppLineItem>();
        for(Quote__c q : closedQuotes) {
            for(Quote_Line_Item__c qli : q.Quote_Line_Items__r) {
                OppLineItem newItem = new OppLineItem();
                
                OpportunityLineItem newOppLineRecord = new OpportunityLineItem();
                newOppLineRecord.Quantity = qli.Quantity__c;
                newOppLineRecord.UnitPrice = qli.Actual_Price__c;
                newOppLineRecord.OpportunityId = q.Opportunity__c;
                newOppLineRecord.Quote__c = q.Id;
                newOppLineRecord.Quote_Line_Item__c = qli.Id;
                
                String product2Id;
                for(Product2 p : allProducts) {
                    if(qli.Material_Item__c == p.Material_Item__c) {
                        product2Id = p.Id;
                        break;
                    }
                }
                PricebookEntry newPriceBookRecord;
                for(PricebookEntry pbe : newPriceBookRecords) {
                    if(pbe.Product2Id == product2Id && pbe.Pricebook2Id == standardPriceBook.Id) {
                        newPriceBookRecord = pbe;
                    }
                }
                if(newPriceBookRecord == null) {            
                    newPriceBookRecord = new PricebookEntry();
                    newPriceBookRecord.Pricebook2Id = standardPriceBook.Id;
                    newPriceBookRecord.UnitPrice = qli.Actual_Price__c;
                    newPriceBookRecord.IsActive = true;
                    newPriceBookRecord.Product2Id = product2Id; 
                } 
                
                Pricing_Condition__c newPricingConditionRecord = new Pricing_Condition__c();
                //newPricingConditionRecord.VAKEY__c = qli.Sales_Site__r.SAP_Account_Number__c + ' ' + q.Opportunity__r.Deal_Number__c + ' ' + opportunityRecords.get(q.Opportunity__c).Account.SAP_Account_Number__c + ' ' + qli.Material_Item__r.Material_Code__c;
                newPricingConditionRecord.Price_Valid_From__c = qli.Price_Valid_From__c;
                newPricingConditionRecord.Price_Valid_To__c = qli.Price_Valid_To__c;
                newPricingConditionRecord.Price__c = qli.Actual_Price__c;
                
                newItem.newPriceBookEntry = newPriceBookRecord;
                newItem.newPricingCondition = newPricingConditionRecord;
                newItem.currentLineItem = qli;
                newItem.newLineItem = newOppLineRecord;
                oppLineItems.add(newItem);
            }
        }
        if(oppLineItems.size() > 0) {
            List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
            for(OppLineItem oli : oppLineItems) {
                Boolean currentlyExisting = false;
                for(PricebookEntry pbe : pricebookEntries) {
                    if(pbe.Id == oli.newPriceBookEntry.Id) {
                        currentlyExisting = true;
                    }
                }
                if(!currentlyExisting) {
                    pricebookEntries.add(oli.newPriceBookEntry);
                }
            }
            upsert pricebookEntries;
            
            List<Pricing_Condition__c> pricingConditions = new List<Pricing_Condition__c>();
            for(OppLineItem oli : oppLineItems) {
                pricingConditions.add(oli.newPricingCondition);
            }
            insert pricingConditions;
            
            List<OpportunityLineItem> opportunityProducts = new List<OpportunityLineItem>();
            for(OppLineItem oli : oppLineItems) {
                oli.newLineItem.PricebookEntryId = oli.newPriceBookEntry.Id;
                oli.newLineItem.Pricing_Condition__c = oli.newPricingCondition.Id;
                opportunityProducts.add(oli.newLineItem);
            }
            insert opportunityProducts;
        }
    }
    private static testmethod void opportunityClosedDealTest() {
    	Test.startTest();
    	Account testAccount = TestUtils.createAccount('Test Account 1', null);
    	RecordType dealRecordType = [select Id From RecordType where SobjectType = 'Opportunity' and DeveloperName = 'Deal_Quoted' limit 1];
        Opportunity testOpportunity = new Opportunity();
        //testOpportunity.Name = 'Test Opportunity 1';
        testOpportunity.CloseDate = Date.today();
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.StageName = 'Prospecting';
        testOpportunity.RecordTypeId = dealRecordType.Id;
        insert testOpportunity;
        
        Quote__c testQuote = TestUtils.createQuote(testOpportunity);
        Material_Item__c testMaterial = TestUtils.createMaterialItem('TestMaterial', 'TestMaterialCode', '00123');
        
        Quote_Line_Item__c testQLI = TestUtils.createQli(testMaterial, 3, '', testQuote , 1);
        
        testOpportunity.StageName = 'Closed - Won';
        update testOpportunity;
        Test.stopTest();
    }
    class OppLineItem {
        public Quote_Line_Item__c currentLineItem {get; set;}
        public OpportunityLineItem newLineItem {get; set;}
        public PricebookEntry newPriceBookEntry {get; set;}
        public Pricing_Condition__c newPricingCondition {get; set;}
    }
    */
    
}