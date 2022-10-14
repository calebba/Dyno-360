@isTest
public class COPAAllocatorTest {
    
	@isTest static void testBasicAllocation() {
        // Accounts
        Account cust1 = TestUtils.createAccount('ACC1', null);
        Account cust2 = TestUtils.createAccount('ACC2', cust1.Id);
            
        // Company Site
        Sales_Site__c company = TestUtils.createSalesSite('DNNA', null, null);
            
        // Region Site
        Sales_Site__c region = TestUtils.createSalesSite('100 WEST', company.Id, null);
            
        // Sales Sites
        Sales_Site__c site = TestUtils.createSalesSite('ERAL', company.Id, region.Id);
            
        // Insert COPA Data
        List<Cost_Driver_Entry__c> entries = new List<Cost_Driver_Entry__c>(); 
        TestUtils.createCDE(cust1, site, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
        TestUtils.createCDE(cust2, site, 25, 25, 20000, 50, 50000, 45,Date.newInstance(2010,5,1));
            
        Cost_Driver_Entry__c companyEntry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :company.Id];
        Cost_Driver_Entry__c regionEntry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :region.Id];
        
        System.assertEquals(50, companyEntry.DELHRS__c);
        System.assertEquals(50, companyEntry.SHOTHRS__c);
        System.assertEquals(100, companyEntry.DISTANCE__c);
        System.assertEquals(30000, companyEntry.REVENUE__c);
        System.assertEquals(100000, companyEntry.UNITS__c);
        System.assertEquals(90, companyEntry.INVOICES__c);
        
