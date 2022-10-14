@istest
public class DCServiceTriggerTest {
    
/*
 * Run under specific user
 * Make sure user has key prefix (prerequisite)
 * Create the instance (dyno consult service)
 * Save it
 * Verify that the key field was filled in appropriately
 * user record: Key = DNO, end result = DNO2016
*/

    public static testmethod void KeyIsPopulatedWhenDynoConsultIsCreated(){
        //Create the user with required fields set up
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User usr = new User(
      Alias = 'standt', 
      Email='standarduser@am.dynonobel.com.dynoconsult',
      EmailEncodingKey='UTF-8', 
      LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', 
      UserName='standarduser@am.dynonobel.com.dynoconsult', 
      DynoConsult_Prefix__c='DNO');
      insert usr;
          
      System.runAs(usr) {
         // The following code runs as user 'usr'
         
         Account acct = new Account(
         Name = 'Test Account',
         ShippingState = 'UT',
         ShippingPostalCode = '84121');
         insert acct;
         
         Account acc=[SELECT id,Name FROM Account WHERE id=: acct.Id];
         System.assertEquals(acc.Name, 'Test Account');
         
         DynoConsult_Service__c dcs1 = new DynoConsult_Service__c( Name = 'Test DCS 1', Account__c = acct.id, Description__c = 'Test DC Service 1',StartDate__c = System.today());
         DynoConsult_Service__c dcs2 = new DynoConsult_Service__c( Name = 'Test DCS 2', Account__c = acct.id, Description__c = 'Test DC Service 2',StartDate__c = System.today());
         
         insert dcs1;
         insert dcs2;
          
         List<DynoConsult_Service__c> dcsAll = [SELECT Key__c FROM DynoConsult_Service__c];          
          
         System.assertEquals(2, dcsAll.Size());
         System.assertEquals('DNO-' + string.valueof(Date.Today().Year()) + '-1', dcsAll[0].Key__c);
         System.assertEquals('DNO-' + string.valueof(Date.Today().Year()) + '-2', dcsAll[1].Key__c);         
  
      }
    
    }

}