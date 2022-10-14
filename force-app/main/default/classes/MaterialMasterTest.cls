@isTest
public class MaterialMasterTest {
    
    // Test simple cost with no SCA or TP
    @isTest static void testSimpleCost() {
        // Setup site
         
        MaterialMaster.CostData data = new MaterialMaster.CostData();
        Sales_Site__c site = TestUtils.createPlant('Test Site');
        
        // Setup material
        Material_Item__c item = TestUtils.createItemWitCost(site);
        
        data = MaterialMaster.calculateCost(item.Id, site.Id, null);
        
        System.assertEquals(12.34,data.cost);
        System.assertEquals(12.34,data.seeThroughCost);
        
        //System.assertEquals(12.34,data.cost);
        //System.assertEquals(12.34,data.seeThroughCost);
    }
    
    // Test costing based on a Supply Chain Assumption record
    @isTest static void testSCACost() {
        // Setup site
        Sales_Site__c originSite = TestUtils.createPlant('Origin Site');
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        
        // Setup material
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create SCA
        Supply_Chain_Assumption__c sca = new Supply_Chain_Assumption__c(Material_Item__c=item.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Fixed_Conversion_Cost__c=10.00d);
        insert sca;
        
        MaterialMaster.calculateCost(item.Id, receivingSite.Id, originSite.Id);
        
    }
    
