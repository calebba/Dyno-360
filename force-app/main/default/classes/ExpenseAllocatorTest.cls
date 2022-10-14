@isTest
public class ExpenseAllocatorTest {
	
      @isTest static void testDetermineDates() {
            List<Date> dl = ExpenseAllocator.determineDates(Date.parse('4/1/2001'), Date.parse('4/1/2001') );
            System.assertEquals(1, dl.size());
            dl = ExpenseAllocator.determineDates(Date.parse('1/1/2001'),Date.parse('12/1/2001'));
            System.assertEquals(12, dl.size());
            dl = ExpenseAllocator.determineDates(Date.parse('1/1/2001'),Date.parse('12/1/2002'));
            System.assertEquals(24, dl.size());
            dl = ExpenseAllocator.determineDates(Date.parse('1/1/2001'),Date.parse('12/1/2003'));
            System.assertEquals(36, dl.size());
            dl = ExpenseAllocator.determineDates(Date.parse('1/1/2001'),Date.parse('12/1/2004'));
            System.assertEquals(48, dl.size());
            dl = ExpenseAllocator.determineDates(Date.parse('1/1/2001'),Date.parse('12/1/2005'));
            System.assertEquals(60, dl.size());
            dl = ExpenseAllocator.determineDates(Date.parse('1/1/2001'),Date.parse('6/1/2006'));
            System.assertEquals(66, dl.size());                                     
        }
        
