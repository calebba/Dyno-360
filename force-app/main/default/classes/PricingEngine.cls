public with sharing class PricingEngine {
    public static PricingData getPricingData(Id customerId, Id originSiteId, Id salesSiteId, Id materialId, Date priceValidFrom, Date priceValidTo, Id companyCode, String customerGroup, String ScPricingRegion, String PricingSalesOffice) {
        // Search for the correct pricing rule
        //This appears to not be used anymore....see below for new method
        /*
        * Order of precedence:
        * TODO: Add Company Code logic
        * 1. Customer, Sales Site, Material, Correct Dates, Company Code
        * 2. Customer, Pricing Region, Material, Correct Dates, Company Code
        * 3. Sales Site, Material, Correct Dates, Company Code
        * 4. Customer, Material, Correct Dates, Company Code
        * 5. Pricing Region, Material, Correct Dates, Company Code
        * 6. Material, Correct Dates, Company Code
        */
        
        Pricing_Rule__c rule;
        List<Pricing_Rule__c> rules;
        //Id regionId = [Select Region_Site__c from Sales_Site__c where Id=:salesSiteId].Region_Site__c;
        
        String PricingRegion = String.isNotBlank(scPricingRegion) ? scPricingRegion : [SELECT Pricing_Region__c from Account Where id = :customerId].Pricing_Region__c;
        //String PricingRegion = [SELECT Pricing_Region__c from Account Where id = :customerId].Pricing_Region__c;
        
        system.debug('Pricing RegionA : ' + PricingRegion);
        
        Date currentDate = System.today();
        if(customerGroup != null) {
            if(customerGroup.contains('01')) {
                customerGroup = '01%';
            } else if(customerGroup.contains('02')) {
                customerGroup = '02%';
            }
        }
        
        // Ensure that the material is not marked for deletion
        if (0 == [SELECT COUNT() FROM Material_Item__c WHERE Id=:materialId AND Flag_for_Deletion__c=FALSE]){
            throw new PricingEngineException(System.Label.Pricing_Engine_Material_Not_Available);
        }
         // Ensure that the pricing rule for the material exists
        if ( 0 == [SELECT COUNT() FROM Pricing_Rule__c WHERE Pricing_Sales_Office__c=:PricingSalesOffice AND Material_Item__c =:materialId AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup]){
            throw new PricingEngineException(System.Label.Pricing_Engine_No_Pricing_Rule);
    	}
        
        // 0. Pricing sales office, , Material, Correct Dates, Company Code, cstomer group
        rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c, Pricing_Sales_Office__c FROM Pricing_Rule__c WHERE Pricing_Sales_Office__c=:PricingSalesOffice AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
        if(rules.size() > 0) {
	        rule = findClosest(rules);
        	system.debug('Used 0' + rule);
            system.debug('Pricing Sales office ' + PricingSalesOffice+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
        
        }else{
        	// 1. Customer, Sales Site, Material, Correct Dates, Company Code
        	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c FROM Pricing_Rule__c WHERE Account__c=:customerId AND Receiving_Sales_Site__c=:salesSiteId AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
        	if(rules.size() > 0) {
            	rule = findClosest(rules);
                 system.debug('Used 1');
                system.debug('Customer ' + customerId +' '+ 'Sales Site ' + salesSiteId+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
        	} else {
            	// 2. Customer, Pricing Region, Material, Correct Dates, Company Code
            	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c, Pricing_Region__c FROM Pricing_Rule__c WHERE Account__c=:customerId AND Pricing_Region__c=:PricingRegion  AND Receiving_Sales_Site__c = null AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];  //Region_Site__c=:regionId
            	if(rules.size() > 0) {
                	rule = findClosest(rules);
                     system.debug('Used 2' + rule);
                     system.debug('Customer ' + customerId +' '+ 'Pricing Region ' + PricingRegion+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
            	} else {
                	// 3. Sales Site, Material, Correct Dates, Company Code
                	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c FROM Pricing_Rule__c WHERE Receiving_Sales_Site__c=:salesSiteId AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
                	if(rules.size() > 0) {
                    	rule = findClosest(rules);
                         system.debug('Used 3' + rule);
                         system.debug('Sales Site ' + salesSiteId+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                	} else {
                    	// 4. Customer, Material, Correct Dates, Company Code
                    	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c FROM Pricing_Rule__c WHERE Account__c=:customerId AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
                    	if(rules.size() > 0) {
                        	rule = findClosest(rules);
                            system.debug('Used 4' + rule);
                            system.debug('Customer ' + customerId +' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                    	} else {
                        	// 5. Pricing Region, Material, Correct Dates, Company Code
                        	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c, Pricing_Region__c FROM Pricing_Rule__c WHERE Pricing_Region__c=:PricingRegion AND Receiving_Sales_Site__c = null AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
                        	if(rules.size() > 0) {
                            	rule = findClosest(rules);
                                system.debug('Used 5' + rule + 'Sales office' + PricingSalesOffice);
                                system.debug('For Condition 5 :'+'Pricing Region ' + PricingRegion+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                                system.debug('For Condition 1 :'+'Customer ' + customerId +' '+ 'Sales Site ' + salesSiteId+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                                system.debug('For Condition 2 :'+'Customer ' + customerId +' '+ 'Pricing Region ' + PricingRegion+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                                system.debug('For Condition 3 :'+'Sales Site ' + salesSiteId+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                                system.debug('For Condition 4 :'+'Customer ' + customerId +' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                                system.debug('For Condition 4 :'+'Pricing Sales office ' + PricingSalesOffice+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
                            	} else {
	                        	// 6. Pricing Sales Office, Material, Correct Dates, Company Code
	                        	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c, Pricing_Sales_Office__c FROM Pricing_Rule__c WHERE Pricing_Sales_Office__c=:PricingSalesOffice AND Receiving_Sales_Site__c = null AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
	                        	if(rules.size() > 0) {
	                            	rule = findClosest(rules);
                                    system.debug('Used 6' + rule);
                                    system.debug('Pricing Sales office ' + PricingSalesOffice+' '+ 'Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
	                        	} else {
	                            	rules = [SELECT Price_Valid_To__c, Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c FROM Pricing_Rule__c WHERE Pricing_Sales_Office__c = null AND Pricing_Region__c = null AND Receiving_Sales_Site__c = null AND Account__c = null AND Material_Item__c =:materialId AND Price_Valid_To__c >= :currentDate AND Company_Code__c=:companyCode AND Customer_Group__c like :customerGroup AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))];
	                            	if(rules.size() > 0) {
	                                	rule = findClosest(rules);
                                        system.debug('Used else' + rule);
                                         system.debug('Material ' + materialId+' '+ 'Price Valid from ' + priceValidFrom +' '+ 'Company Code ' + companyCode +' '+'Customer Group '+ customerGroup);
	                            	} else {
	                                	throw new PricingEngineException(System.Label.Pricing_Engine_No_Pricing_Rule);
	                            	}
	                        	}
                        	}
                    	}
                	}
            	}
                
            	}
        	}
       
        // Get cost data
        MaterialMaster.CostData costData;
        try {
            costData = MaterialMaster.calculateCost(materialId, salesSiteId, originSiteId);
        }
        catch (MaterialMaster.MaterialMasterException me) {
            // Cost is not extended to site, get average cost;
            costData = MaterialMaster.calculateCost(materialId, companyCode);
        }
        
        // Calculate average sales price
        //AggregateResult res = [Select AVG(Actual_Price__c) averagePrice from Quote_Line_Item__c where Material_Item__c =:materialId AND Sales_Site__r.Region_Site__c = :regionId AND Quote__r.CreatedDate = LAST_N_DAYS:365];
        PricingData data = new PricingData(rule, costData);
        data.averageSalesPrice = 0.00;//(Decimal)res.get('averagePrice');
       
        return data; 
    }
    
    private static Pricing_Rule__c findClosest(List<Pricing_Rule__c> prList) {
        if(prList.size() == 1) {
            return prList.get(0);
        }
        Pricing_Rule__c minRule = prList.get(0);
        System.debug('Pricing Rule List '+ minRule);
        Date todaysDate = System.today();
        Integer min = 100000;
        for(Pricing_Rule__c pr : prList) {
            if(pr.Price_Valid_From__c <= todaysDate && pr.Price_Valid_From__c.daysBetween(todaysDate) < min) {
                min = pr.Price_Valid_From__c.daysBetween(todaysDate);
                minRule = pr;
            }
        }
        
        System.debug('Pricing Rule List Later '+ minRule);
        return minRule;
    }
    

    
    public static List<PricingData> getPricingData(Id companyCodeId, Id accountId, Id salesSiteId, Id materialId, Id regionId, String customerGroup) {
        String query = 'SELECT Company_Code__c, UoM__c, Customer_Group__c, Material_Item__r.Name, Material_Item__r.Material_Description__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Preferred__c, Material_Item__r.Material_Code__c, Receiving_Sales_Site__r.Name, Floor_Price__c, Target_Price__c, Price_Valid_From__c, Price_Valid_To__c, Region_Site__c, Per__c, CurrencyIsoCode FROM Pricing_Rule__c Where Material_Item__c =:  materialId';
        
        if(accountId != null) {
            query += ' AND Account__c = :accountId';
        }
        if(salesSiteId != null) {
            query += ' AND Receiving_Sales_Site__c = :salesSiteId';
        }
        if(regionId != null) {
            query += ' AND Region_Site__c = :regionId';
        }
        if(companyCodeId != null) {
            query += ' AND Company_Code__c = :companyCodeId';
        }
        if(customerGroup != null || (customerGroup != null && customerGroup.trim() != '')) {
            String fakeCustGroup = '';
            if(customerGroup.contains('01')) {
                fakeCustGroup = '01%';
            } else if(customerGroup.contains('02')) {
                fakeCustGroup = '02%';
            }
            query += ' AND Customer_Group__c like \'' + fakeCustGroup + '\'';   
        }
        System.debug('Query: ' + query);
        List<Pricing_Rule__c> rules = Database.query(query);
        List<Material_Item__c> materials = new List<Material_Item__c>();
        
        for (Pricing_Rule__c rule : rules) {
            materials.add(new Material_Item__c(Id=rule.Material_Item__c, Name=rule.Material_Item__r.Name, Material_Code__c=rule.Material_Item__r.Material_Code__c, Material_Description__c=rule.Material_Item__r.Material_Description__c, Product_Hierarchy__c=rule.Material_Item__r.Product_Hierarchy__c,Preferred__c=rule.Material_Item__r.Preferred__c));
        }
        // Calculate average sales price
        /*List<AggregateResult> results = [Select Material_Item__c, AVG(Actual_Price__c) averagePrice from Quote_Line_Item__c where Material_Item__c in :materials AND Quote__r.CreatedDate = LAST_N_DAYS:365 GROUP BY Material_Item__c];
        Map<Id, Decimal> avgSalesPriceMap = new Map<Id, Decimal>(); 
        for (AggregateResult result : results) {
            avgSalesPriceMap.put((Id)result.get('Material_Item__c'), (Decimal)result.get('averagePrice'));
        }*/
        Map<Id, MaterialMaster.CostData> costDataMap = MaterialMaster.calculateCost(materials, salesSiteId, null, companyCodeId, true, materials);
        List<PricingData> dataList = new List<PricingData>();
        PricingData data;
        for (Pricing_Rule__c rule : rules) {
            data = new PricingData(rule, costDataMap.get(rule.Material_Item__c));
            data.averageSalesPrice = 0.00;//avgSalesPriceMap.get(rule.Material_Item__c);
            dataList.add(data);
        }
        
        return dataList;        
    }
	//this the newest getPricingData method form quoteutil.clonestandardsli  (RPN 11/09/2013)
    public static List<PricingData> getPricingData(Id customerId, Id salesSiteId, List<Id> materialIds, Date priceValidFrom, Date priceValidTo, Id companyCode, Set<Id> ignoreIds, String customerGroup, Boolean calculateCost, List<Material_Item__c> materialDetails, Id originSiteId, boolean fromQuickAdd, String scPricingRegion, String pricingSalesOffice) {
        List<Pricing_Rule__c> rules = new List<Pricing_Rule__c>();
        //below line commented out so one less soql call in loop
        //Id regionId = [Select Region_Site__c from Sales_Site__c where Id=:salesSiteId].Region_Site__c;
        
        //String PricingRegion = [SELECT Pricing_Region__c from Account Where id = :customerId].Pricing_Region__c;
        String PricingRegion = String.isNotBlank(scPricingRegion) ? scPricingRegion : [SELECT Pricing_Region__c from Account Where id = :customerId].Pricing_Region__c;
        
        system.debug('Pricing Region:C ' + PricingRegion);
                
        Set<Id> materialRejectionList = new Set<Id>();
        if(ignoreIds != null) {
            materialRejectionList = ignoreIds;
        }
        
        Date currentDate = System.today();
        if(customerGroup != null) {
            if(customerGroup.contains('01')) {
                customerGroup = '01%';
            } else if(customerGroup.contains('02')) {
                customerGroup = '02%';
            }
        }
        //Removing 11/10/2010 AND Price_Valid_From__c <= :currentDate 
        String query = 'SELECT Price_Valid_From__c, Floor_Price__c, Target_Price__c, Per__c, UoM__c, Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Preferred__c, Receiving_Sales_Site__c, Account__c, Pricing_Region__c FROM Pricing_Rule__c WHERE Material_Item__r.Flag_For_Deletion__c=FALSE AND Material_Item__c in :materialIds';
        // RPN comment out Dec 3 2012 and use new string below ---- query += ' AND Price_Valid_To__c >= :currentDate AND Customer_Group__c like :customerGroup AND Material_Item__c not in :materialRejectionList AND Company_Code__c=:companyCode AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom) Or (Price_Valid_From__c > :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))';
        query += ' AND Price_Valid_To__c >= :currentDate AND Customer_Group__c like :customerGroup AND Material_Item__c not in :materialRejectionList AND Company_Code__c=:companyCode AND ((Price_Valid_From__c <= :priceValidFrom AND Price_Valid_To__c >= :priceValidFrom))';
        
        // 0. Customer, Sales Site, Material, Correct Dates, Company Code
        rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Account__c=:customerId AND Receiving_Sales_Site__c=:salesSiteId order by Price_Valid_From__c asc'));
        for(Pricing_Rule__c pr : rules) {
            system.debug('Start 0:');
            materialRejectionList.add(pr.Material_Item__c);
        }
        if (rules.size() < materialIds.size()) {
	       // 1. Pricing Sales Office, Material, Correct Dates, Company Code
	       rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Pricing_Sales_Office__c=:pricingSalesOffice order by Price_Valid_From__c asc'));
	       for(Pricing_Rule__c pr : rules) {
               system.debug('Start 1:');
	       materialRejectionList.add(pr.Material_Item__c);
	       } 
        if (rules.size() < materialIds.size()) {
            // 2. Customer, Pricing Region, Material, Correct Dates, Company Code
            rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Account__c=:customerId AND Pricing_Region__c=:PricingRegion AND Receiving_Sales_Site__c = null order by Price_Valid_From__c asc'));
            for(Pricing_Rule__c pr : rules) {
                system.debug('Start 2:');
                materialRejectionList.add(pr.Material_Item__c);
            }
                              
            if (rules.size() < materialIds.size()) {
                // 3. Sales Site, Material, Correct Dates, Company Code
                rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Receiving_Sales_Site__c=:salesSiteId order by Price_Valid_From__c asc'));
                for(Pricing_Rule__c pr : rules) {
                    system.debug('Start 2:');
                    materialRejectionList.add(pr.Material_Item__c);
                }
                if (rules.size() < materialIds.size()) {
                    // 4. Customer, Material, Correct Dates, Company Code
                    rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Account__c=:customerId order by Price_Valid_From__c asc'));
                    for(Pricing_Rule__c pr : rules) {
                        system.debug('Start 4:');
                        materialRejectionList.add(pr.Material_Item__c);
                    }   
                    if (rules.size() < materialIds.size()) {
                        // 5. Pricing Region, Material, Correct Dates, Company Code
                        rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Pricing_Region__c=:PricingRegion AND Receiving_Sales_Site__c = null order by Price_Valid_From__c asc'));
                        for(Pricing_Rule__c pr : rules) {
                            system.debug('Start 5:');
                            materialRejectionList.add(pr.Material_Item__c);
                        }               
                        if (rules.size() < materialIds.size()) {
	                        // 6. Pricing Sales Office, Material, Correct Dates, Company Code
	                        rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Pricing_Sales_Office__c=:pricingSalesOffice AND Receiving_Sales_Site__c = null order by Price_Valid_From__c asc'));
	                        for(Pricing_Rule__c pr : rules) {
                                system.debug('Start 6:');
	                            materialRejectionList.add(pr.Material_Item__c);
	                        }               
	                        if (rules.size() < materialIds.size()) {
                                system.debug('Start 7:');
	                            rules.addAll((List<Pricing_Rule__c>)Database.query(query + ' AND Pricing_Sales_Office__c = null AND Pricing_Region__c = null AND Receiving_Sales_Site__c = null AND Account__c = null order by Price_Valid_From__c asc'));
	                        }
                        }
                    }
                        
                }
                }
            }
        }
        
        // Calculate average sales price

        List<PricingData> dataList = new List<PricingData>();
        PricingData data;
        if(calculateCost) {
            List<Material_Item__c> materials = new List<Material_Item__c>();
            for (Id materialId : materialIds) {
                materials.add(new Material_Item__c(Id=materialId));
            }
            Map<Id, MaterialMaster.CostData> costDataMap = MaterialMaster.calculateCost(materials, salesSiteId, originSiteId, companyCode, fromQuickAdd, materialDetails);          
            /*List<AggregateResult> results = [Select Material_Item__c, AVG(Actual_Price__c) averagePrice from Quote_Line_Item__c where Material_Item__c in :materials AND Sales_Site__r.Region_Site__c = :regionId AND Quote__r.CreatedDate = LAST_N_DAYS:365 GROUP BY Material_Item__c];
            Map<Id, Decimal> avgSalesPriceMap = new Map<Id, Decimal>(); 
            for (AggregateResult result : results) {
                avgSalesPriceMap.put((Id)result.get('Material_Item__c'), (Decimal)result.get('averagePrice'));
            }*/
            for (Pricing_Rule__c rule : rules) {
            	system.debug('tttest1: ');
                data = new PricingData(rule, costDataMap.get(rule.Material_Item__c));
                data.averageSalesPrice = 0.00;//avgSalesPriceMap.get(rule.Material_Item__c);
                dataList.add(data);
            }                       
        } else {
            for (Pricing_Rule__c rule : rules) {
            	system.debug('tttest2: ');
                data = new PricingData(rule, null);
                dataList.add(data);
            }           
        }
        
        system.debug('tttest3: ' + dataList.size());
        return dataList;
    }
    
    public static List<PricingData> getPricingData(Id customerId, Id salesSiteId, String PHL1, Boolean includeUnextendedMaterials, Date priceValidFrom, Date priceValidTo, Id companyCode, Boolean fromQuickAdd, String customerGroup, Id originSiteId, String phl2, String phl3, CurrencyData theLimit, String scPricingRegion, String pricingSalesOffice) {
        // Search for the correct pricing rule
        /*
        * Order of precedence:
        * 1. Customer, Sales Site, Material, Correct Dates, Company Code
        * 2. Customer, Region, Material, Correct Dates, Company Code
        * 3. Sales Site, Material, Correct Dates, Company Code
        * 4. Customer, Material, Correct Dates, Company Code
        * 5. Region, Material, Correct Dates, Company Code
        * 6. Pricing Sales Office, Material, Correct Dates, Company Code
        */
        
        List<PricingData> rules = new List<PricingData>();
        List<PricingData> rules2 = new List<PricingData>();
        
        //String query;
        List<Material_Item__c> materials = new List<Material_Item__c>();
        List<Material_Item__c> materials2 =  new List<Material_Item__c>();
        List<Id> materialId = new List<Id>();
        List<Id> materialId2 = new List<Id>();      
        
        String baseQuery1 = 'SELECT Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Material_Description__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Preferred__c from Material_Cost__c';
        String baseQuery2 = 'SELECT Id, Name, Material_Code__c, Material_Description__c, Product_Hierarchy__c, Preferred__c from Material_Item__c';
        List<Material_Cost__c> theMcList = new List<Material_Cost__c>();
        if(phl2 != '--None--' && phl3 != '--None--') {
            String additionalQuery = theLimit.value >= 0 ? ' LIMIT ' + theLimit.value.format().replaceAll(',','') : '';
            theMcList = Database.query(baseQuery1 + ' where Material_Item__r.PHL1__c=:PHL1 AND Material_Item__r.PHL2__c=:phl2 AND Material_Item__r.PHL3__c=:phl3 AND Flag_For_Deletion__c=FALSE AND Sales_Site__c=:salesSiteId AND Material_Item__r.Flag_For_Deletion__c=FALSE' + additionalQuery);
            for (Material_Cost__c cost : theMcList) {
                materials2.add(new Material_Item__c(Id=cost.Material_Item__c, Name=cost.Material_Item__r.Name, Material_Code__c=cost.Material_Item__r.Material_Code__c, Material_Description__c=cost.Material_Item__r.Material_Description__c,Product_Hierarchy__c=cost.Material_Item__r.Product_Hierarchy__c,Preferred__c=cost.Material_Item__r.Preferred__c));
                materialId2.add(cost.Material_Item__c);
            }
            theLimit.value -= materialId2.size();
            if (includeUnextendedMaterials) {
                additionalQuery = theLimit.value >= 0 ? ' LIMIT ' + theLimit.value.format().replaceAll(',','') : '';
                materials = Database.query(baseQuery2 + ' where PHL1__c=:PHL1 AND PHL2__c=:phl2 AND PHL3__c=:phl3 AND Flag_For_Deletion__c=FALSE And Id not in :materialId2' + additionalQuery);
                for(Material_Item__c mi : materials) {
                    materialId.add(mi.Id);
                }
                theLimit.value -= materialId.size();
            }
        } else if(phl2 != '--None--') {
            String additionalQuery = theLimit.value >= 0 ? ' LIMIT ' + theLimit.value.format().replaceAll(',','') : '';
            theMcList = Database.query(baseQuery1 + ' where Material_Item__r.PHL1__c=:PHL1 AND Material_Item__r.PHL2__c=:phl2 AND Flag_For_Deletion__c=FALSE AND Sales_Site__c=:salesSiteId AND Material_Item__r.Flag_For_Deletion__c=FALSE' + additionalQuery);
            for (Material_Cost__c cost : theMcList) {
                materials2.add(new Material_Item__c(Id=cost.Material_Item__c, Name=cost.Material_Item__r.Name, Material_Code__c=cost.Material_Item__r.Material_Code__c, Material_Description__c=cost.Material_Item__r.Material_Description__c,Product_Hierarchy__c=cost.Material_Item__r.Product_Hierarchy__c,Preferred__c=cost.Material_Item__r.Preferred__c));
                materialId2.add(cost.Material_Item__c);
            }
            theLimit.value -= materialId2.size();
            if (includeUnextendedMaterials) {
                additionalQuery = theLimit.value >= 0 ? ' LIMIT ' + theLimit.value.format().replaceAll(',','') : '';
                materials = Database.query(baseQuery2 + ' where PHL1__c=:PHL1 AND PHL2__c=:phl2 AND Flag_For_Deletion__c=FALSE And Id not in :materialId2' + additionalQuery);
                for(Material_Item__c mi : materials) {
                    materialId.add(mi.Id);
                }
                theLimit.value -= materialId.size();
            }       
        } else {
            String additionalQuery = theLimit.value >= 0 ? ' LIMIT ' + theLimit.value.format().replaceAll(',','') : '';
            System.Debug('Lucian Debug: PHL1: ' + PHL1);
            System.Debug('Lucian Debug: salesSiteId: ' + salesSiteId);
            theMcList = Database.query(baseQuery1 + ' where Material_Item__r.PHL1__c=:PHL1 AND Flag_For_Deletion__c=FALSE AND Sales_Site__c=:salesSiteId AND Material_Item__r.Flag_For_Deletion__c=FALSE' + additionalQuery);
            for (Material_Cost__c cost : theMcList) {
                materials2.add(new Material_Item__c(Id=cost.Material_Item__c, Name=cost.Material_Item__r.Name, Material_Code__c=cost.Material_Item__r.Material_Code__c, Material_Description__c=cost.Material_Item__r.Material_Description__c,Product_Hierarchy__c=cost.Material_Item__r.Product_Hierarchy__c,Preferred__c=cost.Material_Item__r.Preferred__c));
                materialId2.add(cost.Material_Item__c);
            }
            theLimit.value -= materialId2.size();
            if (includeUnextendedMaterials) {
                additionalQuery = theLimit.value >= 0 ? ' LIMIT ' + theLimit.value.format().replaceAll(',','') : '';
                materials = Database.query(baseQuery2 + ' where PHL1__c=:PHL1 AND Flag_For_Deletion__c=FALSE And Id not in :materialId2' + additionalQuery);
                for(Material_Item__c mi : materials) {
                    materialId.add(mi.Id);
                }
                theLimit.value -= materialId.size();
            }                   
        }
        System.Debug('Lucian Debug: Number Of materials2:' + materials2.size());
        Id regionId = [Select Region_Site__c from Sales_Site__c where Id=:salesSiteId].Region_Site__c;
        materials.addAll(materials2);
        rules = getPricingData(customerId, salesSiteId, materialId2, priceValidFrom, priceValidTo, companyCode, null, customerGroup, false, materials2, originSiteId, fromQuickAdd, scPricingRegion, pricingSalesOffice);
        //Strip material items off the materials
        Set<Id> currentIds = new Set<Id>();
        for(PricingData pd : rules) {
            currentIds.add(pd.rule.Material_Item__c);
        }
        //pass in to a new pricingdata method
        if(materialId.size() > 0) {
            rules2 = getPricingData(customerId, salesSiteId, materialId, priceValidFrom, priceValidTo, companyCode, currentIds, customerGroup, false, materials, originSiteId, fromQuickAdd, scPricingRegion, pricingSalesOffice);
            rules.addAll(rules2);
        }
        /* Post processing to remove extraneous entries and sort the list */
        Map<Id, PricingData> pricingMap = new Map<Id, PricingData>();
        Map<Id, Date> idToDate = new Map<Id, Date>();
        Map<Id, Id> parallelMap = new Map<Id, Id>();
        Map<String, PricingData> sortMap = new Map<String, PricingData>();      
        for(PricingData pd : rules) {
            pricingMap.put(pd.rule.Id, pd);
            sortMap.put(pd.rule.Material_Item__r.Material_Description__c + '|' + pd.rule.Material_Item__c, pd);
            if(!idToDate.containsKey(pd.rule.Material_Item__c)) {
                idToDate.put(pd.rule.Material_Item__c, pd.rule.Price_Valid_From__c);
                parallelMap.put(pd.rule.Material_Item__c, pd.rule.Id);
            } else if(idToDate.containsKey(pd.rule.Material_Item__c) && pd.rule.Price_Valid_From__c > idToDate.get(pd.rule.Material_Item__c)) {
                idToDate.put(pd.rule.Material_Item__c, pd.rule.Price_Valid_From__c);
                parallelMap.put(pd.rule.Material_Item__c, pd.rule.Id);
            }           
        }

        rules.clear();

        List<String> sortList = new List<String>();
        for(Id theId : idToDate.keySet()) {
            sortList.add(pricingMap.get(parallelMap.get(theId)).rule.Material_Item__r.Material_Description__c + '|' + pricingMap.get(parallelMap.get(theId)).rule.Material_Item__c);
        }
        
        sortList.sort();
        
        List<Material_Item__c> filteredMaterialList = new List<Material_Item__c>();
        for(String currCode : sortList) {
            filteredMaterialList.add(new Material_Item__c(Id=sortMap.get(currCode).rule.Material_Item__c, Name=sortMap.get(currCode).rule.Material_Item__r.Name, Material_Code__c=sortMap.get(currCode).rule.Material_Item__r.Material_Code__c, Material_Description__c=sortMap.get(currCode).rule.Material_Item__r.Material_Description__c, Product_Hierarchy__c=sortMap.get(currCode).rule.Material_Item__r.Product_Hierarchy__c, Preferred__c=sortMap.get(currCode).rule.Material_Item__r.Preferred__c));
            rules.add(sortMap.get(currCode));
        }
        
        //This is the final list of rules narrowed down as much as possible.
        //To minimize # of queries, this is the list we want to get cost for.
        /*List<AggregateResult> results = [Select Material_Item__c, AVG(Actual_Price__c) averagePrice from Quote_Line_Item__c where Material_Item__c in :materials AND Sales_Site__r.Region_Site__c = :regionId AND Quote__r.CreatedDate = LAST_N_DAYS:365 GROUP BY Material_Item__c];
        Map<Id, Decimal> avgSalesPriceMap = new Map<Id, Decimal>(); 
        for (AggregateResult result : results) {
            avgSalesPriceMap.put((Id)result.get('Material_Item__c'), (Decimal)result.get('averagePrice'));
        }*/
        
        Map<Id, MaterialMaster.CostData> costDataMap = MaterialMaster.calculateCost(filteredMaterialList, salesSiteId, originSiteId, companyCode, fromQuickAdd, filteredMaterialList);
        for(PricingData pd : rules) {
            pd.costData = costDataMap.get(pd.rule.Material_Item__c);
            pd.averageSalesPrice = 0.00;//avgSalesPriceMap.get(pd.rule.Material_Item__c);
        }
        system.debug('Thus 2');
        return rules;
    }
    
    public static List<PricingData> getPricingData(List<Pricing_Rule__c> rules) {
        List<PricingData> dataList = new List<PricingData>();
        
        List<Id> materialIds = new List<Id>();
        List<Id> salesSiteIds = new List<Id>();
        for (Pricing_Rule__c rule : rules) {
            materialIds.add(rule.Material_Item__c);
            salesSiteIds.add(rule.Receiving_Sales_Site__c);
        }
        
        // Calculate average sales price
        /*List<AggregateResult> results = [Select Material_Item__c, AVG(Actual_Price__c) averagePrice from Quote_Line_Item__c where Material_Item__c in :materialIds AND Quote__r.CreatedDate = LAST_N_DAYS:365 GROUP BY Material_Item__c];
        Map<Id, Decimal> avgSalesPriceMap = new Map<Id, Decimal>(); 
        for (AggregateResult result : results) {
            avgSalesPriceMap.put((Id)result.get('Material_Item__c'), (Decimal)result.get('averagePrice'));
        }*/
        
        Map<String, MaterialMaster.CostData> costDataMap = MaterialMaster.calculateCost(materialIds, salesSiteIds);
        
        PricingData data;
        for (Pricing_Rule__c rule : rules) {
            data = new PricingData(rule, costDataMap.get(rule.Material_Item__c+'|'+rule.Receiving_Sales_Site__c));
            data.averageSalesPrice = 0.00;//avgSalesPriceMap.get(rule.Material_Item__c);
            dataList.add(data);
        }
        
        return dataList;
    }
    
    public static List<FormulaPricingData> getFormulaPricingData(Id customerId, Id salesSiteId, Id sourceSalesSiteId) {
        List<Formula_Mapping__c> mappings = [Select f.UoM__c, f.Per__c, f.Formula__r.Formula_Text__c, f.Formula__r.Material_Item__c, f.Formula__r.Material_Item__r.Name, f.Formula__r.Material_Item__r.Material_Code__c, f.Formula__r.Material_Item__r.Product_Hierarchy__c, f.Formula__r.Material_Item__r.Material_Description__c, f.Formula__r.Material_Item__r.Preferred__c, f.Formula__c, f.Sales_Site__c From Formula_Mapping__c f where f.Customer__c =:customerId And f.Sales_Site__c =:salesSiteId And f.Source_Sales_Site__c=:sourceSalesSiteId];
        List<Material_Item__c> materials = new List<Material_Item__c>();
        for (Formula_Mapping__c mapping : mappings) {
            materials.add(new Material_Item__c(Id=mapping.Formula__r.Material_Item__c, Material_Code__c=mapping.Formula__r.Material_Item__r.Material_Code__c, Material_Description__c=mapping.Formula__r.Material_Item__r.Material_Description__c, Product_Hierarchy__c=mapping.Formula__r.Material_Item__r.Product_Hierarchy__c, Preferred__c=mapping.Formula__r.Material_Item__r.Preferred__c));
        }
        
        Map<Id, MaterialMaster.CostData> costDataMap = MaterialMaster.calculateCost(materials, salesSiteId, sourceSalesSiteId, [SELECT Company_Site__c FROM Sales_Site__c WHERE Id = :salesSiteId].Company_Site__c, true, materials);
        
        List<FormulaPricingData> data = new List<FormulaPricingData>();
        
        for (Formula_Mapping__c mapping : mappings) {
            data.add(new FormulaPricingData(mapping, costDataMap.get(mapping.Formula__r.Material_Item__c)));
        }
        
        return data;
    }
    
    public static FormulaPricingData getFormulaPricingData(Id customerId, Id salesSiteId, Id sourceSalesSiteId, Id materialId) {
        Formula_Mapping__c mapping = [Select f.UoM__c, f.Per__c, f.Formula__r.Formula_Text__c, f.Formula__r.Material_Item__c, f.Formula__r.Material_Item__r.Name, f.Formula__r.Material_Item__r.Material_Code__c, f.Formula__r.Material_Item__r.Product_Hierarchy__c, f.Formula__r.Material_Item__r.Material_Description__c, f.Formula__r.Material_Item__r.Preferred__c, f.Formula__c, f.Sales_Site__c From Formula_Mapping__c f where f.Customer__c =:customerId And f.Sales_Site__c =:salesSiteId And f.Source_Sales_Site__c=:sourceSalesSiteId and f.Formula__r.Material_Item__c=:materialId];
        
        MaterialMaster.CostData costData = MaterialMaster.calculateCost(materialId, salesSiteId, sourceSalesSiteId);
        
        List<FormulaPricingData> data = new List<FormulaPricingData>();
        
        return new FormulaPricingData(mapping, costData);
    }
    
    public class PricingData {
        public Id materialId {get;set;}
        public Decimal floorPrice {get;set;}
        public Decimal targetPrice {get;set;}
        public Decimal averageSalesPrice {get; set;}
        public MaterialMaster.CostData costData {get;set;}
        public Integer per {get;set;}
        public String uom {get;set;}
        public Pricing_Rule__c rule {get;set;}
        
        public PricingData(Pricing_Rule__c rule, MaterialMaster.CostData costData) {
            this.materialId = rule.Material_Item__c;
            this.floorPrice = rule.Floor_Price__c;
            this.targetPrice = rule.Target_Price__c;
            if(costData != null) {
                this.costData = costData;
            }
            if(rule.Per__c != null) {
                this.per = rule.Per__c.intValue();
            }
            this.uom = rule.UoM__c;
            this.rule = rule;
        }
    }
    
    public class FormulaPricingData {
        public Id materialId {get; set;}
        public String materialCode;
        public Formula_Mapping__c mapping;
        public Decimal actualPrice;
        public MaterialMaster.CostData costData;
        public Integer per;
        public String uom;
        
        public FormulaPricingData(Formula_Mapping__c mapping, MaterialMaster.CostData costData) {
            this.materialId = mapping.Formula__r.Material_Item__c;
            this.materialCode = mapping.Formula__r.Material_Item__r.Material_Code__c;
            this.actualPrice = FormulaProcessor.process(mapping.Formula__c);
            this.costData = costData;
            this.per = mapping.Per__c.intValue();
            this.uom = mapping.UoM__c;
            this.mapping = mapping;
        }
    }
    
    public class PricingEngineException extends Exception {}
    
}