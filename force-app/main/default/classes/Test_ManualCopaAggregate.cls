@isTest
public class Test_ManualCopaAggregate {
	public static testmethod void test1() {
		Account cust1 = TestUtils.createAccount('ACC1', null,'123');
		cust1.Account_Group__c = '0002 Ship-to party';
		update cust1;
		
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
		Copa__c entry = TestUtils.createCopa(cust1, site1, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
		entry.Total_Cogs__c = 100;
		entry.Current_Month__c = date.today();

		Copa__c entry2 = TestUtils.createCopa(cust1, site2, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
		entry2.Total_Cogs__c = 100;
		entry2.Current_Month__c = date.today();
		
		insert entry;
		insert entry2;
		
		COPA_Aggregate__c ca = new COPA_Aggregate__c();
		List<COPA_Aggregate__c> cas = new List<COPA_Aggregate__c>();
		cas.add(ca);
		insert cas;
		
		//User currentUser = [SELECT Email FROM User WHERE IsActive = true limit 1]
		
		ApexPages.StandardSetcontroller controller = new ApexPages.StandardSetcontroller(cas);
		ManualCopaAggregate mca = new ManualCopaAggregate(controller);
		mca.month = String.valueof(date.today().month());
		
		mca.getKeyPrefix();
		mca.getYears();
		mca.GoBack();
		mca.SendInfo();
	}
	
	public static testmethod void test2() {
		Account cust1 = TestUtils.createAccount('ACC1', null,'123');
		
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
		Copa__c entry = TestUtils.createCopa(cust1, site1, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
		entry.Total_Cogs__c = 100;
		entry.Current_Month__c = date.today();

		Copa__c entry2 = TestUtils.createCopa(cust1, site2, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
		entry2.Total_Cogs__c = 100;
		entry2.Current_Month__c = date.today();
		
		insert entry;
		insert entry2;
		
		COPA_Aggregate__c ca = new COPA_Aggregate__c();
		List<COPA_Aggregate__c> cas = new List<COPA_Aggregate__c>();
		cas.add(ca);
		insert cas;
		
		//User currentUser = [SELECT Email FROM User WHERE IsActive = true limit 1]
		
		ApexPages.StandardSetcontroller controller = new ApexPages.StandardSetcontroller(cas);
		ManualCopaAggregate mca = new ManualCopaAggregate(controller);
		mca.month = String.valueof(date.today().month());
		
		mca.getKeyPrefix();
		mca.getYears();
		mca.GoBack();
		mca.SendInfo();
	}
}