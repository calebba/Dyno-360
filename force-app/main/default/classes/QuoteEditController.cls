public with sharing class QuoteEditController {

	public Opportunity theQuote {get; set;}
	public Quote__c theScenario {get; set;}
	public Boolean renderBundled {get; set;}
	public String siteChoice {get; set;}
	public Boolean isInsert {get; set;}
	public Boolean isValidUser {get; set;}
	public Boolean changesAllowed {get; set;}
	private Map<Id, Customer_Sales_Site__c> cssToDetails;
	private Boolean doOnce;
	public Boolean isVolumetric {get; set;}
	public String PricingRegion {get; set;}
	
	public QuoteEditController(ApexPages.StandardController control) {
		isValidUser = isValidCheck();
		List<Quote__c> scenarioList = new List<Quote__c>();
		if(ApexPages.currentPage().getParameters().get('id') != null) {
			theQuote = QuoteUtil.getOpportunity(ApexPages.currentPage().getParameters().get('id'));
			isInsert = false;
			scenarioList = queryForQuote(theQuote.Id);
			
		} else {
			theQuote = new Opportunity();
			theQuote.StageName = System.Label.Default_Opportunity_Stage;
			theQuote.CloseDate = System.today().addDays(30);
			isInsert = true;
			
		}
		
		if(ApexPages.currentPage().getParameters().get('accid') != null) {
			theQuote.AccountId = ApexPages.currentPage().getParameters().get('accid');
			CheckFFDCustomer();
			Account currentAccount = [Select Pricing_Region__c from Account where Id = :theQuote.AccountId Limit 1];
			PricingRegion = currentAccount.Pricing_Region__c;
		}

		if(scenarioList.size() > 0) {
			theScenario = scenarioList.get(0);
			changesAllowed = (theScenario.Approval_Status__c != 'Approved' && theScenario.Approval_Status__c != 'Pending');
		} else {
			theScenario = new Quote__c();
			changesAllowed = true;
		}
		
		if(!changesAllowed) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QuoteCreateEP1 + ' ' + theScenario.Approval_Status__c + ' ' + System.Label.QuoteCreateEP2));
		}
			
		if(ApexPages.currentPage().getParameters().get('RecordType') != null) {
			renderBundled = (ApexPages.currentPage().getParameters().get('RecordType') == [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id);
			theQuote.RecordTypeId = (Id) ApexPages.currentPage().getParameters().get('RecordType');
			if(renderBundled) {
				isVolumetric = false;
			} else {
				isVolumetric = (ApexPages.currentPage().getParameters().get('RecordType') == [SELECT Id FROM RecordType WHERE DeveloperName = 'Deal_Volumetric_Quoted'].Id);
			}
		} else {
			renderBundled = (theQuote.RecordTypeId == [SELECT Id FROM RecordType WHERE DeveloperName = 'Bundled'].Id);
		}
		
		if(renderBundled && isInsert) {
			theQuote.Scenario_Choice__c = 'Delivery';
		}		
		doOnce = true;
	}	

	public List<Quote__c> queryForQuote(Id filterId) {
		return [SELECT Promotional__c, Trial__c, Id, Quote_Description__c, Quote_Valid_From__c, Quote_Valid_To__c, Approval_Status__c, CurrencyIsoCode, Quote_Amount__c, Country__c, Name, Price_Valid_From__c, Price_Valid_To__c, Opportunity__r.AccountId, Opportunity__r.RecordTypeId, Sales_Organization_Primary__r.Name, Sales_Organization_Primary__r.Company_Site__c, Sales_Organization_Primary__c, Volume_Produced__c, Volume_UoM__c, Calculated_Price__c, Opportunity__r.Customer_Group__c FROM Quote__c WHERE Opportunity__c = :filterId AND Active_Quote__c = true];
	}	
	
	public List<SelectOption> getPricingRegions(){
  		List<SelectOption> options = new List<SelectOption>();
        
   		Schema.DescribeFieldResult fieldResult = Account.Pricing_Region__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   		for( Schema.PicklistEntry f : ple)
   		{
      		options.add(new SelectOption(f.getLabel(), f.getValue()));
   		}       
   		return options;
	}

	public List<SelectOption> getCustomerSites() {
		List<SelectOption> soList = new List<SelectOption>();
		cssToDetails = new Map<Id, Customer_Sales_Site__c>();
		List<Customer_Sales_Site__c> cssList = new List<Customer_Sales_Site__c>();
		
	
		
		if(theQuote.AccountId != null) {
			cssList = [SELECT Id, Payment_Terms__c, Flag_For_Deletion__c, CurrencyIsoCode, Sales_Site__r.Region_Site__c, Pricelist__c, INCO__c, Delivery_Sales_Site__c, Service_Type__c, Drilled_By__c, Customer_Group__c, Sales_Site__r.Name, Sales_Site__r.Company_Site__r.Name, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c = :theQuote.AccountId order by Sales_Site__r.Name asc];
			String companyCodes = [SELECT Company_Codes__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Company_Codes__c;
			for(Customer_Sales_Site__c currCSS : cssList) {
				if(!currCSS.Flag_For_Deletion__c && currCSS.Sales_Site__r.Region_Site__c != null && currCSS.Sales_Site__r.Company_Site__c != null && companyCodes.indexOf(currCSS.Sales_Site__r.Company_Site__r.Name) != -1) {
					soList.add(new SelectOption(currCSS.Id, currCSS.Sales_Site__r.Name));
					cssToDetails.put(currCSS.Id, currCSS);
				}
			}
		}
		
		if(cssList.size() == 0) {
			siteChoice = '--None--';
			soList.add(new SelectOption(siteChoice, '--' + System.Label.None + '--'));
		} else {
			if(doOnce && theQuote.Id != null) {
				siteChoice = theQuote.Customer_Sales_Site__c;
				doOnce = false;
			} else {
				siteChoice = cssList[0].Id;	
			}	
		}
		
		return soList;
	}
	
	private Boolean validateRecord() {
		Boolean shouldFail = false;
		Boolean flagForDel = false;
		if(theQuote.AccountId != null) {
	 		try {
				flagForDel = [SELECT Flag_for_Deletion__c FROM Account WHERE Id = :theQuote.AccountId LIMIT 1].Flag_for_Deletion__c;
			} catch(Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
				return false;
			}
		}
	
		
		if(siteChoice == '--None--') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Opportunity.fields.Sales_Site__c.label + ' ' + System.Label.QGP_Required));
			return false;
		} else if(theScenario.Quote_Valid_From__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote__c.fields.Quote_Valid_From__c.label + ' ' + System.Label.QGP_Required));
			return false;			
		} else if(theScenario.Quote_Valid_To__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote__c.fields.Quote_Valid_To__c.label + ' ' + System.Label.QGP_Required));
			return false;			
		} else if(theScenario.Price_Valid_From__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote__c.fields.Price_Valid_From__c.label + ' ' + System.Label.QGP_Required));
			return false;			
		} else if(theScenario.Price_Valid_To__c == null) {	
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote__c.fields.Price_Valid_To__c.label + ' ' + System.Label.QGP_Required));
			return false;						
		} else if(theScenario.Quote_Valid_To__c < theScenario.Quote_Valid_From__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Date_Range_Inccorect));
			return false;			
		}else if(theScenario.Price_Valid_To__c < theScenario.Price_Valid_From__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Price_Validation));
			return false;			
		}else if(theQuote.AccountId == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Opportunity.fields.AccountId.label + ' ' + System.Label.QGP_Required));
			return false;		
		} else if(theQuote.CloseDate == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Opportunity.fields.CloseDate.label + ' ' + System.Label.QGP_Required));
			return false;
		} else if(theQuote.Scenario_Choice__c == 'Shot Service with Drilling' && theQuote.Hole_Size__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Hole_Choice + ' ' + System.Label.QGP_Required));
			return false;
		} else if(cssToDetails.get((Id)siteChoice).Flag_For_Deletion__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Customer_Not_Purchase));
			return false;							
		} else if(flagForDel) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Customer_Flag_Deletion));
			return false;					
		}  else if([SELECT count() FROM Customer_Sales_Site__c WHERE Customer__c = :theQuote.AccountId AND Sales_Site__c = :cssToDetails.get((Id)siteChoice).Sales_Site__c] == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Sales_Site_Incorrect));
			return false;
		}
		
		
		
		

		return true;
	}
	
	private PageReference saveQuote(String retUrl) {
		if(validateRecord()) {
			
			String pricingSalesOffice;
			pricingSalesOffice = [Select Pricing_Sales_Office__c from Sales_Site__c where Id =: cssToDetails.get((Id)siteChoice).Sales_Site__c limit 1].Pricing_Sales_Office__c;
			
			
			theQuote.Customer_Sales_Site__c = (Id)siteChoice;
			theQuote.CurrencyIsoCode = cssToDetails.get((Id)siteChoice).CurrencyIsoCode;
			theQuote.Sales_Site__c = cssToDetails.get((Id)siteChoice).Sales_Site__c;
			theQuote.Description = theScenario.Quote_Description__c;
			theQuote.Pricing_Region__c = PricingRegion;	
			//slee added
			theQuote.Pricing_Sales_Office__c = pricingSalesOffice;
			if(isInsert) {
				theQuote.Name = 'temp';
				insert theQuote;
				List<Opportunity> newOpps = new List<Opportunity>{QuoteUtil.getOpportunity(theQuote.Id)};
				OpportunityTriggerUtils.createQuote(newOpps, theScenario.Quote_Valid_From__c, theScenario.Quote_Valid_To__c, theScenario.Price_Valid_From__c, theScenario.Price_Valid_To__c, theScenario.Quote_Description__c, theScenario.Promotional__c, theScenario.Trial__c, cssToDetails.get((Id)siteChoice), theQuote.Scenario_Choice__c, theQuote.Hole_Size__c, theScenario.Volumetric_Parent_Product__c);
				update newOpps;
			} else {		
				update theQuote;
				if(changesAllowed) {
					if(renderBundled) {
						delete [SELECT Id FROM Quote_Line_Item__c WHERE Is_Bundled__c = true AND Quote__c = :theScenario.Id];
						OpportunityTriggerUtils.createBundledServices(theQuote.Scenario_Choice__c, theQuote.Hole_Size__c, cssToDetails.get((Id)siteChoice).Sales_Site__c, new List<Quote__c>{theScenario}, theScenario.Price_Valid_From__c, theScenario.Price_Valid_To__c);
					}
					update theScenario;
				}
			}
			
			retUrl = retUrl.replace('NoIdYet', theQuote.Id);
			return new PageReference(retUrl);
		}		
		return null;
	}
	
	public PageReference revertSelected() {

		getCustomerSites();
		siteChoice = '--None--';
		
		if(theQuote.AccountId != null) {
			PricingRegion = [Select Pricing_Region__c from Account where Id =: theQuote.AccountId limit 1].Pricing_Region__c;
		}else{
			PricingRegion = '';			
		}
		
		return null;
	}
	
	public PageReference performSave() {
		return saveQuote('/NoIdYet');
	}

	public PageReference performSaveAndNew() {
		return saveQuote('/apex/QuotePage');
	}	
	public Boolean isValidCheck(){
		
		User currUser = [SELECT Id, Company_Codes__c FROM User WHERE Id =: UserInfo.getUserId()];
		if(currUser.Company_Codes__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Not_Associated));
			return false;
		}
		return true;
	}
	
	private void CheckFFDCustomer(){
		Account custAcct = [Select Flag_for_Deletion__c From Account Where Id = :theQuote.AccountId];
		
		if(custAcct.Flag_for_Deletion__c){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Quote_Edit_Customer_Flag_Deletion));
		}
	}
}