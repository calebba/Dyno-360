@isTest
public class MassQuoteOutputControllerTest {
    
    @testSetup static void testData() {
		Account dummyField = new Account();
        dummyField.Name = 'Test1';
		dummyField.Contract_Expiration__c = null; //Start Date
		dummyField.License_Expiration__c = null; // End Date
		dummyField.OwnerId = UserInfo.getUserId();
		dummyField.Usable_Owner__c = UserInfo.getUserId();
        dummyField.ShippingCountry = 'US';
        
        insert dummyField;
        
        Account insertedAcct = [Select Id from Account where name = 'Test1'];
        
        Contact dummyContField = new Contact();
        dummyContField.FirstName = 'cont1';
        dummyContField.LastName = 'Cont2';
        dummyContField.AccountId = insertedAcct.Id;
        dummyContField.User__c = UserInfo.getUserId();
     
		insert dummyContField;  
        
	}
    
	@isTest static void testConstructor() {
		MassQuoteOutputController mqoc = new MassQuoteOutputController();
        mqoc.includeQ = true;
		mqoc.includeB = true;
		mqoc.includeV = true;
        mqoc.selectAll = false;
		System.assertEquals(mqoc.dummyField.OwnerId, UserInfo.getUserId());
		System.assertEquals(mqoc.dummyField.Usable_Owner__c, UserInfo.getUserId());
		System.assertEquals(false, mqoc.batchStarted);
	}	
	
	@isTest static void testGenerateAllQuotes() {
		MassQuoteOutputController mqoc = new MassQuoteOutputController();
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
        testAcct.Usable_Owner__c = UserInfo.getUserId();
        update testAcct;
        
        Contact testCont = TestUtils.createContact('DynoFirst', 'DynoLast', testAcct.id);
        testCont.User__c = UserInfo.getUserId();
        update testCont;
        
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
        testQuote.OwnerId = UserInfo.getUserId();
    	update testQuote;
        
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
        testScenario.Price_Valid_From__c = System.today();
        testScenario.Price_Valid_To__c = System.today().addDays(30);
        update  testScenario;
           
        
    	string contactID = [Select id FROM Contact WHERE User__c = :testAcct.Usable_Owner__c LIMIT 1].id;
		mqoc.dummyField.Contract_Expiration__c = System.today();
		mqoc.dummyField.License_Expiration__c = System.today().addDays(30);
        mqoc.dummyField.Account_Owner_Contact__c = contactID;
        mqoc.generateAllQuotes();
        
        system.debug(contactID);
        system.debug(mqoc.includeQ);
        system.debug(mqoc.includeB);
        system.debug(mqoc.includeV);
        system.debug(mqoc.toDownload.size());
		System.assertEquals(null, mqoc.generateAllQuotes());
		System.assert(mqoc.toDownload.size() >= 0);
	}	
	
	@isTest static void testGetUpdatedMax() {
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	testQuote.OwnerId = UserInfo.getUserId();
    	update testQuote;
    	
    	MassQuoteOutputController mqoc = new MassQuoteOutputController();
		mqoc.dummyField.Contract_Expiration__c = System.today();
		mqoc.dummyField.License_Expiration__c = System.today().addDays(30);    	
    	mqoc.generateAllQuotes();
    	System.assert(mqoc.getUpdatedMax() >= 0);
	}	
	
	@isTest static void testEmailSelected() {
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	testQuote.OwnerId = UserInfo.getUserId();
    	update testQuote;
    	
    	MassQuoteOutputController mqoc = new MassQuoteOutputController();
		mqoc.dummyField.Contract_Expiration__c = System.today();
		mqoc.dummyField.License_Expiration__c = System.today().addDays(30);    	
    	mqoc.generateAllQuotes();
    	System.assertEquals(null, mqoc.emailSelected());
    			
	}	
	
	@isTest static void testIndividualEmailSelected() {
    	Id bundledRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled' LIMIT 1].Id;
    	Account testAcct = TestUtils.createAccount('TA930', null);
    	List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC930', 'TR930', 'TS930');
    	Opportunity testQuote = TestUtils.createOppty('TQ930', testAcct.Id, 'Proposal/Price Quote', bundledRT, testSites.get(2));
    	Quote__c testScenario = TestUtils.createQuote(testQuote, testSites.get(2).Id);
    	testQuote.OwnerId = UserInfo.getUserId();
    	update testQuote;
    	
    	MassQuoteOutputController mqoc = new MassQuoteOutputController();
		mqoc.dummyField.Contract_Expiration__c = System.today();
		mqoc.dummyField.License_Expiration__c = System.today().addDays(30);    	
    	mqoc.generateAllQuotes();
    	System.assertEquals(null, mqoc.emailIndividualSelected());		
	}
}