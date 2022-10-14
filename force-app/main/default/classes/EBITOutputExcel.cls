global class EBITOutputExcel {
    
    public PandLData plDataReport { get; set; }
    public List<PandLData> plDataReportShipToList { get; set; }
    //public static List<PandLData> plDataReportShipToListBatch { get; set; }
    //global List<EBITData.EBITDataHelper> edhList = new List<EBITData.EBITDataHelper>();
    public String currentLanguage { get; set; }
    public String xmlheader { get; set; }
    public String endfile { get; set; }
    public List<COPA_Aggregate__c> copaAggregateResults { get; set; }
    public Map<String,String> copaAggregateHeader { get; set; }
    public List<PCA__c> pcaResults { get; set; }
    public Map<String,String> pcaHeader { get; set; }
    public List<Cost_Driver_Entry__c> cdeResults { get; set; }
    public Map<String,String> cdeHeader { get; set; }
    
    public void EBITOutputExcelAction() {
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        currentLanguage = 'US'; 
        
        String batchId = ApexPages.currentPage().getParameters().get('batchId');
        List<COPA_ShipTos_Temp__c> auxs = [SELECT Id, Value__c, BatchId__c FROM COPA_ShipTos_Temp__c
                                                 WHERE BatchId__c = :batchId];
        plDataReportShipToList = new List<PandLData>();
        for (COPA_ShipTos_Temp__c c : auxs) {
            plDataReportShipToList.add((PandLData)JSON.deserialize(c.Value__c, PandLData.class));
        }
        System.debug('plDataReportShipToList:::');
        auxs = [SELECT Id FROM COPA_ShipTos_Temp__c];
        delete auxs;
        
        System.debug('plDataReportShipToList:::');
        
        String accountIdsString = ApexPages.currentPage().getParameters().get('accountIds');
        List<Id> accountIdsList = accountIdsString.split(',',-1);
        Set<Id> accountIds = new Set<Id>();
        for (Id a : accountIdsList) {
            accountIds.add(a);
        }

        String sitesIdsListString = ApexPages.currentPage().getParameters().get('sitesIdsList');
        List<Id> sitesIdsList = new List<Id>();
        if (sitesIdsListString != null && sitesIdsListString != '') {
            sitesIdsList = sitesIdsListString.trim().split(',',-1);
        }
        Set<Id> sitesIds = new Set<Id>();
        if (sitesIdsList.size() > 0) {
            for (Id s : sitesIdsList) {
                sitesIds.add(s);
            }
        }
        Date dateFrom = date.valueOf(ApexPages.currentPage().getParameters().get('dateFrom'));
        Date dateTo = date.valueOf(ApexPages.currentPage().getParameters().get('dateTo'));
        String currentCurrency = ApexPages.currentPage().getParameters().get('currentCurrency');
        String plant = ApexPages.currentPage().getParameters().get('plant');
        
        EBITData.EBITDataHelper edh = new EBITData.EBITDataHelper();
        System.debug('accountIds::::' + accountIds);
        System.debug('siteIds::::' + sitesIds);
        edh.accountIds = accountIds;
        edh.siteIds = sitesIds;
        edh.dateFrom = dateFrom;
        edh.dateTo = dateTo;
        edh.currencyUsed = currentCurrency;
        edh.plant = plant;
        edh.isMainReport = true;
        
        plDataReport = EBITData.createEBIT(edh);
        plDataReport.inGenerator = false;
        
        copaAggregateResults = new List<COPA_Aggregate__c>(); //database.query(EBITData.createCopaAggregateResults(edh));
        System.debug('copaAggregateResults:::' + copaAggregateResults);
        
        copaAggregateHeader = new Map<String, String>();
        //copaAggregateHeader.put('Material_PHL1__c', 'Material PHL1');
        //copaAggregateHeader.put('Sales_Site__r.Name', 'Sales Sites');
        copaAggregateHeader.put('DELHRS__c', 'Delivery Hours');
        copaAggregateHeader.put('SHOTHRS__c', 'Shot Hours');
        copaAggregateHeader.put('MILES__c', 'Distance');
        copaAggregateHeader.put('LBS__c','Units');
        copaAggregateHeader.put('INVOICES__c','Invoices');
        copaAggregateHeader.put('Net_Revenue__c','Net Revenue');
        copaAggregateHeader.put('True_Total_Cogs__c','Cost of Goods Sold');
        copaAggregateHeader.put('COGS_See_Through__c','Cost of Goods Sold See Through');
        //copaAggregateHeader.put('','');
        
        pcaResults = EBITData.createPCAResults(edh);
        pcaHeader = new Map<String, String>();
        pcaHeader.put('Miles_Total__c','Miles Total');
        pcaHeader.put('Rev_Exp_Total__c','Net Revenue Total');
        pcaHeader.put('Total_Hrs_Total__c','Total Hours Total');
        pcaHeader.put('Pounds_Total__c','Pounds Total');
        pcaHeader.put('MHrs__c','MHrs');
        pcaHeader.put('Total_Hrs__c','Total_Hrs');
        pcaHeader.put('Miles__c','Miles');
        pcaHeader.put('Pounds__c','Pounds');
        pcaHeader.put('Invoice__c','Invoice');
        pcaHeader.put('Rev_Exp__c','Revenue Expected');
        pcaHeader.put('Total_Hrs_Reg__c','Total Hrs Reg');
        pcaHeader.put('Miles_Reg__c','Miles Reg');
        pcaHeader.put('Pounds_Reg__c','Pounds Reg');
        pcaHeader.put('Invoice_Reg__c','Invoice Reg');
        pcaHeader.put('Rev_Exp_Reg__c','Rev Exp Reg');
        
        
        cdeResults = EBITData.createCDEResults(edh);
        cdeHeader = new Map<String, String>();
        cdeHeader.put('DISTANCE__C','Distance');
        cdeHeader.put('SHOTHRS__c','Shot Hours');
        cdeHeader.put('INVOICES__c','Invoices');
        cdeHeader.put('REVENUE__C','Revenue');
        cdeHeader.put('Total_Cogs__c','Total Cogs');
        cdeHeader.put('UNITS__c','Units');
        
    }

}