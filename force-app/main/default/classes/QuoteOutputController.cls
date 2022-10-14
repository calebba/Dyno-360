public with sharing class QuoteOutputController {
    
    public Id quoteId {get;set;}
    public Id componentQuoteId;
    public String currentDate {get; set;}
    public String validDate {get; set;}
    public String validDateTo {get; set;}
    public String lockDateTo { get; set; }
    public Quote__c theQuote {get; set;}
    public List<Quote_Line_Item__c> quoteLineRecords {get; set;}
    public List<Quote_Line_Item__c> bundledList {get; set;}
    public Boolean isNew {get; set;}
    public String priceValid {get; set;}
    public String currentLanguage {get; set;}
    public String componentId {get; set;}
    public Boolean volumetricDeal {get; set;}
    public String shippingStreet {get; set;}
    public String shippingCity {get; set;}
    public String shippingCountry {get; set;}
    public String shippingState {get; set;}
    public String shippingZip {get; set;}   
    public String trialAccount {get; set;}
    public CurrencyData cd {get; set;}
    public String topName {get; set;}
    public String bottomName {get; set;}
    
    public QuoteOutputController() {
        currentDate = System.today().format();
        shippingStreet = null;
        shippingCity = null;
        shippingCountry = null;
        shippingState = null;
        shippingZip = null;
        trialAccount = null;
        if(ApexPages.currentPage().getParameters().get('quoteID') != null) {
            quoteId = ApexPages.currentPage().getParameters().get('quoteID');
            init(quoteId);
        }
    }

    public void setcomponentQuoteId(Id incId){
        componentQuoteId = incId;
        quoteId = componentQuoteId;
        if(quoteId != null) {
            init(quoteId);
        }
    }    
    
    private void init(Id theId) { 
        theQuote = [SELECT Opportunity__r.Description, Opportunity__r.Owner.Name, Opportunity__r.Owner.Phone, Id, Scenario_Notes__c, Opportunity__r.Account.Account_Group__c, Name, Quote_Valid_From__c, CurrencyIsoCode, Opportunity__r.Account.Id, Opportunity__r.Account.Name, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.ParentId,
                    Opportunity__r.Account.ShippingCity, Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingPostalCode, Price_Adjustment__c, Opportunity__r.Account.Parent.Name, Opportunity__r.Account.Language__c,
                    Opportunity__r.Account.ShippingCountry, Price_Valid_From__c, Price_Valid_To__c, Quote_Acceptance_Period__c, On__c, Opportunity__r.RecordTypeId, Sales_Organization_Primary__r.Company_Code__c, Scenario_Output_Header_Name__c, 
                    Sales_Organization_Primary__r.Street_Address__c, Print_text_on_AN_and_AN_Based_30_day_p__c, Sales_Organization_Primary__r.City__c, Sales_Organization_Primary__r.State__c, Sales_Organization_Primary__r.Country__c, Sales_Organization_Primary__r.Postal_Code__c,  
                    Sales_Organization_Primary__r.Name, Scenario_Output_Header_Info__c, Volumetric_Per__c, Volumetric_Parent_Product__r.Name, Volumetric_Parent_Product__r.Material_Code__c, Volumetric_Parent_Product__r.PHL1__c, Volumetric_Parent_Product_UoM__c, Trial__c, Calculated_Price__c,Blast_Pattern_UoM__c, Quote_Description__c FROM Quote__c WHERE Id = :quoteId LIMIT 1];
        if(theQuote.On__c != null) {
            isNew = theQuote.On__c == System.Label.Yes;
        } else {
            isNew = true;
        }
        
        //rpn added mar 23 2012
        if (theQuote.Scenario_Output_Header_Info__c != null){
        theQuote.Scenario_Output_Header_Info__c = theQuote.Scenario_Output_Header_Info__c.replaceAll( '\n', '<br/>' );
        }
        // ended mar 23 2012
        if (theQuote.Trial__c){
            trialAccount = System.Label.TrialQuote;
        }
        cd = new CurrencyData(theQuote.CurrencyIsoCode, theQuote.Calculated_Price__c);

        volumetricDeal = (theQuote.Opportunity__r.RecordTypeId == [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted' LIMIT 1].Id);           
        //Language Translation
        currentLanguage = 'US'; 
        if (theQuote.Opportunity__r.Account.Id != null){
            currentLanguage = LanguageTranslationUtil.queryLanguage(theQuote.Opportunity__r.Account.Id);
        }

        validDate = theQuote.Price_Valid_From__c.format();
        validDateTo = theQuote.Price_Valid_To__c.format();
        priceValid = theQuote.Price_Adjustment__c.format();
        determineAddress();
        quoteLineRecords = QuoteUtil.queryForChildRecordsByQuote(quoteId);
        bundledList = getBundledServices();     
    }
    
    private void determineAndAssignAddress(Account billTo, Account alternate) {
        /*
        if( (billTo.Bill_To_Street__c != null      && billTo.Bill_To_Street__c.trim() != '') || 
            (billTo.Bill_To_City__c != null        && billTo.Bill_To_City__c.trim() != '') || 
            (billTo.Bill_To_State__c != null       && billTo.Bill_To_State__c.trim() != '') || 
            (billTo.Bill_To_Postal_Code__c != null && billTo.Bill_To_Postal_Code__c.trim() != '') || 
            (billTo.Bill_To_Country__c != null     && billTo.Bill_To_Country__c.trim() != '') ||
            (billTo.Name != null && billTo.Name.trim() != '')) {
            shippingStreet = billTo.Bill_To_Street__c;
            shippingCity = billTo.Bill_To_City__c;
            shippingCountry = billTo.Bill_To_Country__c;
            shippingState = billTo.Bill_To_State__c;
            shippingZip = billTo.Bill_To_Postal_Code__c; 
            bottomName = billTo.Name;
        } else {*/
            shippingStreet = alternate.ShippingStreet;
            shippingCity = alternate.ShippingCity;
            shippingCountry = alternate.ShippingCountry;
            shippingState = alternate.ShippingState;
            shippingZip = alternate.ShippingPostalCode;    
            bottomName = alternate.Name;        
        //}
    }
    
    private void determineAddress() {
        List<Account> shipTos = [SELECT ShippingCity, ShippingCountry, ShippingState, ShippingStreet, ShippingPostalCode, Name From Account WHERE ParentId = :theQuote.Opportunity__r.Account.ParentId AND Account_Group__c = '0002 Ship-to party'];

        if(theQuote.Opportunity__r.Account.Account_Group__c == '0001 Sold-to party') {
            topName = theQuote.Opportunity__r.Account.Name;
            determineAndAssignAddress(new Account()
                                      , 
                                     new Account(ShippingStreet = theQuote.Opportunity__r.Account.ShippingStreet, ShippingCity = theQuote.Opportunity__r.Account.ShippingCity,
                                                 ShippingCountry = theQuote.Opportunity__r.Account.ShippingCountry, ShippingState = theQuote.Opportunity__r.Account.ShippingState,
                                                 ShippingPostalCode = theQuote.Opportunity__r.Account.ShippingPostalCode, Name = ''));              
        } else if(shipTos.size() == 0) {
            topName = getParentCustomerName();
            determineAndAssignAddress(new Account()
                                      , 
                                     new Account(ShippingStreet = theQuote.Opportunity__r.Account.ShippingStreet, ShippingCity = theQuote.Opportunity__r.Account.ShippingCity,
                                                 ShippingCountry = theQuote.Opportunity__r.Account.ShippingCountry, ShippingState = theQuote.Opportunity__r.Account.ShippingState,
                                                 ShippingPostalCode = theQuote.Opportunity__r.Account.ShippingPostalCode, Name = theQuote.Opportunity__r.Account.Name));                    
        } else if(shipTos.size() == 1) {
            topName = theQuote.Opportunity__r.Account.Name;
            determineAndAssignAddress(new Account(), shipTos[0]);            
        } else {
            /*
            shippingStreet = System.Label.QuotePDF_MultLoc;  
            topName = getParentCustomerName();
            bottomName = theQuote.Opportunity__r.Account.Name;*/
            topName = theQuote.Opportunity__r.Account.Name;
            determineAndAssignAddress(new Account(), 
                                     new Account(ShippingStreet = theQuote.Opportunity__r.Account.ShippingStreet, ShippingCity = theQuote.Opportunity__r.Account.ShippingCity,
                                     ShippingCountry = theQuote.Opportunity__r.Account.ShippingCountry, ShippingState = theQuote.Opportunity__r.Account.ShippingState,
                                     ShippingPostalCode = theQuote.Opportunity__r.Account.ShippingPostalCode, Name = ''));              
            //bottomName = theQuote.Opportunity__r.Account.Bill_To_Name__c == null || theQuote.Opportunity__r.Account.Bill_To_Name__c.trim() == '' ? theQuote.Opportunity__r.Account.Name : theQuote.Opportunity__r.Account.Bill_To_Name__c;              
        }
    }
    
    public String getParentCustomerName() {
        String name = theQuote.Opportunity__r.Account.Name;
        if(theQuote.Opportunity__r.Account.ParentId != null) {
            name = theQuote.Opportunity__r.Account.Parent.Name;
        }
        return name;
    }
    
    public Id getcomponentQuoteId(){
        return componentQuoteId;
    }
    
    private Boolean findBundle(List<Quote_Line_Item__c> qliList) {
        for(Quote_Line_Item__c currQli : qliList) {
            if(currQli.Bundled_Flag__c) {
                return true;
            }
        }
        return false;
    }
    
    private Boolean isGroupable(Boolean foundBundle, Quote_Line_Item__c currQli) {
        if(!foundBundle) {
            return (currQli.Material_Item__r.Product_Hierarchy__c != null && currQli.Material_Item__r.Product_Hierarchy__c.length() >= 5);
        } 
        return (currQli.Material_Item__r.Product_Hierarchy__c != null && currQli.Material_Item__r.Product_Hierarchy__c.length() >= 5 && 
               currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) != 'PL050' && currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) != 'PL060' && 
               currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) != 'PL061');
    }
    
    public List<CalculatedBlastPattern> getBlastPatterns() {
        return new List<CalculatedBlastPattern>();
    }
    
    private boolean hasLockedDates = false;
    private transient boolean lockedCalculated = false;
    public boolean getHasLockedDates() {
    	if (!lockedCalculated)
    		getItems();
    	return hasLockedDates;
    }
        
    public List<GroupedQli> getItems() {
    	hasLockedDates = false;
        if(theQuote == null) {
            return null;
        }       
        //Make a list of the first 5 characters of Product_Hierarchy__c from needed QLI
        List<String> prodList = new List<String>(); 
        List<Quote_Line_Item__c> qliListNotPL060 = [SELECT Id, Price_Valid_To__c ,Is_Bundled__c, Lock_Expiration_Date__c, Material_Item__r.Hazmat_Class__c, Material_Item__r.Material_Description__c, Material_Item__r.Material_Description_French__c, Bundled_Flag__c, Name, Material_Item__r.Name,Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c,Material_Item__r.PHL1__c,Material_Item__r.PHL2__c, Material_Item__r.PHL3__c, Per__c, Actual_Price__c, UoM__c FROM Quote_Line_Item__c WHERE Quote__c = :theQuote.Id AND Material_Item__r.PHL1__c <> 'PL060' order by Material_Item__r.Material_Description__c, Material_Item__r.PHL2__c, Material_Item__r.PHL1__c asc];
        List<Quote_Line_Item__c> qliListPL060 = [SELECT Id, CREATEDDATE, Price_Valid_To__c ,Is_Bundled__c, Lock_Expiration_Date__c, Material_Item__r.Hazmat_Class__c, Material_Item__r.Material_Description__c, Material_Item__r.Material_Description_French__c,Bundled_Flag__c, Name, Material_Item__r.Name,Material_Item__r.Material_Code__c, Material_Item__r.Product_Hierarchy__c,Material_Item__r.PHL1__c,Material_Item__r.PHL2__c, Material_Item__r.PHL3__c, Per__c, Actual_Price__c, UoM__c FROM Quote_Line_Item__c WHERE Quote__c = :theQuote.Id AND Material_Item__r.PHL1__c = 'PL060' order by CREATEDDATE, Material_Item__r.Material_Description__c, Material_Item__r.PHL2__c, Material_Item__r.PHL1__c asc];
        List<Quote_Line_Item__c> qliList = new List<Quote_Line_Item__c>();
        qliList.addAll(qliListNotPL060);
        qliList.addAll(qliListPL060);
        //done with above update RPN Dec 10 2012 - used to sort PL060 outputs by created date
                       
        Boolean foundBundle = findBundle(qliList);
        for(Quote_Line_Item__c currQli : qliList) {
            if(isGroupable(foundBundle, currQli)) {
                prodList.add(currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5));
            }
        }
        //Get all product groupings where name is in that list, order by product line
        
        List<Product_Grouping__c> pgList = [SELECT Id, Name, Description__c, Product_Line__c, Title__c, French_Title__c, Spanish_Title__c FROM Product_Grouping__c WHERE Name in :prodList order by Name];
        Map<String, Product_Grouping__c> phl1ToPG = new Map<String, Product_Grouping__c>();
        for(Product_Grouping__c currPg : pgList) {
            phl1ToPG.put(currPg.Name, currPg);
        }
        List<String> preferredOrder = new List<String>{'PL084', 'PL070', 'PL005', 'PL035', 'PL030 OR PL065 1', 'PL030 OR PL065 2', 'PL030 OR PL065 3', 'PL032', 'PL048', 'PL042', 'PL045', 'PL047', 'PL040', 'PL080', 'PL049', 'PL050', 'PL051', 'PL060', 'PL061', 'PL062', 'PL085', 'PL088'};
        // Below, "New Code" is an optimization of the "Old Code"
        // "Old Code" is still here for reference, in case "New Code" is not accomplishing the same thing
        // -------------------- BEGIN New Code --------------------
        GroupedQli tempGq;
        List<Quote_Line_Item__c> tempList;
        Map<String, List<Quote_Line_Item__c>> orderMap = new Map<String, List<Quote_Line_Item__c>>();
        orderMap.put('Other', new List<Quote_Line_Item__c>());
        for (String currKey : preferredOrder)
        	orderMap.put(currKey, new List<Quote_Line_Item__c>());
        for (Quote_Line_Item__c currQli : qliList) {
            if (!currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && currQli.Material_Item__r.Hazmat_Class__c == '1.1D' &&
               (currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL030' || currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL065')) {
                
            	orderMap.get('PL030 OR PL065 1').add(currQli);
                    
            } else if (!currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && currQli.Material_Item__r.Hazmat_Class__c == '1.5D' && 
                      (currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL030' || currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL065')) {
                            
            	orderMap.get('PL030 OR PL065 2').add(currQli);
                    
            } else if (!currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && 
            		   currQli.Material_Item__r.Hazmat_Class__c != '1.5D' && currQli.Material_Item__r.Hazmat_Class__c != '1.1D' && 
                      (currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL030' || currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL065') ) {
                            
            	orderMap.get('PL030 OR PL065 3').add(currQli);  
                    
            } else if (!currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && orderMap.containsKey(currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5))) {
                
            	orderMap.get(currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5)).add(currQli);
                    
            } else if (isGroupable(foundBundle, currQli) && !currQli.Is_Bundled__c) {
            	
            	orderMap.get('Other').add(currQli);
            	
            }

        	if (currQli.Lock_Expiration_Date__c) {
        		hasLockedDates = true;
        		lockDateTo = currQli.Price_Valid_To__c.format();
        	}
        }
        List<GroupedQli> toReturn = new List<GroupedQli>();
        for (String currKey : preferredOrder)
        	if (orderMap.get(currKey).size() > 0) {
        		tempGq = new GroupedQli();
                if(currKey == 'PL030 OR PL065 1') {
                    tempGq.grouping = 'X1';//System.Label.PL030_OR_PL065;
                } else if(currKey == 'PL030 OR PL065 2') {
                    tempGq.grouping = 'X2';//System.Label.PL030_OR_PL065_2;
                } else if(currKey == 'PL030 OR PL065 3') {
                    tempGq.grouping = 'X3';//System.Label.PL030_OR_PL065_3;
                } else {
                    if(currentLanguage == 'FR') {
                        tempGq.grouping = phl1ToPG.get(currKey).French_Title__c;
                    } else if(currentLanguage == 'ES') {
                        tempGq.grouping = phl1ToPG.get(currKey).Spanish_Title__c;
                    } else {
                        tempGq.grouping = phl1ToPG.get(currKey).Title__c;
                    }
                }
                
                tempGq.groupedQlis = orderMap.get(currKey);
                toReturn.add(tempGq);
        	}
        if(orderMap.get('Other').size() > 0) {
            tempGq = new GroupedQli();
            tempGq.grouping = System.Label.QuotePDF_Misc;
            tempGq.groupedQlis = orderMap.get('Other');
            toReturn.add(tempGq);
        }
        // --------------------  END  New Code --------------------
        // Above, "New Code" is an optimization of the "Old Code" below
        // "Old Code" is still here for reference, in case "New Code" is not accomplishing the same thing
        // -------------------- BEGIN Old Code -------------------- 
        //Iterate through this product grouping list, grouping qlis in order by type 
        /*List<GroupedQli> toReturn = new List<GroupedQli>();
        List<Quote_Line_Item__c> tempList;
        GroupedQli tempGq;
        for(String currKey : preferredOrder) {
            tempList = new List<Quote_Line_Item__c>();
            for(Quote_Line_Item__c currQli : qliList) {
                if(currKey == 'PL030 OR PL065 1' && !currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && 
                   currQli.Material_Item__r.Hazmat_Class__c == '1.1D' && 
                   (currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL030' || 
                   currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL065') ) {
                    
                    	if (currQli.Lock_Expiration_Date__c) {
                    		hasLockedDates = true;
                    		lockDateTo = currQli.Price_Valid_To__c.format();
                    	}
                        tempList.add(currQli);
                        
                    } else if(currKey == 'PL030 OR PL065 2' && !currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && 
                              currQli.Material_Item__r.Hazmat_Class__c == '1.5D' && 
                              (currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL030' || 
                              currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL065') ) {
                                
                    	if (currQli.Lock_Expiration_Date__c) {
                    		hasLockedDates = true;
                    		lockDateTo = currQli.Price_Valid_To__c.format();
            			}
                        tempList.add(currQli);
                        
                } else if(currKey == 'PL030 OR PL065 3' && !currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && 
                              currQli.Material_Item__r.Hazmat_Class__c != '1.5D' && currQli.Material_Item__r.Hazmat_Class__c != '1.1D' && 
                              (currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL030' || 
                              currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == 'PL065') ) {
                                
                    	if (currQli.Lock_Expiration_Date__c) {
                    		hasLockedDates = true;
                    		lockDateTo = currQli.Price_Valid_To__c.format();
                    	}
	                    tempList.add(currQli);  
                        
                } else if (!currQli.Is_Bundled__c && currQli.Material_Item__r.Product_Hierarchy__c != null && currQli.Material_Item__r.Product_Hierarchy__c.substring(0,5) == currKey) {
                        
                    	if (currQli.Lock_Expiration_Date__c) {
                    		hasLockedDates = true;
                    		lockDateTo = currQli.Price_Valid_To__c.format();
                    	}
                        tempList.add(currQli);
                        
                }
            }
            if(tempList.size() > 0) {
                tempGq = new GroupedQli();
                if(currKey == 'PL030 OR PL065 1') {
                    tempGq.grouping = 'X1';//System.Label.PL030_OR_PL065;
                } else if(currKey == 'PL030 OR PL065 2') {
                    tempGq.grouping = 'X2';//System.Label.PL030_OR_PL065_2;
                } else if(currKey == 'PL030 OR PL065 3') {
                    tempGq.grouping = 'X3';//System.Label.PL030_OR_PL065_3;
                } else {
                    if(currentLanguage == 'FR') {
                        tempGq.grouping = phl1ToPG.get(currKey).French_Title__c;
                    } else if(currentLanguage == 'ES') {
                        tempGq.grouping = phl1ToPG.get(currKey).Spanish_Title__c;
                    } else {
                        tempGq.grouping = phl1ToPG.get(currKey).Title__c;
                    }
                }
                
                tempGq.groupedQlis = tempList;
                toReturn.add(tempGq);
            }
        }
        
        List<Quote_Line_Item__c> qliRemaining = new List<Quote_Line_Item__c>();
        Integer count = 0, max = 0;
        
        if(qliList.size() < 300) {
            for(Quote_Line_Item__c currQli : qliList) {
                count = 0;
                max = 0;
                for(GroupedQli currGq : toReturn) {
                    max += currGq.groupedQlis.size();
                    for(Quote_Line_Item__c subQli : currGq.groupedQlis) {
                        if(subQli.Id != currQli.Id) {
                            count++;
                        }
                    }
                }
                
                if(count == max && isGroupable(foundBundle, currQli)) {
                    qliRemaining.add(currQli);
                }           
            }
        }
    
        //Add in ones that cannot be grouped as miscellaneous
        tempList = new List<Quote_Line_Item__c>();
        for(Quote_Line_Item__c currQli : qliRemaining) {
            if(!currQli.Is_Bundled__c) {
                tempList.add(currQli);  
            }    
        }
        if(tempList.size() > 0) {
            tempGq = new GroupedQli();
            tempGq.grouping = System.Label.QuotePDF_Misc;
            tempGq.groupedQlis = tempList;
            toReturn.add(tempGq);
        }*/
        
        // --------------------  END  Old Code --------------------
        
        lockedCalculated = true;

        return toReturn;
    }
    
    public List<Quote_Line_Item__c> getBundledServices() {
        List<Quote_Line_Item__c> qliList = new List<Quote_Line_Item__c>();
        
        for(Quote_Line_Item__c currQli : quoteLineRecords) {
            if(currQli.Is_Bundled__c) {
                qliList.add(currQli); 
            }
        }
        
        if(qliList.size() == 0) {
            return null;
        }
        return qliList;
    }
    
    class CalculatedBlastPattern {
        //public Blast_Pattern__c relatedBp {get; set;}
        public String calculatedPrice {get; set;}
    }
        
    class GroupedQli {
        public String grouping {get; set;}
        public List<Quote_Line_Item__c> groupedQlis {get; set;}
    }
    
}