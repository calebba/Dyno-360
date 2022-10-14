public with sharing class MaterialScenarioRelatedListExtension {
	public Id miId {get;set;}
	public boolean fullList {get;set;}
	public integer RecordCount {get;set;}
	public List<Quote__c> Scenarios {get;set;}
	
	public MaterialScenarioRelatedListExtension(ApexPages.StandardController sc){
		miId = (Id)sc.getId();
		RecordCount = 0;
		
		if(Apexpages.currentPage().getParameters().get('full') == 'y'){
			fullList = true;
		}else{
			fullList = false;
		}
		
		Scenarios = queryForScenariosByMaterialID(miId);
	}
	
	private List<Quote__c> queryForScenariosByMaterialID(Id material){
		List<Quote__c> retVal;
		if(!fullList){
			List<Quote_Line_Item__c> qli = [Select Id, Quote__c From Quote_Line_Item__c Where Material_Item__c = :material And IsActiveScenario__c = 1 limit 100];
			List<Id> ScenarioIds = new List<Id>();
			
			for(Quote_Line_Item__c li : qli){
				ScenarioIds.add(li.Quote__c);
			}
			
			retVal = [Select Id, Name, Quote_Valid_To__c, Quote_Valid_From__c, Price_Valid_To__c, Price_Valid_From__c, Approval_Status__c 
					From Quote__c 
					Where Id in :ScenarioIds
					Or Volumetric_Parent_Product__c = :material
					limit 5];
		}else{
			List<Quote_Line_Item__c> qli = [Select Id, Quote__c From Quote_Line_Item__c Where Material_Item__c = :material And IsActiveScenario__c = 1];
			List<Id> ScenarioIds = new List<Id>();
			
			for(Quote_Line_Item__c li : qli){
				ScenarioIds.add(li.Quote__c);
			}
			
			retVal = [Select Id, Name, Quote_Valid_To__c, Quote_Valid_From__c, Price_Valid_To__c, Price_Valid_From__c, Approval_Status__c 
					From Quote__c 
					Where Id in :ScenarioIds
					Or Volumetric_Parent_Product__c = :material
					limit 1000];
		}
		
		RecordCount = retVal.size();
		if(RecordCount == 1000){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Too many results were found.  Data was limited to first 1000 records.'));
		}
		return retVal;
	}
	
	public pageReference backToMaterial(){
		pageReference retVal = new pageReference('/' + miId);
		retVal.setRedirect(true);
		
		return retVal;
	}
	
	public pageReference startReplaceProc(){
		pageReference retVal = new pageReference('/apex/MassReplaceMaterial?id=' + miId);
		retVal.setRedirect(true);
		
		return retVal;
	}
	
	static testMethod void Test_InitMaterialScenarioRelatedList(){
		test.setCurrentPage(Page.MaterialScenarioRelatedList);
		
		Material_Item__c item = TestUtils.createMaterialItem('Test', 'TEST', '', null);
		
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(item);
		MaterialScenarioRelatedListExtension ctrl = new MaterialScenarioRelatedListExtension(sc);
	}
	
	static testMethod void Test_InitMaterialScenarioFullList(){
		test.setCurrentPage(Page.MaterialScenarioFullList);
		
		Material_Item__c item = TestUtils.createMaterialItem('Test', 'TEST', '', null);
		
		ApexPages.currentPage().getParameters().put('full','y');
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(item);
		MaterialScenarioRelatedListExtension ctrl = new MaterialScenarioRelatedListExtension(sc);
		
		ctrl.backToMaterial();
	}
}