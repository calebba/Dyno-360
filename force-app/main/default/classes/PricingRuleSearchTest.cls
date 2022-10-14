/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PricingRuleSearchTest {

    static testMethod void testSearch() {
		
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
			
    	Test.startTest();
        
    	Account testAcct = TestUtils.createAccount('TC050', null);
    	List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
    	Material_Item__c testMi = TestUtils.createMaterialItem('TMI050', 'TMI05', 'PL0509', sites[2].Id);
    	Pricing_Rule__c rule = TestUtils.createPricingRule(sites[2].Id, testAcct.Id, sites[1].Id, true, testMi.Id, 1, 'EA', 12.34, 23.45, System.today(), System.today());
    	rule.Company_Code__c = sites[0].Id;
    	update rule;
    	List<Copa__c> entries = new List<Copa__c>(); 
    	entries.add(TestUtils.createCopa(testAcct, sites[2], 25, 25, 10000, 50, 50000, 45, Date.newInstance(2010,5,1),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 25, 25, 10000, 50, 50000, 45, Date.newInstance(2010,5,2),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2010,5,3),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2010,5,3),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2010,4,3),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2010,4,1),testMi));
		insert entries;
		
        //Test a search and assert the results.
        PricingRuleSearchController prsc = new PricingRuleSearchController();
        prsc.companyCodeId = sites[0].Id;
        prsc.ruleCriteria.Account__c = testAcct.Id;
        prsc.ruleCriteria.Receiving_Sales_Site__c = sites[2].Id;
        prsc.materialSelector.Material_Item__c = testMi.Id;
        prsc.ruleCriteria.Customer_Group__c = null;
        System.assert(!prsc.includeHistory);
        System.assert(!prsc.hasSearched);
        prsc.search();
        System.assert(prsc.hasSearched);
        System.assertEquals(1, prsc.searchResults.size());
        System.assertEquals(12.34, prsc.searchResults[0].floorPrice);
        System.assertEquals(23.45, prsc.searchResults[0].targetPrice);
        System.assertEquals(1, prsc.searchResults[0].per);
        System.assertEquals('EA', prsc.searchResults[0].uom);
        //End Assert Check

        prsc.clear();        
        prsc.ruleCriteria.Account__c = testAcct.Id;
        prsc.ruleCriteria.Receiving_Sales_Site__c = sites[2].Id;
        prsc.ruleCriteria.Material_Item__c = testMi.Id;
        prsc.includeHistory = true;
        prsc.search();
        //System.assertEquals(prsc.customerSalesHistoryResults.size(),1);
        List<SelectOption> ccOptions 	= prsc.getCompanyCodeOptions();
        List<SelectOption> ccOptions2 	= prsc.getRegionOptions();
        
        Test.stopTest();
        }
    }
    
    
    static testMethod void testSearch2() {
		
       	Test.startTest();
        
    	Account testAcct = TestUtils.createAccount('TC050', null);
    	List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
    	Material_Item__c testMi = TestUtils.createMaterialItem('TMI050', 'TMI05', 'PL0509', sites[2].Id);
    	Pricing_Rule__c rule = TestUtils.createPricingRule(sites[2].Id, testAcct.Id, sites[1].Id, true, testMi.Id, 1, 'EA', 12.34, 23.45, System.today(), System.today());
        rule.Receiving_Sales_Site__c = null;
        rule.Region_Site__c = null;
    	rule.Company_Code__c = sites[0].Id;
    	update rule;
    	List<Copa__c> entries = new List<Copa__c>(); 
    	entries.add(TestUtils.createCopa(testAcct, sites[2], 25, 25, 10000, 50, 50000, 45, Date.newInstance(2022,5,1),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 25, 25, 10000, 50, 50000, 45, Date.newInstance(2022,5,2),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2022,5,3),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2022,5,3),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2022,4,3),testMi));
		entries.add(TestUtils.createCopa(testAcct, sites[2], 75, 75, 10000, 50, 50000, 45, Date.newInstance(2022,4,1),testMi));
		insert entries;
        
        String searchHistoryQuery = 'SELECT Material_Item__r.Name material, UoM__c, CurrencyIsoCode, SUM(Price__c) price, SUM(Net_Revenue__c) netRev, SUM(LBS__c) units FROM Copa__c WHERE Current_Month__c = LAST_N_DAYS:365 AND Customer__c = \'' + testAcct.Id + '\'';
		String groupByClause = ' GROUP BY Material_Item__r.Name, UoM__c, CurrencyIsoCode  LIMIT 1';
        AggregateResult resultsing = Database.query(searchHistoryQuery + groupByClause);
		
        
        //Test a search and assert the results.
        PricingRuleSearchController prsc = new PricingRuleSearchController();
        prsc.companyCodeId = sites[0].Id;
        prsc.ruleCriteria.Account__c = testAcct.Id;
        prsc.ruleCriteria.Receiving_Sales_Site__c = null;
        prsc.materialSelector.Material_Item__c = null;
        prsc.ruleCriteria.Customer_Group__c = null;
        System.assert(!prsc.includeHistory);
        System.assert(!prsc.hasSearched);
        
        
        PricingRuleSearchController.CopaData innerclass = new PricingRuleSearchController.CopaData(resultsing);
        prsc.search();
        System.assert(!prsc.hasSearched);
        
        
         system.debug('afRull.reciving:'+prsc.ruleCriteria.Receiving_Sales_Site__c);
            system.debug('afRull.region:'+prsc.ruleCriteria.Region_Site__c);
            system.debug('afRull.msterial:'+prsc.materialSelector.Material_Item__c);
        
           
        //End Assert Check
        
        Test.stopTest();
    }
}