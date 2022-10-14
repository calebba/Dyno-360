@isTest
public class AccountLMSControllerExtensionTest {

    public static testMethod void ValidateCalculateTable(){
        
        Account acct = TestUtils.createAccount('Service Account', null);

        AccountLMSControllerExtension accountLMS = InitializeController(acct.Id);
        
        System.assertEquals(acct.id, accountLMS.PVA.Account__c);
        
        CreateCalculationsData(acct);
        
        accountLMS.CalculateTable();
    }
    
    private static AccountLMSControllerExtension InitializeController(Id acctId) {
                
        PVA__c PVA = new PVA__c();
        PVA.Account__c = acctId;
        PVA.PVA_Start_Date__c = System.today();
        PVA.Price_List_Date__c = System.today();
        PVA.PVA_End_Date__c = System.today();
            
        insert PVA;
        
        PVA__c newPVA = [SELECT Id, Account__c, PVA_Start_Date__c, PVA_End_Date__c FROM PVA__c LIMIT 1];
        
        PageReference pageRef = Page.AccountLMSsummary;
		Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newPVA);
        AccountLMSControllerExtension conExt = new AccountLMSControllerExtension(sc);
        
        return conExt;
        
    }
    private static void CreateCalculationsData(Account acct){
        
        Product_Grouping__c pg = new Product_Grouping__c();
        pg.Name = 'PL050';
        pg.Product_Line__c = 'Other';
        pg.Description__c = 'Accessories';
        
        insert pg;
        
        Id materialId = createMaterialWithProducts();
        
		Sales_Site__c company1 = TestUtils.createSalesSite('DNNA', null, null);
		Sales_Site__c region1 = TestUtils.createSalesSite('100 WEST', company1.Id, null);
		Sales_Site__c site1 = TestUtils.createSalesSite('WERO', company1.Id, region1.Id);
        
        Copa__c copa = TestUtils.createCopa(acct, site1, 25, 25, 10000, 50, 50000, 45, System.today());
		copa.Material_Item__c = materialId;
            
        insert copa;
         
    }
    
    public static Id createMaterialWithProducts()
    {
       	Material_Item__c testItem = new Material_Item__c();
       	testItem.Name = 'Mesh';
       	testItem.Material_Code__c = 'TS400';
       	testItem.Material_Description__c = 'Heavy Duty';
       	testItem.Label_Family__c = 'Float';
        testItem.Base_Unit_of_Measue__c = 'TON';
        testItem.PHL1__c = 'PL061';
        
        insert testItem;
   	
        return testItem.Id;
    }
    
}