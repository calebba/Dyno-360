public class EBITOutputPdf {
    
    public PandLData plDataReport { get; set; }
    public String currentLanguage { get; set; }
    
    public EBITOutputPdf() {
        currentLanguage = 'US'; 
        
        String accountIdsString = ApexPages.currentPage().getParameters().get('accountIds');
        List<Id> accountIdsList = accountIdsString.split(',',-1);
        Set<Id> accountIds = new Set<Id>();
        for (Id a : accountIdsList) {
            accountIds.add(a);
        }
        String sitesIdsListString = ApexPages.currentPage().getParameters().get('sitesIdsList');
        List<Id> sitesIdsList = sitesIdsListString.split(',',-1);
        Set<Id> sitesIds = new Set<Id>();
        for (Id s : sitesIdsList) {
            sitesIds.add(s);
        }
        Date dateFrom = date.valueOf(ApexPages.currentPage().getParameters().get('dateFrom'));
        Date dateTo = date.valueOf(ApexPages.currentPage().getParameters().get('dateTo'));
        String currentCurrency = ApexPages.currentPage().getParameters().get('currentCurrency');
        
        EBITData.EBITDataHelper edh = new EBITData.EBITDataHelper();
        edh.accountIds = accountIds;
        edh.siteIds = sitesIds;
        edh.dateFrom = dateFrom;
        edh.dateTo = dateTo;
        edh.currencyUsed = currentCurrency;
        edh.isMainReport = true;
        
        plDataReport = EBITData.createEBIT(edh);
        plDataReport.inGenerator = false;
        
    }

}