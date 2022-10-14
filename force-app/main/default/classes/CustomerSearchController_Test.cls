@isTest
public with sharing class CustomerSearchController_Test {

    private static testMethod void testConstructor() {
		CustomerSearchController csc = new CustomerSearchController();
		System.assertEquals(csc.searchString, '');
		System.assertEquals(csc.customerList.size(), 0);
	}
	
	private static testMethod void testSearchCustomers() {
		Account temp = TestUtils.createAccount('TESTACCTCPC465', null);
		CustomerSearchController csc = new CustomerSearchController();
		csc.searchCustomers();
		System.assertNotEquals(csc.customerList.size(), 0);
	}
}