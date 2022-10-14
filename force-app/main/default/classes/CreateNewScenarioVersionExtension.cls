public with sharing class CreateNewScenarioVersionExtension {
    public Boolean recreateVersion {get; set;}
    public Quote__c scenario {get; set;}
    public Boolean isSysAdmin {get; set;}
    public SLIAdjustments Adjustments { get; set; } 
     
    private string QuoteRecordType;
     
    public CreateNewScenarioVersionExtension(ApexPages.StandardController con) {
    	recreateVersion = false;
        if (ApexPages.currentPage().getParameters().get('reactivate') == 'y') {
            this.recreateVersion = true;
        }
        this.scenario = (Quote__c)con.getRecord();
        if (this.recreateVersion) {
        	Id scenId = ApexPages.currentPage().getParameters().get('scenarioId');
        	Quote__c tm = [SELECT Id, Price_Valid_From__c, Price_Valid_To__c, Quote_Valid_From__c, Quote_Valid_To__c, Opportunity__r.RecordType.DeveloperName FROM Quote__c WHERE Id= :scenId];
        
	        this.scenario.Prev_Price_Valid_From__c = tm.Price_Valid_From__c;
	        this.scenario.Prev_Price_Valid_To__c = tm.Price_Valid_To__c;
	        this.scenario.Quote_Valid_From__c = tm.Quote_Valid_From__c;
        	this.scenario.Quote_Valid_To__c = tm.Quote_Valid_To__c;
        	this.scenario.Price_Valid_From__c = null;
	        this.scenario.Price_Valid_To__c = null;
	        QuoteRecordType = tm.Opportunity__r.RecordType.DeveloperName;
	        LoadAdjustments(scenId);
        } else {
        	Quote__c tm = [SELECT Id, Price_Valid_From__c, Price_Valid_To__c, Quote_Valid_From__c, Quote_Valid_To__c, Opportunity__r.RecordType.DeveloperName FROM Quote__c WHERE Id= :scenario.id];
            this.scenario.Prev_Price_Valid_From__c = tm.Price_Valid_From__c;
        	this.scenario.Prev_Price_Valid_To__c = tm.Price_Valid_To__c;
        	this.scenario.Quote_Valid_From__c = tm.Quote_Valid_From__c;
        	this.scenario.Quote_Valid_To__c = tm.Quote_Valid_To__c;
        	this.scenario.Price_Valid_From__c = null;
        	this.scenario.Price_Valid_To__c = null;
	        QuoteRecordType = tm.Opportunity__r.RecordType.DeveloperName;
	        LoadAdjustments(scenario.Id);
        }
        user = [SELECT CreateNewScenarioHide__c FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    private User user;
    public Boolean getRenderAdjustments() {
    	return !(user.CreateNewScenarioHide__c || QuoteRecordType == 'Deal_Volumetric_Quoted');
    }
    
    private void LoadAdjustments(Id scenarioId) {
        Adjustments = new SLIAdjustments();
        List<Quote_Line_Item__c> qlis = [SELECT PHL1__c FROM Quote_Line_Item__c WHERE Quote__c = :scenarioId];
        List<String> phl1s = new List<String>();
        for (Quote_Line_Item__c qli : qlis)
        	phl1s.add(qli.PHL1__c);
        phl1s.sort();
        String lastPHL1 = '';
        for (String phl1 : phl1s) {
        	if (phl1 != lastPHL1)
        		Adjustments.AddLine(phl1);
        	lastPHL1 = phl1;
        }
    }
    
    public void AdjustPHL1Prices() {
    	for (SLIAdjustments.PAndQAdjustment pqa : Adjustments.Adjustments)
    		pqa.PriceAdjustment = Adjustments.PriceAdjustment;
    }
    
    public void AdjustPHL1Quantities() {
    	for (SLIAdjustments.PAndQAdjustment pqa : Adjustments.Adjustments)
    		pqa.QuantityAdjustment = Adjustments.QuantityAdjustment;
    }

    public void AdjustEmptyPHL1Prices() {
    	for (SLIAdjustments.PAndQAdjustment pqa : Adjustments.Adjustments)
    		if (pqa.PriceAdjustment == null || pqa.PriceAdjustment == 0)
    			pqa.PriceAdjustment = Adjustments.PriceAdjustment;
    }
    
    public void AdjustEmptyPHL1Quantities() {
    	for (SLIAdjustments.PAndQAdjustment pqa : Adjustments.Adjustments)
    		if (pqa.QuantityAdjustment == null || pqa.QuantityAdjustment == 0)
        		pqa.QuantityAdjustment = Adjustments.QuantityAdjustment;
    }

    public PageReference create() {
    	
    	//added by RPN apr 6 2012
    		date mytodayDate = date.today();
			date thismonthStart = mytodayDate.toStartofMonth();
			String myprofileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
			isSysAdmin = myprofileName == 'System Administrator' || myprofileName == '# Custom DNA - Pricing Power User';
			
			if (this.scenario.Price_Valid_From__c < thismonthStart && isSysAdmin==False){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have selected an invalid \'Pricing Valid From\' date; the value selected cannot be prior to the first of this month.  Either correct or, if a prior date is needed, contact your pricing administrator.'));
				//this.scenario.Price_Valid_From__c = null;
    			return null;
			}
    	
    	// end RPN
    	
    	
    	boolean wrongQuantity = false;
    	if (Adjustments.PriceAdjustment < -100 || Adjustments.QuantityAdjustment < -100)
    		wrongQuantity = true;
    	for (SLIAdjustments.PAndQAdjustment pqa : Adjustments.Adjustments)
    		if (pqa.PriceAdjustment < -100 || pqa.QuantityAdjustment < -100)
    			wrongQuantity = true;
    	if (wrongQuantity) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Values below -100% are not allowed'));
    		return null;
    	}
    		
        if (this.recreateVersion) {
            Id scenarioId = ApexPages.currentPage().getParameters().get('scenarioId');
            return new PageReference('/'+QuoteUtil.reactivateVersion(scenarioId, this.scenario.Price_Valid_From__c, this.scenario.Price_Valid_To__c, this.scenario.Quote_Valid_From__c, this.scenario.Quote_Valid_To__c, Adjustments));
        } else {
            return new PageReference('/'+QuoteUtil.createNewVersion(this.scenario.Id, this.scenario.Price_Valid_From__c, this.scenario.Price_Valid_To__c, this.scenario.Quote_Valid_From__c, this.scenario.Quote_Valid_To__c, Adjustments));
        }
    }
    
    public PageReference cancel() {
        return new PageReference('/'+this.scenario.Id);
    }
    
}