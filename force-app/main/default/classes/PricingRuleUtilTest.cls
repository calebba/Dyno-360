@isTest
public class PricingRuleUtilTest {

  @isTest static void testDuplicatePricingRuleRecords() {
		List<Pricing_Rule__c> rules = new List<Pricing_Rule__c>();
		
		Account cust = TestUtils.createAccount('TEST', null);
		Sales_Site__c company = TestUtils.createSalesSite('Company', null, null);
		Sales_Site__c region = TestUtils.createSalesSite('Region', company.Id, null);
		Sales_Site__c site = TestUtils.createSalesSite('Site', company.Id, region.Id);
		Material_Item__c material = TestUtils.createMaterialItem('Test', 'TEST', 'PL00000', site.Id);
		Opportunity testOpp = TestUtils.createOppty('TO001', cust.Id, 'Prospecting');
		Quote__c quote = TestUtils.createQuote(testOpp, site.Id);
		rules.add(new Pricing_Rule__c(Account__c=cust.Id, Receiving_Sales_Site__c=site.Id, Region_Site__c=region.Id, Material_Item__c=material.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 - Retail'));
		rules.add(new Pricing_Rule__c(Account__c=cust.Id, Receiving_Sales_Site__c=site.Id, Region_Site__c=region.Id, Material_Item__c=material.Id, CurrencyIsoCode='USD', Price_Valid_From__c=System.today(), Price_Valid_To__c=System.today(), Customer_Group__c='01 - Retail'));
		PricingRuleUtil.getPricingSearchQuery();
		try {
			insert rules;
			System.assert(false, 'No error caught.');
		}
		catch (System.Dmlexception de) {
			System.assert(true);
		}
	}
}