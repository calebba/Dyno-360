public class DCJobDetailControllerExtension {
    
   public Double totalCostDisplay {get; set;}
   public String selectedMaterial {get;  set;}
   public list<SelectOption> materialOptions {get; set;}
   private ApexPages.StandardController std;
   
   //public String unitOfMeasureDisplay {get; set;}
   
  Public DynoConsult_Job_Detail__c dcJobDetail;
  Public DynoConsult_Job_Detail__c dcjd;


    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public DCJobDetailControllerExtension(ApexPages.StandardController stdController) {
    
        std = stdController;
        dcJobDetail = (DynoConsult_Job_Detail__c)stdController.getRecord();
        if (dcJobDetail == null) {
            dcJobDetail  = new DynoConsult_Job_Detail__c();
            totalCostDisplay = 0;
          }else{
           
           totalCostDisplay = dcJobDetail.Total_Cost__c;
           //totalDiscountCostDisplay = dcJobDetail.Discount_Cost__c;
        }
        
        dcJobDetail.CurrencyIsoCode = 'USD';
        
        //Material_Item__c[] materials = [SELECT Id, Name FROM Material_Item__c WHERE Material_Code__c LIKE 'TS%'];
        Material_Item__c[] materials = [SELECT Id, Name FROM Material_Item__c WHERE DynoConsult_Material__c = True ORDER BY NAME ASC];
        
         list<SelectOption> findMaterials = new list<SelectOption>();
         
         if( dcJobDetail.Material__c == NULL){
            findMaterials.add( new SelectOption('', '--- Please Select ---'));
        }
         
         for ( Material_Item__c mat: materials){
             findMaterials.add( new SelectOption(mat.Id, mat.Name));
         
         }
         
        // for (Integer i = 0; i < 10; i++) {
          //  findMaterials.add( new SelectOption('Material ' + i, 'Material ' + i));
         //  }
         
         materialOptions = findMaterials;
        if( dcJobDetail.Material__c <> NULL){
            selectedMaterial = dcJobDetail.Material__c;
        }     
         
    }

    
    public Void MaterialSelected() {
    
    Material_Item__c material;
        Pricing_Rule__c pricingRule;
    
        dcJobDetail.Material__c = selectedMaterial;
        material = [SELECT Id, Base_Unit_of_Measue__c, Material_Description__c from Material_Item__c Where Id = :dcJobDetail.Material__c limit 1];
    
        Pricing_Rule__c[] pricingRules = [SELECT Id, Target_Price__c FROM Pricing_Rule__c WHERE Material_Item__c = :dcJobDetail.Material__c AND Pricing_Sales_Office__c = 'DynoConsult' limit 1];
        if (pricingRules.size() > 0){
            dcJobDetail.UOM__c = material.Base_Unit_of_Measue__c;
            dcJobDetail.Unit_Cost__c = pricingRules[0].Target_Price__c;
            
        }else{
            dcJobDetail.UOM__c = material.Base_Unit_of_Measue__c;
            dcJobDetail.Unit_Cost__c = 0;
        }

        CalculateTotal();
    }
    
   
    
    public Void CalculateTotal() {
        //this mimics the computed fields calculation
        
        //if (!((dcJobDetail.Material__c == NULL) || (dcJobDetail.Units__c == NULL)||(dcJobDetail.Discount__c == NULL)||(dcJobDetail.Unit_Cost__c == NULL))) 
        if (!((dcJobDetail.Material__c == NULL) || (dcJobDetail.Units__c == NULL)||(dcJobDetail.Unit_Cost__c == NULL))) {
            totalCostDisplay = dcJobDetail.Unit_Cost__c * dcJobDetail.Units__c;
            //totalDiscountCostDisplay = (dcJobDetail.Unit_Cost__c * dcJobDetail.Units__c) * (1-(dcJobDetail.Discount__c/100));
        }
        
    }
    
    public PageReference newSave() {
                  
        try {
            // Save the current sObject
            std.save();
            PageReference parentPage = new PageReference('/' + dcJobDetail.DynoConsult_Job__c);
            return parentPage;
        } catch(Exception e) {
            // Don't redirect if something goes wrong. May be a validation or trigger issue on save.
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    
    
}