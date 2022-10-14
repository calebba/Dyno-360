@isTest
public class CloneQuoteExtensionTest {
    @isTest static void cloneQuoteExtTest() {
            Test.startTest();
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
            u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            u1.LanguageLocaleKey = 'en_US';
            u1.Company_Codes__c = '100  DYNO NOBEL INC.;104 DYNO NOBEL WO';
            u1.State = 'UT';
            u1.Employee__c = True;
            u1.PostalCode = '84121';
            u1.IsActive = True;
            
            System.runAs(u1) {
                
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
            //Account testAcct = TestUtils.createAccount('TA439', null);
            List<Sales_Site__c> testSites = TestUtils.createSalesSiteHierarchy('TC783', 'TR783', 'TS783');
            Opportunity testOpp = TestUtils.createOppty('TO001', cust.Id, 'Prospecting');
            testOpp.Sales_Site__c = testSites[2].Id;
            update testOpp;
            Quote__c testQuote = TestUtils.createQuote(testOpp, testOpp.Sales_Site__c);
            Customer_Sales_Site__c testCSS = TestUtils.createCSS(cust.Id, testOpp.Sales_Site__c);
            Test.setCurrentPage(new PageReference(Page.CloneQuotePage.getUrl() + '?Id=' + testQuote.Id));
            ApexPages.StandardController controller = new ApexPages.StandardController(testOpp);
            CloneQuoteExtension CQE = new CloneQuoteExtension(controller);
            PageReference testLoc = CQE.getCloneUrl();
           }
        }
}