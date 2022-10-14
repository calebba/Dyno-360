public with sharing class QuoteUtil {
    public static Quote__c queryForQuoteAndChildRecords(String activeQuoteId) {
        return [Select q.Version_Number__c, q.Opportunity__r.Account.SAP_Account_Number__c,q.Opportunity__r.Account.ShippingCountry, q.AccountReference__c, Opportunity__r.Account.Language__c, q.Opportunity__r.Account.Name, q.Opportunity__r.Account.BillingStreet, q.Opportunity__r.Account.Type, q.Total_Direct_Hours__c, q.Total_Allocated_Indirect_Costs__c, q.Target_Win__c, 
            q.Take_or_Pay_Contract__c, q.Shot_Service_Hours__c, q.Opportunity__r.Account.BillingCity,
            q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.Name, q.Risk_Assesment__c, q.Quote_Valid_To__c, q.Quote_Valid_From__c, q.Opportunity__r.Account.BillingState,
            q.Quote_Description__c, q.Quote_Amount__c, q.Quote_Acceptance_Period__c, q.Quote_Accepted_By_Customer__c, 
            q.Price_Valid_To__c, q.Price_Valid_From__c, q.Price_Adjustment__c, q.Potential_Cash_Discount__c, q.Opportunity__r.Account.BillingPostalCode,
            q.Payment_Terms__c, q.Opportunity__c, q.On__c, q.On_Contract__c, q.Name, q.Opportunity__r.Account.BillingCountry,
            q.LastModifiedDate, q.LastModifiedById, q.LastActivityDate, q.Is_Additional_Capital_Required__c, q.Opportunity__r.Account.RecordTypeId,
            q.Id, q.Have_You_Spoken_to_Operations__c, q.Opportunity__r.RecordTypeId,
            q.Delivery_Hours__c, q.CurrencyIsoCode, q.Alternate_Address_Detail__c, q.Country__c,
            q.Caps_On_Escalation__c, q.Cap_Details__c, q.Sales_Organization_Primary__r.Region__c,
            q.Are_Additional_People_Required__c, q.Approval_Status__c, q.Active_Quote__c, q.AN_Formula_Pricing__c, Reason_Comments__c, q.COGS__c, q.COGS_See_Through__c,
            (Select Name, Quote__c, Actual_Price__c, Available_Credit_Limit__c, Avg_Sell_Price__c, Bundled_Flag__c, Substitution_Comments__c, Formula_Text__c,
            Bundled_Percent__c, Calculated_Monthly_Purchases__c, Credit_Limit__c, Description__c, Floor_Price__c, Formula_Flag__c, Substitution__c,
            Material_Item__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Name, Monthly_Purchases__c, Notify_Credit__c, Per__c, Percent__c, Sales_Site__c, Price_Valid_From__c, 
            Price_Valid_To__c,  Quantity__c, Total_Price__c, Reason__c, Source_Sales_Site__c, Target_Price__c, UoM__c, Country__c, Adder_Notes__c From Quote_Line_Items__r) 
        From Quote__c q where Id =: activeQuoteId];
 
     }
    
    public static List<Quote_Line_Item__c> queryForChildRecordsByQuote(String quoteId) {
        return [Select q.Total_Cost__c, q.Volume_Based__c, q.Quote__r.AccountReference__c, q.UoM__c, q.Target_Price__c, q.SystemModstamp, q.Source_Sales_Site__c, q.Sales_Site__c, q.Rounding_Method__c, 
        q.Reason__c, q.Quote__c, q.Quantity__c, q.Pricing_Rule__c, q.Price_Valid_To__c, q.Price_Valid_From__c, q.Percent__c, q.Per__c, q.Is_Bundled__c,
        q.Notify_Credit__c, q.Name, q.Monthly_Purchases__c, q.Material_Item__r.PHL1__c, q.Material_Item__r.Name, q.Material_Item__c, q.MFN_Flag__c, q.LastModifiedDate, q.LastModifiedById, q.Formula_Text__c,
        q.LastActivityDate, q.IsDeleted, q.IsBelowFloorPrice__c, q.Id, q.Formula_Flag__c, q.Floor_Price__c, q.Discount_Surcharge__c, q.Extended__c,
        q.Discount_Surcharge_Terms__c, q.Description__c, q.Credit_Limit__c, q.CreatedDate, q.CreatedById, q.Cost__c, q.Country__c, q.Substitution_Comments__c,
        q.Calculated_Monthly_Purchases__c, q.Bundled_Percent__c, q.Bundled_Flag__c, q.Avg_Sell_Price__c, q.Available_Credit_Limit__c, q.Adder_Notes__c, q.Substitution__c, 
        q.Actual_Price__c, q.AUn__c, q.Total_Price__c, q.Material_Item__r.Material_Code__c, q.Material_Item__r.Material_Description__c, q.Material_Item__r.Product_Hierarchy__c, Quote__r.Opportunity__r.AccountId From Quote_Line_Item__c q where Quote__c =: quoteId order by Material_Item__r.PHL1__c, Material_Item__r.Material_Description__c];
    }
    
    public static List<Quote__c> queryForQuoteAndChildRecordsByOppyAndActive(List<Id> opportunityIds) {
        return [Select q.Version_Number__c, q.Total_Direct_Hours__c, q.Total_Allocated_Indirect_Costs__c, q.Target_Win__c, 
            q.Take_or_Pay_Contract__c, q.Shot_Service_Hours__c, q.Country__c,  q.Opportunity__r.RecordTypeId,
            q.Sales_Organization_Primary__c, q.Risk_Assesment__c, q.Quote_Valid_To__c, q.Quote_Valid_From__c,
            q.Quote_Description__c, q.Quote_Amount__c, q.Quote_Acceptance_Period__c, q.Quote_Accepted_By_Customer__c, 
            q.Price_Valid_To__c, q.Price_Valid_From__c, q.Price_Adjustment__c, q.Potential_Cash_Discount__c, 
            q.Payment_Terms__c, q.Opportunity__c, q.On__c, q.On_Contract__c, q.Name,
            q.LastModifiedDate, q.LastModifiedById, q.LastActivityDate, q.Is_Additional_Capital_Required__c, 
            q.Id, q.Have_You_Spoken_to_Operations__c,
            q.Delivery_Hours__c,  q.CurrencyIsoCode, q.Alternate_Address_Detail__c,
            q.Caps_On_Escalation__c, q.Cap_Details__c, 
            q.Are_Additional_People_Required__c, q.Approval_Status__c, q.Active_Quote__c, q.AN_Formula_Pricing__c, q.Opportunity__r.Deal_Number__c,
            (Select Name, Quote__c, Actual_Price__c, Available_Credit_Limit__c, Avg_Sell_Price__c, Bundled_Flag__c, Sales_Site__r.SAP_Account_Number__c, Substitution__c, Formula_Text__c,
            Bundled_Percent__c, Calculated_Monthly_Purchases__c, Credit_Limit__c, Description__c, Floor_Price__c, Formula_Flag__c, Material_Item__r.Material_Code__c,
            Material_Item__c, Monthly_Purchases__c, Notify_Credit__c, Per__c, Percent__c, Sales_Site__c, Price_Valid_From__c, Pricing_Rule__c, Substitution_Comments__c,
            Price_Valid_To__c, Quantity__c, Reason__c, Total_Price__c, Source_Sales_Site__c, UoM__c, Target_Price__c, Country__c, Adder_Notes__c From Quote_Line_Items__r)
        From Quote__c q where Opportunity__c in: opportunityIds and Active_Quote__c = true];
    }
    
    public static List<Quote__c> getDealChildren(Id dealId) {
        return [Select q.Version_Number__c, q.Total_Direct_Hours__c, q.Total_Allocated_Indirect_Costs__c, q.Target_Win__c, q.Take_or_Pay_Contract__c, 
                q.SystemModstamp, q.Shot_Service_Hours__c, q.Sales_Organization_Primary__c, q.Risk_Assesment__c, q.Alternate_Address_Detail__c,
                q.Reason_Comments__c, q.Quote_Valid_To__c, q.Quote_Valid_From__c, q.Quote_Description__c, q.Quote_Amount__c, 
                q.Quote_Accepted_By_Customer__c, q.Quote_Acceptance_Period__c, q.QuoteItemsBelowFlrPrice__c, q.Price_Valid_To__c, q.Price_Valid_From__c, 
                q.Price_Adjustment__c, q.Potential_Cash_Discount__c, q.Payment_Terms__c, q.Opportunity__c, q.On__c, q.Country__c,
                q.On_Contract__c, q.Name, q.LastModifiedDate, q.LastModifiedById, q.LastActivityDate, q.Is_Additional_Capital_Required__c, 
                q.IsDeleted, q.Id, q.Have_You_Spoken_to_Operations__c, 
                q.Delivery_Hours__c,  q.CurrencyIsoCode, q.CreatedDate, q.CreatedById, q.Opportunity__r.RecordTypeId,
                q.Caps_On_Escalation__c, q.Cap_Details__c, q.Are_Additional_People_Required__c, q.Approval_Status__c, 
                q.Active_Quote__c, q.AN_Formula_Pricing__c, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Adder_Notes__c, Formula_Text__c,
                LastActivityDate, Quote__c, Actual_Price__c, Available_Credit_Limit__c, Avg_Sell_Price__c, Bundled_Flag__c, Bundled_Percent__c, Substitution__c, Calculated_Monthly_Purchases__c, 
                Credit_Limit__c, Description__c, Floor_Price__c, Formula_Flag__c, Material_Item__c, Monthly_Purchases__c, Notify_Credit__c, Per__c, Percent__c, Sales_Site__c, Substitution_Comments__c,
                Price_Valid_From__c, Total_Price__c, Country__c, Price_Valid_To__c, Quantity__c, Reason__c, UoM__c, Source_Sales_Site__c, Target_Price__c, IsBelowFloorPrice__c, MFN_Flag__c, Pricing_Rule__c 
                From Quote_Line_Items__r) From Quote__c q where q.Opportunity__c = :dealId];
    }
    
    public static Account getAccount(Id accId){
        return [select Id, IsDeleted, MasterRecordId, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, 
        ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Phone, Fax, Website, Industry, AnnualRevenue, NumberOfEmployees, Ownership, 
        Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, AN_Formula_Pricing__c,
         Billing__c, Credit_Category__c, Credit_Exposure__c, Credit_Limit__c, CurrencyIsoCode, Delivery__c, 
         Flag_for_Deletion__c, On_Contract__c, On_Standard_Ts_Cs__c, Price_Adjustment_Notice_Period__c, SAP_Account_Number__c, 
         Deal_Count__c, Sub_Industry__c,
         Account_Group__c, Company_Code__c, SAPParentID__c, License_Expiration__c, Language__c from Account Where Id=:accId];
        
    }
    
    public static Opportunity getOpportunity(Id oppId) {
        return [Select o.Type, o.SystemModstamp, o.StageName, o.RecordTypeId, o.Probability, o.Pricebook2Id, o.OwnerId, o.Opportunity__c, o.Scenario_Choice__c, o.Hole_Size__c,
                o.NextStep, o.Name, o.LeadSource, o.LastModifiedDate, o.LastModifiedById, o.LastActivityDate, o.IsWon, o.IsDeleted, o.IsClosed, o.CurrencyIsoCode, o.Reason__c,
                o.HasOpportunityLineItem, o.ForecastCategoryName, o.ForecastCategory, o.FiscalYear, o.FiscalQuarter, o.Fiscal, o.Description, o.Sales_Site__c, o.Who_Won__c,
                o.Customer_Sales_Site__c, o.Comments__c, o.Deal_Number__c, o.CreatedDate, o.CreatedById, o.CloseDate, o.CampaignId, o.Amount, o.AccountId, o.Pricing_Sales_Office__c From Opportunity o where Id = :oppId];
    }
  


    
    public static Id createNewVersion(Id scenarioId, Date priceValidFrom, Date priceValidTo, Date qValidFrom, Date qValidTo, SLIAdjustments adjustments) {
        Id quoteId = [Select Opportunity__c from Quote__c where Id =:scenarioId].Opportunity__c;
        return cloneScenario(null, null, quoteId, scenarioId, false, priceValidFrom, priceValidTo, qValidFrom, qValidTo, adjustments).Id;
    }
    
    public static Id reactivateVersion(Id scenarioId, Date priceValidFrom, Date priceValidTo, Date qValidFrom, Date qValidTo, SLIAdjustments adjustments) {
        Id quoteId = [Select Opportunity__c from Quote__c where Id =:scenarioId].Opportunity__c;
        return cloneScenario(null, null, quoteId, scenarioId, true, priceValidFrom, priceValidTo, qValidFrom, qValidTo, adjustments).Id;
    }
    
   
    public class MaterialCostException extends Exception {}
    
    public static void CreatePricingCondition(String incQuoteId){
        String quoteType           = '';
        Double mcCount             = 0;
        Set <String> materialItems = new Set<String>();
        
        Quote__c aQuote =  [SELECT q.Id, q.Volumetric_Parent_Product__r.Material_code__c, q.Name, q.SAP_Scenario_Number__c, q.SAP_Scenario_Number_v2__c, q.Customer_Group__c, q.Opportunity__r.RecordType.Name, q.Quote_Accepted_By_Customer__c,  q.Approval_Status__c, q.Active_Quote__c, q.Sales_Organization_Primary__r.Company_Site__r.Name, q.CurrencyIsoCode, q.Price_Valid_From__c, q.Price_Valid_To__c, q.Volumetric_Parent_Product_UoM__c, 
                            q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.SAPExternalId__c, q.Opportunity__r.Deal_Number__c, q.Sales_Organization_Primary__r.SalesOrg_Code__c, q.Sales_Organization_Primary__r.SalesGroup_Code__c, q.Sales_Organization_Primary__r.Region__c, q.Sales_Organization_Primary__r.Name, q.Customer__r.SAP_Account_Number__c, q.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c, q.Calculated_Price__c, q.Volumetric_Per__c, q.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c,
                            (SELECT Id, Name, Price_Valid_From__c, Price_Valid_To__c, Per__c, UoM__c, Quote__r.Name, Sales_Site__r.Region__c, Sales_Site__r.Company_Site__r.Name, Actual_Price__c, Sales_Site__r.SAP_Account_Number__c, Material_Item__r.Is_PHL__c, Material_Item__r.Product_Hierarchy__c,
                            Material_Item__c, Receive_NH3_Surcharge__c, Sales_Site__c,  Sales_Site__r.SAPExternalId__c, Sales_Site__r.Company_Site__r.SAPExternalId__c, Sales_Site__r.Region_Site__r.SAPExternalId__c, Material_Item__r.Material_Code__c, Quote__r.Customer__r.SAP_Account_Number__c, Quote__r.Opportunity__r.Deal_Number__c, Sales_Site__r.Name
                            FROM Quote_Line_Items__r Where Is_Bundled__c = false)  FROM Quote__c q WHERE Id=:incQuoteId];
      
        
        for(Quote_Line_Item__c qli : aQuote.Quote_Line_Items__r) {
            materialItems.add(qli.Material_Item__c);
            mcCount++;
        }

        Double mcCostCount = [SELECT Count() FROM Material_Cost__c WHERE Material_Item__c in: materialItems AND Sales_Site__c =: aQuote.Sales_Organization_Primary__c];
        if (mcCostCount < mcCount) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Util_No_Material_Cost));
        }

        List<Pricing_Condition__c> pcList = new List<Pricing_Condition__c>();
       
        for(Quote_Line_Item__c qli : aQuote.Quote_Line_Items__r) {
            Pricing_Condition__c pc     = new Pricing_Condition__c();
            //FORCE Pricing Condition Id
            //SAP IDOC TYPE in createPricingConditionDetails
            pc.Price_Valid_From__c      = qli.Price_Valid_From__c;
            pc.Price_Valid_To__c        = qli.Price_Valid_To__c;
            //SAP Usage in createPricingConditionDetails
            //SAP Application in createPricingConditionDetails
            //SAP Table in createPricingConditionDetails
            //SAP Condition Type in createPricingConditionDetails
            //SAP VARKEY in createPricingConditionDetails
            
            // Add if/else code to line 137: awaiting to see if need to add to line 183 & 223   RPN   Mar 29 2011
            //if(qli.Receive_NH3_Surcharge__c == 'No')  {
            //  pc.NH3_Surcharge_Exclusion__c = 'Z';
            //} else {
            //  pc.NH3_Surcharge_Exclusion__c = '';
            //}
            //RPN modified above if else statement to just pass value of field to pc....field has updated calc to cover if statement
            pc.NH3_Surcharge_Exclusion__c = qli.Receive_NH3_Surcharge__c;
                        
            pc.Price__c                 = qli.Actual_Price__c;            
            pc.Per__c                   = qli.Per__c;
            pc.UoM__c                   = transformUoM(qli.UoM__c);
            pc.CurrencyIsoCode          = aQuote.CurrencyIsoCode;
            pc.Quote_Number__c          = aQuote.Opportunity__r.Deal_Number__c;
            pc.Scenario__c              = aQuote.Id;
            //pc.SAP_Scenario_Number__c   = transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
            pc.SAP_Scenario_Number__c   = aQuote.SAP_Scenario_Number_v2__c;
            pc.SAP_Customer_Number__c   = aQuote.Customer__r.SAP_Account_Number__c;
            pc.SAP_Sales_Org__c         = aQuote.Sales_Organization_Primary__r.SalesOrg_Code__c;
            pc.SAP_Sales_Group__c       = aQuote.Sales_Organization_Primary__r.SalesGroup_Code__c;
            pc.Company_Code__c          = aQuote.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c;
            pc.Quote_Type__c            = aQuote.Opportunity__r.RecordType.Name.substring(0,1);
            if(pc.Quote_Type__c == 'V') {
                pc.Volumetric_Level__c  = 'C';
            }   
            
            pc.Sales_Site__c            = aQuote.Sales_Organization_Primary__r.SAPExternalId__c;
            pc.Region__c                = aQuote.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c;
            pc.Customer_Group__c        = aQuote.Customer_Group__c;
            pc.MaterialCode__c          = qli.Material_Item__r.Material_Code__c;     
            
            createPricingConditionDetails(pc, qli.Material_Item__r.Is_PHL__c == 1);
            pcList.add(pc);
        }
        
        //Create PC record for the Volumetric Parent Product.
        if ( aQuote.Opportunity__r.RecordType.Name  == 'Volumetric'){
            Pricing_Condition__c pc     = new Pricing_Condition__c();
            //FORCE Pricing Condition Id
            //SAP IDOC TYPE in createPricingConditionDetails
            pc.Price_Valid_From__c      = aQuote.Price_Valid_From__c;
            pc.Price_Valid_To__c        = aQuote.Price_Valid_To__c;
            //SAP Usage in createPricingConditionDetails
            //SAP Application in createPricingConditionDetails
            //SAP Table in createPricingConditionDetails
            //SAP Condition Type in createPricingConditionDetails
            //SAP VARKEY in createPricingConditionDetails
            
            pc.Price__c                 = aQuote.Calculated_Price__c;    
            pc.Per__c                   = Decimal.valueOf(aQuote.Volumetric_Per__c);
            pc.UoM__c                   = transformUoM(aQuote.Volumetric_Parent_Product_UoM__c);
            pc.CurrencyIsoCode          = aQuote.CurrencyIsoCode;
            pc.Quote_Number__c          = aQuote.Opportunity__r.Deal_Number__c;
            pc.Scenario__c              = aQuote.Id;
            //pc.SAP_Scenario_Number__c   = transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
            pc.SAP_Scenario_Number__c   = aQuote.SAP_Scenario_Number_v2__c;
            pc.SAP_Customer_Number__c   = aQuote.Customer__r.SAP_Account_Number__c;
            pc.SAP_Sales_Org__c         = aQuote.Sales_Organization_Primary__r.SalesOrg_Code__c;
            pc.SAP_Sales_Group__c       = aQuote.Sales_Organization_Primary__r.SalesGroup_Code__c;
            pc.Company_Code__c          = aQuote.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c; 
            pc.Quote_Type__c            = aQuote.Opportunity__r.RecordType.Name.substring(0,1);
            if(pc.Quote_Type__c == 'V') {
                pc.Volumetric_Level__c  = 'P';
            }
            
            pc.Sales_Site__c            = aQuote.Sales_Organization_Primary__r.SAPExternalId__c;
            pc.Region__c                = aQuote.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c;
            pc.Customer_Group__c        = aQuote.Customer_Group__c;
            pc.MaterialCode__c          = aQuote.Volumetric_Parent_Product__r.Material_Code__c;     
            createPricingConditionDetails(pc, false);
            pcList.add(pc);         
        }
        
        //Create PC record for the header
        Pricing_Condition__c pc     = new Pricing_Condition__c();
        //FORCE Pricing Condition Id
        pc.SAP_IDOC_Type__c         = 'COND_A02';
        pc.Price_Valid_From__c      = aQuote.Price_Valid_From__c;
        pc.Price_Valid_To__c        = aQuote.Price_Valid_To__c;
        pc.SAP_Usage__c             = 'A';
        pc.SAP_Application__c       = 'V';
        pc.SAP_Table__c             = '507';
        pc.SAP_Condition_Type__c    = 'ZFSQ';  
        pc.Price__c                 = null;
        pc.Per__c                   = null;
        pc.UoM__c                   = null;    
        pc.CurrencyIsoCode          = null;
        pc.Quote_Number__c          = aQuote.Opportunity__r.Deal_Number__c;
        
        //pc.SAP_Scenario_Number__c   = transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
        pc.SAP_Scenario_Number__c   = aQuote.SAP_Scenario_Number_v2__c;
        pc.Scenario__c              = aQuote.Id;
        pc.SAP_Customer_Number__c   = aQuote.Customer__r.SAP_Account_Number__c;
        pc.SAP_Sales_Org__c         = padToAlternate(siteToPlant(aQuote.Sales_Organization_Primary__r.SAPExternalId__c, aQuote.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c));
        pc.Company_Code__c          = null;
        pc.Quote_Type__c            = null;
        pc.Volumetric_Level__c      = null;
        pc.Sales_Site__c            = null;
        pc.Region__c                = null; 
        pc.Customer_Group__c        = null;
        pc.MaterialCode__c          = null;
        //pc.SAP_VARKEY__c            = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
        pc.SAP_VARKEY__c            = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + aQuote.SAP_Scenario_Number_v2__c;
        pcList.add(pc);
        
        insert(pcList);
        aQuote.Published__c = true;
        aQuote.Date_Published_to_SAP__c = Date.today();
        Opportunity parentOpp = [SELECT StageName, Who_Won__c FROM Opportunity WHERE Id = :aQuote.Opportunity__c LIMIT 1];
        parentOpp.StageName = 'Closed Won';
        parentOpp.Who_Won__c = 'Dyno Nobel';
        parentOpp.Reason__c = 'Pricing';
        update parentOpp;
        update aQuote;                      
    }
    
    //US
    //SORGPGCUSTOMERMATERIAL     = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
    //SORGPGCUSTOMERPRODHIER     = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
    
    //CAN
    //SORGPGCUSTOMERPLNTMATERIAL = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.Sales_Site__c + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
    //SORGPGCUSTOMERPLNTPRODHIER = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.Sales_Site__c + pc.MaterialCode__c;
  
    public static void CreatePricingConditionBulk(List<Quote__c> scenarioList){
        String quoteType           = '';
        Double mcCount             = 0;
        Set <String> materialItems = new Set<String>();
        String scenarioID;
        List<Pricing_Condition__c> pcList = new List<Pricing_Condition__c>();
        List<Quote__c> quoteList = new List<Quote__c>();
        List<Quote_Line_Item__c> sliList = new List<Quote_Line_Item__c>();
        Integer count = 0;
        
        for(Quote__c s: scenarioList) {

            scenarioID = s.id; 
            count = count + 1;  
            mcCount = 0;     
             
            //system.debug(LoggingLevel.INFO,'count = :' + count);     
                
            //Quote__c aQuote =  [SELECT q.Id, q.Volumetric_Parent_Product__r.Material_code__c, q.Name, q.SAP_Scenario_Number__c, q.SAP_Scenario_Number_v2__c, q.Customer_Group__c, q.Opportunity__r.RecordType.Name, q.Quote_Accepted_By_Customer__c,  q.Approval_Status__c, q.Active_Quote__c, q.Sales_Organization_Primary__r.Company_Site__r.Name, q.CurrencyIsoCode, q.Price_Valid_From__c, q.Price_Valid_To__c, q.Volumetric_Parent_Product_UoM__c, 
                                //q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.SAPExternalId__c, q.Opportunity__r.Deal_Number__c, q.Sales_Organization_Primary__r.SalesOrg_Code__c, q.Sales_Organization_Primary__r.SalesGroup_Code__c, q.Sales_Organization_Primary__r.Region__c, q.Sales_Organization_Primary__r.Name, q.Customer__r.SAP_Account_Number__c, q.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c, q.Calculated_Price__c, q.Volumetric_Per__c, q.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c,
                                //(SELECT Id, Name, Price_Valid_From__c, Price_Valid_To__c, Per__c, UoM__c, Quote__r.Name, Sales_Site__r.Region__c, Sales_Site__r.Company_Site__r.Name, Actual_Price__c, Sales_Site__r.SAP_Account_Number__c, Material_Item__r.Is_PHL__c, Material_Item__r.Product_Hierarchy__c,
                               // Material_Item__c, Receive_NH3_Surcharge__c, Sales_Site__c,  Sales_Site__r.SAPExternalId__c, Sales_Site__r.Company_Site__r.SAPExternalId__c, Sales_Site__r.Region_Site__r.SAPExternalId__c, Material_Item__r.Material_Code__c, Quote__r.Customer__r.SAP_Account_Number__c, Quote__r.Opportunity__r.Deal_Number__c, Sales_Site__r.Name
                               // FROM Quote_Line_Items__r Where Is_Bundled__c = false)  FROM Quote__c q WHERE Id=:scenarioID];
          
            Quote__c aQuote = s;
            //for(Quote_Line_Item__c qli : aQuote.Quote_Line_Items__r) {
            //    materialItems.add(qli.Material_Item__c);
            //    mcCount++;
            //}
    
            //Double mcCostCount = [SELECT Count() FROM Material_Cost__c WHERE Material_Item__c in: materialItems AND Sales_Site__c =: aQuote.Sales_Organization_Primary__c];
            //if (mcCostCount < mcCount) {
            //                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cost is missing for Scenario Line Item for - ' + aQuote.Name));
            //                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'mcCostCount:' + mcCostCount + ' --mcCount:' + mcCount));
            //}        
            for(Quote_Line_Item__c qli : aQuote.Quote_Line_Items__r) {
                 
                //if (qli.Material_Item__r.Material_Code__c.substring(0,2).toUpperCase() == 'PL'){
                //if (qli.Publish_To_SAP__c == 'TRUE'){
                                    
                    Pricing_Condition__c pc     = new Pricing_Condition__c();
                    //FORCE Pricing Condition Id
                    //SAP IDOC TYPE in createPricingConditionDetails
                    pc.Price_Valid_From__c      = qli.Price_Valid_From__c;
                    pc.Price_Valid_To__c        = qli.Price_Valid_To__c;
                    //SAP Usage in createPricingConditionDetails
                    //SAP Application in createPricingConditionDetails
                    //SAP Table in createPricingConditionDetails
                    //SAP Condition Type in createPricingConditionDetails
                    //SAP VARKEY in createPricingConditionDetails
                    
                    // Add if/else code to line 137: awaiting to see if need to add to line 183 & 223   RPN   Mar 29 2011
                    //if(qli.Receive_NH3_Surcharge__c == 'No')  {
                    //  pc.NH3_Surcharge_Exclusion__c = 'Z';
                    //} else {
                    //  pc.NH3_Surcharge_Exclusion__c = '';
                    //}
                    //RPN modified above if else statement to just pass value of field to pc....field has updated calc to cover if statement
                    pc.NH3_Surcharge_Exclusion__c = qli.Receive_NH3_Surcharge__c;
                                
                    pc.Price__c                 = qli.Actual_Price__c;            
                    pc.Per__c                   = qli.Per__c;
                    pc.UoM__c                   = transformUoM(qli.UoM__c);
                    pc.CurrencyIsoCode          = aQuote.CurrencyIsoCode;
                    pc.Quote_Number__c          = aQuote.Opportunity__r.Deal_Number__c;
                    pc.Scenario__c              = aQuote.Id;
                    //pc.SAP_Scenario_Number__c   = transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
                    pc.SAP_Scenario_Number__c   = aQuote.SAP_Scenario_Number_v2__c;
                    pc.SAP_Customer_Number__c   = aQuote.Customer__r.SAP_Account_Number__c;
                    pc.SAP_Sales_Org__c         = aQuote.Sales_Organization_Primary__r.SalesOrg_Code__c;
                    pc.SAP_Sales_Group__c       = aQuote.Sales_Organization_Primary__r.SalesGroup_Code__c;
                    pc.Company_Code__c          = aQuote.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c;
                    pc.Quote_Type__c            = aQuote.Opportunity__r.RecordType.Name.substring(0,1);
                    
                    if(pc.Quote_Type__c == 'V') {
                        pc.Volumetric_Level__c  = 'C';
                    }   
                    
                    pc.Sales_Site__c            = aQuote.Sales_Organization_Primary__r.SAPExternalId__c;
                    pc.Region__c                = aQuote.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c;
                    pc.Customer_Group__c        = aQuote.Customer_Group__c;
                    pc.MaterialCode__c          = qli.Material_Item__r.Material_Code__c;     
                    
                    createPricingConditionDetails(pc, qli.Material_Item__r.Is_PHL__c == 1);
                    pcList.add(pc);
                    qli.Publish_To_SAP__c = '';
                    sliList.add(qli);
                //}
            }
            
            //Create PC record for the Volumetric Parent Product.
            if ( aQuote.Opportunity__r.RecordType.Name  == 'Volumetric'){
                Pricing_Condition__c pc     = new Pricing_Condition__c();
                //FORCE Pricing Condition Id
                //SAP IDOC TYPE in createPricingConditionDetails
                pc.Price_Valid_From__c      = aQuote.Price_Valid_From__c;
                pc.Price_Valid_To__c        = aQuote.Price_Valid_To__c;
                //SAP Usage in createPricingConditionDetails
                //SAP Application in createPricingConditionDetails
                //SAP Table in createPricingConditionDetails
                //SAP Condition Type in createPricingConditionDetails
                //SAP VARKEY in createPricingConditionDetails
                
                pc.Price__c                 = aQuote.Calculated_Price__c;    
                pc.Per__c                   = Decimal.valueOf(aQuote.Volumetric_Per__c);
                pc.UoM__c                   = transformUoM(aQuote.Volumetric_Parent_Product_UoM__c);
                pc.CurrencyIsoCode          = aQuote.CurrencyIsoCode;
                pc.Quote_Number__c          = aQuote.Opportunity__r.Deal_Number__c;
                pc.Scenario__c              = aQuote.Id;
                //pc.SAP_Scenario_Number__c   = transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
                pc.SAP_Scenario_Number__c   = aQuote.SAP_Scenario_Number_v2__c;
                pc.SAP_Customer_Number__c   = aQuote.Customer__r.SAP_Account_Number__c;
                pc.SAP_Sales_Org__c         = aQuote.Sales_Organization_Primary__r.SalesOrg_Code__c;
                pc.SAP_Sales_Group__c       = aQuote.Sales_Organization_Primary__r.SalesGroup_Code__c;
                pc.Company_Code__c          = aQuote.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c; 
                pc.Quote_Type__c            = aQuote.Opportunity__r.RecordType.Name.substring(0,1);
                
                if(pc.Quote_Type__c == 'V') {
                    pc.Volumetric_Level__c  = 'P';
                }
                
                pc.Sales_Site__c            = aQuote.Sales_Organization_Primary__r.SAPExternalId__c;
                pc.Region__c                = aQuote.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c;
                pc.Customer_Group__c        = aQuote.Customer_Group__c;
                pc.MaterialCode__c          = aQuote.Volumetric_Parent_Product__r.Material_Code__c;     
                
                createPricingConditionDetails(pc, false);
                pcList.add(pc);         
            }
            
            //Create PC record for the header
            Pricing_Condition__c pc     = new Pricing_Condition__c();
            //FORCE Pricing Condition Id
            pc.SAP_IDOC_Type__c         = 'COND_A02';
            pc.Price_Valid_From__c      = aQuote.Price_Valid_From__c;
            pc.Price_Valid_To__c        = aQuote.Price_Valid_To__c;
            pc.SAP_Usage__c             = 'A';
            pc.SAP_Application__c       = 'V';
            pc.SAP_Table__c             = '507';
            pc.SAP_Condition_Type__c    = 'ZFSQ';  
            pc.Price__c                 = null;
            pc.Per__c                   = null;
            pc.UoM__c                   = null;    
            pc.CurrencyIsoCode          = null;
            pc.Quote_Number__c          = aQuote.Opportunity__r.Deal_Number__c;
            
            //pc.SAP_Scenario_Number__c   = transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
            pc.SAP_Scenario_Number__c   = aQuote.SAP_Scenario_Number_v2__c;
            pc.Scenario__c              = aQuote.Id;
            pc.SAP_Customer_Number__c   = aQuote.Customer__r.SAP_Account_Number__c;
            pc.SAP_Sales_Org__c         = padToAlternate(siteToPlant(aQuote.Sales_Organization_Primary__r.SAPExternalId__c, aQuote.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c));
            pc.Company_Code__c          = null;
            pc.Quote_Type__c            = null;
            pc.Volumetric_Level__c      = null;
            pc.Sales_Site__c            = null;
            pc.Region__c                = null; 
            pc.Customer_Group__c        = null;
            pc.MaterialCode__c          = null;
            //pc.SAP_VARKEY__c            = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + transformScenarioNumber(aQuote.Opportunity__r.RecordType.Name,aQuote.SAP_Scenario_Number__c);
            pc.SAP_VARKEY__c            = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + aQuote.SAP_Scenario_Number_v2__c;
            pcList.add(pc);
            
            aQuote.Quote_Accepted_By_Customer__c = 'Yes';
            aQuote.Published__c = true;
            aQuote.Date_Published_to_SAP__c = Date.today();
            aQuote.Manual_Publish_SAP__c = '9';
            aQuote.Manual_Publish_Date__c = Date.today();
            aQuote.Approval_Status__c = 'Approved';
            //aQuote.RecordTypeID = '01230000000mJYgAAM';
            
            quoteList.add(aQuote);

        
        }//end of for loop for each scenario            
        //update parentOpp;
        insert(pcList);
        update quoteList;  
        update sliList;
                
    }  
    
    @testVisible
    private static String siteToPlant(String site, String comp) {
        if(comp != '150' || site == '1132' || site == '1133' || site == '1134' || site == '1135' || site == '1136' || site == '1137' || site == '1150') return site;
        return '1150';
    }
  
    //not using this funciton anymore as there is a inbuilt isNumeric Function  
    //private static boolean isNumeric(String s) {
    //    return (s == '0' || s == '1' || s == '2' || s == '3' || s == '4' || s == '5' || s == '6' || s == '7' || s == '8' || s == '9');
    //}
    @testVisible
    private static String padTo(String s, Integer padTo) {
        if (s == null)
            return null;
        String tempStr = s;
        while(tempStr.length() < padTo) {
            tempStr = '0' + tempStr;
        }
        
        return tempStr;
    }
    @testVisible
    private static String padToAlternate(String s) {
        String tempStr = s;
        while(tempStr.length() < 4) {
            tempStr+= 'x';
        }
        return tempStr;
    }    
    @testVisible
    private static String transformUoM(String oldUoM) {
        if(oldUoM == 'BOT') return 'BO';
        else if(oldUoM == 'BX') return 'CS';
        else if(oldUoM == 'CAR') return 'CT';
        else if(oldUoM == 'CAS') return 'CS';
        else if(oldUoM == 'D') return 'DAY';
        else if(oldUoM == 'DRM') return 'DR';
        else if(oldUoM == 'G') return 'GRM';
        else if(oldUoM == 'GAL') return 'GLL';
        else if(oldUoM == 'H') return 'HUR';
        else if(oldUoM == 'HR') return 'HUR';       
        else if(oldUoM == 'KG') return 'KGM';
        else if(oldUoM == 'KM') return 'KMT';
        else if(oldUoM == 'L') return 'LTR';
        else if(oldUoM == 'M2') return 'MTK';
        else if(oldUoM == 'M3') return 'MTQ';
        else if(oldUoM == 'MI') return 'SMI';
        else if(oldUoM == 'OZ') return 'ONZ';
        else if(oldUoM == 'PAA') return 'PR';
        else if(oldUoM == 'PAL') return 'PF';
        else if(oldUoM == 'STD') return 'HUR';
        else if(oldUoM == 'TO') return 'TNE';
        else if(oldUoM == 'TS') return 'MIL';       
        return oldUoM;
    }
    @testVisible
    private static Boolean SalesSiteIsWholesale(string salesSite){
        //March, 2017 - Added Peabody Sales Sites to the Wholesale Definition
        //Set<String> sites = new Set<String>{'JV', 'IND', 'WO', 'INTL', 'NATL'};
        Set<String> sites = new Set<String>{'JV', 'IND', 'WO', 'INTL', 'NATL', 'CRPM', 'WRPP', 'WRPS'};
        
        return sites.contains(salesSite);
    }
    @testVisible
    private static String transformScenarioNumber(String RecTypeName, String oldNum){
        return RecTypeName.substring(0,1) + oldNum.substring(1,oldNum.length());
    }
    @testVisible
    private static void createPricingConditionDetails(Pricing_Condition__c pc, Boolean isPHL) {
        final String SAP_TABLE_005 = '005';
        final String SAP_TABLE_610 = '610';
        final String SAP_TABLE_993 = '993';
        final String SAP_TABLE_992 = '992';
        final String SAP_CONDITION_Z100 = 'Z100';
        final String SAP_CONDITION_Z600 = 'Z600';
        final String SAP_CONDITION_ZPT = 'ZPT';
        final String SAP_CONDITION_ZPT1 = 'ZPT1';
        
        String routefreight = 'ZCON';
        if (pc.MaterialCode__c=='SS150'||pc.MaterialCode__c=='SS184'||pc.MaterialCode__c=='SS186'||pc.MaterialCode__c=='SS260'
            ||pc.MaterialCode__c=='SS284'||pc.MaterialCode__c=='SS295'||pc.MaterialCode__c=='SS296'||pc.MaterialCode__c=='SS297'
            ||pc.MaterialCode__c=='SS299'||pc.MaterialCode__c=='SS300'||pc.MaterialCode__c=='SS301'||pc.MaterialCode__c=='SS302'
            ||pc.MaterialCode__c=='SS303'||pc.MaterialCode__c=='SS307'||pc.MaterialCode__c =='SS255'||pc.MaterialCode__c =='SS256'
            ||pc.MaterialCode__c =='SS257'||pc.MaterialCode__c =='SS258'||pc.MaterialCode__c =='SS259'||pc.MaterialCode__c =='SS261'
            ||pc.MaterialCode__c =='SS262') {
                routefreight = 'ZFRT';
        }       
        pc.SAP_IDOC_Type__c = 'COND_A02';
        pc.SAP_Usage__c = 'A';
        pc.SAP_Application__c = 'V';        
        //pc.SAP_Sales_Org__c = padToAlternate(siteToPlant(pc.Sales_Site__c, pc.Company_Code__c)); //comment this out to allow Sales Org to pass down from header.  preserve in INTL code below
        
        String MaterialCode = pc.MaterialCode__c.isNumeric() ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c; 
                
        if(pc.Company_code__c == '100'||pc.Company_code__c=='104') {
            
            if(SalesSiteIsWholesale(pc.Sales_Site__c)){
                //pc.SAP_Sales_Org__c = pc.Sales_Site__c == 'JV' || pc.Sales_Site__c == 'NATL' || pc.Sales_Site__c == 'IND' ? pc.SAP_Sales_Org__c : pc.Sales_Site__c;
                //March 2017 business decision that pc.SAP_Sales_Org__c is always the sales_site__c except for IND = "JV", and Peabody Sales Sites = "NATL"
                if(pc.Sales_Site__c == 'IND'){
                    pc.SAP_Sales_Org__c = 'JV';
                } else if(pc.Sales_Site__c == 'WRPP' || pc.Sales_Site__c == 'CRPM' || pc.Sales_Site__c == 'WRPS'){
                    pc.SAP_Sales_Org__c = 'NATL';
                } else{          
                    pc.SAP_Sales_Org__c = pc.Sales_Site__c;
                }
                
                if(pc.Quote_Type__c == 'V') {
                    if(pc.Volumetric_Level__c == 'P') {
                        //18, 19
                        if(isPHL) {
                            //NOT POSSIBLE IGNORE CASE pc.SAP_Table__c = '610';
                            //NOT POSSIBLE IGNORE CASE pc.SAP_Condition_Type__c = 'Z600';
                        } else {
                            pc.SAP_Table__c = SAP_TABLE_005;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
                            //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        }                               
                    } else if(pc.Volumetric_Level__c == 'C') {
                        //20, 21
                        if(isPHL) {
                            pc.SAP_Table__c = SAP_TABLE_610;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
                            //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        } else {
                            pc.SAP_Table__c = SAP_TABLE_005;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
                            //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        }                               
                    } else {
                        
                    }
                } else {
                    if(pc.Volumetric_Level__c == 'P') {
                        
                    } else if(pc.Volumetric_Level__c == 'C') {
                        
                    } else {
                        if (pc.Sales_Site__c == 'INTL'){
                            //16, 17
                            if(isPHL) {
                                pc.SAP_Table__c = SAP_TABLE_610;
                                pc.SAP_Condition_Type__c = SAP_CONDITION_Z600;
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            } else {
                                pc.SAP_Table__c = SAP_TABLE_005;
                                pc.SAP_Condition_Type__c = SAP_CONDITION_Z600;
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            }   
                        } else {
                            //16, 17
                            //March 2017 business decision that all wholesale accounts go to z600
                            if(isPHL) {
                                pc.SAP_Table__c = SAP_TABLE_610;
                                pc.SAP_Condition_Type__c = SAP_CONDITION_Z600;
                                //account for two-digit Sales Org (JV) in the SAP VARKEY to be sent to SAP's iDoc load
                                if(pc.SAP_Sales_Org__c == 'JV') {
                                    pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '  ' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                                } else {
                                    //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
                                    pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                                }
                            } else {
                                pc.SAP_Table__c = SAP_TABLE_005;
                                pc.SAP_Condition_Type__c = SAP_CONDITION_Z600;
                                //account for two-digit Sales Org (JV) in the SAP VARKEY to be sent to SAP's iDoc load
                                if(pc.SAP_Sales_Org__c == 'JV') {
                                    pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '  00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                                } else {
                                    //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                    pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                                }
                            }    
                        }
                        //16, 17
                        //comment out the below part due to above going live  oct 24 2012
//                        if(isPHL) {
//                          pc.SAP_Table__c = SAP_TABLE_610;
//                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
//                            //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
//                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
//                        } else {
//                            pc.SAP_Table__c = SAP_TABLE_005;
//                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
//                            //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
//                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
//                        }   
//                                                    
                    }                       
                }
            } else {
                if(pc.Quote_Type__c == 'V') {
                    if(pc.Volumetric_Level__c == 'P') {
                        //12, 13
                        if(isPHL) {
                            pc.SAP_Table__c = SAP_TABLE_610;
                            pc.SAP_Condition_Type__c = 'Z600';
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.SAP_Sales_Group__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        } else {
                            pc.SAP_Table__c = SAP_TABLE_992;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_ZPT;
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.SAP_Sales_Group__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        }                           
                    } else if(pc.Volumetric_Level__c == 'C') {
                        //14, 15
                        if(isPHL) {
                            pc.SAP_Table__c = SAP_TABLE_993;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_ZPT1;
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.SAP_Sales_Group__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        } else {
                            pc.SAP_Table__c = SAP_TABLE_992;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_ZPT1;
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.SAP_Sales_Group__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        }                           
                    } else {
                        
                    }                       
                } else {
                    if(pc.Volumetric_Level__c == 'P') {
                        
                    } else if(pc.Volumetric_Level__c == 'C') {
                        
                    } else {
                        //10, 11
                        if(isPHL) {
                            pc.SAP_Table__c = SAP_TABLE_993;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.SAP_Sales_Group__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        } else {
                            pc.SAP_Table__c = SAP_TABLE_992;
                            pc.SAP_Condition_Type__c = SAP_CONDITION_Z100;
                            pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.SAP_Sales_Group__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                        }
                    }                       
                }                   
            }//end US
        } else if(pc.Company_code__c == '132' || pc.Company_code__c == '133' || pc.Company_code__c == '135' || pc.Company_code__c == '136' || pc.Company_code__c == '137' || pc.Company_code__c == '150') {
            pc.SAP_Sales_Org__c = padToAlternate(siteToPlant(pc.Sales_Site__c, pc.Company_Code__c)); //hack to preserve the mapping that needs to go away at some point
            if(pc.Customer_Group__c.contains('02') || pc.Customer_Group__c.contains('01')) {
                if(pc.Quote_Type__c == 'V') {
                    if(pc.Volumetric_Level__c == 'P') {
                        //28, 29
                        if(isPHL) {
                            //NOT POSSIBLE IGNORE CASE pc.SAP_Table__c = '999';
                            //NOT POSSIBLE IGNORE CASE pc.SAP_Condition_Type__c = 'ZCON';
                        } else {
                            if (routefreight == 'ZFRT'){
                                pc.SAP_Table__c = '005'; //1-5-11 changed from 998 to 005
                                pc.SAP_Condition_Type__c = 'ZFRT';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            } else {
                                pc.SAP_Table__c = '005'; //1-5-11 changed from 998 to 005
                                pc.SAP_Condition_Type__c = 'ZCON';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            }
                        }                           
                    } else if(pc.Volumetric_Level__c == 'C') {
                        //30, 31
                        if(isPHL) {
                            if (routefreight == 'ZFRT'){
                                pc.SAP_Table__c = '604'; //1-5-11 changed from 801 to 604
                                pc.SAP_Condition_Type__c = 'ZFRT';
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            } else {
                                pc.SAP_Table__c = '604'; //1-5-11 changed from 801 to 604
                                pc.SAP_Condition_Type__c = 'ZCON';
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            }
                            
                        } else {
                            if (routefreight == 'ZFRT'){
                                pc.SAP_Table__c = '005'; //1-5-11 changed from 998 to 005
                                pc.SAP_Condition_Type__c = 'ZFRT';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            } else {
                                pc.SAP_Table__c = '005'; //1-5-11 changed from 998 to 005
                                pc.SAP_Condition_Type__c = 'ZCON';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            }
                            }                           
                    } else {
                        
                    }                       
                } else {
                        //26, 27
                        if(isPHL) {
                            if (routefreight == 'ZFRT'){
                                pc.SAP_Table__c = '604'; //1-5-11 changed from 801 to 604
                                pc.SAP_Condition_Type__c = 'ZFRT';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            } else {
                                pc.SAP_Table__c = '604'; //1-5-11 changed from 801 to 604
                                pc.SAP_Condition_Type__c = 'ZCON';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + pc.MaterialCode__c;
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            }
                            
                        } else {
                            if (routefreight == 'ZFRT'){
                                pc.SAP_Table__c = '005'; //1-5-11 changed from 998 to 005
                                pc.SAP_Condition_Type__c = 'ZFRT';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            } else {
                                pc.SAP_Table__c = '005'; //1-5-11 changed from 998 to 005
                                pc.SAP_Condition_Type__c = 'ZCON';
                                //pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + pc.Quote_Number__c + padTo(pc.SAP_Customer_Number__c, 10) + (isNumeric(pc.MaterialCode__c.substring(0,1)) ? padTo(pc.MaterialCode__c, 18) : pc.MaterialCode__c);
                                pc.SAP_VARKEY__c = pc.SAP_Sales_Org__c + '00' + padTo(pc.SAP_Customer_Number__c, 10) + MaterialCode;
                            }
                            
                        }                           
                    }                   
            }       
        }
    }
    
    
    /*
    public static testmethod void pricingConditionTest(){
        // Initialize Test Data 
        Account testAccount = TestUtils.createAccount('TestMDgjdsi43', null);
        testAccount.SAP_Account_Number__c = '0000';
        update testAccount;
        List<Sales_Site__c> testHier = TestUtils.createSalesSiteHierarchy('Comp-gjdsi43', 'Reg-gjdsi43', 'Site-gjdsi43');
        testHier.get(2).SAPExternalId__c = '0000';
        testHier.get(1).SAPExternalId__c = '0009';
        List<Sales_Site__c> ssTempo = [SELECT Name, Id, SAPExternalId__c FROM Sales_Site__c WHERE SAPExternalId__c = '100' LIMIT 1];
        if(ssTempo.size() > 0) {
            testHier.remove(0);
            testHier.add(0, ssTempo.get(0));
            testHier.get(2).Company_Site__c = testHier.get(0).Id;
            testHier.get(1).Company_Site__c = testHier.get(0).Id;
            update testHier;
            Id volumetricQuoteId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted'].Id;
            Opportunity testQuote = TestUtils.createOppty('TBC', testAccount.Id, 'Proposal/Price Quote', volumetricQuoteId, testHier.get(2).Id);
            testQuote = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :testQuote.Id];
            Quote__c testScenario = TestUtils.createQuote(testQuote, testHier.get(2).Id);
            Material_Item__c testMat1 = TestUtils.createMaterialItem('TMI9384', 'PL0000000100000001', 'PL0000000100000001');
            Material_Item__c testMat2 = TestUtils.createMaterialItem('TMI9384', '0RZ1086', 'PL0000000100000001');
            Quote_Line_Item__c testSLI1 = TestUtils.createQli(testMat1, 10.0d, '1: Half Cent', testScenario, 1.0d, testHier.get(2));
            Quote_Line_Item__c testSLI2 = TestUtils.createQli(testMat2, 50.0d, '1: Half Cent', testScenario, 1.0d, testHier.get(2));         
             
            // Create Pricing Condition records                   
            CreatePricingCondition(testScenario.Id);
            List<Pricing_Condition__c> testPCs = [SELECT Id, SAP_IDOC_Type__c, Price_Valid_From__c, Price_Valid_To__c, SAP_Usage__c, SAP_Application__c, SAP_Table__c, Scenario__c,
                                                  SAP_Condition_Type__c, SAP_VARKEY__c, Price__c, Per__c, UoM__c, CurrencyIsoCode, Quote_Number__c, SAP_Scenario_Number__c, 
                                                  SAP_Customer_Number__c , SAP_Sales_Org__c, Company_Code__c, Quote_Type__c, Volumetric_Level__c, Sales_Site__c, Region__c, 
                                                  Customer_Group__c, MaterialCode__c, CreatedDate FROM Pricing_Condition__c WHERE Scenario__c = :testScenario.Id];
                                                  
            System.assert(testPCs.size() > 0);              
            // Test 1: Scenario level PricingCondition
            Integer assertionCount = 0;
            
            for(Pricing_Condition__c currPc : testPCs) {
                if(currPc.SAP_IDOC_Type__c == 'COND_A02' && currPc.Price_Valid_From__c == System.TODAY() && currPc.Price_Valid_To__c == System.TODAY().addDays(30) &&
                   currPc.SAP_Usage__c == 'A' && currPc.SAP_Application__c == 'V' && currPc.SAP_Table__c == '507' && currPc.SAP_Condition_Type__c == 'ZFSQ' &&
                   currPc.SAP_VARKEY__c == ('0000010000000000' + currPc.SAP_Scenario_Number__c) && currPc.Price__c == null && currPc.Per__c == null && currPc.UoM__c == null && currPc.CurrencyIsoCode == 'USD' &&
                   currPc.Quote_Number__c == '01' && currPc.SAP_Scenario_Number__c.contains('V0') && currPc.Scenario__c == testScenario.Id && currPc.SAP_Customer_Number__c == '0000' &&
                   currPc.SAP_Sales_Org__c == '0000' && currPc.Company_Code__c == null && currPc.Quote_Type__c == null && currPc.Volumetric_Level__c == null && currPc.Sales_Site__c == null &&
                   currPc.Region__c == null && currPc.Customer_Group__c == null && currPc.MaterialCode__c == null) {
                    assertionCount++;
                   }
            }
            
            System.assertEquals(1, assertionCount);
            assertionCount = 0;
                
            Material_Item__c volumetricParent = [SELECT Material_Code__c FROM Material_Item__c WHERE Id = :testScenario.Volumetric_Parent_Product__c];
            for(Pricing_Condition__c currPc : testPCs) {
                if(currPc.SAP_IDOC_Type__c == 'COND_A02' && currPc.Price_Valid_From__c == System.TODAY() && currPc.Price_Valid_To__c == System.TODAY().addDays(30) &&
                   currPc.SAP_Table__c == '998' && currPc.SAP_Condition_Type__c == 'ZPT' && currPc.SAP_VARKEY__c == ('0000010000000000' + volumetricParent.Material_Code__c) &&
                   currPc.SAP_Usage__c == 'A' && currPc.SAP_Application__c == 'V' && currPc.Price__c == null && currPc.Per__c == 1.00 && currPc.UoM__c == 'EA' && currPc.CurrencyIsoCode == 'USD' &&
                   currPc.Quote_Number__c == '01' && currPc.SAP_Scenario_Number__c.contains('V0') && currPc.Scenario__c == testScenario.Id && currPc.SAP_Customer_Number__c == '0000' &&
                   currPc.SAP_Sales_Org__c == '0000' && currPc.Company_Code__c == '100' && currPc.Quote_Type__c == 'V' && currPc.Volumetric_Level__c == 'P' && currPc.Sales_Site__c == '0000' &&
                   currPc.Region__c == '0009' && currPc.Customer_Group__c == '02 Retail' && currPc.MaterialCode__c == volumetricParent.Material_Code__c) {
                    assertionCount++;
                   }
            }
            
            System.assertEquals(1, assertionCount);
            assertionCount = 0;
            
            for(Pricing_Condition__c currPc : testPCs) {
                if(currPc.SAP_IDOC_Type__c == 'COND_A02' && currPc.Price_Valid_From__c == System.TODAY() && currPc.Price_Valid_To__c == System.TODAY().addDays(30) &&
                   currPc.SAP_Table__c == '998' && currPc.SAP_Condition_Type__c == 'ZPT1' && currPc.SAP_VARKEY__c == '0000010000000000000000000000RZ1086' &&
                   currPc.SAP_Usage__c == 'A' && currPc.SAP_Application__c == 'V' && currPc.Price__c == 50 && currPc.Per__c == 1.00 && currPc.UoM__c == 'LB' && currPc.CurrencyIsoCode == 'USD' &&
                   currPc.Quote_Number__c == '01' && currPc.SAP_Scenario_Number__c.contains('V0') && currPc.Scenario__c == testScenario.Id && currPc.SAP_Customer_Number__c == '0000' &&
                   currPc.SAP_Sales_Org__c == '0000' && currPc.Company_Code__c == '100' && currPc.Quote_Type__c == 'V' && currPc.Volumetric_Level__c == 'C' && currPc.Sales_Site__c == '0000' &&
                   currPc.Region__c == '0009' && currPc.Customer_Group__c == '02 Retail' && currPc.MaterialCode__c == '0RZ1086') {
                    assertionCount++;
                   }                
            }

            System.assertEquals(1, assertionCount);
            assertionCount = 0;

            for(Pricing_Condition__c currPc : testPCs) {
                if(currPc.SAP_IDOC_Type__c == 'COND_A02' && currPc.Price_Valid_From__c == System.TODAY() && currPc.Price_Valid_To__c == System.TODAY().addDays(30) &&
                   currPc.SAP_Table__c == '999' && currPc.SAP_Condition_Type__c == 'ZPT1' && currPc.SAP_VARKEY__c == '0000010000000000PL0000000100000001' &&
                   currPc.SAP_Usage__c == 'A' && currPc.SAP_Application__c == 'V' && currPc.Price__c == 10 && currPc.Per__c == 1.00 && currPc.UoM__c == 'LB' && currPc.CurrencyIsoCode == 'USD' &&
                   currPc.Quote_Number__c == '01' && currPc.SAP_Scenario_Number__c.contains('V0') && currPc.Scenario__c == testScenario.Id && currPc.SAP_Customer_Number__c == '0000' &&
                   currPc.SAP_Sales_Org__c == '0000' && currPc.Company_Code__c == '100' && currPc.Quote_Type__c == 'V' && currPc.Volumetric_Level__c == 'C' && currPc.Sales_Site__c == '0000' &&
                   currPc.Region__c == '0009' && currPc.Customer_Group__c == '02 Retail' && currPc.MaterialCode__c == 'PL0000000100000001') {
                    assertionCount++;
                   }                                
            }                       
            
            System.assertEquals(1, assertionCount);
            
        } else {
            System.assertEquals('This test requires a sales site with SAP External ID 100 to be in the system', 'Failure');
        }
        
    }
    */
    
    
    public static String getScaledValue(Double db) {
        Decimal dec = Decimal.valueOf(db);
        return (dec.setScale(2)).format();
    }
    
    // New version of scenario, quote clone
    public static Opportunity createNewQuote(Customer_Sales_Site__c css, Date closeDate, Date qValidFrom, Date qValidTo, Date pValidFrom, Date pValidTo, String description, Boolean promo, Boolean tri, String scenarioChoice, String holeChoice, Id recordTypeId) {
        
        Opportunity opp = new Opportunity(
            AccountId = css.Customer__c,
            CurrencyIsoCode = css.CurrencyIsoCode,
            Sales_Site__c = css.Sales_Site__c,
            StageName = System.Label.Default_Opportunity_Stage,
            RecordTypeId = recordTypeId,
            CloseDate = closeDate
        );
        insert opp;
        
        // Create quote
        Account customerMaster = [SELECT Price_Adjustment_Notice_Period__c, CurrencyIsoCode, On_Standard_Ts_Cs__c, On_Contract__c, AN_Formula_Pricing__c FROM Account WHERE Id = :css.Customer__c];
        Quote__c q = new Quote__c(
            Price_Adjustment__c = customerMaster.Price_Adjustment_Notice_Period__c,
            Payment_Terms__c = css.Payment_Terms__c,
            CurrencyIsoCode = css.CurrencyIsoCode,
            On__c = customerMaster.On_Standard_Ts_Cs__c,
            On_Contract__c = customerMaster.On_Contract__c,
            AN_Formula_Pricing__c = customerMaster.AN_Formula_Pricing__c,
            Customer__c = customerMaster.Id,
            Sales_Organization_Primary__c = css.Sales_Site__c,
            Pricelist__c = css.Pricelist__c,
            Inco_Terms__c = css.INCO__c,
            Delivery_Sales_Site__c = css.Delivery_Sales_Site__c,
            Service_Type__c = css.Service_Type__c,
            Drilling_Provided_By__c = css.Drilled_By__c,
            Customer_Group__c = css.Customer_Group__c,
            Quote_Valid_From__c = qValidFrom,
            Quote_Valid_To__c = qValidTo,
            Price_Valid_From__c = pValidFrom,
            Price_Valid_To__c = pValidTo,
            Quote_Description__c = description,
            Promotional__c = promo,
            Trial__c = tri,
            Version_Number__c = '1',
            Active_Quote__c = true,
            Opportunity__c = opp.Id,
            Quote_Accepted_By_Customer__c = 'Not Yet'
        );
        insert q;
        
        // Add Bundled Services
        if(recordTypeId == [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id) {
            List<Bundled_Service__c> bsList = new List<Bundled_Service__c>();
            List<Quote_Line_Item__c> toInsert = new List<Quote_Line_Item__c>();
            
            if(scenarioChoice == 'Shot_Service_with_Drilling') {
                bsList = [SELECT Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Material_Description__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Preferred__c FROM Bundled_Service__c WHERE RecordType.DeveloperName = :scenarioChoice AND Hole_Size__c = :holeChoice];
            } else {
                bsList = [SELECT Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Material_Description__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Preferred__c FROM Bundled_Service__c WHERE RecordType.DeveloperName = :scenarioChoice];
            }
            List<Id> tempIds = new List<Id>();
            List<Material_Item__c> materialDetails = new List<Material_Item__c>();
            //Id, Name, Material_Code__c, Material_Description__c, Product_Hierarchy__c, Preferred__c
            for(Bundled_Service__c currBS : bsList) {
                tempIds.add(currBS.Material_Item__c);
                materialDetails.add( new Material_Item__c(Id=currBS.Material_Item__c, Name=currBS.Material_Item__r.Name, Material_Code__c=currBS.Material_Item__r.Material_Code__c, Material_Description__c=currBS.Material_Item__r.Material_Description__c, Product_Hierarchy__c=currBS.Material_Item__r.Product_Hierarchy__c, Preferred__c=currBS.Material_Item__r.Preferred__c));
            }
            List<MaterialMaster.CostData> cdList = MaterialMaster.calculateCost(tempIds, css.Sales_Site__c, true, materialDetails);
            
            Quote_Line_Item__c currQli;
            for(Bundled_Service__c currBS : bsList) {
                currQli = new Quote_Line_Item__c();
                currQli.Material_Item__c = currBS.Material_Item__c;
                currQli.Sales_Site__c = css.Sales_Site__c;
                currQli.Quantity__c = 1;
                currQli.Per__c = 1;
                currQli.UoM__c = 'N/A';
                currQli.Price_Valid_From__c = pValidFrom;
                currQli.Price_Valid_To__c = pValidTo;
                currQli.Country__c = q.Country__c;
                currQli.Floor_Price__c = 0.00;
                currQli.Target_Price__c = 0.00;
                currQli.Actual_Price__c = 0.00;
                currQli.Quote__c = q.Id;
                currQli.Is_Bundled__c = true;
                for(MaterialMaster.CostData mmcd : cdList) {
                    if(mmcd.materialId == currBS.Material_Item__c) {
                        currQli.Cost__c = mmcd.cost;
                    }
                }
                toInsert.add(currQli);
            }
            insert toInsert;                
        }
        
        return opp; 
    }
    
    public static Opportunity cloneQuote(Id quoteId) {
        Opportunity o = [Select Customer_Sales_Site__c, AccountId, Account.Pricing_Region__c, CurrencyIsoCode, Sales_Site__c, Sales_Site__r.Pricing_Sales_Office__c, StageName, RecordTypeId, CloseDate, Pricing_Region__c, Pricing_Sales_Office__c from Opportunity where Id =:quoteId];
        Opportunity opp = o.clone(false, true);
        opp.StageName = 'Proposal/Price Quote';
        opp.Reason__c = null;
        opp.Comments__c = null;
        opp.Who_Won__c = null;
        
        //I think we should check if there is a pricing region on opp (quote)and used that if not use Pricing region from account
        if( string.isBlank( o.Pricing_Region__c) ){
            opp.Pricing_Region__c = o.Account.Pricing_Region__c;
        }else{
            opp.Pricing_Region__c = o.Pricing_Region__c;
        }
        opp.Pricing_Sales_Office__c = o.Sales_Site__r.Pricing_Sales_Office__c;
            
        insert opp;
        
        cloneScenario(quoteId, opp);
        
        return opp;
    }
    
    public static List<Opportunity> cloneQuote(Id quoteId, List<Sales_Site__c> sites, Id customerId, Date validfrom, Date validto, Date qValidFrom, Date qValidTo, String pricingRegion) {
        Opportunity o = [Select Customer_Sales_Site__c, AccountId, CurrencyIsoCode, StageName, RecordTypeId, CloseDate, Description, Pricing_Region__c, Pricing_Sales_Office__c from Opportunity where Id =:quoteId];
        List<Opportunity> quotes = new List<Opportunity>();
        Opportunity quoteTemp;
        
        Account newAccount = [Select Pricing_Region__c from Account where Id =:customerId];
        
        system.debug('scott pricing region :' + pricingRegion);
        
        for (Sales_Site__c site : sites) {
            quoteTemp = new Opportunity();
            quoteTemp = o.clone(false, true);
            quoteTemp.StageName = 'Proposal/Price Quote';
            quoteTemp.AccountId = customerId;
            quoteTemp.Sales_Site__c = site.Id;
            quoteTemp.Reason__c = null;
            quoteTemp.Comments__c = null;
            quoteTemp.Who_Won__c = null;
            quoteTemp.Pricing_Region__c = pricingRegion;
            //added SL 
            quoteTemp.Pricing_Sales_Office__c = site.Pricing_Sales_Office__c;
            quotes.add(quoteTemp);
        }
        insert quotes;
        
        quote__c scenario = [SELECT Id From quote__c Where Opportunity__c = :quoteID And Active_Quote__c = True];
        
        for (Opportunity quote : quotes) {
            system.debug('scott pricing region 2 :' + quote.Pricing_Region__c);
            cloneScenario(customerId, Quote.sales_Site__c, quote.Id, scenario.Id, False , validFrom, validTo, qValidFrom, qValidTo, null);
        }
        
        return quotes;
    }
    
    
    public static Quote__c cloneScenario(Id oldQuoteId, Opportunity newQuote) {
        Id scenarioId;
        try {
            scenarioId = [Select Id from Quote__c where Active_Quote__c=true and Opportunity__c=:oldQuoteId].Id;
            return cloneScenario(scenarioId, newQuote.Id);
        } catch(Exception e) {
            throw new CloneException(System.Label.Quote_Util_No_Active);
        }
    }
    
    public static Quote__c cloneScenario(Id oldQuoteId, Id newQuoteId, Id salesSiteId, Id customerId) {
        Id scenarioId;
        
        try {
            scenarioId = [Select Id from Quote__c where Active_Quote__c=true and Opportunity__c=:oldQuoteId].Id;
            Quote__c q = getScenario(scenarioId);
            return cloneScenario(customerId, salesSiteId, newQuoteId, scenarioId, false, q.Price_Valid_From__c, q.Price_Valid_To__c, null, null, null);
        } catch(Exception e) {
            throw new CloneException(System.Label.Quote_Util_No_Active);
        }
    }
    
    
    public static Quote__c cloneScenario(Id scenarioId, Id quoteId) {
        
        Quote__c q = getScenario(scenarioId);
        
        return cloneScenario(null, null, quoteId, scenarioId, false, q.Price_Valid_From__c, q.Price_Valid_To__c, null, null, null);
    }
    
    // New version of clone Scenario   rpn 11/09/2013
    public static Quote__c cloneScenario(Id customerId, Id salesSiteId, Id quoteId, Id scenarioId, Boolean isReactivation, Date priceValidFrom, Date priceValidTo, Date quoteValidFrom, Date quoteValidTo, SLIAdjustments adjustments) {
        //Take a save point here
        System.SavePoint sp = Database.setSavepoint();
        Quote__c oldScenario = getScenario(scenarioId);
        string query = getObjectQuery('Quote_Line_Item__c', 'Quote__c = :scenarioId');
        List<Quote_Line_Item__c> qlis = new List<Quote_Line_Item__c>();
        List<Quote_Line_Item__c> oldQlis = database.query(query);
        for (Quote_Line_Item__c oldQLI : oldQlis)
            qlis.add(oldQli.clone(false));
        //List<Quote_Line_Item__c> qlis = oldScenario.Quote_Line_Items__r.deepClone(false);
        if(qlis.size() > 100 & [SELECT count() FROM AsyncApexJob WHERE Status = 'Processing' OR Status = 'Queued'] > 4) {
            oldScenario.Clone_Error__c = true;
            update oldScenario;
            return oldScenario;
        }
        
        Quote__c newScenario = oldScenario.clone(false, true);
        newScenario.Date_Published_to_SAP__c = null;
        newScenario.Published__c = false;
        newScenario.Approval_Notes__c = null;
        //changed from System.Label.Approval_Status_Brand_New to 'Brand New'
        newScenario.Approval_Status__c = 'Brand New';
        newScenario.Price_Valid_From__c = priceValidFrom;
        newScenario.Price_Valid_To__c = priceValidTo; 
        if(quoteValidFrom != null) {  
            newScenario.Quote_Valid_From__c = quoteValidFrom;
        }
        if(quoteValidTo != null) {
            newScenario.Quote_Valid_To__c = quoteValidTo;
        }
        newScenario.Active_Quote__c = true;
        newScenario.Quote_Accepted_By_Customer__c = 'No';
        newScenario.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and Name = 'Scenario New'].Id;
        newScenario.Previously_Approved__c = oldScenario.Approval_Status__c == 'Approved' ? true : newScenario.Previously_Approved__c; 
        
        // Set customer defaults
        if (customerId != null) {
            newScenario.Customer__c = customerId;
            setCustomerDefaults(customerId, newScenario);
        } else {
            if(newScenario.Customer__c == null) {
                throw new CloneException(System.Label.CloneNoAcct);
            }
            setCustomerDefaults(newScenario.Customer__c, newScenario);
        }
        
        // Set customer sales site defaults
        if (salesSiteId != null && customerId != null) {
            newScenario.Sales_Organization_Primary__c = salesSiteId;
            setCustomerSalesSiteDefaults(customerId, salesSiteId, newScenario);
        }
        else if (salesSiteId != null && customerId == null) {
            newScenario.Sales_Organization_Primary__c = salesSiteId;
            setCustomerSalesSiteDefaults(newScenario.Customer__c, salesSiteId, newScenario);
        }
        else {
            setCustomerSalesSiteDefaults(newScenario.Customer__c, newScenario.Sales_Organization_Primary__c, newScenario);
        }
            
        if (quoteId != null) {
            newScenario.Opportunity__c = quoteId;
            newScenario.Sales_Organization_Primary__c = [SELECT Sales_Site__c FROM Opportunity WHERE Id = :quoteId].Sales_Site__c;
        }
            
        // Set scenario version
        system.debug('rick1');
        if (isReactivation) {
            system.debug('rick2');
            Quote__c activeVersion = [Select Id, Version_Number__c from Quote__c where Opportunity__c =: newScenario.Opportunity__c and Active_Quote__c = true];
            newScenario.Version_Number__c = String.valueOf(Integer.valueOf(activeVersion.Version_Number__c) + 1);
            activeVersion.Active_Quote__c = false;
            update activeVersion;
        }
        else if (oldScenario.Opportunity__c == quoteId) {
            system.debug('rick3');
            newScenario.Version_Number__c = String.valueOf(Integer.valueOf(newScenario.Version_Number__c) + 1);
        } else
            newScenario.Version_Number__c = '1';
            
        if (!isReactivation && oldScenario.Opportunity__c == quoteId) {
            oldScenario.Active_Quote__c = false;
            update oldScenario;
        }
        
        insert newScenario;
        newScenario = getScenario(newScenario.Id);
            
        // Price and cost quote lines
        Integer oldScenarioLineItemCount = oldQlis.size();
        
        // Group line items by the following criteria
        // 1. Source Sales Site == Scenario.Sales_Site__c
        // 2. Source Sales Site != Scenario.Sales_Site__c
        // 3. Formula_Flag__c = true
        List<Id> materialIds = new List<Id>();
        List<MaterialFormula> materialFormulas = new List<MaterialFormula>();
        List<Id> formulaMaterialIds = new List<Id>();   
        List<Id> formulaSiteIds = new List<Id>();
        List<Id> formulaSourceSiteIds = new List<Id>();
        List<Quote_Line_Item__c> extendedSLIs = new List<Quote_Line_Item__c>();
        List<Quote_Line_Item__c> unextendedSLIs = new List<Quote_Line_Item__c>();
        List<Id> unextendedMaterialIds = new List<Id>();
        for (Quote_Line_Item__c item : qlis) {
            
            if (item.Formula_Flag__c) {
                materialFormulas.add(new MaterialFormula(item, item.Formula__c, item.Source_Sales_Site__c));
                formulaSiteIds.add(item.Sales_Site__c);
                formulaSourceSiteIds.add(item.Source_Sales_Site__c);
                formulaMaterialIds.add(item.Material_Item__c);
            } else {
                materialIds.add(item.Material_Item__c);
                extendedSLIs.add(item);             
            }
                
        }
        
        //We need to handle properly recreating SLI e.g. pulling the correct pricing rules and cost for each of the cases.
        //This essentially entails three things.  
        //  1) Copy data from existing sli to new version of sli...replace price valid from and to with that on the new scenario, new scenario lookup
        //  2) Find the correct pricing rules to obtain per, uom, target, floor...I would think keep actual as is
        //  3) Find the correct material cost to obtain cost.
        //  For formulaic
        //      Step 1 ok, Step 2 is more like find formula mapping, take per and uom from it, go to formula get value, formula text, 
        //      and formula from it, Step 3 Ok
        //  For at site
        //      Step 1 ok, Step 2 ok, Step 3 ok Try to use calculate cost
        //  For not at site
        //      Step 1 ok, Step 2 ok, Step 3 ok Try to use calculate cost
        
        Id companyId = [SELECT Company_Site__c FROM Sales_Site__c WHERE Id = :newScenario.Sales_Organization_Primary__c LIMIT 1].Company_Site__c;
        Quote__c aQuote = [SELECT Opportunity__r.AccountId, Opportunity__r.Pricing_Sales_Office__c, Opportunity__r.Customer_Group__c, Name FROM Quote__c WHERE Id = :newScenario.Id LIMIT 1];
        system.debug('rick4');
        if(materialFormulas.size() > 0) {
            system.debug('rick5');
            cloneFormulaicSLI(newScenario, materialFormulas, formulaMaterialIds, formulaSiteIds, formulaSourceSiteIds, aQuote.Opportunity__r.AccountId);
        }
        system.debug('rick6');
        if(materialIds.size() > 0) {
            system.debug('rick7');
            if(extendedSLIs.size() + unextendedSLIs.size() > 1000) {  //was 125 - changed rpn 11/09/2013
                system.debug('rick8');
                newScenario.Being_Cloned__c = true;
                update newScenario;
                String emailAddy = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Email;
                system.debug(emailAddy);
                SLICloneBatch sliCB = new SLICloneBatch([SELECT Name FROM Quote__c WHERE Id = :newScenario.Id].Name, ApexPages.currentPage().getHeaders().get('Host') + '/' + newScenario.Id, emailAddy, newScenario, oldScenario.Id, extendedSLIs, customerId, companyId, aQuote.Opportunity__r.Customer_Group__c, adjustments); 
                system.debug('rick9');
                Database.executeBatch(sliCB, 25);
            } else {
                system.debug('rick10');
                        
                //Get a list of pricing rules from the material Ids
                List<Pricing_Rule__c> materialIdsWithPRules = [SELECT Id,Material_Item__c FROM Pricing_Rule__c WHERE Pricing_Sales_Office__c=: aQuote.Opportunity__r.Pricing_Sales_Office__c AND Material_Item__c in:materialIds AND Customer_Group__c like : aQuote.Opportunity__r.Customer_Group__c];
                List<Id> materialItemIds = new List<Id>();
                Set<Id> setMaterialItemIds = new Set<Id>();
                //filter Ids and get a list of Ids with pricing rules for the new pricing sales office/Account
                for (Pricing_Rule__c MPR : materialIdsWithPRules){
                    materialItemIds.add(MPR.Material_Item__c);
                    setMaterialItemIds.add(MPR.Material_Item__c);
                }
                //Get all materials that do not have pricing rules for for the new pricing sales office/Account
                Set<Id> MaterialItemIdsWithNoPR = new Set<Id>();
                //List<Pricing_Rule__c> materialIdsWithNoPRules = [SELECT Id,Material_Item__c FROM Pricing_Rule__c WHERE Material_Item__c in:materialIds AND Pricing_Sales_Office__c !=: aQuote.Opportunity__r.Pricing_Sales_Office__c  AND Customer_Group__c like : aQuote.Opportunity__r.Customer_Group__c];
                for (Id mNPR : materialIds){
                    if(materialItemIds.contains(mNPR)){
                        system.debug('Nothing');
                    }else{
                       MaterialItemIdsWithNoPR.add(mNPR); 
                    }
                }
                
                if(MaterialItemIdsWithNoPR.size() > 0){
                    sendMail(aQuote.Opportunity__r.Pricing_Sales_Office__c, MaterialItemIdsWithNoPR, aQuote.Name);
                }
                //end
                
                cloneStandardSLI(newScenario, extendedSLIs, materialItemIds, aQuote.Opportunity__r.AccountId, companyId, aQuote.Opportunity__r.Customer_Group__c, adjustments); 
            }
        }
        
        return newScenario; 
        
    }
    
    //Email Materials With No Pricing Rule in the Pricing Sales office
    private static void sendMail(string pricingSalesOffice, Set<Id> materialRejectedList, String scenarioName){
        
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // String to hold to Address.
        List<String> toAddresses = new List<String>();
        string userEmail = Userinfo.getUserEmail();
        toAddresses.add(userEmail);
        
        // String to hold to ccAddresses
        List<String> ccAddresses = new List<String>();
        if (userEmail != system.Label.first_cc_email_for_cloned_quote_missing_item ){
            ccAddresses.add(system.Label.first_cc_email_for_cloned_quote_missing_item);
        }
        
        if (userEmail != system.Label.second_cc_email_for_cloned_quote_missing_item ){
            ccAddresses.add(system.Label.second_cc_email_for_cloned_quote_missing_item);
        }
        
        List<Material_Item__c> materialList = [SELECT Id,Material_Code__c FROM Material_Item__c WHERE Id In: materialRejectedList];
        list<String> emailBody = new list<String>();
        emailBody.add(system.Label.Email_message_for_missing_item_on_cloned_quote);
        for (Material_Item__c mat : materialList){
           emailBody.add(' <a href=\'' + ApexPages.currentPage().getHeaders().get('Host') + '/' + mat.Id + '\'> ' + mat.Material_Code__c + ' </a><br>');
        }
        emailBody.add('<br><p>Thank you.<br><p>Dyno Nobel</p>');
                
        String allmaterialList = String.join(emailBody,' ');
        string message = allmaterialList;
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        
        //mail.setReplyTo(system.Label.Recipient_email_for_cloned_quote_missing_item);
        mail.setSenderDisplayName('Dyno Nobel');
        mail.setSubject('List of Material Items Dropped from Quote Cloned. The New Quote is' + scenarioName);
        mail.setHtmlBody(message);
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //system.debug('The email status : '+ lResult[0].success);
    }
    
    public static void cloneStandardSLI(Quote__c newScenario, List<Quote_Line_Item__c> extendedSLIs, List<Id> materialIds, Id customerId, Id companyId, String customerGroup, SLIAdjustments adjustments) {
        List<Quote_Line_Item__c> extendedSLI = new List<Quote_Line_Item__c>();
        Quote_Line_Item__c currentLine;
        
        Opportunity parentQuote = [SELECT Pricing_Region__c, Pricing_Sales_Office__c FROM Opportunity WHERE Id = :newScenario.Opportunity__c LIMIT 1];
        
        system.debug('Scott PricingReg clonestandar ' + parentQuote.Pricing_Region__c);
        system.debug('Scott Pricing Office clonestandar ' + parentQuote.Pricing_Sales_Office__c);
        system.debug('Scott Date from ' + newScenario.Price_Valid_From__c);
        system.debug('Scott Price Valid to ' + newScenario.Price_Valid_To__c);
                
        List<Material_Item__c> materialDetails = [SELECT Id, Name, Material_Code__c, Material_Description__c, Product_Hierarchy__c, Preferred__c FROM Material_Item__c WHERE Id in :materialIds];
        
        //Lets just immediately get rid of ones with null data
        //Something wrong with this call to getPricingData its returning 0 rows.
        List<PricingEngine.PricingData> pdList = new List<PricingEngine.PricingData>();
        //String additionalFailures = '';
        transient Set<Id> pePdIds = new Set<Id>();
        
        //Check if materialIds have pricing Rule
        
        //  

        //for(PricingEngine.PricingData pePd : PricingEngine.getPricingData(customerId, newScenario.Sales_Organization_Primary__c, materialIds, newScenario.Price_Valid_From__c, newScenario.Price_Valid_To__c, companyId, null, customerGroup, true, materialDetails, newScenario.Sales_Organization_Primary__c, false, parentQuote.Pricing_Region__c)) {
        for(PricingEngine.PricingData pePd : PricingEngine.getPricingData(customerId, newScenario.Sales_Organization_Primary__c, materialIds, newScenario.Price_Valid_From__c, newScenario.Price_Valid_To__c, companyId, null, customerGroup, true, materialDetails, newScenario.Sales_Organization_Primary__c, false, parentQuote.Pricing_Region__c,parentQuote.Pricing_Sales_Office__c)) {
            if(pePd.costData != null) {
                pdList.add(pePd);
                pePdIds.add(pePd.materialId);
            } 
            
            /*
            else {
                additionalFailures += 'The material with id: ' + pePd.materialId + ' could not be added because a cost could not be found.  ';
            }
            */
        }

        /*
        if(extendedSLIs.size() != pdList.size()) {
            for(Id currMatId : materialIds) {
                if(!pePdIds.contains(currMatId)) {
                    additionalFailures += 'The material with id: ' + currMatId + ' could not be added because an applicable pricing rule could not be found.  ';
                }
            }
        }


        if(additionalFailures != '') {
            throw new CloneException(additionalFailures);
        }*/
        
        //Get all AUMS for the extended SLIS
        List<String> aunList = new List<String>();
        for(Quote_Line_Item__c currSli : extendedSLIs) {
            aunList.add(currSli.UoM__c);
        }
        system.debug(extendedSLIs);
        List<Alternate_Unit_of_Measure__c> allAums = [SELECT AUn__c, BUn__c, X__c, Y__c, Material_Item__c FROM Alternate_Unit_of_Measure__c WHERE Material_Item__c in :materialIds AND AUn__c in :aunList];
        Map<String, Alternate_Unit_of_Measure__c> stringToAum = new Map<String, Alternate_Unit_of_Measure__c>();
        for(Alternate_Unit_of_Measure__c currAum : allAums) {
            stringToAum.put(currAum.Material_Item__c + '|' + currAum.BUn__c + '|' + currAum.AUn__c, currAum);
        }
        Alternate_Unit_of_Measure__c tempAUM;       
        Boolean found;
        Integer count1 = 0, count2 = 0;
        for(Quote_Line_Item__c currSli : extendedSLIs) {
            found = false;
            currentLine = new Quote_Line_Item__c();
            currentLine = currSli.clone(false, true);
            currentLine.Quote__c = newScenario.Id;
            currentLine.Price_Valid_From__c = newScenario.Price_Valid_From__c;
            if (!currentLine.Lock_Expiration_Date__c)
                currentLine.Price_Valid_To__c = newScenario.Price_Valid_To__c;
            
            if(!currentLine.Is_Bundled__c) {
                currentLine.Floor_Price__c = null;
                currentLine.Target_Price__c = null;
                currentLine.Pricing_Rule__c = null;
            }
            
            //Iterate over PricingData filling in the nulled out fields above
            String baseUoM = null;
            Integer basePer = null;
            for(PricingEngine.PricingData pePd : pdList) {
                system.debug('ttest:' + pdList.size());
                system.debug('>' + pePd.materialId + '<->' + currentLine.Material_Item__c + '<:' + currentLine.Is_Bundled__c);
                if(pePd.materialId == currentLine.Material_Item__c && !currentLine.Is_Bundled__c) {
                    if (currentLine.Per__c == null || currentLine.Per__c == 0)
                        currentLine.Per__c = 1;
                    if (pePd.costData.cost3m != null && pePd.costData.cost3m > 0)
                        currentLine.Base_Cost__c = pePd.costData.cost3m;
                    else if (pePd.costData.cost6m != null && pePd.costData.cost6m > 0)
                        currentLine.Base_Cost__c = pePd.costData.cost6m;
                    else
                        currentLine.Base_Cost__c = pePd.costData.cost;
                    System.Debug('Material Item - ' + pePd.materialId + ' - ' + currentLine);
                    currentLine.Base_Floor__c = pePd.rule.Floor_Price__c;
                    currentLine.Base_Target__c = pePd.rule.Target_Price__c;
                    currentLine.Cost__c = currentLine.Base_Cost__c / (1/currentLine.Per__c);                    
                    if (pePd.costData.seeThroughCost3m != null && pePd.costData.seeThroughCost3m > 0)
                        currentLine.Base_Cost_ST__c = pePd.costData.seeThroughCost3m;
                    else if (pePd.costData.seeThroughCost6m != null && pePd.costData.seeThroughCost6m > 0)
                        currentLine.Base_Cost_ST__c = pePd.costData.seeThroughCost6m;
                    else
                        currentLine.Base_Cost_ST__c = pePd.costData.seeThroughCost;
                    currentLine.Cost_See_Through__c = currentLine.Base_Cost_ST__c / (1/currentLine.Per__c);
                    currentLine.Floor_Price__c = pePd.rule.Floor_Price__c;
                    currentLine.Target_Price__c = pePd.rule.Target_Price__c;
                    if (adjustments != null)
                        for (SLIAdjustments.PAndQAdjustment pqa : adjustments.Adjustments)
                            if (pqa.PHL1 == currSli.PHL1__c) {
                                system.debug('ttest.before:' + currentLine.Actual_Price__c);
                                currentLine.Quantity__c = currentLine.Quantity__c * (100 + pqa.QuantityAdjustment) / 100;
                                currentLine.Actual_Price__c = (currentLine.Actual_Price__c * (100 + pqa.PriceAdjustment) / 100).setScale(2);
                                system.debug('ttest.after:' + currentLine.Actual_Price__c);
                            }
                    //currentLine.Per__c = pePd.per;
                    basePer = pePd.per;
                    currentLine.Pricing_Rule__c = pePd.rule.Id;
                    baseUoM = pePd.uom;
                    found = true;
                } else if(currentLine.Is_Bundled__c) {
                    found = true;
                }
            }
            
            
            if(found) {         
                //Get the AUM for the currentLines Material where bun is that on the pePd and the aun is uom on the currSli
                //AUM Key can be: materialId|bun|aun
                //If we find it, use it to scale Floor, Target
                //If we dont find it, throw a CloneException we dont care where the error bubbles up to.            
                tempAUM = stringToAum.get(currentLine.Material_Item__c + '|' + baseUoM + '|' + currentLine.UoM__c);
                if(tempAUM == null && !currentLine.Is_Bundled__c) {
                    system.debug('test1');
                    throw new CloneException('There is no Alternate Unit of Measure for the Material with ID: ' + currentLine.Material_Item__c + ' where BUn is ' + baseUoM + ' and the AUn is ' + currentLine.UoM__c + '.  To resolve this error please add this Alternate Unit of Measure.');
                } else if(!currentLine.Is_Bundled__c) {
                    system.debug('test2');
                    currentLine.Cost__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Cost_See_Through__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Base_Cost__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Base_Cost_ST__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Base_Floor__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Base_Target__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Floor_Price__c *= (currentLine.Per__c / basePer);
                    currentLine.Target_Price__c *= (currentLine.Per__c / basePer);
                    currentLine.Floor_Price__c *= tempAUM.X__c/tempAUM.Y__c;
                    currentLine.Target_Price__c *= tempAUM.X__c/tempAUM.Y__c;
                }
                count1++;
                if((currentLine.Cost__c != null && currentLine.Pricing_Rule__c != null) || currentLine.Is_Bundled__c) {
                    extendedSLI.add(currentLine);
                    count2++;
                }
            }
            
        }

        if(extendedSLI.size() > 0) {
            insert extendedSLI;
        }
    }
    
    private static void cloneFormulaicSLI(Quote__c newScenario, List<MaterialFormula> materialFormulas, List<Id> formulaMaterialIds, List<Id> formulaSiteIds, List<Id> formulaSourceSiteIds, Id customerId) {
        List<Quote_Line_Item__c> formulaicSLI = new List<Quote_Line_Item__c>();
        Quote_Line_Item__c currentLine;
        
        //Formula Mapping Query
        String query = 'SELECT Id, Formula__c, Formula__r.Material_Item__c, Per__c, UoM__c, Formula__r.Formula_Text__c, Sales_Site__c, Source_Sales_Site__c FROM Formula_Mapping__c WHERE Customer__c = \'' + customerId + '\' AND (';
        for(Integer i = 0; i < formulaSiteIds.size(); i++) {
            if(i > 0) {
                query += ' OR';
            }
            query += ' ( Formula__r.Material_Item__c = \'' + formulaMaterialIds.get(i) + '\' AND Sales_Site__c = \'' + formulaSiteIds.get(i) + '\' AND Source_Sales_Site__c = \'' + formulaSourceSiteIds.get(i) + '\' )';
        }
        query += ' )';
        System.debug('MAPPING QUERY = ' + query);
        List<Formula_Mapping__c> theMappings = Database.query(query);
        
        //Cost Query
        query = 'SELECT Id, Material_Item__c, Sales_Site__c, Cost__c, X3_Month_Cost__c, X6_Month_Cost__c FROM Material_Cost__c WHERE';
        for(Integer i = 0; i < formulaSourceSiteIds.size(); i++) {
            if(i > 0) {
                query += ' OR';
            }
            query += ' ( Sales_Site__c = \'' + formulaSourceSiteIds.get(i) + '\' AND Material_Item__c = \'' + formulaMaterialIds.get(i) + '\' )';   
        }
        System.debug('COST QUERY = ' + query);
        List<Material_Cost__c> theCosts = Database.query(query);
        
        //Formula Line Item Query
        //Iterate over mappings gathering the formulas
        List<Id> formulaIdList = new List<Id>();
        for(Formula_Mapping__c currFm : theMappings) {
            formulaIdList.add(currFm.Formula__c);
        }
        //Query for FLI where the formula is in the list
        List<Formula_Line_Item__c> fliList = [Select Id, Formula__c, Formula_Component__r.Name, Formula_Component__r.Value__c, Formula_Component__r.Group__c From Formula_Line_Item__c where Formula__c in :formulaIdList order by Formula__c];
        
        //Create a mapping from formula id to a list of FLIs
        Id currId = null;
        Map<Id, List<Formula_Line_Item__c>> idToFli = new Map<Id, List<Formula_Line_Item__c>>();
        List<Formula_Line_Item__c> tempFliList;             
        for(Formula_Line_Item__c currFli : fliList) {
            if(currId != currFli.Formula__c) {
                if(currId != null) {
                    idToFli.put(currId, tempFliList);
                }
                tempFliList = new List<Formula_Line_Item__c>();
                currId = currFli.Formula__c;
            }
            tempFliList.add(currFli);
        }
        idToFli.put(currId, tempFliList);
        
        for(MaterialFormula mf : materialFormulas) {
            currentLine = new Quote_Line_Item__c();
            currentLine = mf.sli.clone(false, true);
            currentLine.Quote__c = newScenario.Id;
            currentLine.Price_Valid_From__c = newScenario.Price_Valid_From__c;
            currentLine.Price_Valid_To__c = newScenario.Price_Valid_To__c;
            
            //Reset stuff we have to get from mappings and material cost
            currentLine.Cost__c = null;
            currentLine.Actual_Price__c = null;
            currentLine.Floor_Price__c = 0.00;
            currentLine.Target_Price__c = 0.00;
            
            //Assign the cost
            for(Material_Cost__c currCost : theCosts) {
                if(currCost.Material_Item__c == currentLine.Material_Item__c && currCost.Sales_Site__c == currentLine.Source_Sales_Site__c) {
                    if (currCost.X3_Month_Cost__c != null && currCost.X3_Month_Cost__c > 0)
                        currentLine.Cost__c = currCost.X3_Month_Cost__c;
                    else if (currCost.X6_Month_Cost__c != null && currCost.X6_Month_Cost__c > 0)
                        currentLine.Cost__c = currCost.X6_Month_Cost__c;
                    else
                        currentLine.Cost__c = currCost.Cost__c;
                    currentLine.Cost_See_Through__c = currCost.Cost__c;
                }
            }
            
            //Assign the per, uom, value, formula, formula text
            for(Formula_Mapping__c currFm : theMappings) {
                if(currFm.Sales_Site__c == currentLine.Sales_Site__c && currFm.Source_Sales_Site__c == currentLine.Source_Sales_Site__c
                 && currFm.Formula__r.Material_Item__c == currentLine.Material_Item__c) {
                    currentLine.Per__c = currFm.Per__c;
                    currentLine.UoM__c = currFm.UoM__c;
                    currentLine.Formula__c = currFm.Formula__c;
                    currentLine.Formula_Text__c = currFm.Formula__r.Formula_Text__c;
                    currentLine.Actual_Price__c = FormulaProcessor.process(currentLine.Formula_Text__c, idToFli.get(currentLine.Formula__c));
                }
            }
            
            if(currentLine.Cost__c != null && currentLine.Actual_Price__c != null) {
                formulaicSLI.add(currentLine);
            }
        }
        if(formulaicSLI.size() > 0) {
            insert formulaicSLI;        
        }
    }
    
    public class MaterialFormula {
        public Quote_Line_Item__c sli {get; set;}
        public Id formulaId {get; set;}
        public Id sourceSalesSiteId {get; set;}
        
        public MaterialFormula(Quote_Line_Item__c qli, Id formulaId, Id sourceSalesSiteId) {
            this.sli = qli;
            this.formulaId = formulaId;
            this.sourceSalesSiteId = sourceSalesSiteId;
        }
    }
    
    public class CloneException extends Exception {}
    
    private static void setCustomerDefaults(Id customerId, Quote__c scenario) {
        Account customerMaster = [Select On_Contract__c, AN_Formula_Pricing__c from Account where Id = :customerId];
        scenario.On_Contract__c = customerMaster.On_Contract__c;
        scenario.AN_Formula_Pricing__c = customerMaster.AN_Formula_Pricing__c;
    }
    private static void setCustomerSalesSiteDefaults(Id customerId, Id salesSiteId, Quote__c scenario) {
        Customer_Sales_Site__c css = [Select Payment_Terms__c, CurrencyIsoCode, Pricelist__c, INCO__c, Delivery_Sales_Site__c, Service_Type__c, Drilled_By__c, Customer_Group__c from Customer_Sales_Site__c where Customer__c =:customerId And Sales_Site__c = :salesSiteId];
        scenario.Payment_Terms__c = css.Payment_Terms__c;
        scenario.CurrencyIsoCode = css.CurrencyIsoCode;
        scenario.Sales_Organization_Primary__c = salesSiteId;
        scenario.Pricelist__c = css.Pricelist__c;
        scenario.Inco_Terms__c = css.INCO__c;
        scenario.Delivery_Sales_Site__c = css.Delivery_Sales_Site__c;
        scenario.Service_Type__c = css.Service_Type__c;
        scenario.Drilling_Provided_By__c = css.Drilled_By__c;
        //scenario.Customer_Group__c = css.Customer_Group__c;
    }
    
    public static Quote_Line_Item__c addQuoteLine(Id quoteId, Id materialId, Integer quantity, Decimal actualPrice, Decimal cost) {
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        
        qli.Cost__c = cost;
        qli.Cost_See_Through__c = cost;
        qli.CurrencyIsoCode = 'USD';
        qli.Material_Item__c = materialId;
        qli.Price_Valid_From__c = System.today();
        qli.Price_Valid_To__c = System.today();
        qli.Actual_Price__c = actualPrice;
        qli.Quote__c = quoteId;
        qli.Quantity__c = quantity;
        
        try {
            insert qli;
        }
        catch (System.DmlException de) {
            System.debug(de.getDmlFieldNames(0));
            System.debug(de.getDmlMessage(0));
            throw de;
        }
        return qli;
    }
    
    //addFormulaQuoteLine(q.Id, testFormula.Id, 5, 1, 'EA');
    @TestVisible
    private static Quote_Line_Item__c addFormulaQuoteLine(Id quoteId, Id formulaId, Integer quantity, Integer per, String uom, Decimal cost) {
        Formula__c formula = [Select Formula_Text__c, Material_Item__c, (Select Formula_Component__r.Name, Formula_Component__r.Value__c from Formula_Line_Items__r) from Formula__c where Id =:formulaId];
        System.debug(formula.Formula_Text__c);
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        
        qli.Cost__c = cost;
        qli.Cost_See_Through__c = cost;
        qli.CurrencyIsoCode = 'USD';
        qli.Material_Item__c = formula.Material_Item__c;
        qli.Price_Valid_From__c = System.today();
        qli.Price_Valid_To__c = System.today();
        qli.Actual_Price__c = FormulaProcessor.process(formula.Formula_Text__c, formula.Formula_Line_Items__r);
        System.debug(qli.Actual_Price__c);
        qli.Formula_Flag__c = true;
        qli.Formula__c = formulaId;
        qli.Per__c = per;
        qli.UoM__c = uom;
        qli.Quote__c = quoteId;
        qli.Quantity__c = quantity;
        insert qli;
        
        return qli;
    }
    
    public static string getObjectQuery(String objectName, String whereClause){
 
        String selects = '';

        if (whereClause == null || whereClause == '')
            return null;
 
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>(); 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
                //if (fd.isCreateable()){
                selectFields.add(fd.getName());
                //}
            }
        }
 
        if (!selectFields.isEmpty()){
            for (string s:selectFields)
                selects += s + ',';
            if (selects.endsWith(','))
                selects = selects.substring(0,selects.lastIndexOf(','));
 
        }
 
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
 
    }
    
    @TestVisible
    private static Quote__c getScenario(Id scenarioId) {
        string query = getObjectQuery('Quote__c', 'Id = :scenarioId');
        return database.query(query);
        //return [Select q.RCS__c, q.Being_Cloned__c, q.Fuel_Surcharge_FCS__c, q.Volumetric_Per__c, q.Quote_Accepted_By_Customer__c, q.Stored_Ebit__c, q.Below_Floor_Reason__c, q.Scenario_Notes__c, q.Volumetric_Parent_Product__c, q.Volumetric_Parent_Product_UoM__c, q.Total_Number_of_Invoices__c, q.Volume_to_be_Blasted__c, q.Volume_of_Explosives__c, q.Volume_of_Explosives_UoM__c, q.Volume_UoM__c, q.Volume_Produced__c, q.Volume_Produced_UoM__c, q.Vice_President__c, q.Version_Number__c, q.UoM__c, q.Trial__c, q.Technical_Services_Required__c, q.Target_Win__c, q.Target_Price_Rollup__c, q.Take_or_Pay_Contract__c, q.Subdrill__c, q.Subdrill_UoM__c, q.Street_House_Number__c, q.Stemming__c, q.Stemming_UoM__c, q.State_Province__c, q.Spacing__c, q.Spacing_UoM__c, q.Shot_Service_Load_Assistance_Hours__c, q.Shot_Service_Hours__c, q.Service_Type__c, q.Sales_Organization_Primary__c, q.Round_Trip_Truck_Distance__c, q.Rock_Specific_Gravity__c, q.Risk_Assesment__c, q.Rental_Equipment_Required__c, q.Regional_Ops_Manager__c, q.Reason_Comments__c, q.RSM__c, q.Quote_Valid_To__c, q.Quote_Valid_From__c, q.Quote_Description__c, q.Promotional__c, q.Product_Industry_Manager__c, q.Pricing_Manager__c, q.Pricelist__c, q.Price_Valid_To__c, q.Price_Valid_From__c, q.Price_Adjustment__c, q.Previously_Approved__c, q.Potential_Cash_Discount__c, q.Post_Zip_Code__c, q.Per_Event__c, q.Payment_Terms__c, q.Opportunity__c, q.On__c, q.On_Contract__c, q.Number_of_Holes__c, q.Loaded_Volume__c, q.Loaded_Volume_UoM__c, q.Is_Additional_Capital_Required__c, q.Industry_Manager__c, q.Inco_Terms__c, q.Holes_per_Event__c, q.Hole_Diameter__c, q.Hole_Diameter_UoM__c, q.Hole_Depth__c, q.Hole_Depth_UoM__c, q.Have_You_Spoken_to_Operations__c, q.Finance__c, q.Estimated_Events_Project__c, q.Drilling_Provided_By__c, q.Dewatering_Required__c, q.Delivery_Sales_Site__c, q.Delivery_Hours__c, q.Delivery_Direct_to_Customer_Site__c, q.Customer__c, q.Customer_Group__c, q.CurrencyIsoCode, q.County__c, q.Country__c, q.City__c, q.Caps_On_Escalation__c, q.Cap_Details__c, q.Burden__c, q.Burden_UoM__c, q.Blast_Pattern_UoM__c, q.Bench_Height__c, q.Bench_Height_UoM__c, q.Are_Additional_People_Required__c, q.Approval_Status__c, q.Annual_Number_of_Events__c, q.Alternate_Address_Detail__c, q.Active_Quote__c, q.AccountReference__c, q.AN_Formula_Pricing__c, (Select Extended__c, CurrencyIsoCode, Quote__c, Actual_Price__c, Available_Credit_Limit__c, Avg_Sell_Price__c, Bundled_Flag__c, Calculated_Monthly_Purchases__c, Credit_Limit__c, Description__c, Floor_Price__c, Formula__c, Formula_Flag__c, MFN_Flag__c, Material_Item__c, Monthly_Purchases__c, Notify_Credit__c, Per__c, Percent__c, Sales_Site__c, Price_Valid_From__c, Price_Valid_To__c, Pricing_Rule__c, Quantity__c, Reason__c, Source_Sales_Site__c, Target_Price__c, UoM__c, Volume_Based__c, Country__c, Cost__c, Discount_Surcharge__c, Discount_Surcharge_Terms__c, Discount_Amount__c, AUn__c, Adder_Notes__c, Substitution__c, Substitution_Comments__c, Is_Bundled__c, Cost_See_Through__c, Product_Description__c From Quote_Line_Items__r) From Quote__c q where Id =: scenarioId];
    }
    
}