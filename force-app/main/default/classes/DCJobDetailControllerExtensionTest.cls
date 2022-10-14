@isTest
public class DCJobDetailControllerExtensionTest {
    
    public static testMethod void InitializeControllerWhenDCJobDetailIsNotNull(){
        
        Id materialId = createMaterialWithProducts();
        
        Sales_Site__c ssite = new Sales_Site__c();
        
        insert ssite;
        
        Material_Cost__c mCost = new Material_Cost__c();
        mCost.Material_Item__c = materialId;
        mCost.Sales_Site__c = ssite.Id;
        
        insert mCost;
        
        Account acct = TestUtils.createAccount('Service Account', null);
        
        DynoConsult_Service__c dcS = new DynoConsult_Service__c();
        dcS.StartDate__c = Date.today();
        dcS.Account__c = acct.Id;
        dcs.Description__c = 'Test Service';
        
        insert dcS;
        
        DynoConsult_Job__c dcJ = new DynoConsult_Job__c();
        dcJ.Date_Performed__c = Date.today();
        dcJ.End_Date__c = Date.today().addDays(2);
        dcJ.DynoConsult_Service__c = dcS.Id;
        
        insert dcJ;
        
        DynoConsult_Job_Detail__c dcJD = new DynoConsult_Job_Detail__c();
        dcJD.Material__c = materialId;
        dcJD.Unit_Cost__c = 15;
        dcJD.Units__c = 1.5;
        dcJD.Discount__c = 25;
        dcJD.DynoConsult_Job__c = dcJ.Id;
        
        insert dcJD;
        
        // test first without price rule
            
        DynoConsult_Job_Detail__c dcJobDet = [SELECT Id, Total_Cost__c, Discount_Cost__c, Material__c FROM DynoConsult_Job_Detail__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(dcJobDet);
        DCJobDetailControllerExtension conExt = new DCJobDetailControllerExtension(sc);
        
        System.assertEquals(dcJobDet.Total_Cost__c, conExt.totalCostDisplay);

        conExt.MaterialSelected();
        
        System.assertEquals('TON', conExt.dcJobDetail.UOM__c);
        System.assertEquals(0, conExt.dcJobDetail.Unit_Cost__c);
        
        // test again with price rule
        
        Pricing_Rule__c priceRule = new Pricing_Rule__c();
        priceRule.Pricing_Sales_Office__c = 'DynoConsult';
        priceRule.Receiving_Sales_Site__c = ssite.Id;
        priceRule.Material_Item__c = materialId;
        priceRule.Price_Valid_From__c = System.TODAY();
        priceRule.Price_Valid_To__c = System.TODAY();
        priceRule.Floor_Price__c = 160;
        priceRule.Target_Price__c = 160;
        priceRule.Per__c= 1.0;
        priceRule.UoM__c= 'LB';
        
        insert priceRule;
        
        DCJobDetailControllerExtension conExt2 = new DCJobDetailControllerExtension(sc);
        
        conExt2.MaterialSelected();

        System.assertEquals('TON', conExt2.dcJobDetail.UOM__c);
        System.assertEquals(160, conExt2.dcJobDetail.Unit_Cost__c);
        
    }
    
    public static Id createMaterialWithProducts()
    {
        Material_Item__c testItem = new Material_Item__c();
        testItem.Name = 'Mesh';
        testItem.Material_Code__c = 'TS400';
        testItem.Material_Description__c = 'Heavy Duty';
        testItem.Label_Family__c = 'Float';
        testItem.Base_Unit_of_Measue__c = 'TON';
        testItem.DynoConsult_Material__c = True;
        
        insert testItem;
    
        return testItem.Id;
    }



}