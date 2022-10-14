public with sharing class OpportunityTriggerUtils {
   public static Boolean isRunning = false;
    //Creates a quote for Opportunities where the RecordType is "New Quote"
    public static void createQuote(List<Opportunity> opptyList, Date qValidFrom, Date qValidTo, Date pValidFrom, Date pValidTo, String description, Boolean promo, Boolean tri, Customer_Sales_Site__c currCSS, String scenarioChoice, String holeChoice, Id volumetricParentProduct) {
        isRunning = true;
        List<RecordType> typesNeeded = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Deal_Quoted' OR DeveloperName = 'Deal_Volumetric_Quoted' OR DeveloperName = 'Bundled'];
        Id bundledType = null;
        for(RecordType rt : typesNeeded) {
            if(rt.DeveloperName == 'Bundled') {
                bundledType = rt.Id;
            }
        }
        List<Quote__c> quotesToInsert = new List<Quote__c>();
        List<Id> customerList = new List<Id>();
        for(Opportunity currOpp : opptyList) {
            if(currOpp.AccountId != null) {
                customerList.add(currOpp.AccountId);
            }
        }
        List<Account> customerMaster = [SELECT Price_Adjustment_Notice_Period__c, CurrencyIsoCode, On_Standard_Ts_Cs__c, On_Contract__c, AN_Formula_Pricing__c FROM Account WHERE Id in :customerList];
        
        for(Opportunity currOpp : opptyList) {
            if((typesNeeded[0].Id == currOpp.RecordTypeId  || typesNeeded[1].Id == currOpp.RecordTypeId || typesNeeded[2].Id == currOpp.RecordTypeId) && currOpp.StageName != System.Label.Opportunity_Stage_CW && currOpp.StageName != System.Label.Opportunity_Stage_CL) {
                Quote__c theQuote = new Quote__c();
                for(Account currAccount : customerMaster) {
                    if(currAccount.Id == currOpp.AccountId) {
                        theQuote.Price_Adjustment__c = currAccount.Price_Adjustment_Notice_Period__c;
                        theQuote.Payment_Terms__c = currCSS.Payment_Terms__c;
                        theQuote.CurrencyIsoCode = currAccount.CurrencyIsoCode;
                        theQuote.On__c = currAccount.On_Standard_Ts_Cs__c;
                        theQuote.On_Contract__c = currAccount.On_Contract__c;
                        theQuote.AN_Formula_Pricing__c = currAccount.AN_Formula_Pricing__c;
                        theQuote.Customer__c = currAccount.Id;
                        theQuote.CurrencyIsoCode = currCSS.CurrencyIsoCode;  //RPN June 05 2012
                    }
                }
                theQuote.Sales_Organization_Primary__c = currCSS.Sales_Site__c;
                theQuote.Pricelist__c = currCSS.Pricelist__c;
                theQuote.Inco_Terms__c = currCSS.INCO__c;
                theQuote.Delivery_Sales_Site__c = currCSS.Delivery_Sales_Site__c;
                theQuote.Service_Type__c = currCSS.Service_Type__c;
                theQuote.Drilling_Provided_By__c = currCSS.Drilled_By__c;
                theQuote.Customer_Group__c = currCSS.Customer_Group__c;
                theQuote.Quote_Valid_From__c = qValidFrom;
                theQuote.Quote_Valid_To__c = qValidTo;
                theQuote.Price_Valid_From__c = pValidFrom;
                theQuote.Price_Valid_To__c = pValidTo;
                theQuote.Quote_Description__c = description;
                theQuote.Promotional__c = promo;
                theQuote.Trial__c = tri;
                theQuote.Version_Number__c = '1';
                theQuote.Active_Quote__c = true;
                theQuote.Opportunity__c = currOpp.Id;
                theQuote.Quote_Accepted_By_Customer__c = 'Not Yet';
                theQuote.Volumetric_Parent_Product__c = volumetricParentProduct;
                if(volumetricParentProduct != null) {
                    theQuote.Volume_UoM__c = [SELECT Base_Unit_of_Measue__c FROM Material_Item__c WHERE Id = :volumetricParentProduct LIMIT 1].Base_Unit_of_Measue__c;
                }
                quotesToInsert.add(theQuote);               
            }
        }
        
        if(quotesToInsert.size() > 0) {       
            insert quotesToInsert;
            if(opptyList.get(0).RecordTypeId == bundledType) {
               createBundledServices(scenarioChoice, holeChoice, currCSS.Sales_Site__c, quotesToInsert, pValidFrom, pValidTo);
            }
        }
        isRunning = false;
    }
    
    public static void createBundledServices(String scenarioChoice, String holeChoice, Id salesSiteId, List<Quote__c> quotesToInsert, Date pValidFrom, Date pValidTo) {
        List<Bundled_Service__c> bsList = new List<Bundled_Service__c>();
        List<Quote_Line_Item__c> toInsert = new List<Quote_Line_Item__c>();
        if(scenarioChoice == 'Shot_Service_with_Drilling') {
            bsList = [SELECT Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Material_Description__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Preferred__c FROM Bundled_Service__c WHERE RecordType.DeveloperName = :scenarioChoice AND (Hole_Size__c = :holeChoice OR Hole_Size__c = null)];
        } else {
            bsList = [SELECT Material_Item__c, Material_Item__r.Name, Material_Item__r.Material_Code__c, Material_Item__r.Material_Description__c, Material_Item__r.Product_Hierarchy__c, Material_Item__r.Preferred__c FROM Bundled_Service__c WHERE RecordType.DeveloperName = :scenarioChoice];
        }
        List<Id> tempIds = new List<Id>();
        List<Material_Item__c> materialDetails = new List<Material_Item__c>();
        for(Bundled_Service__c currBS : bsList) {
            tempIds.add(currBS.Material_Item__c);
            materialDetails.add( new Material_Item__c(Id=currBS.Material_Item__c, Name=currBS.Material_Item__r.Name, Material_Code__c=currBS.Material_Item__r.Material_Code__c, Material_Description__c=currBS.Material_Item__r.Material_Description__c, Product_Hierarchy__c=currBS.Material_Item__r.Product_Hierarchy__c, Preferred__c=currBS.Material_Item__r.Preferred__c));
        }
        
        List<MaterialMaster.CostData> cdList = MaterialMaster.calculateCost(tempIds, salesSiteId, true, materialDetails);
    
        for(Quote__c currQuote : quotesToInsert) {
            Quote_Line_Item__c currQli;
            for(Bundled_Service__c currBS : bsList) {
                currQli = new Quote_Line_Item__c();
                currQli.Material_Item__c = currBS.Material_Item__c;
                currQli.Sales_Site__c = salesSiteId;
                currQli.Source_Sales_Site__c = salesSiteId;
                currQli.Quantity__c = 1;
                currQli.Per__c = 1;
                currQli.UoM__c = 'N/A';
                currQli.Price_Valid_From__c = pValidFrom;
                currQli.Price_Valid_To__c = pValidTo;
                currQli.Country__c = currQuote.Country__c;
                currQli.Floor_Price__c = 0.00;
                currQli.Target_Price__c = 0.00;
                currQli.Actual_Price__c = 0.00;
                currQli.Quote__c = currQuote.Id;
                currQli.Is_Bundled__c = true;
                for(MaterialMaster.CostData mmcd : cdList) {
                    if(mmcd.materialId == currBS.Material_Item__c) {
                        currQli.Cost__c = mmcd.cost;
                        currQli.Cost_See_Through__c = mmcd.seeThroughCost;
                    }
                }
                toInsert.add(currQli);
            }
        }
        insert toInsert;        
    }
    
    public static void checkDeletionFlag(List<Opportunity> opptyList) {
        List<Id> idList = new List<Id>();
        
        for(Opportunity currOpp : opptyList) {
            if(currOpp.AccountId != null) {
                idList.add(currOpp.AccountId);
            }
        }
        
        List<Account> acctList = [SELECT Id, Flag_for_Deletion__c FROM Account WHERE Id in :idList];
        
        for(Opportunity currOpp : opptyList) {
            for(Account currAcct : acctList) {
                if(currOpp.AccountId == currAcct.Id && currAcct.Flag_for_Deletion__c) {
                   currOpp.AccountId.addError(System.Label.Flagged_For_Deletion);
                }
            }
        }
    }
    
    public static void setClosedWon(List<Opportunity> opptyList) {
      List<Id> idList = new List<Id>();
      for(Opportunity currOpp : opptyList) {
        if(currOpp.StageName == System.Label.Opportunity_Stage_CW) {
          idList.add(currOpp.Id);
        }
      }
      
      if(idList.size() > 0) {
        isRunning = true;
        //OpportunityClosedDeal runClosedDeal = new OpportunityClosedDeal(idList);
        //runClosedDeal.executeCopyOfRecords();
        isRunning = false;
      }
    }
    
    
    public static void pullApproversToQuote(List<Opportunity> opportunityRecords) {
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(Opportunity o : opportunityRecords) {
            if(o.StageName != System.Label.Opportunity_Stage_CW) {
                opportunityIds.add(o.Id);
                userIds.add(o.OwnerId);
            }
        }
        Map<Id, User> userRecords = new Map<Id, User>([Select u.Industry_Manager__c, u.Id, u.Vice_President__c, u.Product_Manager__c, u.Product_Manager_2__c, u.Product_Manager_3__c, u.Regional_Ops_Manager__c, u.RSM__c, u.Pricing_Manager__c, 
             u.Finance__c From User u where Id in: userIds]);
        List<Quote__c> quoteRecords = [select Id, Opportunity__c, Opportunity__r.OwnerId from Quote__c where Opportunity__c in: opportunityIds and Active_Quote__c = true AND Approval_Status__c <> 'Pending' AND Approval_Status__c <> 'Approved'];
        for(Quote__c q : quoteRecords) {
            User newOwnerData = userRecords.get(q.Opportunity__r.OwnerId);
            q.Vice_President__c = newOwnerData.Vice_President__c;
            q.Regional_Ops_Manager__c = newOwnerData.Regional_Ops_Manager__c;
            q.RSM__c = newOwnerData.RSM__c;
            q.Pricing_Manager__c = newOwnerData.Pricing_Manager__c;
            q.Finance__c = newOwnerData.Finance__c;
            q.Product_Industry_Manager__c = newOwnerData.Product_Manager__c;
            q.Product_Manager_2__c = newOwnerData.Product_Manager_2__c;
            q.Product_Manager_3__c = newOwnerData.Product_Manager_3__c;
            q.Industry_Manager__c = newOwnerData.Industry_Manager__c;
        }
        isRunning = true;
        if(quoteRecords.size() > 0) {
        	update quoteRecords;
        }
        isRunning = false;
    }    
    
    /*
    public static void nameTransform(List<Opportunity> oppList) {
    	//Should query for all others at this location, order them by name, then rename
    	isRunning = true;

    	List<Opportunity> oList = [SELECT Id, Name, Sales_Site__c, AccountId FROM Opportunity WHERE AccountId = :oppList[0].AccountId order by Sales_Site__c, Deal_Number__c asc];
    	Id ssId = oList[0].Sales_Site__c;
    	Integer counter = 0;
    	String temp = '', newName = '';
    	List<String> tempSplit;
    	for(Opportunity o : oList) {
    		if(ssId != o.Sales_Site__c) {
    			ssId = o.Sales_Site__c;
    			counter = 1;
    		} else {
    			counter++;
    		}
    		    		
    		if(counter < 10) {
    			temp = '0' + counter;
    		} else {
    			temp = '' + counter;
    		}
    		
    		tempSplit = o.Name.split('-');
    		newName = '';
    		for(Integer index = 0; index < tempSplit.size(); index++) {
    			if(index == 1) {
    				newName += temp + '-';
    			} else if(index < tempSplit.size() - 1) {
    				newName += tempSplit[index] + '-';
    			} else {
    				newName += tempSplit[index];
    			}
    		}

    		o.Name = newName;
    		o.Deal_Number__c = temp;
    	}
    	
    	update oList;
    	isRunning = false;
    }*/

     public static void generateOpportunityName(List<Opportunity> oppList){
        Set<String> accountIds = new Set<String>();
        Set<String> salesSiteIds = new Set<String>();
        
        //Strip AccountId, Site off all incoming opps
        for (Opportunity a: oppList){
            accountIds.add(a.AccountId);
            salesSiteIds.add(a.Sales_Site__c);
        }
        
        //Query for more info on Accts, Sites from incoming Opptys
        List<Account>       accountsForOpps = [SELECT Id, Name, Deal_Count__c, RecordTypeId, Sap_Account_Number__c, Pricing_Region__c FROM Account WHERE Id in: accountIds];
        List<Sales_Site__c> salesSiteForOpps = [SELECT Id, Name,SAPExternalId__c FROM Sales_Site__c WHERE Id in: salesSiteIds];
        List<RecordType>    oppRecordType    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Opportunity' OR SObjectType = 'Account'];
      
        //Init some maps
        Map<String, Double>             accountToCount   = new Map<String, Double>();
        Map<Id, Account>            OppIdToAccount   = new Map<Id, Account>(accountsforOpps); 
        Map<Id, Sales_Site__c>      OppIdtoSS        = new Map<Id, Sales_Site__c>(salesSiteForOpps);
        Map<Id, RecordType>         recordTypeIds    = new Map<Id,RecordType>(oppRecordType);
        Integer dealC = 0;
        
        //Iterate over all accounts, because we are creating a new Quote for these accounts, increment the deal count by 1 (or is it because we cant have 0?)
        //Need to perform an aggregatequery to get this info
        
        List<AggregateResult> countList = [SELECT count(Id) idCount, AccountId aId, Sales_Site__c ssId FROM Opportunity WHERE Sales_Site__c in :salesSiteIds AND AccountId in :accountIds group by Sales_Site__c, AccountId];
        
        for(AggregateResult ar : countList) {
        	accountToCount.put(ar.get('aId') + '-' + ar.get('ssId'), (Double) ar.get('idCount'));
        }
        /*
        for(Account a : accountsForOpps) {
            accountToCount.put(a.Id, a.Deal_Count__c);
        }*/
        
        
        //Iterate over the opptys
        for (Opportunity o: oppList) {
            
            //Initialize name and prefix it with B, V, or Q.
            String generatedName = '';  
            String pricingRegion = '';
            if (recordTypeIds.get(o.RecordTypeId).DeveloperName == 'Bundled'){
                generatedName = 'B-';
            } else if (recordTypeIds.get(o.RecordTypeId).DeveloperName == 'Deal_Volumetric_Quoted'){
                generatedName = 'V-';
            } else {
                generatedName = 'Q-';
            }
            
            //This is always true...
            if (OppIdToAccount.size() > 0) {
                //Pull down deal count for this account
                Integer dealNumber;
                if(!accountToCount.containsKey(o.AccountId + '-' + o.Sales_Site__c)) {
                	accountToCount.put(o.AccountId + '-' + o.Sales_Site__c, 0);
                }
                dealNumber = accountToCount.get(o.AccountId + '-' + o.Sales_Site__c).intValue();
                
                dealNumber = Math.mod(dealNumber, 99);
                dealNumber++;
                //If deal count is less than 10, tack a 0 on the front.
                //Set the Deal Number on the OPPTY to this value.
                if(dealNumber < 10) {
                    o.Deal_Number__c = '0' + dealNumber;
                } else {
                    o.Deal_Number__c = '' + dealNumber;
                }
                
                //Increment deal count...not sure why at this point
                accountToCount.put(o.AccountId + '-' + o.Sales_Site__c, accountToCount.get(o.AccountId + '-' + o.Sales_Site__c).intValue()+1);
                
                //Pulls account name and SAP # from relevent account
                String accountName = OppIdToAccount.get(o.AccountId).Name; 
                String sapNumber = OppIdToAccount.get(o.AccountId).Sap_Account_Number__c;
                pricingRegion = OppIdToAccount.get(o.AccountId).Pricing_Region__c;
   
                //When is the deal number null at this point?
                if (o.Deal_Number__c != null) {
                    generatedName += o.Deal_Number__c + '-';
                    /*
                    //This is an oddly placed mod
                    if (math.mod(dealNumber, 100) < 10 && dealNumber > 0){
                        generatedName += '0' + dealNumber + '-';
                    } else {
                        generatedName += dealNumber + '-';
                    }*/
                }
                
                //Dont we already know the account name is not null by virture of being in this IF statement?
                if (accountName != null) {
                    //Prospect accounts do not yet have an SAP Account #, so just take the first 5 characters from the name.
                    //When it already exists in SAP, just tack on the SAP #
                    if (recordTypeIds.get(OppIdToAccount.get(o.AccountId).RecordTypeId).DeveloperName == 'Prospect'){
                        if (accountName.length() > 5){
                            generatedName = generatedName + accountName.substring(0,5) + '-';
                        } else {
                            generatedName = generatedName + accountName + '-';
                        }
                    } else {
                        if (sapNumber != null){
                            generatedName = generatedName + sapNumber + '-'; 
                        }
                    }
                }
            }
            
            //If there are any sales sites referenced by the Opps in this trigger...
            if (OppIdtoSS.size() > 0) {
                //Take the SAP ID of the site, and tack it onto the name.
                String siteName = OppIdtoSS.get(o.Sales_Site__c).SAPExternalId__c;
                if (siteName != null) {
                    generatedName = generatedName + siteName + '-';
                }
            }

            //Tack the current date onto the name.
            datetime t = System.now();
            String todaysDate = t.format('yyyyMMdd'); 
            generatedName = generatedName + todaysDate;
            o.Name = generatedName; 
            
            //Only set pricing region if it has not been set by cloning with changes
            if(String.isBlank(o.Pricing_Region__c)) {
            	o.Pricing_Region__c = pricingRegion;
        	}
            
            system.debug('scott got here :' + pricingRegion);
        } //END LOOP
     }
     
    /*
    private static void createPricingCondition(Account anAccount, Quote__c aQuote) {
        List<Pricing_Condition__c> pcList = new List<Pricing_Condition__c>();
        for(Quote_Line_Item__c qli : aQuote.Quote_Line_Items__r) {
            Pricing_Condition__c pc = new Pricing_Condition__c();
           // pc.VAKEY__c = qli.Sales_Site__r.SAP_Account_Number__c + ' ' + aQuote.Opportunity__r.Deal_Number__c + ' ' + anAccount.SAP_Account_Number__c + ' ' + qli.Material_Item__r.Material_Code__c;
            pc.Price_Valid_From__c = qli.Price_Valid_From__c;
            pc.Price_Valid_To__c = qli.Price_Valid_To__c;
            pc.Price__c = qli.Actual_Price__c;
            pc.Currency__c = aQuote.Currency__c;
            pcList.add(pc);
        }
        
        insert(pcList);
    } */
}