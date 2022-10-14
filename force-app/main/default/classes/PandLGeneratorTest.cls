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
private class PandLGeneratorTest {

    static testMethod void myUnitTest() {
           Account testCustomer = TestUtils.createAccount('TestCust001', null);
           testCustomer.SAP_Account_Number__c = 'test l 08956';
           testCustomer.Account_Group__c = '0002 Ship-to party';
           update testCustomer;
           Sales_Site__c testCompany = TestUtils.createPlant('Lucian-c');
           Sales_Site__c testRegion = TestUtils.createPlant('Lucian-r');
           testRegion.Company_Site__c = testCompany.Id;
           update testRegion;
           Sales_Site__c testSite = TestUtils.createPlant('Lucian-s');
           testSite.Region_Site__c = testRegion.Id;
           testSite.Company_Site__c = testCompany.Id;
           update testSite;
           Customer_Sales_Site__c css = TestUtils.CreateCSS(testCustomer.Id, testSite.Id);
           
           Test.startTest();
           
           PandLGeneratorController pageController = new PandLGeneratorController();
           System.assertEquals(date.today().addyears(-1), pageController.dummyQuote.Price_Valid_From__c);
           System.assertEquals(date.today().addmonths(-1), pageController.dummyQuote.Price_Valid_To__c);
           pageController.dummyQuote.Customer__c = testCustomer.Id;
           pageController.dummyQuote.Price_Valid_From__c = date.newInstance(2010, 01, 01);
           pageController.dummyQuote.Price_Valid_To__c = date.newInstance(2010, 10, 10);
           pageController.dummyQuote.Sales_Organization_Primary__c = null;
           pageController.reporttype = 'Detail';
           pageController.hideZeroData = false;
           pageController.orderby = 'Company ASC';
           
           pageController.ResetRegion();
           pageController.ResetCompany();
           pageController.getReportTypes();
           pageController.dummyQuoteCustomerNumber = 'test l 08956';
           pageController.dummyQuoteCustomerNumber = pageController.dummyQuoteCustomerNumber;
           pageController.setQuoteCustomer();
           pageController.setCustomerNumber();
           System.assertEquals('0002 Ship-to party', pageController.customerAccountGroup);
           pageController.getMonths();
           pageController.getYears();
           pageController.monthFrom = pageController.monthFrom;
           pageController.monthTo = pageController.monthTo;
           pageController.yearFrom = pageController.yearFrom;
           pageController.yearTo = pageController.yearTo;
           pageController.regionId = testRegion.Id;
           pageController.siteId = testSite.Id;
           pageController.generatePandL(); 
           pageController.orderby = 'Region DESC';
           pageController.generatePandL(); 
           pageController.orderby = 'Company DESC';
           pageController.generatePandL(); 
           System.assertEquals(1, pageController.getCurrentPage().size());
           pageController.getIndustries();
           pageController.getRegionOptions();
           pageController.getCompanyOptions();
           pageController.siteId = null;
           pageController.getRegionOptions();
           pageController.getCompanyOptions();
           pageController.regionId = null;
           pageController.getRegionOptions();
           pageController.getCompanyOptions();
           pageController.nextPage();
           pageController.previousPage();

           Test.stopTest();
    }
    
    static testmethod void TestReClick() {
        Account testCustomer = TestUtils.createAccount('TestCust001', null);
        Sales_Site__c testSite = TestUtils.createPlant('600WChicago');
        
        ApexPages.currentPage().getParameters().put('fromdate', date.newInstance(2010, 01, 01).format());  
        ApexPages.currentPage().getParameters().put('todate', date.newInstance(2010, 10, 10).format());
        ApexPages.currentPage().getParameters().put('companyid', testSite.Id);
        ApexPages.currentPage().getParameters().put('regionid', testSite.Id);
        ApexPages.currentPage().getParameters().put('siteid', testSite.Id);
        ApexPages.currentPage().getParameters().put('parentid', testCustomer.Id);

        Test.startTest();
        PandLGeneratorController pageController = new PandLGeneratorController();
        pageController.dummyQuoteCustomerNumber = 'test';
        pageController.setCustomerNumber();
        pageController.setQuoteCustomer();
        Test.stopTest();
        
        System.assertNotEquals(0, pageController.getCurrentPage().size());
    } 
    
    /*static testMethod void testGetIndustries() {
        Test.startTest();
        Account testCustomer = TestUtils.createAccount('TestCust001', null);
        Sales_Site__c testSite = TestUtils.createPlant('600WChicago');      
        Test.stopTest();
        PandLGeneratorController pageController = new PandLGeneratorController();
        System.assert(pageController.getIndustries().size() > 1);
    }
    
    static testmethod void testGetOtherOptions() {
        Test.startTest();
        Account testCustomer = TestUtils.createAccount('TestCust001', null);
        Sales_Site__c testSite = TestUtils.createPlant('600WChicago');      
        Test.stopTest();
        PandLGeneratorController pageController = new PandLGeneratorController();
        
        System.assert(pageController.siteSelectOptions.size() >= 1);
        System.assert(pageController.getRegionOptions().size() >= 1);
        System.assert(pageController.getCompanyOptions().size() >= 1);
                
    }*/
}