public with sharing class MaterialItemTriggerUtils {
    
    //Create Product, Pricebook Entry for price of $0 and adds link to the Material Item List on the 
    //newly created Product
    public static void CreateProductInfo(List<Material_Item__c> materialItemList) {
        
        Pricebook2 standardPriceBook;
        
        // if in test mode, there is no access to the PriceBook2 object and query will return no rows
        if (Test.isRunningTest())
        {
            standardPriceBook = new Pricebook2();
            standardPriceBook.Id = Test.getStandardPricebookId(); 
        }
        else
        {
            standardPriceBook = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'Standard Price Book'];
        }
        
        List <Product2> productsToInsert                = new List <Product2>();
        List <PricebookEntry> pricebookEntryToInsert    = new list <PricebookEntry>();
        
        for (Material_Item__c currMaterialItem : materialItemList){
            //Create a new product record with the Item Material Data
            Product2 myProduct = new Product2();
            myProduct.Name              = currMaterialItem.Name;
            myProduct.ProductCode       = currMaterialItem.Material_Code__c;
            myProduct.Description       = currMaterialItem.Material_Description__c;
            myProduct.Family            = currMaterialItem.Label_Family__c;
            myProduct.Material_Item__c  = currMaterialItem.Id;
            myProduct.IsActive          = true;
            
            productsToInsert.add(myProduct);                
            
        }
        insert productsToInsert;
        
        for (Product2 singleProduct: productsToInsert){
            
            //Create a new Pricebook Entry under the Standard Price Book
            PricebookEntry myPbEntry = new PricebookEntry();
            myPbEntry.UnitPrice    = 0.00;
            myPbEntry.Pricebook2Id = standardPriceBook.Id;
            myPbEntry.Product2Id   = singleProduct.Id;
            myPBEntry.IsActive     = true;
            pricebookEntryToInsert.add(myPbEntry);  
            
        }
        
        
        insert pricebookEntryToInsert;
        
    }
    
    public static void setDefaultRecordType(List<Material_Item__c> materialItemList) {
        Id standardMaterialItem = [select Id from RecordType where SobjectType = 'Material_Item__c' and DeveloperName = 'Standard'].Id;
        for(Material_Item__c mi : materialItemList) {
            mi.RecordTypeId = standardMaterialItem;
        }
    }
    
    public static void setIfFormulaExists(List<Material_Item__c> materialItemList) {
        Id formulaMaterialItem = [select Id from RecordType where SobjectType = 'Material_Item__c' and DeveloperName = 'Formula'].Id;
        for(Material_Item__c mi : materialItemList) {
            /*  if(mi.Formula_Text__c != null && mi.RecordTypeId != formulaMaterialItem) {
mi.RecordTypeId = formulaMaterialItem;
} */
        }
    }
}