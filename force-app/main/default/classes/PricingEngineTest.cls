@isTest
public class PricingEngineTest {
	
   @isTest static void testSimplePricingRule() {
        Account cust = TestUtils.createAccount('TEST', null);
        Sales_Site__c company = TestUtils.createSalesSite('Company', null, null);
        Sales_Site__c region = TestUtils.createSalesSite('Region', company.Id, null);
        Sales_Site__c site = TestUtils.createSalesSite('Site', company.Id, region.Id);
        Material_Item__c material = TestUtils.createItemWitCost(site,5.00d);
       	Material_Item__c material1 = TestUtils.createItemWitCost(site,6.00d);
       	Material_Item__c material2 = TestUtils.createItemWitCost(site,7.00d);
       	Material_Item__c material3 = TestUtils.createItemWitCost(site,8.00d);
       	//Formula__c sformula = TestUtils.createFormula('Test', material.Id, 2.00, 1.00);
       	//Formula_Mapping__c formula = TestUtils.createFormulaMapping(sformula.Id, cust.Id, site.Id, 1, 1, 'EA');
        
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site.Id, Region_Site__c=region.Id,Pricing_Sales_Office__c = 'WC-WESTERN CANADA', Material_Item__c=material.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='02 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.34, Target_Price__c=23.45);
       //PricingEngine pepa = new PricingEngine.PricingData();
       //
       	List<Pricing_Rule__c> insertedrule = [Select Id,Material_Item__c,Receiving_Sales_Site__c,Floor_Price__c,Target_Price__c,Per__c,Company_Code__c,Account__c,Region_Site__c,UoM__c,CurrencyIsoCode,Price_Valid_From__c,Price_Valid_To__c,Customer_Group__c from Pricing_Rule__c where Uom__c='EA'];

        PricingEngine.PricingData data = PricingEngine.getPricingData(cust.Id, site.Id, site.Id, material.Id, System.today(), System.today(), company.Id, '02 Retail', cust.Pricing_Region__c,'WC-WESTERN CANADA');
       	PricingEngine.getPricingData (insertedrule);
       	PricingEngine.getPricingData (company.Id,cust.Id,site.Id,material.Id,region.Id,'02 Retail');
       	PricingEngine.getFormulaPricingData (cust.Id,site.Id,site.Id);
       	
        System.assertEquals(12.34, data.floorPrice);
        System.assertEquals(23.45, data.targetPrice);
        System.assertEquals(1, data.per);
        System.assertEquals('EA', data.uom);
        System.assertEquals(5, data.costData.cost);
        System.assertEquals(5, data.costData.seeThroughCost);
    }
    
