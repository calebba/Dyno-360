public with sharing class EBITReporting {
    
    public Quote__c dummyQuote {get; set;}
    public Account dummyAccount {get; set;}
    public Sales_Site__c dummySalesSite {get; set;}
    public List<String> siteIds {get; set;}
    public List<String> customersIds { get; set; }
    public String salesOfficeValue { get; set; }
    public List<SelectOption> selectedCustomersOptions { get; set; }
    public List<String> selectedCust { get; set; }
    public EBITData.EBITDataHelper edh;
    public PandLData plDataReport { get; set; }
    public Boolean isGenerated { get; set; }
    //public String selectedPlant { get; set;}
    //public String plantsString;
    //public List<String> plantsOptions;
    
    public Boolean showGenerateButton { 
        get{
            return (selectedCustomersOptions.size() > 0 || (dummySalesSite.SalesOffice_String__c !=null && dummySalesSite.SalesOffice_String__c !='') || (dummyAccount.Account_Manager__c !=null && dummyAccount.Account_Manager__c !='') || (dummyAccount.Industry !=null && dummyAccount.Industry !=''));
        }
        set; 
    }
    public Boolean showGeneratePdfButton { get; set; }
    public Set<Id> accountIdsList;
    public Set<Id> sitesIdsList;
    public Set<Id> shipToIdsList;
    public String accountIdsString { get; set; }
    public String sitesIdsListString { get; set; }
    public String shipToIdsListString { get; set; }

    public Boolean showCustomerLookup { 
        get{
            return !((dummyAccount.Account_Manager__c !=null && dummyAccount.Account_Manager__c !='') || (dummyAccount.Industry !=null && dummyAccount.Industry !=''));
        }
        set; 
    }
    
    public Boolean showCustomerList { 
        get{
            System.debug('showCustomerList:::' + ((dummyAccount.Account_Manager__c !=null && dummyAccount.Account_Manager__c !='') || (dummyAccount.Industry !=null && dummyAccount.Industry !='')));
            return (dummyAccount.Account_Manager__c !=null && dummyAccount.Account_Manager__c !='') || (dummyAccount.Industry !=null && dummyAccount.Industry !='');
        }
        set; 
    }
    
    public boolean accountEditable {
        get {
            return (salesOfficeValue == '--None--');
        }
    }
    
    /*public boolean salesOfficeEditable {
        get {
            System.debug('salesOfficeEditable:::' + ((dummyAccount.Account_Manager__c ==null || dummyAccount.Account_Manager__c =='') && (dummyAccount.Industry ==null || dummyAccount.Industry =='')));
            return (dummyAccount.Account_Manager__c ==null || dummyAccount.Account_Manager__c =='') && (dummyAccount.Industry ==null || dummyAccount.Industry =='');
        }
    }
    
    public boolean accountManagerEditable {
        get {
            return salesOfficeValue == '--None--' && (dummyAccount.Industry == null || dummyAccount.Industry == '');
        }
    }
    
    public boolean industryEditable {
        get {
            return (dummyAccount.Account_Manager__c ==null || dummyAccount.Account_Manager__c =='') && salesOfficeValue == '--None--';
        }
    }*/
    
    public EBITReporting() {
        //plantsOptions = new List<String>();
        dummyQuote = new Quote__c();
        dummyAccount = new Account();
        dummySalesSite = new Sales_Site__c();
        dummyQuote.Price_Valid_From__c = Date.Today().addyears(-1);
        dummyQuote.Price_Valid_To__c = Date.Today().addmonths(-1);
        selectedCustomersOptions = new List<SelectOption>();
        customersIds = new List<String>();
        siteIds = new List<String>();
        salesOfficeValue = '--None--';
        SetDefaultCurrency();
        isGenerated = false;
        System.debug(':::' + dummyAccount.Account_Manager__c);
    }
    
    // -- BEGIN -- Customer Number / Name / Account group functionality
    private String dummyQuoteCustomerNumber_private;
    public String dummyQuoteCustomerNumber {
        get {
            return dummyQuoteCustomerNumber_private;
        }
        set {
            if (dummyQuoteCustomerNumber_private == '') dummyQuoteCustomerNumber_private = null;
            if (value == '') value = null;
            if (dummyQuoteCustomerNumber_private != value) {
                customernumberchanged = true;
                dummyQuoteCustomerNumber_private = value;
            }
        }
    }
    boolean customernumberchanged = false;
    public void setCustomerNumber() {
        if (customernumberchanged) {
            customernumberchanged = false;
            if (dummyQuoteCustomerNumber_private == null || dummyQuoteCustomerNumber_private == '') {
                dummyQuote.Customer__c = null;
                customerAccountGroup = '';
                return;
            }
            try {
                Account xCust = [SELECT Id, Account_Group__c, Name FROM Account WHERE SAP_Account_Number__c = :dummyQuoteCustomerNumber_private LIMIT 1];
                dummyQuote.Customer__c = xCust.Id;
                customerAccountGroup = xCust.Account_Group__c;
                selectedCustomerName = xCust.Name;
            } catch (Exception ex) {
                dummyQuote.Customer__c = null;
                customerAccountGroup = '';
            }
        }
    }
    public string customerAccountGroup {get;set;}
    public void setQuoteCustomer() {
        try {
            Account xCust = [SELECT SAP_Account_Number__c, Name, Account_Group__c FROM Account WHERE Id = :dummyQuote.Customer__c LIMIT 1];
            dummyQuoteCustomerNumber_private = xCust.SAP_Account_Number__c;
            customerAccountGroup = xCust.Account_Group__c;
            selectedCustomerName = xCust.Name;
        } catch (Exception ex) {
            dummyQuoteCustomerNumber_private = null;
            customerAccountGroup = '';
        }
    }
    private string selectedCustomerName;
    
    
    // -- BEGIN -- Report from and to functionality
    public List<SelectOption> getMonths() {
        List<SelectOption> monthsList = new List<SelectOption>();
        monthsList.add(new SelectOption('1', 'January'));
        monthsList.add(new SelectOption('2', 'February'));
        monthsList.add(new SelectOption('3', 'March'));
        monthsList.add(new SelectOption('4', 'April'));
        monthsList.add(new SelectOption('5', 'May'));
        monthsList.add(new SelectOption('6', 'June'));
        monthsList.add(new SelectOption('7', 'July'));
        monthsList.add(new SelectOption('8', 'August'));
        monthsList.add(new SelectOption('9', 'September'));
        monthsList.add(new SelectOption('10', 'October'));
        monthsList.add(new SelectOption('11', 'November'));
        monthsList.add(new SelectOption('12', 'December'));
        return monthsList;
    }
    
    public List<SelectOption> getYears() {
        List<SelectOption> yearsList = new List<SelectOption>();
        integer currentyear = Date.Today().year();
        for (integer i = currentyear - 10; i < currentyear + 10; i++)
            yearsList.add(new SelectOption(string.valueof(i), string.valueof(i)));
        return yearsList;
    }
    
    public integer monthFrom {
        get {
            return dummyQuote.Price_Valid_From__c.month();
        }
        set {
            dummyQuote.Price_Valid_From__c = Date.newInstance(dummyQuote.Price_Valid_From__c.Year(), value, 1);
        }
    }
    
    public integer monthTo {
        get {
            return dummyQuote.Price_Valid_To__c.month();
        }
        set {
            dummyQuote.Price_Valid_To__c = Date.newInstance(dummyQuote.Price_Valid_To__c.Year(), value, Date.daysInMonth(dummyQuote.Price_Valid_To__c.Year(), value));
        }
    }
    
    public integer yearFrom {
        get {
            return dummyQuote.Price_Valid_From__c.year();
        }
        set {
            dummyQuote.Price_Valid_From__c = Date.newInstance(value, dummyQuote.Price_Valid_From__c.month(), 1);
        }
    }
    
    public integer yearTo {
        get {
            return dummyQuote.Price_Valid_To__c.year();
        }
        set {
            dummyQuote.Price_Valid_To__c = Date.newInstance(value, dummyQuote.Price_Valid_To__c.month(), Date.daysInMonth(value, dummyQuote.Price_Valid_To__c.month()));
        }
    }
    // -- END -- Report from and to functionality
    // -- BEGIN -- Currency functionality
    public string currentCurrency {get;set;}
    private void SetDefaultCurrency() {
        currentCurrency = UserInfo.getDefaultCurrency();
    }
    // -- END -- Currency functionality 
    
    //All sites should always be able to be chosen
    public List<SelectOption> getSiteOptions() {
        List<SelectOption> soList = new List<SelectOption>();
        Set<Id> custIds = new Set<Id>();
        System.debug('selectedCustomersOptions0:::' + selectedCustomersOptions);
        System.debug('customersIds:::' + customersIds);
        System.debug('dummySalesSite.SalesOffice_String__c:::' + dummySalesSite.SalesOffice_String__c);
        if (selectedCustomersOptions.size() > 0) {
            for (integer i = 0; i < selectedCustomersOptions.size(); i++) {
                custIds.add(selectedCustomersOptions.get(i).getValue());
            }
        } else if (customersIds.size() > 0) {
            custIds = getCustomerIdsSet();
        }
        if (dummySalesSite.SalesOffice_String__c != null && dummySalesSite.SalesOffice_String__c != '' && (dummyAccount.Account_Manager__c == null || dummyAccount.Account_Manager__c == '') && (dummyAccount.Industry == null || dummyAccount.Industry == '')) {
            List<Sales_Site__c> ssList = [SELECT Id, Name FROM Sales_Site__c WHERE SalesOffice_String__c = :dummySalesSite.SalesOffice_String__c];
            if (ssList.size() > 0) {
                soList.add(new SelectOption('--All--', '--' + Label.All + '--'));
                for (Sales_Site__c s : ssList) {
                    soList.add(new SelectOption(s.Id, s.Name));
                }
                siteIds.add('--All--');
            }
        } else if (custIds.size() > 0) {
            System.debug('custIds55:::' + custIds);
            List<AggregateResult> custSalesSite = [SELECT Sales_Site__c ss, MIN(Sales_Site__r.Name) ssn FROM Customer_Sales_Site__c c WHERE Customer__c IN :custIds group by Sales_Site__c];
            if (custSalesSite.size() > 0) {
                soList.add(new SelectOption('--All--', '--' + Label.All + '--'));
                for(AggregateResult currSite : custSalesSite) {
                    soList.add( new SelectOption((String)currSite.get('ss'), (String)currSite.get('ssn')) );
                }
                if (siteIds.size() == 0) {
                    siteIds.add('--All--');
                }
            } 
        } else {
            soList = new List<SelectOption>();
        }
        return soList;
    }
    
    /*public List<SelectOption> getSalesOfficeOptions() {
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption('--None--', '--' + Label.None + '--'));
        List<AggregateResult> salesOffice = [SELECT Sales_Office__c so, min(Sales_Office__r.Name) son from Sales_Site__c Where Sales_Office__c != null group by Sales_Office__c];
        for(AggregateResult currSite : salesOffice) {
            soList.add( new SelectOption((String)currSite.get('so'), (String)currSite.get('son')) );
        }
        return soList;
    }
    
    public List<SelectOption> getPlantOptions() {
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption('--None--', '--' + Label.None + '--'));
        List<AggregateResult> plants = [SELECT Plant__c pl from COPA_Aggregate__c Where Plant__c != null group by Plant__c];
        System.debug('plantsOptions1::::' + plantsOptions);
        plantsOptions = new List<String>();
        for(AggregateResult plant : plants) {
            System.debug('pl1::::' + (String)plant.get('pl'));
            soList.add( new SelectOption((String)plant.get('pl'), (String)plant.get('pl')) );
            plantsOptions.add((String)plant.get('pl'));
            System.debug('plantsOptions1::::' + plantsOptions);
        }
        return soList;
    }*/

    
    public Set<Id> getCustomerIdsSet() {
        Set<Id> custIds = new Set<Id>();
        Boolean isAllSelected = false;
        List<SelectOption> customersList = getCustomersList();
        for(String c : customersIds) {
            if (c == '--All--') {
                isAllSelected = true;
            }
        }
        if (isAllSelected) {
            for (integer i = 0; i < customersList.size(); i++) {
                if (customersList.get(i).getValue() != '--All--') {
                    custIds.add(customersList.get(i).getValue());
                }
            }
        } else {
            for (String c : customersIds) {
                custIds.add(c);
            }
        }
        return custIds;
    }
    
    public Set<Id> getSitesIdsSet() {
        System.debug('siteIds:::' + siteIds);
        Set<Id> sitesIds = new Set<Id>();
        Boolean isAllSelected = false;
        
        for(String s : siteIds) {
            System.debug('s:::' + s);
            if (s == '--All--') {
                isAllSelected = true;
            }
        }
        System.debug('isAllSelected:::' + isAllSelected);
        
        if (isAllSelected) {
            List<SelectOption> siteOptions = getSiteOptions();
            for (integer i = 0; i < siteOptions.size(); i++) {
                if (siteOptions.get(i).getValue() != '--All--') {
                    sitesIds.add(siteOptions.get(i).getValue());
                }
            }
        } else {
            for (String s : siteIds) {
                sitesIds.add(s);
            }
        }
        System.debug('sitesIds:::' + sitesIds);
        return sitesIds;
    }
    
    public void addCustomer() {
        String optLine = '';
        Boolean exists = false;
        for (integer i = 0; i < selectedCustomersOptions.size(); i++) {
            System.debug(':::' + selectedCustomersOptions.get(i).getValue() + ' ' + dummyQuote.Customer__c);
            if (selectedCustomersOptions.get(i).getValue() == dummyQuote.Customer__c) {
                exists = true;
            }
        }
        if (exists == false && dummyQuote.Customer__c != null) {
            if (dummyQuoteCustomerNumber == null || dummyQuoteCustomerNumber == '') {
                optLine = selectedCustomerName;
            } else {
                optLine = dummyQuoteCustomerNumber + ' ' + selectedCustomerName;
            }
            selectedCustomersOptions.add(new SelectOption(dummyQuote.Customer__c, optLine));
        }
        dummyQuoteCustomerNumber = null;
        dummyQuote.Customer__c = null;
        customerAccountGroup = null;
    }
    
    public void removeCustomer() {
        for (String val : selectedCust) {
            for (integer i = 0; i < selectedCustomersOptions.size(); i++) {
                if (selectedCustomersOptions.get(i).getValue() == val) {
                    selectedCustomersOptions.remove(i);
                }
            }
        }
    }
    
    public void emptyLists() {
        selectedCustomersOptions = new List<SelectOption>();
        customersIds = new List<String>();
        siteIds = new List<String>();
        getSiteOptions();
    }
    
    public List<SelectOption> getCustomersList() {
        System.debug('customers::::' + dummyAccount.Account_Manager__c);
        List<SelectOption> soList = new List<SelectOption>();
        List<Account> accountsList = new List<Account>();
        System.debug('both:::' + dummyAccount.Account_Manager__c + ',' + dummyAccount.Industry);
        if (dummyAccount.Account_Manager__c != null && dummyAccount.Account_Manager__c != '' && (dummyAccount.Industry == null || dummyAccount.Industry == '')) {
            accountsList = [SELECT Id, SAP_Account_Number__c, Name FROM Account WHERE Account_Manager__c = :dummyAccount.Account_Manager__c];
        } else if ((dummyAccount.Account_Manager__c == null || dummyAccount.Account_Manager__c == '') && (dummyAccount.Industry != null && dummyAccount.Industry != '')) {
            accountsList = [SELECT Id, SAP_Account_Number__c, Name FROM Account WHERE Industry = :dummyAccount.Industry];
        } else if ((dummyAccount.Account_Manager__c != null && dummyAccount.Account_Manager__c != '') && (dummyAccount.Industry != null && dummyAccount.Industry != '')) {
            System.debug('both22:::' + dummyAccount.Account_Manager__c + ',' + dummyAccount.Industry);
            accountsList = [SELECT Id, SAP_Account_Number__c, Name FROM Account WHERE Account_Manager__c = :dummyAccount.Account_Manager__c AND Industry = :dummyAccount.Industry];
        }
        //accountsList.sort();
        sortList(accountsList, 'SAP_Account_Number__c','asc');
        if (accountsList.size() > 0) {
            soList.add(new SelectOption('--All--', '--' + Label.All + '--'));
            for(Account acc : accountsList) {
                soList.add( new SelectOption(acc.Id, (acc.SAP_Account_Number__c == null ? '' : acc.SAP_Account_Number__c) + ' ' + acc.Name) );
            }
            if (customersIds.size() == 0) {
                customersIds.add('--All--');
            }
        }
        System.debug('soList:::' + soList);
        //soList = SortOptionList(soList);
        return soList;
    }
    ///////////////////////////////////////////////////////////////////////////////////////
    public void generateEBIT(){
        try {
            List<Sales_Site__c> sitesList;
            sitesIdsList = new Set<Id>();
            List<Account> accountList;
            accountIdsList = new Set<Id>();
            /*
            if (dummySalesSite.SalesOffice_String__c != null && dummySalesSite.SalesOffice_String__c != '') {
                sitesList = [SELECT Id FROM Sales_Site__c WHERE Sales_Office__c = :salesOfficeValue];
                sitesIdsList.add(salesOfficeValue);
                for (Sales_Site__c ss : sitesList) {
                    sitesIdsList.add(ss.Id);
                }
                List<Customer_Sales_Site__c> customerList = [SELECT Customer__c FROM Customer_Sales_Site__c WHERE Sales_Site__c IN :sitesIdsList];
                accountIdsList = new Set<Id>();
                for (Customer_Sales_Site__c customer : customerList) {
                    accountIdsList.add(customer.Customer__c);
                }
            }*/
            System.debug('selectedCustomersOptions.size():::' + selectedCustomersOptions.size());
            System.debug('customersIds.size():::' + customersIds.size());
            //1. create list of Ids for all the sites
            sitesIdsList = getSitesIdsSet();
            System.debug('SitesList has this value: ' + sitesIdsList);
            System.debug('sitesIdsList.size(): ' + sitesIdsList.size());
            
            //2. create list of Ids for customers(accounts)
            if ( selectedCustomersOptions.size() > 0 ) {
                //get all the accounts that were selected
                for (integer i = 0; i < selectedCustomersOptions.size(); i++) {
                    accountIdsList.add(selectedCustomersOptions.get(i).getValue());
                }
            } else if ( selectedCustomersOptions.size() == 0 && customersIds.size() == 0 && dummySalesSite.SalesOffice_String__c != null && dummySalesSite.SalesOffice_String__c != '') {
                //get all the accounts that were related with SalesSites selected
                List<AggregateResult> customerList = [SELECT Customer__c FROM Customer_Sales_Site__c WHERE Sales_Site__c IN :sitesIdsList GROUP BY Customer__c];
                for (AggregateResult customer : customerList) {
                    accountIdsList.add((Id)customer.get('Customer__c'));
                }
            } else if ( customersIds.size() > 0 ) {
                //get all the accounts that were selected
                accountIdsList = getCustomerIdsSet();
            }
            
            // Prelucrate account list to eliminate ship-tos when sold-tos are selected
            System.debug('accountIdsList:::' + accountIdsList.size());
            accountIdsList = prelucrateAccountIds(accountIdsList);
            System.debug('accountIdsList:::' + accountIdsList.size());
            //return;
            
            shipToIdsList = getShipToIds(accountIdsList);
            
            edh = new EBITData.EBITDataHelper();
            edh.accountIds = accountIdsList;
            edh.siteIds = sitesIdsList;
            edh.dateFrom = dummyQuote.Price_Valid_From__c;
            edh.dateTo = dummyQuote.Price_Valid_to__c;
            edh.currencyUsed = currentCurrency;
            //edh.plant = ((selectedPlant == null || selectedPlant == '--None--') ? '' : selectedPlant);
            edh.isMainReport = true;
            
            isGenerated = true;
            plDataReport = EBITData.createEBIT(edh);
            showGeneratePdfButton = true;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PandLGenerator_Error));
        }
    }
    
    public Set<Id> prelucrateAccountIds(Set<Id> accountIdsList) {
    	Set<Id> returnIds = new Set<Id>();
    	List<Account> accountsList = [SELECT Id, Account_Group__c, Name, ParentId FROM Account WHERE Id IN :accountIdsList];
        for (Account a : accountsList) {
            if (a.Account_Group__c == '0001 Sold-to party') {
                returnIds.add(a.Id);
            }
        }
        for (Account a : accountsList) {
        	if (a.Account_Group__c == '0002 Ship-to party' && !returnIds.contains(a.ParentId)) {
            	returnIds.add(a.Id);
            }
        }
        return returnIds;
    }
    
    public Set<Id> getShipToIds(Set<Id> accountIdsList) {
        Set<Id> shipToIds = new Set<Id>();
        List<Account> accountsList = [SELECT Id, Account_Group__c, Name FROM Account WHERE Id IN :accountIdsList];
        Set<Id> soldToIds = new Set<Id>();
        for (Account a : accountsList) {
            if (a.Account_Group__c == '0001 Sold-to party') {
                soldToIds.add(a.Id);
            } else {
            	shipToIds.add(a.Id);
            }
        }
        if (soldToIds.size() > 0) {
            accountsList = [SELECT Id, Account_Group__c, ParentId, Name FROM Account WHERE Account_Group__c = '0002 Ship-to party' AND ParentId IN :soldToIds];
            for (Account a : accountsList) {
                shipToIds.add(a.Id);
            }
            /*if (shipToIds.size() == 0) {
                shipToIds.addAll(soldToIds);
            }*/
        } 
        /*if (shipToIds.size() == 0 && accountIdsList.size() == 1){
            shipToIds.addAll(accountIdsList);
        }*/
        System.debug('shipToIds:::=:::' + shipToIds);
        return shipToIds;
    }
    
    public Id ReportId { get; set; }
    
    public PageReference setParameters(PageReference p) {
        PageReference pageRef = p;
        
        /*plantsString = '';
        if (selectedPlant == '--None--') {
            plantsString = String.join(plantsOptions,',');
        } else if (selectedPlant != null){
            plantsString = selectedPlant;
        }*/
        
        accountIdsString = '';
        for(Id i : accountIdsList) {
            if (accountIdsString == '') {
                accountIdsString = i;
            } else {
                accountIdsString += ',' + i;
            }
        }
        
        shipToIdsListString = '';
        for(Id i : shipToIdsList) {
            if (shipToIdsListString == '') {
                shipToIdsListString = i;
            } else {
                shipToIdsListString += ',' + i;
            }
        }
        
        sitesIdsListString = '';
        for(Id i : sitesIdsList) {
            if (sitesIdsListString == '') {
                sitesIdsListString = i;
            } else {
                sitesIdsListString += ',' + i;
            }
        }
        
        ReportId = null;
        
        if (pageRef != null) {
            //pageRef.getParameters().put('plant', plantsString);
            //pageRef.getParameters().put('reportId', ReportId);
            pageRef.getParameters().put('accountIds', accountIdsString);
            pageRef.getParameters().put('shipToIds', shipToIdsListString);
            pageRef.getParameters().put('sitesIdsList', sitesIdsListString);
            pageRef.getParameters().put('dateFrom', string.valueOf(dummyQuote.Price_Valid_From__c));
            pageRef.getParameters().put('dateTo', string.valueOf(dummyQuote.Price_Valid_to__c));
            pageRef.getParameters().put('currentCurrency', string.valueOf(currentCurrency));
        }
        return pageRef;
    }
    
    public PageReference generatePDF() {
        setParameters(null);
        PageReference pr = Page.EBITOutputPDF;
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference generateExcel() {
    	setParameters(null);
        PageReference pr = Page.EBITBatchPage;
        pr.setRedirect(false);
        return pr;
    }
    
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort)
    {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        SelectOption firstElem = ListToSort[0];
        ListToSort.remove(0);
        integer pivot = ListToSort.size() / 2;
        
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort)
            {
                if(x.getLabel() <= pivotValue.getLabel())
                    Less.add(x);
                else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);
            }

        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.add(firstElem);
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }
    
    public static void sortList(List<Sobject> items, String sortField, String order){
        List<Sobject> resultList = new List<Sobject>();

        //Create a map that can be used for sorting 
        Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
        
        for(Sobject ob : items){
                if(objectMap.get(ob.get(sortField)) == null){  // For non Sobject use obj.ProperyName
                    objectMap.put(ob.get(sortField), new List<Sobject>()); 
                }
                objectMap.get(ob.get(sortField)).add(ob);
        }
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
    
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
    
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(Sobject ob : resultList){
                items.add(ob); 
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]);  
            }
        }
    }
    
    // --------------------- START PDF Output Page Methods ------------------------
    
    public PandLData plDataReportPDF { get; set; }
    public String currentLanguage { get; set; }
    
    public void EBITOutputPdfGenerate() {
        currentLanguage = 'US'; 
        
        //String accountIdsString = ApexPages.currentPage().getParameters().get('accountIds');
        List<Id> accountIdsList = accountIdsString.split(',',-1);
        Set<Id> accountIds = new Set<Id>();
        for (Id a : accountIdsList) {
            accountIds.add(a);
        }
        //String sitesIdsListString = ApexPages.currentPage().getParameters().get('sitesIdsList');
        List<Id> sitesIdsList = sitesIdsListString.split(',',-1);
        Set<Id> sitesIds = new Set<Id>();
        for (Id s : sitesIdsList) {
            sitesIds.add(s);
        }
        Date dateFrom = dummyQuote.Price_Valid_From__c; //date.valueOf(ApexPages.currentPage().getParameters().get('dateFrom'));
        Date dateTo = dummyQuote.Price_Valid_To__c; //date.valueOf(ApexPages.currentPage().getParameters().get('dateTo'));
        //String currentCurrency = ApexPages.currentPage().getParameters().get('currentCurrency');
        
        EBITData.EBITDataHelper edh = new EBITData.EBITDataHelper();
        edh.accountIds = accountIds;
        edh.siteIds = sitesIds;
        edh.dateFrom = dateFrom;
        edh.dateTo = dateTo;
        edh.currencyUsed = currentCurrency;
        edh.isMainReport = true;
        
        plDataReportPDF = EBITData.createEBIT(edh);
        plDataReportPDF.inGenerator = false;
        
    }
    
    // ---------------------  END  PDF Output Page Methods ------------------------
    
    // --------------------- START Excel Batch Output Page Methods ------------------------
    
    public boolean GeneratePressed { get; set; }
	public Id batchId;
	public boolean BatchStarted { get; set; }
	public String batchMessage { get; set; }
	
	public String plantString;
	public List<String> plants;
	public Date dateFrom;
	public Date dateTo;
	
	public List<PandLData> plDataReportShipToList { get; set; }
	public List<EBITData.EBITDataHelper> edhShipToList = new List<EBITData.EBITDataHelper>();
	
	public boolean EXCELBatchDone { get; set; }
	
	public void EXCELEBITBatchPageControllerS() { 
		
		System.debug('Ids 1 : ' + shipToIdsListString); 
		
		EXCELBatchDone = false;
		
		List<Id> accountIdsList = accountIdsString.split(',',-1);
		Set<Id> accountIds = new Set<Id>();
		for (Id a : accountIdsList) {
			accountIds.add(a);
		}
		List<Id> shipToIdsList = new List<Id>();
		if (shipToIdsListString != null && shipToIdsListString != '') {
			shipToIdsList = shipToIdsListString.trim().split(',',-1);
		}
		
		System.debug('Ids 2 : ' + shipToIdsList);
		
		Set<Id> shipToIds = new Set<Id>();
		if (shipToIdsList.size() > 0) {
			for (Id s : shipToIdsList) { 
				shipToIds.add(s);
			}
		}
		
		System.debug('Ids 3 : ' + shipToIds);
		
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
		Set<Id> originalSitesIds = sitesIds;
		
		dateFrom = dummyQuote.Price_Valid_From__c; //date.valueOf(ApexPages.currentPage().getParameters().get('dateFrom'));
		dateTo = dummyQuote.Price_Valid_To__c; //date.valueOf(ApexPages.currentPage().getParameters().get('dateTo'));
		
		List<AggregateResult> shipToPlants = [SELECT Customer__c cust, Plant__c pl, Sales_Site__c ss FROM COPA_Aggregate__c 
												WHERE Customer__c IN :shipToIds AND Sales_Site__c IN :sitesIds AND (Current_Month__c >= :dateFrom AND Current_Month__c <= :dateTo)
												GROUP BY Customer__c, Plant__c, Sales_Site__c];
		System.debug('shipToPlants::::' + shipToPlants);
		//shipTo report
		EBITData.EBITDataHelper edhShipTo;
		PandLData plDataReportShipTo;
		Set<Id> shipToIdSet;
		
		Set<Id> shipToUsedIdSet = new Set<Id>();
		for (AggregateResult a : shipToPlants) {
			edhShipTo = new EBITData.EBITDataHelper();
			shipToIdSet = new Set<Id>();
			shipToIdSet.add((String)a.get('cust'));
			shipToUsedIdSet.add((String)a.get('cust'));
			edhShipTo.accountIds = shipToIdSet;
			edhShipTo.plant = (String)a.get('pl');
			//edhShipTo.salesGroup = (String)a.get('sg');
			sitesIds = new Set<Id>();
			sitesIds.add((String)a.get('ss'));
			edhShipTo.siteIds = sitesIds;
			edhShipTo.dateFrom = dateFrom;
			edhShipTo.dateTo = dateTo;
			edhShipTo.currencyUsed = currentCurrency;
			edhShipTo.isMainReport = false;
			edhShipToList.add(edhShipTo);
		}
		System.debug('edhShipToList:::' + edhShipToList.size());
		
		if (originalSitesIds == null || originalSitesIds.size() == 0) {
			shipToIds.removeAll(shipToUsedIdSet);
			
			for (String s : shipToIds) {
				edhShipTo = new EBITData.EBITDataHelper();
				shipToIdSet = new Set<Id>();
				shipToIdSet.add(s);
				edhShipTo.accountIds = shipToIdSet;
				edhShipTo.plant = null;
				//edhShipTo.salesGroup = null;
				edhShipTo.siteIds = new Set<Id>();
				edhShipTo.dateFrom = dateFrom;
				edhShipTo.dateTo = dateTo;
				edhShipTo.currencyUsed = currentCurrency;
				edhShipTo.isMainReport = false;
				edhShipToList.add(edhShipTo);
			}
		}
		
		//generate Batch
		EXCELGenerate(edhShipToList);
	}
	
	 public void EXCELGenerate(List<EBITData.EBITDataHelper> edhShipToList) {
		
		EBITShipToReportBatch batch = new EBITShipToReportBatch(edhShipToList);
		batchId = Database.executeBatch(batch, 1);
		BatchStarted = true;
		batchMessage = 'Report 0% completed';
		
		GeneratePressed = true;
	}
	
	public PageReference EXCELCheckBatch() {
		
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
										 TotalJobItems, CreatedBy.Email 
										 FROM AsyncApexJob WHERE Id = :batchId];
		if (a.Status != 'Completed' && (!Test.isRunningTest())) {
			if (a.Status == 'Failed' || a.Status == 'Aborted') {
				batchMessage = 'Report has failed or was aborted by user.';
				return null;
			}
			if (a.TotalJobItems == 0) {
				batchMessage = 'Report 0% completed';
			} else {
				batchMessage = 'Report ' + (a.JobItemsProcessed * 100 / a.TotalJobItems)
									+ '% completed';
			}
			return null;
		}
		
		if (a.Status == 'Completed' && batchMessage != 'Report 100% completed') {
			batchMessage = 'Report 100% completed';
			EXCELBatchDone = true;
			return null;
		}
		
		EXCELBatchDone = true;
		return null;
	}
	
	public PageReference EXCELOpenDocument() {
		EXCELsetParameters(null);
        PageReference pr = Page.EBITOutputExcel;
        pr.setRedirect(false);
        return pr;
	}
	
	public PageReference EXCELCancelBatch() {
		List<COPA_ShipTos_Temp__c> auxs = [SELECT Id FROM COPA_ShipTos_Temp__c
												 WHERE BatchId__c = :batchId];
		if (auxs.size() > 0)
			delete auxs;
		BatchStarted = false;
		GeneratePressed = false;
		return Page.EBITReporting;
	}
	
	public PageReference EXCELsetParameters(PageReference p) {
		PageReference pageRef = p;
		
		if (pageRef != null) {
			pageRef.getParameters().put('batchId', batchId);
			pageRef.getParameters().put('accountIds', accountIdsString);
			pageRef.getParameters().put('shipToIds', shipToIdsListString);
			pageRef.getParameters().put('sitesIdsList', sitesIdsListString);
			pageRef.getParameters().put('dateFrom', string.valueOf(dateFrom));
			pageRef.getParameters().put('dateTo', string.valueOf(dateTo));
			pageRef.getParameters().put('currentCurrency', currentCurrency);
		}
		return pageRef;
	}
    
    // ---------------------  END  Excel Batch Output Page Methods ------------------------
    
    // --------------------- START Excel Output Page Methods ------------------------
    
    public PandLData EXCELplDataReport { get; set; }
    
    //public static List<PandLData> plDataReportShipToListBatch { get; set; }
    //global List<EBITData.EBITDataHelper> edhList = new List<EBITData.EBITDataHelper>();
    public String xmlheader { get; set; }
    public String endfile { get; set; }
    public List<COPA_Aggregate__c> copaAggregateResults { get; set; }
    public Map<String,String> copaAggregateHeader { get; set; }
    public List<PCA__c> pcaResults { get; set; }
    public Map<String,String> pcaHeader { get; set; }
    public List<Cost_Driver_Entry__c> cdeResults { get; set; }
    public Map<String,String> cdeHeader { get; set; }
    
    @future
    public static void EXCEL2DeleteAux(Id batchId) {
    	List<COPA_ShipTos_Temp__c> auxs = [SELECT Id FROM COPA_ShipTos_Temp__c WHERE BatchId__c = :batchId];
        delete auxs;
    }
    
    private List<COPA_ShipTos_Temp__c> shipToExcelList;
    
    public List<Map<string, string>> EXCELplDataReportShipToList {
    	get {
    		List<Map<string, string>> toReturn = new List<Map<string, string>>();
    		System.debug('Start : ' + Limits.getHeapSize());
    		// To avoid the heap size limit, we use rhe SOQL for loop
		    for (List<COPA_ShipTos_Temp__c> shipToExcelList2 : [SELECT Id, Value__c FROM COPA_ShipTos_Temp__c WHERE BatchId__c = :batchId]) {
    			for (COPA_ShipTos_Temp__c c : shipToExcelList2) {
		            toReturn.add((Map<string, string>)JSON.deserialize(c.Value__c, Map<string, string>.class));
		            System.debug('Cont : ' + Limits.getHeapSize());
		        }
    		}
    		System.debug('Cont : ' + Limits.getHeapSize());
        	EXCEL2DeleteAux(batchId);
	    	return toReturn;
    	}
    }
    
    public void EXCEL2EBITOutputExcelAction() {
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        currentLanguage = 'US'; 
        
        //System.debug('plDataReportShipToList:::' + EXCELplDataReportShipToList);
        
        List<Id> accountIdsList = accountIdsString.split(',',-1);
        Set<Id> accountIds = new Set<Id>();
        for (Id a : accountIdsList) {
            accountIds.add(a);
        }

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
        Date dateFrom = dummyQuote.Price_Valid_From__c; //date.valueOf(ApexPages.currentPage().getParameters().get('dateFrom'));
        Date dateTo = dummyQuote.Price_Valid_To__c; //date.valueOf(ApexPages.currentPage().getParameters().get('dateTo'));
        //String currentCurrency = ApexPages.currentPage().getParameters().get('currentCurrency');
        //String plant = ApexPages.currentPage().getParameters().get('plant');
        
        EBITData.EBITDataHelper edh = new EBITData.EBITDataHelper();
        System.debug('accountIds::::' + accountIds);
        System.debug('siteIds::::' + sitesIds);
        edh.accountIds = accountIds;
        edh.siteIds = sitesIds;
        edh.dateFrom = dateFrom;
        edh.dateTo = dateTo;
        edh.currencyUsed = currentCurrency;
        edh.plant = null; // ? plant
        edh.isMainReport = true;
        
        EXCELplDataReport = EBITData.createEBIT(edh);
        EXCELplDataReport.inGenerator = false;
        
        copaAggregateResults = database.query(EBITData.createCopaAggregateResults(edh));
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

    // ---------------------  END  Excel Output Page Methods ------------------------
    
}