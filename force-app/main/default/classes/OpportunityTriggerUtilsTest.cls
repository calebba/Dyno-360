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
private class OpportunityTriggerUtilsTest {

    //Test method for OpportunityTriggerUtils.createQuote()
    static testMethod void testCreateQuote() {
    	
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id; 
    	Account testAccount = new Account();
    	testAccount.Name = 'BobsHouseOfPancakes';
        testAccount.ShippingCountry = 'US';
    	testAccount.ShippingState = 'UT';
    	testAccount.ShippingPostalCode = '84121';
    	testAccount.SAP_Account_Number__c = '34401';
    	insert testAccount;
    	
    	//Setup a temporary Sales Site that functions as a region and company sales site so the one listed below 
    	//Validates against the CSS Validation rules
    	
		List<Sales_Site__c> mySS = TestUtils.createSalesSiteHierarchy('CompanySS', 'RegionSS', 'ActualSite');
    	
    	Material_Item__c testMi1 = TestUtils.createMaterialItem('TMI398', 'TMI398', 'TMI398', mySS[2].Id);
    	Material_Item__c testMi2 = TestUtils.createMaterialItem('TMI399', 'TMI3991', 'TMI399', mySS[2].Id);        
    	Bundled_Service__c testBs1 = TestUtils.createBundledServiceMapping(testMi1.Id, 'Shot_Service', '--None--');
    	Bundled_Service__c testBs2 = TestUtils.createBundledServiceMapping(testMi2.Id, 'Shot_Service_with_Drilling', '1 in');   

    	Customer_Sales_Site__c testCSS = TestUtils.createCSS(testAccount.Id, mySS[2].Id); 	
		update testCSS;
  
       
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'TO001';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.TODAY();
        testOpp.AccountId = testAccount.Id;
        testOpp.Opportunity_Owner_Contact__c ='003a000002LhWKbAAN';
        testOpp.Sales_Site__c = mySS[2].Id;
        testOpp.RecordTypeId = typeNeeded;
        insert testOpp;
        
        Test.startTest();
    	//Create 2 bundled service mapping
    	//one for SSwD, HoleSize one for SS
    	//Verify it creates the QLI with the MI from the mapping.
		OpportunityTriggerUtils.createQuote(new List<Opportunity>{testOpp}, System.today(), System.today().addDays(30), System.today(), System.today().addDays(30), 'A Test Description', true, true, testCSS, 'Shot_Service', '--None--', null);    
        Opportunity nameCheck = [SELECT Id,Name FROM Opportunity WHERE Id=: testOpp.Id];
        
        datetime t = System.now();
        String todaysDate = t.format('yyyyMMdd');
        //System.assertEquals(nameCheck.Name, 'B-0-BobsH-BobsSS-' + todaysDate);
        Quote__c testQuote = [SELECT Opportunity__c, Id FROM Quote__c WHERE Opportunity__c = :testOpp.Id LIMIT 1];
        System.assertEquals(testOpp.Id, testQuote.Opportunity__c);
        System.assertEquals(1, [SELECT count() FROM Quote_Line_Item__c WHERE Material_Item__c = :testMi1.Id]);
        OpportunityTriggerUtils.createQuote(new List<Opportunity>{testOpp}, System.today(), System.today().addDays(30), System.today(), System.today().addDays(30), 'A Test Description', true, true, testCSS, 'Shot_Service_with_Drilling', '1 in', null);
        System.assertEquals(1, [SELECT count() FROM Quote_Line_Item__c WHERE Material_Item__c = :testMi2.Id]);
        Test.stopTest();           
    }
    
