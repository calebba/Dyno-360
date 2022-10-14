public with sharing class SLIQuickAddController {
    
    public String selectedPHL1 {get; set;}
    public String selectedPHL2 {get; set;}
    public String selectedPHL3 {get; set;}
    public String recordType {get; set;}
    public String allocatedPrice {get; set;}    
    public Quote__c pageRecord {get; set;}
    public List<FormulaLine> formulaList {get; set;}            
    public List<Quote_Contact__c> quoteContactList {get; set;}
    public Boolean renderQC {get; set;}
    public Boolean areQli {get; set;}
    public Boolean areBs {get; set;}
    public Boolean selectAll {get; set;}
    public Boolean selectAllFormula {get; set;}
    public Boolean volumetricDeal {get; set;}
    public String siteChoice {get; set;}
    public List<Account> fakeList {get; set;}
    public SLIPaginator paginator {get; set;}
    public List<Account> emptyList {get; set;}
    public Double taic {get; set;}
    public Double contribMargin {get; set;}
    public CurrencyData volumeToBeBlasted {get; set;}
    public Boolean ReadMode {get; set;}
    private User currentUser;
    public ApexPages.StandardSetController setCtrl {get; set;}  //Used for the paginated list of line items.
    private static final Integer ROWS_PER_PAGE = 250;
    
    
    public SLIQuickAddController(ApexPages.StandardController quoteController) {
        try {
            pageRecord = queryForQuote(quoteController.getId());
        } catch(Exception e) {
            throw new IllegalStateException(System.Label.Advanced_Add_Fatal);
        }
        currentUser = [SELECT Product_Manager__r.Name, Product_Manager_2__r.Name, Product_Manager_3__r.Name, Product_Manager_1_PHL1s__c, Product_Manager_2_PHL1s__c, Product_Manager_3_PHL1s__c FROM User WHERE Id = :pageRecord.Opportunity__r.OwnerId];
        if(pageRecord.Being_Cloned__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.Batch_Clone_In_Progress));
        }
        if(pageRecord.Clone_Error__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Batch_Clone_Error));
        }
        emptyList = new List<Account>();
        paginator = new SLIPaginator();
        fakeList = new List<Account>();
        fakeList.add(new Account(Name='FakeAcct'));
        Readmode = True;
        selectedPHL1 = '--None--';
        selectedPHL2 = '--None--';
        selectedPHL3 = '--None--';
        volumeToBeBlasted = new CurrencyData(' ', pageRecord.Volume_to_be_Blasted__c == null ? 0 : pageRecord.Volume_to_be_Blasted__c);

        determineCMandTAIC(false);
        
        getCustomerSites();
        siteChoice = pageRecord.Sales_Organization_Primary__c;
        Id typeNeeded  = [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted' LIMIT 1].Id;
        volumetricDeal = pageRecord.Opportunity__r.RecordTypeId == typeNeeded;
        //slList = new List<ScenarioLine>();
        formulaList = new List<FormulaLine>();
        selectAll = false;
        selectAllFormula = false;
        quoteContactList = [SELECT Id, Name, Contact__r.Name, Contact__r.Email, Contact__r.AccountId, Contact__c, Quote__c, Selected__c, Primary_Recipient__c FROM Quote_Contact__c WHERE Quote__c = :pageRecord.Id];
        renderQC = quoteContactList.size() > 0;     
        
        getMaterialsBySite();       
        determineRenders();
        setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Price_Valid_To__c, Id, Material_Item__r.PHL1__c, Material_Item__c, Quantity__c, Floor_Price__c, Target_Price__c, Actual_Price__c, Formula_Flag__c, Extended__c, Total_Price__c, Per__c, UoM__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :pageRecord.Id AND Is_Bundled__c = false order by Material_Item__r.PHL1__c asc, Material_Item__r.Material_Description__c asc]));
        setCtrl.setPageSize(ROWS_PER_PAGE);
    }
    
    private void determineCMandTAIC(Boolean includeUpdate) {
        PandLData data = PandLData.getTAIC(pageRecord.Id);
        contribMargin = data.contributionMarginPercentage;
        taic = data.ebitPercentage;
        if(includeUpdate) {
            pageRecord.Stored_Ebit__c = data.ebit.value;
            update pageRecord;          
        }
    }
    
    public PageReference gotoeditmode() {
        Readmode = False;
        return null;
        }
    
    public PageReference gotoreadmode() {
        Readmode = True;
        return null;
        }
    
    public PageReference SLIsave() {        
        update getCurrentPageOfRecordsList();
        pageRecord = queryForQuote(pageRecord.Id);
        updatePaginator();
        determineCMandTAIC(false);
        return gotoreadmode();
        
    }
    
    public PageReference SLIsaveandedit() {
        update getCurrentPageOfRecordsList();
        pageRecord = queryForQuote(pageRecord.Id);
        updatePaginator();
        determineCMandTAIC(false);
        return null;
        
    }
    
    private void updatePaginator() {
        Integer pageNum = setCtrl.getPageNumber();
        setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Price_Valid_To__c, Id, Material_Item__r.PHL1__c, Material_Item__c, Quantity__c, Floor_Price__c, Target_Price__c, Actual_Price__c, Formula_Flag__c, Extended__c, Total_Price__c, Per__c, UoM__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :pageRecord.Id AND Is_Bundled__c = false order by Material_Item__r.PHL1__c asc, Material_Item__r.Material_Description__c asc]));
        setCtrl.setPageSize(ROWS_PER_PAGE);
        if(pageNum <= getTotalPages) {
            setCtrl.setPageNumber(pageNum);
        }
    }   
    
    public PageReference init() {
        if(pageRecord.CreatedDate == pageRecord.LastModifiedDate) {
            if(pageRecord.Approval_Status__c != 'Pending' && pageRecord.Approval_Status__c != 'Approved') {
                calculatePreviouslyApproved();
            }
            
            if(pageRecord.Clone_Error__c) {
                pageRecord.Clone_Error__c = false;
                update pageRecord;
            }
        }
                
        return null;    
    }   
    
    private void calculatePreviouslyApproved() {
        pageRecord.Previously_Approved__c = determinePreviouslyApproved();
        if(pageRecord.QuoteItemsBelowFlrPrice__c > 250) {
            pageRecord.Product_Manager_Approval_Items__c = System.Label.Approval_Error;   
        } 
        
        update pageRecord;
    }
    
    private Boolean determinePreviouslyApprovedHelper() {
        String msg1 = '', msg2 = '', msg3 = '';
        Boolean found1 = false, found2 = false, found3 = false;
        /*
        String miName = Schema.SObjectType.Material_Item__c.fields.Name.label, aPrice = Schema.SObjectType.Quote_Line_Item__c.fields.Actual_Price__c.label,
               perName = Schema.SObjectType.Quote_Line_Item__c.fields.Per__c.label, uomName = Schema.SObjectType.Quote_Line_Item__c.fields.UoM__c.label,
               totalPName = Schema.SObjectType.Quote_Line_Item__c.fields.Total_Price__c.label, floorPName = Schema.SObjectType.Quote_Line_Item__c.fields.Floor_Price__c.label,
               targetPName = Schema.SObjectType.Quote_Line_Item__c.fields.Target_Price__c.label;
        */
        String miName = 'Material Item', aPrice = 'Actual Price', perName = 'Per', uomName = 'UoM', totalPName = 'Total Price', floorPName = 'Floor Price', targetPName = 'Target Price';
        //Iterate over SLI and if something is below floor create the message to attribute it to the correct Product Manager        
        for(Quote_Line_Item__c currQLI : queryForLines()) {
            if(currQLI.Actual_Price__c < currQLI.Floor_Price__c)
            {
                if(currentUser.Product_Manager_1_PHL1s__c != null && currentUser.Product_Manager_1_PHL1s__c.contains(currQLI.Material_Item__r.PHL1__c)) {
                    msg1 += '&nbsp;&nbsp;&nbsp;&nbsp;' + miName + ': ' + currQLI.Material_Item__r.Name + ', '+ aPrice + ': ' + currQLI.Actual_Price__c + ', ' + perName + ': ' + currQLI.Per__c + ', ' + uomName +  ': ' + currQLI.UoM__c + ', ' + totalPName + ': ' + currQLI.Total_Price__c + ', ' + floorPName +': ' + currQLI.Floor_Price__c + ', ' + targetPName + ': ' + currQLI.Target_Price__c + '<br />';
                    found1 = true;
                } else if(currentUser.Product_Manager_2_PHL1s__c != null && currentUser.Product_Manager_2_PHL1s__c.contains(currQLI.Material_Item__r.PHL1__c)) {
                    msg2 += '&nbsp;&nbsp;&nbsp;&nbsp;' + miName + ': ' + currQLI.Material_Item__r.Name + ', '+ aPrice + ': ' + currQLI.Actual_Price__c + ', ' + perName + ': ' + currQLI.Per__c + ', ' + uomName +  ': ' + currQLI.UoM__c + ', ' + totalPName + ': ' + currQLI.Total_Price__c + ', ' + floorPName +': ' + currQLI.Floor_Price__c + ', ' + targetPName + ': ' + currQLI.Target_Price__c + '<br />';
                    found2 = true;
                } else if(currentUser.Product_Manager_3_PHL1s__c != null && currentUser.Product_Manager_3_PHL1s__c.contains(currQLI.Material_Item__r.PHL1__c)) {
                    msg3 += '&nbsp;&nbsp;&nbsp;&nbsp;' + miName + ': ' + currQLI.Material_Item__r.Name + ', '+ aPrice + ': ' + currQLI.Actual_Price__c + ', ' + perName + ': ' + currQLI.Per__c + ', ' + uomName +  ': ' + currQLI.UoM__c + ', ' + totalPName + ': ' + currQLI.Total_Price__c + ', ' + floorPName +': ' + currQLI.Floor_Price__c + ', ' + targetPName + ': ' + currQLI.Target_Price__c + '<br />';
                    found3 = true;
                }               
            }
        }
        
        //Finish building the Product Manager Approval Items string
        if(msg1 != '') {
            msg1 = currentUser.Product_Manager__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg1 + '<br />';
        }
        if(msg2 != '') {
            msg2 = currentUser.Product_Manager_2__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg2 + '<br />';
        }
        if(msg3 != '') {
            msg3 = currentUser.Product_Manager_3__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg3 + '<br />';
        }       
        //Save the string and which approvers need to provide approval.
        pageRecord.Product_Manager_Approval_Items__c = msg1 + msg2 + msg3;  
        pageRecord.Include_PHL1_Approver__c = found1;
        pageRecord.Include_PHL1_Approver_2__c = found2;
        pageRecord.Include_PHL1_Approver_3__c = found3; 
        
        //Only way for this to be previously approved is if it has been approved.
        return pageRecord.Approval_Status__c == 'Approved';         
    }
    
    private Boolean determinePreviouslyApproved() {
        Integer versionNumber = Integer.valueOf(pageRecord.Version_Number__c); //get version # of this scenario
        String msg1 = '', msg2 = '', msg3 = '';
        Boolean found1 = false, found2 = false, found3 = false;
        //If this has been approved, previously approved must be true
        if(pageRecord.Approval_Status__c == 'Approved') { 
            return true; 
        }
        //If it has not been approved, and the version number is > 1...
        if(versionNumber > 1) {
            /*
            String miName = Schema.SObjectType.Material_Item__c.fields.Name.label, aPrice = Schema.SObjectType.Quote_Line_Item__c.fields.Actual_Price__c.label,
                   perName = Schema.SObjectType.Quote_Line_Item__c.fields.Per__c.label, uomName = Schema.SObjectType.Quote_Line_Item__c.fields.UoM__c.label,
                   totalPName = Schema.SObjectType.Quote_Line_Item__c.fields.Total_Price__c.label, floorPName = Schema.SObjectType.Quote_Line_Item__c.fields.Floor_Price__c.label,
                   targetPName = Schema.SObjectType.Quote_Line_Item__c.fields.Target_Price__c.label;
            */
            String miName = 'Material Item', aPrice = 'Actual Price', perName = 'Per', uomName = 'UoM', totalPName = 'Total Price', floorPName = 'Floor Price', targetPName = 'Target Price';           
            //Find the scenario prior to this one.
            String vStr = (versionNumber - 1).format();
            List<Quote__c> previousQuotes = [SELECT Id, Previously_Approved__c, Quote_Amount__c FROM Quote__c WHERE Version_Number__c = :vStr AND Opportunity__c = :pageRecord.Opportunity__c];
            //If we are able to find the previous scenario and it has been "previously approved"...
            if(previousQuotes.size() > 0 && previousQuotes.get(0).Previously_Approved__c) {
                //Get the SLI for the previous scenario.
                List<Quote_Line_Item__c> sliList = [SELECT Id, Material_Item__c, Actual_Price__c, Floor_Price__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :previousQuotes.get(0).Id];
                Set<Id> belowFloorIds = new Set<Id>(); //Generate a list of material ids that are below floor in the previous version of the current scenario
                for(Quote_Line_Item__c currQLI : sliList) {
                    if(currQLI.Actual_Price__c < currQLI.Floor_Price__c) {
                        belowFloorIds.add(currQLI.Material_Item__c);
                    }
                }
                
                //Assume previouslyApproved is true and iterate over the SLI on the current Scenario
                Boolean previouslyApproved = true;
                for(Quote_Line_Item__c currQLI : queryForLines()) {
                    //If we are on a SLI where actual < floor and it isn't on the previous version...
                    if(currQLI.Actual_Price__c < currQLI.Floor_Price__c && !belowFloorIds.contains(currQLI.Material_Item__c)) {
                        previouslyApproved = false; //...then it isnt previously approved
                        //Track this item so the correct Product Manager can approve it.
                        if(currentUser.Product_Manager_1_PHL1s__c != null && currentUser.Product_Manager_1_PHL1s__c.contains(currQLI.Material_Item__r.PHL1__c)) {
                            msg1 += '&nbsp;&nbsp;&nbsp;&nbsp;' + miName + ': ' + currQLI.Material_Item__r.Name + ', '+ aPrice + ': ' + currQLI.Actual_Price__c + ', ' + perName + ': ' + currQLI.Per__c + ', ' + uomName +  ': ' + currQLI.UoM__c + ', ' + totalPName + ': ' + currQLI.Total_Price__c + ', ' + floorPName +': ' + currQLI.Floor_Price__c + ', ' + targetPName + ': ' + currQLI.Target_Price__c + '<br />';
                            found1 = true;
                        } else if(currentUser.Product_Manager_2_PHL1s__c != null && currentUser.Product_Manager_2_PHL1s__c.contains(currQLI.Material_Item__r.PHL1__c)) {
                            msg2 += '&nbsp;&nbsp;&nbsp;&nbsp;' + miName + ': ' + currQLI.Material_Item__r.Name + ', '+ aPrice + ': ' + currQLI.Actual_Price__c + ', ' + perName + ': ' + currQLI.Per__c + ', ' + uomName +  ': ' + currQLI.UoM__c + ', ' + totalPName + ': ' + currQLI.Total_Price__c + ', ' + floorPName +': ' + currQLI.Floor_Price__c + ', ' + targetPName + ': ' + currQLI.Target_Price__c + '<br />';
                            found2 = true;
                        } else if(currentUser.Product_Manager_3_PHL1s__c != null && currentUser.Product_Manager_3_PHL1s__c.contains(currQLI.Material_Item__r.PHL1__c)) {
                            msg3 += '&nbsp;&nbsp;&nbsp;&nbsp;' + miName + ': ' + currQLI.Material_Item__r.Name + ', '+ aPrice + ': ' + currQLI.Actual_Price__c + ', ' + perName + ': ' + currQLI.Per__c + ', ' + uomName +  ': ' + currQLI.UoM__c + ', ' + totalPName + ': ' + currQLI.Total_Price__c + ', ' + floorPName +': ' + currQLI.Floor_Price__c + ', ' + targetPName + ': ' + currQLI.Target_Price__c + '<br />';
                            found3 = true;
                        }                       
                    }
                }
                //If msg1,2,3 are not empty string then there are items to approve and it must go the long way.
                if(msg1 != '') {
                    msg1 = currentUser.Product_Manager__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg1 + '<br />';
                }
                if(msg2 != '') {
                    msg2 = currentUser.Product_Manager_2__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg2 + '<br />';
                }
                if(msg3 != '') {
                    msg3 = currentUser.Product_Manager_3__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg3 + '<br />';
                }               
                
                //Set the message and the previous approvers
                pageRecord.Product_Manager_Approval_Items__c = msg1 + msg2 + msg3;
                pageRecord.Include_PHL1_Approver__c = found1;
                pageRecord.Include_PHL1_Approver_2__c = found2;
                pageRecord.Include_PHL1_Approver_3__c = found3;
                
                //If there is nothing below floor on the previous version and this version is approved...
                if( belowFloorIds.size() == 0 && previousQuotes.get(0).Quote_Amount__c  < 3000000 && pageRecord.Approval_Status__c == 'Approved') {
                    return true;
                } else { //...if there are items below floor on the previous version or this isnt approved use the previouslyApproved value
                    if(pageRecord.Quote_Amount__c >= 3000000) {
                        pageRecord.Include_3_Million__c = previousQuotes.get(0).Quote_Amount__c  >= 3000000;
                        return previouslyApproved && pageRecord.Include_3_Million__c;
                    } else {
                        return previouslyApproved;
                    }
                } 
                
            //When the previous version exists, but is not in a previously approved state use the helper method.
            } else if(previousQuotes.size() > 0 && !previousQuotes.get(0).Previously_Approved__c) {
                return determinePreviouslyApprovedHelper();
            }
        } else {
            //When the version number is 1 use the helper.
            return determinePreviouslyApprovedHelper();
        }
        
        return false;
    }
    
    public List<SelectOption> getCustomerSites() {
        List<SelectOption> soList = new List<SelectOption>();
        List<Customer_Sales_Site__c> cssList = new List<Customer_Sales_Site__c>();
        if(pageRecord.Opportunity__r.AccountId != null) {
            cssList = [SELECT Id, CurrencyIsoCode, Sales_Site__r.Region_Site__c, Pricelist__c, INCO__c, Delivery_Sales_Site__c, Service_Type__c, Drilled_By__c, Customer_Group__c, Sales_Site__r.Name, Sales_Site__r.Company_Site__r.Name, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c = :pageRecord.Opportunity__r.AccountId order by Sales_Site__r.Name];
            String companyCodes = [SELECT Company_Codes__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Company_Codes__c;
            for(Customer_Sales_Site__c currCSS : cssList) {
                if(currCSS.Sales_Site__r.Region_Site__c != null && currCSS.Sales_Site__r.Company_Site__c != null && companyCodes.indexOf(currCSS.Sales_Site__r.Company_Site__r.Name) != -1) {
                    soList.add(new SelectOption(currCSS.Sales_Site__c, currCSS.Sales_Site__r.Name));
                }
            }
        }
        
        
        if(soList.size() <= 0) {
            siteChoice = '--None--';
            soList.add(new SelectOption(siteChoice, '--' + System.Label.None + '--'));
        }
        
            
        return soList;
    }

    public PageReference goToAdvancedAdd() {
        return new PageReference('/apex/SLIAdvancedAdd?scenarioID='+pageRecord.Id);
    }

    public Quote__c queryForQuote(Id filterId) {
        return [SELECT QuoteItemsBelowFlrPrice__c, EOY_Scenario__c, Being_Cloned__c, Clone_Error__c, CreatedDate, LastModifiedDate, Include_3_Million__c, Opportunity__r.OwnerId, Product_Manager_Approval_Items__c, Version_Number__c, Include_PHL1_Approver__c, Include_PHL1_Approver_2__c, Include_PHL1_Approver_3__c, Volume_to_be_Blasted__c, Volumetric_Parent_Product_UoM__c, Volumetric_Parent_Product__c, Volumetric_Per__c, Stored_Ebit__c, Quote_Valid_From__c, Quote_Valid_To__c, Previously_Approved__c, GM__c, GM_Percentage__c, CM__c, CM_Percent__c, EBIT_F__c, EBIT_F_Percent__c, Id, Active_Quote__c, Opportunity__r.Customer_Group__c, Opportunity__r.account.recordtype.developername, Opportunity__c, Quote_Amount__c, Approval_Status__c, CurrencyIsoCode, Country__c, Name, Price_Valid_From__c, Price_Valid_To__c, Opportunity__r.AccountId, Opportunity__r.RecordTypeId, Sales_Organization_Primary__r.Name, Sales_Organization_Primary__r.Company_Site__c, Sales_Organization_Primary__c, Volume_Produced__c, Volume_UoM__c, Calculated_Price__c, Quote_Description__c, Opportunity__r.Pricing_Region__c, Opportunity__r.Pricing_Sales_Office__c FROM Quote__c WHERE Id = :filterId LIMIT 1];
    }
    
    public PageReference publishToSAP(){
        
        if (pageRecord.Opportunity__r.account.recordtype.developername != 'Prospect'){
            try {
                QuoteUtil.CreatePricingCondition(pageRecord.Id);
            }
            catch (QuoteUtil.MaterialCostException me) {
                ApexPages.addMessages(me);
            }
            PageReference pr = new PageReference( '/' + pageRecord.Opportunity__c + '/e?retURL=/apex/SLIQuickAdd?id=' + pageRecord.Id);
            return pr.setRedirect(true);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_No_Publish_SAP));
            return null;
        }
    }
    
    public PageReference allocatePriceAcrossQLI() {
        if(allocatedPrice == null || allocatedPrice.trim() ==  '') {
            allocatedPrice = null;
            return null;
        }
        if(pageRecord.Calculated_Price__c == null || pageRecord.Calculated_Price__c == 0) {
            return null;
        }
        try {
            Double val = Double.valueOf(allocatedPrice);
        } catch(Exception e) {
            allocatedPrice = null;
            return null;
        }
        
        Integer numZero = 0;
        Integer numNotZero = 0;     
        Double diff = Double.valueOf(allocatedPrice) / pageRecord.Calculated_Price__c;
        transient List<Quote_Line_Item__c> quoteLineRecords = queryForLines();
        for(Quote_Line_Item__c currQli : quoteLineRecords) {
            currQli.Actual_Price__c = (currQli.Actual_Price__c * diff).setScale(2);
            if(currQli.Actual_Price__c == 0.00) {
                numZero++;
            } else if(currQli.Actual_Price__c > 0.01) {
                numNotZero++;
            }
        }
        
        //Lets say theres a list of 8, 3 zero 5 not zero
        //the zeros go to .01
        //the not zeros each need 3/5ths of a penny removed, always ceiling it
        if(numNotZero > 0) {
            for(Quote_Line_Item__c currQli : quoteLineRecords) {
                if(currQli.Actual_Price__c == 0.00) {
                    currQli.Actual_Price__c = 0.01;
                } else if(currQli.Actual_Price__c > 0.01) {
                        currQli.Actual_Price__c -= (Math.ceil(numZero/(numNotZero))/100);
                }
            }
        }
        
        update quoteLineRecords;
        quoteLineRecords = queryForLines();
        pageRecord = queryForQuote(pageRecord.Id);
        
        determineCMandTAIC(true);
        
        //Lets see where we are in terms of allocated VS calculated
        Decimal allocated = Decimal.valueOf(allocatedPrice);
        Decimal difference = 0;
        if(allocated > pageRecord.Calculated_Price__c) {
            //If calculated is less than allocated this is easy.  Pick an sli and add the difference/quantity.
            difference = allocated - pageRecord.Calculated_Price__c;
            Integer indexToUse = -1;
            
            //Added loop (2/23/2011) to prevent from picking item where quantity is 0 thus and causing division by 0 error.
            for(Integer index = 0; index < quoteLineRecords.size(); index++) {
                if(quoteLineRecords.get(index).Quantity__c != 0) {
                    indexToUse = index;
                    break;
                }
            }
            if(indexToUse != -1) {
                quoteLineRecords.get(indexToUse).Actual_Price__c += difference / quoteLineRecords.get(indexToUse).Quantity__c;
            }
        } else if(allocated < pageRecord.Calculated_Price__c) {
            //If calculated is greater than allocated this is very difficult!
            //We cant fall below 0 and we arent always guaranteed to be able to not fall below 0.
            //Just do your best and if it doesnt work out throw an error.
            difference = pageRecord.Calculated_Price__c - allocated;
            Boolean done = false;
            for(Quote_Line_Item__c currQli : quoteLineRecords) {
                if(!done && currQLI.Quantity__c != 0 && (currQli.Actual_Price__c - (difference/currQli.Quantity__c)) >= 0.01) {
                    currQli.Actual_Price__c -= difference/currQli.Quantity__c;
                    done = true;
                }
            }
        }
        
        if(difference != 0) {
            update quoteLineRecords;
            //quoteLineRecords = queryForLines();//QuoteUtil.queryForChildRecordsByQuote(pageRecord.Id);
            pageRecord = queryForQuote(pageRecord.Id);
            determineCMandTAIC(true);
            if(allocated != pageRecord.Calculated_Price__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Quick_Add_No_Price));
            }           
        }
        
        calculatePreviouslyApproved();
        return null;
    }

