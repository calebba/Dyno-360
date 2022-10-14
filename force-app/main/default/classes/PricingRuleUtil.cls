public with sharing class PricingRuleUtil {
	
	public static void updateDataHoles(List<Pricing_Rule__c> newPricingRules) {
		List<Id> idList = new List<Id>();
		List<Id> customerIds = new List<Id>();
		//Iterate over pricing rules getting a list of all relevant customer and sales site ids
		//Query for all css where the customer and sales site are in your lists
		//iterate over your pricing rules
		//iterate over your css, the css where the customer and sales site match that on the pr is the css for that pr		
		for(Pricing_Rule__c currPr : newPricingRules) {
			if(currPr.Account__c != null) {
				customerIds.add(currPr.Account__c);
			}
			if(currPr.Receiving_Sales_Site__c != null) {
				idList.add(currPr.Receiving_Sales_Site__c);
			}
		}
		List<Sales_Site__c> salesSites = [SELECT Company_Site__c, Region_Site__c, Id FROM Sales_Site__c WHERE Id in :idList];
		for(Pricing_Rule__c currPr : newPricingRules) {
			for(Sales_Site__c currSite : salesSites) {
				if(currSite.Id == currPr.Receiving_Sales_Site__c) {
					currPr.Region_Site__c = currSite.Region_Site__c;
					currPr.Company_Code__c = currSite.Company_Site__c;
				}
			}
		}
		List<Customer_Sales_Site__c> cssList = [SELECT Id, Customer__c, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c in :customerIds AND Sales_Site__c in :idList];
		for(Pricing_Rule__c currPr : newPricingRules) {
			for(Customer_Sales_Site__c css : cssList) {
				if(currPr.Receiving_Sales_Site__c == css.Sales_Site__c && currPr.Account__c == css.Customer__c) {
					currPr.Customer_Sales_Site__c = css.Id;
				}
			}
		}
		
	}
	/*
	public static void createNewDealsBasedOnPricingChange(List<Pricing_Rule__c> newPricingRules) {
		RecordType dealRecordType = [select Id From RecordType where SobjectType = 'Opportunity' and DeveloperName = 'Deal_Quoted' limit 1];
		Set<String> originalPricingRules = new Set<String>();
		/*
		for(Pricing_Rule__c pr : newPricingRules) {
			originalPricingRules.add(pr.Origin_Pricing_Rule__c);
		}*/
	/*	List<Quote_Line_Item__c> currentQuoteLineItems = [select Id, Quote__c, Quote__r.Opportunity__c, Quote__r.Opportunity__r.AccountId from Quote_Line_Item__c where Pricing_Rule__c in: originalPricingRules order by Quote__r.Opportunity__r.AccountId];
		
		List<AggregateResult> results = [Select Quote__r.Opportunity__r.AccountId account, Material_Item__c material,SUM(Quantity__c) totalQuant, UOM__c uom From Quote_Line_Item__c where Id in: currentQuoteLineItems
			Group by Quote__r.Opportunity__r.AccountId, Material_Item__c, UOM__c];
		
		Map<String, List<MaterialQuantity>> lineItemMap = new Map<String, List<MaterialQuantity>>();
		
		for (AggregateResult result : results) {
			if (!lineItemMap.containsKey(String.valueOf(result.get('account')))) {
				lineItemMap.put(String.valueOf(result.get('account')), new List<MaterialQuantity>());
			}
			lineItemMap.get(String.valueOf(result.get('account'))).add(new MaterialQuantity(String.valueOf(result.get('material')), Double.valueOf(result.get('totalQuant')), String.valueOf(result.get('uom'))));
		}	
		
		Set<String> accountIds = new Set<String>();
		for(Quote_Line_Item__c qli : currentQuoteLineItems) {
			accountIds.add(qli.Quote__r.Opportunity__r.AccountId);
		}
		List<Opportunity> newOpportunities = new List<Opportunity>();
		for(String accountId : accountIds) {
			Opportunity newOpportunity = new Opportunity();
			newOpportunity.Name = System.Label.Default_Opportunity_Name;
			newOpportunity.AccountId = accountId;
			newOpportunity.StageName = System.Label.Default_Opportunity_Stage;
			newOpportunity.RecordTypeId = dealRecordType.Id;
			newOpportunity.CloseDate = Date.today().addDays(30);
			newOpportunities.add(newOpportunity);
		}
		insert newOpportunities;
		Set<Id> opportunityIds = new Set<Id>();
		for(Opportunity o : newOpportunities) {
			opportunityIds.add(o.Id);
		}
		List<Quote__c> newQuotes = [select Id, Opportunity__r.AccountId, Sales_Organization_Primary__c from Quote__c where Opportunity__c in: opportunityIds and Active_Quote__c = true];
		List<Quote_Line_Item__c> newQuoteLineItems = new List<Quote_Line_Item__c>();
		for(Quote__c q : newQuotes) {
			List<MaterialQuantity> accountIdQuantities = lineItemMap.get(q.Opportunity__r.AccountId);
			for(Integer i=0; i<newPricingRules.size(); i++) {
				Quote_Line_Item__c newQuoteLineItem = new Quote_Line_Item__c();
				newQuoteLineItem.Quote__c = q.Id;
				newQuoteLineItem.Actual_Price__c = newPricingRules[i].Target_Price__c;
				if(i < accountIdQuantities.size()) {
					newQuoteLineItem.Quantity__c = accountIdQuantities[i].quantity;
					newQuoteLineItem.Material_Item__c = accountIdQuantities[i].material;
					newQuoteLineItem.UoM__c = accountIdQuantities[i].uom;
				}
				newQuoteLineItem.Pricing_Rule__c = newPricingRules[i].Id;
				newQuoteLineItem.Price_Valid_From__c = newPricingRules[i].Price_Valid_From__c;
				newQuoteLineItem.Price_Valid_To__c = newPricingRules[i].Price_Valid_To__c;
				newQuoteLineItem.Sales_Site__c = q.Sales_Organization_Primary__c;
				newQuoteLineItems.add(newQuoteLineItem);
			}
		}
		if(newQuoteLineItems.size() > 0) {
			insert newQuoteLineItems;
		}
	}
	*/

	public static String getPricingSearchQuery() {
		String query = 'select p.UoM__c, p.Target_Price__c, p.SystemModstamp, p.Region_Site__c, p.Receiving_Sales_Site__r.Name, ';
		query += 'p.Receiving_Sales_Site__c, p.Price_Valid_To__c, p.Price_Valid_From__c, p.Per__c, p.OwnerId, ';
		query += 'p.Name, p.Material_Item__c, p.Material_Item__r.Name, p.Material_Item__r.Material_Category__c, ';
		query += 'p.Material_Item__r.Label_Family__c, p.LastModifiedDate, p.LastModifiedById, p.CurrencyIsoCode, '; 
		query += 'p.IsDeleted, p.Id, p.Floor_Price__c, p.CreatedDate, p.CreatedById, p.Account__r.Name, '; 
		query += 'p.Account__c from Pricing_Rule__c p';
		return query;
	}
	
	class MaterialQuantity {
		public String material;
		public Double quantity;
		public String uom;
		
		public MaterialQuantity(String material, Double quantity, String uom) {
			this.material = material;
			this.quantity = quantity;
			this.uom = uom;
		}
	}
	
	public static void checkForDuplicatePricingRules(List<Pricing_Rule__c> pricingRules) {
		for (Pricing_Rule__c rule : pricingRules) {
			rule.Constraint_Key__c = rule.Account__c + '-' + rule.Receiving_Sales_Site__c + '-' + rule.Region_Site__c + '-' + rule.Material_Item__c + '-' + rule.CurrencyIsoCode + '-' + rule.Price_Valid_From__c.format() + '-' + rule.Price_Valid_To__c.format() + '-' + rule.Customer_Group__c + '-' + rule.Pricing_Region__c + '-' + rule.Pricing_Sales_Office__c;
		}
	}
	
}