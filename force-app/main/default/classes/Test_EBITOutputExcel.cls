@isTest
public class Test_EBITOutputExcel {
	public static testmethod void test1() {
		Account cust1 = TestUtils.createAccount('ACC1', null,'123');
		Account cust2 = TestUtils.createAccount('ACC2', null,'222');
		
		// Company Site
		Sales_Site__c company1 = TestUtils.createSalesSite('DNNA', null, null);
		Sales_Site__c company2 = TestUtils.createSalesSite('DNCI', null, null);
		  
		// Region Site
		Sales_Site__c region1 = TestUtils.createSalesSite('100 WEST', company1.Id, null);
		Sales_Site__c region2 = TestUtils.createSalesSite('200 MIDWEST', company1.Id, null);
		Sales_Site__c region3 = TestUtils.createSalesSite('1111', company2.Id, null);
		Sales_Site__c region4 = TestUtils.createSalesSite('2222', company2.Id, null);
		  
		// Sales Sites
		Sales_Site__c site1 = TestUtils.createSalesSite('WERO', company1.Id, region1.Id);
		Sales_Site__c site2 = TestUtils.createSalesSite('ERAL', company1.Id, region2.Id);
		Sales_Site__c site3 = TestUtils.createSalesSite('ERMA', company1.Id, region2.Id);
		
		
		ApexPages.currentPage().getParameters().put('dateFrom', String.valueOf(date.today().addYears(-1)));
		ApexPages.currentPage().getParameters().put('dateTo', String.valueOf(date.today()));
		ApexPages.currentPage().getParameters().put('currentCurrency', 'USD');
		ApexPages.currentPage().getParameters().put('accountIds', cust1.Id);
		ApexPages.currentPage().getParameters().put('shipToIds', cust2.Id);
		ApexPages.currentPage().getParameters().put('sitesIdsList', site1.Id);
		
		EBITOutputExcel eo = new EBITOutputExcel();
		eo.EBITOutputExcelAction();
	}
}