        System.assertEquals(50, regionEntry.DELHRS__c);
        System.assertEquals(50, regionEntry.SHOTHRS__c);
        System.assertEquals(100, regionEntry.DISTANCE__c);
        System.assertEquals(30000, regionEntry.REVENUE__c);
        System.assertEquals(100000, regionEntry.UNITS__c);
        System.assertEquals(90, regionEntry.INVOICES__c);
    }
     
    @isTest static void testAdvancedAllocation() {
        // Accounts
        Account cust1 = TestUtils.createAccount('ACC1', null);
        Account cust2 = TestUtils.createAccount('ACC2', cust1.Id, 'test-3');
        Account cust3 = TestUtils.createAccount('ACC2', null);
            
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
        Sales_Site__c site4 = TestUtils.createSalesSite('3333', company2.Id, region3.Id);
        Sales_Site__c site5 = TestUtils.createSalesSite('4444', company2.Id, region4.Id);
            
        // Insert COPA Data
        List<Cost_Driver_Entry__c> entries = new List<Cost_Driver_Entry__c>(); 
        TestUtils.createCDE(cust1, site1, 25, 25, 10000, 50, 50000, 45,Date.newInstance(2010,5,1));
        TestUtils.createCDE(cust2, site2, 25, 25, 20000, 50, 50000, 45,Date.newInstance(2010,5,1));
        TestUtils.createCDE(cust2, site3, 25, 25, 20000, 50, 50000, 45,Date.newInstance(2010,5,1));
        TestUtils.createCDE(cust3, site4, 25, 25, 20000, 50, 50000, 45,Date.newInstance(2010,5,1));
        TestUtils.createCDE(cust3, site5, 25, 25, 20000, 50, 50000, 45,Date.newInstance(2010,5,1));
            
        //COPAAllocator.execute(entries);
        Cost_Driver_Entry__c company1Entry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :company1.Id];
        Cost_Driver_Entry__c company2Entry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :company2.Id];
        Cost_Driver_Entry__c region1Entry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :region1.Id];
        Cost_Driver_Entry__c region2Entry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :region2.Id];
        Cost_Driver_Entry__c region3Entry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :region3.Id];
        Cost_Driver_Entry__c region4Entry = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :region4.Id];
            
        System.assertEquals(75, company1Entry.DELHRS__c);
        System.assertEquals(75, company1Entry.SHOTHRS__c);
        System.assertEquals(150, company1Entry.DISTANCE__c);
        System.assertEquals(50000, company1Entry.REVENUE__c);
        System.assertEquals(150000, company1Entry.UNITS__c);
        System.assertEquals(135, company1Entry.INVOICES__c);
        
        System.assertEquals(50, company2Entry.DELHRS__c);
        System.assertEquals(50, company2Entry.SHOTHRS__c);
        System.assertEquals(100, company2Entry.DISTANCE__c);
        System.assertEquals(40000, company2Entry.REVENUE__c);
        System.assertEquals(100000, company2Entry.UNITS__c);
        System.assertEquals(90, company2Entry.INVOICES__c);
        
        System.assertEquals(25, region1Entry.DELHRS__c);
        System.assertEquals(25, region1Entry.SHOTHRS__c);
        System.assertEquals(50, region1Entry.DISTANCE__c);
        System.assertEquals(10000, region1Entry.REVENUE__c);
        System.assertEquals(50000, region1Entry.UNITS__c);
        System.assertEquals(45, region1Entry.INVOICES__c);
        
        System.assertEquals(50, region2Entry.DELHRS__c);
        System.assertEquals(50, region2Entry.SHOTHRS__c);
        System.assertEquals(100, region2Entry.DISTANCE__c);
        System.assertEquals(40000, region2Entry.REVENUE__c);
        System.assertEquals(100000, region2Entry.UNITS__c);
        System.assertEquals(90, region2Entry.INVOICES__c);
        
        System.assertEquals(25, region3Entry.DELHRS__c);
        System.assertEquals(25, region3Entry.SHOTHRS__c);
        System.assertEquals(50, region3Entry.DISTANCE__c);
        System.assertEquals(20000, region3Entry.REVENUE__c);
        System.assertEquals(50000, region3Entry.UNITS__c);
        System.assertEquals(45, region3Entry.INVOICES__c);
        
        System.assertEquals(25, region4Entry.DELHRS__c);
        System.assertEquals(25, region4Entry.SHOTHRS__c);
        System.assertEquals(50, region4Entry.DISTANCE__c);
        System.assertEquals(20000, region4Entry.REVENUE__c);
        System.assertEquals(50000, region4Entry.UNITS__c);
        System.assertEquals(45, region4Entry.INVOICES__c);
    }
    
    @isTest static void testMultiMonthPosts() { 
        // Accounts
        Account cust1 = TestUtils.createAccount('ACC1', null);
        Account cust2 = TestUtils.createAccount('ACC2', null);
            
        // Company Site
        Sales_Site__c company = TestUtils.createSalesSite('DNNA', null, null);
            
        // Region Site
        Sales_Site__c region = TestUtils.createSalesSite('100 WEST', company.Id, null);
            
        // Sales Sites
        Sales_Site__c site = TestUtils.createSalesSite('ERAL', company.Id, region.Id);
            
        // Insert COPA Data
        List<Cost_Driver_Entry__c> entries = new List<Cost_Driver_Entry__c>();
        //Account customer, Sales_Site__c site, Double dHrs, Double ssHrs, Double revenue, Double mileage, Double units, Double invoices, Date currentMonth
        entries.add(new Cost_Driver_Entry__c(Account__c=cust1.Id,Sales_Site__c=site.Id,DELHRS__c=25,SHOTHRS__c=25,REVENUE__c=10000,DISTANCE__c=50,UNITS__c=50000,INVOICES__c=45, Current_Month__c=Date.newInstance(2010,5,1)));
        entries.add(new Cost_Driver_Entry__c(Account__c=cust1.Id,Sales_Site__c=site.Id,DELHRS__c=26,SHOTHRS__c=26,REVENUE__c=10001,DISTANCE__c=51,UNITS__c=50001,INVOICES__c=46, Current_Month__c=Date.newInstance(2010,6,1)));
        insert entries; 

        Cost_Driver_Entry__c companyEntry1 = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :company.Id];
        Cost_Driver_Entry__c companyEntry2 = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,6,1) And Sales_Site__c = :company.Id];
        Cost_Driver_Entry__c regionEntry1 = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,5,1) And Sales_Site__c = :region.Id];
        Cost_Driver_Entry__c regionEntry2 = [Select c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where Current_Month__c = :Date.newInstance(2010,6,1) And Sales_Site__c = :region.Id];
        
        System.assertEquals(25, companyEntry1.DELHRS__c);
        System.assertEquals(25, companyEntry1.SHOTHRS__c);
        System.assertEquals(50, companyEntry1.DISTANCE__c);
        System.assertEquals(10000, companyEntry1.REVENUE__c);
        System.assertEquals(50000, companyEntry1.UNITS__c);
        System.assertEquals(45, companyEntry1.INVOICES__c);
        
        System.assertEquals(26, companyEntry2.DELHRS__c);
        System.assertEquals(26, companyEntry2.SHOTHRS__c);
        System.assertEquals(51, companyEntry2.DISTANCE__c);
        System.assertEquals(10001, companyEntry2.REVENUE__c);
        System.assertEquals(50001, companyEntry2.UNITS__c);
        System.assertEquals(46, companyEntry2.INVOICES__c);
        
        System.assertEquals(25, regionEntry1.DELHRS__c);
        System.assertEquals(25, regionEntry1.SHOTHRS__c);
        System.assertEquals(50, regionEntry1.DISTANCE__c);
        System.assertEquals(10000, regionEntry1.REVENUE__c);
        System.assertEquals(50000, regionEntry1.UNITS__c);
        System.assertEquals(45, regionEntry1.INVOICES__c);
        
        System.assertEquals(26, regionEntry2.DELHRS__c);
        System.assertEquals(26, regionEntry2.SHOTHRS__c);
        System.assertEquals(51, regionEntry2.DISTANCE__c);
        System.assertEquals(10001, regionEntry2.REVENUE__c);
        System.assertEquals(50001, regionEntry2.UNITS__c);
        System.assertEquals(46, regionEntry2.INVOICES__c);
    }
}