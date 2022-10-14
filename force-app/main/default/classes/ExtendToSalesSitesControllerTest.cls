@isTest
public class ExtendToSalesSitesControllerTest {
    
    @testsetup static void testdatat(){
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
            
       // Create Account     
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
            system.debug('account ID:' + cust.id);
        }
        
    }
    
	@isTest static void testExtendToSites() {
        
        User u1 = [Select Id,FirstName,LastName,Username,CompanyName,CommunityNickname from User where Username = 'tu3@tus.com'];
		
        System.runAs(u1) {
            
            
         // Create Account     
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
            
		// Create Sites
		List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE1');
		Sales_Site__c site2 = TestUtils.createSalesSite('SITE2', sites[0].Id, sites[1].Id);
		Sales_Site__c site3 = TestUtils.createSalesSite('SITE3', sites[0].Id, sites[1].Id);
		
		// Create Customer Sale Site records
		List<Customer_Sales_Site__c> css = new List<Customer_Sales_Site__c>();
		css.add(new Customer_Sales_Site__c(Customer__c=cust.Id, Sales_Site__c=sites[2].Id));
		css.add(new Customer_Sales_Site__c(Customer__c=cust.Id, Sales_Site__c=site2.Id));
		css.add(new Customer_Sales_Site__c(Customer__c=cust.Id, Sales_Site__c=site3.Id));
		insert css;
		
            Test.startTest();
		//createNewQuote(Customer_Sales_Site__c css, Date closeDate, Date qValidFrom, Date qValidTo, Date pValidFrom, Date pValidTo, String description, Boolean promo, Boolean tri, String scenarioChoice, String holeChoice, Id recordTypeId) {
		Opportunity opp = QuoteUtil.createNewQuote(css[0], System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Deal_Quoted'].Id);
		Quote__c q = [Select Id from Quote__c where Opportunity__c = :opp.Id];
		Material_Item__c item = TestUtils.createItemWitCost(sites[2], 12.34d);
		TestUtils.createPricingRule(site2.Id, cust.Id, sites[1].Id, true, item.Id, 1, 'EA', 45.00d, 55.00d, System.today(), System.today().addDays(10));
		
		//addQuoteLine(q.Id, mat1.Id, 5, 50.00, 12.34);
		Quote_Line_Item__c qli = QuoteUtil.addQuoteLine(q.Id, item.Id, 5, 50.00, 12.34);
		
		ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(opp);
		ExtendToSalesSitesController con2 = new ExtendToSalesSitesController(con);
		con2.extendedSites[0].selected = false;
		con2.extendedSites[1].selected = true;
		con2.quote.Price_Valid_From__c = System.Today();
		con2.quote.Price_Valid_To__c = System.Today();
		PageReference r = con2.cancel();
		PageReference s = con2.extend();
            
        ExtendToSalesSitesController getregion = new ExtendToSalesSitesController(con);
		getregion.getPricingRegions();
            
		System.assertNotEquals(s, null);
		System.assertNotEquals(r, null);
            Test.stopTest();
        }
	}
    
	/*private static testmethod void testExtendToSites() {
		// Create Sites
		
		List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE1');
		Sales_Site__c site2 = TestUtils.createSalesSite('SITE2', sites[0].Id, sites[1].Id);
		Sales_Site__c site3 = TestUtils.createSalesSite('SITE3', sites[0].Id, sites[1].Id);
		// Create Account
		Account cust = TestUtils.createAccount('CUSTOMER', null);
		
		// Create Customer Sale Site records
		List<Customer_Sales_Site__c> css = new List<Customer_Sales_Site__c>();
		css.add(new Customer_Sales_Site__c(Customer__c=cust.Id, Sales_Site__c=sites[2].Id));
		css.add(new Customer_Sales_Site__c(Customer__c=cust.Id, Sales_Site__c=site2.Id));
		css.add(new Customer_Sales_Site__c(Customer__c=cust.Id, Sales_Site__c=site3.Id));
		insert css;
		
		//createNewQuote(Customer_Sales_Site__c css, Date closeDate, Date qValidFrom, Date qValidTo, Date pValidFrom, Date pValidTo, String description, Boolean promo, Boolean tri, String scenarioChoice, String holeChoice, Id recordTypeId) {
		Opportunity opp = QuoteUtil.createNewQuote(css[0], System.today().addMonths(1), System.today(), System.today().addYears(1), System.today(), System.today().addYears(1), 'Test Quote Create', false, false, '', '', [Select Id from RecordType where SObjectType='Opportunity' And DeveloperName='Deal_Quoted'].Id);
		Quote__c q = [Select Id from Quote__c where Opportunity__c = :opp.Id];
		Material_Item__c item = TestUtils.createItemWitCost(sites[2], 12.34d);
		TestUtils.createPricingRule(site2.Id, cust.Id, sites[1].Id, true, item.Id, 1, 'EA', 45.00d, 55.00d, System.today(), System.today().addDays(10));
		
		//addQuoteLine(q.Id, mat1.Id, 5, 50.00, 12.34);
		Quote_Line_Item__c qli = QuoteUtil.addQuoteLine(q.Id, item.Id, 5, 50.00, 12.34);
		
		ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(opp);
		ExtendToSalesSitesController con2 = new ExtendToSalesSitesController(con);
		con2.extendedSites[0].selected = false;
		con2.extendedSites[1].selected = true;
		con2.quote.Price_Valid_From__c = System.Today();
		con2.quote.Price_Valid_To__c = System.Today();
		PageReference r = con2.cancel();
		PageReference s = con2.extend();
		
		System.assertNotEquals(s, null);
		System.assertNotEquals(r, null);
	
	}*/
}