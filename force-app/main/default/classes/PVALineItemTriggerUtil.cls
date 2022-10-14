public with sharing class PVALineItemTriggerUtil {
	
	public static void generateNames(List<PVA_Line_Item__c> pvaList) {
		//get map of customer id to number of pca line items
		List<AggregateResult> arList = [SELECT count(Id) theCount, PVA__r.Account__c acctId FROM PVA_Line_Item__c GROUP BY PVA__r.Account__c];
		Map<Id, Integer> customerToCount = new Map<Id, Integer>();
		for(AggregateResult ar : arList) {
			customerToCount.put((Id) ar.get('acctId'), (Integer) ar.get('theCount'));
		}
		//when inserting pva line item, look at its pva's name and its customer.
		Integer count = 0;
		for(PVA_Line_Item__c currPVALine : pvaList) {
			if(customerToCount.get(currPVALine.Customer__c) == null) {
				//there are no pvas under this customer, its number is 1.
				currPVALine.PVA_Name__c = currPVALine.Parent_Name__c + '-001';
				customerToCount.put(currPVALine.PVA__r.Account__c, 1);
			} else {
				//set pva line items name to be pva's name "-" the count+1
				count = customerToCount.get(currPVALine.Customer__c) + 1;
				if(count < 10) {
					currPVALine.PVA_Name__c = currPVALine.Parent_Name__c + '-00' + count;
				} else if(count < 100) {
					currPVALine.PVA_Name__c = currPVALine.Parent_Name__c + '-0' + count;
				} else {
					currPVALine.PVA_Name__c = currPVALine.Parent_Name__c + '-' + count;
				}
				customerToCount.put(currPVALine.Customer__c, count+1);
			}
		}		
	}
	
}