        @isTest static void testSimpleHierarchy() {
            Test.startTest();
            // Accounts
            Account cust1 = TestUtils.createAccount('ACC1', null);
            Account cust2 = TestUtils.createAccount('ACC2', null);
            
            // Company Site
            Sales_Site__c company = TestUtils.createSalesSite('DNNA', null, null);
            
            // Region Site
            Sales_Site__c region = TestUtils.createSalesSite('100 WEST', company.Id, null);
            
            // Sales Sites
            Sales_Site__c site1 = TestUtils.createSalesSite('ERAL', company.Id, region.Id);
            Sales_Site__c site2 = TestUtils.createSalesSite('ERNA', company.Id, region.Id);
            
            // Insert COPA Data
            List<Cost_Driver_Entry__c> cdes = new List<Cost_Driver_Entry__c>();
            cdes.add(new Cost_Driver_Entry__c(Account__c =cust1.Id, Sales_Site__c=site1.Id, DELHRS__c=25, SHOTHRS__c=25, REVENUE__c=10000, DISTANCE__c=50, UNITS__c=50000, INVOICES__c=45, CURRENT_MONTH__c=Date.newInstance(2010,5,1)));
            cdes.add(new Cost_Driver_Entry__c(Account__c =cust2.Id, Sales_Site__c=site2.Id, DELHRS__c=25, SHOTHRS__c=25, REVENUE__c=10000, DISTANCE__c=50, UNITS__c=50000, INVOICES__c=45, CURRENT_MONTH__c=Date.newInstance(2010,5,1)));
            insert cdes;
            
            // Insert PCA Data
            List<PCA__c> pcas = new List<PCA__c>();
            //String costCenterCode, Double invoices, Double mhrs, Double mileage, Double units, Double revExp, Sales_Site__c site, Double tHrs
            pcas.add(new PCA__c(Cost_Center_Code__c='DNNA', Miles_Reg__c=0, Mhrs_Reg__c=0,Invoice_Reg__c=0,Pounds_Reg__c=0, Total_Hrs_Reg__c=0,Rev_Exp_Reg__c=0, Miles_Comp__c=0, Mhrs_Comp__c=0,Invoice_Comp__c=0,Pounds_Comp__c=0, Total_Hrs_Comp__c=0,Rev_Exp_Comp__c=0, Invoice__c=25000, Mhrs__c=15000, Miles__c=20000, Pounds__c=10000, Rev_Exp__c=30000, Sales_Site__c=company.Id, Total_Hrs__c=40000, Post_Month__c=Date.newInstance(2010,5,1)));
            pcas.add(new PCA__c(Cost_Center_Code__c='100 WEST', Miles_Reg__c=0, Mhrs_Reg__c=0,Invoice_Reg__c=0,Pounds_Reg__c=0, Total_Hrs_Reg__c=0,Rev_Exp_Reg__c=0, Miles_Comp__c=0, Mhrs_Comp__c=0,Invoice_Comp__c=0,Pounds_Comp__c=0, Total_Hrs_Comp__c=0,Rev_Exp_Comp__c=0,Invoice__c=5000, Mhrs__c=5000, Miles__c=2000, Pounds__c=1000, Rev_Exp__c=3000, Sales_Site__c=region.Id, Total_Hrs__c=4000, Post_Month__c=Date.newInstance(2010,5,1)));
            pcas.add(new PCA__c(Cost_Center_Code__c='ERAL', Miles_Reg__c=0, Mhrs_Reg__c=0,Invoice_Reg__c=0,Pounds_Reg__c=0, Total_Hrs_Reg__c=0,Rev_Exp_Reg__c=0, Miles_Comp__c=0, Mhrs_Comp__c=0,Invoice_Comp__c=0,Pounds_Comp__c=0, Total_Hrs_Comp__c=0,Rev_Exp_Comp__c=0,Invoice__c=0, Mhrs__c=150, Miles__c=200, Pounds__c=0, Rev_Exp__c=30, Sales_Site__c=site1.Id, Total_Hrs__c=0, Post_Month__c=Date.newInstance(2010,5,1)));
            insert pcas;
            Test.stopTest();
            
            // Validate that the PCA was allocated correctly
            PCA__c eralPCA = [Select p.Total_Hrs__c, p.Total_Hrs_Total__c, p.Rev_Exp_Total__c, p.Pounds_Total__c, p.Miles_Total__c, p.Mhrs_Total__c, p.Invoice_Total__c, p.Total_Hrs_Rate__c, p.Rev_Exp_Rate__c, p.Pounds_Rate__c, p.Miles_Rate__c, p.Mhrs_Rate__c, p.Invoice_Rate__c From PCA__c p where p.Sales_Site__c = :site1.Id];
           /* System.assertEquals(22000, eralPCA.Total_Hrs_Total__c);
            System.assertEquals(16530, eralPCA.Rev_Exp_Total__c);
            System.assertEquals(5500, eralPCA.Pounds_Total__c);
            System.assertEquals(11200, eralPCA.Miles_Total__c);
            System.assertEquals(10150, eralPCA.Mhrs_Total__c);
            System.assertEquals(15000, eralPCA.Invoice_Total__c);
            System.assertEquals(440, eralPCA.Total_Hrs_Rate__c.setScale(3));
            System.assertEquals(1.653, eralPCA.Rev_Exp_Rate__c.setScale(3));
            System.assertEquals(.11, eralPCA.Pounds_Rate__c.setScale(3));
            System.assertEquals(224, eralPCA.Miles_Rate__c.setScale(3));
            System.assertEquals(406, eralPCA.Mhrs_Rate__c.setScale(3));
            System.assertEquals(333.333, eralPCA.Invoice_Rate__c.setScale(3));*/

            Sales_Site__c eral = [Select s.Average_Total_Hrs__c, s.Average_Rev_Exp__c, s.Average_Pounds__c, s.Average_Miles__c, s.Average_Mhrs__c, s.Average_Invoice__c From Sales_Site__c s where s.Id = :site1.Id];
           /* System.assertEquals(440, eral.Average_Total_Hrs__c.setScale(3));
            System.assertEquals(1.653, eral.Average_Rev_Exp__c.setScale(3));
            System.assertEquals(.11, eral.Average_Pounds__c.setScale(3));
            System.assertEquals(224, eral.Average_Miles__c.setScale(3));
            System.assertEquals(406, eral.Average_Mhrs__c.setScale(3));
            System.assertEquals(333.333, eral.Average_Invoice__c.setScale(3));*/
            
            PCA__c ernaPCA = [Select p.Total_Hrs_Total__c, p.Rev_Exp_Total__c, p.Pounds_Total__c, p.Miles_Total__c, p.Mhrs_Total__c, p.Invoice_Total__c From PCA__c p where p.Sales_Site__c = :site2.Id];
            /*System.assertEquals(22000, ernaPCA.Total_Hrs_Total__c);
            System.assertEquals(16500, ernaPCA.Rev_Exp_Total__c);
            System.assertEquals(5500, ernaPCA.Pounds_Total__c);
            System.assertEquals(11000, ernaPCA.Miles_Total__c);
            System.assertEquals(10000, ernaPCA.Mhrs_Total__c);
            System.assertEquals(15000, ernaPCA.Invoice_Total__c); */
            
            PCA__c dnnaPCA = [Select p.Total_Hrs_Total__c, p.Rev_Exp_Total__c, p.Pounds_Total__c, p.Miles_Total__c, p.Mhrs_Total__c, p.Invoice_Total__c From PCA__c p where p.Sales_Site__c = :company.Id];
            /*System.assertEquals(40000, dnnaPCA.Total_Hrs_Total__c);
            System.assertEquals(30000, dnnaPCA.Rev_Exp_Total__c);
            System.assertEquals(10000, dnnaPCA.Pounds_Total__c);
            System.assertEquals(20000, dnnaPCA.Miles_Total__c);
            System.assertEquals(15000, dnnaPCA.Mhrs_Total__c);
            System.assertEquals(25000, dnnaPCA.Invoice_Total__c);*/
        }

        /*
        private static testmethod void testLargeHierarchy() {
            // Company Site
            // Region 1 Site
            // Region 2 Site
            // Region 3 Site
            // Region 1 Sales Site 1
            // Region 1 Sales Site 2
            // Region 1 Sales Site 3
            // Region 2 Sales Site 1
            // Region 2 Sales Site 2
            // Region 2 Sales Site 3
            // Region 3 Sales Site 1
            // Region 3 Sales Site 2
            // Region 3 Sales Site 3
        }*/
}