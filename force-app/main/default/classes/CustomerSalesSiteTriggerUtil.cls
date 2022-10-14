public with sharing class CustomerSalesSiteTriggerUtil {

	public static void setUniqueConstraintKey(List <Customer_Sales_Site__c > CSSList) {
		for (Customer_Sales_Site__c css : CSSList) {
			css.Constraint_Key__c = css.Customer__c + '-' + css.Sales_Site__c;
		}
	}
	
	public static void updateCSSListOnAccount(List<Customer_Sales_Site__c > cssList) {
		//Go through the css list mapping customer id to sales site id;
		Map<Id, List<Id>> customerToSalesSites = new Map<Id, List<Id>>();
		List<Id> tempList;
		for(Customer_Sales_Site__c currCSS : cssList) {
			if(customerToSalesSites.containsKey(currCSS.Customer__c)) {
				customerToSalesSites.get(currCSS.Customer__c).add(currCSS.Sales_Site__c);
			} else {
				tempList = new List<Id>();
				tempList.add(currCSS.Sales_Site__c);
				customerToSalesSites.put(currCSS.Customer__c, tempList);				
			}
		}
		//query for all of these sales sites sap external ids
		List<Sales_Site__c> ssList = [SELECT Id, SAPExternalId__c FROM Sales_Site__c WHERE Region_Site__c <> null AND Company_Site__c <> null];
		Map<Id, Sales_Site__c> ssMap = new Map<Id, Sales_Site__c>(ssList);
		//query for all of these customers
		List<Account> acctList = [SELECT Id, Valid_Sites__c FROM Account WHERE Id in :customerToSalesSites.keySet()];
		Map<Id, Account> acctMap = new Map<Id, Account>(acctList);
		//Map from account to sales site
		Map<Account, List<Sales_Site__c>> acctToSS = new Map<Account, List<Sales_Site__c>>();
		Sales_Site__c currentSite;
		for(Account currAcct : acctList) {
			for(Id currentId : customerToSalesSites.get(currAcct.Id)) {
				if(ssMap.containsKey(currentId)) {
					currentSite = ssMap.get(currentId);
					if(currentSite.SAPExternalId__c != null && currentSite.SAPExternalId__c.trim() != '') {
						if(currAcct.Valid_Sites__c == null || currAcct.Valid_Sites__c.trim() == '') {
							currAcct.Valid_Sites__c = currentSite.SAPExternalId__c;
						} else if(currAcct.Valid_Sites__c.trim().length() > 0 && currAcct.Valid_Sites__c.trim().length() <= 90) {
							currAcct.Valid_Sites__c += ', ' + currentSite.SAPExternalId__c;
						}
					}
				}
			}
		}
		update acctList;
	}
	
	public static void CheckRecordTypeChange(List <Customer_Sales_Site__c > CSSList){
		Id CSSRecordTypeSAP = [select Id from RecordType where SobjectType = 'Customer_Sales_Site__c' and DeveloperName = 'SAP_Integrated'].Id;
		Id CSSRecordTypeNonSAP = [select Id from RecordType where SobjectType = 'Customer_Sales_Site__c' and DeveloperName = 'SAP_Non_Integration'].Id;

		for (Customer_Sales_Site__c c: CSSList){
			if (c.SAPAccountSiteId__c != null){
				c.RecordTypeId = CSSRecordTypeSAP;
			}
			else{
				c.RecordTypeId = CSSRecordTypeNonSAP;
			}
		}
	}

}