/*
    public PageReference createNewVersionOfQuote() {
        
        Quote__c c = QuoteUtil.cloneScenario(pageRecord.Id, true);
        return new PageReference('/apex/SLIQuickAdd?id=' + c.Id);
        
    }
*/

    private List<Quote_Line_Item__c> queryForLines() {
        return [SELECT Id, Name, Per__c, UoM__c, Floor_Price__c, Target_Price__c, Actual_Price__c, Total_Price__c, Material_Item__c, Quantity__c, Is_Bundled__c, Material_Item__r.Name, Material_Item__r.PHL1__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :pageRecord.Id order by Material_Item__r.PHL1__c asc, Material_Item__r.Material_Description__c asc];
    }
    
    public PageReference reactivateVersionOfQuote() {
        return (new PageReference('/apex/CreateNewScenarioVersionPage?reactivate=y&scenarioId='+pageRecord.Id)).setRedirect(true);  
    }
        
    private void determineRenders() {
        areQli = false;
        areBs = false;
        for(Quote_Line_Item__c currQli : queryForLines()) {
            if(currQli.Is_Bundled__c) {
                areBs = true;
            }
            if(!currQli.Is_Bundled__c) {
                areQli = true;
            }                       
        }
    }

    public PageReference editQLI() {
        if(System.currentPageReference().getParameters().get('editQLI') == null) {
            return null;
        }
        String recordId = System.currentPageReference().getParameters().get('editQLI');
        return new PageReference('/apex/SLIAdvancedAdd?scenarioID=' + pageRecord.Id + '&sliID=' + recordId);
    }

    public PageReference deleteQLI() {
        String recordId = System.currentPageReference().getParameters().get('deleteQLI');
        for(Quote_Line_Item__c qli : queryForLines()) {
            if(recordId == qli.Id) {
                delete qli;
            }
        }
        //quoteLineRecords = queryForLines();//QuoteUtil.queryForChildRecordsByQuote(pageRecord.Id);
        pageRecord = queryForQuote(pageRecord.Id);
        determineCMandTAIC(true);
        calculatePreviouslyApproved();
        determineRenders();
        updatePaginator();
        return null;
    }   

    public List<Quote_Line_Item__c> getBundledServices() {
        List<Id> idList = new List<Id>();
        
        for(Quote_Line_Item__c currQli : queryForLines()) {
            if(currQli.Is_Bundled__c) {
                idList.add(currQli.Id); 
            }
        }
        
        if(idList.size() == 0) {
            return null;
        }
        
        return [SELECT Price_Valid_To__c, Id, Material_Item__r.PHL1__c, Material_Item__c, Quantity__c, Actual_Price__c, Extended__c, Total_Price__c, Per__c, UoM__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Id in :idList order by Material_Item__r.PHL1__c asc, Material_Item__r.Material_Description__c asc];
    }

    public List<Quote_Line_Item__c> getMaterials() {
        List<Id> idList = new List<Id>();
        for(Quote_Line_Item__c currQli : queryForLines()) {
            if(!currQli.Is_Bundled__c){
                idList.add(currQli.Id);
            }
        }
        
        if(idList.size() == 0) {
            return null;
        }
        
        return [SELECT Price_Valid_To__c, Id, Material_Item__r.PHL1__c, Material_Item__c, Quantity__c, Floor_Price__c, Target_Price__c, Actual_Price__c, Formula_Flag__c, Extended__c, Total_Price__c, Per__c, UoM__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Id in :idList order by Material_Item__r.PHL1__c asc, Material_Item__r.Material_Description__c asc];
    }
    
    public List<SelectOption> getPHL1Options() {
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
        for(Product_Grouping__c currPg : [SELECT Name, Title__c FROM Product_Grouping__c order by Name asc]) {
            soList.add(new SelectOption(currPg.Name, currPg.Name + ' - ' + currPg.Title__c));
        }
        return soList;
    }
    
    public List<SelectOption> getPHL2Options() {
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
        if(selectedPHL1 != '--None--') {
            for(PHL2__c currPHL : [SELECT PHL2__c, Full_PHL2__c, Description__c FROM PHL2__c WHERE PHL1__c = :selectedPHL1 order by Full_PHL2__c asc]) {
                soList.add(new SelectOption(currPHL.PHL2__c, currPHL.Full_PHL2__c + ' - ' + currPHL.Description__c));
            }
        }
        return soList;
    }   
    
    public PageReference setPHL2andPHL3ToNone() {
        selectedPHL2 = '--None--';
        return setPHL3ToNone(); 
    }
    
    public PageReference setPHL3ToNone() {
        selectedPHL3 = '--None--';
        return null;
    }
    
    public List<SelectOption> getPHL3Options() {
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
        if(selectedPHL1 != '--None--' && selectedPHL2 != '--None--') {
            for(PHL3__c currPHL : [SELECT PHL3__c, Full_PHL3__c, Description__c FROM PHL3__c WHERE PHL1__c = :selectedPHL1 AND PHL2__c = :selectedPHL2 order by Full_PHL3__c asc]) {
                soList.add(new SelectOption(currPHL.PHL3__c, currPHL.Full_PHL3__c + ' - ' + currPHL.Description__c));
            }
        }
        return soList;
    }       

    public PageReference obtainAUMForSelectedStandard() {
        Id matId = (Id) ApexPages.currentPage().getParameters().get('materialID');
        
        for(ScenarioLine sl : paginator.getAll()) {
            if(sl.isSelected && sl.miRecord.Id == matId && sl.aumRecords.size() == 0) {
                sl.availableUoMs.clear();
                for(Alternate_Unit_of_Measure__c currAum : [SELECT Id, Name, X__c, Y__c, AUn__c, BUn__c, Material_Item__c  FROM Alternate_Unit_of_Measure__c WHERE Material_Item__c = :matId AND BUn__c = :sl.uom order by AUn__c]) {
                    sl.availableUoMs.add(new SelectOption(currAum.AUn__c, currAum.AUn__c));
                    sl.aumRecords.add(currAum);
                }
                sl.sli.UoM__c = sl.uom;
            }
        } 
        
        return null;
    }
    
    public PageReference getMaterialsByPHL1() {
        List<ScenarioLine> slList = new List<ScenarioLine>();
        paginator.setRecords(slList);
        ScenarioLine temp;
        List<SelectOption> soList;

        List<PricingEngine.PricingData> pdList = new List<PricingEngine.PricingData>();
            
        String errorMessage = 'The following items cannot be shown because they do not have a cost for these materials: ';
        Boolean first = true;
        Boolean addable;
        List<Quote_Line_Item__c> tempQLIList = queryForLines();
        List<PricingEngine.PricingData> myPD = PricingEngine.getPricingData(pageRecord.Opportunity__r.AccountId, pageRecord.Sales_Organization_Primary__c, selectedPHL1, false, pageRecord.Price_Valid_From__c, pageRecord.Price_Valid_To__c, pageRecord.Sales_Organization_Primary__r.Company_Site__c, true, pageRecord.Opportunity__r.Customer_Group__c, pageRecord.Sales_Organization_Primary__c, selectedPHL2, selectedPHL3, new CurrencyData(' ', -1),pageRecord.Opportunity__r.Pricing_Region__c,pageRecord.Opportunity__r.Pricing_Sales_Office__c);
        System.Debug('Lucian Debug: myPD:' + myPD);
        for(PricingEngine.PricingData currPd : myPD) {
            if(currPd.costData != null && currPd.rule.Material_Item__r.Product_Hierarchy__c != currPd.rule.Material_Item__r.Material_Code__c) {
                //Only add ones where there isnt a qli with the currPd.rule.Material_Item__c
                addable = true;
                for(Quote_Line_Item__c currQli : tempQLIList) {
                    if(currQli.Material_Item__c == currPd.rule.Material_Item__c) {
                        addable = false;
                    }
                }
                if(addable) {
                    pdList.add(currPd);
                }
            } else if(currPd.rule.Material_Item__r.Product_Hierarchy__c != currPd.rule.Material_Item__r.Material_Code__c) {
                if(!first) {
                    errorMessage += ', ';
                }
                first = false;
                errorMessage += currPd.rule.Material_Item__r.Name;
            }
        }
        
        if(!first) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
        List<String> baseUoMs = new List<String>();
        String query = 'SELECT AUn__c, BUn__c, X__c, Y__c, Material_Item__c FROM Alternate_Unit_of_Measure__c WHERE';
        Integer count = 0;
        System.Debug('Lucian Debug: pdList:' + pdList);
        for(PricingEngine.PricingData currPd: pdList) {
            if(currPd.costData.uom != null) {
                if(count > 0) {
                    query += ' OR';
                }
                query += ' (Material_Item__c = \'' + currPd.costData.miRecord.Id + '\' AND BUn__c = \'' + currPd.costData.uom + '\')';
                count++;    
            }
        }
        if(count > 0) {
            List<Alternate_Unit_of_Measure__c> aumList = Database.query(query);
            Map<String, Alternate_Unit_of_Measure__c> stringToAum = new Map<String, Alternate_Unit_of_Measure__c>();
            for(Alternate_Unit_of_Measure__c aum : aumList) {
                stringToAum.put(aum.Material_Item__c + '|' + aum.BUn__c + '|' + aum.AUn__c, aum);
            }
            System.Debug('Lucian Debug: Number Of pdList:' + pdList.size());
            for(PricingEngine.PricingData currPd: pdList) {
                temp = new ScenarioLine();
                temp.notAtPrimarySite = currPd.costData.extendedToSite;
                temp.miRecord = currPd.costData.miRecord;
                temp.sli = new Quote_Line_Item__c();
                temp.sli.Base_Floor__c = currPd.rule.Floor_Price__c;
                temp.sli.Base_Target__c = currPd.rule.Target_Price__c;
                if(currPd.costData.uom != null) {
                    //Find the AUM for this material item, BUN from costData.uom, AUN from Pricing Rule UOM
                    //If you dont find it, throw error
                    if(stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom) != null) {
                        if (currPd.costData.cost3m != null && currPd.costData.cost3m != 0)
                            temp.sli.Base_Cost__c = currPd.costData.cost3m * (stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).X__c/stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).Y__c);
                        else if (currPd.costData.cost6m != null && currPd.costData.cost6m != 0)
                            temp.sli.Base_Cost__c = currPd.costData.cost6m * (stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).X__c/stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).Y__c);
                        else
                            temp.sli.Base_Cost__c = currPd.costData.cost * (stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).X__c/stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).Y__c);
                        temp.sli.Base_Cost_ST__c = currPd.costData.seeThroughCost * (stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).X__c/stringToAum.get(currPd.costData.miRecord.Id + '|' + currPd.costData.uom + '|' + currPd.uom).Y__c);                
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The row for ' + currPd.costData.miRecord.Material_Description__c + ' could not be shown.  Please add the conversion from ' + currPd.costData.uom + ' to ' + currPd.uom + '.'));
                        continue;
                    }
                    
                } else {
                    if (currPd.costData.cost3m != null && currPd.costData.cost3m != 0)
                        temp.sli.Base_Cost__c = currPd.costData.cost3m;
                    else if (currPd.costData.cost6m != null && currPd.costData.cost6m != 0)
                        temp.sli.Base_Cost__c = currPd.costData.cost6m;
                    else
                        temp.sli.Base_Cost__c = currPd.costData.cost;
                    temp.sli.Base_Cost_ST__c = currPd.costData.seeThroughCost;
                }
                temp.avgSellPrice = currPd.averageSalesPrice;
                temp.per = currPd.per;
                temp.uom = currPd.uom;
                temp.id = currPd.rule.Id;
                temp.salesSite = currPd.rule.Receiving_Sales_Site__c;           
                temp.sli.UoM__c = currPd.uom;
                temp.sli.Per__c = currPd.rule.Per__c;
                temp.sli.Cost__c = temp.sli.Base_Cost__c/(1/temp.sli.Per__c);
                temp.sli.Cost_See_Through__c = temp.sli.Base_Cost_ST__c/(1/temp.sli.Per__c);
                temp.sli.Floor_Price__c = temp.sli.Base_Floor__c/(temp.per/temp.sli.Per__c);
                temp.sli.Target_Price__c = temp.sli.Base_Target__c/(temp.per/temp.sli.Per__c);
                temp.sli.Actual_Price__c = temp.sli.Target_Price__c;
                temp.sli.Quantity__c = 1;       
                temp.sli.Quote__c = pageRecord.Id;
                temp.sli.Country__c = pageRecord.Country__c;
                temp.sli.CurrencyIsoCode = pageRecord.CurrencyIsoCode;
                temp.sli.Material_Item__c = temp.miRecord.Id;
                temp.sli.Price_Valid_From__c = pageRecord.Price_Valid_From__c;
                temp.sli.Price_Valid_To__c = pageRecord.Price_Valid_To__c;
                temp.sli.Pricing_Rule__c = temp.id;
                temp.sli.Sales_Site__c = pageRecord.Sales_Organization_Primary__c;
                temp.sli.Source_Sales_Site__c = pageRecord.Sales_Organization_Primary__c;               
                soList = new List<SelectOption>();
                temp.aumRecords = new List<Alternate_Unit_of_Measure__c>();
                soList.add(new SelectOption(currPd.uom, currPd.uom));
                temp.availableUoMs = soList;
                slList.add(temp);
            } 
                
            paginator.setRecords(slList);
        }
        return null;
    }
    
    public PageReference getMaterialsBySite() {
        formulaList = new List<FormulaLine>();
        String errorMessage = System.Label.Quick_Add_No_Cost;
        Boolean first = true;       
        
        if(siteChoice != '--None--') {
            List<PricingEngine.FormulaPricingData> fpdList = new List<PricingEngine.FormulaPricingData>();
            Boolean addable;
            for(PricingEngine.FormulaPricingData currFpd : PricingEngine.getFormulaPricingData(pageRecord.Opportunity__r.AccountId, pageRecord.Sales_Organization_Primary__c, (Id)siteChoice)) {
                
                if(currFpd.costData != null && currFpd.mapping.Formula__r.Material_Item__r.Product_Hierarchy__c != currFpd.mapping.Formula__r.Material_Item__r.Material_Code__c) {
                    addable = true;
                    for(Quote_Line_Item__c currQli : queryForLines()) {
                        if(currFpd.materialId == currQli.Material_Item__c) {
                            addable = false;
                        }
                    }
                    if(addable) {
                        fpdList.add(currFpd);
                    }
                } else if(currFpd.mapping.Formula__r.Material_Item__r.Product_Hierarchy__c != currFpd.mapping.Formula__r.Material_Item__r.Material_Code__c) {
                    if(!first) {
                        errorMessage += ', ';
                    }
                    first = false;
                    errorMessage += currFpd.mapping.Formula__r.Material_Item__r.Name;
                }
            }
            
            if(!first) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
                        
            List<Id> materialIds = new List<Id>();
            for(PricingEngine.FormulaPricingData fpd : fpdList) {
                materialIds.add(fpd.materialId);
            }
            //List<Alternate_Unit_of_Measure__c> aumList = [SELECT Id, Name, X__c, Y__c, AUn__c, BUn__c , Material_Item__c FROM Alternate_Unit_of_Measure__c WHERE Material_Item__c in :materialIds];
            FormulaLine temp;
            List<SelectOption> soList;
            Integer counter = 0;
            for(PricingEngine.FormulaPricingData fpd : fpdList) {
                temp = new FormulaLine();
                temp.isSelected = false;
                temp.fpd = fpd;
                temp.materialCode = fpd.mapping.Formula__r.Material_Item__r.Material_Code__c;
                temp.materialDesc = fpd.mapping.Formula__r.Material_Item__r.Material_Description__c;
                temp.materialPref = fpd.mapping.Formula__r.Material_Item__r.Preferred__c;
                temp.id = (counter++) + '';
                temp.notAtPrimarySite = fpd.mapping.Sales_Site__c == pageRecord.Sales_Organization_Primary__c;
                temp.sli = new Quote_Line_Item__c();
                temp.sli.Per__c = fpd.per;
                temp.sli.Formula_Flag__c = true;
                temp.sli.Actual_Price__c = fpd.actualPrice / (fpd.per/temp.sli.Per__c);
                temp.sli.Formula__c = fpd.mapping.Formula__c;
                temp.sli.Quantity__c = 1;
                temp.sli.UoM__c = fpd.uom;
                soList = new List<SelectOption>();
                temp.aumRecords = new List<Alternate_Unit_of_Measure__c>();
                soList.add(new SelectOption('--None--', '--' + System.Label.None + '--'));
                temp.fpd.uom = '--None--';
                temp.availableUoMs = soList;
                formulaList.add(temp);                                          
            }
        }
        
        return null;
    }
    
    public PageReference addSelected() {
        System.debug('Adding selected');
        List<Quote_Line_Item__c> toAdd = new List<Quote_Line_Item__c>();
        //List<Quote_Line_Item__c> toReject = new List<Quote_Line_Item__c>();
        List<ScenarioLine>         toReject = new List<ScenarioLine>();
        List<FormulaLine>          toRejectFormula = new List<FormulaLine>();
        Quote_Line_Item__c tempSli;
        if(paginator.getAll() != null && paginator.getAll().size() > 0) {
            for(ScenarioLine sl : paginator.getAll()) {
                if(sl != null && sl.isSelected != null && sl.isSelected) {
                    tempSli = new Quote_Line_Item__c();
                    tempSli = sl.sli;

                    if(sl.notAtPrimarySite == null) {
                        tempSli.Extended__c = tempSli.Source_Sales_Site__c == sl.salesSite;
                    } else {
                        tempSli.Extended__c = sl.notAtPrimarySite;
                    }   
                        
                    if(sl.sli.UoM__c == null || sl.sli.UoM__c == '--None--' || sl.sli.UoM__c.trim() == '') {
                        toReject.add(sl);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_Invalid_UOM));              
                    } else if(sl.sli.Quantity__c < 0) {
                        toReject.add(sl);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_Qty_Greater_0));
                    } else if(sl.sli.Actual_Price__c == 0) {
                        toReject.add(sl);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_Price_Greater_0));                      
                    } else {
                        toAdd.add(tempSli);
                    }   
                }
            }
        }
        for(FormulaLine fl : formulaList) {
            if(fl.isSelected) {
                tempSli = new Quote_Line_Item__c();
                tempSli = fl.sli;
                tempSli.Quote__c = pageRecord.Id;
                if (fl.fpd.costData.cost3m != null && fl.fpd.costData.cost3m != 0)
                    tempSli.Cost__c = fl.fpd.costData.cost3m;
                else if (fl.fpd.costData.cost6m != null && fl.fpd.costData.cost6m != 0)
                    tempSli.Cost__c = fl.fpd.costData.cost6m;
                else
                    tempSli.Cost__c = fl.fpd.costData.cost;
                tempSli.Cost_See_Through__c = fl.fpd.costData.seeThroughCost;
                tempSli.Country__c = pageRecord.Country__c;
                tempSli.CurrencyIsoCode = pageRecord.CurrencyIsoCode;
                tempSli.Material_Item__c = fl.fpd.materialId;
                tempSli.Price_Valid_From__c = pageRecord.Price_Valid_From__c;
                tempSli.Price_Valid_To__c = pageRecord.Price_Valid_To__c;
                tempSli.Sales_Site__c = pageRecord.Sales_Organization_Primary__c;
                tempSli.Source_Sales_Site__c = siteChoice;
                if(fl.fpd.costData.extendedToSite == null) {
                    tempSli.Extended__c = false;
                } else {
                    tempSli.Extended__c = fl.fpd.costData.extendedToSite;   
                }
                
                if(fl.sli.Quantity__c < 1){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_Formulaic_Qty_Greater_0));
                    toRejectFormula.add(fl);
                } else if(fl.sli.UoM__c == null || fl.sli.UoM__c == '--None--') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_Invalid_UOM));                              
                    toRejectFormula.add(fl);
                } else if(fl.sli.Actual_Price__c == 0) {
                    toRejectFormula.add(fl);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quick_Add_Price_Greater_0));      
                } else {
                    toAdd.add(tempSli);
                }
                
            }
        }
        
        if(toAdd.size() > 0) {
            insert toAdd;
            update pageRecord;
            //quoteLineRecords = queryForLines();//QuoteUtil.queryForChildRecordsByQuote(pageRecord.Id);
        }

        //HERE I WANT TO SET THE RECORDS THE PAGINATOR USES TO BE THE REJECTED SET
        formulaList = new List<FormulaLine>();
        formulaList.addAll(toRejectFormula);
        for(FormulaLine currFl : formulaList) {
            currFl.isSelected = false;
        }
        for(ScenarioLine currSl : toReject) {
            currSl.isSelected = false;
        }
        if (toReject.size() > 0){
            paginator.setRecords(toReject);
        }
        //siteChoice = '--None--';
        //selectedPHL1 = '--None--';
        getMaterialsBySite();
        getMaterialsByPHL1();
        determineRenders();
        pageRecord = queryForQuote(pageRecord.Id);
        determineCMandTAIC(true);
        calculatePreviouslyApproved();
        updatePaginator();
        return null;
    }
    
    public PageReference markAccepted() {
        pageRecord.Quote_Accepted_By_Customer__c = 'Yes';
        update pageRecord;
        //Opportunity parentOpp = [SELECT StageName, Who_Won__c FROM Opportunity WHERE Id = :pageRecord.Opportunity__c LIMIT 1];
        //parentOpp.StageName = 'Closed Won';
        //parentOpp.Who_Won__c = 'Dyno Nobel';
        //parentOpp.Reason__c = 'Select a Reason';
        //update parentOpp;
        PageReference pr = new PageReference('/apex/SLIQuickAdd?id=' + pageRecord.Id);
        return pr.setRedirect(true);
    }

    public PageReference goToDocumentPage() {
        return new PageReference('/apex/UsefulDocumentPage?quoteID=' + pageRecord.Id);
    }
    
    public PageReference goToQCCreate() {
        return new PageReference('/apex/ScenarioContactPage?id=' + pageRecord.Id);
    }   

    public PageReference saveEmailSelection() {
        update quoteContactList;
        return null;
    }

    public PageReference markOneAsPrimary() {
        String primaryContact = ApexPages.currentPage().getParameters().get('primaryContact');
        
        for(Quote_Contact__c currQC : quoteContactList) {
            if(primaryContact == currQC.Id) {
                currQC.Primary_Recipient__c = true;
            } else {
                currQC.Primary_Recipient__c = false;
            }
        }
        
        return null;
    }
    
    public PageReference emailCSR(){
        String primaryEmail = '';
        String ccList = '';
        
        for(Quote_Contact__c currQC : quoteContactList) {
            if(currQC.Primary_Recipient__c) {
                primaryEmail = currQC.Contact__c;
            }
            if(ccList == '' && currQC.Selected__c && !currQC.Primary_Recipient__c) {
                ccList += currQC.Contact__r.Email;
            } else if(currQC.Selected__c && !currQC.Primary_Recipient__c){
                ccList += ', ' + currQC.Contact__r.Email;
            }
        }

        if (ccList != ''){
            return new PageReference('/_ui/core/email/author/EmailAuthor?p2_lkid='+ primaryEmail +'&rtype=003&p3_lkid='+pageRecord.Id+'&p3_mlktp=' + Schema.SObjectType.Quote__c.getKeyPrefix() + '&p4='+   ccList + '&Id='+ pageRecord.Id + '&retURL=/apex/SLIQuickAdd?id=' + pageRecord.Id);  
        }
        return new PageReference('/_ui/core/email/author/EmailAuthor?p2_lkid='+ primaryEmail +'&rtype=003&p3_lkid='+pageRecord.Id+'&p3_mlktp=' + Schema.SObjectType.Quote__c.getKeyPrefix() + '&Id='+ pageRecord.Id +'&retURL=/apex/SLIQuickAdd?id=' + pageRecord.Id);
    }   
    
    /* THESE ARE GENERIC PAGINATION METHODS */
    
    private List<ScenarioLineItem> sliList;
    
    public List<ScenarioLineItem> getCurrentPageOfRecords() {
        List<Quote_Line_Item__c> temprecs = (List<Quote_Line_Item__c>) setCtrl.getRecords();
        sliList = new List<ScenarioLineItem>();
        for (Quote_Line_Item__c temprec : temprecs)
            sliList.add(new ScenarioLineItem(temprec));
        return sliList;
    }
    
    private List<Quote_Line_Item__c> getCurrentPageOfRecordsList() {
        return (List<Quote_Line_Item__c>) setCtrl.getRecords();
    }
    
    public class ScenarioLineItem {
        public Quote_Line_Item__c item { get; set; }
        public Boolean deleteItem { get; set; }
        public ScenarioLineItem(Quote_Line_Item__c i) {
            item = i;
            deleteItem = false;
        }
    }
    
    /**
     * Goes to the next page of records in the preview table.
     *
     * @return PageReference - required for action methods.
     */
    public PageReference nextPage() {
        setCtrl.next();
        return null;
    }

    /**
     * Goes to the previous page of records in the preview table.
     *
     * @return PageReference - required for action methods.
     */ 
    public PageReference prevPage() {
        setCtrl.previous();
        return null;
    }
    
    /* The current page number in the preview table */
    public Integer getCurrentPageNumber {
        get {
            if(setCtrl == null) {
                return 0;
            } else {
                return setCtrl.getPageNumber();
            }
        }
    }
    
    /* The total number of pages in the preview table */
    public Integer getTotalPages {
        get {
            if(setCtrl == null) {
                return 0;
            } else {
                if(Math.mod(setCtrl.getResultSize(), ROWS_PER_PAGE) == 0) {
                    return setCtrl.getResultSize() / ROWS_PER_PAGE;
                } else {
                    return (setCtrl.getResultSize() / ROWS_PER_PAGE) + 1;
                }
            }
        }
    }
    
    /* True when the user can page backwards */
    public Boolean hasPrev {
        get {
            if(setCtrl == null) {
                return false;
            } else {            
                return setCtrl.getHasPrevious();
            }
        }
    }
    
    /* True when the user can page forwards */
    public Boolean hasNext {
        get {
            if(setCtrl == null) {
                return false;
            } else {            
                return setCtrl.getHasNext();
            }
        }
    }   
    
    public void DeleteSLIS() {
        List<Quote_Line_Item__c> SLIs = new List<Quote_Line_Item__c>();
        for (ScenarioLineItem sli : sliList)
            if (sli.deleteItem)
                SLIs.add(sli.item);
        delete SLIs;
        
        pageRecord = queryForQuote(pageRecord.Id);
        determineCMandTAIC(true);
        calculatePreviouslyApproved();
        determineRenders();
        updatePaginator();
    }
    
    public class FormulaLine {
        public PricingEngine.FormulaPricingData fpd {get; set;}
        public Quote_Line_Item__c sli {get; set;}
        public Boolean isSelected {get; set;}
        public Boolean notAtPrimarySite {get; set;}
        public List<SelectOption> availableUoMs {get; set;}
        public String materialCode {get; set;}
        public String materialDesc {get; set;}
        public Boolean materialPref {get; set;}
        public List<Alternate_Unit_of_Measure__c> aumRecords {get; set;}
        public String id {get; set;}        
    }
    
    public class ScenarioLine {
        public Quote_Line_Item__c sli {get; set;}
        public Id salesSite {get; set;}
        public Boolean isSelected {get; set;}
        public Boolean notAtPrimarySite {get; set;} //Make this hold extended...
        public Material_Item__c miRecord {get; set;}
        public List<SelectOption> availableUoMs {get; set;}
        public List<Alternate_Unit_of_Measure__c> aumRecords {get; set;}
        public String id {get; set;} // Rule Id
        public String uom {get; set;} // Base UoM from Rule
        public Double avgSellPrice {get; set;} // Average Sell Price From Rule
        public Integer per {get; set;} // Per from rule
    }
}