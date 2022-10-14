@isTest
//@isTest(SeeAllData=true)
private class PandLTests {
    
    /*
    * FIX UNIT TESTS WHEN P&L IS FIXED
    */
    static testMethod void myUnitTest() {
           Account testCustomer = TestUtils.createAccount('TestCust001', null);
           testCustomer.SAP_Account_Number__c = 'test l 08956';
           testCustomer.Account_Group__c = '0002 Ship-to party';
           update testCustomer;
           Sales_Site__c testCompany = TestUtils.createPlant('Lucian-c');
           Sales_Site__c testRegion = TestUtils.createPlant('Lucian-r');
           testRegion.Company_Site__c = testCompany.Id;
           update testRegion;
           Sales_Site__c testSite = TestUtils.createPlant('Lucian-s');
           testSite.Region_Site__c = testRegion.Id;
           testSite.Company_Site__c = testCompany.Id;
           update testSite;
           Customer_Sales_Site__c css = TestUtils.CreateCSS(testCustomer.Id, testSite.Id);
           
           Test.startTest();
           
           PandLGeneratorController pageController = new PandLGeneratorController();
           System.assertEquals(date.today().addyears(-1), pageController.dummyQuote.Price_Valid_From__c);
           System.assertEquals(date.today().addmonths(-1), pageController.dummyQuote.Price_Valid_To__c);
           pageController.dummyQuote.Customer__c = testCustomer.Id;
           pageController.dummyQuote.Price_Valid_From__c = date.newInstance(2010, 01, 01);
           pageController.dummyQuote.Price_Valid_To__c = date.newInstance(2010, 10, 10);
           pageController.dummyQuote.Sales_Organization_Primary__c = null;
           pageController.reporttype = 'Detail';
           pageController.hideZeroData = false;
           pageController.orderby = 'Company ASC';
           
           pageController.ResetRegion();
           pageController.ResetCompany();
           pageController.getReportTypes();
           pageController.dummyQuoteCustomerNumber = 'test l 08956';
           pageController.dummyQuoteCustomerNumber = pageController.dummyQuoteCustomerNumber;
           pageController.setQuoteCustomer();
           pageController.setCustomerNumber();
           System.assertEquals('0002 Ship-to party', pageController.customerAccountGroup);
           pageController.getMonths();
           pageController.getYears();
           pageController.monthFrom = pageController.monthFrom;
           pageController.monthTo = pageController.monthTo;
           pageController.yearFrom = pageController.yearFrom;
           pageController.yearTo = pageController.yearTo;
           pageController.regionId = testRegion.Id;
           pageController.siteId = testSite.Id;
           pageController.generatePandL(); 
           pageController.orderby = 'Region DESC';
           pageController.generatePandL(); 
           pageController.orderby = 'Company DESC';
           pageController.generatePandL(); 
           System.assertEquals(1, pageController.getCurrentPage().size());
           pageController.getIndustries();
           pageController.getRegionOptions();
           pageController.getCompanyOptions();
           pageController.siteId = null;
           pageController.getRegionOptions();
           pageController.getCompanyOptions();
           pageController.regionId = null;
           pageController.getRegionOptions();
           pageController.getCompanyOptions();
           pageController.nextPage();
           pageController.previousPage();

           Test.stopTest();
    }
    
