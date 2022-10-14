public with sharing class SuggestedActionsController {
    
    
    public Decimal EBITAGoal                		{get; set;}
    public Decimal ebitaPerc               			{get; set;}
    public Decimal invoices              		  	{get; set;}
    public Decimal revenue   	                	{get; set;}
    public Decimal gmPer                    		{get; set;}
         
    public Decimal pounds                   		{get; set;}
    public Decimal mileage                  		{get; set;}
    
    public Decimal totDir               	    	{get; set;}
    public Decimal totInd               	    	{get; set;}
    public Decimal totHrs               	    	{get; set;}
    
    public Decimal suggested_1              		{get; set;}
    public Decimal suggested_2              		{get; set;}
    public Decimal suggested_3              		{get; set;}
    public Decimal suggested_4              		{get; set;}
    public Decimal suggested_5              		{get; set;}
    public Decimal suggested_6              		{get; set;}
    public Decimal suggested_7              		{get; set;}
    
    public Date startDate                   		{get; set;}
    public Date endDate                     		{get; set;}
    
    public Decimal ebita 							{get; set;}
    public Decimal gm 								{get; set;}
    public Decimal cm 								{get; set;}
    
    public Map<Id, List<Quote__c>> mappedQuotes {get; set;}
    public List <Sales_Site__c> customerSalesSites {get; set;}
    public Account       fillInParentAcc    {get; set;}
    public Account 		 dataAccount		{get; set;}
    public Account       shipToAccount		{get; set;}
    public List <Account>  fillInAccount      {get; set;}
    public Sales_Site__c fillInSalesSite    {get; set;}
    public Quote__c dummyQuote {get; set;}
    public PandLData data {get; set;}
    
    public suggestedActionsController(){
        
    	fillInAccount 	= new List <Account>();
    	shipToAccount	= new Account();
    	fillInParentAcc = new Account();
        dummyQuote 		= new Quote__c();
        startDate   	= null;
        endDate     	= null;
        
        ebita       	= null;
        gm          	= null;
        cm         		= null;
        
        suggested_1 = 0;
        suggested_2 = 0;
        suggested_3 = 0;
        suggested_4 = 0;
        suggested_5 = 0;
        suggested_6 = 0;
        suggested_7 = 0;
        EBITAGoal = 0.00;
    }
    
    public void performAnalyzation(){
        if (EBITAGoal != 0.00){
        	fillInAccount 	= new List <Account>();
           if( fillInParentAcc.ParentId == null && dummyQuote.Sales_Organization_Primary__c == null){
            	return;
            }
           if (fillInParentAcc.ParentId != null && dummyQuote.Sales_Organization_Primary__c == null){
            	data =	PandLData.createForCustomer(fillInParentAcc.ParentId, dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_To__c);
				dataAccount = [SELECT Name, SAP_Account_Number__c FROM Account WHERE Id=:fillInParentAcc.ParentId];
				
				fillInAccount = [Select SAP_Account_Number__c, Name From Account Where Account_Group__c = '0002 Ship-to party' AND Name =: fillInParentAcc.Name  limit 1];
				if (fillInAccount.size() > 0){
					shipToAccount = fillInAccount[0];
				}
				
            }
        
            if(fillInParentAcc.ParentId == null && dummyQuote.Sales_Organization_Primary__c != null) {
               data = PandLData.createForSite(dummyQuote.Sales_Organization_Primary__c, dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_To__c);
               fillInSalesSite = [SELECT Company_Site__r.Name, SAP_Account_Number__c, Name From Sales_Site__c Where Id=:dummyQuote.Sales_Organization_Primary__c];
            
            }
            
            if(fillInParentAcc.ParentId != null && dummyQuote.Sales_Organization_Primary__c != null) {
               data = PandLData.createForCustomerSalesSite(fillInParentAcc.ParentId, dummyQuote.Sales_Organization_Primary__c, dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_To__c);
               fillInSalesSite = [SELECT Company_Site__r.Name, SAP_Account_Number__c, Name From Sales_Site__c Where Id=:dummyQuote.Sales_Organization_Primary__c];	
               dataAccount = [SELECT Name, SAP_Account_Number__c FROM Account WHERE Id=:fillInParentAcc.ParentId];
               
               fillInAccount = [Select SAP_Account_Number__c, Name From Account Where Account_Group__c = '0002 Ship-to party' AND Name =: fillInParentAcc.Name limit 1];
           		if (fillInAccount.size() > 0){
					shipToAccount = fillInAccount[0];
				}
				
            }
            
            startDate           = dummyQuote.Price_Valid_From__c;		
            endDate             = dummyQuote.Price_Valid_To__c;		
            mileage             = data.distance.value;
            pounds              = data.units.value;  
            ebitaPerc           = data.ebitPercentage;
            invoices            = data.invoices.value;
            revenue             = data.netRevenue.value;
            gmPer               = data.grossMarginPercentage;  
            totDir              = data.directCostDeliveryHrs.value  + data.directCostShotHrs.value;
            totInd              = data.indirectCostTotalHours.value;
            totHrs              = totDir+ totInd;
            ebita               = data.ebit.value;
            gm                  = data.grossMargin.value;
            cm                  = data.contributionMargin.value;
			
            
            try{
                suggested_1 = ((EBITAGoal - (ebitaPerc /100)) * revenue/pounds * 100).setScale(4);
            }
            catch(exception e){
            	suggested_1 = 0;
            }
            try {
            	suggested_2 = ((EBITAGoal - (ebitaPerc/100)) * revenue/invoices / (gmPer/100)).setScale(4);
            }
            catch(exception e){
            	suggested_2 = 0;	
            }
             try {
            	suggested_3 = ((((EBITAGoal - (ebitaPerc/100)) * revenue) / (totDir/ totHrs)) / invoices).setScale(4);
            }
            catch(exception e){
            	suggested_3 = 0;	
            }
            try {
            	suggested_4 = ((((EBITAGoal - (ebitaPerc/100)) * revenue) / invoices) / ((totDir / invoices) + (totInd / invoices))).setScale(4);
            }
            catch(exception e){
            	suggested_4 = 0;	
            }
            try {
            	suggested_5 = ((((EBITAGoal - (ebitaPerc/100)) * revenue) / invoices) / (totHrs / invoices)).setScale(4);
            }
            catch(exception e){
            	suggested_5 = 0;	
            }
            try {
            	suggested_6 = ((((EBITAGoal - (ebitaPerc/100)) * revenue)) / invoices).setScale(4);
            }
            catch(exception e){
            	suggested_6 = 0;	
            }
            try {
            	suggested_7 = ((((EBITAGoal - (ebitaPerc/100)) * revenue) / invoices) / (mileage / invoices)).setScale(4);
            }
            catch(exception e){
            	suggested_7 = 0;	
            } 
        }
    }
}