@isTest
private class MaterialItemTriggerUtilsTest {

    @isTest static void myUnitTest() {
 
 		List <Material_Item__c> testItems = new List <Material_Item__c>();
 		
       	Material_Item__c myTestItem = new Material_Item__c();
       	
       	myTestItem.Name = 'TEST ITEM';
       	myTestItem.Material_Code__c = '400';
       	myTestItem.Material_Description__c = 'This product causes me to levitate';
       	myTestItem.Label_Family__c = 'Float';   	
       	testItems.add(myTestItem);
       	
       	Material_Item__c myTestItem2 = new Material_Item__c();

       	myTestItem2.Name = 'TEST ITEM 2';
       	myTestItem2.Material_Code__c = '800';
       	myTestItem2.Material_Description__c = 'This product is the best product ever';
       	myTestItem2.Label_Family__c = 'Fantastic';   	
       	testItems.add(myTestItem2); 
       	
       	insert testItems;
                
		//Pricebook2 standardPriceBook = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'Standard Price Book'];
       	
       	Product2 autoCreatedProduct =  [SELECT Id,Name,ProductCode,Material_Item__c FROM Product2 WHERE Material_Item__c =: myTestItem.Id];       		
       		System.assertEquals(autoCreatedProduct.Name, myTestItem.Name);
       		System.assertEquals(autoCreatedProduct.ProductCode, myTestItem.Material_Code__c);
       		
       	Product2 autoCreatedProduct2 =  [SELECT Id,Name,ProductCode,Material_Item__c FROM Product2 WHERE Material_Item__c =: myTestItem2.Id];       		
       		System.assertEquals(autoCreatedProduct2.Name, myTestItem2.Name);
       		System.assertEquals(autoCreatedProduct2.ProductCode, myTestItem2.Material_Code__c);
       		
       	/*PricebookEntry autoPBEntry =  [SELECT Id,UnitPrice,Pricebook2Id,Product2Id FROM PricebookEntry WHERE Product2Id =: autoCreatedProduct.Id]; 
       		System.assertEquals(autoPBEntry.UnitPrice, 0.00);
       		System.assertEquals(autoPBEntry.Pricebook2Id, standardPriceBook.Id);
       	
       	PricebookEntry autoPBEntry2 =  [SELECT Id,UnitPrice,Pricebook2Id,Product2Id FROM PricebookEntry WHERE Product2Id =: autoCreatedProduct2.Id]; 
       		System.assertEquals(autoPBEntry2.UnitPrice, 0.00);
       		System.assertEquals(autoPBEntry2.Pricebook2Id, standardPriceBook.Id);*/
       			
       		
	}
}