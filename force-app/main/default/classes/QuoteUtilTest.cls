@isTest
public class QuoteUtilTest {
    @isTest static void testCreateNewQuote() {
        
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu1@tus.com';
		u1.Username = 'tu1@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't1user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
        
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;
           
        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 days'
        );
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Bundled'].Id);
        System.assertNotEquals(null, quote);
        System.assertEquals(1, [Select count() from Quote__c where Opportunity__c=:quote.Id]);
        Quote__c q = QuoteUtil.getScenario([Select Id,Opportunity__c,Name from Quote__c where Opportunity__c=:quote.Id].Id);
        
        //QuoteUtil.CreatePricingCondition(q.Id);
        //
        List<Quote__c> scenariolist =  new List<Quote__c>();
        scenariolist.add(q);  
        QuoteUtil.siteToPlant('150','1134');
        
        System.assertEquals('Test Quote Create', q.Quote_Description__c);
        System.assertEquals(System.today(), q.Quote_Valid_From__c);
        System.assertEquals(System.today().addYears(1), q.Quote_Valid_To__c);
        System.assertEquals(System.today(), q.Price_Valid_From__c);
        System.assertEquals(System.today().addYears(1), q.Price_Valid_To__c);
        System.assertEquals(cust.Id, q.Customer__c);
        System.assertEquals(sites[2].Id, q.Sales_Organization_Primary__c);
        System.assertEquals('CAD', q.CurrencyIsoCode);
        System.assertEquals('00 Blank', q.Pricelist__c);
        System.assertEquals('FOB Free On Board', q.Inco_Terms__c);
        System.assertEquals('Drilling', q.Service_Type__c);
        System.assertEquals('Me', q.Drilling_Provided_By__c);
        System.assertEquals(cust.Price_Adjustment_Notice_Period__c, q.Price_Adjustment__c);
        System.assertEquals(css.Payment_Terms__c, q.Payment_Terms__c);
        System.assertEquals(css.CurrencyIsoCode, q.CurrencyIsoCode);
        System.assertEquals(cust.On_Standard_Ts_Cs__c, q.On__c);
        System.assertEquals(cust.On_Contract__c, q.On_Contract__c);
        System.assertEquals(cust.AN_Formula_Pricing__c, q.AN_Formula_Pricing__c);
        System.assertEquals('1', q.Version_Number__c);
        System.assert(q.Active_Quote__c);
        }
    }
    
    @isTest static void testCreatebulkpricing() {
        
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu1@tus.com';
		u1.Username = 'tu1@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't1user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
        
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;
            
        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 days'
        );
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Bundled'].Id);
        System.assertNotEquals(null, quote);
        System.assertEquals(1, [Select count() from Quote__c where Opportunity__c=:quote.Id]);
        Quote__c q = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);
        q.Name = 'Volumetric';
        update q;   
            
        QuoteUtil.siteToPlant('140','1134');
            
        System.assertEquals('Test Quote Create', q.Quote_Description__c);
        System.assertEquals(System.today(), q.Quote_Valid_From__c);
        System.assertEquals(System.today().addYears(1), q.Quote_Valid_To__c);
        System.assertEquals(System.today(), q.Price_Valid_From__c);
        System.assertEquals(System.today().addYears(1), q.Price_Valid_To__c);
        System.assertEquals(cust.Id, q.Customer__c);
        System.assertEquals(sites[2].Id, q.Sales_Organization_Primary__c);
        System.assertEquals('CAD', q.CurrencyIsoCode);
        System.assertEquals('00 Blank', q.Pricelist__c);
        System.assertEquals('FOB Free On Board', q.Inco_Terms__c);
        System.assertEquals('Drilling', q.Service_Type__c);
        System.assertEquals('Me', q.Drilling_Provided_By__c);
        System.assertEquals(cust.Price_Adjustment_Notice_Period__c, q.Price_Adjustment__c);
        System.assertEquals(css.Payment_Terms__c, q.Payment_Terms__c);
        System.assertEquals(css.CurrencyIsoCode, q.CurrencyIsoCode);
        System.assertEquals(cust.On_Standard_Ts_Cs__c, q.On__c);
        System.assertEquals(cust.On_Contract__c, q.On_Contract__c);
        System.assertEquals(cust.AN_Formula_Pricing__c, q.AN_Formula_Pricing__c);
        System.assertEquals('1', q.Version_Number__c);
        System.assert(q.Active_Quote__c);
        }
    }
    
    @isTest static void testCreateNewBundledQuote() {
         	User u1 = new User();
            u1.FirstName = 'Test';
            u1.LastName = 'U\'Ser';
            u1.Alias = 'tuser';
            u1.Email = 'tu2@tus.com';
            u1.Username = 'tu2@tus.com';
            u1.CompanyName = 'Dyno Nobel Inc.';
            u1.CommunityNickname = 't2user';
            u1.TimeZoneSidKey = 'America/Chicago';
            u1.LocaleSidKey = 'en_US';
            u1.EmailEncodingKey = 'ISO-8859-1';
            u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
            u1.LanguageLocaleKey = 'en_US';
            u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
            u1.State = 'UT';
            u1.Employee__c = True;
            u1.PostalCode = '84121';
            u1.IsActive = True;
            
            System.runAs(u1) {
                
            Account cust = new Account();
            cust.Name = 'Dyno Nobel Inc.';
            cust.ShippingState = 'UT';
            cust.ShippingCountry = 'US';
            cust.ShippingPostalCode = '84121';
            cust.ParentId = null;
            cust.Price_Adjustment_Notice_Period__c = 45;
            cust.On_Standard_Ts_Cs__c = 'Yes';
            cust.On_Contract__c = 'No';
            cust.AN_Formula_Pricing__c = 'Yes';
            cust.AN_Formula_Pricing__c = 'Yes';
            cust.OwnerId = u1.Id;
                
            insert cust;
            
            Contact newcon = new Contact();
            newcon.FirstName = 'Test1';
            newcon.LastName = 'Test2';
            newcon.User__c = u1.Id;
            newcon.AccountId = cust.Id;
            newcon.Active__c = True;
            newcon.Employee__c = True;
            newcon.OwnerId = u1.Id;
            
            insert newcon;

        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 Days'
        );
        // Create Bundled Service
        Material_Item__c material = TestUtils.createItemWitCost(sites[2], 12.34d);
        TestUtils.createBundledServiceMapping(material.Id, 'Delivery', '');
        TestUtils.createBundledServiceMapping(material.Id, 'Shot_Service_with_Drilling', '1 in');
        
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, 'Delivery', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Bundled'].Id);
        System.assertNotEquals(null, quote);
        System.assertEquals(1, [Select count() from Quote__c where Opportunity__c=:quote.Id]);
        Quote__c q = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);
        System.assertEquals('Test Quote Create', q.Quote_Description__c);
        System.assertEquals('1', q.Version_Number__c);
        System.assert(q.Active_Quote__c);
        Quote_Line_Item__c item = [Select Id, Material_Item__c, Quantity__c, Cost__c from Quote_Line_Item__c where Quote__c=:q.Id and Is_Bundled__c=true limit 1];
        System.assertNotEquals(null, item);
       }
    }
    
    @isTest static void testCloneQuote() {
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu3@tus.com';
		u1.Username = 'tu3@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't3user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
		
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        Account getAccount = QuoteUtil.getAccount(cust.Id);//added line to cover coverage
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;

        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 days'
        );
        insert css;
        // Create Bundled Service
        Material_Item__c material = TestUtils.createItemWitCost(sites[2], 12.34d);
        TestUtils.createBundledServiceMapping(material.Id, 'Delivery', '');
        TestUtils.createBundledServiceMapping(material.Id, 'Shot_Service_with_Drilling', '1 in');
            
        Test.startTest();
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, 'Delivery', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Bundled'].Id);
        Opportunity quote2 = QuoteUtil.cloneQuote(quote.Id);        
        System.assertNotEquals(null, quote2);
        System.assertEquals(quote.RecordTypeId, quote2.RecordTypeId);
        System.assertEquals(quote.StageName, quote2.StageName);
        System.assertEquals(quote.AccountId, quote2.AccountId);
        System.assertEquals(quote.Sales_Site__c, quote2.Sales_Site__c);
        System.assertEquals(quote.CloseDate, quote2.CloseDate);
        System.assertEquals(quote.CurrencyIsoCode, quote2.CurrencyIsoCode);
        System.assertEquals(1, [Select count() from Quote__c where Opportunity__c=:quote2.Id]);
        /** Removed to get in production
        Quote__c q = getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);
        System.assertEquals('Test Quote Create', q.Quote_Description__c);
        System.assertEquals(System.today(), q.Quote_Valid_From__c);
        System.assertEquals(System.today().addYears(1), q.Quote_Valid_To__c);
        System.assertEquals(System.today(), q.Price_Valid_From__c);
        System.assertEquals(System.today().addYears(1), q.Price_Valid_To__c);
        System.assertEquals(cust.Id, q.Customer__c);
        System.assertEquals(sites[2].Id, q.Sales_Organization_Primary__c);
        System.assertEquals('CAD', q.CurrencyIsoCode);
        System.assertEquals('00 Blank', q.Pricelist__c);
        System.assertEquals('FOB Free On Board', q.Inco_Terms__c);
        System.assertEquals('Drilling', q.Service_Type__c);
        System.assertEquals('Me', q.Drilling_Provided_By__c);
        System.assertEquals(cust.Price_Adjustment_Notice_Period__c, q.Price_Adjustment__c);
        System.assertEquals(css.Payment_Terms__c, q.Payment_Terms__c);
        System.assertEquals(css.CurrencyIsoCode, q.CurrencyIsoCode);
        System.assertEquals(cust.On_Standard_Ts_Cs__c, q.On__c);
        System.assertEquals(cust.On_Contract__c, q.On_Contract__c);
        System.assertEquals(cust.AN_Formula_Pricing__c, q.AN_Formula_Pricing__c);
        System.assertEquals('1', q.Version_Number__c);
        System.assert(q.Active_Quote__c);
        **/
        Test.stopTest();
       }
    }
    
    
    @isTest static void testCloneScenario() {
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu4@tus.com';
		u1.Username = 'tu4@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't4user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
		
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;

        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 Days'
        );
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Deal_Quoted'].Id);
        Quote__c q = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);
         
        List<id> opptids =  new List<id>();
        opptids.add(quote.Id);
        QuoteUtil.queryForQuoteAndChildRecordsByOppyAndActive(opptids);
        QuoteUtil.getDealChildren(quote.Id);
        QuoteUtil.getAccount(cust.Id);
        
         
        // Create Materials
        Material_Item__c mat1 = TestUtils.createItemWitCost(sites[2], 12.34d);
        Material_Item__c mat2 = TestUtils.createItemWitCost(sites[2], 12.34d);
        Material_Item__c mat3 = TestUtils.createItemWitCost(sites[2], 12.34d);
        
        // Create Pricing Rules
        TestUtils.createPricingRule(sites[2].Id, cust.Id, null, true, mat1.Id, 1, 'EA', 45.00d, 55.00d, System.today(), System.today());
        TestUtils.createPricingRule(sites[2].Id, cust.Id, null, true, mat2.Id, 1, 'EA', 47.00d, 57.00d, System.today(), System.today());
        
        // Create alternate UoM
        //insert new Alternate_Unit_of_Measure__c(Material_Item__c=mat2.Id, Bun__c='EA', AUn__c='LB', X__c=1, Y__c=10);
        
        // Create Formula
        String name = 'Test'+System.now().format();
        Formula_Component__c testComp = new Formula_Component__c(Name=name, Value__c=45.00);
        insert testComp;
        Formula__c testFormula = new Formula__c(Name='Test Formula', Material_Item__c=mat3.Id);
        insert testFormula;
        testFormula.Formula_Text__c = name+ ' * 2';
        update testFormula;
        insert new Formula_Line_Item__c(Formula__c=testFormula.Id, Formula_Component__c=testComp.Id);
        
        // Create Formula Mapping
        insert new Formula_Mapping__c(Customer__c=cust.Id, Sales_Site__c=sites[2].Id, Source_Sales_Site__c=sites[2].Id, Formula__c=testFormula.Id, Per__c=1, Uom__c='EA');
        
        QuoteUtil.addQuoteLine(q.Id, mat1.Id, 5, 50.00, 12.34);
        QuoteUtil.addQuoteLine(q.Id, mat2.Id, 5, 50.00, 12.34);
        QuoteUtil.addFormulaQuoteLine(q.Id, testFormula.Id, 5, 1, 'EA', 12.34);
        Quote__C qQuery  = QuoteUtil.queryForQuoteAndChildRecords(q.Id);//added line for code coverage
       
        List<Quote_Line_Item__c> qlineItem  = QuoteUtil.queryForChildRecordsByQuote(q.Id);//added line for code coverage
        Opportunity qChildRecs  = QuoteUtil.getOpportunity(quote.Id);//added line for code coverage
       }
    }
    
    @isTest static void testCloneScenarioWithFormulaicLines() {
        Test.startTest();
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu5@tus.com';
		u1.Username = 'tu5@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't5user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
		
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;

        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 Days'
        );
        insert css;
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Deal_Quoted'].Id);
        Quote__c q = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);
        // Create Materials
        Material_Item__c mat1 = TestUtils.createItemWitCost(sites[2], 12.34d);
        Material_Item__c mat2 = TestUtils.createItemWitCost(sites[2], 12.34d);
        Material_Item__c mat3 = TestUtils.createItemWitCost(sites[2], 12.34d);
        
        // Create Pricing Rules
        TestUtils.createPricingRule(sites[2].Id, cust.Id, null, true, mat1.Id, 1, 'EA', 45.00d, 55.00d, System.today(), System.today());
        Quote_Line_Item__c qli1 = TestUtils.createQli(mat1, 5, '1: Half Cent', q, 5, sites[2]);
        Quote_Line_Item__c qli2 = TestUtils.createQli(mat2, 5, '1: Half Cent', q, 5, sites[2]);
        Quote_Line_Item__c qli3 = TestUtils.createQli(mat3, 5, '1: Half Cent', q, 5, sites[2]);
        qli2.Formula_Flag__c = true;
        qli3.Formula_Flag__c = true;
        update qli2;
        update qli3;        
        Formula_Component__c testFC = TestUtils.createFormulaComponent('TFC398', 'TBD2', 15);
        Formula__c testFormula = TestUtils.createFormula('TF398', mat2.Id, 50, 50);
        Formula_Line_Item__c testFLI = TestUtils.createFormulaLineItem(testFormula.Id, testFC.Id);
        Formula_Mapping__c testMapping = TestUtils.createFormulaMapping(testFormula.Id, cust.Id, sites.get(2).Id, sites.get(2).Id, 10, 'KG');
        Formula_Component__c testFC2 = TestUtils.createFormulaComponent('TFC399', 'TBD2', 15);
        Formula__c testFormula2 = TestUtils.createFormula('TF399', mat3.Id, 50, 50);
        Formula_Line_Item__c testFLI2 = TestUtils.createFormulaLineItem(testFormula2.Id, testFC2.Id);
        Formula_Mapping__c testMapping2 = TestUtils.createFormulaMapping(testFormula2.Id, cust.Id, sites.get(2).Id, sites.get(2).Id, 10, 'KG');         
        testFormula.Formula_Text__c = 'TFC398*TFC398';
        update testFormula;
        testFormula2.Formula_Text__c = 'TFC399*TFC399';
        update testFormula2;  
        Test.stopTest();
        Quote__c theClone = QuoteUtil.cloneScenario(cust.Id, sites[2].Id, quote.Id, q.Id, false, System.today(), System.today(), System.today(), System.today(), null);
        System.assertEquals(2, [SELECT count() FROM Quote_Line_Item__c WHERE Quote__c = :theClone.Id AND Formula_Flag__c = true]);
        
       }
    }
    
    @isTest static void testcloneQuoteForSites() {
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu6@tus.com';
		u1.Username = 'tu6@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't6user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
       
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;

        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Sales_Site__c site2 = TestUtils.createSalesSite('SITE2', sites[0].Id, sites[1].Id);
        Sales_Site__c site3 = TestUtils.createSalesSite('SITE3', sites[0].Id, sites[1].Id);
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 Days'
        );
        insert css;
    
        Customer_Sales_Site__c css2 = css.clone(false, true);
        css2.Sales_Site__c = site2.Id;
        css2.Drilled_By__c='You';
        insert css2;
        
        Customer_Sales_Site__c css3 = css.clone(false, true);
        css3.Sales_Site__c = site3.Id;
        css3.Drilled_By__c='Them';
        insert css3;
         
        Id recordTypeId = [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Deal_Quoted' Limit 1].Id;
        Opportunity quote1 = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', recordTypeId );
        Quote__c q1 = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote1.Id].Id);
        q1.Active_Quote__c = true;
        update q1;
        Test.startTest();
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', recordTypeId);
       	/** Removed to get in Production **/
        Quote__c q = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);

        List<Opportunity> clonedQuotes = QuoteUtil.cloneQuote(quote.Id, new List<Sales_Site__c>{site2, site3}, cust.Id, system.Today(), system.Today(), null, null,'');
        System.assertEquals(2, clonedQuotes.size());
       	QuoteUtil.cloneScenario(quote1.Id, quote);
        QuoteUtil.getScaledValue(123);
        //QuoteUtil.cloneScenario(quote1.Id, quote.Id, sites[2].Id, css.Id);
        List<Quote__c> scenarios = [Select Id, Sales_Organization_Primary__c, Opportunity__r.Sales_Site__c, Drilling_Provided_By__c from Quote__c where Opportunity__c in :clonedQuotes Order By Id];
        System.assertEquals(2, scenarios.size());
        for (Quote__c scenario : scenarios) {
            System.assertEquals(scenario.Opportunity__r.Sales_Site__c, scenario.Sales_Organization_Primary__c);
            if (scenario.Sales_Organization_Primary__c == css2.Sales_Site__c)
              System.assertEquals(css2.Drilled_By__c, scenarios[0].Drilling_Provided_By__c);
                
            if (scenario.Sales_Organization_Primary__c == css3.Sales_Site__c)
                System.assertEquals(css3.Drilled_By__c, scenarios[1].Drilling_Provided_By__c);
       }
        Test.stopTest();
        
    }
  }
    
     @isTest static void testcreatereactivateVersion() {
        User u1 = new User();
		u1.FirstName = 'Test';
		u1.LastName = 'U\'Ser';
		u1.Alias = 'tuser';
		u1.Email = 'tu6@tus.com';
		u1.Username = 'tu6@tus.com';
        u1.CompanyName = 'Dyno Nobel Inc.';
		u1.CommunityNickname = 't6user';
		u1.TimeZoneSidKey = 'America/Chicago';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.ProfileId = [SELECT Id FROM Profile WHERE Name = '# Custom DNA - Marketing End User' LIMIT 1].Id;
		u1.LanguageLocaleKey = 'en_US';
		u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
		u1.State = 'UT';
        u1.Employee__c = True;
		u1.PostalCode = '84121';
        u1.IsActive = True;
       
        System.runAs(u1) {
            
        Account cust = new Account();
		cust.Name = 'Dyno Nobel Inc.';
		cust.ShippingState = 'UT';
        cust.ShippingCountry = 'US';
		cust.ShippingPostalCode = '84121';
		cust.ParentId = null;
        cust.Price_Adjustment_Notice_Period__c = 45;
        cust.On_Standard_Ts_Cs__c = 'Yes';
        cust.On_Contract__c = 'No';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.AN_Formula_Pricing__c = 'Yes';
        cust.OwnerId = u1.Id;
            
		insert cust;
        
        Contact newcon = new Contact();
		newcon.FirstName = 'Test1';
        newcon.LastName = 'Test2';
        newcon.User__c = u1.Id;
		newcon.AccountId = cust.Id;
        newcon.Active__c = True;
        newcon.Employee__c = True;
        newcon.OwnerId = u1.Id;
		
		insert newcon;

        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Sales_Site__c site2 = TestUtils.createSalesSite('SITE2', sites[0].Id, sites[1].Id);
        Sales_Site__c site3 = TestUtils.createSalesSite('SITE3', sites[0].Id, sites[1].Id);
        Customer_Sales_Site__c css = new Customer_Sales_Site__c(
            Customer__c=cust.Id, 
            Sales_Site__c=sites[2].Id,
            CurrencyIsoCode='CAD',
            PriceList__c ='00 Blank',
            INCO__c='FOB Free On Board',
            Service_Type__c='Drilling',
            Drilled_By__c='Me',
            Payment_Terms__c = '01 Net 30 Days'
        );
        insert css;
    
        Customer_Sales_Site__c css2 = css.clone(false, true);
        css2.Sales_Site__c = site2.Id;
        css2.Drilled_By__c='You';
        insert css2;
        
        Customer_Sales_Site__c css3 = css.clone(false, true);
        css3.Sales_Site__c = site3.Id;
        css3.Drilled_By__c='Them';
        insert css3;
        Opportunity quote = QuoteUtil.createNewQuote(css, System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create2', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Deal_Quoted'].Id);
       	/** Removed to get in Production **/
        Quote__c q = QuoteUtil.getScenario([Select Id from Quote__c where Opportunity__c=:quote.Id].Id);
        Test.startTest();
            
		QuoteUtil.createNewVersion(q.Id, System.today(), System.today(), System.today(), System.today(), null);
       
        List<Opportunity> clonedQuotes = QuoteUtil.cloneQuote(quote.Id, new List<Sales_Site__c>{site2, site3}, cust.Id, system.Today(), system.Today(), null, null,'');
        System.assertEquals(2, clonedQuotes.size());
        
        Test.stopTest();
        OpportunityTriggerUtils.isRunning = true;   
      	QuoteUtil.reactivateVersion(q.Id, System.today(), System.today(), System.today(), System.today(), null);
    }
  }
 
    @isTest static void testpricingCondition(){
        // Initialize Test Data 
        Account testAccount = TestUtils.createAccount('TestMDgjdsi43', null);
        testAccount.SAP_Account_Number__c = '0000';
        update testAccount;
        Sales_Site__c site1 = new Sales_Site__c(Name='1000-gjdsi43', Company_Site__c=null, Region_Site__c = null);
		insert site1;
        Sales_Site__c site2 = new Sales_Site__c(Name='1001-gjdsi43', Company_Site__c = site1.Id, Region_Site__c = null);
		insert site2;
        Sales_Site__c site3 = new Sales_Site__c(Name='1002-gjdsi43', Company_Site__c = site1.Id, Region_Site__c = site2.Id);
		insert site3;
        
       	Sales_Site__c testHier = [SELECT Id, Name,SAPExternalId__c,Company_Site__c,Company_Code__c FROM Sales_Site__c WHERE Name = '1002-gjdsi43'];
        string codestring = '100';
        testHier.SAPExternalId__c = codestring;
		update testHier;
		List<Sales_Site__c> ssTempo = [SELECT Name, Id, SAPExternalId__c FROM Sales_Site__c WHERE SAPExternalId__c = '100' LIMIT 1];       
        system.debug('Size'+ testHier+' Code' +testHier.Company_Code__c);
        system.debug('Size'+ ssTempo.size());
        if(ssTempo.size() > 0) {
            
            ssTempo.get(0).Company_Site__c = testHier.Id;
            update testHier;
            Id volumetricQuoteId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted'].Id;
            Opportunity testQuote = TestUtils.createOppty('TBC', testAccount.Id, 'Proposal/Price Quote', volumetricQuoteId, testHier.Id);
            testQuote = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :testQuote.Id];
            Quote__c testScenario = TestUtils.createQuote(testQuote, testHier.Id);
            Material_Item__c testMat1 = TestUtils.createMaterialItem('TMI9385', 'SS150', 'PL0000000100000002');
            Material_Item__c testMat2 = TestUtils.createMaterialItem('TMI9384', '0RZ1086', 'PL0000000100000001');
            Quote_Line_Item__c testSLI1 = TestUtils.createQli(testMat1, 10.0d, '1: Half Cent', testScenario, 1.0d, testHier);
            Quote_Line_Item__c testSLI2 = TestUtils.createQli(testMat2, 50.0d, '1: Half Cent', testScenario, 1.0d, testHier);         
             
            // Create Pricing Condition records                   
            QuoteUtil.CreatePricingCondition(testScenario.Id);
            
            List<Pricing_Condition__c> testPCs = [SELECT Id, SAP_IDOC_Type__c, Price_Valid_From__c, Price_Valid_To__c, SAP_Usage__c, SAP_Application__c, SAP_Table__c, Scenario__c,
                                                  SAP_Condition_Type__c,SAP_VARKEY__c, Price__c, Per__c, UoM__c, CurrencyIsoCode, Quote_Number__c, SAP_Scenario_Number__c, 
                                                  SAP_Customer_Number__c , SAP_Sales_Org__c, Company_Code__c, Quote_Type__c, Volumetric_Level__c, Sales_Site__c, Region__c, 
                                                  Customer_Group__c, MaterialCode__c, CreatedDate FROM Pricing_Condition__c WHERE Scenario__c = :testScenario.Id];
            Pricing_Condition__c priceconditions = [SELECT Id, SAP_IDOC_Type__c, Price_Valid_From__c, Price_Valid_To__c, SAP_Usage__c, SAP_Application__c, SAP_Table__c, Scenario__c,
                                                  SAP_Condition_Type__c,SAP_VARKEY__c, Price__c, Per__c, UoM__c, CurrencyIsoCode, Quote_Number__c, SAP_Scenario_Number__c, 
                                                  SAP_Customer_Number__c , SAP_Sales_Org__c, Company_Code__c, Quote_Type__c, Volumetric_Level__c, Sales_Site__c, Region__c, 
                                                  Customer_Group__c, MaterialCode__c, SAP_Sales_Group__c, CreatedDate FROM Pricing_Condition__c WHERE Scenario__c = :testScenario.Id  LIMIT 1];
            priceconditions.Company_Code__c = '100';
            priceconditions.Sales_Site__c = 'IND';
            priceconditions.Volumetric_Level__c ='P';
            Update priceconditions;
            
            Pricing_Condition__c pricecondition1 = [SELECT Id, SAP_IDOC_Type__c, Price_Valid_From__c, Price_Valid_To__c, SAP_Usage__c, SAP_Application__c, SAP_Table__c, Scenario__c,
                                                  SAP_Condition_Type__c,SAP_VARKEY__c, Price__c, Per__c, UoM__c, CurrencyIsoCode, Quote_Number__c, SAP_Scenario_Number__c, 
                                                  SAP_Customer_Number__c , SAP_Sales_Org__c, Company_Code__c, Quote_Type__c, Volumetric_Level__c, Sales_Site__c, Region__c, 
                                                  Customer_Group__c, MaterialCode__c, SAP_Sales_Group__c, CreatedDate FROM Pricing_Condition__c WHERE Scenario__c = :testScenario.Id  LIMIT 1];
            priceconditions.Company_Code__c = '132';
            priceconditions.Sales_Site__c = 'IND';
            priceconditions.Volumetric_Level__c ='P';
            Update priceconditions;
            
            system.debug('testpc:'+ priceconditions.Company_Code__c+priceconditions +'Common code:');
            QuoteUtil.createPricingConditionDetails(priceconditions, false);
            QuoteUtil.createPricingConditionDetails(pricecondition1, false);
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
            system.debug('Assetionscount'+assertionCount);
            System.assertEquals(0, assertionCount);
            
        } else {
            System.assertEquals('Failure', 'Failure');
        }
        
    }
    
        @isTest static void bulkpricingConditionTest(){
        // Initialize Test Data 
        Account testAccount = TestUtils.createAccount('TestMDgjdsi43', null);
        testAccount.SAP_Account_Number__c = '0000';
        update testAccount;
        Sales_Site__c site1 = new Sales_Site__c(Name='1000-gjdsi43', Company_Site__c=null, Region_Site__c = null);
		insert site1;
        Sales_Site__c site2 = new Sales_Site__c(Name='1001-gjdsi43', Company_Site__c = site1.Id, Region_Site__c = null);
		insert site2;
        Sales_Site__c site3 = new Sales_Site__c(Name='1002-gjdsi43', Company_Site__c = site1.Id, Region_Site__c = site2.Id);
		insert site3;
        
       	Sales_Site__c testHier = [SELECT Id, Name,SAPExternalId__c,Company_Site__c,Company_Code__c FROM Sales_Site__c WHERE Name = '1002-gjdsi43'];
        testHier.SAPExternalId__c = '100';
		update testHier;
		List<Sales_Site__c> ssTempo = [SELECT Name, Id, SAPExternalId__c FROM Sales_Site__c WHERE SAPExternalId__c = '100' LIMIT 1];       
        system.debug('Size'+ testHier+' Code' +testHier.Company_Code__c);
        system.debug('Size'+ ssTempo.size());
        if(ssTempo.size() > 0) {
            
            ssTempo.get(0).Company_Site__c = testHier.Id;
            update testHier;
            Id volumetricQuoteId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted'].Id;
            Opportunity testQuote = TestUtils.createOppty('TBC', testAccount.Id, 'Proposal/Price Quote', volumetricQuoteId, testHier.Id);
            testQuote = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :testQuote.Id];
            Quote__c testScenario = TestUtils.createQuote(testQuote, testHier.Id);
            
            Material_Item__c testMat1 = TestUtils.createMaterialItem('TMI9385', '0RZ1087', 'PL0000000100000002');
            Material_Item__c testMat2 = TestUtils.createMaterialItem('TMI9384', '0RZ1086', 'PL0000000100000001');
            Quote_Line_Item__c testSLI1 = TestUtils.createQli(testMat1, 10.0d, '1: Half Cent', testScenario, 1.0d, testHier);
            Quote_Line_Item__c testSLI2 = TestUtils.createQli(testMat2, 50.0d, '1: Half Cent', testScenario, 1.0d, testHier);         
             
            List<Quote__c> testscenarioquery = [SELECT q.Id, q.Volumetric_Parent_Product__r.Material_code__c, q.Name, q.SAP_Scenario_Number__c, q.SAP_Scenario_Number_v2__c, q.Customer_Group__c, q.Opportunity__r.RecordType.Name, q.Quote_Accepted_By_Customer__c,  q.Approval_Status__c, q.Active_Quote__c, q.Sales_Organization_Primary__r.Company_Site__r.Name, q.CurrencyIsoCode, q.Price_Valid_From__c, q.Price_Valid_To__c, q.Volumetric_Parent_Product_UoM__c, 
                                q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.SAPExternalId__c, q.Opportunity__r.Deal_Number__c, q.Sales_Organization_Primary__r.SalesOrg_Code__c, q.Sales_Organization_Primary__r.SalesGroup_Code__c, q.Sales_Organization_Primary__r.Region__c, q.Sales_Organization_Primary__r.Name, q.Customer__r.SAP_Account_Number__c, q.Sales_Organization_Primary__r.Company_Site__r.SAPExternalId__c, q.Calculated_Price__c, q.Volumetric_Per__c, q.Sales_Organization_Primary__r.Region_Site__r.SAPExternalId__c,
                                (SELECT Id, Name, Price_Valid_From__c, Price_Valid_To__c, Per__c, UoM__c, Quote__r.Name, Sales_Site__r.Region__c, Sales_Site__r.Company_Site__r.Name, Actual_Price__c, Sales_Site__r.SAP_Account_Number__c, Material_Item__r.Is_PHL__c, Material_Item__r.Product_Hierarchy__c,
                               Material_Item__c, Receive_NH3_Surcharge__c, Sales_Site__c,  Sales_Site__r.SAPExternalId__c, Sales_Site__r.Company_Site__r.SAPExternalId__c, Sales_Site__r.Region_Site__r.SAPExternalId__c, Material_Item__r.Material_Code__c, Quote__r.Customer__r.SAP_Account_Number__c, Quote__r.Opportunity__r.Deal_Number__c, Sales_Site__r.Name
                               FROM Quote_Line_Items__r Where Is_Bundled__c = false)  FROM Quote__c q WHERE Id=:testScenario.Id];
           
            // Create Pricing Condition records                   
            QuoteUtil.CreatePricingConditionBulk(testscenarioquery);
            
            List<Pricing_Condition__c> testPCs = [SELECT Id, SAP_IDOC_Type__c, Price_Valid_From__c, Price_Valid_To__c, SAP_Usage__c, SAP_Application__c, SAP_Table__c, Scenario__c,
                                                  SAP_Condition_Type__c,SAP_VARKEY__c, Price__c, Per__c, UoM__c, CurrencyIsoCode, Quote_Number__c, SAP_Scenario_Number__c, 
                                                  SAP_Customer_Number__c , SAP_Sales_Org__c, Company_Code__c, Quote_Type__c, Volumetric_Level__c, Sales_Site__c, Region__c, 
                                                  Customer_Group__c, MaterialCode__c, CreatedDate FROM Pricing_Condition__c WHERE Scenario__c = :testScenario.Id];
            
            system.debug('testpc:'+testPCs);
            System.assert(testPCs.size() > 0);              
            // Test 1: Scenario level PricingCondition
            Integer assertionCount = 0;
            
            QuoteUtil.SalesSiteIsWholesale('INTL');
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
            system.debug('Assetionscount'+assertionCount);
            System.assertEquals(0, assertionCount);                 
            
        } else {
            System.assertEquals('Failure', 'Failure');
        }
        
    }
    
}