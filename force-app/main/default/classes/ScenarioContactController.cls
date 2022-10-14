public with sharing class ScenarioContactController {
	
	public Quote_Contact__c scenarioContactRecord {get; set;}
	public Id				scenarioId			  {get; set;}
	
	public ScenarioContactController(ApexPages.StandardController quoteController){
		scenarioContactRecord = new Quote_Contact__c();
		scenarioContactRecord.Quote__c = quoteController.getId();
		scenarioId = quoteController.getId();
	}
	
	public PageReference returnToScenario(){
		return new PageReference('/apex/SLIQuickAdd?id=' + scenarioContactRecord.Quote__c);
	}
	
	public PageReference saveScenarioContact(){
		insert scenarioContactRecord;	
		return new PageReference('/apex/SLIQuickAdd?id=' + scenarioContactRecord.Quote__c);
	}
	public PageReference saveAndNewScenarioContact(){
		insert scenarioContactRecord;
		scenarioContactRecord = new Quote_Contact__c();
		return new PageReference('/apex/ScenarioContactPage?id=' + scenarioContactRecord.Quote__c);
	}
}