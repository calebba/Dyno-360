public with sharing class QuoteTriggerUtil {
	public static Boolean isRunning = false;
	
	public static void updateQuotePrice(List<Quote__c> incQLI){
	
		List <Id> incOppIds   = new List<Id>();
		
		List <Quote__c> updateQuotes = [SELECT Id, Active_Quote__c, Quote_Amount__c, Opportunity__c FROM Quote__c WHERE Active_Quote__c = TRUE AND Id in: incQLI];

		for (Quote__c incQ: updateQuotes){
			incOppIds.add(incQ.Opportunity__c);
		}
		List <Opportunity> updateOpps = [SELECT Id, Name, Amount FROM Opportunity WHERE Id in: incOppIds];
		Map <Id, Opportunity> quoteMap = new Map <Id, Opportunity>(updateOpps);
		List <Opportunity> finishedOpps = new List<Opportunity>();
		
		for (Quote__c q: updateQuotes){
			Opportunity tempOpp = quoteMap.get(q.Opportunity__c);
			if(tempOpp != null){
				tempOpp.Amount = q.Quote_Amount__c;	
				finishedOpps.add(tempOpp);
			}
			
		}
		update finishedOpps;
	}
	
	/*
	public static void generateQuoteName2(List<Quote__c> quoteList) {
		isRunning = true;
     	Set<String> DealIds = new Set<String>();
     	
     	for (Quote__c a: quoteList) {
     		DealIds.add(a.Opportunity__c);
     	}
		List<Opportunity> 	dealForOpps 	 = [SELECT Id, Name FROM Opportunity WHERE Id in: DealIds];
		Map<Id, Opportunity> OppIdtoDeal   = new Map<Id, Opportunity>(dealForOpps);		
		
		for (Quote__c o: quoteList) {
			String generatedName = '';	
			
			if ( OppIdtoDeal.size() > 0)
				generatedName = OppIdtoDeal.get(o.Opportunity__c).Name;
			
			if(o.Version_Number__c != null)
			  	generatedName = generatedName + '-' + o.Version_Number__c;
			
			o.Name = generatedName;
		}		
		update quoteList;
		isRunning = false;
	}*/
	
	public static void generateQuoteName(List<Quote__c> quoteList){
     	Set<String> DealIds = new Set<String>();
     	
     	for (Quote__c a: quoteList) {
     		DealIds.add(a.Opportunity__c);
     	}
		List<Opportunity> 	dealForOpps 	 = [SELECT Id, Name FROM Opportunity WHERE Id in: DealIds];
		Map<Id, Opportunity> OppIdtoDeal   = new Map<Id, Opportunity>(dealForOpps);		
		
		for (Quote__c o: quoteList) {
			String generatedName = '';	
			
			if ( OppIdtoDeal.size() > 0)
				generatedName = OppIdtoDeal.get(o.Opportunity__c).Name;
			
			if(o.Version_Number__c != null)
			  	generatedName = generatedName + '-' + o.Version_Number__c;
			
			o.Name = generatedName;
		}
	}
	
	public static void setCostDriverRates(List<Quote__c> quotes) {
		List<Id> siteIds = new List<Id>();
		
		for (Quote__c quote : quotes) {
			siteIds.add(quote.Sales_Organization_Primary__c);
		}
		
		Map<Id, Sales_Site__c> siteMap = new Map<Id, Sales_Site__c>([Select s.Id, s.Average_Total_Hrs__c, s.Average_Rev_Exp__c, s.Average_Pounds__c, s.Average_Miles__c, s.Average_Mhrs__c, s.Average_Invoice__c From Sales_Site__c s where s.Id in :siteIds]);
		
		Sales_Site__c site;
		for (Quote__c quote : quotes) {
			site = siteMap.get(quote.Sales_Organization_Primary__c);
			quote.Site_Cost_Driver_Rate_Invoice__c = site.Average_Invoice__c;
			quote.Site_Cost_Driver_Rate_Mhrs__c = site.Average_Mhrs__c;
			quote.Site_Cost_Driver_Rate_Miles__c = site.Average_Miles__c;
			quote.Site_Cost_Driver_Rate_Pounds__c = site.Average_Pounds__c;
			quote.Site_Cost_Driver_Rate_Rev_Exp__c = site.Average_Rev_Exp__c;
			quote.Site_Cost_Driver_Rate_Total_Hrs__c = site.Average_Total_Hrs__c;
		}
	}
}