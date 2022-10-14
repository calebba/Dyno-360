public with sharing class MaterialMaster {
    public static CostData calculateCost(Id materialId, Id companyCode) {
        Material_Item__c testItem = [SELECT Product_Hierarchy__c, Material_Code__c FROM Material_Item__c WHERE Id = :materialId];
        //Non phl3 case
        AggregateResult costRes;
        if(testItem.Product_Hierarchy__c != testItem.Material_Code__c) {
            costRes = [Select AVG(Cost__c) averageCost, AVG(X3_Month_Cost__c) average3M, AVG(X6_Month_Cost__c) average6M from Material_Cost__c where Material_Item__c=:materialId and Sales_Site__r.Company_Site__c = :companyCode];
        } else { //PHL3 case
            costRes = [Select AVG(Cost__c) averageCost, AVG(X3_Month_Cost__c) average3M, AVG(X6_Month_Cost__c) average6M from Material_Cost__c where Material_Item__r.Product_Hierarchy__c =: testItem.Product_Hierarchy__c and Sales_Site__r.Company_Site__c = :companyCode GROUP BY Material_Item__r.Product_Hierarchy__c];
        }
        
        CostData data = new CostData();
        data.cost=(Decimal)costRes.get('averageCost');
        data.cost3m=(Decimal)costRes.get('average3M');
        data.cost6m=(Decimal)costRes.get('average6M');
        data.seeThroughCost = data.cost;
        data.seeThroughCost3m = data.cost3m;
        data.seeThroughCost6m = data.cost6m;
        
        return data;    
    }
    
    private static Map<Id, Material_Item__c> createItemsMap(List<Material_Item__c> materialDetails) {
        Map<Id, Material_Item__c> itemsMap = new Map<Id, Material_Item__c>();
        for(Material_Item__c matItem : materialDetails) {
            itemsMap.put(matItem.Id, matItem);
        }
        
        return itemsMap;
    }

    public static List<CostData> calculateCost(List<Id> materialIds, Id companyCode, Boolean fromQuickAdd, List<Material_Item__c> materialDetails) {
        List<AggregateResult> costRes = [Select AVG(Cost__c) averageCost, AVG(X3_Month_Cost__c) average3M, AVG(X6_Month_Cost__c) average6M, Material_Item__c from Material_Cost__c where Material_Item__c in :materialIds and Sales_Site__r.Company_Site__c = :companyCode GROUP BY Material_Item__c];
        //List<Material_Cost__c> itemRes =   [Select Material_Item__c, Material_Item__r.Id, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c from Material_Cost__c WHERE Material_Item__c in :materialIds];
        Map<Id, Material_Item__c> itemsMap = createItemsMap(materialDetails);
        List<CostData> toReturn = new List<CostData>();
        Set<Id> usedSet = new Set<Id>();
        for(AggregateResult ar : costRes) {
            CostData data = new CostData();
            data.cost=(Decimal)ar.get('averageCost');
            data.cost3m=(Decimal)ar.get('average3M');
            data.cost6m=(Decimal)ar.get('average6M');
            data.seeThroughCost = data.cost;
            data.seeThroughCost3m = data.cost3m;
            data.seeThroughCost6m = data.cost6m;
            data.materialId = (Id)ar.get('Material_Item__c');
            data.miRecord = itemsMap.get(data.materialId);
            usedSet.add(data.materialId);
            toReturn.add(data);
        }
        //Here we need to calculate average cost for the remaining material items (where they are phl3s)
        //We will do this by taking the average cost of everything in its hierarchy
        if(!fromQuickAdd) {
            Map<String, Id> phToId = new Map<String, Id>();
            List<String> phlsAvailable = new List<String>();
            for(Id currId : materialIds) {
                if(!usedSet.contains(currId) && itemsMap.get(currId).Material_Code__c == itemsMap.get(currId).Product_Hierarchy__c) {
                    phToId.put(itemsMap.get(currId).Product_Hierarchy__c, currId);
                    phlsAvailable.add(itemsMap.get(currId).Product_Hierarchy__c);
                }
            }
            
            //Need to do an impact analysis before pushing this change.
            String queryStr = 'Select AVG(Cost__c) averageCost, AVG(X3_Month_Cost__c) average3M, AVG(X6_Month_Cost__c) average6M, Material_Item__r.Product_Hierarchy__c ph from Material_Cost__c where Material_Item__r.Product_Hierarchy__c in :phlsAvailable and Sales_Site__r.Company_Site__c = :companyCode GROUP BY Material_Item__r.Product_Hierarchy__c';
            List<AggregateResult> costRes2 = Database.query(queryStr + ' LIMIT ' + (Limits.getLimitQueryRows()-Limits.getQueryRows()));
            for(AggregateResult ar : costRes2) {
                CostData data = new CostData();
                data.cost=(Decimal)ar.get('averageCost');
                data.cost3m=(Decimal)ar.get('average3M');
                data.cost6m=(Decimal)ar.get('average6M');
                data.seeThroughCost = data.cost;
                data.seeThroughCost3m = data.cost3m;
                data.seeThroughCost6m = data.cost6m;
                data.materialId = phToId.get((String)ar.get('ph'));
                data.miRecord = itemsMap.get(data.materialId);
                toReturn.add(data);     
            }       
            if(Limits.getLimitQueryRows()-Limits.getQueryRows() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Advanced_Add_Bad_PHL3));
            }               
        }
        return toReturn;    
    }
    
    public static CostData calculateCost(Id materialId, Id siteId, Id originSiteId) {
        CostData data = new CostData();
        try {
            Material_Cost__c cost = [Select Cost__c, X3_Month_Cost__c, X6_Month_Cost__c, BUn__c from Material_Cost__c where Material_Item__c=:materialId and Sales_Site__c =:siteId LIMIT 1];
            Supply_Chain_Assumption__c sca;
            try {               
                sca = [Select Fixed_Conversion_Cost__c, Variable_Conversion_Cost__c, Freight_Cost__c from Supply_Chain_Assumption__c where RecordTypeId = :[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Supply_Cost_Allocation'].Id and Material_Item__c = :materialId And Receiving_Sales_Site__c=:siteId and Source_Sales_Site__c=:originSiteId Limit 1];
                if (sca.Fixed_Conversion_Cost__c != null) {
                    data.cost = cost.Cost__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (cost.X3_Month_Cost__c != null)
                        data.cost3m = cost.X3_Month_Cost__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (cost.X6_Month_Cost__c != null)
                        data.cost6m = cost.X6_Month_Cost__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                } else if (sca.Variable_Conversion_Cost__c != null) {
                    data.cost = (cost.Cost__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (cost.X3_Month_Cost__c != null)
                        data.cost3m = (cost.X3_Month_Cost__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (cost.X6_Month_Cost__c != null)
                        data.cost6m = (cost.X6_Month_Cost__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                } else {
                    data.cost = cost.Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (cost.X3_Month_Cost__c != null)
                        data.cost3m = cost.X3_Month_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (cost.X6_Month_Cost__c != null)
                        data.cost6m = cost.X6_Month_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                }
            }
            catch (System.QueryException qe) {
                try {
                    sca = [Select Fixed_Conversion_Cost__c, Variable_Conversion_Cost__c, Freight_Cost__c, Gross_Margin__c from Supply_Chain_Assumption__c where RecordTypeId = :[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Transfer_Price'].Id and Material_Item__c = :materialId And Receiving_Sales_Site__c=:siteId and Source_Sales_Site__c=:originSiteId Limit 1];
                    if (sca.Fixed_Conversion_Cost__c != null) {
                        data.cost = cost.Cost__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        data.cost3m = cost.X3_Month_Cost__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        data.cost6m = cost.X6_Month_Cost__c + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                    } else if (sca.Variable_Conversion_Cost__c != null) {
                        data.cost = (cost.Cost__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        data.cost3m = (cost.X3_Month_Cost__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        data.cost6m = (cost.X6_Month_Cost__c * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                    } else {
                        data.cost = cost.Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                        if (cost.X3_Month_Cost__c != null)
                            data.cost3m = cost.X3_Month_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                        if (cost.X6_Month_Cost__c != null)
                            data.cost6m = cost.X6_Month_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    }
                }
                catch (System.QueryException qe2) {
                    data.cost = cost.Cost__c;
                    if (cost.X3_Month_Cost__c != null)
                        data.cost3m = cost.X3_Month_Cost__c;
                    if (cost.X6_Month_Cost__c != null)
                        data.cost6m = cost.X6_Month_Cost__c;
                }
            }
            data.uom = cost.BUn__c;
            data.cost = data.cost.stripTrailingZeros();
            if (data.cost3m != null)
                data.cost3m = data.cost3m.stripTrailingZeros();
            if (data.cost6m != null)
                data.cost6m = data.cost6m.stripTrailingZeros();
            data.seeThroughCost = cost.Cost__c.stripTrailingZeros();
            if (data.seeThroughCost3m != null)
                data.seeThroughCost3m = data.seeThroughCost3m.stripTrailingZeros();
            if (data.seeThroughCost6m != null)
                data.seeThroughCost6m = data.seeThroughCost6m.stripTrailingZeros();
        }
        catch (System.QueryException qe3) {
            throw new MaterialMasterException(System.Label.Material_No_Cost);
        }
        
        return data;
    }
    
    public static Map<Id, CostData> calculateCost(List<Material_Item__c> materials, Id siteId, Id originSiteId, Id companyCode, Boolean fromQuickAdd, List<Material_Item__c> materialDetails) {
        List<Material_Cost__c> costs = [SELECT Cost__c, X3_Month_Cost__c, X6_Month_Cost__c, BUn__c, Material_Item__c FROM Material_Cost__c WHERE Material_Item__c in :materials AND Sales_Site__c =:siteId];
        List<Supply_Chain_Assumption__c> scas = [SELECT Fixed_Conversion_Cost__c, Variable_Conversion_Cost__c, Freight_Cost__c, Material_Item__c from Supply_Chain_Assumption__c where RecordTypeId = :[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Supply_Cost_Allocation'].Id and Material_Item__c in :materials And Receiving_Sales_Site__c=:siteId and Source_Sales_Site__c=:originSiteId];
        List<Supply_Chain_Assumption__c> tps = [SELECT Fixed_Conversion_Cost__c, Variable_Conversion_Cost__c, Freight_Cost__c, Material_Item__c, Gross_Margin__c from Supply_Chain_Assumption__c where RecordTypeId = :[Select Id from RecordType where SobjectType='Supply_Chain_Assumption__c' and DeveloperName='Transfer_Price'].Id and Material_Item__c in :materials And Receiving_Sales_Site__c=:siteId and Source_Sales_Site__c=:originSiteId];
        Map<Id, Material_Item__c> itemsMap = createItemsMap(materialDetails);
        
        Map<Id, Supply_Chain_Assumption__c> scaMap = new Map<Id, Supply_Chain_Assumption__c>();
        for (Supply_Chain_Assumption__c sca : scas) {
            scaMap.put(sca.Material_Item__c, sca);
        }
        Map<Id, Supply_Chain_Assumption__c> tpMap = new Map<Id, Supply_Chain_Assumption__c>();
        for (Supply_Chain_Assumption__c tp : tps) {
            tpMap.put(tp.Material_Item__c, tp);
        }
        
        Map<Id, CostData> costDataMap = new Map<Id, CostData>();
        CostData data;
        Supply_Chain_Assumption__c sca;
        for (Material_Cost__c cost : costs) {
            data = new CostData();
            data.cost = cost.Cost__c;
            if (cost.X3_Month_Cost__c != null)
                data.cost3m = cost.X3_Month_Cost__c;
            if (cost.X6_Month_Cost__c != null)
                data.cost6m = cost.X6_Month_Cost__c;
            data.uom = cost.BUn__c;
            data.seeThroughCost = data.cost;
            data.seeThroughCost3m = data.cost3m;
            data.seeThroughCost6m = data.cost6m;
            data.materialId = cost.Material_Item__c;
            data.miRecord = itemsMap.get(data.materialId);
            data.extendedToSite = true;
            sca = scaMap.get((Id)cost.get('Material_Item__c'));
            if (sca != null) {
                if (sca.Fixed_Conversion_Cost__c != null) {
                    data.cost = data.cost + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (data.cost3m != null)
                        data.cost3m = data.cost3m + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (data.cost6m != null)
                        data.cost6m = data.cost6m + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                } else if (sca.Variable_Conversion_Cost__c != null) {
                    data.cost = (data.cost * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (data.cost3m != null)
                        data.cost3m = (data.cost3m * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (data.cost6m != null)
                        data.cost6m = (data.cost6m * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                } else {
                    data.cost = data.cost + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (data.cost3m != null)
                        data.cost3m = data.cost3m + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    if (data.cost6m != null)
                        data.cost6m = data.cost6m + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                }
            }
            else {
                sca = tpMap.get((Id)cost.get('Material_Item__c'));
                if (sca != null) {
                    if (sca.Fixed_Conversion_Cost__c != null) {
                        data.cost = data.cost + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        if (data.cost3m != null)
                            data.cost3m = data.cost3m + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        if (data.cost6m != null)
                            data.cost6m = data.cost6m + sca.Fixed_Conversion_Cost__c + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                    } else if (sca.Variable_Conversion_Cost__c != null) {
                        data.cost = (data.cost * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        if (data.cost3m != null)
                            data.cost3m = (data.cost3m * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                        if (data.cost6m != null)
                            data.cost6m = (data.cost6m * (1 + sca.Variable_Conversion_Cost__c)) + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c) + ((sca.Gross_Margin__c==null)?0.00:sca.Gross_Margin__c);
                    } else {
                        data.cost = data.cost + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                        if (data.cost3m != null)
                            data.cost3m = data.cost3m + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                        if (data.cost6m != null)
                            data.cost6m = data.cost6m + ((sca.Freight_Cost__c==null)?0.00:sca.Freight_Cost__c);
                    }
                }
            }
            costDataMap.put(cost.Material_Item__c, data);
        }
        
        System.debug('Cost map : ' + costDataMap);
        System.debug('Materials : ' + materials);
        
        // Find costs for materials not extended to site
        Set<Id> materialIdSet = new Set<Id>();
        for (Material_Item__c material : materials) {
            materialIdSet.add(material.Id);
        }
        materialIdSet.removeAll(costDataMap.keySet());
        List<Id> remaining = new List<Id>();
        for(Id currId : materialIdSet) {
            remaining.add(currId);
        }

        System.debug('Remaining : ' + remaining);

        if(companyCode != null) {
            List<CostData> cdList = MaterialMaster.calculateCost(remaining, companyCode, fromQuickAdd, materialDetails);
            System.debug('Siteless Cost Map size:' + cdList.size());
            for (CostData cd : cdList) {
                costDataMap.put(cd.materialId, cd);
            }
        }
        
        System.debug('Combined map size:' + costDataMap.keySet().size());
        
        return costDataMap;
    }
    
    public static Map<String, CostData> calculateCost(List<Id> materialIds, List<Id> salesSiteIds) {
        List<AggregateResult> costResults = [Select AVG(Cost__c) cost, AVG(X3_Month_Cost__c) cost3m, AVG(X6_Month_Cost__c) cost6m, Material_Item__c, Sales_Site__c from Material_Cost__c WHERE Material_Item__c in :materialIds AND Sales_Site__c in :salesSiteIds AND CreatedDate = LAST_N_DAYS:365 GROUP By Material_Item__c, Sales_Site__c, Sales_Site__r.Company_Site__c];
        List<Material_Item__c> itemRes =   [Select Id, Name, Material_Code__c, Material_Description__c, Preferred__c from Material_Item__c WHERE Id in :materialIds];
        Map<String, CostData> costDataMap = new Map<String, CostData>();
        CostData data;
        for (AggregateResult result : costResults) {
            data = new CostData();
            data.cost = (Decimal)result.get('cost');
            data.cost3m = (Decimal)result.get('cost3m');
            data.cost6m = (Decimal)result.get('cost6m');
            data.seeThroughCost = (Decimal)result.get('cost');
            data.seeThroughCost3m = (Decimal)result.get('cost3m');
            data.seeThroughCost6m = (Decimal)result.get('cost6m');
            for(Material_Item__c currMi : itemRes) {
                if((Id)result.get('Material_Item__c') == currMi.Id) {
                    data.miRecord = currMi;
                    data.materialId = currMi.Id;
                }
            }
            costDataMap.put((String)result.get('Material_Item__c')+'|'+(String)result.get('Sales_Site__c'), data);
        }
        
        return costDataMap;
    }
    
    // Retrieve the scalar value to convert between to UoMs for a given Material
    public static Double convertUoM(Id materialId, String sourceUoM, String targetUoM) {
        if (sourceUoM == targetUoM) {
            return 1;
        }
        try {
            Alternate_Unit_of_Measure__c uom = [Select X__c, Y__c from Alternate_Unit_of_Measure__c where BUn__c =:sourceUoM and AUn__c =:targetUoM and Material_Item__c = :materialId LIMIT 1];
            return (uom.X__c/uom.Y__c);
        }
        catch (System.QueryException qe) {
            try {
                Alternate_Unit_of_Measure__c uom = [Select X__c, Y__c from Alternate_Unit_of_Measure__c where AUn__c =:sourceUoM and BUn__c =:targetUoM and Material_Item__c = :materialId LIMIT 1];
                return (uom.Y__c/uom.X__c);
            }
            catch (System.QueryException qe2) {
                throw new MaterialMasterException(String.format(System.Label.MM + '{0}, {1}', new List<String>{sourceUoM, targetUoM}));
            }           
        }
    }
    
    // Retrieve the scalar value to convert between to UoMs for a given Material from a specific site
    public static Double convertUoM(Id materialId, Id siteId, String targetUoM) {
        // Find Base UoM from Material Cost
        String baseUnit = [Select BUn__c from Material_Cost__c where Material_Item__c=:materialId and Sales_Site__c=:siteId].BUn__c;
        
        return convertUoM(materialId, baseUnit, targetUoM);
    }
    
    public static Double convertPerAndUoM(Id materialId, Double sourcePer, String sourceUoM, Double targetPer, String targetUoM) {
        return convertUoM(materialId, sourceUoM, targetUoM) / (targetPer/sourcePer);
    }
    
    public static Double convertPerAndUoM(Id materialId, Double sourcePer, Id siteId, Double targetPer, String targetUoM) {
        return convertUoM(materialId, siteId, targetUoM) / (targetPer/sourcePer);
    }
    
    public class CostData {
        public Material_Item__c miRecord {get; set;}
        public Id materialId {get;set;}
        public Decimal seeThroughCost {get;set;}
        public Decimal seeThroughCost3m {get;set;}
        public Decimal seeThroughCost6m {get;set;}
        public Decimal cost {get;set;}
        public Decimal cost3m {get;set;}
        public Decimal cost6m {get;set;}
        public String uom {get; set;}
        public Boolean extendedToSite {get;set;}
    }
    
    public class MaterialMasterException extends Exception {}
   
}