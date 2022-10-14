@isTest
public class SalesPipelineVolumeControllerTest {
    
        public static Account createAccount(Integer TotalIspeRevenue,Integer TotalGrossMargin,Integer TotalANProducts,
                                            String abilityToDiff,String proabilitySuccess,String compReaction,String segment,Integer totalCapEx,Integer people){
            Account accountObj = new Account();
            accountObj.Name = 'test Account';
            accountObj.Industry = '19 Stone';
            accountObj.Ability_to_Diff__c = abilityToDiff;
            accountObj.Probability_of_Succ__c = proabilitySuccess;
            accountObj.Comp_Reaction__c = compReaction;
            accountObj.Segment_Priority__c = segment;
            accountObj.Include_in_National_Pipeline_Output__c = true;
            accountObj.Total_Child_ISPE_Revenue__c = TotalIspeRevenue;
            accountObj.Account_ISPE_Revenue__c = 367;
            accountObj.Total_Child_Gross_Margin__c = TotalGrossMargin;
            accountObj.Account_Gross_Margin__c = 134;
            accountObj.Total_Child_AN_Products__c = TotalANProducts;
            accountObj.Account_AN_Products__c = 235;
            accountObj.Total_CapEx__c = totalCapEx;
            accountObj.ShippingCountry = 'US';
            accountObj.People__c = people;

            insert accountObj;
            return accountObj;
        } 
    
    	public static Account createChildAccount(Integer TotalIspeRevenue,Integer TotalGrossMargin,Integer TotalANProducts,
                                            String abilityToDiff,String proabilitySuccess,String compReaction,String segment,Integer totalCapEx,Integer people, Id parentAccount){
            Account accountObj = new Account();
            accountObj.Name = 'test Account';
            accountObj.Industry = '19 Stone';
            accountObj.Ability_to_Diff__c = abilityToDiff;
            accountObj.Probability_of_Succ__c = proabilitySuccess;
            accountObj.Comp_Reaction__c = compReaction;
            accountObj.Segment_Priority__c = segment;
            accountObj.Include_in_National_Pipeline_Output__c = true;
            accountObj.Total_Child_ISPE_Revenue__c = TotalIspeRevenue;
            accountObj.Account_ISPE_Revenue__c = 367;
            accountObj.Total_Child_Gross_Margin__c = TotalGrossMargin;
            accountObj.Account_Gross_Margin__c = 134;
            accountObj.Total_Child_AN_Products__c = TotalANProducts;
            accountObj.Account_AN_Products__c = 235;
            accountObj.Total_CapEx__c = totalCapEx;
            accountObj.ShippingCountry = 'US';
            AccountObj.ParentId = parentAccount ;                           
            accountObj.People__c = people;

            insert accountObj;
            return accountObj;
        } 
    