    //Test method for OpportunityTriggerUtils.setClosedWon()
    static testmethod void setClosedWonTest() {
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Prospect' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('BiggerTestCorp', null);
    	testAcct.RecordTypeId = typeNeeded;
    	typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Quoted' LIMIT 1].Id;
    	Opportunity currentOpportunity = TestUtils.createOppty('TO398', testAcct.Id, 'Prospecting', typeNeeded);
    	Quote__c q = TestUtils.createQuote(currentOpportunity);
		Material_Item__c newMaterialItem = TestUtils.createMaterialItem('Test Material 1', '12345', 'PL959', null);
		Material_Item__c newMaterialItemTwo = TestUtils.createMaterialItem('Test Material 1', '123456', 'PL959', null);
		Material_Item__c newMaterialItemThree = TestUtils.createMaterialItem('Test Material 1', '123457', 'PL959', null);  
		Sales_Site__c testPlant = TestUtils.createPlant('Test Plant 001');
		//Material_Cost__c matCost = TestUtils.createMaterialCost(newMaterialItem, testPlant, 1.00, 'Medium');
		//Material_Cost__c matCostTwo = TestUtils.createMaterialCost(newMaterialItemTwo, testPlant, 1.00, 'Medium');
		//Material_Cost__c matCostThree = TestUtils.createMaterialCost(newMaterialItemThree, testPlant, 1.00, 'Medium');
		Quote__c testQuote = [SELECT Id, Name, Quote_Accepted_By_Customer__c, Approval_Status__c FROM Quote__c WHERE Opportunity__c = :currentOpportunity.Id LIMIT 1];
		//Quote_Line_Item__c newQuoteLineItem = TestUtils.createQli(newMaterialItem, 1.00, 'Nearest Cent', testQuote, 1.0, testPlant);
		//newQuoteLineItem = TestUtils.createQli(newMaterialItemTwo, 1.00, 'Nearest Cent', testQuote, 1.0, testPlant);
		//newQuoteLineItem = TestUtils.createQli(newMaterialItemThree, 1.00, 'Nearest Cent', testQuote, 1.0, testPlant);
		Test.startTest();				  	
    	testQuote.Quote_Accepted_By_Customer__c = 'Yes';
    	testQuote.Approval_Status__c = 'Approved';
    	update testQuote;
    	currentOpportunity.StageName = 'Closed Won';   
    	currentOpportunity.Reason__c = 'Pricing';
    	update currentOpportunity;
    	System.assertEquals('Closed Won', currentOpportunity.StageName);
    	Test.stopTest();    	 	
    }
    
    /*
    static testMethod void testCreatePricingConditions() {
    	Account parent = TestUtils.createAccount('TestAccountParent001', null, 'TAP001');
    	Account child = TestUtils.createAccount('TestAccountChild001', parent.Id, 'TAC001');
    	Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Basic'].Id;
        Opportunity testOpp = TestUtils.createOppty('TO001', parent.Id, 'Prospecting', typeNeeded);

        Sales_Site__c testPlant = new Sales_Site__c();
        testPlant.Name = 'TestPlant001';
        testPlant.SAP_Account_Number__c = 'TP001';
        insert testPlant;
        
        Quote__c testQuote = TestUtils.createQuote(testOpp);
        Material_Item__c testMatItem = TestUtils.createMaterialItem('AnItemForTesting001', 'AIFT001', 'FAKE1', testPlant.Id);
        Material_Cost__c testMatCost = TestUtils.createMaterialCost(testMatItem, testPlant, 5, 'Medium');
        Quote_Line_Item__c testQli = TestUtils.createQli(testMatItem, 10.00, 'DNE', testQuote, 1, testPlant);
        
        Deal_Sub_Account__c dsa = new Deal_Sub_Account__c();
        dsa.Opportunity__c = testOpp.Id;
        dsa.Account__c = child.Id;
        insert dsa;
        
        Test.startTest();
        Opportunity theOpp = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :testOpp.Id LIMIT 1];
        theOpp.StageName = 'Closed Lost';
        theOpp.Reason__c = 'Testing';
        theOpp.Comments__c = 'Testing More';
        theOpp.Who_Won__c = 'Other';
        update theOpp;
        Integer count = [SELECT count() FROM Pricing_Condition__c WHERE VAKEY__c = 'TP001 0 TAC001 AIFT001' OR VAKEY__c = 'TP001 0 TAP001 AIFT001'];
        List<Pricing_Condition__c> pcList = [SELECT Id, Name, VAKEY__c FROM Pricing_Condition__c];
        System.assertEquals(2, count);
        Test.stopTest();
    }
    */
    
    /*
	static testMethod void testCreateQuoteWithOwner() {
         Profile p = [select id from profile where name='Standard User']; 
         User u = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser3@testorg.com');
         insert u;
         User ownerUser = new User(alias = 'standt2', email='standarduser2@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser2@testorg.com',
            Vice_President__c = u.Id,  Regional_Ops_Manager__c = u.Id,  RSM__c = u.Id,
            Pricing_Manager__c = u.Id,  Legal__c = u.Id,  Finance__c = u.Id);            
        insert ownerUser;    
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'TO001';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.TODAY();
        testOpp.OwnerId = ownerUser.Id;
        Id typeNeeded = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Quoted'].Id;
        testOpp.RecordTypeId = typeNeeded;
        Test.startTest();
        insert testOpp;
        Test.stopTest();           
    }
    */
}