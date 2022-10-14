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
private class QuoteEditTest {

    static testMethod void testController() {
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id;
    	Account testCust = TestUtils.createAccount('TestAcct', null);
    	Sales_Site__c theCompany = TestUtils.createSalesSite('ATestCompany878', null, null);
    	Sales_Site__c theRegion = TestUtils.createSalesSite('ATestRegion878', theCompany.Id, null);
    	Sales_Site__c theSite = TestUtils.createSalesSite('ATestSite878', theCompany.Id, theRegion.Id);
    	Opportunity testOpp = TestUtils.createOppty('TestOppName721', testCust.Id, 'Proposal/Price Quote', typeNeeded, testCust.Id);
    	
    	Test.startTest();
    	Test.setCurrentPage(new PageReference('/apex/QuoteEdit?RecordType=' + typeNeeded));
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(new Opportunity());
        QuoteEditController qec = new QuoteEditController(controller);
        System.assertEquals(null, qec.theQuote.Hole_Size__c);
        System.assertEquals('Delivery', qec.theQuote.Scenario_Choice__c);
        System.assertEquals(null, qec.theQuote.Id);
        controller = new ApexPages.Standardcontroller(testOpp);
        Test.setCurrentPage(new PageReference('/apex/QuoteEdit?id=' + testOpp.Id));
        qec = new QuoteEditController(controller);
        System.assertEquals(null, qec.theQuote.Hole_Size__c);
        System.assertEquals(testOpp.Id, qec.theQuote.Id);
        System.assertEquals(null, qec.revertSelected());
        System.assertEquals(null, qec.performSaveAndNew());
        System.assertEquals('--None--', qec.siteChoice);    
        Test.stopTest();
    }
    
    static testMethod void testGetCustomerSites() {
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id;
    	Account testCust = TestUtils.createAccount('TestAcct25643', null);
    	Account testCust2 = TestUtils.createAccount('TestAcct38932', null);
    	Sales_Site__c theCompany = TestUtils.createSalesSite('ATestCompany878', null, null);
    	Sales_Site__c theRegion = TestUtils.createSalesSite('ATestRegion878', theCompany.Id, null);
    	Sales_Site__c theSite = TestUtils.createSalesSite('ATestSite878', theCompany.Id, theRegion.Id);
    	Customer_Sales_Site__c testCSS1 = TestUtils.createCSS(testCust.Id, theSite.Id);
    	//Customer_Sales_Site__c testCSS2 = TestUtils.createCSS(testCust.Id, theRegion.Id);
    	//Customer_Sales_Site__c testCSS3 = TestUtils.createCSS(testCust.Id, theCompany.Id);
    	Opportunity testOpp = TestUtils.createOppty('TestOppName721', testCust.Id, 'Proposal/Price Quote', typeNeeded, testCust.Id);
    	
    	Test.startTest();
    	Test.setCurrentPage(new PageReference('/apex/QuoteEdit?RecordType=' + typeNeeded));
    	System.runAs(TestUtils.createUserNoInsert(theCompany.Name)) {
        	ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(new Opportunity());
        	QuoteEditController qec = new QuoteEditController(controller);
        	qec.theQuote.AccountId = testCust.Id;
        	List<SelectOption> soList = qec.getCustomerSites();
        	for(SelectOption so : soList) {
        		System.assertEquals(theSite.Name, so.getLabel());
        		System.assertEquals(testCSS1.Id, so.getValue());
        	}
        	qec = new QuoteEditController(controller);
        	qec.theQuote.AccountId = testCust2.Id;
        	soList = qec.getCustomerSites();
			System.assertEquals('--None--', qec.siteChoice);
			System.assertEquals(1, soList.size());
    	}       
        Test.stopTest();    	
    }
    
