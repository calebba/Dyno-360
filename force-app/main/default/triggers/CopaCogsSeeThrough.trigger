trigger CopaCogsSeeThrough on Copa__c (before insert, before update) {

    Set<Id> materialIds = new Set<Id>();
    Set<Id> siteIds = new Set<Id>();
    for (Copa__c copa : Trigger.new)
    {
        if (copa.Material_Item__c != null)
            materialIds.add(copa.Material_Item__c);
        if (copa.Sales_Site__c != null)
            siteIds.add(copa.Sales_Site__c);
    }

    List<Supply_Chain_Assumption__c> scas = [Select Fixed_Conversion_Cost__c, Variable_Conversion_Cost__c, Freight_Cost__c, Receiving_Sales_Site__c, Source_Sales_Site__c, Material_Item__c from Supply_Chain_Assumption__c where RecordTypeId = :[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Supply_Cost_Allocation'].Id and Material_Item__c in :materialIds And Receiving_Sales_Site__c in :siteIds And Source_Sales_Site__c in :siteIds];
    Map<String, Supply_Chain_Assumption__c> scasMap = new Map<String, Supply_Chain_Assumption__c>();
    for (Supply_Chain_Assumption__c sca : scas)
        if (sca.Receiving_Sales_Site__c == sca.Source_Sales_Site__c)
            scasMap.put(sca.Material_Item__c + '-' + sca.Receiving_Sales_Site__c, sca);

    List<Supply_Chain_Assumption__c> scas2 = [Select Fixed_Conversion_Cost__c, Variable_Conversion_Cost__c, Freight_Cost__c, Receiving_Sales_Site__c, Source_Sales_Site__c, Material_Item__c from Supply_Chain_Assumption__c where RecordTypeId = :[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Transfer_Price'].Id and Material_Item__c in :materialIds And Receiving_Sales_Site__c in :siteIds And Source_Sales_Site__c in :siteIds];
    Map<String, Supply_Chain_Assumption__c> scas2Map = new Map<String, Supply_Chain_Assumption__c>();
    for (Supply_Chain_Assumption__c sca2 : scas2)
        if (sca2.Receiving_Sales_Site__c == sca2.Source_Sales_Site__c)
            scasMap.put(sca2.Material_Item__c + '-' + sca2.Receiving_Sales_Site__c, sca2);

    for (Copa__c copa : Trigger.new) {
        Supply_Chain_Assumption__c sca = scasMap.get(copa.Material_Item__c + '-' + copa.Sales_Site__c);
        if (sca != null) {
            if (sca.Fixed_Conversion_Cost__c != null) {
                copa.COGS_See_Through__c = copa.True_Total_Cogs__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
            } else if (sca.Variable_Conversion_Cost__c != null) {
                copa.COGS_See_Through__c = (copa.True_Total_Cogs__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
            } else {
                copa.COGS_See_Through__c = copa.True_Total_Cogs__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
            }
        } else {
            sca = scas2Map.get(copa.Material_Item__c + '-' + copa.Sales_Site__c);
            if (sca != null) {
                if (sca.Fixed_Conversion_Cost__c != null) {
                    copa.COGS_See_Through__c = copa.True_Total_Cogs__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                } else if (sca.Variable_Conversion_Cost__c != null) {
                    copa.COGS_See_Through__c = (copa.True_Total_Cogs__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                } else {
                    copa.COGS_See_Through__c = copa.True_Total_Cogs__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                }
            } else {
                copa.COGS_See_Through__c = copa.True_Total_Cogs__c;
            }
        }
    }

}