    private static testmethod void testSimplePandL() {
        Date theDate = Date.newInstance(2010,5,1);
        // Create customer
        Account cust = TestUtils.createAccount('Test', null, '1234567890');
        // Create site hierarchy
        List<Sales_Site__c> sites = TestUtils.createSalesSiteHierarchy('COMP', 'REG', 'SITE');
        Sales_Site__c otherSite = TestUtils.createSalesSite('Other', sites[0].Id, sites[1].Id);
        
        // Create Actuals for site
        // Account customer, Sales_Site__c site, Double dHrs, Double ssHrs, Double revenue, Double mileage, Double units, Double invoices, Date currentMonth
        List<Cost_Driver_Entry__c> cdes = new List<Cost_Driver_Entry__c>();
        cdes.add(new Cost_Driver_Entry__c(Account__c=cust.Id, Sales_Site__c=sites[2].Id, DELHRS__c=500, SHOTHRS__c=250, REVENUE__c=150000, DISTANCE__c=1000, UNITS__c=250000, INVOICES__c=45, Current_Month__c=theDate));
        cdes.add(new Cost_Driver_Entry__c(Account__c=cust.Id, Sales_Site__c=otherSite.Id, DELHRS__c=100, SHOTHRS__c=50, REVENUE__c=50000, DISTANCE__c=100, UNITS__c=25000, INVOICES__c=5, Current_Month__c=theDate));
        insert cdes;
        
        Cost_Driver_Entry__c regionCDE = [Select DELHRS__c, SHOTHRS__c, REVENUE__c, DISTANCE__c, UNITS__c, INVOICES__c from Cost_Driver_Entry__c where Sales_Site__c=:sites[1].Id And Current_Month__c=:theDate];
        Cost_Driver_Entry__c companyCDE = [Select DELHRS__c, SHOTHRS__c, REVENUE__c, DISTANCE__c, UNITS__c, INVOICES__c from Cost_Driver_Entry__c where Sales_Site__c=:sites[0].Id And Current_Month__c=:theDate];
        
        System.assertEquals(600, regionCDE.DELHRS__c);
        System.assertEquals(300, regionCDE.SHOTHRS__c);
        System.assertEquals(200000, regionCDE.REVENUE__c);
        System.assertEquals(1100, regionCDE.DISTANCE__c);
        System.assertEquals(275000, regionCDE.UNITS__c);
        System.assertEquals(50, regionCDE.INVOICES__c);
        
        System.assertEquals(600, companyCDE.DELHRS__c);
        System.assertEquals(300, companyCDE.SHOTHRS__c);
        System.assertEquals(200000, companyCDE.REVENUE__c);
        System.assertEquals(1100, companyCDE.DISTANCE__c);
        System.assertEquals(275000, companyCDE.UNITS__c);
        System.assertEquals(50, companyCDE.INVOICES__c);
        
        Test.startTest();
        List<PCA__c> pcas = new List<PCA__c>();
        pcas.add(new PCA__c(Sales_Site__c=sites[0].Id, Post_Month__c=theDate, Invoice__c=50000, Mhrs__c=1000, Miles__c=100000, Pounds__c=1500000, Rev_Exp__c=1200000, Total_Hrs__c=12400));
        pcas.add(new PCA__c(Sales_Site__c=sites[1].Id, Post_Month__c=theDate, Invoice__c=25000, Mhrs__c=1000, Miles__c=50000, Pounds__c=750000, Rev_Exp__c=140000, Total_Hrs__c=3455));
        pcas.add(new PCA__c(Sales_Site__c=sites[2].Id, Post_Month__c=theDate, Invoice__c=5000, Mhrs__c=200, Miles__c=800, Pounds__c=7500, Rev_Exp__c=14000, Total_Hrs__c=350));
        insert pcas;
        
        
        PCA__c sitePCA = [Select Invoice__c, Invoice_Total__c, Mhrs__c, Mhrs_Total__c, Miles__c, Miles_Total__c, Pounds__c, Pounds_Total__c, Rev_Exp__c, Rev_Exp_Total__c, Total_Hrs__c, Total_Hrs_Total__c from PCA__c where Sales_Site__c=:sites[2].Id and Post_Month__c=:theDate];
        System.assertEquals(1866.667, sitePCA.Mhrs_Total__c.setScale(3));
        System.assertEquals(13562.5, sitePCA.Total_Hrs_Total__c.setScale(3));
        System.assertEquals(1019000, sitePCA.Rev_Exp_Total__c.setScale(3));
        System.assertEquals(137163.636, sitePCA.Miles_Total__c.setScale(3));
        System.assertEquals(2052954.545, sitePCA.Pounds_Total__c.setScale(3));
        System.assertEquals(72500, sitePCA.Invoice_Total__c.setScale(3));
        
        /*
        cdes = new List<Cost_Driver_Entry__c>();
        cdes.add(new Cost_Driver_Entry__c(Account__c=cust.Id, Sales_Site__c=sites[2].Id, DELHRS__c=500, SHOTHRS__c=250, REVENUE__c=150000, DISTANCE__c=1000, UNITS__c=250000, INVOICES__c=45, Current_Month__c=Date.newInstance(2010,6,1)));
        cdes.add(new Cost_Driver_Entry__c(Account__c=cust.Id, Sales_Site__c=otherSite.Id, DELHRS__c=100, SHOTHRS__c=50, REVENUE__c=50000, DISTANCE__c=100, UNITS__c=25000, INVOICES__c=5, Current_Month__c=Date.newInstance(2010,6,1)));
        insert cdes; 
        
        pcas = new List<PCA__c>();
        pcas.add(new PCA__c(Sales_Site__c=sites[0].Id, Post_Month__c=Date.newInstance(2010,6,1), Invoice__c=50000, Mhrs__c=1000, Miles__c=100000, Pounds__c=1500000, Rev_Exp__c=1200000, Total_Hrs__c=12400));
        pcas.add(new PCA__c(Sales_Site__c=sites[1].Id, Post_Month__c=Date.newInstance(2010,6,1), Invoice__c=25000, Mhrs__c=1000, Miles__c=50000, Pounds__c=750000, Rev_Exp__c=140000, Total_Hrs__c=3455));
        insert pcas;
        */
        
        // Create Expenses
        // Sales_Site__c site, Date postMonth, Double invoices, Double mhrs, Double mileage, Double units, Double revExp, Double tHrs
        
        
            
        // Site 1
        // 5/1/2010
        // dHrs,    ssHrs,  revenue,    mileage,    units,      invoices
        // 500      250     150000      1000        250000      45
        // 2000     15855   1340000     150000      2250000     750000
        // 4        21.14   8.933       150         9           16666.667
        
        // 6/1/2010
        // dHrs,    ssHrs,  revenue,    mileage,    units,      invoices
        // 500      250     150000      1000        250000      45
        // 1666.667 13212.5 1005000     136363.636  2045454.545 675000
        // 3.333    17.617  6.7         136.363     8.182       15000
        // {Site_Cost_Driver_Rate_Total_Hrs__c=7.677777777777778, Site_Cost_Driver_Rate_Pounds__c=5.454545454545454, Site_Cost_Driver_Rate_Invoice__c=1000.00, Site_Cost_Driver_Rate_Rev_Exp__c=1.40, Site_Cost_Driver_Rate_Miles__c=90.9090909090909, Site_Cost_Driver_Rate_Mhrs__c=3.3333333333333335}
        
        // Create quote header
        Opportunity opp = TestUtils.createOppty('TEST OPPTY', cust.Id, 'Prospecting');
        Quote__c q = new Quote__c(
            Customer__c = cust.Id,
            Active_Quote__c = true,
            Opportunity__c = opp.Id,
            Sales_Organization_Primary__c = sites[2].Id,
            Quote_Valid_From__c=theDate.addDays(-1),
            Quote_Valid_To__c=theDate.addYears(1),
            Price_Valid_From__c=theDate.addDays(-1),
            Price_Valid_To__c=theDate.addYears(1),
            Quote_Description__c = 'Test',
            Delivery_Hours__c=100,
            Shot_Service_Load_Assistance_Hours__c=100,
            Round_Trip_Truck_Distance__c=1000,
            Total_Number_of_Invoices__c=12,
            Annual_Number_Of_Events__c = 5
        );
        insert q;
        q = [Select Name from Quote__c where Id = :q.Id];
        
        // Assert correct site driver rates
        //Invoice 5000 / 45 = 111.11
        //Mhrs 200 / 500 = .4
        //Miles 800 / 1000 = .8
        //Pounds 7500 / 250000 = .03 
        //Rev Exp 14000 / 150000 = .0933
        //Shot Hours 350 / 250 = 1.4
        Quote__c siteDriverRates = [Select q.Site_Cost_Driver_Rate_Total_Hrs__c,q.Sales_Organization_Primary__c,q.Price_Valid_To__c,q.Price_Valid_From__c,q.Site_Cost_Driver_Rate_Rev_Exp__c, q.Site_Cost_Driver_Rate_Pounds__c, q.Site_Cost_Driver_Rate_Miles__c, q.Site_Cost_Driver_Rate_Mhrs__c, q.Site_Cost_Driver_Rate_Invoice__c From Quote__c q where q.Id = :q.Id];
        /*System.debug(Logginglevel.ERROR, siteDriverRates);
        System.assertEquals(1.4, siteDriverRates.Site_Cost_Driver_Rate_Total_Hrs__c.setScale(3));
        System.assertEquals(.093, siteDriverRates.Site_Cost_Driver_Rate_Rev_Exp__c.setScale(3));
        System.assertEquals(.03, siteDriverRates.Site_Cost_Driver_Rate_Pounds__c.setScale(3));
        System.assertEquals(.8, siteDriverRates.Site_Cost_Driver_Rate_Miles__c.setScale(3));
        System.assertEquals(.4, siteDriverRates.Site_Cost_Driver_Rate_Mhrs__c.setScale(3));
        System.assertEquals(111.111, siteDriverRates.Site_Cost_Driver_Rate_Invoice__c.setScale(3));*/
        
        // Assert correct metrics without line items
        PandLData data = PandLData.createForQuote(q.Id);
        PandLData.createForCustomerSalesSite(cust.Id, sites[2].Id, theDate.addDays(-1), theDate.addYears(1));
        PandLData.createForCustomer(cust.Id, theDate.addDays(-1), theDate.addYears(1));
        PandLData.getTAIC(siteDriverRates.Id);
        PandLData.createForQuote(siteDriverRates.Id, 2);
        PandLData.createForSite(siteDriverRates.Sales_Organization_Primary__c, siteDriverRates.Price_Valid_To__c, siteDriverRates.Price_Valid_From__c);
        //createForPandLGenerator2(theDate.addDays(-1), theDate.addYears(1), cust.Id,true, sites[2].Id, Id regionId, Id companyId, '--None--', cust.Account_Manager__c, Id rsmId,'USD', data, true)
        // Assert header data
        System.assertEquals('Test', data.customerName);
        System.assertEquals('COMP', data.companyName);
        System.assertEquals('REG', data.regionName);
        System.assertEquals('SITE', data.siteName);
        System.assertEquals('1234567890', data.sapCustomerNumber);
        System.assertEquals(q.Name, data.scenarioName);
        System.assertEquals(theDate.addDays(-1), data.validFrom);
        System.assertEquals(theDate.addYears(1), data.validTo);
        System.assertEquals('USD', data.currencyIsoCode);
        Test.stopTest();
        /*
        System.assertEquals(0, data.netRevenue.value);
        System.assertEquals(200, data.directCostDeliveryHrs.value);
        System.assertEquals(200, data.directCostShotHrs.value);
        System.assertEquals(400, data.directCosts.value);
        
        
        System.assertEquals(6666.67, data.indirectCostInvoices.value);
        System.assertEquals(4000, data.indirectCostMiles.value);
        System.assertEquals(0, data.indirectCostNetRevenue.value);
        System.assertEquals(1400, data.indirectCostTotalHours.value);
        System.assertEquals(0, data.indirectCostUnits.value);
        System.assertEquals(12066.67, data.indirectCosts.value);
        System.assertEquals(0, data.grossMargin.value);
        System.assertEquals(0, data.grossMarginPercentage);
        System.assertEquals(0, data.grossMarginSeeThrough.value);
        System.assertEquals(0, data.grossMarginSeeThroughPercentage);
        System.assertEquals(-900, data.contributionMargin.value);
        System.assertEquals(0, data.contributionMarginPercentage);
        System.assertEquals(-900, data.ebit.value);
        System.assertEquals(0, data.ebitPercentage);*/
        
        // Add line items
        // Create Material
        Material_Item__c item1 = TestUtils.createItemWitCost(sites[2], 12.34d);
        item1.PHL1__c='PL050';
        update item1;
        Material_Item__c item2 = TestUtils.createItemWitCost(sites[2], 23.45d);
        item2.PHL1__c='PL065';
        update item2;
        Quote_Line_Item__c qli1 = TestUtils.createQli(item1, 15.00d, '', q, 1000.0d, sites[2]);
        Quote_Line_Item__c qli2 = TestUtils.createQli(item2, 25.00d, '', q, 1000.0d, sites[2]);
        qli1.Cost__c = 12.340;
        qli1.Cost_See_Through__c = 12.340;
        qli2.Cost__c = 23.450;
        qli2.Cost_See_Through__c = 23.450;
        update qli1;
        update qli2;
          
        
        // Assert correct metrics with line items
        data = PandLData.createForQuote(q.Id);
                /*
        System.assertEquals(40000, data.netRevenue.value);
        System.assertEquals(35790, data.costOfGoodsSold.value);
        System.assertEquals(35790, data.costOfGoodsSoldSeeThrough.value);
        System.assertEquals(200, data.directCostDeliveryHrs.value);
        System.assertEquals(200, data.directCostShotHrs.value);
        System.assertEquals(400, data.directCosts.value);
        

        System.assertEquals(6666.67, data.indirectCostInvoices.value);
        System.assertEquals(4000, data.indirectCostMiles.value);
        System.assertEquals(3733.33, data.indirectCostNetRevenue.value);
        System.assertEquals(1400, data.indirectCostTotalHours.value);
        System.assertEquals(60, data.indirectCostUnits.value);
        System.assertEquals(15860, data.indirectCosts.value);
        
        System.assertEquals(4210, data.grossMargin.value);
        System.assertEquals(10.53, data.grossMarginPercentage);
        System.assertEquals(4210, data.grossMarginSeeThrough.value);
        System.assertEquals(10.53, data.grossMarginSeeThroughPercentage);
        System.assertEquals(3310, data.contributionMargin.value);
        System.assertEquals(8.28, data.contributionMarginPercentage);
        System.assertEquals(3310, data.ebit.value);
        System.assertEquals(8.275, data.ebitPercentage);    
        
        // Test Product-based GM
        System.assertNotEquals(null, data.productGmData);
        System.assertEquals(0, data.productGmData.PL084.gm.value);
        System.assertEquals(0, data.productGmData.PL084.gmPercentage);
        System.assertEquals(0, data.productGmData.PL084.gmSeeThrough.value);
        System.assertEquals(0, data.productGmData.PL084.gmSeeThroughPercentage);
        
        System.assertEquals(2660, data.productGmData.PL049_50.gm.value);
        System.assertEquals(17.73, data.productGmData.PL049_50.gmPercentage);
        System.assertEquals(2660, data.productGmData.PL049_50.gmSeeThrough.value);
        System.assertEquals(17.73, data.productGmData.PL049_50.gmSeeThroughPercentage);
        
        System.assertEquals(1550, data.productGmData.PL065.gm.value);
        System.assertEquals(6.2, data.productGmData.PL065.gmPercentage);
        System.assertEquals(1550, data.productGmData.PL065.gmSeeThrough.value);
        System.assertEquals(6.2, data.productGmData.PL065.gmSeeThroughPercentage);*/
    }
    
   
}