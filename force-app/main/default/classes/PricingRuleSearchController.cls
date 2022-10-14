public with sharing class PricingRuleSearchController {
	public Pricing_Rule__c ruleCriteria {get; set;}
	public List<PricingEngine.PricingData> searchResults {get; private set;}
	public List <CopaData> customerSalesHistoryResults {get; private set;}
	public Boolean includeHistory{get; set;}
	public Boolean hasSearched {get; private set;}
	public String companyCodeId {get;set;}
	public String regionSite {get;set;}
	private Boolean firstTime {get; set;}
	public String customerGroup {get; set;}
	public Quote_Line_Item__c materialSelector {get; set;}
	
	public PricingRuleSearchController() {
		ruleCriteria = new Pricing_Rule__c();
		materialSelector = new Quote_Line_Item__c();
		hasSearched = false;
		includeHistory = false;
		regionSite = '--None--';
		companyCodeId = null;
		firstTime = true;
		customerGroup = null;
	}
	
	public List<SelectOption> getCompanyCodeOptions() {
		List<SelectOption> options = new List<SelectOption>();
		List<String> companyCodes = new List<String>();
		User currUser = [Select Company_Codes__c from User where Id = :UserInfo.getUserId()];
		if(currUser.Company_Codes__c != null && currUser.Company_Codes__c.contains(';')) {
			companyCodes = currUser.Company_Codes__c.split(';');
		} else if(currUser.Company_Codes__c != null) {
			companyCodes.add(currUser.Company_Codes__c);
		}
		for (Sales_Site__c company : [Select Id, Name from Sales_Site__c where Name in :companyCodes]) {
			options.add(new SelectOption(company.Id, company.Name));
			System.debug('Company: ' + company.Name);
		}
		
		if(firstTime) {
			firstTime = false;
			if(options.size() > 0) {
				companyCodeId = options.get(0).getValue();
				
			} else {
				companyCodeId = null;
			}
		}
		
		
		return options;
	}
	
	public List<SelectOption> getRegionOptions() {
		List<SelectOption> options = new List<SelectOption>();
		System.debug('COMPANY CODE ID: ' + companyCodeId);
		List<Sales_Site__c> regions = [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = null and Company_Site__c = :companyCodeId];
		options.add( new SelectOption('--None--', '--' + System.Label.None + '--'));
		if(companyCodeId != null) {
			for(Sales_Site__c currSite : regions) {
				options.add(new SelectOption(currSite.Id, currSite.Name));
				System.debug('Regions added: '  + currSite.Name);
			}
		}
		
		regionSite = options.get(0).getValue();
		return options;
	}
	
	public void search() {
		if(this.ruleCriteria.Account__c != null) {
			try {
				Id anID = [SELECT Id, Parent.SAP_Account_Number__c, Name, SAP_Account_Number__c, CurrencyISOCode, ShippingCountry FROM Account WHERE Id = :this.ruleCriteria.Account__c LIMIT 1].Id;
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
				return;
			}			
		}
		if(this.materialSelector.Material_Item__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Schema.SObjectType.Quote_Line_Item__c.fields.Material_Item__c.label + ' ' + System.Label.QGP_Required));
			return;
		}
		if (this.includeHistory && this.ruleCriteria.Account__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.CSHistoryError));
			return;
		}

		this.hasSearched = true;
		if(regionSite == '--None--') {
			ruleCriteria.Region_Site__c = null;
		} else {
			ruleCriteria.Region_Site__c = regionSite;
		}
		this.searchResults = PricingEngine.getPricingData((Id)this.companyCodeId, this.ruleCriteria.Account__c, this.ruleCriteria.Receiving_Sales_Site__c, this.materialSelector.Material_Item__c, ruleCriteria.Region_Site__c, customerGroup);

		//searchResults = PricingEngine.getPricingData();	
		if (includeHistory){
			this.customerSalesHistoryResults = new List <CopaData>();
			String searchHistoryQuery = 'SELECT Material_Item__r.Name material, UoM__c, CurrencyIsoCode, SUM(Price__c) price, SUM(Net_Revenue__c) netRev, SUM(LBS__c) units FROM Copa__c WHERE Current_Month__c = LAST_N_DAYS:365 AND Customer__c = \'' + ruleCriteria.Account__c + '\'';
			String groupByClause = ' GROUP BY Material_Item__r.Name, UoM__c, CurrencyIsoCode';
			
            system.debug('Rullm.reciving:'+ruleCriteria.Receiving_Sales_Site__c);
            system.debug('Rullm.region:'+ruleCriteria.Region_Site__c);
            system.debug('Rullm.msterial:'+materialSelector.Material_Item__c);
            
			if (ruleCriteria.Receiving_Sales_Site__c == null && materialSelector.Material_Item__c == null && ruleCriteria.Region_Site__c == null){
				List<AggregateResult> results = Database.query(searchHistoryQuery + groupByClause);
				for (AggregateResult res : results) {
					this.customerSalesHistoryResults.add(new CopaData(res));
				}
			}
			else {
				searchHistoryQuery = searchHistoryQuery + ' AND ';
				if (materialSelector.Material_Item__c!= null){
					searchHistoryQuery = searchHistoryQuery + 'Material_Item__c = \'' + materialSelector.Material_Item__c + '\' AND ';
				}
				if (ruleCriteria.Receiving_Sales_Site__c!= null){
					searchHistoryQuery = searchHistoryQuery + 'Sales_Site__c = \'' + ruleCriteria.Receiving_Sales_Site__c + '\' AND ';
				}
				searchHistoryQuery = searchHistoryQuery.substring(0, searchHistoryQuery.length()-4);
				List<AggregateResult> results = Database.query(searchHistoryQuery + groupByClause);
				for (AggregateResult res : results) {
					this.customerSalesHistoryResults.add(new CopaData(res));
				}
			}	
		}		
	}

	public void clear(){
		this.ruleCriteria = new Pricing_Rule__c();
		this.hasSearched = false;
		this.includeHistory = false;
	}
	
	public class CopaData {
		public String material {get;set;}
		public CurrencyData revenue {get;set;}
		public Integer volume {get;set;}
		public CurrencyData price {get;set;}
		public String uom {get;set;}
		
		public CopaData(AggregateResult res) {
			String currencyIsoCode = (String)res.get('CurrencyIsoCode');
			this.material = (String)res.get('material');
			this.revenue = new CurrencyData(currencyIsoCode, (Decimal)res.get('netRev'));
			this.volume = ((Double)res.get('units')).intValue();
			this.price = new CurrencyData(currencyIsoCode, this.revenue.value/this.volume);
			this.uom = (String)res.get('UoM__c');
		}
	}
}