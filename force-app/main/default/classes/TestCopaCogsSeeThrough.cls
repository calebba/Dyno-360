@isTest
private class TestCopaCogsSeeThrough {

    static testMethod void TestMethod1() {

        Account cust1 = TestUtils.createAccount('ACC1', null);
      
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
        
        // Material
        Material_Item__c matt = new Material_Item__c();
        insert matt;
        
        // Insert Supply Chain Assumption
        Supply_Chain_Assumption__c sca = new Supply_Chain_Assumption__c(
                                            Fixed_Conversion_Cost__c = 10,
                                            Material_Item__c = matt.Id,
                                            Receiving_Sales_Site__c = site1.Id,
                                            Source_Sales_Site__c = site1.Id,
                                            RecordTypeId = [Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Supply_Cost_Allocation'].Id
                                        );
        insert sca;
        Supply_Chain_Assumption__c sca2 = new Supply_Chain_Assumption__c(
                                            Fixed_Conversion_Cost__c = 10,
                                            Material_Item__c = matt.Id,
                                            Receiving_Sales_Site__c = site2.Id,
                                            Source_Sales_Site__c = site2.Id,
                                            RecordTypeId = [Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Transfer_Price'].Id
                                        );
        insert sca2;
        
        // Insert COPA Data
        Copa__c entry = TestUtils.createCopa(cust1, site1, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
        entry.Total_Cogs__c = 100;
        entry.Material_Item__c = matt.Id;

        Copa__c entry2 = TestUtils.createCopa(cust1, site2, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
        entry2.Total_Cogs__c = 100;
        entry2.Material_Item__c = matt.Id;
          
        Test.startTest();

        insert entry;
        insert entry2;

        Test.stopTest();
        
        entry = [SELECT Id, COGS_See_Through__c FROM Copa__c WHERE Id = :entry.Id LIMIT 1];
        
        System.assertEquals(110.0, entry.COGS_See_Through__c);

        entry2 = [SELECT Id, COGS_See_Through__c FROM Copa__c WHERE Id = :entry2.Id LIMIT 1];
        
        System.assertEquals(110.0, entry2.COGS_See_Through__c);

    }
}