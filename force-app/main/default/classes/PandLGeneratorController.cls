public with sharing class PandLGeneratorController {

	public Quote__c dummyQuote 					{get; set;}
    public Account dummyAccount 				{get; set;}
    public User dummyUser 						{get; set;}
    public String siteId 						{get; set;}
    public String regionId 						{get; set;}
    public String companyId 					{get; set;}
    public PandLData plData 					{get; set;}
    public String theIndustry 					{get; set;}
    public List<SelectOption> siteSelectOptions {get; set;}
    public String reporttype 					{get; set;}
    public List<PandLData> reportsList 			{ 
    	get {
    		return getCurrentPage();	  
    	} 
    	
    	set;}
    public Boolean HideZeroData					{ get; set; }
    public Integer currPage							{get; set;}
    public Integer maxPage						{get; set;}
    public Integer noOfEntriesOnPage			{get; set;}
    private List<SearchParameters> searchParamList;
    public String orderby						{get; set;}
    
    private Map<String, PandLData> cachedReports;
    
    public PandLData ReportToPrint { get; set; }
    
    public PageReference Print() {
    	integer i = Math.Round(decimal.valueof(ApexPages.currentPage().getParameters().get('print')));
    	ReportToPrint = getCurrentPage()[i];
    	PageReference secondPage = Page.PandLPrint;
    	secondPage.setRedirect(true);
    	return secondPage;
    }
    
    public void ResetRegion() {
    	if (siteId == null || siteId == '' || siteId == '--None--') {
    		regionId = '--None--';
    		companyId = '--None--';
    	}
    }
    
    public void ResetCompany() {
    	if (regionId == null || regionId == '' || regionId == '--None--') {
    		companyId = '--None--';
    	}
    }
    
    public List<SelectOption> getReportTypes() {
    	List<SelectOption> options = new List<SelectOption>();
    	if (customerAccountGroup != '0001 Sold-to party') {
    		options.add(new SelectOption('Summary', 'Summary'));
    	}
    	
		options.add(new SelectOption('Detail', 'Detail'));
		
		return options;
    }
    
    public PandLGeneratorController() {
        dummyQuote = new Quote__c();
        dummyQuote.Price_Valid_From__c = Date.Today().addyears(-1);
        dummyQuote.Price_Valid_To__c = Date.Today().addmonths(-1);
        dummyAccount = new Account();
        dummyUser = new User();
        siteId = '--None--';
        regionId = '--None--';
        companyId = '--None--';
        siteSelectOptions = getSiteOptions();
        SetDefaultCurrency();
        reporttype = 'Summary';
        noOfEntriesOnPage = 3;
        
        searchParamList = new List<SearchParameters>();
        cachedReports = new Map<String, PandLData>();
        
        HideZeroData = true;
        
        String strfromdate = ApexPages.currentPage().getParameters().get('fromdate');  
        String strtodate = ApexPages.currentPage().getParameters().get('todate'); 
        if ((strfromdate != null) && (strtodate != null)) {
        	dummyQuote.Price_Valid_From__c = Date.parse(EncodingUtil.urlDecode(strfromdate, 'UTF-8'));
       		dummyQuote.Price_Valid_To__c = Date.parse(EncodingUtil.urlDecode(strtodate, 'UTF-8'));
        	
    		String sId = ApexPages.CurrentPage().getParameters().get('siteid');
    		if ((sId != null) && (sId != '')) {
    			siteId = sId;
    		}
    		
    		String cId = ApexPages.CurrentPage().getParameters().get('companyid');
    		if ((cId != null) && (cId != '')) {
    			companyId = cId;
    		}
    		
    		String rId = ApexPages.CurrentPage().getParameters().get('regionid');
    		if ((rId != null) && (rId != '')) {
    			regionId = rId;
    		}
    		
    		String customerparentId = ApexPages.CurrentPage().getParameters().get('parentid');
    		if ((customerparentId != null) && (customerparentId != '')) {
    			dummyQuote.Customer__c = customerparentId;
    			setQuoteCustomer();
    		}
    		
    		generatePandL();
       	}
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
				Account xCust = [SELECT Id, Account_Group__c FROM Account WHERE SAP_Account_Number__c = :dummyQuoteCustomerNumber_private LIMIT 1];
				dummyQuote.Customer__c = xCust.Id;
				customerAccountGroup = xCust.Account_Group__c;
			} catch (Exception ex) {
				dummyQuote.Customer__c = null;
				customerAccountGroup = '';
			}
			if (customerAccountGroup == '0002 Ship-to party')
				SelectSiteFromAccount();
			if (customerAccountGroup == '0001 Sold-to party')
				reporttype = 'Detail';
    	}
    }
    
    public string customerAccountGroup {get;set;}
    
    public void setQuoteCustomer() {
    	try {
    		Account xCust = [SELECT SAP_Account_Number__c, Account_Group__c FROM Account WHERE Id = :dummyQuote.Customer__c LIMIT 1];
    		dummyQuoteCustomerNumber_private = xCust.SAP_Account_Number__c;
    		customerAccountGroup = xCust.Account_Group__c;
    	} catch (Exception ex) {
    		dummyQuoteCustomerNumber_private = null;
    		customerAccountGroup = '';
    	}
		if (customerAccountGroup == '0002 Ship-to party')
			SelectSiteFromAccount();
		if (customerAccountGroup == '0001 Sold-to party')
			reporttype = 'Detail';
    }
    
    private void SelectSiteFromAccount() {
    	List<Customer_Sales_Site__c> csss = [SELECT Id, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c = :dummyQuote.Customer__c LIMIT 1];
    	
    	if (csss.size() > 0)
    		siteId = csss[0].Sales_Site__c;
    }
    // -- END -- Customer Number / Name / Account group functionality
    
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
    		System.debug('Lucian month from: ' + dummyQuote.Price_Valid_From__c);
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
    
    
    public void generatePandL(){
    	cachedReports = new Map<String, PandLData>();
    	
    	if(siteId == '--None--') {
    		siteId = null;
    	}
    	if(regionId == '--None--') {
    		regionId = null;
    	}
    	if(companyId == '--None--') {
    		companyId = null;
    	}
    	if(theIndustry == '--None--') {
    		theIndustry = null;
    	}
    	
    	if(dummyQuote.Customer__c != null) {
    		try {
    			Boolean success = [SELECT Flag_for_Deletion__c FROM Account WHERE Id = :dummyQuote.Customer__c LIMIT 1].Flag_for_Deletion__c;
    		} catch (Exception e) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
    			return;
    		}
    	}
    	
    	reportsList = new List<PandLData>(); 
    	searchParamList = new List<SearchParameters>();
    	
    	try {
    		//we shall always have at least one report - the one selected by the user
    		searchParamList.add(new SearchParameters(dummyQuote.Customer__c, siteId, regionId, companyId, customerAccountGroup == '0001 Sold-to party'));
			
			currpage = 1;
			maxPage = 1;
			//if the user use the Detail version
    		if (reporttype == 'Detail') {
    			
    			//1. create list of Ids for customers(accounts)
    			List<Account> childrenList = [SELECT Id FROM Account WHERE ParentId != NULL AND ParentId=:dummyQuote.Customer__c];
    			List<Id> accountIdsList = new List<Id>();
    			if (childrenList.size() != 0) {
    				for (Account acc: childrenList) {
    					accountIdsList.add(acc.Id);
    				}
    			}
    			
    			//2. create list of Ids for all the sites
    			List<Id> sitesIdsList = new List<Id>();
    			boolean sitescompleted = false;
    			if (siteId != null) {
    				sitescompleted = true;
    			}
    			
    			if ((regionId != null) && (!sitescompleted)) {
    				List<Sales_Site__c> regionSitesList = [SELECT Id, Region_Site__c FROM Sales_Site__c WHERE Region_Site__c=:regionId];
    				System.debug('regionSitesList has this value: ' + regionSitesList);
    				if (regionSitesList.size() != 0) {
    					for (Sales_Site__c s: regionSitesList) {
    						sitesIdsList.add(s.Id);
    					}
    				}
    				sitescompleted = true; 
    			}

    			if ((companyId != null) && (!sitescompleted)) {
    				List<Sales_Site__c> companySitesList = [SELECT Id, Company_Site__c FROM Sales_Site__c WHERE Company_Site__c=:companyId];
    				System.debug('companySitesList has this value: ' + companySitesList);
    				if (companySitesList.size() != 0) {
    					for (Sales_Site__c s: companySitesList) {
    						sitesIdsList.add(s.Id);
    					}
    				}
    			} 
    			
    			//3. we create all the PandLData for each <customer,site> pairs
    			if (sitesIdsList.size() == 0 && accountIdsList.size() > 0) {
    				for (Id accId: accountIdsList) {
    					searchParamList.add(new SearchParameters(accId, siteId, regionId, companyId));
    				}
    			}
    			if (sitesIdsList.size() > 0 && accountIdsList.size() == 0) {
    				for (Id xsiteId : sitesIdsList) {
    					searchParamList.add(new SearchParameters(dummyQuote.Customer__c, xsiteId, regionId, companyId));
    				}
    			}
    			if (sitesIdsList.size() > 0 && accountIdsList.size() > 0) {
	    			for (Id accId: accountIdsList) {
	    				for (Id sId: sitesIdsList) {
	    					searchParamList.add(new SearchParameters(accId, sId, null, null));
	    				}
	    			}
    			}
    			System.debug('searchParamList.size() has this value: ' + searchParamList.size());
    			System.debug('searchParamList has this value at the end of generatePandL():' + searchParamList);
    			
    			//we set maxPage using searchParamList.size()
    			if (searchParamList.size() != 0) {
    				//maxPage = searchParamList.size()/noOfEntriesOnPage + 1; does not work cause the size of the list can be a multiple of noOfEntries and adding 1 would add an extra page... like 16/4 +1 = 5 when 4 should be teh value
    				maxPage = ((searchParamList.size() - 1)/noOfEntriesOnPage) + 1;
    			}
    		}
    		SortReports();
    		getCurrentPage();
    	} catch (Exception e) {
    		ApexPages.addMessages(e);
    		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PandLGenerator_Error));
    	}
    }
    
    public List<SelectOption> getIndustries() {
    	List<SelectOption> soList = new List<SelectOption>();
    	soList.add(new SelectOption('--None--', '--' + System.Label.None + '--'));
    	Schema.Describefieldresult fr = Account.Industry__c.getDescribe();
    	for(Schema.PicklistEntry pe : fr.getPicklistValues()) {
    		soList.add(new SelectOption(pe.getValue(), pe.getLabel()));
    	}
    	return soList;
    }
    
    //All sites should always be able to be chosen
    private List<SelectOption> getSiteOptions() {
    	List<SelectOption> soList = new List<SelectOption>();
    	soList.add(new SelectOption('--None--', '--' + Label.None + '--'));
    	for(Sales_Site__c currSite : [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c <> null AND Company_Site__c <> null order by Name asc]) {
    		soList.add( new SelectOption(currSite.Id, currSite.Name) );
    	}
    	return soList;
    }
    
    
    //All region should be able to be chosen if no site is chosen.  If a site is chosen region needs to filter.
    public List<SelectOption> getRegionOptions() {
    	List<SelectOption> soList = new List<SelectOption>();
    	soList.add(new SelectOption('--None--', '--' + Label.None + '--'));
    	
    	if(siteId == null || siteId == '--None--') {
	    	for(Sales_Site__c currSite : [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = null AND Company_Site__c <> null order by Name asc]) {
	    		soList.add( new SelectOption(currSite.Id, currSite.Name) );
	    	}    		
    	} else {
	    	for(Sales_Site__c currSite : [SELECT Region_Site__c, Region_Site__r.Name FROM Sales_Site__c WHERE Id = :siteId]) {
	    		soList.add( new SelectOption(currSite.Region_Site__c, currSite.Region_Site__r.Name) );
	    	}       		
    	} 	
    	
    	if (soList.size() == 2)
    		regionId = soList.get(1).getvalue();
    	return soList;
    }
    
    //All companies should be able to be chosen if no region is chosen. If a region is chosen company needs to filter.
    public List<SelectOption> getCompanyOptions() {
    	List<SelectOption> soList = new List<SelectOption>();
    	soList.add(new SelectOption('--None--', '--' + Label.None + '--'));
    	
    	if (siteId != null && siteId != '--None--') {
    		for(Sales_Site__c currSite : [SELECT Company_Site__c, Company_Site__r.Name FROM Sales_Site__c WHERE Id = :siteId]) {
	    		soList.add( new SelectOption(currSite.Company_Site__c, currSite.Company_Site__r.Name) );
	    	}
    	} else {
	    	if(regionId != null && regionId != '--None--') {    
		    	for(Sales_Site__c currSite : [SELECT Company_Site__c, Company_Site__r.Name FROM Sales_Site__c WHERE Id = :regionId]) {
		    		soList.add( new SelectOption(currSite.Company_Site__c, currSite.Company_Site__r.Name) );
		    	}       	    		
	    	} else {
		    	for(Sales_Site__c currSite : [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = null AND Company_Site__c = null order by Name asc]) {
		    		soList.add( new SelectOption(currSite.Id, currSite.Name) );
		    	}        		
	    	} 
    	}
    	
    	if (soList.size() == 2)
    		companyId = soList.get(1).getvalue();
    	
    	return soList;
    }
    
    public void nextPage() {
    	if (currPage < maxPage) {
    		currPage++;
    		getCurrentPage();
	    	if (currPage > maxPage) {
	    		currPage--;
	    	}
    	}
    }
    
    public void previousPage() {
    	if (currPage > 1) {
    		currPage--;
    	}
    }
    
    public List<PandLData> getCurrentPage() {
    	if (searchParamList == null || searchParamList.size() == 0)
    		return null;
    	List<PandLData> currentPageList = new List<PandLData>();
    	if (reporttype == 'Summary') {
    		SearchParameters sp = searchParamList.get(0);
    		PandLData pld = GeneratePandLReport(sp);
	    	currentPageList.add(pld); 
    	} else {
	    	for (Integer i = 0; i < searchParamList.size(); i++) {
	    		if ((i >= ((currPage-1) * noOfEntriesOnPage)) && (i < (currPage * noOfEntriesOnPage))) {
	    			SearchParameters sp = searchParamList.get(i);
	    			PandLData pld = GeneratePandLReport(sp);
	    			if (hideZeroData && !sp.IsSoldTo && (pld.netRevenue == null || pld.netRevenue.value == 0)) {
	    				searchParamList.remove(i);
	    				i--;
	    			} else {
	    				currentPageList.add(pld);
	    			}
	    		}
	    	}
    	}
    	maxPage = ((searchParamList.size() - 1)/noOfEntriesOnPage) + 1;
    	return currentPageList;
    }
    
    private PandLData GeneratePandLReport(SearchParameters sp) {
    	string searchKey = sp.accountId + '*' + sp.companyId + '*' + sp.regionId + '*' + sp.salesSite;
    	
    	System.debug('Lucian search key: ' + searchKey);
    	
    	if (cachedReports.keyset().contains(searchKey))
    		return cachedReports.get(searchKey);

		List<PandLData> shiptos = new List<PandLData>();
		if (sp.isSoldTo) {
			for (PandLData pld : cachedReports.values())
				shiptos.add(pld);
		}
    	PandLData pl = PandLData.createForPandLGenerator2(dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_to__c, sp.accountId, sp.isSoldTo,
	    												 sp.salesSite, sp.regionId, sp.companyId, theIndustry, dummyAccount.Account_Manager__c, dummyUser.RSM__c, currentCurrency, shiptos, HideZeroData);
		cachedReports.put(searchKey, pl);
		return pl;
    }
    
    private void SortReports() {
    	if (orderby == null || orderby == '')
    		return;
    		
    	List<Id> ids1 = new List<Id>();
    	for (SearchParameters sp : searchParamList) {
	    	if (orderby.startsWith('Company'))
	    		 ids1.add(sp.companyId);
	    	if (orderby.startsWith('Region'))
	    		 ids1.add(sp.regionId);
	    	if (orderby.startsWith('Site'))
	    		 ids1.add(sp.salesSite);
	    }
	    Map<Id, Sales_Site__c> sites = new Map<Id, Sales_Site__c>([SELECT Id, Name FROM Sales_Site__c WHERE id in :ids1]);
	    for (SearchParameters sp : searchParamList) {
	    	try {
		    	if (orderby.startsWith('Company'))
		    		 sp.sortName = sites.get(sp.companyId).Name;
		    	if (orderby.startsWith('Region'))
		    		 sp.sortName = sites.get(sp.regionId).Name;
		    	if (orderby.startsWith('Site'))
		    		 sp.sortName = sites.get(sp.salesSite).Name;
	    	} catch (Exception ex) {}
	    }
    	
    	integer totalsize = searchParamList.size();
    	boolean isasc = orderby.endsWith('ASC');
    	for (integer i = 0; i < totalSize - 1; i++)
    		for (integer j = i + 1; j < totalSize; j++)
   				if ((searchParamList[i].sortName > searchParamList[j].sortName && isasc) ||
   					(searchParamList[i].sortName < searchParamList[j].sortName && !isasc) ||
   					(searchParamList[i].isSoldTo)) {
   					SearchParameters aux = searchParamList[i];
   					searchParamList[i] = searchParamList[j];
   					searchParamList[j] = aux;
   				}
    }
    
    //helper class for pagination
    public class SearchParameters {
    	
    	Id salesSite;
    	Id regionId;
    	Id companyId;
    	Id accountId;
    	boolean isSoldTo;
    	
    	public String sortName;
    	
    	SearchParameters(String a, String s, String r, String c) {
    		this.salesSite = s;
    		this.regionId = r;
    		this.companyId = c;
    		this.accountId = a;
    		isSoldTo = false; 
    	} 

    	SearchParameters(String a, String s, String r, String c, boolean st) {
    		this.salesSite = s;
    		this.regionId = r;
    		this.companyId = c;
    		this.accountId = a;
    		isSoldTo = st; 
    	} 
    }
    
    
}