public with sharing class ManualPublishScenario {

	private String retURL;
	public boolean isButtonShown { get; set; }
	public boolean publishButtonDisabled { get; set; }
		
	//public ManualCopaAggregate(ApexPages.StandardSetController controller) {
		//retURL = ApexPages.currentPage().getParameters().get('retURL');
	//}
	
	List<Quote__c> scenarios;	
	
	public List<Quote__c> getScenarios() {

		scenarios = [SELECT id, Name, Date_Published_to_SAP__c, Opportunity__r.StageName, Opportunity__r.Owner.Name, Opportunity__r.Account.Name FROM Quote__c WHERE Manual_Publish_SAP__c = '1'];
		return scenarios;

  	}
  	
  	public ManualPublishScenario() {
  		
  		isButtonShown = false;
  		publishButtonDisabled = false;
  	}
  	
  	public pageReference ReloadScenario(){
  		
  		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Button pressed' ));
  		publishButtonDisabled = false;
  		return null;
  	}

	
	public pageReference ManualPubToSAPLaunch() {
		String userId = UserInfo.getUserId();
		User myUser = [SELECT email FROM User where Id = :userId LIMIT 1];
		
		List<Quote__c> scenarioList;
		scenarioList = [SELECT q.Id, q.Volumetric_Parent_Product__r.Material_code__c, q.Name, q.SAP_Scenario_Number__c, q.SAP_Scenario_Number_v2__c, q.Customer_Group__c, q.Opportunity__r.RecordType.Name, q.Quote_Accepted_By_Customer__c,  q.Approval_Status__c, q.Active_Quote__c, q.Sales_Organization_Primary__r.Company_Site__r.Name, q.CurrencyIsoCode, q.Price_Valid_From__c, q.Price_Valid_To__c, q.Volumetric_Parent_Product_UoM__c, 
	                            q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.SAPExternalId__c, q.Opportunity__r.Deal_Number__c, q.Sales_Organization_Primary__r.SalesOrg_Code__c, q.Sales_Organization_Primary__r.SalesGroup_Code__c, q.Sales_Organization_Primary__r.Region__c, q.Sales_Organization_Primary__r.Name, q.Customer__r.SAP_Account_Number__c, q.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c, q.Calculated_Price__c, q.Volumetric_Per__c, q.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c,
	                            (SELECT Id, Name, Price_Valid_From__c, Price_Valid_To__c, Per__c, UoM__c, Quote__r.Name, Sales_Site__r.Region__c, Sales_Site__r.Company_Site__r.Name, Actual_Price__c, Sales_Site__r.SAP_Account_Number__c, Material_Item__r.Is_PHL__c, Material_Item__r.Product_Hierarchy__c,
	                            Material_Item__c, Receive_NH3_Surcharge__c, Sales_Site__c,  Sales_Site__r.SAPExternalId__c, Sales_Site__r.Company_Site__r.SAPExternalId__c, Sales_Site__r.Region_Site__r.SAPExternalId__c, Material_Item__r.Material_Code__c, Quote__r.Customer__r.SAP_Account_Number__c, Quote__r.Opportunity__r.Deal_Number__c, Sales_Site__r.Name, Publish_To_SAP__c
	                            FROM Quote_Line_Items__r Where Is_Bundled__c = false)  FROM Quote__c q WHERE Manual_Publish_SAP__c = '1'];

		 try {
                QuoteUtil.CreatePricingConditionBulk(scenarioList);
            }
            catch (QuoteUtil.MaterialCostException me) {
                ApexPages.addMessages(me);
            }
		
		//for(Quote__c s: scenarioList) {

			//publishToSAP( s.id);
		//}   
		
		isButtonShown = true;
		publishButtonDisabled = true;
		return null;
		
	}
	
	
	
	public void publishToSAP(String id){
        
       
            try {
                QuoteUtil.CreatePricingCondition(id);
            }
            catch (QuoteUtil.MaterialCostException me) {
                ApexPages.addMessages(me);
            }
            //PageReference pr = new PageReference( '/' + pageRecord.Opportunity__c + '/e?retURL=/apex/SLIQuickAdd?id=' + pageRecord.Id);
            //return pr.setRedirect(true);
        	//return 'done';
    }
	


}