    static testMethod void testSave() {
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id;
    	Account testCust = TestUtils.createAccount('TestAcct25643', null);
        Contact testOwner = TestUtils.createContact('Marsha', 'Brady', testCust.Id);
    	Account testCust2 = TestUtils.createAccount('TestAcct32745', null);
    	Sales_Site__c theCompany = TestUtils.createSalesSite('ATestCompany878', null, null);
    	Sales_Site__c theRegion = TestUtils.createSalesSite('ATestRegion878', theCompany.Id, null);
    	Sales_Site__c theSite = TestUtils.createSalesSite('ATestSite878', theCompany.Id, theRegion.Id);
    	Customer_Sales_Site__c testCSS1 = TestUtils.createCSS(testCust.Id, theSite.Id);
    	//Customer_Sales_Site__c testCSS2 = TestUtils.createCSS(testCust.Id, theRegion.Id);
    	//Customer_Sales_Site__c testCSS3 = TestUtils.createCSS(testCust.Id, theCompany.Id);
    	//Opportunity testOpp = TestUtils.createOppty('TestOppName721', testCust.Id, 'Proposal/Price Quote', typeNeeded, testCust.Id);
    	
    	Test.startTest();
    	Test.setCurrentPage(new PageReference('/apex/QuoteEdit?RecordType=' + typeNeeded));
    	System.runAs(TestUtils.createUserNoInsert(theCompany.Name)) {
        	ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(new Opportunity());
        	QuoteEditController qec = new QuoteEditController(controller);  
        	qec.theQuote.RecordTypeId = typeNeeded;      	
        	qec.performSave();
        	qec.siteChoice = testCSS1.Id;
        	qec.performSave();        	
        	qec.theScenario.Quote_Valid_From__c = System.today();
        	qec.performSave();
        	qec.theScenario.Quote_Valid_To__c = System.today().addDays(30);
        	qec.performSave();
        	qec.theScenario.Price_Valid_From__c = System.today();
        	qec.performSave();
        	qec.theScenario.Price_Valid_To__c = System.today().addDays(30);
        	qec.performSave();    	
        	qec.theQuote.AccountId = testCust.Id;
        	qec.getCustomerSites();
            qec.theQuote.Opportunity_Owner_Contact__c = testOwner.Id;
        	qec.performSave();
        	qec.theQuote.CloseDate = System.today().addDays(30);
        	qec.theQuote.Scenario_Choice__c = 'Shot Service with Drilling';
        	qec.theQuote.Hole_Size__c = null;        	
        	qec.performSave();
        	qec.theQuote.Hole_Size__c = '3.5';
        	//This is the successful save, still 2 more fail cases to test.
        	//qec.performSave();
        	System.assertEquals(1, [SELECT count() FROM Quote__c WHERE Opportunity__c = :qec.theQuote.Id]);
        	testCust.Flag_for_Deletion__c = true;
        	update testCust;
        	qec.performSave();
        	testCust.Flag_for_Deletion__c = false;
        	update testCust;
        	qec.theQuote.AccountId = testCust2.Id;
        	qec.performSave();
    	}       
        Test.stopTest();        	
    }
    
//    static testMethod void testVolumetricParentExtension(){
//    	Sales_Site__c theCompany = TestUtils.createSalesSite('ATestCompany878', null, null);
//    	
//    	Test.startTest();
//    	Test.setCurrentPage(new PageReference('/apex/QuotePage'));
//    	
//    	System.runAs(TestUtils.createUserNoInsert(theCompany.Name)) {
//    		ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(new Opportunity());
//    		VolumetricParentExtension ext = new VolumetricParentExtension(controller);
//    		
//    		system.debug(ext.getVolumetricParentMaterials());
//    	}
//    	
//    	Test.stopTest();
//    }
    
    static testMethod void testCustomerFlaggedForDeletion(){
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id;
    	Account testCust = TestUtils.createAccount('TestAcct25643', null);
    	Sales_Site__c theCompany = TestUtils.createSalesSite('ATestCompany878', null, null);
    	testCust.Flag_for_Deletion__c = true;
    	update testCust;
    	
    	Test.startTest();
    	Test.setCurrentPage(new PageReference('/apex/QuoteEdit?RecordType=' + typeNeeded + '&accid=' + testCust.Id));
    	System.runAs(TestUtils.createUserNoInsert(theCompany.Name)) {
    		ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(new Opportunity());
        	QuoteEditController qec = new QuoteEditController(controller);
    	}
    	Test.stopTest();
    }
}