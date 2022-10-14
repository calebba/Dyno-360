@isTest
public class CopaToCDETest {
	@isTest static void testCopaToCDE() {
		
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
				
		
						// Insert COPA Data
		List<Copa__c> entries = new List<Copa__c>(); 
			
		entries.add(TestUtils.createCopa(cust1, site1, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1)));
		entries.add(TestUtils.createCopa(cust1, site1, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,2)));
		entries.add(TestUtils.createCopa(cust1, site1, 75, 75, 10000, 50, 50000, 45,Date.newInstance(2010,5,3)));
		entries.add(TestUtils.createCopa(cust1, site2, 75, 75, 10000, 50, 50000, 45,Date.newInstance(2010,5,3)));
		entries.add(TestUtils.createCopa(cust1, site1, 75, 75, 10000, 50, 50000, 45,Date.newInstance(2010,4,3)));
		entries.add(TestUtils.createCopa(cust1, site1, 75, 75, 10000, 50, 50000, 45,Date.newInstance(2010,4,1)));
		insert entries;
			
		List<Cost_Driver_Entry__c>  CDE_Results = [SELECT c.Current_Month__c, c.DELHRS__c, c.Sales_Site__c FROM Cost_Driver_Entry__c c WHERE Sales_Site__c=: site1.Id AND c.Current_Month__c = 2010-05-01];
		System.debug('Agg Result Count' + CDE_Results.size());
		
		for (Cost_Driver_Entry__c d: CDE_Results){
				String currDate = d.Current_Month__c + '';
				System.assertEquals(d.DELHRS__c,125.000);
				System.assertEquals(d.Sales_Site__c, site1.Id);
				System.assertEquals(currDate, '2010-05-01 00:00:00');	
		}
			
		List<Cost_Driver_Entry__c>  CDE_Results2 = [SELECT c.Current_Month__c, c.DELHRS__c, c.Sales_Site__c FROM Cost_Driver_Entry__c c WHERE Sales_Site__c=: site1.Id AND c.Current_Month__c = 2010-04-01];
		System.debug('Agg Result Count' + CDE_Results2.size());
			
		for (Cost_Driver_Entry__c d: CDE_Results2){
				String currDate2 = d.Current_Month__c + '';
				System.assertEquals(d.DELHRS__c,150.000);
				System.assertEquals(d.Sales_Site__c, site1.Id);
				System.assertEquals(currDate2, '2010-04-01 00:00:00');	
		}
			
	}
}