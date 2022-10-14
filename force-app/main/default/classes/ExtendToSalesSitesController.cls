public with sharing class ExtendToSalesSitesController {
	public List<ExtendedSite> extendedSites {get; private set;}
	public Integer numActive {get; set;}
	public Opportunity opp {get; set;}
	public Quote__c quote {get; set;}
	public String PricingRegion {get; set;}
	public String PricingSalesOffice {get; set;}
	
	public ExtendToSalesSitesController(ApexPages.StandardController con) {
		this.opp = [Select Id, AccountId, Sales_Site__c from Opportunity where Id =:(Id)con.getId()];
		determineExtendedSites();
		numActive = [SELECT count() From Quote__c WHERE Active_Quote__c = TRUE and Opportunity__c = :con.getId()];
		quote = New Quote__c();
		quote.Price_Valid_From__c = null;
		quote.Price_Valid_To__c = null;
		quote.Quote_Valid_From__c = null;
		quote.Quote_Valid_To__c = null;

		if(numActive == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Active_Scenario_Extend));
		}
	}
	
	public void determineExtendedSites() {
		//Datetime myDT = Datetime.now();
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, myDT.format('h:mm:ss a') + ' scott ' + this.opp.AccountId));
		this.extendedSites = new List<ExtendedSite>();
		List<Customer_Sales_Site__c> cssList = [Select Sales_Site__c from Customer_Sales_Site__c where Customer__c=:this.opp.AccountId and Flag_For_Deletion__c = false];
		Set<Id> salesSiteIds = new Set<Id>();
		for (Customer_Sales_Site__c css : cssList) {
			salesSiteIds.add(css.Sales_Site__c);
		}
		
		ExtendedSite exSite;
		for (Sales_Site__c site : [Select Id, Name, Pricing_Sales_Office__c from Sales_Site__c where Id in :salesSiteIds]) {
			exSite = new ExtendedSite();
			exSite.site = site;
			exSite.selected = false;
			extendedSites.add(exSite);
		}
		
		//Get the default pricing region for this quote by getting it fromthe account
		PricingRegion = [Select Pricing_Region__c from Account where Id =: opp.AccountId limit 1].Pricing_Region__c;

	}
	
	public List<SelectOption> getPricingRegions(){
  		List<SelectOption> options = new List<SelectOption>();
        
   		Schema.DescribeFieldResult fieldResult = Account.Pricing_Region__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   		for( Schema.PicklistEntry f : ple)
   		{
      		options.add(new SelectOption(f.getLabel(), f.getValue()));
   		}       
   		return options;
	}
	/*
	public List<SelectOption> getSalesOffices(){
  		List<SelectOption> options = new List<SelectOption>();
        
   		Schema.DescribeFieldResult fieldResult = Opportunity.Sales_Office__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   		for( Schema.PicklistEntry f : ple)
   		{
      		options.add(new SelectOption(f.getLabel(), f.getValue()));
   		}       
   		return options;
	}
	*/
	public PageReference extend() {
		if(numActive > 0) {
			
			List<Sales_Site__c> sites = new List<Sales_Site__c>();
			for (ExtendedSite site : this.extendedSites) {
				if (site.selected)
					sites.add(site.site);
			}
			
			If (sites.size() <> 1) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select 1 site'));
				return null;
			}
			
			QuoteUtil.cloneQuote(this.opp.Id, sites, opp.AccountId,quote.Price_Valid_From__c, quote.Price_Valid_To__c, quote.Quote_Valid_From__c, quote.Quote_Valid_To__c, PricingRegion );
			return new PageReference('/'+ Schema.SObjectType.Opportunity.getKeyPrefix() + '/o');
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Active_Scenario_Extend));
		}
		
		return null;
	}
	
	public PageReference cancel() {
		return new PageReference('/'+this.opp.Id);
	}
	
	public class ExtendedSite {
		public Boolean selected {get;set;}
		public Sales_Site__c site {get;set;}
	}
	
}