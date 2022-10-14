global class TransferPricingBatch implements Database.Batchable<sObject>, Database.Stateful {

	private Criteria BatchCriteria;
	
	private integer Inserts;
	private integer Updates;
	
	private List<ErrorElement> ErrorElements;
	
	private Map<Id, Set<Id>> duplicates;

	global TransferPricingBatch(Criteria bCriteria) {
		BatchCriteria = bCriteria; 
		Inserts = 0;
		Updates = 0;
        ErrorElements = new List<ErrorElement>();
        duplicates = new Map<Id, Set<Id>>();
    }

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id, Product2.Material_Item__c, Product2.Material_Item__r.PHL3__c, Product2.Material_Item__r.PHL2__c, Product2.Material_Item__r.PHL1__c, CurrencyIsoCode, ' +
											 	'Pricebook2.Name, Product2.ProductCode, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = \'' + BatchCriteria.PricebookId + '\'');
		/* UnitPrice > 0 AND Product2.Material_Item__c != null AND */
    }
    
    global void execute(Database.BatchableContext BC, List<PricebookEntry> pes) {
    	
    	system.debug(BatchCriteria);
    	
    	Set<Transfer_Data__c> newTDs = new Set<Transfer_Data__c>();
		Map<Id, Transfer_Data__c> updTDs = new Map<Id, Transfer_Data__c>();
		
		
		for (PricebookEntry pe : pes) {
			
			if (!duplicates.containsKey(pe.Product2.Material_Item__c))
				duplicates.put(pe.Product2.Material_Item__c, new Set<Id>());
			duplicates.get(pe.Product2.Material_Item__c).add(pe.Product2Id);
			
			for (Id tpaId : BatchCriteria.ExTpas.keyset()) {
			
				if (BatchCriteria.ExTpas.get(tpaId).CurrencyIsoCode != pe.CurrencyIsoCode)
					continue;
				
				if (pe.Product2.Material_Item__c == null || pe.UnitPrice == null || pe.UnitPrice == 0) {
					ErrorElements.add(new ErrorElement(pe.Product2, BatchCriteria.ExTpas.get(tpaId)));
					continue;
				}
	
				integer discountLevel = 4;
				Account_Discount__c foundAD = null;
				for (Account_Discount__c ad : BatchCriteria.ExistingAds) {
					if (ad.Transfer_Pricing_Account__c != tpaId)
						continue;
					if (BatchCriteria.ValidTo < ad.Start_Date__c || BatchCriteria.ValidFrom > ad.End_Date__c)
						continue;
					if (discountLevel > 0 && ad.Material_Item__c == pe.Product2.Material_Item__c) {
						discountLevel = 0;
						foundAD = ad;
					}
					if (discountLevel > 1 && ad.PHL3__r.Full_PHL3__c == pe.Product2.Material_Item__r.PHL1__c + pe.Product2.Material_Item__r.PHL2__c + pe.Product2.Material_Item__r.PHL3__c && ad.Material_Item__c == null) {
						discountLevel = 1;
						foundAD = ad;
					}
					if (discountLevel > 2 && ad.PHL2__r.Full_PHL2__c == pe.Product2.Material_Item__r.PHL1__c + pe.Product2.Material_Item__r.PHL2__c && ad.Material_Item__c == null && ad.PHL3__c == null) {
						discountLevel = 2;
						foundAD = ad;
					}
					if (discountLevel > 3 && ad.PHL1__r.Name == pe.Product2.Material_Item__r.PHL1__c && ad.Material_Item__c == null && ad.PHL3__c == null && ad.PHL2__c == null) {
						discountLevel = 3;
						foundAD = ad;
					}
				}
				
				Transfer_Data__c foundTD = null;
				for (Transfer_Data__c td : BatchCriteria.ExistingTDs)
					if (td.Transfer_Pricing_Account__c == tpaId && td.Material__c == pe.Product2.Material_Item__c) /* && td.Pricelist__c == pe.Pricebook2.Name*/
						foundTD = td;
					
				if (discountLevel == 4) {
					ErrorElements.add(new ErrorElement(pe.Product2, BatchCriteria.ExTpas.get(tpaId)));
					continue;
				}
				
				string discountFrom = 'No Discount';
				if (discountLevel == 0)
					discountFrom = 'Material';
				if (discountLevel == 1)
					discountFrom = 'PHL3';
				if (discountLevel == 2)
					discountFrom = 'PHL2';
				if (discountLevel == 3)
					discountFrom = 'PHL1';
				decimal discount = 0;
				if (foundAD != null)
					discount = foundAD.Discount_Percent__c;
				if (foundTD == null) {
					foundTD = new Transfer_Data__c();
					foundTD.Transfer_Pricing_Account__c = tpaId;
					foundTD.Valid_From__c = BatchCriteria.ValidFrom;
					foundTD.Valid_To__c = BatchCriteria.ValidTo;
					foundTD.Pricelist__c = pe.Pricebook2.Name;
					foundTD.Material__c = pe.Product2.Material_Item__c;
					foundTD.Base_Price__c = pe.UnitPrice;
					foundTD.Discount__c = discount;
					foundTD.Discount_From__c = discountFrom;
					newTDs.add(foundTD);
				} else {
					boolean changed = false;
					if (foundTD.Valid_From__c != BatchCriteria.ValidFrom) {
						foundTD.Valid_From__c = BatchCriteria.ValidFrom;
						changed = true;
					}
					if (foundTD.Valid_To__c != BatchCriteria.ValidTo) {
						foundTD.Valid_To__c = BatchCriteria.ValidTo;
						changed = true;
					}
					if (foundTD.Base_Price__c != pe.UnitPrice) {
						foundTD.Base_Price__c = pe.UnitPrice;
						changed = true;
					}
					if (foundTD.Discount__c != discount) {
						foundTD.Discount__c = discount;
						changed = true;
					}
					if (foundTD.Discount_From__c != discountFrom) {
						foundTD.Discount_From__c = discountFrom;
						changed = true;
					}
					if (foundTD.Pricelist__c != pe.Pricebook2.Name) {
						foundTD.Pricelist__c = pe.Pricebook2.Name;
						changed = true;
					}
					if (changed)
						updTDs.put(foundTD.Id, foundTD);
				}
			}
		}
		if (newTDs.size() > 0)
			insert new List<Transfer_Data__c>(newTDs);
		Inserts += newTDs.size();
		if (updTDs.size() > 0)
			update updTDs.values();
		Updates += updTDs.size();
    } 

	global void finish(Database.BatchableContext BC){
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        string urlBase = URL.getSalesforceBaseUrl().toExternalForm();
        String body = 'Transfer Pricing Batch Process has completed.<br /><br />';
        body += Inserts + ' records inserted.<br />';
        body += Updates + ' records updated.<br /><br />';
        
        Set<Id> duplicateMaterialIds = new Set<Id>();
		for (Id materialId : duplicates.keyset())
			if (duplicates.get(materialId).size() > 1)
				duplicateMaterialIds.add(materialId);
		if (duplicateMaterialIds.size() > 0) {
			List<Material_Item__c> duplicateMaterials = [SELECT Id, Name FROM Material_Item__c WHERE Id in :duplicateMaterialIds];
			body += 'The following materials have more than one product assigned to them<br />';
			body += '<table style="border-collapse: collapse;" border="1">';
			for (Material_Item__c mater : duplicateMaterials) {
				body += '<tr><td><a href="' + (urlBase + '/' + mater.Id) + '">' + mater.Name + '</a></td></tr>';
			}
			body += '</table>'; 
		}
        
        if (ErrorElements.size() > 0) {
        	ErrorElements.sort();
        	body += 'Errors:<br />';
        	body += 'The following is a list of material codes for which discounts were not created. Please review the list of product and material codes and verify that the discounts.<br />';
        	body += '<table style="border-collapse: collapse;" border="1"><thead><tr><th>PHL1</th><th>PHL2</th><th>PHL3</th><th>Product Code</th><th>Transfer Pricing Account</th></thead><tbody>';
	        for (ErrorElement ee : ErrorElements) {
	        	body += '<tr><td>' + ee.Product.Material_Item__r.PHL1__c + '</td><td>' + ee.Product.Material_Item__r.PHL2__c + '</td><td>' + ee.Product.Material_Item__r.PHL3__c + '</td><td>' + ee.Product.ProductCode + '</td><td><a href="' + (urlBase + '/' + ee.TPA.Id) + '">' + ee.TPA.Name + '</a></td></tr>'; 
	        }
	        body += '</tbody></table>';
        }
        
        mail.setToAddresses(new String[] {BatchCriteria.UserEmail});
        mail.setSenderDisplayName('Transfer Pricing Batch');
        mail.setSubject('Transfer Pricing Batch Process Completed' + ((ErrorElements.size() > 0) ? ' (with Errors)' : ''));
        mail.setHtmlBody(body);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public class ErrorElement implements Comparable {
		public Product2 Product { get; set; }
		public Transfer_Pricing_Account__c TPA { get; set; }
		public ErrorElement(Product2 prod, Transfer_Pricing_Account__c tpacc) {
			Product = prod;
			TPA = tpacc;
		}
		public Integer compareTo(Object compareTo) {
		    ErrorElement toCompare = (ErrorElement)compareTo;
		    if (toCompare.Product.Material_Item__r.PHL1__c > this.Product.Material_Item__r.PHL1__c)
		    	return 1;
		    if (toCompare.Product.Material_Item__r.PHL1__c < this.Product.Material_Item__r.PHL1__c)
		    	return -1;
		    if (toCompare.Product.Material_Item__r.PHL2__c > this.Product.Material_Item__r.PHL2__c)
		    	return 1;
		    if (toCompare.Product.Material_Item__r.PHL2__c < this.Product.Material_Item__r.PHL2__c)
		    	return -1;
		    if (toCompare.Product.Material_Item__r.PHL3__c > this.Product.Material_Item__r.PHL3__c)
		    	return 1;
		    if (toCompare.Product.Material_Item__r.PHL3__c < this.Product.Material_Item__r.PHL3__c)
		    	return -1;
		    return 0;
		}
	}
	
	global class Criteria {
		public string UserEmail;
		public Id PricebookId;
		public Date ValidFrom;
		public Date ValidTo;
		
		public Map<Id, Transfer_Pricing_Account__c> ExTpas;
		public List<Account_Discount__c> ExistingAds;
		public List<Transfer_Data__c> ExistingTDs;
	}
}