    public static Pipeline_Volume__c createPipelineVolume(Id acctId) {
        
        Pipeline_Volume__c pv = new Pipeline_Volume__c();
        pv.Account__c = acctId;
        pv.AN_Prill_Volume__c = 100;
        pv.AN_Prill_GM__c = 100;
        pv.AN_Prill_Incumbent__c = 'Dyno Nobel';
        pv.AN_Prill_Revenue__c = 100;
        pv.ANFO_Volume__c = 60;
        pv.ANFO_GM__c = 100;
        pv.ANFO_Incumbent__c = 'Dyno Nobel';
        pv.ANFO_Revenue__c = 100;
        pv.Bulk_Emulsion_Volume__c = 900;
        pv.Bulk_Emulsion_GM__c = 100;
        pv.Bulk_Emulsion_Incumbent__c = 'Dyno Nobel';
        pv.Bulk_Emulsion_Revenue__c = 100;
        pv.Small_Packaged_Volume__c = 15;
        pv.Small_Packaged_GM__c = 100;
        pv.Small_Packaged_Incumbent__c = 'Dyno Nobel';
        pv.Small_Packaged_Revenue__c = 100;
        pv.Large_Packaged_Volume__c = 1500;
        pv.Large_Packaged_GM__c = 100;
        pv.Large_Packaged_Incumbent__c = 'Dyno Nobel';
        pv.Large_Packaged_Revenue__c = 100;
        pv.Dynamite_Volume__c = 1000;
        pv.Dynamite_GM__c = 100;
        pv.Dynamite_Incumbent__c = 'Dyno Nobel';
        pv.Dynamite_Revenue__c = 100;
        pv.Boosters_Volume__c = 67;
        pv.Boosters_GM__c = 100;
        pv.Boosters_Incumbent__c = 'Dyno Nobel';
        pv.Boosters_Revenue__c = 100;
        pv.Cord_Volume__c = 88;
        pv.Cord_GM__c = 100;
        pv.Cord_Incumbent__c = 'Dyno Nobel';
        pv.Cord_Revenue__c = 100;
        pv.Nonelectrics_Volume__c = 1900;
        pv.Nonelectrics_GM__c = 100;
        pv.Nonelectrics_Incumbent__c = 'Dyno Nobel';
        pv.Nonelectrics_Revenue__c = 100;
        pv.Electronics_Volume__c = 57;
        pv.Electronics_GM__c = 100;
        pv.Electronics_Incumbent__c = 'Dyno Nobel';
        pv.Electronics_Revenue__c = 100;
        pv.Service_Volume__c = 200;
        pv.Service_GM__c = 100;
        pv.Service_Incumbent__c = 'Dyno Nobel';
        pv.Service_Revenue__c = 100;
        pv.Other_Volume__c = 1;
        pv.Other_GM__c = 100;
        pv.Other_Incumbent__c = 'Dyno Nobel';
        pv.Other_Revenue__c = 100;
          
        
        insert pv;
        return pv;
        
    }

        public static testMethod void testInitializeWithPipeline() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            Test.stopTest();

        }
    
        public static testMethod void testInitializeWithoutPipeline() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            Test.stopTest();

        }

        public static testMethod void testGetPipeline() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            List<SelectOption> options = salesPipelineObj.getpipeline();
            Test.stopTest();

        }
    
         public static testMethod void testSaveRecord() {

            Test.startTest();
            Account parentAcocunt = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Account accountObj = createChildAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15, parentAcocunt.Id);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            salesPipelineObj.saveRecord();
            Test.stopTest();

        }       
        
         public static testMethod void testSaveNewRecord() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            salesPipelineObj.saveNewRecord();
            Test.stopTest();

        }       
        
         public static testMethod void testDisplayPipelineVolume() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            salesPipelineObj.displayPipelineVolume();
            Test.stopTest();

        }       
        
         public static testMethod void testDeletePipelineVolume() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            salesPipelineObj.deletePipelineVolume();
            Test.stopTest();

        }       
        
         public static testMethod void testUpdateCurrentSalesPipelineVloume() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            PageReference pageRef = salesPipelineObj.updateCurrentSalesPipelineVloume();
            Test.stopTest();

        }       
        
         public static testMethod void testCancelRecord() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            salesPipelineObj.cancelRecord();
            Test.stopTest();

        }  
        
         public static testMethod void testShowDetailEntry() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            salesPipelineObj.showDetailEntry();
            Test.stopTest();

        }  
        
         public static testMethod void testGetTotalRevenue() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            string rev = salesPipelineObj.getTotalrevenue(pv);
            Test.stopTest();

        }      
    
         public static testMethod void testGetTotalMargin() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            string rev = salesPipelineObj.getTotalMargin(pv);
            Test.stopTest();

        }      
    
         public static testMethod void testValidateRecord() {

            Test.startTest();
            Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
            Pipeline_Volume__c pv = createPipelineVolume(accountObj.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
            SalesPipelineVolumeController salesPipelineObj = new SalesPipelineVolumeController(sc);
            boolean isValid = salesPipelineObj.validateRecord(pv);
            Test.stopTest();

        }      
    
    
}