@isTest
public class Test_EBITReporting {
	
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
		
		EBITReporting er = new EBITReporting();
		er.dummySalesSite.Sales_Office__c = site1.Id;
		er.getSiteOptions();
		er.dummyQuote.Price_Valid_From__c = date.today();
		er.dummyQuote.Price_Valid_To__c = date.today().addDays(20);
		er.dummyAccount.Account_Manager__c = 'acc test';
		er.monthFrom = 3;
		er.monthTo = 5;
		er.yearFrom = 2012;
		er.yearTo = 2013;
		Integer monthFrom = er.monthFrom;
		Integer monthTo = er.monthTo;
		Integer yearFrom = er.yearFrom;
		Integer yearTo = er.yearTo;
		
		er.dummyQuote.Customer__c = cust1.Id;
		er.dummyQuoteCustomerNumber = '222';
		er.setQuoteCustomer();
		er.setCustomerNumber();
		er.addCustomer();
		
		er.generateEBIT();
		er.generateExcel();
		er.generatePDF();
		
		er.getYears();
		er.getCustomersList();
		er.getCustomerIdsSet();
		er.getMonths();
		er.getSitesIdsSet();
		//er.removeCustomer();
		
		List<SelectOption> so = new List<SelectOption>();
		EBITReporting.SortOptionList(so);
		so.add(new SelectOption('test5','test5'));
		so.add(new SelectOption('test1','test1'));
		EBITReporting.SortOptionList(so);
		
		er.dummySalesSite.Sales_Office__c = site2.Id;
		er.emptyLists();
		er.generateEBIT();
	}

}