    // Test costing based on a Supply Chain Assumption record
    @isTest static void testSCACostVariable() {
        // Setup site
        Sales_Site__c originSite = TestUtils.createPlant('Origin Site');
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        
        // Setup material
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create SCA
        Supply_Chain_Assumption__c sca = new Supply_Chain_Assumption__c(RecordTypeId=[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Supply_Cost_Allocation'].Id, Material_Item__c=item.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Freight_Cost__c=5.00d);
        insert sca;
        
        MaterialMaster.calculateCost(item.Id, receivingSite.Id, originSite.Id);

    }
    
    // Test costing based on a Transfer Price record
    @isTest static void testTPCost() {
        // Setup site
        Sales_Site__c originSite = TestUtils.createPlant('Origin Site');
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        
        // Setup material
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create SCA
        Supply_Chain_Assumption__c transferPrice = new Supply_Chain_Assumption__c(RecordTypeId=[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Transfer_Price'].Id, Material_Item__c=item.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Freight_Cost__c=5.00d, Gross_Margin__c=1.00d);
        insert transferPrice;
        
        MaterialMaster.calculateCost(item.Id, receivingSite.Id, originSite.Id);
    
    }
    
	// Test that if we have a Transfer Price and Supply Chain Assumption record for a material, the Transfer Price wins.
    @isTest static void testTPSCACost() {
        
    }
    
    @isTest static void testUoMConversion() {
        // Setup material
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create LB -> KG conversion
        Alternate_Unit_of_Measure__c lbKg = new Alternate_Unit_of_Measure__c(BUn__c='LB', AUn__c='KG', X__c=2.2, Y__c=1.0, Material_Item__c=item.Id);
        insert lbKg;
        
        // Create TON -> LB conversion
        Alternate_Unit_of_Measure__c tonLb = new Alternate_Unit_of_Measure__c(BUn__c='TON', AUn__c='LB', X__c=1.0, Y__c=2000.0, Material_Item__c=item.Id);
        insert tonLb;
        
        System.assertEquals(2.2, MaterialMaster.convertUoM(item.Id, 'LB', 'KG'));
        System.assertEquals(.45454545454545453, MaterialMaster.convertUoM(item.Id, 'KG','LB'));
        System.assertEquals(2000, MaterialMaster.convertUoM(item.Id, 'LB', 'TON'));
        System.assertEquals(.0005, MaterialMaster.convertUoM(item.Id, 'TON', 'LB'));
    }
    
    @isTest static void testUoMConversionSite() {
        // Setup material
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create LB -> KG conversion
        Alternate_Unit_of_Measure__c lbKg = new Alternate_Unit_of_Measure__c(BUn__c='LB', AUn__c='KG', X__c=2.2, Y__c=1.0, Material_Item__c=item.Id);
        insert lbKg;
        
        // Create TON -> LB conversion
        Alternate_Unit_of_Measure__c tonLb = new Alternate_Unit_of_Measure__c(BUn__c='TON', AUn__c='LB', X__c=1.0, Y__c=2000.0, Material_Item__c=item.Id);
        insert tonLb;
        
        // Create EA -> LB conversion
        Alternate_Unit_of_Measure__c eaLb = new Alternate_Unit_of_Measure__c(BUn__c='EA', AUn__c='LB', X__c=1.0, Y__c=10.0, Material_Item__c=item.Id);
        insert eaLb;
        
        System.assertEquals(2.2, MaterialMaster.convertUoM(item.Id, receivingSite.Id, 'KG'));
        System.assertEquals(2000, MaterialMaster.convertUoM(item.Id, receivingSite.Id, 'TON'));
        System.assertEquals(10, MaterialMaster.convertUoM(item.Id, receivingSite.Id, 'EA'));
    }
    
    @isTest static void testUoMPerConversion() {
        // Setup material
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create LB -> KG conversion
        Alternate_Unit_of_Measure__c lbKg = new Alternate_Unit_of_Measure__c(BUn__c='LB', AUn__c='KG', X__c=2.2, Y__c=1.0, Material_Item__c=item.Id);
        insert lbKg;
        
        System.assertEquals(0.22000000000000003, MaterialMaster.convertPerAndUoM(item.Id, 1, 'LB', 10, 'KG'));
        System.assertEquals(4.545454545454545, MaterialMaster.convertPerAndUoM(item.Id, 10, 'KG', 1,'LB'));
    }
    
    @isTest static void testUoMPerConversionSite() {
        // Setup material
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        Material_Item__c item = TestUtils.createItemWitCost(receivingSite);
        
        // Create LB -> KG conversion
        Alternate_Unit_of_Measure__c lbKg = new Alternate_Unit_of_Measure__c(BUn__c='LB', AUn__c='KG', X__c=2.2, Y__c=1.0, Material_Item__c=item.Id);
        insert lbKg;
        
        
        System.assertEquals(0.22000000000000003, MaterialMaster.convertPerAndUoM(item.Id, 1, receivingSite.Id, 10, 'KG'));
        System.assertEquals(22.0, MaterialMaster.convertPerAndUoM(item.Id, 10, receivingSite.Id, 1,'KG'));
    }
    
    @isTest static void testMultipleMaterialCost() {
        
        // Setup site
        Sales_Site__c originSite = TestUtils.createPlant('Origin Site');
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        Sales_Site__c companySite = TestUtils.createPlant('ATestCompany');
        originSite.Company_Site__c = companySite.Id;
        update originSite;
        receivingSite.Company_Site__c = companySite.Id;
        update receivingSite;
        Sales_Site__c extraSite = TestUtils.createPlant('Extra Site');
        extraSite.Company_Site__c = companySite.Id;
        update extraSite;
        // Setup material
        Material_Item__c item01 = TestUtils.createItemWitCost(extraSite);
        Material_Item__c item02 = TestUtils.createItemWitCost(extraSite);
        Material_Item__c item03 = TestUtils.createItemWitCost(extraSite);
        Material_Item__c item1 = TestUtils.createItemWitCost(receivingSite);
        Material_Item__c item2 = TestUtils.createItemWitCost(receivingSite);
        Material_Item__c item3 = TestUtils.createItemWitCost(receivingSite);
        List<Material_Item__c> items = new List<Material_Item__c>{item01, item02, item03, item1, item2, item3};
        
        // Create SCA
        Id rtId1 = [Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Transfer_Price'].Id;
        Supply_Chain_Assumption__c sca11 = new Supply_Chain_Assumption__c(Material_Item__c=item01.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Variable_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca12 = new Supply_Chain_Assumption__c(Material_Item__c=item02.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Fixed_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca13 = new Supply_Chain_Assumption__c(Material_Item__c=item03.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Freight_Cost__c=10.00d, RecordTypeId = rtId1);
        
        Supply_Chain_Assumption__c sca21 = new Supply_Chain_Assumption__c(Material_Item__c=item1.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Variable_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca22 = new Supply_Chain_Assumption__c(Material_Item__c=item2.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Fixed_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca23 = new Supply_Chain_Assumption__c(Material_Item__c=item3.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Freight_Cost__c=10.00d, RecordTypeId = rtId1);
        
        insert new List<Supply_Chain_Assumption__c> {sca11, sca12, sca13, sca21, sca22, sca23};
        
        MaterialMaster.calculateCost(items, receivingSite.Id, originSite.Id, companySite.Id, false, items);
        
    
    }
    
    @isTest static void testMultipleMaterialCost2() {
        // Setup site
        Sales_Site__c originSite = TestUtils.createPlant('Origin Site');
        Sales_Site__c receivingSite = TestUtils.createPlant('Sales Site');
        Sales_Site__c companySite = TestUtils.createPlant('ATestCompany');
        originSite.Company_Site__c = companySite.Id;
        update originSite;
        receivingSite.Company_Site__c = companySite.Id;
        update receivingSite;
        Sales_Site__c extraSite = TestUtils.createPlant('Extra Site');
        extraSite.Company_Site__c = companySite.Id;
        update extraSite;
        // Setup material
        Material_Item__c item01 = TestUtils.createItemWitCost(extraSite);
        Material_Item__c item02 = TestUtils.createItemWitCost(extraSite);
        Material_Item__c item03 = TestUtils.createItemWitCost(extraSite);
        Material_Item__c item1 = TestUtils.createItemWitCost(receivingSite);
        Material_Item__c item2 = TestUtils.createItemWitCost(receivingSite);
        Material_Item__c item3 = TestUtils.createItemWitCost(receivingSite);
        List<Material_Item__c> items = new List<Material_Item__c>{item01, item02, item03, item1, item2, item3};
        
        // Create SCA
        Id rtId1 = [Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Supply_Cost_Allocation'].Id;
        Supply_Chain_Assumption__c sca11 = new Supply_Chain_Assumption__c(Material_Item__c=item01.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Variable_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca12 = new Supply_Chain_Assumption__c(Material_Item__c=item02.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Fixed_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca13 = new Supply_Chain_Assumption__c(Material_Item__c=item03.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Freight_Cost__c=10.00d, RecordTypeId = rtId1);
        
        Supply_Chain_Assumption__c sca21 = new Supply_Chain_Assumption__c(Material_Item__c=item1.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Variable_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca22 = new Supply_Chain_Assumption__c(Material_Item__c=item2.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Fixed_Conversion_Cost__c=10.00d, RecordTypeId = rtId1);
        Supply_Chain_Assumption__c sca23 = new Supply_Chain_Assumption__c(Material_Item__c=item3.Id, Source_Sales_Site__c=originSite.Id, Receiving_Sales_Site__c=receivingSite.Id, Freight_Cost__c=10.00d, RecordTypeId = rtId1);
        
        insert new List<Supply_Chain_Assumption__c> {sca11, sca12, sca13, sca21, sca22, sca23};
        
        MaterialMaster.calculateCost(items, receivingSite.Id, originSite.Id, companySite.Id, false, items);
        
    
    }
    
    @isTest static void testCalculateCostAveraging() {
        Test.startTest();
        List<Sales_Site__c> siteList = TestUtils.createSalesSiteHierarchy('TC953', 'TR953', 'TS953');
        List<Id> siteIds = new List<Id>();
        siteIds.add(siteList.get(2).Id);
        // Setup material
        Material_Item__c item1 = TestUtils.createItemWitCost(siteList.get(2));
        Material_Item__c item2 = TestUtils.createItemWitCost(siteList.get(2));
        Material_Item__c item3 = TestUtils.createItemWitCost(siteList.get(2));
        List<Id> materialIds = new List<Id>();
        materialIds.add(item1.Id);
        materialIds.add(item2.Id);
        materialIds.add(item3.Id);
        Test.stopTest();
        
        System.assertEquals(3, MaterialMaster.calculateCost(materialIds, siteIds).size());
    }
    
    @isTest static void testAverageMaterialCost() {
        Sales_Site__c companySite = TestUtils.createPlant('CompanySite0');
        Sales_Site__c salesSite1 = TestUtils.createPlant('Sales Site1');
        Sales_Site__c salesSite2 = TestUtils.createPlant('Sales Site2');
        Sales_Site__c salesSite3 = TestUtils.createPlant('Sales Site3');
        Sales_Site__c salesSite4 = TestUtils.createPlant('Sales Site4');
        salesSite1.Company_Site__c = companySite.Id;
        salesSite2.Company_Site__c = companySite.Id;
        salesSite3.Company_Site__c = companySite.Id;
        salesSite4.Company_Site__c = companySite.Id;
        update salesSite1;
        update salesSite2;
        update salesSite3;
        update salesSite4;
        Material_Item__c item = TestUtils.createMaterialItem('Test', 'TEST', '', null);
        TestUtils.createMaterialCost(item, salesSite1, 5.00d, '');
        TestUtils.createMaterialCost(item, salesSite2, 7.75d, '');
        TestUtils.createMaterialCost(item, salesSite3, 6.50d, '');
        
        //CostData data = MaterialMaster.calculateCost(item.Id, companySite.Id);
        System.assertEquals(MaterialMaster.calculateCost(item.Id, companySite.Id).cost, 6.42);
        System.assertEquals(MaterialMaster.calculateCost(item.Id, companySite.Id).seeThroughCost, 6.42);
    }
}