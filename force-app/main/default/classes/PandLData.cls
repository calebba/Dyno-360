public with sharing class PandLData {
    // header data
    public String accountManager {get;set;}
    public String industry {get;set;}
    public String SalesGroup {get;set;}
    public String SalesOffice {get;set;}
    public String customerName {get;set;}
    public String customerName2 {get;set;}
    public String companyName {get;set;}
    public String regionName {get;set;}
    public String siteName {get;set;}
    public String sapCustomerNumber {get;set;}
    public String scenarioName {get;set;}
    public String plant { get; set; }
    public Date validFrom {get;set;}
    public Date validTo {get;set;}
    
    public String TabName {
        get {
            if ((siteName == null || siteName == '') && (customerName == null || customerName == ''))
                return 'Summary';
            if (siteName == null || siteName == '')
                return customerName + '(' + sapCustomerNumber + ')';
            if (customerName == null || customerName == '')
                return siteName;
            return siteName + ' / ' + customerName + ' (' + sapCustomerNumber + ')';
        }
    }
    
    public Decimal totalst;
    public Decimal unitsst;
    
    public String validFromDisplay {get; set;}
    public String validToDisplay {get; set;}
     
    public String currencyIsoCode {get;set;}
    
    public CurrencyData netRevenue {get;set;}
    public CurrencyData indirectNetRevenue {get;set;}
    
    // Cost driver data
    public Decimal deliveryHours {get;set;}
    public Decimal shotHours {get;set;}
    public CurrencyData totalHours {get;set;}
    public CurrencyData invoices {get;set;}
    public CurrencyData distance {get;set;}
    public CurrencyData units {get;set;}
    
    // Totals
    public CurrencyData total1 {get; set;}
    public CurrencyData total2 {get; set;}
    public CurrencyData total3 {get; set;}
    public CurrencyData total4 {get; set;}
    public CurrencyData total5 {get; set;}
    
    // Cost driver rates
    public CurrencyData deliveryHoursRate {get;set;}
    public CurrencyData shotHoursRate {get;set;}
    public CurrencyData totalHoursRate {get;set;}
    public CurrencyData invoicesRate {get;set;}
    public CurrencyData distanceRate {get;set;}
    public CurrencyData unitsRate {get;set;}
    public CurrencyData netRevenueRate {get;set;}
    
    // Product Costs
    public CurrencyData costOfGoodsSold {get;set;}
    public CurrencyData costOfGoodsSoldSeeThrough {get;set;}
    
    // Total Labor Costs
    public CurrencyData directCosts {get;set;}
    public CurrencyData indirectCosts {get;set;}
    
    // Individual Labor Costs
    public CurrencyData directCostDeliveryHrs {get;set;}
    public CurrencyData directCostShotHrs {get;set;}
    public CurrencyData indirectCostMiles {get;set;}
    public CurrencyData indirectCostInvoices {get;set;}
    public CurrencyData indirectCostNetRevenue {get;set;}
    public CurrencyData indirectCostTotalHours {get;set;}
    public CurrencyData indirectCostUnits {get;set;}
    public CurrencyData revenueModifier {get; set;}
    
    // Calculated values
    public CurrencyData grossMargin {get;set;}
    public CurrencyData grossMarginSeeThrough {get;set;}
    public CurrencyData contributionMargin {get;set;}
    public CurrencyData ebit {get;set;}
    public CurrencyData ebitWith {get;set;}
    
    // Percentages
    public Decimal grossMarginPercentage {get;set;}
    public Decimal grossMarginSeeThroughPercentage {get;set;}
    public Decimal contributionMarginPercentage {get;set;}
    public Decimal ebitPercentage {get;set;} 
    public Decimal ebitPercentageWith {get;set;} 
    
    //Site, Region, Company Costs
    public CurrencyData siteTotalHrs    {get; set;}
    public CurrencyData siteDistance    {get; set;}
    public CurrencyData siteUnits       {get; set;}
    public CurrencyData siteInvoices    {get; set;}
    public CurrencyData siteNetRev      {get; set;}
    public CurrencyData regionTotalHrs  {get; set;}
    public CurrencyData regionDistance  {get; set;}
    public CurrencyData regionUnits     {get; set;}
    public CurrencyData regionInvoices  {get; set;}
    public CurrencyData regionNetRev    {get; set;} 
    public CurrencyData companyTotalHrs {get; set;}
    public CurrencyData companyDistance {get; set;}
    public CurrencyData companyUnits    {get; set;}
    public CurrencyData companyInvoices {get; set;}
    public CurrencyData companyNetRev   {get; set;}
    public CurrencyData rateTotalHrs    {get; set;}
    public CurrencyData rateDistance    {get; set;}
    public CurrencyData rateUnits       {get; set;}
    public CurrencyData rateInvoices    {get; set;}
    public CurrencyData rateNetRevenue  {get; set;}
    public CurrencyData totalHrsTotal   {get; set;}
    public CurrencyData distanceTotal   {get; set;}
    public CurrencyData unitsTotal      {get; set;}
    public CurrencyData invoicesTotal   {get; set;}
    public CurrencyData netRevTotal     {get; set;}
        
    public Boolean inGenerator          {get; set;}
    public String CompanyId             {get; set;}
    public String RegionId              {get; set;}
    public String SiteId                {get; set;}
    public String customerParentId      {get; set;}
    public String parentName            {get; set;}
    
    public String getFromDate() { 
        return EncodingUtil.urlEncode(validFromDisplay, 'UTF-8');
    }
    /*public String getFromYear() { 
        return string.valueOf(validFrom.year());
    }*/
    public String getToDate() { 
        return EncodingUtil.urlEncode(validToDisplay, 'UTF-8');
    }
    /*public String getToYear() { 
        return string.valueOf(validTo.year());
    }*/
    
    public PandLData() {
        this.inGenerator = false;
    }
    
    
    // Product GM data
    public ProductGMData productGmData {get;set;}
    
    /** METHODS THAT NEED TO BE DEPRECATED START HERE **/
        
    // Convert to target currency
    public void convert(String targetCurrencyISOCode) {
        this.netRevenue.convert(targetCurrencyISOCode);
        this.costOfGoodsSold.convert(targetCurrencyISOCode);
        this.costOfGoodsSoldSeeThrough.convert(targetCurrencyISOCode);
        this.directCosts.convert(targetCurrencyISOCode);
        this.indirectCosts.convert(targetCurrencyISOCode);
        this.directCostDeliveryHrs.convert(targetCurrencyISOCode);
        this.directCostShotHrs.convert(targetCurrencyISOCode);
        this.indirectCostMiles.convert(targetCurrencyISOCode);
        this.indirectCostInvoices.convert(targetCurrencyISOCode);
        this.indirectCostNetRevenue.convert(targetCurrencyISOCode);
        this.indirectCostTotalHours.convert(targetCurrencyISOCode);
        this.indirectCostUnits.convert(targetCurrencyISOCode);
        this.grossMargin.convert(targetCurrencyISOCode);
        this.grossMarginSeeThrough.convert(targetCurrencyISOCode);
        this.contributionMargin.convert(targetCurrencyISOCode);
        this.contributionMargin.convert(targetCurrencyISOCode);
        this.ebit.convert(targetCurrencyISOCode);
    }
    
    private static PandLData addInSiteRegionCompanyData(PandLData data, Id siteId, Id regionId, Id companyId, Date startDate, Date endDate) {
        Id idToUse = null;
        //Determine the correct Sales Site id to use.
        if(siteId != null) {
            idToUse = siteId;
        } else if(regionId != null) {
            idToUse = regionId;
        } else if(companyId != null) {
            idToUse = companyId;
        }
        
        //If we couldn't find one make everything zero.
        if(idToUse == null) {
            return zeroOutRemaining(data);
        }
        
        //If the user doesnt give a start date, make the start date 1/1/1900 so everything is included.
        if(startDate == null) {
            startDate = Date.newInstance(1900, 1, 1);
        }
        //If the user doesnt give an end date, make the end date 1000 years in the future so everything is included.
        if(endDate == null) {
            endDate = System.today().addYears(1000);
        }
        AggregateResult ar;
        List<AggregateResult> arList = [SELECT AVG(Total_Hrs__c) totalHrsSite, AVG(Total_Hrs_Reg__c) totalHrsReg, AVG(Total_Hrs_Comp__c) totalHrsComp, 
                                     AVG(Miles__c) distanceSite, AVG(Miles_Reg__c) distanceReg, AVG(Miles_Comp__c) distanceComp,
                                     AVG(Pounds__c) unitsSite, AVG(Pounds_Reg__c) unitsReg, AVG(Pounds_Comp__c) unitsComp,
                                     AVG(Invoice__c) invoiceSite, AVG(Invoice_Reg__c) invoiceReg, AVG(Invoice_Comp__c) invoiceComp,
                                     AVG(Rev_Exp__c) siteNr, AVG(Rev_Exp_Reg__c) regionNr, AVG(Rev_Exp_Comp__c) compNr,
                                     AVG(Total_Hrs_Total__c) totalHrsTotal, AVG(Miles_Total__c) milesTotal, AVG(Pounds_Total__c) poundsTotal
                                     FROM PCA__c WHERE Sales_Site__c = :idToUse AND Post_Month__c >= :startDate AND Post_Month__c < :endDate];
        if(arList.size() == 0) {
            return zeroOutRemaining(data);
        } else {
            ar = arList.get(0);
        }
        String currencyIsoCode = UserInfo.getDefaultCurrency();
        
        data.siteTotalHrs = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('totalHrsSite') == null) ? 0.00 : (Decimal) ar.get('totalHrsSite'));
        data.siteDistance = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('distanceSite') == null) ? 0.00 : (Decimal) ar.get('distanceSite'));
        data.siteUnits = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('unitsSite') == null) ? 0.00 : (Decimal) ar.get('unitsSite'));
        data.siteInvoices = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('invoiceSite') == null) ? 0.00 : (Decimal) ar.get('invoiceSite'));
        data.siteNetRev = ((Decimal) ar.get('siteNr') == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, (Decimal) ar.get('siteNr'));
        data.regionTotalHrs = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('totalHrsReg') == null) ? 0.00 : (Decimal) ar.get('totalHrsReg'));
        data.regionDistance = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('distanceReg') == null) ? 0.00 : (Decimal) ar.get('distanceReg'));
        data.regionUnits = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('unitsReg') == null) ? 0.00 : (Decimal) ar.get('unitsReg'));
        data.regionInvoices = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('invoiceReg') == null) ? 0.00 : (Decimal) ar.get('invoiceReg'));
        data.regionNetRev = ((Decimal) ar.get('regionNr') == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, (Decimal) ar.get('regionNr'));
        data.companyTotalHrs = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('totalHrsComp') == null) ? 0.00 : (Decimal) ar.get('totalHrsComp'));
        data.companyDistance = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('distanceComp') == null) ? 0.00 : (Decimal) ar.get('distanceComp'));
        data.companyUnits = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('unitsComp') == null) ? 0.00 : (Decimal) ar.get('unitsComp'));
        data.companyInvoices = new CurrencyData(currencyIsoCode, ((Decimal) ar.get('invoiceComp') == null) ? 0.00 : (Decimal) ar.get('invoiceComp'));
        data.companyNetRev = ((Decimal) ar.get('compNr') == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, (Decimal) ar.get('compNr'));
        
        //Compute totals    
        data.totalHrsTotal = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.regionTotalHrs.value + data.companyTotalHrs.value);
        data.distanceTotal = new CurrencyData(currencyIsoCode, data.siteDistance.value + data.regionDistance.value + data.companyDistance.value);
        data.unitsTotal    = new CurrencyData(currencyIsoCode, data.siteUnits.value + data.regionUnits.value + data.companyUnits.value);
        data.invoicesTotal = new CurrencyData(currencyIsoCode, data.siteInvoices.value + data.regionInvoices.value + data.companyInvoices.value);
        data.netRevTotal   = new CurrencyData(currencyIsoCode, data.siteNetRev.value + data.regionNetRev.value + data.companyNetRev.value);
        
        //Rate on PCA is site level, we want total rate.
        data.rateTotalHrs = (data.totalHours.value == 0 || data.totalHours.value == null || data.totalHrsTotal.value == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, data.totalHrsTotal.value/data.totalHours.value);
        data.rateDistance = (data.distance.value == 0 || data.distance.value == null || data.distanceTotal.value == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, data.distanceTotal.value/data.distance.value);
        data.rateUnits = (data.units.value == 0 || data.units.value == null || data.unitsTotal.value == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, data.unitsTotal.value/data.units.value);
        data.rateInvoices = (data.invoices.value == 0 || data.invoices.value == null || data.invoicesTotal.value == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, data.invoicesTotal.value/data.invoices.value);
        data.rateNetRevenue = (data.netRevenue.value == 0 || data.netRevenue.value == null || data.netRevTotal.value == null) ? new CurrencyData(currencyIsoCode, 0.00) : new CurrencyData(currencyIsoCode, data.netRevTotal.value/data.netRevenue.value);
        
        return data;
    }
    
    public static PandLData createForPandLGenerator2(Date fromDate, Date toDate, Id customerId, boolean customerSoldTo, Id salesSiteId, Id regionId, Id companyId, String industry, String accountMgr, Id rsmId, String WorkingCurrency, List<PandLData> shiptodatas, boolean hideZero) {
        PandLData data = new PandLData();
        data.inGenerator = true;
        String currencyIsoCode = WorkingCurrency;
        data.currencyIsoCode = currencyIsoCode;
        
        if (industry == '--None--')
            industry = null;
        
        // All the salessites we're looking for
        List<Id> salesSiteIds = new List<Id>();
        if (salesSiteId != null) {
            data.SiteId = salesSiteId;
            salesSiteIds.add(salesSiteId);
        }
            
        // All the customers we're looking for
        List<Id> customerIds = new List<Id>();
        if (customerId != null) {
            customerIds.add(customerId);

            // Add sites, but only if there is no site / region / company selected
            if (salesSiteId == null && regionId == null && companyId == null) {
                /*for (Customer_Sales_Site__c cssid : [SELECT Id, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c = :customerId])
                    salesSiteIds.add(cssid.Sales_Site__c);*/
                 for (Sales_Site__c ss: [select Id from Sales_Site__c where Company_Site__c != '' and Region_Site__c != '' and Active__c = true])
                    salesSiteIds.add(ss.Id);  //bring this back after we discuss
            }
            
            // See if account is Sold-To
            if (customerSoldTo) {
                // useCalculatedRates = true;
                // Add Ship-Tos
                for (Account acc1 : [SELECT Id FROM Account WHERE ParentId = :customerId])
                    customerIds.add(acc1.Id);
            }
        }
        
        // After finidng all the search criteria, create the query string
        String query = 'SELECT ' +
                         'c.Material_Item__r.PHL1__c PHL1__c, ' +
                         'c.Sales_Site__c salesSiteId,' +
                         'SUM(c.DELHRS__c) deliveryHours, ' +
                         'SUM(c.SHOTHRS__c) shotHours, ' +
                         'SUM(c.MILES__c) distance, ' +
                         'SUM(c.LBS__c) units, ' +
                         'SUM(c.INVOICES__c) invoices, ' +
                         'SUM(c.Net_Revenue__c) netRevenue, ' +
                         'SUM(c.True_Total_Cogs__c) costOfGoodsSold, ' +
                         'SUM(c.COGS_See_Through__c) costOfGoodsSoldST ' +
                         'FROM COPA__c c';
                         
        query += ' WHERE c.Current_Month__c >= :fromDate AND c.Current_Month__c <= :toDate';
        data.validFrom = fromDate;
        data.validFromDisplay = fromDate.format().split(' ').get(0);
        data.validTo = toDate;
        data.validToDisplay = toDate.format().split(' ').get(0);
        
        if(customerIds.size() > 0) {
            query += ' AND c.Customer__c in :customerIds';
        }
        
        if (salesSiteId != null) {
            query += ' AND c.Sales_Site__c = :salesSiteId';       
        } else if (salesSiteIds.size() > 0) {
            query += ' AND c.Sales_Site__c in :salesSiteIds';
        }

        if (regionId != null) {
            query += ' AND c.Sales_Site__r.Region_Site__c = :regionId';   
        }
        
        if (companyId != null) {
            query += ' AND c.Sales_Site__r.Company_Site__c = :companyId';     
        }
        
        if (industry != null && industry.trim() != '')
            query += ' AND c.Customer__r.Industry = :industry';
        
        if (accountMgr != null && accountMgr.trim() != '')
            query += ' AND c.Customer__r.Account_Manager__c = :accountMgr';
        
        if (rsmId != null)
            query += ' AND c.CreatedBy.RSM__c = :rsmId';
            
        query += ' GROUP BY c.Material_Item__r.PHL1__c, c.Sales_Site__c';
        
        Set<Id> salesSiteMap = new Set<Id>();
        // Query the COPAS
        List<AggregateResult> qas = Database.query(query);
        Map<String, decimal> q = new Map<String, decimal>();
        q.put('deliveryHours', 0);
        q.put('shotHours', 0);
        q.put('distance', 0);
        q.put('units', 0);
        q.put('invoices', 0);
        q.put('netRevenue', 0);
        q.put('costOfGoodsSold', 0);
        q.put('costOfGoodsSoldST', 0);
        for (AggregateResult qa : qas) {
            q.put('deliveryHours', q.get('deliveryHours') + (decimal)qa.get('deliveryHours'));
            q.put('shotHours', q.get('shotHours') + (decimal)qa.get('shotHours'));
            q.put('distance', q.get('distance') + (decimal)qa.get('distance'));
            q.put('units', q.get('units') + (decimal)qa.get('units'));
            q.put('invoices', q.get('invoices') + (decimal)qa.get('invoices'));
            q.put('netRevenue', q.get('netRevenue') + (decimal)qa.get('netRevenue'));
            q.put('costOfGoodsSold', q.get('costOfGoodsSold') + (decimal)qa.get('costOfGoodsSold'));
            q.put('costOfGoodsSoldST', q.get('costOfGoodsSoldST') + (decimal)qa.get('costOfGoodsSoldST'));
            salesSiteMap.add((String)qa.get('salesSiteId'));
        }
        system.debug('Lucian hideZero: ->' + hideZero + '<->' + q.get('netRevenue') + '<-');
        if (hideZero && q.get('netRevenue') == 0) {
            data.netRevenue = new CurrencyData(currencyIsoCode, 0);
            return data;
        }
        
        Account customer = null;
        if (customerId != null) {
            customer = [SELECT Id, Account_Group__c, Name, Name_2__c, SAP_Account_Number__c, ParentId, Parent.Name FROM Account WHERE Id = :customerId LIMIT 1];
            if(customerIds.size() > 0) {
                if(data.customerName == null) {
                    data.customerName = customer.Name;
                    data.customerName2 = customer.Name_2__c;
                    data.sapCustomerNumber = customer.SAP_Account_Number__c;
                    if (customer.ParentId != null) {
                        data.customerParentId = customer.ParentId;
                        data.parentName = customer.Parent.Name;
                    } else {
                        data.customerParentId = '';
                        data.parentName = '';
                    }
                }
            }
        }
        
        
        Sales_Site__c site = null;
        if (salesSiteId != null) {
            site = [Select Name, Delivery_Hours_Rate__c, Shot_Service_Hours_Rate__c, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id = :salesSiteId];
            if (data.siteName == null || data.regionName == null || data.companyName == null) {
                data.companyName = site.Company_Site__r.Name;
                data.regionName = site.Region_Site__r.Name;
                data.siteName = site.Name;
                data.RegionId = site.Region_Site__c;
                data.CompanyId = site.Company_Site__c;                   
            }
        } else if (salesSiteIds.size() > 0) {
            site = [Select Name, Region__c, Delivery_Hours_Rate__c, Shot_Service_Hours_Rate__c, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id = :salesSiteIds[0]];
        }
        
        if (regionId != null) {
            if(data.regionName == null || data.companyName == null) {
                Sales_Site__c reg = [Select Name, Company_Site__r.Name from Sales_Site__c where Id =:regionId];
                data.companyName = reg.Company_Site__r.Name;
                data.regionName = reg.Name; 
                data.CompanyId = reg.Company_Site__c;        
            }           
        }
        
        if (companyId != null) {
            if(data.companyName == null) {
                Sales_Site__c comp = [Select Name from Sales_Site__c where Id =:companyId];
                data.companyName = comp.Name;   
            }               
        }
        
        // Sites for PCA / Cost_Driver_Entry__c
        List<Id> aggSites = new List<Id>();
        if (salesSiteId != null)
            aggSites.add(salesSiteId);
        else if (regionId != null)
            aggSites.add(regionId);
        else if (companyId != null)
            aggSites.add(companyId);
        else
            //aggSites.addAll(salesSiteIds);
            aggSites.addAll(salesSiteMap);

        // Get the regionIds            
        List<Id> regionIds = new List<Id>();
        if (regionId != null)
            regionIds.add(regionId);
        else {
            //for (Sales_Site__c ssc : [SELECT Region_Site__c FROM Sales_Site__c WHERE Id in :salesSiteIds])
            for (Sales_Site__c ssc : [SELECT Region_Site__c FROM Sales_Site__c WHERE Id in :salesSiteMap])
                if (ssc.Region_Site__c != null)
                    regionIds.add(ssc.Region_Site__c);
        }

        // Query the PCAs
        AggregateResult pcas = null;
        try {
            pcas = [SELECT
                      SUM(c.Invoice_Total__c) invoices,
                      SUM(c.Miles_Total__c) miles,
                      SUM(c.Rev_Exp_Total__c) netRevenue,
                      SUM(c.Total_Hrs_Total__c) totalHours,
                      SUM(c.Pounds_Total__c) pounds,
                      SUM(c.MHrs__c) mHrs,
                      SUM(c.Total_Hrs__c) tHrs,
                      // part 2
                      SUM(c.Miles__c) sumMiles,
                      SUM(c.Pounds__c) sumLbs,
                      SUM(c.Invoice__c) sumInv,
                      SUM(c.Rev_Exp__c) sumNr,
                      SUM(c.Total_Hrs_Reg__c) totalHrsReg,
                      SUM(c.Miles_Reg__c) milesReg,
                      SUM(c.Pounds_Reg__c) poundsReg,
                      SUM(c.Invoice_Reg__c) invoicesReg,
                      SUM(c.Rev_Exp_Reg__c) nrReg
                    FROM PCA__c c
                    WHERE c.Post_Month__c >= :fromDate
                      AND c.Post_Month__c <= :toDate
                      AND c.Sales_Site__c in :aggSites];
        } catch (Exception ex) { }
        
        AggregateResult spcas = null;
        try {
            string spcasQ = 'SELECT ' +
                     'SUM(c.Invoice_Total__c) invoices, ' +
                     'SUM(c.Miles_Total__c) miles, ' +
                     'SUM(c.Rev_Exp_Total__c) netRevenue, ' +
                     'SUM(c.Total_Hrs_Total__c) totalHours, ' +
                     'SUM(c.Pounds_Total__c) pounds, ' +
                     'SUM(c.MHrs__c) mHrs, ' +
                     'SUM(c.Total_Hrs__c) tHrs, ' +
                      // part 2
                     'SUM(c.Miles__c) sumMiles, ' +
                     'SUM(c.Pounds__c) sumLbs, ' +
                     'SUM(c.Invoice__c) sumInv, ' +
                     'SUM(c.Rev_Exp__c) sumNr, ' +
                     'SUM(c.Total_Hrs_Reg__c) totalHrsReg, ' +
                     'SUM(c.Miles_Reg__c) milesReg, ' +
                     'SUM(c.Pounds_Reg__c) poundsReg, ' +
                     'SUM(c.Invoice_Reg__c) invoicesReg, ' +
                     'SUM(c.Rev_Exp_Reg__c) nrReg ' +
                    'FROM PCA__c c ' +
                    'WHERE c.Post_Month__c >= :fromDate ' +
                      'AND c.Post_Month__c <= :toDate ';
            if (salesSiteId == null)
                spcasQ += 'AND c.Sales_Site__r.Region_Site__c = :regionid';
            else
                //spcasQ += 'AND c.Sales_Site__c in :salesSiteIds';
                spcasQ += 'AND c.Sales_Site__c in :salesSiteMap';
            spcas = database.query(spcasQ);
        } catch (Exception ex) { }
        
        AggregateResult rpcas = null;
        try {
            rpcas = [SELECT
                      SUM(c.Invoice_Total__c) invoices,
                      SUM(c.Miles_Total__c) miles,
                      SUM(c.Rev_Exp_Total__c) netRevenue,
                      SUM(c.Total_Hrs_Total__c) totalHours,
                      SUM(c.Pounds_Total__c) pounds,
                      SUM(c.MHrs__c) mHrs,
                      SUM(c.Total_Hrs__c) tHrs,
                      // part 2
                      SUM(c.Miles__c) sumMiles,
                      SUM(c.Pounds__c) sumLbs,
                      SUM(c.Invoice__c) sumInv,
                      SUM(c.Rev_Exp__c) sumNr,
                      SUM(c.Total_Hrs_Reg__c) totalHrsReg,
                      SUM(c.Miles_Reg__c) milesReg,
                      SUM(c.Pounds_Reg__c) poundsReg,
                      SUM(c.Invoice_Reg__c) invoicesReg,
                      SUM(c.Rev_Exp_Reg__c) nrReg
                    FROM PCA__c c
                    WHERE c.Post_Month__c >= :fromDate
                      AND c.Post_Month__c <= :toDate
                      AND c.Sales_Site__c in :regionIds];
        } catch (Exception ex) { }
        
        // Query for Cost_Driver_Entry__c (for rates)
        AggregateResult cdes = null;
        try {
            cdes = [SELECT
                      SUM(c.DELHRS__c) delSum,
                      SUM(c.DISTANCE__C) milesSum,
                      SUM(c.SHOTHRS__c) sumShot,
                      SUM(c.INVOICES__c) invSum,
                      SUM(c.REVENUE__C) nrSum,
                      SUM(c.Total_Cogs__c) sumCOGS,
                      SUM(c.UNITS__c) lbsSum
                     FROM Cost_Driver_Entry__c c
                    WHERE c.Current_Month__c >= :fromDate
                      AND c.Current_Month__c <= :toDate
                      AND c.Sales_Site__c in :aggSites];
        } catch (Exception ex) {}
        
        AggregateResult scdes = null;
        try {
            string scdesQ = 'SELECT ' +
                      'SUM(c.DELHRS__c) delSum, ' +
                      'SUM(c.DISTANCE__C) milesSum, ' +
                      'SUM(c.SHOTHRS__c) sumShot, ' +
                      'SUM(c.INVOICES__c) invSum, ' +
                      'SUM(c.REVENUE__C) nrSum, ' +
                      'SUM(c.Total_Cogs__c) sumCOGS, ' +
                      'SUM(c.UNITS__c) lbsSum ' +
                     'FROM Cost_Driver_Entry__c c ' +
                    'WHERE c.Current_Month__c >= :fromDate ' +
                      'AND c.Current_Month__c <= :toDate ';
            if (salesSiteId == null)
                scdesQ += 'AND c.Sales_Site__r.Region_Site__c = :regionId';
            else
                //scdesQ += 'AND c.Sales_Site__c in :salesSiteIds';
                scdesQ += 'AND c.Sales_Site__c in :salesSiteMap';
            scdes = database.query(scdesQ);
        } catch (Exception ex) {}
        
        AggregateResult rcdes = null;
        try {
            rcdes = [SELECT
                      SUM(c.DELHRS__c) delSum,
                      SUM(c.DISTANCE__C) milesSum,
                      SUM(c.SHOTHRS__c) sumShot,
                      SUM(c.INVOICES__c) invSum,
                      SUM(c.REVENUE__C) nrSum,
                      SUM(c.Total_Cogs__c) sumCOGS,
                      SUM(c.UNITS__c) lbsSum
                     FROM Cost_Driver_Entry__c c
                    WHERE c.Current_Month__c >= :fromDate
                      AND c.Current_Month__c <= :toDate
                      AND c.Sales_Site__r.Region_Site__c in :regionIds];
        } catch (Exception ex) {}
        
        System.debug('Lucian rates (scdes):' + scdes);
        System.debug('Lucian rates (rcdes):' + rcdes);
        System.debug('Lucian rates (spcas):' + spcas);
        System.debug('Lucian rates (rpcas):' + rpcas);

        // Chunk 1
        data.deliveryHours = (q.get('deliveryHours') == null)?0:(Decimal)q.get('deliveryHours');
        data.shotHours = (q.get('shotHours') == null)?0:(Decimal)q.get('shotHours');
        data.totalHours = new CurrencyData(' ', data.deliveryHours + data.shotHours);
        data.distance = new CurrencyData(' ', (q.get('distance') == null)?0:(Decimal)q.get('distance'));
        data.units = new CurrencyData(' ', (q.get('units') == null)?0:(Decimal)q.get('units'));
        data.invoices = new CurrencyData(' ', (q.get('invoices') == null)?0:(Decimal)q.get('invoices'));
        data.indirectNetRevenue = new CurrencyData(' ', (q.get('netRevenue') == null)?0:(Decimal)q.get('netRevenue'));

        // Chunk 2
        data.revenueModifier = new CurrencyData(currencyIsoCode, 0);
        data.netRevenue = new CurrencyData(currencyIsoCode, (q.get('netRevenue') == null)?0:(Decimal)q.get('netRevenue'));
        data.costOfGoodsSold = new CurrencyData(currencyIsoCode, (q.get('costOfGoodsSold') == null)?0:(-(Decimal)q.get('costOfGoodsSold')));
        data.costOfGoodsSoldSeeThrough = new CurrencyData(currencyIsoCode, (q.get('costOfGoodsSoldST') == null)?0:-(Decimal)q.get('costOfGoodsSoldST'));
        
        // Chunk 3
        // If we calculate rates, calculate totals here
        data.indirectCostInvoices = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('invoices') == null)?0:(Decimal)pcas.get('invoices'));
        data.indirectCostMiles = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('miles') == null)?0:(Decimal)pcas.get('miles'));
        data.indirectCostNetRevenue = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('netRevenue') == null)?0:(Decimal)pcas.get('netRevenue'));
        data.indirectCostTotalHours = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('totalHours') == null)?0:(Decimal)pcas.get('totalHours'));
        data.indirectCostUnits = new CurrencyData(currencyIsoCode, (pcas == null || pcas.get('pounds') == null)?0:(Decimal)pcas.get('pounds'));
        data.indirectCosts = new CurrencyData(currencyIsoCode, data.indirectCostInvoices.value + data.indirectCostMiles.value + data.indirectCostNetRevenue.value + data.indirectCostTotalHours.value + data.indirectCostUnits.value);

        // Chunk 4
        data.grossMargin = new CurrencyData(currencyIsoCode, data.netRevenue.value - data.costOfGoodsSold.value);
        data.grossMarginPercentage = (data.netRevenue.value == 0)?0:((data.grossMargin.value/data.netRevenue.value)*100).setScale(2);
        data.grossMarginSeeThrough = new CurrencyData(currencyIsoCode, data.netRevenue.value - data.costOfGoodsSoldSeeThrough.value);
        data.grossMarginSeeThroughPercentage = (data.netRevenue.value == 0)?0:((data.grossMarginSeeThrough.value/data.netRevenue.value)*100).setScale(2);
        
        // Chunk 5
        decimal totalsts = 0;
        decimal unitssts = 0;
        if (shipToDatas != null)
            for (PandLData shipToData : shipToDatas) {
                if (shipToData != null) {
                    if (shipToData.totalst != null)
                        totalsts += shipToData.totalst;
                    if (shipToData.unitsst != null)
                        unitssts += shipToData.unitsst;
                }
            }
        
        try {
            data.totalst = (decimal)pcas.get('mHrs') + (decimal)pcas.get('tHrs');
        } catch (Exception ex) {
            data.totalst = 0;
        }
        try {
            data.unitsst = (decimal)cdes.get('delSum') + (decimal)cdes.get('sumShot');
        } catch (Exception ex) {
            data.unitsst = 0;
        }
        
        // Delivery rate
        decimal rVal = 0;
        try {
            if (salesSiteId == null && customerId == null && regionId != null)
                rVal = ((decimal)spcas.get('mHrs') + (decimal)spcas.get('tHrs') + totalsts) / ((decimal)scdes.get('delSum') + (decimal)scdes.get('sumShot') + unitssts);
            else
                rVal = ((decimal)pcas.get('mHrs') + (decimal)pcas.get('tHrs') + totalsts) / ((decimal)cdes.get('delSum') + (decimal)cdes.get('sumShot') + unitssts);
        } catch (Exception ex) {}
        if (rVal < 40)
            rVal = 40;
        data.deliveryHoursRate = new CurrencyData(currencyIsoCode, rVal);
        
        // Shot rate
        rVal = 0;
        try {
            if (salesSiteId == null && customerId == null && regionId != null)
                rVal = ((decimal)spcas.get('mHrs') + (decimal)spcas.get('tHrs') + totalsts) / ((decimal)scdes.get('delSum') + (decimal)scdes.get('sumShot') + unitssts);
            else
                rVal = ((decimal)pcas.get('mHrs') + (decimal)pcas.get('tHrs') + totalsts) / ((decimal)cdes.get('delSum') + (decimal)cdes.get('sumShot') + unitssts);
        } catch (Exception ex) {}
        if (rVal < 40)
            rVal = 40;
        data.shotHoursRate = new CurrencyData(currencyIsoCode, rVal);
        
        // Total Hours rate
        data.totalHoursRate = new CurrencyData(currencyIsoCode, 0);
        
        // Now, calculate totals
        data.directCostShotHrs = new CurrencyData(currencyIsoCode, data.shotHours * data.shotHoursRate.value);
        data.directCostDeliveryHrs = new CurrencyData(currencyIsoCode, data.deliveryHours * data.deliveryHoursRate.value);

        data.directCosts = new CurrencyData(currencyIsoCode, data.directCostShotHrs.value + data.directCostDeliveryHrs.value);
        data.contributionMargin = new CurrencyData(currencyIsoCode, data.grossMargin.value - data.directCosts.value);
        data.contributionMarginPercentage = (data.netRevenue.value == 0)?0:((data.contributionMargin.value/data.netRevenue.value)*100).setScale(2);

        // Materials        
        data.productGmData = new ProductGMData(qas, currencyIsoCode);

        // Chunk 6

        // data.totalHoursRate is calculated
        data.siteTotalHrs = new CurrencyData(currencyIsoCode, data.totalHoursRate.value * data.totalHours.value);
        if (rcdes != null && rpcas != null && rpcas.get('tHrs') != null && rpcas.get('mHrs') != null && rcdes.get('delSum') != null && rcdes.get('sumShot') != null && ((decimal)rcdes.get('delSum') + (decimal)rcdes.get('sumShot') != 0)) 
            data.rateTotalHrs = new CurrencyData(currencyIsoCode, ((decimal)rpcas.get('tHrs') + (decimal)rpcas.get('mHrs')) / ((decimal)rcdes.get('delSum') + (decimal)rcdes.get('sumShot')));
        else
            data.rateTotalHrs = new CurrencyData(currencyIsoCode, 0);
        data.regionTotalHrs = new CurrencyData(currencyIsoCode, data.rateTotalHrs.value * data.totalHours.value);

        if (scdes != null && spcas != null && spcas.get('sumMiles') != null && scdes.get('milesSum') != null && (decimal)scdes.get('milesSum') != 0)
            data.distanceRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumMiles') / (decimal)scdes.get('milesSum'));
        else
            data.distanceRate = new CurrencyData(currencyIsoCode, 0);
        data.siteDistance = new CurrencyData(currencyIsoCode, data.distanceRate.value * data.distance.value);
        if (rcdes != null && rpcas != null && rpcas.get('sumMiles') != null && rcdes.get('milesSum') != null && (decimal)rcdes.get('milesSum') != 0)
            data.rateDistance = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumMiles') / (decimal)rcdes.get('milesSum'));
        else
            data.rateDistance = new CurrencyData(currencyIsoCode, 0);
        data.regionDistance = new CurrencyData(currencyIsoCode, data.rateDistance.value * data.distance.value);
    
        if (scdes != null && spcas != null && spcas.get('sumLbs') != null && scdes.get('lbsSum') != null && (decimal)scdes.get('lbsSum') != 0)
            data.unitsRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumLbs') / (decimal)scdes.get('lbsSum'));
        else
            data.unitsRate = new CurrencyData(currencyIsoCode, 0);
        data.siteUnits = new CurrencyData(currencyIsoCode, data.unitsRate.value * data.units.value);
        if (rcdes != null && rpcas != null && rpcas.get('sumLbs') != null && rcdes.get('lbsSum') != null && (decimal)rcdes.get('lbsSum') != 0)
            data.rateUnits = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumLbs') / (decimal)rcdes.get('lbsSum'));
        else
            data.rateUnits = new CurrencyData(currencyIsoCode, 0);
        data.regionUnits = new CurrencyData(currencyIsoCode, data.rateUnits.value * data.units.value);
    
        if (scdes != null && spcas != null && spcas.get('sumInv') != null && scdes.get('invSum') != null && (decimal)scdes.get('invSum') != 0)
            data.invoicesRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumInv') / (decimal)scdes.get('invSum'));
        else
            data.invoicesRate = new CurrencyData(currencyIsoCode, 0);
        data.siteInvoices = new CurrencyData(currencyIsoCode, data.invoicesRate.value * data.invoices.value);
        if (rcdes != null && rpcas != null && rpcas.get('sumInv') != null && rcdes.get('invSum') != null && (decimal)rcdes.get('invSum') != 0)
            data.rateInvoices = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumInv') / (decimal)rcdes.get('invSum'));
        else
            data.rateInvoices = new CurrencyData(currencyIsoCode, 0);
        data.regionInvoices = new CurrencyData(currencyIsoCode, data.rateInvoices.value * data.invoices.value);
    
        if (scdes != null && spcas != null && spcas.get('sumNr') != null && scdes.get('nrSum') != null && (decimal)scdes.get('nrSum') != 0)
            data.netRevenueRate = new CurrencyData(currencyIsoCode, (decimal)spcas.get('sumNr') / (decimal)scdes.get('nrSum'));
        else
            data.netRevenueRate = new CurrencyData(currencyIsoCode, 0);
        data.siteNetRev = new CurrencyData(currencyIsoCode, data.netRevenueRate.value * data.indirectNetRevenue.value);
        if (rcdes != null && rpcas != null && rpcas.get('sumNr') != null && rcdes.get('nrSum') != null && (decimal)rcdes.get('nrSum') != 0)
            data.rateNetRevenue = new CurrencyData(currencyIsoCode, (decimal)rpcas.get('sumNr') / (decimal)rcdes.get('nrSum'));
        else
            data.rateNetRevenue = new CurrencyData(currencyIsoCode, 0);
        data.regionNetRev = new CurrencyData(currencyIsoCode, data.rateNetRevenue.value * data.indirectNetRevenue.value);

        // Chunk 7      
        data.totalHrsTotal = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.regionTotalHrs.value);
        data.distanceTotal = new CurrencyData(currencyIsoCode, data.siteDistance.value + data.regionDistance.value);
        data.unitsTotal    = new CurrencyData(currencyIsoCode, data.siteUnits.value + data.regionUnits.value);
        data.invoicesTotal = new CurrencyData(currencyIsoCode, data.siteInvoices.value + data.regionInvoices.value);
        data.netRevTotal   = new CurrencyData(currencyIsoCode, data.siteNetRev.value + data.regionNetRev.value);
        
        data.total1 = new CurrencyData(currencyIsoCode, data.totalHours.value + data.distance.value + data.units.value + data.invoices.value + data.netRevenue.value);
        data.total2 = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
        data.total3 = new CurrencyData(currencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
        data.total4 = new CurrencyData(currencyIsoCode, 0);//data.companyTotalHrs.value + data.companyDistance.value + data.companyUnits.value + data.companyInvoices.value + data.companyNetRev.value);
        data.total5 = new CurrencyData(currencyIsoCode, data.totalHrsTotal.value + data.distanceTotal.value + data.unitsTotal.value + data.invoicesTotal.value + data.netRevTotal.value);
                                   
        data.ebit = new CurrencyData(currencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;
        data.ebitWith = new CurrencyData(currencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
        data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;

        data.ConvertToCurrency(WorkingCurrency);
        
        System.debug('Lucian data:' + data);

        return data;
    }
    
    /*public static PandLData createForPandLGenerator(Date fromDate, Date toDate, Id customerId, Id salesSiteId, Id regionId, Id companyId, String industry, String accountMgr, Id rsmId, String WorkingCurrency) {
        PandLData data = new PandLData();
        data.inGenerator = true;
        String currencyIsoCode = WorkingCurrency;//UserInfo.getDefaultCurrency();
        data.currencyIsoCode = currencyIsoCode;
        String query = 'Select SUM(q.Net_Revenue_Modifier__c) revenueModifier, SUM(q.EBIT_F_Percent__c) ebitp, SUM(q.EBIT_F__c) ebit, SUM(q.CM_Percent__c) cmp, SUM(q.CM__c) cm, SUM(q.GM__c) gm, SUM(q.GM_Percentage__c) gmp, ' +
                       'SUM(q.GM_See_Through__c) gmst, SUM(q.GM_See_Through_Percent__c) gmstp, SUM(q.Site_Cost_Driver_Rate_Mhrs__c) siteMhrsRate, SUM(q.Site_Cost_Driver_Rate_Total_Hrs__c) siteTotalRate, ' +
                       'SUM(q.Quote_Amount__c) totalAmount, SUM(q.Total_Quantity__c) numUnits, SUM(q.Total_Round_Trip_Truck_Distance__c) numDist, ' +
                       'SUM(q.Total_Shot_Service_Load_Assistance_Hours__c) numSSHrs, SUM(q.Total_Number_of_Invoices__c) numInv, SUM(q.Total_Delivery_Hours__c) numDHrs, ' +
                       'SUM(q.Indirect_Cost_Units__c) totalIDCUnits, SUM(q.Indirect_Cost_Total_Hrs__c) totalIDCHours, SUM(q.Indirect_Cost_Net_Revenue__c) totalIDCNetRev, SUM(q.Indirect_Cost_Invoices__c) totalIDCInvoices, ' +
                       'SUM(q.Indirect_Cost_Distance__c) totalIDCDistance,  SUM(q.Direct_Cost_Delivery_Hrs__c) totalDCDelHrs,  SUM(q.Direct_Cost_Shot_Hrs__c) totalDCShotHrs, SUM(q.Cost_Total_Indirect__c) totalIDC, ' +
                       'SUM(q.Cost_Total_Direct__c) totalDC, SUM(q.COGS__c) cogs, SUM(q.COGS_See_Through__c) cogsST From Quote__c q';
        
        String whereClause = ' WHERE';
        if(fromDate != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            whereClause += ' q.Price_Valid_From__c >= :fromDate';
            data.validFrom = fromDate;
            data.validFromDisplay = fromDate.format().split(' ').get(0);
        }    
        if(toDate != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            whereClause += ' q.Price_Valid_To__c <= :toDate';
            data.validTo = toDate;
            data.validToDisplay =   toDate.format().split(' ').get(0);
        } 
        if(customerId != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            if(data.customerName == null) {
                Account customer = [Select Name, SAP_Account_Number__c, ParentId, Parent.Name from Account where Id =:customerId];
                data.customerName = customer.Name;
                data.sapCustomerNumber = customer.SAP_Account_Number__c;
                if (customer.ParentId != null) {
                    data.customerParentId = customer.ParentId;
                    data.parentName = customer.Parent.Name;
                } else {
                    data.customerParentId = '';
                    data.parentName = '';
                }
            }
            whereClause += ' q.Customer__c = :customerId';
        }
        if(salesSiteId != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            if(data.siteName == null || data.regionName == null || data.companyName == null) {
                Sales_Site__c site = [Select Name, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id =:salesSiteId];
                data.companyName = site.Company_Site__r.Name;
                data.regionName =site.Region_Site__r.Name;
                data.siteName = site.Name;
                data.RegionId = site.Region_Site__c;
                data.CompanyId = site.Company_Site__c;                   
            }
            whereClause += ' q.Sales_Organization_Primary__c = :salesSiteId';       
        }
        if(regionId != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            if(data.regionName == null || data.companyName == null) {
                Sales_Site__c reg = [Select Name, Company_Site__r.Name from Sales_Site__c where Id =:regionId];
                data.companyName = reg.Company_Site__r.Name;
                data.regionName = reg.Name; 
                data.CompanyId = reg.Company_Site__c;        
            }           
            whereClause += ' q.Sales_Organization_Primary__r.Region_Site__c = :regionId';   
        }
        if(companyId != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            if(data.companyName == null) {
                Sales_Site__c comp = [Select Name from Sales_Site__c where Id =:companyId];
                data.companyName = comp.Name;   
            }               
            whereClause += ' q.Sales_Organization_Primary__r.Company_Site__c = :companyId';     
        }
        if(industry != null && industry.trim() != '') {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            whereClause += ' q.Customer__r.Industry = :industry';
        }
        if(accountMgr != null && accountMgr.trim() != '') {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }
            whereClause += ' q.Customer__r.Account_Manager__c = :accountMgr';
        }
        if(rsmId != null) {
            if(whereClause.length() > 6) {
                whereClause += ' AND';
            }   
            whereClause += ' q.CreatedBy.RSM__c = :rsmId';      
        }
        
        String finalQuery = whereClause.length() > 6 ? query + whereClause : query;
        AggregateResult q = Database.query(finalQuery);
        data.deliveryHours = ((Decimal)q.get('numDHrs')==null)?0:(Decimal)q.get('numDHrs');
        data.shotHours = ((Decimal)q.get('numSSHrs')==null)?0:(Decimal)q.get('numSSHrs');
        data.totalHours = new CurrencyData(' ', data.deliveryHours + data.shotHours);
        data.distance = new CurrencyData(' ', ((Decimal)q.get('numDist')==null)?0:(Decimal)q.get('numDist'));
        data.units =    new CurrencyData(' ', ((Decimal)q.get('numUnits')==null)?0:(Decimal)q.get('numUnits'));
        data.invoices = new CurrencyData(' ', ((Decimal)q.get('numInv')==null)?0:(Decimal)q.get('numInv'));
        
        data.revenueModifier = new CurrencyData(currencyIsoCode, (Decimal)q.get('revenueModifier'));
        data.netRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalAmount')==null)?0+data.revenueModifier.value:((Decimal)q.get('totalAmount'))+data.revenueModifier.value);
        data.costOfGoodsSold = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cogs')==null)?0:(Decimal)q.get('cogs'));
        data.costOfGoodsSoldSeeThrough = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cogsST')==null)?0:(Decimal)q.get('cogsST'));
        data.directCosts = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDC')==null)?0:(Decimal)q.get('totalDC'));
        data.indirectCosts = new CurrencyData(currencyIsoCode,((Decimal)q.get('totalIDC')==null)?0:(Decimal)q.get('totalIDC'));
        data.directCostDeliveryHrs = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDCDelHrs')==null)?0:(Decimal)q.get('totalDCDelHrs'));
        data.directCostShotHrs = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDCShotHrs')==null)?0:(Decimal)q.get('totalDCShotHrs'));
        data.indirectCostInvoices = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCInvoices')==null)?0:(Decimal)q.get('totalIDCInvoices'));
        data.indirectCostMiles = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCDistance')==null)?0:(Decimal)q.get('totalIDCDistance'));
        data.indirectCostNetRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCNetRev')==null)?0:(Decimal)q.get('totalIDCNetRev'));
        data.indirectCostTotalHours = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCHours')==null)?0:(Decimal)q.get('totalIDCHours'));
        data.indirectCostUnits = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCUnits')==null)?0:(Decimal)q.get('totalIDCUnits'));  
        
        data.grossMargin = new CurrencyData(currencyIsoCode, data.netRevenue.value - data.costOfGoodsSold.value);
        data.grossMarginPercentage = (data.netRevenue.value == 0)?0:((data.grossMargin.value/data.netRevenue.value)*100).setScale(2);
        data.grossMarginSeeThrough = new CurrencyData(currencyIsoCode, data.netRevenue.value - data.costOfGoodsSoldSeeThrough.value);
        data.grossMarginSeeThroughPercentage = (data.netRevenue.value == 0)?0:((data.grossMarginSeeThrough.value/data.netRevenue.value)*100).setScale(2);
        data.contributionMargin = new CurrencyData(currencyIsoCode, data.grossMargin.value - data.directCosts.value);
        data.contributionMarginPercentage = (data.netRevenue.value == 0)?0:((data.contributionMargin.value/data.netRevenue.value)*100).setScale(2);
        
        data.deliveryHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteMhrsRate') ==null)?0:(Decimal)q.get('siteMhrsRate'));
        data.totalHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteTotalRate') ==null)?0:(Decimal)q.get('siteTotalRate'));
        data.shotHoursRate = new CurrencyData(currencyIsoCode, data.totalHoursRate.value - data.deliveryHoursRate.value);   
        if(whereClause.length() > 6) {
            data.productGmData = new ProductGMData(aggregateRevenueAndCostByPHL1((List<Quote__c>) Database.query('SELECT q.Id FROM Quote__c q' + whereClause)), currencyIsoCode);
        } else {
            data.productGmData = new ProductGMData(aggregateRevenueAndCostByPHL1((List<Quote__c>) Database.query('SELECT q.Id FROM Quote__c q')), currencyIsoCode);
        }   
        data = addInSiteRegionCompanyData(data, salesSiteId, regionId, companyId, fromDate, toDate);
        data.total1 = new CurrencyData(currencyIsoCode, data.totalHours.value + data.distance.value + data.units.value + data.invoices.value + data.netRevenue.value);
        data.total2 = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
        data.total3 = new CurrencyData(currencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
        data.total4 = new CurrencyData(currencyIsoCode, data.companyTotalHrs.value + data.companyDistance.value + data.companyUnits.value + data.companyInvoices.value + data.companyNetRev.value);
        data.total5 = new CurrencyData(currencyIsoCode, data.totalHrsTotal.value + data.distanceTotal.value + data.unitsTotal.value + data.invoicesTotal.value + data.netRevTotal.value);                           
        data.ebit = new CurrencyData(currencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;
        data.ebitWith = new CurrencyData(currencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
        data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;
        
        data.ConvertToCurrency(WorkingCurrency);
                                     
        return data;
    }*/
    
    /* USED BY RATIO ANALYSIS AND SUGGESTED ACTIONS */
    public static PandLData createForCustomerSalesSite(Id customerId, Id salesSiteId, Date fromDate, Date toDate) {
        AggregateResult q = [Select SUM(q.Net_Revenue_Modifier__c) revenueModifier, SUM(q.EBIT_F_Percent__c) ebitp, SUM(q.EBIT_F__c) ebit, SUM(q.CM_Percent__c) cmp, SUM(q.CM__c) cm, SUM(q.GM__c) gm, SUM(q.GM_Percentage__c) gmp, SUM(q.GM_See_Through__c) gmst, SUM(q.GM_See_Through_Percent__c) gmstp, AVG(q.Site_Cost_Driver_Rate_Mhrs__c) siteMhrsRate, AVG(q.Site_Cost_Driver_Rate_Total_Hrs__c) siteTotalRate, SUM(q.Quote_Amount__c) totalAmount, SUM(q.Total_Quantity__c) numUnits, SUM(q.Total_Round_Trip_Truck_Distance__c) numDist, SUM(q.Total_Shot_Service_Load_Assistance_Hours__c) numSSHrs, SUM(q.Total_Number_of_Invoices__c) numInv, SUM(q.Total_Delivery_Hours__c) numDHrs, SUM(q.Indirect_Cost_Units__c) totalIDCUnits, SUM(q.Indirect_Cost_Total_Hrs__c) totalIDCHours, SUM(q.Indirect_Cost_Net_Revenue__c) totalIDCNetRev, SUM(q.Indirect_Cost_Invoices__c) totalIDCInvoices, SUM(q.Indirect_Cost_Distance__c) totalIDCDistance,  SUM(q.Direct_Cost_Delivery_Hrs__c) totalDCDelHrs,  SUM(q.Direct_Cost_Shot_Hrs__c) totalDCShotHrs, SUM(q.Cost_Total_Indirect__c) totalIDC, SUM(q.Cost_Total_Direct__c) totalDC, SUM(q.COGS__c) cogs, SUM(q.COGS_See_Through__c) cogsST From Quote__c q Where q.Customer__c=:customerId and Sales_Organization_Primary__c=:salesSiteId and q.Price_Valid_To__c >=:fromDate AND q.Price_Valid_From__c <=:toDate];
        String currencyIsoCode = UserInfo.getDefaultCurrency();
        Sales_Site__c site = [Select Name, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id =:salesSiteId];
        Account customer = [Select Name, SAP_Account_Number__c from Account where Id =:customerId];
        PandLData data = new PandLData();
        data.customerName = customer.Name;
        data.companyName = site.Company_Site__r.Name;
        data.regionName =site.Region_Site__r.Name;
        data.siteName = site.Name;      
        data.sapCustomerNumber = customer.SAP_Account_Number__c;
        data.currencyIsoCode = currencyIsoCode;
        data.validFrom = fromDate;
        data.validTo = toDate;
        data.validFromDisplay = fromDate.format().split(' ').get(0);
        data.validToDisplay =   toDate.format().split(' ').get(0);

        data.deliveryHours = ((Decimal)q.get('numDHrs')==null)?0:(Decimal)q.get('numDHrs');
        data.shotHours = ((Decimal)q.get('numSSHrs')==null)?0:(Decimal)q.get('numSSHrs');
        data.totalHours = new CurrencyData(' ', data.deliveryHours + data.shotHours);
        data.distance = new CurrencyData(' ', ((Decimal)q.get('numDist')==null)?0:(Decimal)q.get('numDist'));
        data.units =    new CurrencyData(' ', ((Decimal)q.get('numUnits')==null)?0:(Decimal)q.get('numUnits'));
        data.invoices = new CurrencyData(' ', ((Decimal)q.get('numInv')==null)?0:(Decimal)q.get('numInv'));
        
        data.revenueModifier = new CurrencyData(currencyIsoCode, (Decimal)q.get('revenueModifier'));
        data.netRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalAmount')==null)?0+data.revenueModifier.value:((Decimal)q.get('totalAmount'))+data.revenueModifier.value);
        data.costOfGoodsSold = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cogs')==null)?0:(Decimal)q.get('cogs'));
        data.costOfGoodsSoldSeeThrough = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cogsST')==null)?0:(Decimal)q.get('cogsST'));
        data.directCosts = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDC')==null)?0:(Decimal)q.get('totalDC'));
        data.indirectCosts = new CurrencyData(currencyIsoCode,((Decimal)q.get('totalIDC')==null)?0:(Decimal)q.get('totalIDC'));
        data.directCostDeliveryHrs = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDCDelHrs')==null)?0:(Decimal)q.get('totalDCDelHrs'));
        data.directCostShotHrs = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDCShotHrs')==null)?0:(Decimal)q.get('totalDCShotHrs'));
        data.indirectCostInvoices = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCInvoices')==null)?0:(Decimal)q.get('totalIDCInvoices'));
        data.indirectCostMiles = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCDistance')==null)?0:(Decimal)q.get('totalIDCDistance'));
        data.indirectCostNetRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCNetRev')==null)?0:(Decimal)q.get('totalIDCNetRev'));
        data.indirectCostTotalHours = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCHours')==null)?0:(Decimal)q.get('totalIDCHours'));
        data.indirectCostUnits = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCUnits')==null)?0:(Decimal)q.get('totalIDCUnits'));

        data.grossMargin = new CurrencyData(currencyIsoCode, ((Decimal)q.get('gm')==null)?0:(Decimal)q.get('gm'));
        data.grossMarginPercentage = ((Decimal)q.get('gmp')==null)?0:(Decimal)q.get('gmp');
        data.grossMarginSeeThrough = new CurrencyData(currencyIsoCode, ((Decimal)q.get('gmst')==null)?0:(Decimal)q.get('gmst'));
        data.grossMarginSeeThroughPercentage = ((Decimal)q.get('gmstp')==null)?0:(Decimal)q.get('gmstp');
        data.contributionMargin = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cm')==null)?0:(Decimal)q.get('cm'));
        data.contributionMarginPercentage = ((Decimal)q.get('cmp')==null)?0:(Decimal)q.get('cmp');
        
        data.deliveryHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteMhrsRate') ==null)?0:(Decimal)q.get('siteMhrsRate'));
        data.totalHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteTotalRate') ==null)?0:(Decimal)q.get('siteTotalRate'));
        data.shotHoursRate = new CurrencyData(currencyIsoCode, data.totalHoursRate.value - data.deliveryHoursRate.value);
            
        data.productGmData = new ProductGMData(aggregateRevenueAndCostByPHL1([Select q.Id from Quote__c q Where q.Sales_Organization_Primary__c = :salesSiteId and q.Customer__c=:customerId and q.Price_Valid_To__c >=:fromDate AND q.Price_Valid_From__c <=:toDate]), currencyIsoCode);
        data = addInSiteRegionCompanyData(data, site.Id, site.Region_Site__c, site.Company_Site__c, fromDate, toDate);
        data.total1 = new CurrencyData(currencyIsoCode, data.totalHours.value + data.distance.value + data.units.value + data.invoices.value + data.netRevenue.value);
        data.total2 = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
        data.total3 = new CurrencyData(currencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
        data.total4 = new CurrencyData(currencyIsoCode, data.companyTotalHrs.value + data.companyDistance.value + data.companyUnits.value + data.companyInvoices.value + data.companyNetRev.value);
        data.total5 = new CurrencyData(currencyIsoCode, data.totalHrsTotal.value + data.distanceTotal.value + data.unitsTotal.value + data.invoicesTotal.value + data.netRevTotal.value);
        data.ebit = new CurrencyData(currencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;     
        data.ebitWith = new CurrencyData(currencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
        data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;             
        return data;            
    }
    
    public static PandLData createForCustomer(Id customerId, Date fromDate, Date toDate) {
        AggregateResult q = [Select SUM(q.Net_Revenue_Modifier__c) revenueModifier, SUM(q.EBIT_F_Percent__c) ebitp, SUM(q.EBIT_F__c) ebit, SUM(q.CM_Percent__c) cmp, SUM(q.CM__c) cm, SUM(q.GM__c) gm, SUM(q.GM_Percentage__c) gmp, SUM(q.GM_See_Through__c) gmst, SUM(q.GM_See_Through_Percent__c) gmstp, SUM(q.Total_Quantity__c) numUnits, SUM(q.Total_Round_Trip_Truck_Distance__c) numDist, SUM(q.Total_Shot_Service_Load_Assistance_Hours__c) numSSHrs, SUM(q.Total_Number_of_Invoices__c) numInv, SUM(q.Total_Delivery_Hours__c) numDHrs, AVG(q.Site_Cost_Driver_Rate_Mhrs__c) siteMhrsRate, AVG(q.Site_Cost_Driver_Rate_Total_Hrs__c) siteTotalRate, SUM(q.Quote_Amount__c) totalAmount, SUM(q.Indirect_Cost_Units__c) totalIDCUnits, SUM(q.Indirect_Cost_Total_Hrs__c) totalIDCHours, SUM(q.Indirect_Cost_Net_Revenue__c) totalIDCNetRev, SUM(q.Indirect_Cost_Invoices__c) totalIDCInvoices, SUM(q.Indirect_Cost_Distance__c) totalIDCDistance,  SUM(q.Direct_Cost_Delivery_Hrs__c) totalDCDelHrs,  SUM(q.Direct_Cost_Shot_Hrs__c) totalDCShotHrs, SUM(q.Cost_Total_Indirect__c) totalIDC, SUM(q.Cost_Total_Direct__c) totalDC, SUM(q.COGS__c) cogs, SUM(q.COGS_See_Through__c) cogsST From Quote__c q Where q.Customer__c=:customerId and q.Price_Valid_To__c >=:fromDate AND q.Price_Valid_From__c <=:toDate];
        String currencyIsoCode = UserInfo.getDefaultCurrency();
        
        Account customer = [Select Name, SAP_Account_Number__c from Account where Id =:customerId];
        PandLData data = new PandLData();
        data.companyName = customer.Name;
        data.customerName = customer.Name;
        data.sapCustomerNumber = customer.SAP_Account_Number__c;
        data.currencyIsoCode = currencyIsoCode;
        data.validFrom = fromDate;
        data.validTo = toDate;
        data.validFromDisplay = fromDate.format().split(' ').get(0);
        data.validToDisplay =   toDate.format().split(' ').get(0);
        data.deliveryHours = ((Decimal)q.get('numDHrs')==null)?0:(Decimal)q.get('numDHrs');
        data.shotHours = ((Decimal)q.get('numSSHrs')==null)?0:(Decimal)q.get('numSSHrs');
        data.totalHours = new CurrencyData(' ', data.deliveryHours + data.shotHours);
        data.distance = new CurrencyData(' ', ((Decimal)q.get('numDist')==null)?0:(Decimal)q.get('numDist'));
        data.units =    new CurrencyData(' ', ((Decimal)q.get('numUnits')==null)?0:(Decimal)q.get('numUnits'));
        data.invoices = new CurrencyData(' ', ((Decimal)q.get('numInv')==null)?0:(Decimal)q.get('numInv'));     
        data.revenueModifier = new CurrencyData(currencyIsoCode, (Decimal)q.get('revenueModifier'));
        data.netRevenue = new CurrencyData(currencyIsoCode, 0);
        if (q.get('totalAmount') != null)
            data.netRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalAmount'))+data.revenueModifier.value);
        data.costOfGoodsSold = new CurrencyData(currencyIsoCode, (Decimal)q.get('cogs'));
        data.costOfGoodsSoldSeeThrough = new CurrencyData(currencyIsoCode, (Decimal)q.get('cogsST'));
        data.directCosts = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalDC'));
        data.indirectCosts = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalIDC'));
        data.directCostDeliveryHrs = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalDCDelHrs'));
        data.directCostShotHrs = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalDCShotHrs'));
        data.indirectCostInvoices = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalIDCInvoices'));
        data.indirectCostMiles = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalIDCDistance'));
        data.indirectCostNetRevenue = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalIDCNetRev'));
        data.indirectCostTotalHours = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalIDCHours'));
        data.indirectCostUnits = new CurrencyData(currencyIsoCode, (Decimal)q.get('totalIDCUnits'));
        data.grossMargin = new CurrencyData(currencyIsoCode, ((Decimal)q.get('gm')==null)?0:(Decimal)q.get('gm'));
        data.grossMarginPercentage = ((Decimal)q.get('gmp')==null)?0:(Decimal)q.get('gmp');
        data.grossMarginSeeThrough = new CurrencyData(currencyIsoCode, ((Decimal)q.get('gmst')==null)?0:(Decimal)q.get('gmst'));
        data.grossMarginSeeThroughPercentage = ((Decimal)q.get('gmstp')==null)?0:(Decimal)q.get('gmstp');
        data.contributionMargin = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cm')==null)?0:(Decimal)q.get('cm'));
        data.contributionMarginPercentage = ((Decimal)q.get('cmp')==null)?0:(Decimal)q.get('cmp');
        data.deliveryHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteMhrsRate') ==null)?0:(Decimal)q.get('siteMhrsRate'));
        data.totalHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteTotalRate') ==null)?0:(Decimal)q.get('siteTotalRate'));
        data.shotHoursRate = new CurrencyData(currencyIsoCode, data.totalHoursRate.value - data.deliveryHoursRate.value);
                
        data.productGmData = new ProductGMData(aggregateRevenueAndCostByPHL1([Select q.Id from Quote__c q Where q.Customer__c=:customerId and q.Price_Valid_To__c >=:fromDate AND q.Price_Valid_From__c <=:toDate]), currencyIsoCode);      
        data = addInSiteRegionCompanyData(data, null, null, null, fromDate, toDate);
        data.total1 = new CurrencyData(currencyIsoCode, data.totalHours.value + data.distance.value + data.units.value + data.invoices.value + data.netRevenue.value);
        data.total2 = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
        data.total3 = new CurrencyData(currencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
        data.total4 = new CurrencyData(currencyIsoCode, data.companyTotalHrs.value + data.companyDistance.value + data.companyUnits.value + data.companyInvoices.value + data.companyNetRev.value);
        data.total5 = new CurrencyData(currencyIsoCode, data.totalHrsTotal.value + data.distanceTotal.value + data.unitsTotal.value + data.invoicesTotal.value + data.netRevTotal.value);
        data.ebit = new CurrencyData(currencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;     
        data.ebitWith = new CurrencyData(currencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
        data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;             
        return data;
    }
    
    public static PandLData createForSite(Id siteId, Date fromDate, Date toDate) {
        AggregateResult q = [Select SUM(q.Net_Revenue_Modifier__c) revenueModifier, SUM(q.EBIT_F_Percent__c) ebitp, SUM(q.EBIT_F__c) ebit, SUM(q.CM_Percent__c) cmp, SUM(q.CM__c) cm, SUM(q.GM__c) gm, SUM(q.GM_Percentage__c) gmp, SUM(q.GM_See_Through__c) gmst, SUM(q.GM_See_Through_Percent__c) gmstp, AVG(q.Site_Cost_Driver_Rate_Mhrs__c) siteMhrsRate, AVG(q.Site_Cost_Driver_Rate_Total_Hrs__c) siteTotalRate, SUM(q.Quote_Amount__c) totalAmount, SUM(q.Total_Quantity__c) numUnits, SUM(q.Total_Round_Trip_Truck_Distance__c) numDist, SUM(q.Total_Shot_Service_Load_Assistance_Hours__c) numSSHrs, SUM(q.Total_Number_of_Invoices__c) numInv, SUM(q.Total_Delivery_Hours__c) numDHrs, SUM(q.Indirect_Cost_Units__c) totalIDCUnits, SUM(q.Indirect_Cost_Total_Hrs__c) totalIDCHours, SUM(q.Indirect_Cost_Net_Revenue__c) totalIDCNetRev, SUM(q.Indirect_Cost_Invoices__c) totalIDCInvoices, SUM(q.Indirect_Cost_Distance__c) totalIDCDistance,  SUM(q.Direct_Cost_Delivery_Hrs__c) totalDCDelHrs,  SUM(q.Direct_Cost_Shot_Hrs__c) totalDCShotHrs, SUM(q.Cost_Total_Indirect__c) totalIDC, SUM(q.Cost_Total_Direct__c) totalDC, SUM(q.COGS__c) cogs, SUM(q.COGS_See_Through__c) cogsST From Quote__c q Where q.Sales_Organization_Primary__c=:siteId and q.Price_Valid_To__c >=:fromDate AND q.Price_Valid_From__c <=:toDate];
        
        String currencyIsoCode = UserInfo.getDefaultCurrency();
        
        Sales_Site__c site = [Select Name, Company_Site__c, Region_Site__c, Company_Site__r.Name, Region_Site__r.Name from Sales_Site__c where Id =:siteId];
        PandLData data = new PandLData();
        data.companyName = site.Company_Site__r.Name;
        data.regionName = site.Region_Site__r.Name;
        data.siteName = site.Name;
        data.currencyIsoCode = currencyIsoCode;
        data.validFrom = fromDate;
        data.validTo = toDate;
        
        data.validFromDisplay = fromDate.format().split(' ').get(0);
        data.validToDisplay =   toDate.format().split(' ').get(0);
        data.deliveryHours = ((Decimal)q.get('numDHrs') == null)?0:(Decimal)q.get('numDHrs');
        data.shotHours = ((Decimal)q.get('numSSHrs') == null)?0:(Decimal)q.get('numSSHrs');
        data.totalHours = new CurrencyData(' ', data.deliveryHours + data.shotHours);
        data.distance = new CurrencyData(' ', ((Decimal)q.get('numDist') == null)     ? 0 : (Decimal)q.get('numDist'));
        data.units =    new CurrencyData(' ', ((Decimal)q.get('numUnits') == null)    ? 0 : (Decimal)q.get('numUnits'));
        data.invoices = new CurrencyData(' ', ((Decimal)q.get('numInv') == null) ? 0 : (Decimal)q.get('numInv'));
        
        data.revenueModifier = new CurrencyData(currencyIsoCode, (Decimal) q.get('revenueModifier'));
        data.netRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalAmount')==null)?0+data.revenueModifier.value:((Decimal)q.get('totalAmount'))+data.revenueModifier.value);
        data.costOfGoodsSold = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cogs')==null)?0:(Decimal)q.get('cogs'));
        data.costOfGoodsSoldSeeThrough = new CurrencyData(currencyIsoCode,((Decimal)q.get('cogsST')==null)?0:(Decimal)q.get('cogsST'));
        data.directCosts = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDC')==null)?0:(Decimal)q.get('totalDC'));
        data.indirectCosts = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDC')==null)?0:(Decimal)q.get('totalIDC'));
        data.directCostDeliveryHrs = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDCDelHrs')==null)?0:(Decimal)q.get('totalDCDelHrs'));
        data.directCostShotHrs = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalDCShotHrs')==null)?0:(Decimal)q.get('totalDCShotHrs'));
        data.indirectCostInvoices = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCInvoices')==null)?0:(Decimal)q.get('totalIDCInvoices'));
        data.indirectCostMiles = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCDistance')==null)?0:(Decimal)q.get('totalIDCDistance'));
        data.indirectCostNetRevenue = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCNetRev')==null)?0:(Decimal)q.get('totalIDCNetRev'));
        data.indirectCostTotalHours = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCHours')==null)?0:(Decimal)q.get('totalIDCHours'));
        data.indirectCostUnits = new CurrencyData(currencyIsoCode, ((Decimal)q.get('totalIDCUnits')==null)?0:(Decimal)q.get('totalIDCUnits'));
        data.grossMargin = new CurrencyData(currencyIsoCode, ((Decimal)q.get('gm')==null)?0:(Decimal)q.get('gm'));
        data.grossMarginPercentage = ((Decimal)q.get('gmp')==null)?0:(Decimal)q.get('gmp');
        data.grossMarginSeeThrough = new CurrencyData(currencyIsoCode, ((Decimal)q.get('gmst')==null)?0:(Decimal)q.get('gmst'));
        data.grossMarginSeeThroughPercentage = ((Decimal)q.get('gmstp')==null)?0:(Decimal)q.get('gmstp');
        data.contributionMargin = new CurrencyData(currencyIsoCode, ((Decimal)q.get('cm')==null)?0:(Decimal)q.get('cm'));
        data.contributionMarginPercentage = ((Decimal)q.get('cmp')==null)?0:(Decimal)q.get('cmp');
        data.deliveryHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteMhrsRate') ==null)?0:(Decimal)q.get('siteMhrsRate'));
        data.totalHoursRate = new CurrencyData(currencyIsoCode, ((Decimal)q.get('siteTotalRate') ==null)?0:(Decimal)q.get('siteTotalRate'));
        data.shotHoursRate = new CurrencyData(currencyIsoCode, data.totalHoursRate.value - data.deliveryHoursRate.value);
                
        data.productGmData = new ProductGMData(aggregateRevenueAndCostByPHL1([Select q.Id from Quote__c q Where q.Sales_Organization_Primary__c=:siteId and q.Price_Valid_To__c >=:fromDate AND q.Price_Valid_From__c <=:toDate]), currencyIsoCode);
        data = addInSiteRegionCompanyData(data, site.Id, site.Region_Site__c, site.Company_Site__c, fromDate, toDate);
        data.total1 = new CurrencyData(currencyIsoCode, data.totalHours.value + data.distance.value + data.units.value + data.invoices.value + data.netRevenue.value);
        data.total2 = new CurrencyData(currencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
        data.total3 = new CurrencyData(currencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
        data.total4 = new CurrencyData(currencyIsoCode, data.companyTotalHrs.value + data.companyDistance.value + data.companyUnits.value + data.companyInvoices.value + data.companyNetRev.value);
        data.total5 = new CurrencyData(currencyIsoCode, data.totalHrsTotal.value + data.distanceTotal.value + data.unitsTotal.value + data.invoicesTotal.value + data.netRevTotal.value);
        data.ebit = new CurrencyData(currencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;     
        data.ebitWith = new CurrencyData(currencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
        data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;             
        return data;        
    }
    
    private static PandLData zeroOutRemaining(PandLData data) {
        String currencyIsoCode = UserInfo.getDefaultCurrency();
        
        data.siteTotalHrs = new CurrencyData(currencyIsoCode, 0.00);
        data.siteDistance = new CurrencyData(currencyIsoCode, 0.00);
        data.siteUnits = new CurrencyData(currencyIsoCode, 0.00);
        data.siteInvoices = new CurrencyData(currencyIsoCode, 0.00);
        data.siteNetRev = new CurrencyData(currencyIsoCode, 0.00);
        data.regionTotalHrs = new CurrencyData(currencyIsoCode, 0.00);
        data.regionDistance = new CurrencyData(currencyIsoCode, 0.00);
        data.regionUnits = new CurrencyData(currencyIsoCode, 0.00);
        data.regionInvoices = new CurrencyData(currencyIsoCode, 0.00);
        data.regionNetRev = new CurrencyData(currencyIsoCode, 0.00);
        data.companyTotalHrs = new CurrencyData(currencyIsoCode, 0.00);
        data.companyDistance = new CurrencyData(currencyIsoCode, 0.00);
        data.companyUnits = new CurrencyData(currencyIsoCode, 0.00);
        data.companyInvoices = new CurrencyData(currencyIsoCode, 0.00);
        data.companyNetRev = new CurrencyData(currencyIsoCode, 0.00);
        data.totalHrsTotal = new CurrencyData(currencyIsoCode, 0.00);
        data.distanceTotal = new CurrencyData(currencyIsoCode, 0.00);
        data.unitsTotal    = new CurrencyData(currencyIsoCode, 0.00);
        data.invoicesTotal = new CurrencyData(currencyIsoCode, 0.00);
        data.netRevTotal   = new CurrencyData(currencyIsoCode, 0.00);
        data.rateTotalHrs = new CurrencyData(currencyIsoCode, 0.00);
        data.rateDistance = new CurrencyData(currencyIsoCode, 0.00);
        data.rateUnits = new CurrencyData(currencyIsoCode, 0.00);
        data.rateInvoices = new CurrencyData(currencyIsoCode, 0.00);
        data.rateNetRevenue = new CurrencyData(currencyIsoCode, 0.00);
        
        return data;
    }
    
    /** P&L CODE TO DEPRECATE IS ABOVE **/
    /** GOOD P&L CODE IS BELOW **/

    private static PandLData calculateAllocatedIndirectCostsAndMore(PandLData data, Quote__c theQuote) {
        Date startDate = theQuote.Price_Valid_From__c.addYears(-1);
        
        List<AggregateResult> siteArList = [SELECT SUM(DELHRS__c) delSum, SUM(DISTANCE__C) milesSum, SUM(SHOTHRS__c) sumShot,
                                               SUM(INVOICES__c) invSum, SUM(REVENUE__C) nrSum, SUM(Total_Cogs__c) sumCOGS,
                                               SUM(UNITS__c) lbsSum
                                        FROM Cost_Driver_Entry__c
                                        WHERE  Sales_Site__c = :theQuote.Sales_Organization_Primary__c                 AND
                                               Current_Month__c >= :startDate                                          AND 
                                               Current_Month__c < :theQuote.Price_Valid_From__c];       
                                               
        List<AggregateResult> regionArList = [SELECT SUM(DELHRS__c) delSum, SUM(DISTANCE__C) milesSum, SUM(SHOTHRS__c) sumShot,
                                               SUM(INVOICES__c) invSum, SUM(REVENUE__C) nrSum, SUM(Total_Cogs__c) sumCOGS,
                                               SUM(UNITS__c) lbsSum
                                        FROM Cost_Driver_Entry__c
                                        WHERE  Sales_Site__r.Region_Site__c = :theQuote.Sales_Organization_Primary__r.Region_Site__c  AND
                                               Current_Month__c >= :startDate                                                         AND 
                                               Current_Month__c < :theQuote.Price_Valid_From__c];                                                      
        AggregateResult siteAr, regionAr;
        if(siteArList.size() > 0) {
            siteAr = siteArList[0];
        } else {
            siteAr = null;
        }
        
        if(regionArList.size() > 0) {
            regionAr = regionArList[0];
        } else {
            regionAr = null;
        }   
        
        data = calculateUnits(data, theQuote); 
        data = calculateRates(data, theQuote, siteAr, regionAr);
        data = calculateValues(data, theQuote);              
        
        return data;
    }
    
    public static PandLData getTAIC(Id quoteId) {
        Quote__c q = [Select q.Annual_Number_of_Events__c, q.Price_Valid_From__c, q.Formulaic_Mhrs_Rate__c, q.Formulaic_Shot_Rate__c, q.Net_Revenue_Modifier__c, q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.Region_Site__c, q.Name, q.Total_Delivery_Hours__c, q.Total_Annual_of_Invoices__c, q.Total_Round_Trip_Truck_Distance__c, q.Total_Shot_Service_Load_Assistance_Hours__c, q.Sales_Organization_Primary__r.Name, q.Sales_Organization_Primary__r.Company_Site__r.Name, q.Sales_Organization_Primary__r.Region_Site__r.Name, q.Customer__r.Name, q.Customer__r.SAP_Account_Number__c, q.Quote_Valid_From__c, q.Quote_Valid_To__c, q.Quote_Amount__c, q.Indirect_Cost_Units__c, q.Indirect_Cost_Total_Hrs__c, q.Indirect_Cost_Net_Revenue__c, q.Indirect_Cost_Invoices__c, q.Indirect_Cost_Distance__c, q.GM__c, q.GM_See_Through__c, q.GM_See_Through_Percent__c, q.GM_Percentage__c, q.EBIT_F__c, q.EBIT_F_Percent__c, q.Direct_Cost_Delivery_Hrs__c,  q.Direct_Cost_Shot_Hrs__c, q.CurrencyIsoCode, q.Cost_Total_Indirect__c, q.Cost_Total_Direct__c, q.COGS__c, q.COGS_See_Through__c, q.CM__c, q.CM_Percent__c,q.Total_Quantity__c, q.Total_Number_of_Invoices__c, q.Site_Cost_Driver_Rate_Total_Hrs__c, q.Site_Cost_Driver_Rate_Rev_Exp__c, q.Site_Cost_Driver_Rate_Pounds__c, q.Site_Cost_Driver_Rate_Miles__c, q.Site_Cost_Driver_Rate_Mhrs__c, q.Site_Cost_Driver_Rate_Invoice__c, q.Shot_Service_Load_Assistance_Hours__c, q.Round_Trip_Truck_Distance__c, q.Delivery_Hours__c, q.Sales_Organization_Primary__r.Delivery_Hours_Rate__c, q.Sales_Organization_Primary__r.Shot_Service_Hours_Rate__c, q.Sales_Organization_Primary__r.Distance_Rate__c From Quote__c q Where q.Id = :quoteId];
        Sales_Site__c theSite = [SELECT Id, Region_Site__c, Company_Site__c FROM Sales_Site__c WHERE Id = :q.Sales_Organization_Primary__c];
        
        PandLData data = new PandLData();
        
        /* REVENUE AND GROSS MARGIN */
        data.revenueModifier = new CurrencyData(q.CurrencyIsoCode, q.Net_Revenue_Modifier__c);
        data.netRevenue = new CurrencyData(q.CurrencyIsoCode, (q.Quote_Amount__c ==null)?0+data.revenueModifier.value : q.Quote_Amount__c+data.revenueModifier.value);      
        data.costOfGoodsSold = new CurrencyData(q.CurrencyIsoCode, (q.COGS__c ==null)?0:q.COGS__c);
        data.costOfGoodsSoldSeeThrough = new CurrencyData(q.CurrencyIsoCode, (q.COGS_See_Through__c ==null)?0:q.COGS_See_Through__c);
        data.grossMargin = new CurrencyData(q.CurrencyIsoCode, (q.GM__c ==null)?0:q.GM__c);
        data.grossMarginPercentage = (q.GM_Percentage__c == null)?0:q.GM_Percentage__c;
        data.grossMarginSeeThrough = new CurrencyData(q.CurrencyIsoCode, q.GM_See_Through__c);
        data.grossMarginSeeThroughPercentage = (q.GM_See_Through_Percent__c == null)?0:q.GM_See_Through_Percent__c;
                
        /* DIRECT LABOR COSTS AND CONTRIBUTION MARGIN PART 1, PART 2 in calculateAllocatedIndirectCostsAndMore */
        data.deliveryHours = (q.Total_Delivery_Hours__c == null)?0:q.Total_Delivery_Hours__c;
        data.shotHours = (q.Total_Shot_Service_Load_Assistance_Hours__c == null)?0:q.Total_Shot_Service_Load_Assistance_Hours__c;
                
        /* SITE, REGION, AND COMPANY ALLOCATED INDIRECT COSTS */
        data = calculateAllocatedIndirectCostsAndMore(data, q); // Obtain units column      

        /* EBIT WITH CORPORATE ALLOCATION */
        data.ebit = new CurrencyData(q.CurrencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitPercentage = data.netRevenue.value == 0 ? 0 : (data.ebit.value / data.netRevenue.value) * 100;     

        return data;
    }
    
    private static PandLData calculateUnits(PandLData data, Quote__c theQuote) {
        Double units = calculateQuantity(theQuote);
    
        Double annualEvents = theQuote.Annual_Number_Of_Events__c == null ? 0 : theQuote.Annual_Number_Of_Events__c;
        Double truckDist    = theQuote.Round_Trip_Truck_Distance__c == null ? 0 : theQuote.Round_Trip_Truck_Distance__c;
        Double invoices     = theQuote.Total_Number_of_Invoices__c == null ? 0 : theQuote.Total_Number_of_Invoices__c;
        Double amount       = theQuote.Quote_Amount__c == null ? 0 : theQuote.Quote_Amount__c;
        
        data.totalHours         = new CurrencyData(' ', data.deliveryHours + data.shotHours);
        data.distance           = new CurrencyData(' ', annualEvents * truckDist);
        data.units              = new CurrencyData(' ', units);
        data.invoices           = new CurrencyData(' ', annualEvents * invoices);
        data.indirectNetRevenue = new CurrencyData(' ', amount);        
        
        return data;    
    }
    
    private static Double calculateQuantity(Quote__c theQuote) {
        Double units = 0, per, quant;
        List<Quote_Line_Item__c> qliList = [SELECT Material_Item__c, Per__c, Quantity__c, UoM__c FROM Quote_Line_Item__c WHERE Quote__c = :theQuote.Id];
        Map<Id, List<Alternate_Unit_Of_Measure__c>> idToAum = new Map<Id, List<Alternate_unit_of_measure__c>>();
        List<Id> aumsNeededFor = new List<Id>();
        for(Quote_Line_Item__c qli : qliList) {
            if(qli.UoM__c == 'FT' || qli.UoM__c == 'BAG' || qli.UoM__c == 'CS' || qli.UoM__c == 'GLL' || qli.UoM__c == 'KAR' || qli.UoM__c == 'YD') {
                aumsNeededFor.add(qli.Material_Item__c);
            }
        }
        
        if(aumsNeededFor.size() > 0) {
            List<Alternate_Unit_Of_Measure__c> tempAumList;
            for(Alternate_Unit_of_Measure__c aum : [SELECT Id, Material_Item__c, X__c, Y__c, AUn__c, BUn__c FROM Alternate_Unit_Of_Measure__c WHERE Material_Item__c in :aumsNeededFor AND (((AUn__c = 'FT' OR AUn__c = 'BAG' OR AUn__c = 'CS' OR AUn__c = 'GLL' OR AUn__c = 'KAR' OR AUn__c = 'YD') AND (BUn__c = 'EA' OR BUn__c = 'LB')) OR ((AUn__c = 'EA' OR AUn__c = 'LB') AND (BUn__c = 'FT' OR BUn__c = 'BAG' OR BUn__c = 'CS' OR BUn__c = 'GLL' OR BUn__c = 'KAR' OR BUn__c = 'YD')))]) {
                if(idToAum.containsKey(aum.Material_Item__c)) {
                    tempAumList = idToAum.get(aum.Material_Item__c);
                    tempAumList.add(aum);
                    idToAum.put(aum.Material_Item__c, tempAumList);
                } else {
                    tempAumList = new List<Alternate_Unit_Of_Measure__c>();
                    tempAumList.add(aum);
                    idToAum.put(aum.Material_Item__c, tempAumList);
                }
            }
        }
        
        for(Quote_Line_Item__c qli : qliList) {
            per = qli.Per__c == null ? 0 : qli.Per__c;
            if(qli.UoM__c == 'TO') { //Contant conversion
                quant = qli.Quantity__c == null ? 0 : qli.Quantity__c;
                units += quant * 2204.62262;                        
            } else if(qli.UoM__c == 'TON') { //Contant conversion
                quant = qli.Quantity__c == null ? 0 : qli.Quantity__c;
                units += quant * 2000;                      
            }else if(idToAum.containsKey(qli.Material_Item__c) && (qli.UoM__c == 'FT' || qli.UoM__c == 'BAG' || qli.UoM__c == 'CS' || qli.UoM__c == 'GLL' || qli.UoM__c == 'KAR' || qli.UoM__c == 'YD')) { //AUM Based Conversions
                //Look up the material in the map
                //iterate over aums
                for(Alternate_Unit_Of_Measure__c aum : idToAum.get(qli.Material_Item__c)) {
                    if( (qli.UoM__c == 'FT' && aum.BUn__c == 'FT' && aum.AUn__c == 'EA') || 
                        (qli.UoM__c == 'BAG' && aum.BUn__c == 'BAG' && aum.AUn__c == 'LB') || 
                        (qli.UoM__c == 'CS' && aum.BUn__c == 'CS' && aum.AUn__c == 'EA') ||
                        (qli.UoM__c == 'GLL' && aum.BUn__c == 'GLL' && aum.AUn__c == 'EA') || 
                        (qli.UoM__c == 'KAR' && aum.BUn__c == 'KAR' && aum.AUn__c == 'EA') || 
                        (qli.UoM__c == 'YD' && aum.BUn__c == 'YD' && aum.AUn__c == 'EA')) {
                        //mult by y/x
                        quant = qli.Quantity__c == null ? 0 : qli.Quantity__c;
                        units += quant * (aum.Y__c/aum.X__c);                           
                        break;
                    } else if( (qli.UoM__c == 'FT' && aum.BUn__c == 'EA' && aum.AUn__c == 'FT') || 
                        (qli.UoM__c == 'BAG' && aum.BUn__c == 'LB' && aum.AUn__c == 'BAG') || 
                        (qli.UoM__c == 'CS' && aum.BUn__c == 'EA' && aum.AUn__c == 'CS') ||
                        (qli.UoM__c == 'GLL' && aum.BUn__c == 'EA' && aum.AUn__c == 'GLL') || 
                        (qli.UoM__c == 'KAR' && aum.BUn__c == 'EA' && aum.AUn__c == 'KAR') || 
                        (qli.UoM__c == 'YD' && aum.BUn__c == 'EA' && aum.AUn__c == 'YD')) {
                        //mult by x/y   
                        quant = qli.Quantity__c == null ? 0 : qli.Quantity__c;
                        units += quant * (aum.X__c/aum.Y__c);                           
                        break;
                    }
                }
            } else if(qli.UoM__c != 'H' && qli.UoM__c != 'KM' && qli.UoM__c != 'MI' && qli.UoM__c != 'STD' && qli.UoM__c != '10' && qli.UoM__c != 'HR') { //1-to-1
                quant = qli.Quantity__c == null ? 0 : qli.Quantity__c;
                units += quant;             
            }
        }       
        
        return units;       
    }
    
    private static PandLData calculateRates(PandLData data, Quote__c theQuote, AggregateResult siteAr, AggregateResult regionAr) {
        Date startDate = theQuote.Price_Valid_From__c.addYears(-1);
        List<AggregateResult> pcaList = [SELECT SUM(Invoice__c) sumInv, SUM(Invoice_Reg__c) sumInvReg, SUM(Mhrs__c) sumMhrs, SUM(Mhrs_Reg__c) sumMhrsReg,
                                                SUM(Miles__c) sumMiles, SUM(Miles_Reg__c) sumMilesReg, SUM(Pounds__c) sumLbs, SUM(Pounds_Reg__c) sumLbsReg,
                                                SUM(Rev_Exp__c) sumNr, SUM(Rev_Exp_Reg__c) sumNrReg, Sales_Site__c,
                                                SUM(Total_Hrs__c) sumTotalHrs, SUM(Total_Hrs_Reg__c) sumTotalHrsReg FROM PCA__c 
                                          WHERE (Sales_Site__c = :theQuote.Sales_Organization_Primary__c OR
                                                 Sales_Site__c = :theQuote.Sales_Organization_Primary__r.Region_Site__c) AND 
                                                 Post_Month__c >= :startDate                             AND 
                                                 Post_Month__c < :theQuote.Price_Valid_From__c GROUP BY Sales_Site__c];
        
        Double thrSite, dSite, dRegion, uSite, uRegion, iSite, iRegion, nrSite, nrRegion, tSite, tRegion; 
        
        AggregateResult sitePCA, regionPCA;
        if(pcaList.size() > 0) {
            if(String.valueOf(pcaList[0].get('Sales_Site__c')) == String.valueOf(theQuote.Sales_Organization_Primary__c)) {
                sitePCA = pcaList[0];
                regionPCA = pcaList.size() > 1 ? pcaList[1] : null;
            } else {
                sitePCA = pcaList.size() > 1 ? pcaList[1] : null;
                regionPCA = pcaList[0];
            }               
        }  else {
            sitePCA = null;
            regionPCA = null;
        }       
        
        
        if(pcaList.size() > 0) {        
            tSite     = 0;/* siteAr == null || sitePCA == null || siteAr.get('sumShot') == null ||siteAr.get('delSum') ==null|| (Double.valueOf(siteAr.get('sumShot'))+Double.valueOf(siteAr.get('delSum'))) == 0 ? 0 :
                               Double.valueOf(sitePCA.get('sumTotalHrs')) / (Double.valueOf(siteAr.get('sumShot'))+Double.valueOf(siteAr.get('delSum')));
                           */    
            tRegion   = regionAr == null || regionPCA == null || regionAr.get('sumShot') == null || regionAr.get('delSum') ==null || (Double.valueOf(regionAr.get('sumShot'))+Double.valueOf(regionAr.get('delSum'))) == 0 ? 0 :
                               Double.valueOf(regionPCA.get('sumTotalHrs')) / (Double.valueOf(regionAr.get('sumShot'))+Double.valueOf(regionAr.get('delSum')));                
        
            thrSite   = siteAr == null || sitePCA == null || siteAr.get('sumShot')==null|| siteAr.get('delSum')==null|| (Double.valueOf(siteAr.get('sumShot'))+Double.valueOf(siteAr.get('delSum'))) == 0 ? 0 :
                               Double.valueOf(((Double)sitePCA.get('sumMhrs') + (Double)sitePCA.get('sumTotalHrs')) / (Double.valueOf(siteAr.get('sumShot'))+Double.valueOf(siteAr.get('delSum'))));
            /*thrRegion = regionAr == null || regionPCA == null || Double.valueOf(regionAr.get('delSum')) == 0 ? 0 :
                               Double.valueOf(regionPCA.get('sumMhrs')) / Double.valueOf(regionAr.get('delSum'));*/
                               
            dSite     = siteAr == null || sitePCA == null || siteAr.get('milesSum') == null || Double.valueOf(siteAr.get('milesSum')) == 0 ? 0 :
                               Double.valueOf(sitePCA.get('sumMiles')) / Double.valueOf(siteAr.get('milesSum'));
            dRegion   = regionAr == null || regionPCA == null || regionAr.get('milesSum') == null || Double.valueOf(regionAr.get('milesSum')) == 0 ? 0 :
                               Double.valueOf(regionPCA.get('sumMiles')) / Double.valueOf(regionAr.get('milesSum'));
    
            uSite     = siteAr == null || sitePCA == null || siteAr.get('lbsSum') == null || Double.valueOf(siteAr.get('lbsSum')) == 0 ? 0 :
                               Double.valueOf(sitePCA.get('sumLbs')) / Double.valueOf(siteAr.get('lbsSum'));
            uRegion   = regionAr == null || regionPCA == null || regionAr.get('lbsSum') == null || Double.valueOf(regionAr.get('lbsSum')) == 0 ? 0 :
                               Double.valueOf(regionPCA.get('sumLbs')) / Double.valueOf(regionAr.get('lbsSum'));
    
            iSite     = siteAr == null || sitePCA == null || siteAr.get('invSum')==null||Double.valueOf(siteAr.get('invSum')) == 0 ? 0 :
                               Double.valueOf(sitePCA.get('sumInv')) / Double.valueOf(siteAr.get('invSum'));
            iRegion   = regionAr == null || regionPCA == null || regionAr.get('invSum')==null||Double.valueOf(regionAr.get('invSum')) == 0 ? 0 :
                               Double.valueOf(regionPCA.get('sumInv')) / Double.valueOf(regionAr.get('invSum'));
    
            nrSite    = siteAr == null || sitePCA == null || siteAr.get('nrSum')==null||Double.valueOf(siteAr.get('nrSum')) == 0 ? 0 :
                               Double.valueOf(sitePCA.get('sumNr')) / Double.valueOf(siteAr.get('nrSum'));
            nrRegion  = regionAr == null || regionPCA == null || regionAr.get('nrSum')==null||Double.valueOf(regionAr.get('nrSum')) == 0 ? 0 :
                               Double.valueOf(regionPCA.get('sumNr')) / Double.valueOf(regionAr.get('nrSum'));
        } else {
            thrSite = 0;
            dSite = 0;
            dRegion = 0;
            uSite = 0;
            uRegion = 0;
            iSite = 0;
            iRegion = 0;
            nrSite = 0;
            nrRegion = 0;
        }
        
        data.totalHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, tSite);
        if (theQuote.Sales_Organization_Primary__c != null && theQuote.Sales_Organization_Primary__r.Distance_Rate__c != null && theQuote.Sales_Organization_Primary__r.Distance_Rate__c > 0)
            data.distanceRate = new CurrencyData(theQuote.CurrencyIsoCode, theQuote.Sales_Organization_Primary__r.Distance_Rate__c);
        else
            data.distanceRate = new CurrencyData(theQuote.CurrencyIsoCode, dSite);
        data.unitsRate = new CurrencyData(theQuote.CurrencyIsoCode, uSite);
        data.invoicesRate = new CurrencyData(theQuote.CurrencyIsoCode, iSite);
        data.netRevenueRate = new CurrencyData(theQuote.CurrencyIsoCode, nrSite);
        
        data.rateTotalHrs = new CurrencyData(theQuote.CurrencyIsoCode, tRegion);
        data.rateDistance = new CurrencyData(theQuote.CurrencyIsoCode, dRegion);
        data.rateUnits = new CurrencyData(theQuote.CurrencyIsoCode, uRegion);
        data.rateInvoices = new CurrencyData(theQuote.CurrencyIsoCode, iRegion);
        data.rateNetRevenue = new CurrencyData(theQuote.CurrencyIsoCode, nrRegion); 
        
        /* Calculate remainder of DIRECT LABOR COSTS AND CONTRIBUTION MARGIN */
        if (theQuote.Sales_Organization_Primary__c != null && theQuote.Sales_Organization_Primary__r.Delivery_Hours_Rate__c != null && theQuote.Sales_Organization_Primary__r.Delivery_Hours_Rate__c > 0)
            data.deliveryHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, theQuote.Sales_Organization_Primary__r.Delivery_Hours_Rate__c);
        else {
            if (thrSite < 40)
                data.deliveryHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, 40);
            else
                data.deliveryHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, thrSite);
        }
        decimal dhr = data.deliveryHoursRate.value;
        if (theQuote.Sales_Organization_Primary__c != null && theQuote.Sales_Organization_Primary__r.Shot_Service_Hours_Rate__c != null && theQuote.Sales_Organization_Primary__r.Shot_Service_Hours_Rate__c > 0)
            data.shotHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, theQuote.Sales_Organization_Primary__r.Shot_Service_Hours_Rate__c);
        else {
            if (thrSite < 40)
                data.shotHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, 40);
            else
                data.shotHoursRate = new CurrencyData(theQuote.CurrencyIsoCode, thrSite);
        }
        decimal shr = data.shotHoursRate.value;
        data.directCostDeliveryHrs = new CurrencyData(theQuote.CurrencyIsoCode, dhr * data.deliveryHours);
        data.directCostShotHrs = new CurrencyData(theQuote.CurrencyIsoCode, shr * data.shotHours);          
        data.directCosts = new CurrencyData(theQuote.CurrencyIsoCode, data.directCostDeliveryHrs.value + data.directCostShotHrs.value);
        data.contributionMargin = new CurrencyData(theQuote.CurrencyIsoCode, theQuote.GM__c-data.directCosts.value);
        data.contributionMarginPercentage = data.netRevenue.value == null || data.netRevenue.value == 0 ? 0 : (data.contributionMargin.value / data.netRevenue.value) * 100;   
            
        return data;
    }
    
    private static PandLData calculateValues(PandLData data, Quote__c theQuote) {
        data.siteTotalHrs = new CurrencyData(theQuote.CurrencyIsoCode, data.totalHoursRate.value * data.totalHours.value);
        data.siteDistance = new CurrencyData(theQuote.CurrencyIsoCode, data.distanceRate.value * data.distance.value);
        data.siteUnits    = new CurrencyData(theQuote.CurrencyIsoCode, data.unitsRate.value * data.units.value);
        data.siteInvoices = new CurrencyData(theQuote.CurrencyIsoCode, data.invoicesRate.value * data.invoices.value);
        data.siteNetRev   = new CurrencyData(theQuote.CurrencyIsoCode, data.netRevenueRate.value * data.indirectNetRevenue.value);
        
        data.regionTotalHrs = new CurrencyData(theQuote.CurrencyIsoCode, data.rateTotalHrs.value * data.totalHours.value);
        data.regionDistance = new CurrencyData(theQuote.CurrencyIsoCode, data.rateDistance.value * data.distance.value);
        data.regionUnits    = new CurrencyData(theQuote.CurrencyIsoCode, data.rateUnits.value * data.units.value);
        data.regionInvoices = new CurrencyData(theQuote.CurrencyIsoCode, data.rateInvoices.value * data.invoices.value);
        data.regionNetRev   = new CurrencyData(theQuote.CurrencyIsoCode, data.rateNetRevenue.value * data.indirectNetRevenue.value);
        
        data.totalHrsTotal = new CurrencyData(theQuote.CurrencyIsoCode, data.siteTotalHrs.value + data.regionTotalHrs.value);
        data.distanceTotal = new CurrencyData(theQuote.CurrencyIsoCode, data.siteDistance.value + data.regionDistance.value);
        data.unitsTotal    = new CurrencyData(theQuote.CurrencyIsoCode, data.siteUnits.value + data.regionUnits.value);     
        data.invoicesTotal = new CurrencyData(theQuote.CurrencyIsoCode, data.siteInvoices.value + data.regionInvoices.value);
        data.netRevTotal   = new CurrencyData(theQuote.CurrencyIsoCode, data.siteNetRev.value + data.regionNetRev.value);
        
        data.total2 = new CurrencyData(theQuote.CurrencyIsoCode, data.siteTotalHrs.value + data.siteDistance.value + data.siteUnits.value + data.siteInvoices.value + data.siteNetRev.value);
        data.total3 = new CurrencyData(theQuote.CurrencyIsoCode, data.regionTotalHrs.value + data.regionDistance.value + data.regionUnits.value + data.regionInvoices.value + data.regionNetRev.value);
        data.total5 = new CurrencyData(theQuote.CurrencyIsoCode, data.total2.value + data.total3.value);
        
        return data;
    }
    
    public static PandLData createForQuote(Id quoteId) {
    	return createForQuote(quoteId, 1);
    }
    
    // This is used for Quote To Actual report, adjustment decides the multiplier for the volume.
    public static PandLData createForQuote(Id quoteId, decimal adjustment) {
        Quote__c q = [Select q.Annual_Number_of_Events__c, q.Price_Valid_From__c, q.Formulaic_Mhrs_Rate__c, q.Formulaic_Shot_Rate__c, q.Net_Revenue_Modifier__c, q.Sales_Organization_Primary__c, q.Sales_Organization_Primary__r.Region_Site__c, q.Name, q.Total_Delivery_Hours__c, q.Total_Annual_of_Invoices__c, q.Total_Round_Trip_Truck_Distance__c, q.Total_Shot_Service_Load_Assistance_Hours__c, q.Sales_Organization_Primary__r.Name, q.Sales_Organization_Primary__r.Company_Site__r.Name, q.Sales_Organization_Primary__r.Region_Site__r.Name, q.Customer__r.Name, q.Customer__r.SAP_Account_Number__c, q.Quote_Valid_From__c, q.Quote_Valid_To__c, q.Quote_Amount__c, q.Indirect_Cost_Units__c, q.Indirect_Cost_Total_Hrs__c, q.Indirect_Cost_Net_Revenue__c, q.Indirect_Cost_Invoices__c, q.Indirect_Cost_Distance__c, q.GM__c, q.GM_See_Through__c, q.GM_See_Through_Percent__c, q.GM_Percentage__c, q.EBIT_F__c, q.EBIT_F_Percent__c, q.Direct_Cost_Delivery_Hrs__c,  q.Direct_Cost_Shot_Hrs__c, q.CurrencyIsoCode, q.Cost_Total_Indirect__c, q.Cost_Total_Direct__c, q.COGS__c, q.COGS_See_Through__c, q.CM__c, q.CM_Percent__c,q.Total_Quantity__c, q.Total_Number_of_Invoices__c, q.Site_Cost_Driver_Rate_Total_Hrs__c, q.Site_Cost_Driver_Rate_Rev_Exp__c, q.Site_Cost_Driver_Rate_Pounds__c, q.Site_Cost_Driver_Rate_Miles__c, q.Site_Cost_Driver_Rate_Mhrs__c, q.Site_Cost_Driver_Rate_Invoice__c, q.Shot_Service_Load_Assistance_Hours__c, q.Round_Trip_Truck_Distance__c, q.Delivery_Hours__c, q.Sales_Organization_Primary__r.Delivery_Hours_Rate__c, q.Sales_Organization_Primary__r.Shot_Service_Hours_Rate__c, q.Sales_Organization_Primary__r.Distance_Rate__c From Quote__c q Where q.Id = :quoteId];
        Sales_Site__c theSite = [SELECT Id, Region_Site__c, Company_Site__c FROM Sales_Site__c WHERE Id = :q.Sales_Organization_Primary__c];
        
        PandLData data = new PandLData();
        
        /* INIT BASIC DATA FOR HEADERS */
        data.customerName = q.Customer__r.Name;
        data.scenarioName = q.Name;
        data.companyName = q.Sales_Organization_Primary__r.Company_Site__r.Name;
        data.regionName = q.Sales_Organization_Primary__r.Region_Site__r.Name;
        data.siteName = q.Sales_Organization_Primary__r.Name;
        data.sapCustomerNumber = q.Customer__r.SAP_Account_Number__c;
        data.currencyIsoCode = q.CurrencyIsoCode;
        data.validFrom = q.Quote_Valid_From__c;
        data.validTo = q.Quote_Valid_To__c;
        data.validFromDisplay = q.Quote_Valid_From__c.format().split(' ').get(0);
        data.validToDisplay = q.Quote_Valid_To__c.format().split(' ').get(0);

        /* PRODUCT LINE REVENUE AND GROSS MARGIN */
        data.productGmData = new ProductGMData(aggregateRevenueAndCostByPHL1(new List<Quote__c>{q}), q.CurrencyIsoCode);
        if (adjustment != 1) {
        	data.productGmData.PL005.netRevenue.value *= adjustment; 
        	data.productGmData.PL005.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL005.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL030.netRevenue.value *= adjustment; 
        	data.productGmData.PL030.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL030.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL032.netRevenue.value *= adjustment; 
        	data.productGmData.PL032.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL032.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL035.netRevenue.value *= adjustment; 
        	data.productGmData.PL035.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL035.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL040_2.netRevenue.value *= adjustment; 
        	data.productGmData.PL040_2.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL040_2.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL045_7.netRevenue.value *= adjustment; 
        	data.productGmData.PL045_7.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL045_7.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL048.netRevenue.value *= adjustment; 
        	data.productGmData.PL048.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL048.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL049_50.netRevenue.value *= adjustment; 
        	data.productGmData.PL049_50.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL049_50.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL060_1.netRevenue.value *= adjustment; 
        	data.productGmData.PL060_1.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL060_1.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL065.netRevenue.value *= adjustment; 
        	data.productGmData.PL065.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL065.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL070.netRevenue.value *= adjustment; 
        	data.productGmData.PL070.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL070.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL080.netRevenue.value *= adjustment; 
        	data.productGmData.PL080.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL080.costOfGoodsSoldSeeThrough.value *= adjustment; 
        	data.productGmData.PL084.netRevenue.value *= adjustment; 
        	data.productGmData.PL084.costOfGoodsSold.value *= adjustment; 
        	data.productGmData.PL084.costOfGoodsSoldSeeThrough.value *= adjustment; 
        }
        
        /* REVENUE AND GROSS MARGIN */
        data.revenueModifier = new CurrencyData(q.CurrencyIsoCode, q.Net_Revenue_Modifier__c);
        data.netRevenue = new CurrencyData(q.CurrencyIsoCode, (q.Quote_Amount__c ==null)?0+data.revenueModifier.value : q.Quote_Amount__c * adjustment + data.revenueModifier.value);      
        data.costOfGoodsSold = new CurrencyData(q.CurrencyIsoCode, (q.COGS__c ==null)?0:q.COGS__c * adjustment);
        data.costOfGoodsSoldSeeThrough = new CurrencyData(q.CurrencyIsoCode, (q.COGS_See_Through__c ==null)?0:q.COGS_See_Through__c * adjustment);
        data.grossMargin = new CurrencyData(q.CurrencyIsoCode, (q.GM__c ==null)?0:q.GM__c * adjustment);
        data.grossMarginPercentage = (q.GM_Percentage__c == null)?0:q.GM_Percentage__c;
        data.grossMarginSeeThrough = new CurrencyData(q.CurrencyIsoCode, q.GM_See_Through__c * adjustment);
        data.grossMarginSeeThroughPercentage = (q.GM_See_Through_Percent__c == null)?0:q.GM_See_Through_Percent__c;
                
        /* DIRECT LABOR COSTS AND CONTRIBUTION MARGIN PART 1, PART 2 in calculateAllocatedIndirectCostsAndMore */
        data.deliveryHours = (q.Total_Delivery_Hours__c == null)?0:q.Total_Delivery_Hours__c;
        data.shotHours = (q.Total_Shot_Service_Load_Assistance_Hours__c == null)?0:q.Total_Shot_Service_Load_Assistance_Hours__c;
        
        /* SITE, REGION, AND COMPANY ALLOCATED INDIRECT COSTS */
        data = calculateAllocatedIndirectCostsAndMore(data, q); // Obtain units column
        
        /* EBIT WITH CORPORATE ALLOCATION */
        data.ebit = new CurrencyData(q.CurrencyIsoCode, data.contributionMargin.value - data.total5.value);
        data.ebitWith = new CurrencyData(q.CurrencyIsoCode, data.ebit.value - ((Decimal.valueOf(System.Label.CorporateAllocationPercentage)/100.00)*data.netRevenue.value) );
        data.ebitPercentageWith = data.netRevenue.value == 0 ? 0 : (data.ebitWith.value / data.netRevenue.value) * 100;         
        
        return data;
    }
    
    public with sharing class ProductGMData {
        public GMData PL005 {get;set;}
        public GMData PL030 {get;set;}
        public GMData PL032 {get;set;}
        public GMData PL035 {get;set;}
        public GMData PL040_2 {get;set;}
        public GMData PL045_7 {get;set;}
        public GMData PL048 {get;set;}
        public GMData PL049_50 {get;set;}
        public GMData PL084 {get;set;}
        public GMData PL060_1 {get;set;}
        public GMData PL065 {get;set;}
        public GMData PL070 {get;set;}
        public GMData PL080 {get;set;}
        
        public ProductGMData(List<AggregateResult> results, String currencyIsoCode) {
            string userCurr = 'USD';
            this.PL005 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL030 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL032 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL035 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL040_2 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL045_7 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL048 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL049_50 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL084 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL060_1 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL065 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL070 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            this.PL080 = new GMData(new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0), new CurrencyData(userCurr,0.0));
            
            for (AggregateResult result : results) {
                if ((String)result.get('PHL1__c') == 'PL005') {
                    this.PL005.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL005.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL005.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL030') {
                    this.PL030.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL030.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL030.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL032') {
                    this.PL032.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL032.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL032.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL035') {
                    this.PL035.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL035.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL035.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL040' || (String)result.get('PHL1__c') == 'PL042') {
                    this.PL040_2.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL040_2.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));   
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL040_2.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL045' || (String)result.get('PHL1__c') == 'PL047') {
                    this.PL045_7.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL045_7.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL045_7.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL048') {
                    this.PL048.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL048.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL048.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL049' || (String)result.get('PHL1__c') == 'PL050') {
                    this.PL049_50.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL049_50.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL049_50.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL084') {
                    this.PL084.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL084.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL084.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL060' || (String)result.get('PHL1__c') == 'PL061') {
                    this.PL060_1.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL060_1.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL060_1.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL065') {
                    this.PL065.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL065.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL065.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL070') {
                    this.PL070.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL070.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL070.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                }
                if ((String)result.get('PHL1__c') == 'PL080') {
                    this.PL080.netRevenue.value += (Decimal)result.get('netRevenue');
                    this.PL080.costOfGoodsSold.value += Math.Abs((Decimal)result.get('costOfGoodsSold'));
                    if (result.get('costOfGoodsSoldST') != null)
                        this.PL080.costOfGoodsSoldSeeThrough.value += Math.Abs((Decimal)result.get('costOfGoodsSoldST'));
                } 
            }
            
            if (currencyIsoCode != userCurr) {
                this.PL005.netRevenue.convert(currencyIsoCode); this.PL005.netRevenue.value = Math.Round(this.PL005.netRevenue.value);
                this.PL005.costOfGoodsSold.convert(currencyIsoCode); this.PL005.costOfGoodsSold.value = Math.Round(this.PL005.costOfGoodsSold.value);
                this.PL005.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL005.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL005.costOfGoodsSoldSeeThrough.value);
                this.PL030.netRevenue.convert(currencyIsoCode); this.PL030.netRevenue.value = Math.Round(this.PL030.netRevenue.value);
                this.PL030.costOfGoodsSold.convert(currencyIsoCode); this.PL030.costOfGoodsSold.value = Math.Round(this.PL030.costOfGoodsSold.value);
                this.PL030.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL030.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL030.costOfGoodsSoldSeeThrough.value);
                this.PL032.netRevenue.convert(currencyIsoCode); this.PL032.netRevenue.value = Math.Round(this.PL032.netRevenue.value);
                this.PL032.costOfGoodsSold.convert(currencyIsoCode); this.PL032.costOfGoodsSold.value = Math.Round(this.PL032.costOfGoodsSold.value);
                this.PL032.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL032.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL032.costOfGoodsSoldSeeThrough.value);
                this.PL035.netRevenue.convert(currencyIsoCode); this.PL035.netRevenue.value = Math.Round(this.PL035.netRevenue.value);
                this.PL035.costOfGoodsSold.convert(currencyIsoCode); this.PL035.costOfGoodsSold.value = Math.Round(this.PL035.costOfGoodsSold.value);
                this.PL035.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL035.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL035.costOfGoodsSoldSeeThrough.value);
                this.PL040_2.netRevenue.convert(currencyIsoCode); this.PL040_2.netRevenue.value = Math.Round(this.PL040_2.netRevenue.value);
                this.PL040_2.costOfGoodsSold.convert(currencyIsoCode); this.PL040_2.costOfGoodsSold.value = Math.Round(this.PL040_2.costOfGoodsSold.value);
                this.PL040_2.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL040_2.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL040_2.costOfGoodsSoldSeeThrough.value);
                this.PL045_7.netRevenue.convert(currencyIsoCode); this.PL045_7.netRevenue.value = Math.Round(this.PL045_7.netRevenue.value);
                this.PL045_7.costOfGoodsSold.convert(currencyIsoCode); this.PL045_7.costOfGoodsSold.value = Math.Round(this.PL045_7.costOfGoodsSold.value);
                this.PL045_7.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL045_7.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL045_7.costOfGoodsSoldSeeThrough.value);
                this.PL048.netRevenue.convert(currencyIsoCode); this.PL048.netRevenue.value = Math.Round(this.PL048.netRevenue.value);
                this.PL048.costOfGoodsSold.convert(currencyIsoCode); this.PL048.costOfGoodsSold.value = Math.Round(this.PL048.costOfGoodsSold.value);
                this.PL048.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL048.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL048.costOfGoodsSoldSeeThrough.value);
                this.PL049_50.netRevenue.convert(currencyIsoCode); this.PL049_50.netRevenue.value = Math.Round(this.PL049_50.netRevenue.value);
                this.PL049_50.costOfGoodsSold.convert(currencyIsoCode); this.PL049_50.costOfGoodsSold.value = Math.Round(this.PL049_50.costOfGoodsSold.value);
                this.PL049_50.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL049_50.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL049_50.costOfGoodsSoldSeeThrough.value);
                this.PL084.netRevenue.convert(currencyIsoCode); this.PL084.netRevenue.value = Math.Round(this.PL084.netRevenue.value);
                this.PL084.costOfGoodsSold.convert(currencyIsoCode); this.PL084.costOfGoodsSold.value = Math.Round(this.PL084.costOfGoodsSold.value);
                this.PL084.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL084.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL084.costOfGoodsSoldSeeThrough.value);
                this.PL060_1.netRevenue.convert(currencyIsoCode); this.PL060_1.netRevenue.value = Math.Round(this.PL060_1.netRevenue.value);
                this.PL060_1.costOfGoodsSold.convert(currencyIsoCode); this.PL060_1.costOfGoodsSold.value = Math.Round(this.PL060_1.costOfGoodsSold.value);
                this.PL060_1.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL060_1.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL060_1.costOfGoodsSoldSeeThrough.value);
                this.PL065.netRevenue.convert(currencyIsoCode); this.PL065.netRevenue.value = Math.Round(this.PL065.netRevenue.value);
                this.PL065.costOfGoodsSold.convert(currencyIsoCode); this.PL065.costOfGoodsSold.value = Math.Round(this.PL065.costOfGoodsSold.value);
                this.PL065.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL065.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL065.costOfGoodsSoldSeeThrough.value);
                this.PL070.netRevenue.convert(currencyIsoCode); this.PL070.netRevenue.value = Math.Round(this.PL070.netRevenue.value);
                this.PL070.costOfGoodsSold.convert(currencyIsoCode); this.PL070.costOfGoodsSold.value = Math.Round(this.PL070.costOfGoodsSold.value);
                this.PL070.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL070.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL070.costOfGoodsSoldSeeThrough.value);
                this.PL080.netRevenue.convert(currencyIsoCode); this.PL080.netRevenue.value = Math.Round(this.PL080.netRevenue.value);
                this.PL080.costOfGoodsSold.convert(currencyIsoCode); this.PL080.costOfGoodsSold.value = Math.Round(this.PL080.costOfGoodsSold.value);
                this.PL080.costOfGoodsSoldSeeThrough.convert(currencyIsoCode); this.PL080.costOfGoodsSoldSeeThrough.value = Math.Round(this.PL080.costOfGoodsSoldSeeThrough.value);
            }
        }
    }

    private static List<AggregateResult> aggregateRevenueAndCostByPHL1(List<Quote__c> quotes) {
        return [Select SUM(Total_Price__c) netRevenue, SUM(Total_Cost__c) costOfGoodsSold, SUM(Total_Cost_See_Through__c) costOfGoodsSoldST, Material_Item__r.PHL1__c FROM Quote_Line_Item__c where Quote__c in :quotes GROUP BY Material_Item__r.PHL1__c];
    }   
    
    
    
    public with sharing class GMData {
        public CurrencyData netRevenue {get;set;}
        public CurrencyData costOfGoodsSold {get;set;}
        public CurrencyData costOfGoodsSoldSeeThrough {get;set;}
        public CurrencyData gm {
            get {
                return new CurrencyData(netRevenue.currencyISOCode, (netRevenue.value - costOfGoodsSold.value));
            }
        }
        public Decimal gmPercentage {
            get {
                return (this.netRevenue.value != 0)?((this.gm.value/this.netRevenue.value)*100).setScale(2):0;
            }
        }
        
        public CurrencyData gmSeeThrough {
            get {
                return new CurrencyData(netRevenue.currencyISOCode, (netRevenue.value - costOfGoodsSoldSeeThrough.value));
            }
        }
        public Decimal gmSeeThroughPercentage {
            get {
                return (this.netRevenue.value != 0)?((this.gmSeeThrough.value/this.netRevenue.value)*100).setScale(2):0;
            }
        }
        
        public GMData(CurrencyData netRevenue, CurrencyData costOfGoodsSold, CurrencyData costOfGoodsSoldSeeThrough) {
            this.netRevenue = netRevenue;
            this.costOfGoodsSold = costOfGoodsSold;
            this.costOfGoodsSoldSeeThrough = costOfGoodsSoldSeeThrough;
        }
    }
    
    public void ConvertToCurrency(String isoCurrency) {
        if (this.netRevenue != null)
            this.netRevenue.convert(isoCurrency);
        if (this.indirectNetRevenue != null)
            this.indirectNetRevenue.convert(isoCurrency);
        if (this.totalHours != null)
            this.totalHours.convert(isoCurrency);
        if (this.invoices != null)
            this.invoices.convert(isoCurrency);
        if (this.distance != null)
            this.distance.convert(isoCurrency);
        if (this.units != null)
            this.units.convert(isoCurrency);
        if (this.total1 != null)
            this.total1.convert(isoCurrency);
        if (this.total2 != null)
            this.total2.convert(isoCurrency);
        if (this.total3 != null)
            this.total3.convert(isoCurrency);
        if (this.total4 != null)
            this.total4.convert(isoCurrency);
        if (this.total5 != null)
            this.total5.convert(isoCurrency);
        if (this.deliveryHoursRate != null)
            this.deliveryHoursRate.convert(isoCurrency);
        if (this.shotHoursRate != null)
            this.shotHoursRate.convert(isoCurrency);
        if (this.totalHoursRate != null)
            this.totalHoursRate.convert(isoCurrency);
        if (this.invoicesRate != null)
            this.invoicesRate.convert(isoCurrency);
        if (this.distanceRate != null)
            this.distanceRate.convert(isoCurrency);
        if (this.unitsRate != null)
            this.unitsRate.convert(isoCurrency);
        if (this.netRevenueRate != null)
            this.netRevenueRate.convert(isoCurrency);
        if (this.costOfGoodsSold != null)
            this.costOfGoodsSold.convert(isoCurrency);
        if (this.costOfGoodsSoldSeeThrough != null)
            this.costOfGoodsSoldSeeThrough.convert(isoCurrency);
        if (this.directCosts != null)
            this.directCosts.convert(isoCurrency);
        if (this.indirectCosts != null)
            this.indirectCosts.convert(isoCurrency);
        if (this.directCostDeliveryHrs != null)
            this.directCostDeliveryHrs.convert(isoCurrency);
        if (this.directCostShotHrs != null)
            this.directCostShotHrs.convert(isoCurrency);
        if (this.indirectCostMiles != null)
            this.indirectCostMiles.convert(isoCurrency);
        if (this.indirectCostInvoices != null)
            this.indirectCostInvoices.convert(isoCurrency);
        if (this.indirectCostNetRevenue != null)
            this.indirectCostNetRevenue.convert(isoCurrency);
        if (this.indirectCostTotalHours != null)
            this.indirectCostTotalHours.convert(isoCurrency);
        if (this.indirectCostUnits != null)
            this.indirectCostUnits.convert(isoCurrency);
        if (this.revenueModifier != null)
            this.revenueModifier.convert(isoCurrency);
        if (this.grossMargin != null)
            this.grossMargin.convert(isoCurrency);
        if (this.grossMarginSeeThrough != null)
            this.grossMarginSeeThrough.convert(isoCurrency);
        if (this.contributionMargin != null)
            this.contributionMargin.convert(isoCurrency);
        if (this.ebit != null)
            this.ebit.convert(isoCurrency);
        if (this.ebitWith != null)
            this.ebitWith.convert(isoCurrency);
        if (this.siteTotalHrs != null)
            this.siteTotalHrs.convert(isoCurrency);
        if (this.siteDistance != null)
            this.siteDistance.convert(isoCurrency);
        if (this.siteUnits != null)
            this.siteUnits.convert(isoCurrency);
        if (this.siteInvoices != null)
            this.siteInvoices.convert(isoCurrency);
        if (this.siteNetRev != null)
            this.siteNetRev.convert(isoCurrency);
        if (this.regionTotalHrs != null)
            this.regionTotalHrs.convert(isoCurrency);
        if (this.regionDistance != null)
            this.regionDistance.convert(isoCurrency);
        if (this.regionUnits != null)
            this.regionUnits.convert(isoCurrency);
        if (this.regionInvoices != null)
            this.regionInvoices.convert(isoCurrency);
        if (this.regionNetRev != null)
            this.regionNetRev.convert(isoCurrency);
        if (this.companyTotalHrs != null)
            this.companyTotalHrs.convert(isoCurrency);
        if (this.companyDistance != null)
            this.companyDistance.convert(isoCurrency);
        if (this.companyUnits != null)
            this.companyUnits.convert(isoCurrency);
        if (this.companyInvoices != null)
            this.companyInvoices.convert(isoCurrency);
        if (this.companyNetRev != null)
            this.companyNetRev.convert(isoCurrency);
        if (this.rateTotalHrs != null)
            this.rateTotalHrs.convert(isoCurrency);
        if (this.rateDistance != null)
            this.rateDistance.convert(isoCurrency);
        if (this.rateUnits != null)
            this.rateUnits.convert(isoCurrency);
        if (this.rateInvoices != null)
            this.rateInvoices.convert(isoCurrency);
        if (this.rateNetRevenue != null)
            this.rateNetRevenue.convert(isoCurrency);
        if (this.totalHrsTotal != null)
            this.totalHrsTotal.convert(isoCurrency);
        if (this.distanceTotal != null)
            this.distanceTotal.convert(isoCurrency);
        if (this.unitsTotal != null)
            this.unitsTotal.convert(isoCurrency);
        if (this.invoicesTotal != null)
            this.invoicesTotal.convert(isoCurrency);
        if (this.netRevTotal != null)
            this.netRevTotal.convert(isoCurrency);
    }
    
}