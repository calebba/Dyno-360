public with sharing class PricingSearchController {
	
	/*
		PUBLIC VALUES
	*/
	public List<SearchItem> searchPricingRuleFields {get; set;}
	public List<SearchItem> searchAccountFields {get; set;}
	public ModifyItem item1 {get; set;}
	public ModifyItem item2 {get; set;}
	public Pricing_Rule__c dummyPr {get; set;}
	public Account dummyAccountObject {get; set;}
	public Customer_Sales_Site__c dummyCSS {get; set;}	
	public List<SelectOption> regions {get; set;}
	public List<ResultSet> resultSetRecords {get; set;}
	public Boolean selectAll {get; set;}
	public Boolean areResults {get; set;}
	public Boolean amFilter {get; set;}
	public String siteChoice {get; set;}
	public String selectedPHL1 {get; set;}
	
	/*
		PRIVATE VALUES
	*/
	private Map<String, Schema.SObjectField> pricingRuleFields;
	private Map<String, Schema.SObjectField> accountFields;
	private List<Pricing_Rule__c> searchResults {get; set;}
	
	/*
		STATIC VALUES
	*/	
	private static String ERROR_MESSAGE_ON_MODIFY_ITEM = System.Label.Pricing_Search_Error;
	private static SelectOption defaultOption = new SelectOption('', System.Label.Please_Select_An_Option);
	
	private static String[] pricingRuleAPINames = new String[]{
		'Material_Item__c',
		'Account__c',
		'Region_Site__c',
		'Customer_Group__c'
	};
	
	private static String ACCOUNT_API_REFERENCE = 'Account__r.';
	
	/*	
		CONSTRUCTOR
	*/
	public PricingSearchController() {
		areResults = false;
		selectAll = false;
		amFilter = false;
		siteChoice = '--None--';
		selectedPHL1 = '--None--';
		setupMetadata(); 
		setupLists(); 
		setupSearchFields(); 
		setupEditFields(); 
		setupFieldsOnAccount();
	}
	
	/*
		PRIVATE METHODS
	*/
	private void setupMetadata() {
		Map<String, Schema.SObjectType> globalFields = Schema.getGlobalDescribe();
        pricingRuleFields = globalFields.get('Pricing_Rule__c').getDescribe().fields.getMap();
        accountFields = globalFields.get('Account').getDescribe().fields.getMap();
	}
	
	public List<SelectOption> getPHL1Options() {
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--None--'));
		for(Product_Grouping__c currPg : [SELECT Name, Title__c FROM Product_Grouping__c order by Name asc]) {
			soList.add(new SelectOption(currPg.Name, currPg.Name + ' - ' + currPg.Title__c));
		}
		return soList;
	}	
	
	private void setupFieldsOnAccount() {
		for(Sales_Site__c ss : [SELECT Id, Name FROM Sales_Site__c WHERE Region_Site__c = null AND Company_Site__c != null]) {
			regions.add(new SelectOption(ss.Id, ss.Name));
		}		
	}

	public List<SelectOption> getCustomerSites() {
		List<SelectOption> soList = new List<SelectOption>();
		List<Customer_Sales_Site__c> cssList = new List<Customer_Sales_Site__c>();
		
		if(dummyPr.Account__c != null) {
			cssList = [SELECT Id, Payment_Terms__c, Flag_For_Deletion__c, CurrencyIsoCode, Sales_Site__r.Region_Site__c, Pricelist__c, INCO__c, Delivery_Sales_Site__c, Service_Type__c, Drilled_By__c, Customer_Group__c, Sales_Site__r.Name, Sales_Site__r.Company_Site__r.Name, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c = :dummyPr.Account__c];
			String companyCodes = [SELECT Company_Codes__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Company_Codes__c;
			for(Customer_Sales_Site__c currCSS : cssList) {
				if(!currCSS.Flag_For_Deletion__c && currCSS.Sales_Site__r.Region_Site__c != null && currCSS.Sales_Site__r.Company_Site__c != null && companyCodes.indexOf(currCSS.Sales_Site__r.Company_Site__r.Name) != -1) {
					soList.add(new SelectOption(currCSS.Sales_Site__c, currCSS.Sales_Site__r.Name));
				}
			}
		}
		siteChoice = '--None--';
		if(cssList.size() == 0) {
			soList.add(new SelectOption(siteChoice, siteChoice));
		} else {
			soList.add(0, new SelectOption(siteChoice, siteChoice));
		}
		
		return soList;
	}
	
	private void setupLists() {
		searchResults = new List<Pricing_Rule__c>();
		searchPricingRuleFields = new List<SearchItem>();
		searchAccountFields = new List<SearchItem>();
		dummyPr = new Pricing_Rule__c();
		dummyAccountObject = new Account();
		dummyCSS = new Customer_Sales_Site__c();
		regions = new List<SelectOption>();
		regions.add(defaultOption);
	}
	
	private void setupEditFields() {
		ModifyItem editItem = new ModifyItem();
		editItem.modifyFieldName = pricingRuleFields.get('Target_Price__c').getDescribe().getLabel();
		editItem.modifyFieldValue = '';
		editItem.modifyApiName = 'Target_Price__c';
		editItem.percentChange = false;
		editItem.percentOf = 'Target_Price__c';
		editItem.extraSpacing = false;
		item1 = editItem;
		ModifyItem editItem2 = new ModifyItem();
		editItem2.modifyFieldName = pricingRuleFields.get('Floor_Price__c').getDescribe().getLabel();
		editItem2.modifyFieldValue = '';
		editItem2.modifyApiName = 'Floor_Price__c';
		editItem2.percentChange = false;
		editItem2.percentOf = 'Floor_Price__c';
		editItem2.extraSpacing = false;
		item2 = editItem2;
	}
	
	private void setupSearchFields() {
		for(String s : pricingRuleAPINames) {
			SearchItem searchItemOne = new SearchItem();
			searchItemOne.searchFieldValue = '';
			searchItemOne.searchApiName = s;
			searchPricingRuleFields.add(searchItemOne);
		}
	}
	
	private Decimal getNewValueAsNormal(String value) {
		return Decimal.valueOf(value);
	}
	
	public Decimal getNewValueAsPercentage(String value, String currentPRValue, String baseValue) {
		Decimal newValue = Decimal.valueOf(value); 
		newValue = newValue.divide(100, 2);
		Decimal currentValue = Decimal.valueOf(currentPRValue);
		Decimal percentValue = currentValue * newValue; 
		return percentValue;
	}
	
	
	/*
		PUBLIC METHODS - PAGE REFERNCES, BUTTONS, LINKS
	*/
	
	public PageReference selectAllRecords() {
		if(this.resultSetRecords != null && this.resultSetRecords.size() > 0) {
			for(ResultSet rs : this.resultSetRecords) {
				rs.selectForSaving = selectAll;
			}
		}
		return null;
	}
		
	public PageReference searchRecords() {
		if(dummyPr.Account__c != null) {
	 		try {
				Boolean flagForDel = [SELECT Flag_for_Deletion__c FROM Account WHERE Id = :dummyPr.Account__c LIMIT 1].Flag_for_Deletion__c;
			} catch(Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
				return null;
			}			
		}
		if(dummyAccountObject.ParentId != null) {
	 		try {
				Boolean flagForDel = [SELECT Flag_for_Deletion__c FROM Account WHERE Id = :dummyAccountObject.ParentId LIMIT 1].Flag_for_Deletion__c;
			} catch(Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
				return null;
			}						
		}
		String query = PricingRuleUtil.getPricingSearchQuery();
		List<SearchItem> validFilters = new List<SearchItem>();
		for(SearchItem si : this.searchPricingRuleFields) {
			if(dummyPr.get(si.searchApiName) != null) {
				si.searchFieldValue = String.valueOf(dummyPr.get(si.searchApiName));
				validFilters.add(si);
			}
		}
				
		if(validFilters.size() > 0) {
			query += ' WHERE';
			for(Integer i=0; i<validFilters.size(); i++) {
				if(i > 0) {
					query += ' AND';
				}
				query += ' ' + validFilters.get(i).searchApiName;
				query += ' = \'' + validFilters.get(i).searchFieldValue + '\'';
			}
		}
		
		if(dummyAccountObject.ParentId != null) {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Account__r.ParentId = \'' + dummyAccountObject.ParentId + '\'';
		}
		
		if(selectedPHL1 != '--None--') {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Material_Item__r.PHL1__c = \'' + selectedPHL1 + '\'';			
		}

		if(dummyAccountObject.On_Contract__c != null) {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Account__r.On_Contract__c = \'' + dummyAccountObject.On_Contract__c + '\'';
		}

		if(siteChoice != '--None--') {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Receiving_Sales_Site__c = \'' + siteChoice + '\'';
		}		
		
		if(dummyAccountObject.Account_Manager__c != null) {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Account__r.Account_Manager__c like \'%' + dummyAccountObject.Account_Manager__c + '%\'';			
		}
		
		if(dummyCSS.Channel__c != null) {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Customer_Sales_Site__r.Channel__c = \'' + dummyCSS.Channel__c + '\'';			
		}
		
		if(dummyPr.Company_Code__c != null) {
			if(query.indexOf('WHERE') != -1) {
				query += ' AND';
			} else {
				query += ' WHERE';
			}
			
			query += ' Company_Code__c = \'' + dummyPr.Company_Code__c + '\'';			
		}
		System.debug('THE QUERY IS: ' + query);
		this.searchResults = (List<Pricing_Rule__c>)Database.query(query + ' LIMIT 500');
		resultSetRecords = new List<ResultSet>();
		List<PricingEngine.PricingData> pricingData = PricingEngine.getPricingData(searchResults);
		Map<Id, PricingEngine.PricingData> ruleToPd = new Map<Id, PricingEngine.PricingData>();
		for(PricingEngine.PricingData pePd : pricingData) {
			ruleToPd.put(pePd.rule.Id, pePd);
		}
		for(Pricing_Rule__c pr : this.searchResults) {
			ResultSet rs = new ResultSet();
			rs.selectForSaving = false;
			rs.prRecord = pr;
			rs.newTarget = pr.Target_Price__c;
			rs.newFloor = pr.Floor_Price__c;
			Decimal avgSell = 0.00;
			Decimal avgCost = 0.00;
			if(ruleToPd.get(pr.Id).averageSalesPrice != null) {
				avgSell = ruleToPd.get(pr.Id).averageSalesPrice;
			} else {
				avgSell = 0.00;
			}
			if(ruleToPd.get(pr.Id).costData != null && ruleToPd.get(pr.Id).costData.cost != null) {
				avgCost = ruleToPd.get(pr.Id).costData.cost;
			} else {
				avgCost = 0.00;
			}			
			
			rs.averageSalesPrice = avgSell;
			rs.averageCost = avgCost;
			rs.currencyType = pr.CurrencyIsoCode + ' ';
			resultSetRecords.add(rs);						
		}
		areResults = resultSetRecords.size() > 0;
		if(resultSetRecords.size() > 499) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Pricing_Search_Too_Many_Results));
		}
		return null;
	}
	
	public PageReference clearSearchResults() {
		if(resultSetRecords == null || resultSetRecords.size() == 0) {
			return null;
		}
		item1.errorMessage = null;
		item1.modifyFieldValue = '';
		item1.percentChange = false;
		item2.errorMessage = null;
		item2.modifyFieldValue = '';
		item2.percentChange = false;
		
		dummyPr.Price_Valid_From__c = null;
		this.searchResults.clear();
		this.searchResults = new List<Pricing_Rule__c>();
		this.resultSetRecords.clear();
		this.resultSetRecords = new List<ResultSet>();
		selectAll = false;
		this.areResults = false;
		
		return null;
	}
	
	public PageReference determineNewTargetAndFloor() {
		Boolean errorFound = false;
		Boolean updateNeeded = false;
		
		if(item1.modifyFieldValue != '' && item1.modifyFieldValue != null)  {
			updateNeeded = true;
		}
		if(item2.modifyFieldValue != '' && item2.modifyFieldValue != null)  {
			updateNeeded = true;
		}
				
		if(updateNeeded) {
			for(Integer i=0; i<resultSetRecords.size(); i++) {
				
					item1.errorMessage = null;
					if(item1.modifyFieldValue != '' && item1.modifyFieldValue != null) {
						try {
							if(!item1.percentChange && resultSetRecords.get(i).selectForSaving) {
								if(item1.modifyApiName == 'Target_Price__c') resultSetRecords.get(i).newTarget = getNewValueAsNormal(item1.modifyFieldValue);
								else if(item1.modifyApiName == 'Floor_Price__c') resultSetRecords.get(i).newFloor = getNewValueAsNormal(item1.modifyFieldValue);
							} else if(resultSetRecords.get(i).selectForSaving && item1.percentChange) {
								if(item1.percentOf == 'Avg_Sell_Price__c') {
									if(item1.modifyApiName == 'Target_Price__c') {
										resultSetRecords.get(i).newTarget = getNewValueAsPercentage(item1.modifyFieldValue, String.valueOf(resultSetRecords.get(i).averageSalesPrice), String.valueOf(resultSetRecords.get(i).prRecord.Target_Price__c));
									}
									else if(item1.modifyApiName == 'Floor_Price__c') {
										resultSetRecords.get(i).newTarget = getNewValueAsPercentage(item1.modifyFieldValue, String.valueOf(resultSetRecords.get(i).averageSalesPrice), String.valueOf(resultSetRecords.get(i).prRecord.Floor_Price__c));
									}									
								} else {
									if(item1.modifyApiName == 'Target_Price__c') {
										resultSetRecords.get(i).newTarget = getNewValueAsPercentage(item1.modifyFieldValue, String.valueOf(resultSetRecords.get(i).prRecord.get(item1.percentOf)), String.valueOf(resultSetRecords.get(i).prRecord.get(item1.modifyApiName)));
									}
									else if(item1.modifyApiName == 'Floor_Price__c') {
										resultSetRecords.get(i).newFloor = getNewValueAsPercentage(item1.modifyFieldValue, String.valueOf(resultSetRecords.get(i).prRecord.get(item1.percentOf)), String.valueOf(resultSetRecords.get(i).prRecord.get(item1.modifyApiName)));
									}
								}						
							}
						} catch(Exception e) {
							ApexPages.addMessages(e);
							item1.errorMessage = ERROR_MESSAGE_ON_MODIFY_ITEM;
							errorFound = true;
						}
					}
				
					item2.errorMessage = null;
					if(item2.modifyFieldValue != '' && item2.modifyFieldValue != null) {
						try {
							if(!item2.percentChange && resultSetRecords.get(i).selectForSaving) {
								if(item2.modifyApiName == 'Target_Price__c') resultSetRecords.get(i).newTarget = getNewValueAsNormal(item2.modifyFieldValue);
								else if(item2.modifyApiName == 'Floor_Price__c') resultSetRecords.get(i).newFloor = getNewValueAsNormal(item2.modifyFieldValue);
							} else if(resultSetRecords.get(i).selectForSaving && item2.percentChange) {
								if(item2.percentOf == 'Avg_Sell_Price__c') {
									if(item2.modifyApiName == 'Target_Price__c') {
										resultSetRecords.get(i).newTarget = getNewValueAsPercentage(item2.modifyFieldValue, String.valueOf(resultSetRecords.get(i).averageSalesPrice), String.valueOf(resultSetRecords.get(i).prRecord.Target_Price__c));
									}
									else if(item2.modifyApiName == 'Floor_Price__c') {
										resultSetRecords.get(i).newTarget = getNewValueAsPercentage(item2.modifyFieldValue, String.valueOf(resultSetRecords.get(i).averageSalesPrice), String.valueOf(resultSetRecords.get(i).prRecord.Floor_Price__c));
									}									
								} else {
									if(item2.modifyApiName == 'Target_Price__c') {
										resultSetRecords.get(i).newTarget = getNewValueAsPercentage(item2.modifyFieldValue, String.valueOf(resultSetRecords.get(i).prRecord.get(item2.percentOf)), String.valueOf(resultSetRecords.get(i).prRecord.get(item2.modifyApiName)));
									}
									else if(item2.modifyApiName == 'Floor_Price__c') {
										resultSetRecords.get(i).newFloor = getNewValueAsPercentage(item2.modifyFieldValue, String.valueOf(resultSetRecords.get(i).prRecord.get(item2.percentOf)), String.valueOf(resultSetRecords.get(i).prRecord.get(item2.modifyApiName)));
									}
								}						
							}
						} catch(Exception e) {
							ApexPages.addMessages(e);
							item2.errorMessage = ERROR_MESSAGE_ON_MODIFY_ITEM;
							errorFound = true;
						}
					}

				
				if(resultSetRecords.get(i).averageCost != null && resultSetRecords.get(i).newTarget != null && resultSetRecords.get(i).averageCost != 0.00 && resultSetRecords.get(i).newTarget != 0.00) {
					resultSetRecords.get(i).targetGmp = ((resultSetRecords.get(i).newTarget-resultSetRecords.get(i).averageCost)/resultSetRecords.get(i).newTarget)*100;
				} else {
					resultSetRecords.get(i).targetGmp = 100;
				}

				if(resultSetRecords.get(i).averageCost != null && resultSetRecords.get(i).newFloor != null && resultSetRecords.get(i).averageCost != 0.00 && resultSetRecords.get(i).newFloor != 0.00) {
					resultSetRecords.get(i).floorGmp = ((resultSetRecords.get(i).newFloor-resultSetRecords.get(i).averageCost)/resultSetRecords.get(i).newFloor)*100;
				} else {
					resultSetRecords.get(i).floorGmp = 100;
				}		
			}
		}
		return null;		
	}
	
	public PageReference saveEdits() {
		Boolean errorFound = false;
		Boolean updateNeeded = false;
		
		if(item1.modifyFieldValue != '' && item1.modifyFieldValue != null)  {
			updateNeeded = true;
		}
		if(item2.modifyFieldValue != '' && item2.modifyFieldValue != null)  {
			updateNeeded = true;
		}		
		
		if(dummyPr.Price_Valid_From__c != null) {
			updateNeeded = true;
		}
		if(updateNeeded) {
			List<Pricing_Rule__c> checkResultSet = new List<Pricing_Rule__c>();
			List<ResultSet> subResultSet = new List<ResultSet>();
			for(ResultSet rs : this.resultSetRecords) {
				if(rs.selectForSaving) {
					checkResultSet.add(rs.prRecord);
					subResultSet.add(rs);
				}
			}
			List<Pricing_Rule__c> newlyModifiedResults = checkResultSet.deepClone(false);
			List<PricingEngine.PricingData> pricingData = PricingEngine.getPricingData(checkResultSet);
			
			//String changeSetId = PricingRuleUtil.getChangeSetValue();
			for(Integer i=0; i<newlyModifiedResults.size(); i++) {
				
					item1.errorMessage = null;
					if(item1.modifyFieldValue != '' && item1.modifyFieldValue != null) {
						try {
							if(!item1.percentChange) {
								newlyModifiedResults.get(i).put(item1.modifyApiName, getNewValueAsNormal(item1.modifyFieldValue));
							} else {
								if(item1.percentOf != 'Avg_Sell_Price__c') {
									newlyModifiedResults.get(i).put(item1.modifyApiName, getNewValueAsPercentage(item1.modifyFieldValue, String.valueOf(newlyModifiedResults.get(i).get(item1.percentOf)), String.valueOf(newlyModifiedResults.get(i).get(item1.modifyApiName))));
								} else {
									newlyModifiedResults.get(i).put(item1.modifyApiName, getNewValueAsPercentage(item1.modifyFieldValue, String.valueOf(subResultSet.get(i).averageSalesPrice), String.valueOf(newlyModifiedResults.get(i).get(item1.modifyApiName))));
								}
							}
						} catch(Exception e) {
							ApexPages.addMessages(e);
							item1.errorMessage = ERROR_MESSAGE_ON_MODIFY_ITEM;
							errorFound = true;
						}
					}

					item2.errorMessage = null;
					if(item2.modifyFieldValue != '' && item2.modifyFieldValue != null) {
						try {
							if(!item2.percentChange) {
								newlyModifiedResults.get(i).put(item2.modifyApiName, getNewValueAsNormal(item2.modifyFieldValue));
							} else {
								if(item2.percentOf != 'Avg_Sell_Price__c') {
									newlyModifiedResults.get(i).put(item2.modifyApiName, getNewValueAsPercentage(item2.modifyFieldValue, String.valueOf(newlyModifiedResults.get(i).get(item2.percentOf)), String.valueOf(newlyModifiedResults.get(i).get(item2.modifyApiName))));
								} else {
									newlyModifiedResults.get(i).put(item2.modifyApiName, getNewValueAsPercentage(item2.modifyFieldValue, String.valueOf(subResultSet.get(i).averageSalesPrice), String.valueOf(newlyModifiedResults.get(i).get(item2.modifyApiName))));
								}
							}
						} catch(Exception e) {
							ApexPages.addMessages(e);
							item2.errorMessage = ERROR_MESSAGE_ON_MODIFY_ITEM;
							errorFound = true;
						}
					}
				
				if(dummyPr.Price_Valid_From__c != null) {
					Integer numDaysBetween = 1;
					if(this.searchResults.get(i).Price_Valid_From__c != null && this.searchResults.get(i).Price_Valid_To__c != null) {
						numDaysBetween = this.searchResults.get(i).Price_Valid_From__c.daysBetween(this.searchResults.get(i).Price_Valid_To__c);
					}
					newlyModifiedResults.get(i).Price_Valid_From__c = dummyPr.Price_Valid_From__c;
					newlyModifiedResults.get(i).Price_Valid_To__c = dummyPr.Price_Valid_From__c.addDays(numDaysBetween);
				}
				//newlyModifiedResults.get(i).Changeset_ID__c = changeSetId;
			}
			if(!errorFound) {
				try {
					insert newlyModifiedResults;
				} catch (Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PC_DateError));
				}
				//PricingRuleUtil.createNewDealsBasedOnPricingChange(newlyModifiedResults);
				clearSearchResults();
				searchRecords();
			}
		}
		return null;
	}
	
	/*
		INNER CLASSES
	*/
	public class ResultSet {
		public Boolean selectForSaving {get; set;}
		public Pricing_Rule__c prRecord {get; set;}
		public Decimal averageSalesPrice {get; set;}
		public Decimal averageCost {get; set;}
		public Decimal newTarget {get; set;}
		public Decimal newFloor {get; set;}
		public Decimal targetGmp {get; set;}
		public Decimal floorGmp {get; set;}
		public String currencyType {get; set;}
		
		public ResultSet() {
			selectForSaving = false;
			targetGmp = 100;
			floorGmp = 100;
		}
	}
	
	public class SearchItem {
		public String searchFieldValue {get; set;}
		public String searchApiName {get; set;}
	}
	
	public class ModifyItem {
		public String modifyFieldName {get; set;}
		public String modifyFieldValue {get; set;}
		public String modifyApiName {get; set;}
		public Boolean percentChange {get; set;}
		public String errorMessage {get; set;}
		public String percentOf {get; set;}
		public Boolean extraSpacing {get; set;}
	}
}