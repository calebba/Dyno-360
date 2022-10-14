public with sharing class ExpenseAllocator {
    public static Boolean isRunning = false;
    private static List<PCA__c> futurePCAs = new List<PCA__c>();
    public static boolean inFutureContext = false;
    public static List<PCA__c> subList = new List<PCA__c>();
    
    /*
      When P&L is fixed, fix testSimpleHierarchy()
    */
    
    public static void allocate(List<PCA__c> records) {
        isRunning = true;
        
        //Get list of all sales sites referenced by any of the input PCAs.
        Date tempDate;
        List<Id> salesSiteIds = new List<Id>();
        for (PCA__c rec : records) {
            if(rec.Sales_Site__c != null) {
                salesSiteIds.add(rec.Sales_Site__c);
            }
        }       

        //Step 1
        //Find earliest incoming month and latest incoming month and get list of all months between those two dates.
        AggregateResult ar = [SELECT MAX(Post_Month__c) maxMonth, MIN(Post_Month__c) minMonth FROM PCA__c WHERE Id in :records];
        Date minDate = (Date) ar.get('minMonth');
        Date maxDate = (Date) ar.get('maxMonth');
        List<Date> dateList = determineDates(minDate, maxDate);

        //Step 2
        //Get aggregated PCA data for Site, Region, and Company
        List<AggregateResult> companyPCAs = [SELECT SUM(Mhrs__c) mhrs, SUM(Total_Hrs__c) totalHrs, SUM(Miles__c) miles, SUM(Invoice__c) invoices, SUM(Pounds__c) pounds, SUM(Rev_Exp__c) revenueExpense, Sales_Site__c, Post_Month__c FROM PCA__c WHERE (Post_Month__c >= :minDate and Post_Month__c <= :maxDate) and Sales_Site__r.Company_Site__c = null GROUP BY Sales_Site__c, Post_Month__c];
        List<Id> companySalesSiteIds = new List<Id>();
        Map<String, AggregateResult> companyPCAMap = new Map<String, AggregateResult>();
        for (AggregateResult companyPCA : companyPCAs) {
            tempDate = ((Date) companyPCA.get('Post_Month__c')).toStartOfMonth();
            companyPCAMap.put((Id)companyPCA.get('Sales_Site__c') +'|'+ tempDate.format(), companyPCA);
            companySalesSiteIds.add((Id)companyPCA.get('Sales_Site__c'));
        }

        List<AggregateResult> regionPCAs = [SELECT SUM(Mhrs__c) mhrs, SUM(Total_Hrs__c) totalHrs, SUM(Miles__c) miles, SUM(Invoice__c) invoices, SUM(Pounds__c) pounds, SUM(Rev_Exp__c) revenueExpense, Sales_Site__c, Post_Month__c FROM PCA__c WHERE (Post_Month__c >= :minDate and Post_Month__c <= :maxDate) and Sales_Site__r.Company_Site__c <> null And Sales_Site__r.Region_Site__c = null GROUP BY Sales_Site__c, Post_Month__c];
        List<Id> regionIds = new List<Id>();
        Map<String, AggregateResult> regionPCAMap = new Map<String, AggregateResult>();
        for (AggregateResult regionPCA : regionPCAs) {
            tempDate = ((Date) regionPCA.get('Post_Month__c')).toStartOfMonth();
            regionPCAMap.put((Id)regionPCA.get('Sales_Site__c') +'|'+ tempDate.format(), regionPCA);
            regionIds.add((Id)regionPCA.get('Sales_Site__c'));
        }

        List<AggregateResult> sitePCAs = [SELECT SUM(Mhrs__c) mhrs, SUM(Total_Hrs__c) totalHrs, SUM(Miles__c) miles, SUM(Invoice__c) invoices, SUM(Pounds__c) pounds, SUM(Rev_Exp__c) revenueExpense, Sales_Site__c, Post_Month__c FROM PCA__c WHERE (Post_Month__c >= :minDate and Post_Month__c <= :maxDate) and Sales_Site__r.Company_Site__c <> null and Sales_Site__r.Region_Site__c <> null GROUP BY Sales_Site__c, Post_Month__c];
        Map<String, AggregateResult> sitePCAMap = new Map<String, AggregateResult>();
        List<Id> siteIds = new List<Id>();
        for(AggregateResult aggRes : sitePCAs) {
            tempDate = ((Date) aggRes.get('Post_Month__c')).toStartOfMonth();
            sitePCAMap.put((Id) aggRes.get('Sales_Site__c') + '|' + tempDate.format(), aggRes);
            siteIds.add((Id) aggRes.get('Sales_Site__c'));
        }
        
        //Step 3
        //Get all Cost Driver Entries      
        Map<String, Cost_Driver_Entry__c> companyToCDE = new Map<String, Cost_Driver_Entry__c>();
        Map<String, Cost_Driver_Entry__c> regionToCDE = new Map<String, Cost_Driver_Entry__c>();
        Map<String, Cost_Driver_Entry__c> siteToCDE = new Map<String, Cost_Driver_Entry__c>();
        for(Cost_Driver_Entry__c currCDE : [Select c.Current_Month__c, c.Sales_Site__c, c.UNITS__c, SHOTHRS__c, REVENUE__c, INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where (c.Current_Month__c >= :minDate and c.Current_Month__c <= :maxDate) and c.Sales_Site__r.Company_Site__c <> null and c.Sales_Site__r.Region_Site__c = null]) {
            regionToCDE.put(currCDE.Sales_Site__c + '|' + currCDE.Current_Month__c.toStartOfMonth().format(), currCDE);
        }

        for(Cost_Driver_Entry__c currCDE : [Select c.Current_Month__c, c.Sales_Site__r.Name, c.Sales_Site__c, c.UNITS__c, SHOTHRS__c, REVENUE__c, INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where (c.Current_Month__c >= :minDate and c.Current_Month__c <= :maxDate) and c.Sales_Site__r.Company_Site__c <> null and c.Sales_Site__r.Region_Site__c <> null]) {
            siteToCDE.put(currCDE.Sales_Site__c + '|' + currCDE.Current_Month__c.toStartOfMonth().format(), currCDE);
        }

        for(Cost_Driver_Entry__c currCDE : [Select c.Current_Month__c, c.Sales_Site__c, c.UNITS__c, SHOTHRS__c, REVENUE__c, INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where (c.Current_Month__c >= :minDate and c.Current_Month__c <= :maxDate) and c.Sales_Site__r.Company_Site__c = null]) {
            companyToCDE.put(currCDE.Sales_Site__c + '|' + currCDE.Current_Month__c.toStartOfMonth().format(), currCDE);
        }
        
        //Step 4        
        //Get all site level pca
        Map<String, PCA__c> siteToPCA = new Map<String, PCA__c>();
        for(PCA__c currPCA : [SELECT Mhrs_Rate__c, Total_Hrs_Rate__c, Miles_Rate__c, Invoice_Rate__c, Pounds_Rate__c, Rev_Exp_Rate__c, Mhrs_Reg__c, Total_Hrs_Reg__c, Miles_Reg__c, Invoice_Reg__c, Pounds_Reg__c, Rev_Exp_Reg__c, Mhrs_Comp__c, Total_Hrs_Comp__c, Miles_Comp__c, Invoice_Comp__c, Pounds_Comp__c, Rev_Exp_Comp__c, Mhrs__c, Total_Hrs__c, Miles__c, Invoice__c, Pounds__c, Rev_Exp__c, Sales_Site__c, Post_Month__c FROM PCA__c WHERE id in :records And Sales_Site__r.Company_Site__c <> null And Sales_Site__r.Region_Site__c <> null]) {
            siteToPCA.put(currPCA.Sales_Site__c + '|' + currPCA.Post_Month__c.toStartOfMonth().format(), currPCA);
        }
                
        //Step 5
        //Get ALL SITES (Note the caps)
        List<Sales_Site__c> allSites = [SELECT Id, Name, Region_Site__c, Company_Site__c FROM Sales_Site__c WHERE Region_Site__c <> null and Company_Site__c <> null];
        Map<Id, Sales_Site__c> allSitesMap = new Map<Id, Sales_Site__c>(allSites);          

        //Step 6 - Update/create new PCA data for each month/site combo
        String key, regionKey, companyKey;
        ExpenseData currentExpenses;
        List<ExpenseData> expenses = new List<ExpenseData>();
        PCA__c currentPCA;
        Cost_Driver_Entry__c currentCDE;
        List<PCA__c> toUpsertList = new List<PCA__c>();
        for(Sales_Site__c currSite : allSites) {
            for(Date currDate : dateList) {
                key = getPrimaryKey(currSite.Id, currDate);
                regionKey = getRegionKey(currSite, currDate);
                companyKey = getCompanyKey(currSite, currDate);
                currentPCA = new PCA__c();
                currentCDE = new Cost_Driver_Entry__c();
                if(siteToPCA.get(key) != null) {
                	currentPCA = siteToPCA.get(key);
                } else {
                	//Generate a zeroed out PCA
                    currentPCA = new PCA__c(Invoice_Comp_Rate__c = 0.00, Invoice_Comp__c = 0.00, Invoice_Reg_Rate__c = 0.00, Invoice_Reg__c = 0.00, Invoice_Rate__c = 0.00, Invoice__c = 0.00, Pounds_Comp_Rate__c = 0.00, Pounds_Comp__c = 0.00, Pounds_Reg_Rate__c = 0.00, Pounds_Reg__c = 0.00, Pounds_Rate__c = 0.00, Pounds__c = 0.00, Total_Hrs_Comp_Rate__c = 0.00, Total_Hrs_Comp__c = 0.00, Total_Hrs_Reg_Rate__c = 0.00, Sales_Site__c = currSite.Id, Post_Month__c = currDate, Miles__c = 0.00, Miles_Reg__c = 0.00, Miles_Reg_Rate__c = 0.00, Miles_Comp__c = 0.00, Miles_Comp_Rate__c = 0.00, Miles_Rate__c = 0.00, Mhrs__c = 0.00, Mhrs_Rate__c = 0.00, Mhrs_Reg__c = 0.00, Mhrs_Reg_Rate__c = 0.00, Mhrs_Comp__c = 0.00, Mhrs_Comp_Rate__c = 0.00, Rev_Exp__c = 0.00, Rev_Exp_Rate__c = 0.00, Rev_Exp_Reg__c = 0.00, Rev_Exp_Comp__c = 0.00, Rev_Exp_Comp_Rate__c = 0.00, Total_Hrs__c = 0.00, Total_Hrs_Rate__c = 0.00, Total_Hrs_Reg__c = 0.00);                             
                }
                    
                if(siteToCDE.get(key) != null) {
                    currentCDE = siteToCDE.get(key);
                } else {
                	//Generated a zeroed out CDE
                	currentCDE = new Cost_Driver_Entry__c(Sales_Site__c = currSite.Id, INVOICES__c = 0.00, DISTANCE__c = 0.00, DELHRS__c = 0.00, REVENUE__c = 0.00, SHOTHRS__c = 0.00, UNITS__c = 0.00);
                }
                    
                currentExpenses = new ExpenseData(currentPCA, currentCDE);              

                //Update region fields on site PCA
                if(regionPCAMap.get(regionKey) != null && regionToCDE.get(regionKey) != null) {
                    currentExpenses.setRegionValues(regionPCAMap.get(regionKey), regionToCDE.get(regionKey));
                }
                //Update company fields on site PCA
                if(companyPCAMap.get(companyKey) != null && companyToCDE.get(companyKey) != null) {
                    currentExpenses.setCompanyValues(companyPCAMap.get(companyKey), companyToCDE.get(companyKey));
                }

                currentExpenses.calculateRates();
                toUpsertList.add(currentExpenses.pcaRec);    
            }
        } 

        //Step 7 - Update the siteExpenses     
        if(!inFutureContext) {
        	upsert toUpsertList;
        	inFutureContext = true;
        	futureAveraging();
        }
        
        isRunning = false;
    }
    
    @future
    static private void futureAveraging() {
        // Update site rolling averages
        List<AggregateResult> pcaValues = [SELECT SUM(Mhrs__c) sumPCAMhrs, SUM(Total_Hrs__c) sumPCAShotHrs, SUM(Miles__c) sumPCAMiles, SUM(Invoice__c) sumPCAInvoices, SUM(Pounds__c) sumPCAPounds, SUM(Rev_Exp__c) sumPCANetRev, Sales_Site__c sitePCA from PCA__c WHERE Sales_Site__r.Region_Site__c <> null AND Sales_Site__r.Company_Site__c <> null AND Post_Month__c = LAST_N_DAYS:365 GROUP BY Sales_Site__c];
        List<AggregateResult> cdeValues = [SELECT SUM(DELHRS__c) sumCDEMhrs, SUM(SHOTHRS__c) sumCDEShotHrs, SUM(DISTANCE__c) sumCDEMiles, SUM(INVOICES__c) sumCDEInvoices, SUM(UNITS__c) sumCDEPounds, SUM(REVENUE__c) sumCDENetRev, Sales_Site__c siteCDE FROM Cost_Driver_Entry__c WHERE Sales_Site__r.Region_Site__c <> null AND Sales_Site__r.Company_Site__c <> null AND Current_Month__c = LAST_N_DAYS:365 GROUP BY Sales_Site__c];
        
        Map<Id, AggregateCoupler> aggregateMap = new Map<Id, AggregateCoupler>();
        for(AggregateResult ar : pcaValues) {
        	AggregateCoupler ac = new AggregateCoupler();
        	ac.pcaAr = ar;
        	ac.cdeAr = null;
        	aggregateMap.put((Id)ar.get('sitePCA'), ac);
        }
        
        for(AggregateResult ar : cdeValues) {
        	if(aggregateMap.containsKey((Id)ar.get('siteCDE'))) {
        		AggregateCoupler ac = aggregateMap.get((Id)ar.get('siteCDE'));
        		ac.cdeAr = ar;
        		aggregateMap.put((Id)ar.get('siteCDE'), ac);
        	}
        }
        
        List<Sales_Site__c> sitesToUpdate = new List<Sales_Site__c>();
        Sales_Site__c tempSite;
        AggregateCoupler ac;
        for (Id acKey : aggregateMap.keySet()) {
        	ac = aggregateMap.get(acKey);
        	if(ac.pcaAr != null && ac.cdeAr != null) {
        		tempSite = new Sales_Site__c(Id = acKey, 
        		                             Average_Mhrs__c =      (Double)ac.cdeAr.get('sumCDEMhrs')     == 0 ? 0 : ((Double)ac.pcaAr.get('sumPCAMhrs'))/((Double)ac.cdeAr.get('sumCDEMhrs')),
        		                             Average_Total_Hrs__c = (Double)ac.cdeAr.get('sumCDEShotHrs')  == 0 ? 0 : ((Double)ac.pcaAr.get('sumPCAShotHrs'))/((Double)ac.cdeAr.get('sumCDEShotHrs')),
        		                             Average_Miles__c =     (Double)ac.cdeAr.get('sumCDEMiles')    == 0 ? 0 : ((Double)ac.pcaAr.get('sumPCAMiles'))/((Double)ac.cdeAr.get('sumCDEMiles')),
        		                             Average_Invoice__c =   (Double)ac.cdeAr.get('sumCDEInvoices') == 0 ? 0 : ((Double)ac.pcaAr.get('sumPCAInvoices'))/((Double)ac.cdeAr.get('sumCDEInvoices')),
        		                             Average_Pounds__c =    (Double)ac.cdeAr.get('sumCDEPounds')   == 0 ? 0 : ((Double)ac.pcaAr.get('sumPCAPounds'))/((Double)ac.cdeAr.get('sumCDEPounds')),
        		                             Average_Rev_Exp__c =   (Double)ac.cdeAr.get('sumCDENetRev')   == 0 ? 0 : ((Double)ac.pcaAr.get('sumPCANetRev'))/((Double)ac.cdeAr.get('sumCDENetRev')));
        	} else {
        		tempSite = new Sales_Site__c(Id = acKey, Average_Mhrs__c = 0, Average_Total_Hrs__c = 0, Average_Miles__c = 0, 
        		                                         Average_Invoice__c = 0, Average_Pounds__c = 0, Average_Rev_Exp__c = 0);
        	}
			sitesToUpdate.add(tempSite);
        }

        update sitesToUpdate;       
    }
    
    public class AggregateCoupler {
    	public AggregateResult pcaAr {get; set;}
    	public AggregateResult cdeAr {get; set;}
    }
    
    
    private static String getPrimaryKey(Id siteId, Date aDate) {
        return siteId + '|' + aDate.format();
    }
    
    private static String getRegionKey(Sales_Site__c aSite, Date aDate) {
        String regionKey;
        if(aSite.Region_Site__c == null) {
            regionKey = 'NOREGIONKEY';
        } else {
            regionKey = aSite.Region_Site__c + '|' + aDate.format();
        }
        return regionKey;
    }
    
    private static String getCompanyKey(Sales_Site__c aSite, Date aDate) {
        String companyKey;
        if(aSite.Company_Site__c == null) {
            companyKey = 'NOCOMPANYKEY';
        } else {
            companyKey = aSite.Company_Site__c + '|' + aDate.format();
        }       
        return companyKey;
    }
    
    @testVisible
    private static List<Date> determineDates(Date minDate, Date maxDate) {
        List<Date> dateList = new List<Date>();
        if(minDate == maxDate) {
            dateList.add(minDate.toStartOfMonth());
            return dateList;
        }
        //Calculate a list of all months inbetween the minDate and maxDate
        //Case 1: Min date and max date in same year.
        if(minDate.year() == maxDate.year()) {
            for(Integer i = minDate.month(); i <= maxDate.month(); i++) {
                dateList.add(Date.parse(i+'/1/'+minDate.year()));
            }
        }
        //Case 2 Min date and max date not in same year.
        if(minDate.year() != maxDate.year()) {
            //Sub case 1: Dates only off by 1 year.
            //Sub case 2: Dates off by > 1 year.
            for(Integer i = minDate.month(); i <= 12; i++) {
                dateList.add(Date.parse(i+'/1/'+minDate.year()));
            }
            Integer yearDiff = maxDate.year() - minDate.year();
            if(yearDiff > 1) {
                Integer startYear = minDate.year()+1;
                for(Integer yearCount = 0; yearCount <= yearDiff-2;yearCount++) {
                    for(Integer month = 1; month <= 12; month++) {
                        dateList.add(Date.parse(month+'/1/'+startYear));
                    }
                    startYear++;
                }
            }
            for(Integer i = 1; i <= maxDate.month(); i++) {
                dateList.add(Date.parse(i+'/1/'+maxDate.year()));
            }               
        }
        return dateList;
    }
    
    private static Decimal performRatioCalc(Decimal value, Decimal numerator, Decimal denominator) {
        if(denominator == 0 || value == null || numerator == null || denominator == null) {
            return 0;
        }
        return value * (numerator/denominator);
    }
    
    //Expense data will be used to group site pca and cde
    //Do it for everything, e.g. site, region, company
    //Looking at the original implementation he just takes the first, so I suppose we will do the same
    //I will call setCompanyValues and setRegionValues for sites
    //I will call setCompanyValues for regions
    //I will call none for companies
    //I will feed the appropriate region and company level data to it to feed its fields.
    public class ExpenseData {
        private PCA__c pcaRec;
        private Cost_Driver_Entry__c cdeRec;
        
        public ExpenseData(PCA__c p, Cost_Driver_Entry__c c) {
            pcaRec = p;
            cdeRec = c;
        }
                
        public void setCompanyValues(AggregateResult companyPCA, Cost_Driver_Entry__c companyCDE) {
            // Miles
            pcaRec.Miles_Comp__c += performRatioCalc((Decimal)companyPCA.get('miles'), cdeRec.DISTANCE__c, companyCDE.DISTANCE__c);
            
            // Mhrs
            pcaRec.Mhrs_Comp__c += performRatioCalc((Decimal)companyPCA.get('mhrs'), cdeRec.DELHRS__c, companyCDE.DELHRS__c);
            
            // Rev Exp
            pcaRec.Rev_Exp_Comp__c += performRatioCalc((Decimal)companyPCA.get('revenueExpense'), cdeRec.REVENUE__c, companyCDE.REVENUE__c);
            
            // Total hours
            pcaRec.Total_Hrs_Comp__c += performRatioCalc((Decimal)companyPCA.get('totalHrs'), cdeRec.SHOTHRS__c+cdeRec.DELHRS__c, companyCDE.SHOTHRS__c+companyCDE.DELHRS__c);
            
            // Pounds
            pcaRec.Pounds_Comp__c += performRatioCalc((Decimal)companyPCA.get('pounds'), cdeRec.UNITS__c, companyCDE.UNITS__c);

            // Invoices
            pcaRec.Invoice_Comp__c += performRatioCalc((Decimal)companyPCA.get('invoices'), cdeRec.INVOICES__c, companyCDE.INVOICES__c);
        }

        public void setRegionValues(AggregateResult regionPCA, Cost_Driver_Entry__c regionCDE) {
            //Miles                                         
            pcaRec.Miles_Reg__c += performRatioCalc((Decimal)regionPCA.get('miles'), cdeRec.DISTANCE__c, regionCDE.DISTANCE__c);

            // Mhrs
            pcaRec.Mhrs_Reg__c += performRatioCalc((Decimal)regionPCA.get('mhrs'), cdeRec.DELHRS__c, regionCDE.DELHRS__c);

            // Rev Exp
            pcaRec.Rev_Exp_Reg__c += performRatioCalc((Decimal)regionPCA.get('revenueExpense'), cdeRec.REVENUE__c, regionCDE.REVENUE__c);

            // Total hours
            pcaRec.Total_Hrs_Reg__c += performRatioCalc((Decimal)regionPCA.get('totalHrs'), cdeRec.SHOTHRS__c+cdeRec.DELHRS__c, regionCDE.SHOTHRS__c+regionCDE.DELHRS__c);

            // Pounds
            pcaRec.Pounds_Reg__c += performRatioCalc((Decimal)regionPCA.get('pounds'), cdeRec.UNITS__c, regionCDE.UNITS__c);
            
            // Invoices
            pcaRec.Invoice_Reg__c += performRatioCalc((Decimal)regionPCA.get('invoices'), cdeRec.INVOICES__c, regionCDE.INVOICES__c);
        }
        
        public void calculateRates() {
            // Miles
            pcaRec.Miles_Rate__c = (cdeRec.DISTANCE__c > 0) ? (pcaRec.Miles__c +pcaRec.Miles_Reg__c + pcaRec.Miles_Comp__c)/cdeRec.DISTANCE__c : 0;
            
            // Mhrs
            pcaRec.Mhrs_Rate__c = (cdeRec.DELHRS__c > 0) ? (pcaRec.Mhrs__c +pcaRec.Mhrs_Reg__c + pcaRec.Mhrs_Comp__c)/cdeRec.DELHRS__c : 0; 

            // Rev Exp
            pcaRec.Rev_Exp_Rate__c = (cdeRec.REVENUE__c > 0) ? (pcaRec.Rev_Exp__c +pcaRec.Rev_Exp_Reg__c + pcaRec.Rev_Exp_Comp__c)/cdeRec.REVENUE__c : 0;  

            // Total hours
            pcaRec.Total_Hrs_Rate__c = ((cdeRec.SHOTHRS__c  + cdeRec.DELHRS__c) > 0) ? ((pcaRec.Total_Hrs__c +pcaRec.Total_Hrs_Reg__c + pcaRec.Total_Hrs_Comp__c)/(cdeRec.SHOTHRS__c  + cdeRec.DELHRS__c)) : 0;
            
            // Pounds
            pcaRec.Pounds_Rate__c = (cdeRec.UNITS__c > 0) ? (pcaRec.Pounds__c +pcaRec.Pounds_Reg__c + pcaRec.Pounds_Comp__c)/cdeRec.UNITS__c : 0;

            // Invoices
            pcaRec.Invoice_Rate__c = (cdeRec.INVOICES__c > 0) ? (pcaRec.Invoice__c +pcaRec.Invoice_Reg__c + pcaRec.Invoice_Comp__c)/cdeRec.INVOICES__c : 0; 
        }
        
        public PCA__c getRecord() {
            return pcaRec;
        }
    }
    
      
}