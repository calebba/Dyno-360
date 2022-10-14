public with sharing class COPAAllocator {
    public static Boolean isRunning = false;
    public static void execute(List<Cost_Driver_Entry__c> inputRecords) {
        isRunning=true;
        
        // Retrieve individuals months in the changeset
        Set<Date> dates = new Set<Date>();
        for (Cost_Driver_Entry__c record : inputRecords) {
            dates.add(record.Current_Month__c);
        }
        
        // Sum entry data by company code
        List<AggregateResult> companyEntries = [Select c.Sales_Site__r.Company_Site__c companySiteId, Current_Month__c currentMonth, SUM(c.UNITS__c) totalUnits, SUM(c.SHOTHRS__c) totalShotHrs, SUM(c.REVENUE__c) totalRevenue, SUM(c.INVOICES__c) totalInvoices, SUM(c.DISTANCE__c) totalDistance, SUM(c.DELHRS__c) totalDeliveryHours From Cost_Driver_Entry__c c where c.Id in :inputRecords Group by c.Sales_Site__r.Company_Site__c, Current_Month__c];
        System.debug(companyEntries);
        
        // Sum entry data by region
        List<AggregateResult> regionEntries = [Select c.Sales_Site__r.Region_Site__c regionSiteId, Current_Month__c currentMonth, SUM(c.UNITS__c) totalUnits, SUM(c.SHOTHRS__c) totalShotHrs, SUM(c.REVENUE__c) totalRevenue, SUM(c.INVOICES__c) totalInvoices, SUM(c.DISTANCE__c) totalDistance, SUM(c.DELHRS__c) totalDeliveryHours From Cost_Driver_Entry__c c where c.Id in :inputRecords Group by c.Sales_Site__r.Region_Site__c, Current_Month__c];
        
        // Select the PCA records by Company code for this month
        List<Cost_Driver_Entry__c> existingCompanyEntries = [Select c.Id, c.Sales_Site__c, c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where c.Current_Month__c in :dates and c.Sales_Site__r.Company_Site__c = null];
        Map<Id, Cost_Driver_Entry__c> companyMap = new Map<Id, Cost_Driver_Entry__c>();
        for (Cost_Driver_Entry__c entry : existingCompanyEntries) {
            companyMap.put(entry.Sales_Site__c, entry);
        }
        
        // Select the PCA records by region for this month
        List<Cost_Driver_Entry__c> existingRegionEntries = [Select c.Id, c.Sales_Site__c, c.UNITS__c, c.SHOTHRS__c, c.REVENUE__c, c.INVOICES__c, c.DISTANCE__c, c.DELHRS__c From Cost_Driver_Entry__c c where c.Current_Month__c in :dates and c.Sales_Site__r.Company_Site__c <> null and c.Sales_Site__r.Region_Site__c = null];
        Map<Id, Cost_Driver_Entry__c> regionMap = new Map<Id, Cost_Driver_Entry__c>();
        for (Cost_Driver_Entry__c entry : existingRegionEntries) {
            regionMap.put(entry.Sales_Site__c, entry);
        }
        
        // Iterate over company sums and apply to company cost driver entries
        Cost_Driver_Entry__c existingEntry;
        List<Cost_Driver_Entry__c> entries = new List<Cost_Driver_Entry__c>();
        
        for (AggregateResult entry : companyEntries) {
            if (companyMap.containsKey((Id)entry.get('companySiteId'))) {
                existingEntry = companyMap.get((Id)entry.get('companySiteId'));
                entries.add(allocateCOPA(existingEntry, entry));
            }
            else {
                entries.add(new Cost_Driver_Entry__c(Sales_Site__c=(Id)entry.get('companySiteId'), Units__c = (Decimal)entry.get('totalUnits'), SHOTHRS__c = (Decimal)entry.get('totalShotHrs'), REVENUE__c = (Decimal)entry.get('totalRevenue'), INVOICES__c = (Decimal)entry.get('totalInvoices'), DISTANCE__c = (Decimal)entry.get('totalDistance'),DELHRS__c = (Decimal)entry.get('totalDeliveryHours'), Current_Month__c=(Date)entry.get('currentMonth')));
            }
        }
        
        // Iterate over region sums and apply to region cost driver entries
        for (AggregateResult entry : regionEntries) {
            if (regionMap.containsKey((Id)entry.get('regionSiteId'))) {
                existingEntry = regionMap.get((Id)entry.get('regionSiteId'));
                entries.add(allocateCOPA(existingEntry, entry));
            }
            else {
                entries.add(new Cost_Driver_Entry__c(Sales_Site__c=(Id)entry.get('regionSiteId'), Units__c = (Decimal)entry.get('totalUnits'), SHOTHRS__c = (Decimal)entry.get('totalShotHrs'), REVENUE__c = (Decimal)entry.get('totalRevenue'), INVOICES__c = (Decimal)entry.get('totalInvoices'), DISTANCE__c = (Decimal)entry.get('totalDistance'),DELHRS__c = (Decimal)entry.get('totalDeliveryHours'), Current_Month__c=(Date)entry.get('currentMonth')));
            }
        }
        
        upsert entries;
        isRunning=false;
    }
    
    private static Cost_Driver_Entry__c allocateCOPA(Cost_Driver_Entry__c existing, AggregateResult amendments) {
        existing.UNITS__c += (Decimal)amendments.get('totalUnits');
        existing.SHOTHRS__c += (Decimal)amendments.get('totalShotHrs');
        existing.REVENUE__c += (Decimal)amendments.get('totalRevenue');
        existing.INVOICES__c += (Decimal)amendments.get('totalInvoices');
        existing.DISTANCE__c += (Decimal)amendments.get('totalDistance');
        existing.DELHRS__c += (Decimal)amendments.get('totalDeliveryHours');
        
        return existing;
    }
}