    @isTest static void testSimplePricingRule2() {
        Account cust = TestUtils.createAccount('TEST', null);
        Account cust1 = TestUtils.createAccount('TEST1', null);
        Sales_Site__c company = TestUtils.createSalesSite('Company', null, null);
        Sales_Site__c region = TestUtils.createSalesSite('Region', company.Id, null);
        Sales_Site__c site = TestUtils.createSalesSite('Site', company.Id, region.Id);
        Material_Item__c material = TestUtils.createItemWitCost(site,5.00d);
        
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust1.id,Pricing_Sales_Office__c = 'WC-WESTERN CANADA',Receiving_Sales_Site__c=site.Id, Region_Site__c=region.Id, Material_Item__c=material.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='02 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.34, Target_Price__c=23.45);
       //PricingEngine pepa = new PricingEngine.PricingData();

        PricingEngine.PricingData data = PricingEngine.getPricingData(cust.Id, site.Id, site.Id, material.Id, System.today(), System.today(), company.Id, '02 Retail', cust1.Pricing_Region__c,'WC-WESTERN CANADA');
        System.assertEquals(12.34, data.floorPrice);
        System.assertEquals(23.45, data.targetPrice);
        System.assertEquals(1, data.per);
        System.assertEquals('EA', data.uom);
        System.assertEquals(5, data.costData.cost);
        System.assertEquals(5, data.costData.seeThroughCost);
    }
    
    
    @isTest static void testGetListOfPricingData() {
        Account cust = TestUtils.createAccount('TEST', null);
        Sales_Site__c company = TestUtils.createSalesSite('Company', null, null);
        Sales_Site__c region = TestUtils.createSalesSite('Region', company.Id, null);
        Sales_Site__c site1 = TestUtils.createSalesSite('Site', company.Id, region.Id);
        Sales_Site__c site2 = TestUtils.createSalesSite('Site', company.Id, region.Id);
        Material_Item__c material1 = TestUtils.createItemWitCost(site1,5.00d);
        material1.PHL1__c ='PL054';
        material1.PHL2__c ='PL055';
        material1.PHL3__c ='PL056';
        update material1;
        Material_Item__c material2 = TestUtils.createItemWitCost(site1,5.00d);
        material2.PHL1__c ='PL054';
        material2.PHL2__c ='PL055';
        material2.PHL3__c ='PL056';
        update material2;
        Material_Item__c material3 = TestUtils.createItemWitCost(site1,5.00d);
        material3.PHL1__c ='PL054';
        material3.PHL2__c ='PL055';
        material3.PHL3__c ='PL056';
        update material3;
        Material_Item__c material4 = TestUtils.createItemWitCost(site1,5.00d);
        material4.PHL1__c ='PL054';
        material4.PHL2__c ='PL055';
        material4.PHL3__c ='PL056';
        update material4;
        Material_Item__c material5 = TestUtils.createItemWitCost(site2,5.00d);
        material5.PHL1__c ='PL054';
        material5.PHL2__c ='PL055';
        material5.PHL3__c ='PL056';
        update material5;
        
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material1.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.34, Target_Price__c=23.45);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material2.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.35, Target_Price__c=23.46);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material3.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.36, Target_Price__c=23.47);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material4.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.37, Target_Price__c=23.48);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material5.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.38, Target_Price__c=23.49);
        
        List<PricingEngine.PricingData> data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', false, System.today(), System.today(), company.Id, true, '01 Retail', null, '--None--', '--None--', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
        Formula__c formulatest = TestUtils.createFormula('Test1', material1.Id, 1261992, 1261992);
        Formula_Mapping__c formmap = TestUtils.createFormulaMapping(formulatest.Id, cust.Id, site1.Id, site1.Id, 1, 'EA') ;
        PricingEngine.getFormulaPricingData (cust.Id,site1.Id,formmap.Sales_Site__c,material1.Id);
        System.assertEquals(4, data.size());
        for(PricingEngine.PricingData pd : data) {
            if (pd.materialId == material1.Id) {
                System.assertEquals(12.34, pd.floorPrice);
                System.assertEquals(23.45, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material2.Id) {
                System.assertEquals(12.35, pd.floorPrice);
                System.assertEquals(23.46, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material3.Id) {
                System.assertEquals(12.36, pd.floorPrice);
                System.assertEquals(23.47, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material4.Id) {
                System.assertEquals(12.37, pd.floorPrice);
                System.assertEquals(23.48, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }           
        }
         data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', true, System.today(), System.today(), company.Id, true, '01 Retail', null, 'PL055', 'PL056', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
         data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', true, System.today(), System.today(), company.Id, true, '01 Retail', null, 'PL055', '--None--', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
        
        data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', true, System.today(), System.today(), company.Id, true, '01 Retail', null, '--None--', '--None--', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
        System.assertEquals(5, data.size());
        for(PricingEngine.PricingData pd : data) {
            if (pd.materialId == material1.Id) {
                System.assertEquals(12.34, pd.floorPrice);
                System.assertEquals(23.45, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material2.Id) {
                System.assertEquals(12.35, pd.floorPrice);
                System.assertEquals(23.46, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material3.Id) {
                System.assertEquals(12.36, pd.floorPrice);
                System.assertEquals(23.47, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material4.Id) {
                System.assertEquals(12.37, pd.floorPrice);
                System.assertEquals(23.48, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material5.Id) {
                System.assertEquals(12.38, pd.floorPrice);
                System.assertEquals(23.49, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }           
        }
    }
    
    
    @isTest static void testGetListOfPricingData2() {
        Account cust = TestUtils.createAccount('TEST', null);
        Sales_Site__c company = TestUtils.createSalesSite('Company', null, null);
        Sales_Site__c region = TestUtils.createSalesSite('Region', company.Id, null);
        Sales_Site__c site1 = TestUtils.createSalesSite('Site', company.Id, region.Id);
        Sales_Site__c site2 = TestUtils.createSalesSite('Site', company.Id, region.Id);
        Material_Item__c material1 = TestUtils.createItemWitCost(site1,5.00d);
        material1.PHL1__c ='PL054';
        material1.PHL2__c ='PL055';
        material1.PHL3__c ='PL056';
        update material1;
        Material_Item__c material2 = TestUtils.createItemWitCost(site1,5.00d);
        material2.PHL1__c ='PL054';
        material2.PHL2__c ='PL055';
        material2.PHL3__c ='PL056';
        update material2;
        Material_Item__c material3 = TestUtils.createItemWitCost(site1,5.00d);
        material3.PHL1__c ='PL054';
        material3.PHL2__c ='PL055';
        material3.PHL3__c ='PL056';
        update material3;
        Material_Item__c material4 = TestUtils.createItemWitCost(site1,5.00d);
        material4.PHL1__c ='PL054';
        material4.PHL2__c ='PL055';
        material4.PHL3__c ='PL056';
        update material4;
        Material_Item__c material5 = TestUtils.createItemWitCost(site2,5.00d);
        material5.PHL1__c ='PL054';
        material5.PHL2__c ='PL055';
        material5.PHL3__c ='PL056';
        update material5;
        
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material1.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.34, Target_Price__c=23.45);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material2.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.35, Target_Price__c=23.46);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material3.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.36, Target_Price__c=23.47);
        insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material4.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.37, Target_Price__c=23.48);
        //insert new Pricing_Rule__c(Company_Code__c=company.Id,Account__c=cust.Id, Receiving_Sales_Site__c=site1.Id, Region_Site__c=region.Id, Material_Item__c=material5.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 Retail', Per__c=1, Uom__c='EA', Floor_Price__c=12.38, Target_Price__c=23.49);
        
        List<PricingEngine.PricingData> data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', false, System.today(), System.today(), company.Id, true, '01 Retail', null, '--None--', '--None--', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
        Formula__c formulatest = TestUtils.createFormula('Test1', material1.Id, 1261992, 1261992);
        Formula_Mapping__c formmap = TestUtils.createFormulaMapping(formulatest.Id, cust.Id, site1.Id, site1.Id, 1, 'EA') ;
        PricingEngine.getFormulaPricingData (cust.Id,site1.Id,formmap.Sales_Site__c,material1.Id);
        System.assertEquals(4, data.size());
        for(PricingEngine.PricingData pd : data) {
            if (pd.materialId == material1.Id) {
                System.assertEquals(12.34, pd.floorPrice);
                System.assertEquals(23.45, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material2.Id) {
                System.assertEquals(12.35, pd.floorPrice);
                System.assertEquals(23.46, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material3.Id) {
                System.assertEquals(12.36, pd.floorPrice);
                System.assertEquals(23.47, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material4.Id) {
                System.assertEquals(12.37, pd.floorPrice);
                System.assertEquals(23.48, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }           
        }
         data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', true, System.today(), System.today(), company.Id, true, '01 Retail', null, 'PL055', 'PL056', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
         data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', true, System.today(), System.today(), company.Id, true, '01 Retail', null, 'PL055', '--None--', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
        
        Test.startTest();
        data = PricingEngine.getPricingData(cust.Id, site1.Id, 'PL054', true, System.today(), System.today(), company.Id, true, '01 Retail', null, '--None--', '--None--', new CurrencyData(' ', 1000),cust.Pricing_Region__c,'WC-WESTERN CANADA');
        System.assertEquals(4, data.size());
        for(PricingEngine.PricingData pd : data) {
            if (pd.materialId == material1.Id) {
                System.assertEquals(12.34, pd.floorPrice);
                System.assertEquals(23.45, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material2.Id) {
                System.assertEquals(12.35, pd.floorPrice);
                System.assertEquals(23.46, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material3.Id) {
                System.assertEquals(12.36, pd.floorPrice);
                System.assertEquals(23.47, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material4.Id) {
                System.assertEquals(12.37, pd.floorPrice);
                System.assertEquals(23.48, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }
            if (pd.materialId == material5.Id) {
                System.assertEquals(12.38, pd.floorPrice);
                System.assertEquals(23.49, pd.targetPrice);
                System.assertEquals(5.00, pd.costData.cost);
            }           
        }
      Test.stoptest();
    }
}