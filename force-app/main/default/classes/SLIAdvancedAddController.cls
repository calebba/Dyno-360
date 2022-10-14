public with sharing class SLIAdvancedAddController {
	
	public Quote_Line_Item__c currentLine {get; set;}
	public Quote__c scenario {get; set;}
	public List<Formula_Mapping__c> formulaList {get; set;}
	public String selectedPHL1 {get; set;}
	public String selectedPHL2 {get; set;}
	public String selectedPHL3 {get; set;}
	public String selectedPHL1Advanced {get; set;}
	public String selectedPHL2Advanced {get; set;}
	public String selectedPHL3Advanced {get; set;}
	public String selectedCode {get; set;}
	public String selectedCodeAdvanced {get; set;}
	public String selectedFormula {get; set;}
	public String selectedMaterialCode {get; set;}
	public Material_Item__c theMaterial {get; set;}
	private String oldUoM;
	private List<Alternate_Unit_of_Measure__c> currAums;
	public PricingEngine.PricingData pd {get; set;}
	public PricingEngine.FormulaPricingData fpd {get; set;}
	public Decimal avgPrice {get; set;}
	private List<String> requiredFields = new List<String>{'Source_Sales_Site__c', 'Sales_Site__c', 'Price_Valid_From__c', 'Price_Valid_To__c'};
	private Map<String, Schema.SObjectField> qliFields;
	public Boolean showPopup {get; set;}
	public Opportunity dummyOpp {get; set;}
	public Material_Cost__c dummyCost {get; set;}
	public String sourceSalesSite {get; set;}
	public List<Material_Cost__c> results {get; set;}
	public Boolean areResults {get; set;}
	public Boolean isFinanceUser {get; set;}
	private List<PricingEngine.PricingData> pricingDataList {get; set;}
	private List<PricingEngine.FormulaPricingData> formulaicPricingDataList {get; set;}
	public Boolean extendSites {get; set;}
	public Boolean isIe {get; set;}
	public Boolean searchPreferred {get; set;}
	public String searchDescription {get; set;}
	public String searchCode {get; set;}
	private Map<Id, PricingEngine.PricingData> miToPdMap;
	private Map<Id, PricingEngine.FormulaPricingData> mitoFpdMap;
	private User currentUser;
	private static final Integer UNEXTENDED_LIMIT = 1000;
	
	public SLIAdvancedAddController() {
		
		if(ApexPages.currentPage().getParameters().get('scenarioID') == null) {
			throw new IllegalStateException(System.Label.Advanced_Add_Fatal);
		}
		
		//Initialize Material Search related vars
		dummyOpp = new Opportunity();
		dummyCost = new Material_Cost__c();
		results = new List<Material_Cost__c>();
		searchPreferred = false;
		searchDescription = '';
		searchCode = '';
		
		//Render booleans
		isIe = ApexPages.currentPage().getHeaders().get('USER-AGENT') != null && ApexPages.currentPage().getHeaders().get('USER-AGENT').contains('MSIE');
		isFinanceUser = UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = '# Custom Dyno - Finance' LIMIT 1].Id;
		areResults = false;
		showPopup = false;
		
		//Picklist related vars
		sourceSalesSite = '--None--';
		selectedFormula = '--None--';
		selectedPHL1 = '--None--';
		selectedPHL2 = '--None--';
		selectedPHL3 = '--None--';
		selectedCode = '--None--';
		selectedPHL1Advanced = '--None--';
		selectedPHL2Advanced = '--None--';
		selectedPHL3Advanced = '--None--';
		selectedCodeAdvanced = '--None--';	
		
		//Validation related init		
		Map<String, Schema.SObjectType> globalFields = Schema.getGlobalDescribe();
		qliFields = globalFields.get('Quote_Line_Item__c').getDescribe().fields.getMap();
		String scenarioID = ApexPages.currentPage().getParameters().get('scenarioID');
		scenario = queryForQuote(scenarioID);
		currentUser = [SELECT Product_Manager__r.Name, Product_Manager_2__r.Name, Product_Manager_3__r.Name, Product_Manager_1_PHL1s__c, Product_Manager_2_PHL1s__c, Product_Manager_3_PHL1s__c FROM User WHERE Id = :scenario.Opportunity__r.OwnerId];
		extendSites = true;
		pricingDataList = new List<PricingEngine.PricingData>();
		formulaicPricingDataList = new List<PricingEngine.FormulaPricingData>();
		miToPdMap = new Map<Id, PricingEngine.PricingData>();
		miToFpdMap = new Map<Id, PricingEngine.FormulaPricingData>();
		initEmptyLine();
		fullMaterialInit();			
		
		//Scenario Line Item init
		if(ApexPages.currentPage().getParameters().get('sliID') != null) {
            System.debug('sliID + ' + ApexPages.currentPage().getParameters().get('sliID'));
			extendSites = false;
			String sliID = ApexPages.currentPage().getParameters().get('sliID');
			currentLine = queryForLine(sliID);
			oldUoM = currentLine.UoM__c;
			selectedPHL1 = currentLine.Material_Item__r.PHL1__c;
			selectedPHL2 = currentLine.Material_Item__r.PHL2__c;
			singleFind();
			if((currentLine.Material_Item__r.PHL1__c + currentLine.Material_Item__r.PHL2__c + currentLine.Material_Item__r.PHL3__c) == currentLine.Material_Item__r.Material_Code__c) {
				selectedPHL3 = currentLine.Material_Item__c;
			} else {
				selectedCode = currentLine.Material_Item__c;
			}
			
			if(currentLine.Formula_Flag__c) {
				getFormulaList();			
			} else {
				getCurrAums();		
			}
		}
		
		initTheMaterial();	
	}
	
	public PageReference selectPHL1() {
		/*CurrencyData theLimit = new CurrencyData(' ', UNEXTENDED_LIMIT);
		if(currentLine.Formula_Flag__c) {
			List<PricingEngine.FormulaPricingData> fpdList = PricingEngine.getFormulaPricingData(scenario.Opportunity__r.AccountId, currentLine.Sales_Site__c, currentLine.Source_Sales_Site__c);
			formulaicPricingDataList.clear();
			fullMaterialInit();
			miToFpdMap.clear();

			for(PricingEngine.FormulaPricingData fpd : fpdList) {
				if(fpd.costData != null && formulaicPricingDataList.size() < 1000) {
					formulaicPricingDataList.add(fpd);
					miToFpdMap.put(fpd.materialId, fpd);
				}	
			}			
		} else {
			List<PricingEngine.PricingData> pdList = PricingEngine.getPricingData(scenario.Opportunity__r.AccountId, currentLine.Sales_Site__c, selectedPHL1, extendSites, currentLine.Price_Valid_From__c, currentLine.Price_Valid_To__c, scenario.Sales_Organization_Primary__r.Company_Site__c, false, scenario.Opportunity__r.Customer_Group__c, currentLine.Source_Sales_Site__c, '--None--', '--None--', extendSites ? theLimit : new CurrencyData(' ', -1),scenario.Opportunity__r.Pricing_Region__c,scenario.Opportunity__r.Pricing_Sales_Office__c);
			pricingDataList.clear();
			fullMaterialInit();
			miToPdMap.clear();
			for(PricingEngine.PricingData pd : pdList) {
				if(pd.costData != null && pricingDataList.size() < 1000) {
					pricingDataList.add(pd);
					miToPdMap.put(pd.rule.Material_Item__c, pd);
				}	
			}
		}	
		
		if( (extendSites && theLimit.value == 0) || (formulaicPricingDataList.size() >= 999) || (pricingDataList.size() >= 999) ) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_Too_Many_Records));
		}*/
		return null;
	}	
	
	public PageReference selectPHL2() {
		CurrencyData theLimit = new CurrencyData(' ', UNEXTENDED_LIMIT);
		if(currentLine.Formula_Flag__c) {
			List<PricingEngine.FormulaPricingData> fpdList = PricingEngine.getFormulaPricingData(scenario.Opportunity__r.AccountId, currentLine.Sales_Site__c, currentLine.Source_Sales_Site__c);
			formulaicPricingDataList.clear();
			fullMaterialInit();
			miToFpdMap.clear();

			for(PricingEngine.FormulaPricingData fpd : fpdList) {
				if(fpd.costData != null && formulaicPricingDataList.size() < 1000) {
					formulaicPricingDataList.add(fpd);
					miToFpdMap.put(fpd.materialId, fpd);
				}	
			}			
		} else {
			//PricingEngine.getPricingData line 238 (replace first '--None--' with selected PHL2)
			system.debug('Values to get Pricing Data'+ scenario.Opportunity__r.AccountId + ' '+ currentLine.Sales_Site__c+ ' '+ extendSites+ ' '+currentLine.Price_Valid_From__c+ ' '+ currentLine.Price_Valid_To__c+ ' '+scenario.Sales_Organization_Primary__r.Company_Site__c+ ' '+ scenario.Opportunity__r.Customer_Group__c+ ' '+currentLine.Source_Sales_Site__c+ ' '+scenario.Opportunity__r.Pricing_Region__c+ ' '+scenario.Opportunity__r.Pricing_Sales_Office__c);
			List<PricingEngine.PricingData> pdList = PricingEngine.getPricingData(scenario.Opportunity__r.AccountId, currentLine.Sales_Site__c, selectedPHL1, extendSites, currentLine.Price_Valid_From__c, currentLine.Price_Valid_To__c, scenario.Sales_Organization_Primary__r.Company_Site__c, false, scenario.Opportunity__r.Customer_Group__c, currentLine.Source_Sales_Site__c, selectedPHL2, '--None--', extendSites ? theLimit : new CurrencyData(' ', -1),scenario.Opportunity__r.Pricing_Region__c,scenario.Opportunity__r.Pricing_Sales_Office__c);
			pricingDataList.clear();
			fullMaterialInit();
			miToPdMap.clear();
			for(PricingEngine.PricingData pd : pdList) {
				if(pd.costData != null && pricingDataList.size() < 1000) {
					pricingDataList.add(pd);
					miToPdMap.put(pd.rule.Material_Item__c, pd);
				}	
			}
		}	
		
		if( (extendSites && theLimit.value == 0) || (formulaicPricingDataList.size() >= 999) || (pricingDataList.size() >= 999) ) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_Too_Many_Records));
		}					
		return null;
	}
	
	private void fullMaterialInit() {
		formulaList = new List<Formula_Mapping__c>();
		currAums = new List<Alternate_Unit_of_Measure__c>();
		pd = null;
		fpd = null;
		oldUoM = null;
		avgPrice = 0.00;
		currentLine.Base_Floor__c = 0.00;
		currentLine.Base_Target__c = 0.00;
		currentLine.Base_Cost__c = 0.00;
		currentLine.Base_Cost_ST__c = 0.00;
		currentLine.Floor_Price__c = 0.00;
		currentLine.Target_Price__c = 0.00;		
		currentLine.Actual_Price__c = 0.00;
		currentLine.Per__c = null;
		currentLine.UoM__c = null;
		currentLine.Cost__c = null;
		currentLine.Quantity__c = 1;
		selectedFormula = '--None--';
		initMaterial();
		getValidUoM();
	}
	
	private void materialChangeInit() {
		if(currentLine.Formula_Flag__c) {
			fpd = miToFpdMap.get(currentLine.Material_Item__c);
			if(fpd != null) {
				pullFromFormulaicPricingData();
				getFormulaList();
			}
		} else {
			pd = miToPdMap.get(currentLine.Material_Item__c);
			if( pd != null) {
				pullFromPricingData();
				getCurrAums();
			}
		}
	}
	
	private void pullFromPricingData() {
		currentLine.UoM__c = pd.uom;
		currentLine.Per__c = pd.per;
		currentLine.Formula__c = null;
		currentLine.Base_Floor__c = pd.rule.Floor_Price__c;
		currentLine.Base_Target__c = pd.rule.Target_Price__c;
		if (pd.costData.cost3m != null && pd.costData.cost3m != 0)
			currentLine.Base_Cost__c = pd.costData.cost3m;
		else if (pd.costData.cost6m != null && pd.costData.cost6m != 0)
			currentLine.Base_Cost__c = pd.costData.cost6m;
		else
			currentLine.Base_Cost__c = pd.costData.cost;
		currentLine.Base_Cost_ST__c = pd.costData.seeThroughCost;
		currentLine.Floor_Price__c = (currentLine.Base_Floor__c / (pd.per/currentLine.Per__c)).setScale(2); 
		currentLine.Target_Price__c = (currentLine.Base_Target__c / (pd.per/currentLine.Per__c)).setScale(2);
		currentLine.Actual_Price__c = currentLine.Target_Price__c.setScale(2);
		if(!extendSites) {
			currentLine.Cost__c = currentLine.Base_Cost__c / (1/currentLine.Per__c);
			currentLine.Cost_See_Through__c = currentLine.Base_Cost_ST__c / (1/currentLine.Per__c);
		} else {
			currentLine.Cost__c = currentLine.Base_Cost__c;
			currentLine.Cost_See_Through__c = currentLine.Base_Cost_ST__c;
		}
		system.debug('pricing rule before schedule' + currentLine.Pricing_Rule__c);
        system.debug('Pricing Data' + pd);
        system.debug('Pricing Data Rule' + pd.rule );
		if(pd.rule != null && pd.rule.Id != null) {
			currentLine.Pricing_Rule__c = pd.rule.Id;
            system.debug('pricing rule after schedule' + pd.rule +' '+ pd.rule.Id + ' '+currentLine.Pricing_Rule__c);
		}
		
		avgPrice = pd.averageSalesPrice;		
	}
	
	private void pullFromFormulaicPricingData() {
		currentLine.Actual_Price__c = fpd.actualPrice;
		currentLine.Target_Price__c = 0.00;
		currentLine.Floor_Price__c = 0.00;
		avgPrice = 0.00;
		currentLine.UoM__c = fpd.uom;
		currentLine.Per__c = fpd.per;
		if (fpd.costData.cost3m != null && fpd.costData.cost3m != 0)
			currentLine.Cost__c = fpd.costData.cost3m;
		else if (fpd.costData.cost6m != null && fpd.costData.cost6m != 0)
			currentLine.Cost__c = fpd.costData.cost6m;
		else
			currentLine.Cost__c = fpd.costData.cost;
		currentLine.Cost_See_Through__c = fpd.costData.seeThroughCost;		
	}
		
	private void initEmptyLine() {
		currentLine = new Quote_Line_Item__c();
		currentLine.Sales_Site__c = scenario.Sales_Organization_Primary__c;
		currentLine.Source_Sales_Site__c = scenario.Sales_Organization_Primary__c;
		currentLine.Quote__c = scenario.Id;
		currentLine.Price_Valid_From__c = scenario.Price_Valid_From__c;
		currentLine.Price_Valid_To__c = scenario.Price_Valid_To__c;	
		currentLine.Formula_Flag__c = false;		
	}
	
	
	
	
	private void singleFind() {
		pricingDataList.clear();
		miToPdMap.clear();
		formulaicPricingDataList.clear();
		miToFpdMap.clear();
		
		if(currentLine.Formula_Flag__c) {
			for(PricingEngine.FormulaPricingData currFpd : PricingEngine.getFormulaPricingData(scenario.Opportunity__r.AccountId, currentLine.Sales_Site__c, currentLine.Source_Sales_Site__c)) {
				if(currFpd.materialId == currentLine.Material_Item__c) {
					fpd = currFpd;
				}		
			}					
		} else {
			try {
                system.debug('Assign Pd Values:'+ scenario.Opportunity__r.AccountId+' '+currentLine.Source_Sales_Site__c+' '+currentLine.Sales_Site__c+' '+ currentLine.Material_Item__c+' '+currentLine.Price_Valid_From__c+' '+currentLine.Price_Valid_To__c+' '+scenario.Sales_Organization_Primary__r.Company_Site__c+' '+ scenario.Opportunity__r.Customer_Group__c+' '+ scenario.Opportunity__r.Pricing_Region__c+' '+scenario.Opportunity__r.Pricing_Sales_Office__c);
				pd = PricingEngine.getPricingData(scenario.Opportunity__r.AccountId, currentLine.Source_Sales_Site__c, currentLine.Sales_Site__c, currentLine.Material_Item__c, currentLine.Price_Valid_From__c, currentLine.Price_Valid_To__c,scenario.Sales_Organization_Primary__r.Company_Site__c, scenario.Opportunity__r.Customer_Group__c, scenario.Opportunity__r.Pricing_Region__c,scenario.Opportunity__r.Pricing_Sales_Office__c);	
				pricingDataList.add(pd);
				miToPdMap.put(currentLine.Material_Item__c, pd);
			} catch(Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AA_No_PR));
				materialPHLInit();
			}
		}
		
		if(currentLine.Formula_Flag__c && fpd == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AA_No_FM));
			materialPHLInit();
		} else if(fpd != null) {
			formulaicPricingDataList.add(fpd);
			miToFpdMap.put(currentLine.Material_Item__c, fpd);
		}
	}

	public PageReference selectItemByPHL3() {
		List<Pricing_Rule__c> phl3Materials = [SELECT Receiving_Sales_Site__c, Region_Site__c, Company_Code__c, Material_Item__c, Material_Item__r.PHL1__c, Material_Item__r.Name FROM Pricing_Rule__c WHERE Material_Item__r.Is_PHL__c = 1 AND Material_Item__r.Product_Hierarchy__c = :ApexPages.currentPage().getParameters().get('materialHierarchy')];
	 	Pricing_Rule__c phl3Material;
	 	
	 	if(phl3Materials.size() == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_PHL3_No_Material));
			materialPHLInit();
			return displayPopup();
	 	} else {
	 		phl3Material = phl3Materials.get(0);
	 	}
	 	
	 	selectedPHL1				           = phl3Material.Material_Item__r.PHL1__c;
	 	currentLine.Material_Item__c           = phl3Material.Material_Item__c;
	 	if(phl3Material.Receiving_Sales_Site__c != null) {
	 		currentLine.Sales_Site__c          = phl3Material.Receiving_Sales_Site__c;
	 	} else if(phl3Material.Region_Site__c != null) {
	 		currentLine.Sales_Site__c          = [SELECT Id FROM Sales_Site__c WHERE Region_Site__c = :phl3Material.Region_Site__c LIMIT 1].Id;
	 	} else {
	 		currentLine.Sales_Site__c          = [SELECT Id FROM Sales_Site__c WHERE Company_Site__c = :phl3Material.Company_Code__c AND Region_Site__c <> null LIMIT 1].Id;
	 	}
	 	theMaterial.Name                       = phl3Material.Material_Item__r.Name;
	 	selectedPHL3                           = currentLine.Material_Item__c;
	 	extendSites                            = true;
	 	currentLine.Formula_Flag__c            = false;
		singleFind();
		initializeLine();
		currentLine.Quantity__c                = 1;
		system.debug('This is for regions '+currentLine.Sales_Site__c + phl3Material);
		return displayPopup();
	}	
	
	private void initializeLine() {
		if(fpd != null) {		
			pullFromFormulaicPricingData();
			getFormulaList();
		} else if(pd != null){
			pullFromPricingData();
			getCurrAums();
		}		
	}
	
	public PageReference selectItem() {
		currentLine.Material_Item__c     = ApexPages.currentPage().getParameters().get('materialID');
		theMaterial.Name 			     = ApexPages.currentPage().getParameters().get('materialName');
	 	selectedPHL1				     = ApexPages.currentPage().getParameters().get('materialPHL1'); 
	 	selectedCode                     = currentLine.Material_Item__c;
	 	extendSites                      = false;
	 	currentLine.Quantity__c          = 1;
	 	
	 	if(currentLine.Formula_Flag__c) {
	 		//Take the first formula mappings sales site and source sales site where the related formulas material is the current one and the customer is the current one, and the sales site and source sales site are in the current company
	 		List<Formula_Mapping__c> tempMappings = [SELECT Sales_Site__c, Source_Sales_Site__c FROM Formula_Mapping__c WHERE Formula__r.Material_Item__c = :currentLine.Material_Item__c AND Customer__c = :scenario.Opportunity__r.AccountId AND Sales_Site__r.Company_Site__c = :scenario.Sales_Organization_Primary__r.Company_Site__c AND Source_Sales_Site__r.Company_Site__c = :scenario.Sales_Organization_Primary__r.Company_Site__c];
	 		if(tempMappings.size() == 0) {
	 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AA_No_FM));
	 			return displayPopup();
	 		} else {
	 			currentLine.Sales_Site__c = tempMappings.get(0).Sales_Site__c;
	 			currentLine.Source_Sales_Site__c = tempMappings.get(0).Source_Sales_Site__c;
	 		}
	 	}  else {
	 		currentLine.Sales_Site__c        = ApexPages.currentPage().getParameters().get('materialSite');
	 	}
	 	
		singleFind();
        system.debug('selectItem function '+ currentLine.Sales_Site__c);
		initializeLine();

		return displayPopup();
	}
		
	private void initMaterial() {
		currentLine.Material_Item__c = null;
		theMaterial = new Material_Item__c();
		theMaterial.Name = System.Label.TBD;
	}
	
	private Id getMaterialId() {
		Id theId = null;

		try {
			theId = selectedPHL3;
		} catch(Exception e) {
			try {
				theId = selectedCode;
			} catch(Exception e2) {
				theId = null;
			}
		}
			
		return theId;
	}

	public PageReference setMaterialFromCode() {
		return setMaterial(true);
	}
	
	public PageReference setMaterialFromPHL3() {
		return setMaterial(false);
	}
	
	private PageReference setMaterial(Boolean fromCode) {
		if(fromCode && selectedCode != '--None--') {
			selectedPHL3 = '--None--';
			currentLine.Quantity__c = 1;
			currentLine.Material_Item__c = (Id) selectedCode;
			materialChangeInit();
		} else if(fromCode && selectedCode == '--None--') {
			fullMaterialInit();
		} else if(!fromCode && selectedPHL3 != '--None--') {
			selectedCode = '--None--';
			currentLine.Quantity__c = 1;
			currentLine.Material_Item__c = (Id) selectedPHL3;
			materialChangeInit();
		} else if(!fromCode && selectedCode == '--None--') {
			fullMaterialInit();
		}
		
		initTheMaterial();
		
		return null;
	}
	
	private void initTheMaterial() {
		if(currentLine.Material_Item__c != null) {
			theMaterial = [SELECT Id, Name FROM Material_Item__c WHERE Id = :currentLine.Material_Item__c];
		} else {
			initMaterial();
		}			
	}
	
	
	
	
	/* CODE BELOW THIS IS OK
	   CODE ABOVE THIS NEEDS TO BE REWORKED, ITS JUST TOO CONFUSING!
	*/
	
	public PageReference onFormulaCheck() {
		materialPHLInit();
		selectedPHL1 = '--None--';
		return null;
	}	
	
	private void materialPHLInit() {
		fullMaterialInit();
		pricingDataList.clear();
		formulaicPricingDataList.clear();
		miToPdMap.clear();
		miToFpdMap.clear();
		selectedPHL3 = '--None--';
		selectedCode = '--None--';		
	}
	
	private void getFormulaList() {
		formulaList = [SELECT Id, Name, Formula__r.Formula_Text__c, Formula__c FROM Formula_Mapping__c WHERE Formula__r.Material_Item__c = :currentLine.Material_Item__c AND Sales_Site__c = :currentLine.Sales_Site__c AND Source_Sales_Site__c = :currentLine.Source_Sales_Site__c AND Customer__c = :scenario.Opportunity__r.AccountId];
	}
	
	private void getCurrAums() {
		currAums = [SELECT Id, Name, X__c, Y__c, BUn__c, AUn__c, Material_Item__c  FROM Alternate_Unit_of_Measure__c WHERE Material_Item__c = :currentLine.Material_Item__c AND BUn__c = :pd.uom];	
	}
	
	public List<SelectOption> getValidUoM() {
		List<SelectOption> validUom = new List<SelectOption>();
		if(currentLine.Formula_Flag__c && fpd != null) {
			validUom.add(new SelectOption(fpd.uom, fpd.uom));
			currentLine.UoM__c = fpd.uom;
		} else if(!currentLine.Formula_Flag__c) {
			String baseUoM;
			
			for(Alternate_Unit_of_Measure__c currAum : currAums) {
				if(currAum.Id != null) {
					validUom.add(new SelectOption(currAum.AUn__c, currAum.AUn__c));
				}
			}
		}		
			
		if(validUom.size() == 0) {
			validUom.add(new SelectOption('--None--', System.Label.QGP_No_UoM));
		}
		
		if(currentLine.UoM__c == null) {
			currentLine.UoM__c = validUom[0].getValue();
		}

		return validUom;
	}	

	public PageReference performConversion() {
		String baseUoM;
		Integer basePer;
		if(currentLine.Formula_Flag__c) {
			baseUoM = fpd.uom;
			basePer = fpd.per;
		} else {
			basePer = pd.per;
			baseUoM = pd.uom;
		}		

		//Old UoM -> Base UoM	
		for(Alternate_Unit_of_Measure__c currAum : currAums) {
			if(currAum.AUn__c == oldUoM && baseUoM == currAum.BUn__c) {
				currentLine.Base_Target__c = convertQuantity(currentLine.Base_Target__c, currAum, false);
				currentLine.Base_Floor__c = convertQuantity(currentLine.Base_Floor__c, currAum, false);
				currentLine.Base_Cost__c = convertQuantity(currentLine.Base_Cost__c, currAUM, false);
				currentLine.Base_Cost_ST__c = convertQuantity(currentLine.Base_Cost_ST__c, currAUM, false);
			}	
		}
		//Base UoM -> New UoM
		System.debug('Base UoM -> New UoM; BT: ' + currentLine.Base_Target__c);
		System.debug('AUN = ' + currentLine.UoM__c);
		System.debug('BUN = ' + baseUoM);			
		for(Alternate_Unit_of_Measure__c currAum : currAums) {
			if(currAum.AUn__c == currentLine.UoM__c && currAum.BUn__c == baseUoM) {
				currentLine.Base_Floor__c = convertQuantity(currentLine.Base_Floor__c, currAum, true);
				currentLine.Base_Target__c = convertQuantity(currentLine.Base_Target__c, currAum, true);
				currentLine.Base_Cost__c = convertQuantity(currentLine.Base_Cost__c, currAUM, true);
				currentLine.Base_Cost_ST__c = convertQuantity(currentLine.Base_Cost_ST__c, currAUM, true);				
			}
		}
		oldUoM = currentLine.UoM__c;
		currentLine.Floor_Price__c = (currentLine.Base_Floor__c / (basePer/currentLine.Per__c)).setScale(2);
		currentLine.Target_Price__c = (currentLine.Base_Target__c / (basePer/currentLine.Per__c)).setScale(2);
		currentLine.Actual_Price__c = currentLine.Target_Price__c.setScale(2);
		currentLine.Cost__c = currentLine.Base_Cost__c / (1/currentLine.Per__c);
		currentLine.Cost_See_Through__c = currentLine.Base_Cost_ST__c / (1/currentLine.Per__c);
		return null;
	}
	
	private static Decimal convertQuantity(Decimal quant, Alternate_Unit_of_Measure__c aum, Boolean toAum) {
		if(toAum) {
			return quant * (aum.X__c / aum.Y__c);
		}
		return quant * (aum.Y__c / aum.X__c);
	}

	public PageReference changePer() {
		Integer basePer;
		if(currentLine.Material_Item__c != null) {
			if(currentLine.Formula_Flag__c) {
				basePer = fpd.per;
			} else {
				basePer = pd.per;
			}				
			if(currentLine.Per__c == null || currentLine.Per__c < 1) {
				currentLine.Per__c = 1;
			}
			
			currentLine.Target_Price__c = (currentLine.Base_Target__c / (basePer/currentLine.Per__c)).setScale(2);
			currentLine.Floor_Price__c = (currentLine.Base_Floor__c / (basePer/currentLine.Per__c)).setScale(2);
			currentLine.Actual_Price__c = currentLine.Target_Price__c.setScale(2);
			currentLine.Cost__c = currentLine.Base_Cost__c / (1/currentLine.Per__c);
			currentLine.Cost_See_Through__c = currentLine.Base_Cost_ST__c / (1/currentLine.Per__c);
		}
		return null;
	}
	
	public Quote_Line_Item__c queryForLine(Id filterId) {
		return [SELECT Id, Cost__c, Total_Cost__c, Cost_See_Through__c, Name, Sales_Site__c, Source_Sales_Site__c, Price_Valid_From__c, Price_Valid_To__c, Discount_Surcharge__c, Extended__c,
					   Discount_Amount__c, Material_Item__c, Material_Item__r.Name, Formula_Flag__c, Formula_Text__c, Quantity__c, Per__c, UoM__c, Material_Item__r.Material_Code__c,
					   Floor_Price__c, Target_Price__c, Actual_Price__c, Reason__c, Notify_Credit__c, Volume_Based__c, Cost_Adjustment__c, Material_Item__r.PHL1__c, Material_Item__r.PHL2__c,
					   Available_Credit_Limit__c, Credit_Limit__c, Monthly_Purchases__c, Percent__c, Substitution__c, Cost_Adjustment_Reason__c, Material_Item__r.PHL3__c,
					   Substitution_Comments__c, Description__c, Adder_Notes__c, Base_Target__c, Base_Floor__c, Base_Cost__c, Base_Cost_ST__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Id = :filterId LIMIT 1];
	}
	
	public Quote__c queryForQuote(Id filterId) {
		return [SELECT QuoteItemsBelowFlrPrice__c, Opportunity__r.OwnerId, Approval_Status__c, Product_Manager_Approval_Items__c, Version_Number__c, Include_PHL1_Approver__c, Include_PHL1_Approver_2__c, Include_PHL1_Approver_3__c, CM__c, Quote_Valid_From__c, Quote_Valid_To__c, Stored_Ebit__c, Previously_Approved__c, Id, CurrencyIsoCode, Quote_Amount__c, Country__c, Name, Price_Valid_From__c, Price_Valid_To__c, Opportunity__r.AccountId, Opportunity__r.RecordTypeId, Sales_Organization_Primary__r.Name, Sales_Organization_Primary__r.Company_Site__c, Sales_Organization_Primary__c, Volume_Produced__c, Volume_UoM__c, Calculated_Price__c, Opportunity__r.Customer_Group__c, Opportunity__r.Pricing_Region__c, Opportunity__r.Pricing_Sales_Office__c FROM Quote__c WHERE Id = :filterId LIMIT 1];
	}	
	
	public List<SelectOption> getFormulas() {
		List<SelectOption> soList = new List<SelectOption>();
		if(formulaList == null || formulaList.size() == 0) {
			soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		}

		for(Formula_Mapping__c currFm : formulaList) {
			soList.add(new SelectOption(currFm.Formula__c, currFm.Formula__r.Formula_Text__c));
		}
		selectedFormula = soList.get(0).getValue();			
		return soList;
	}
	
	public List<SelectOption> getPHL1Options() {
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		for(Product_Grouping__c currPg : [SELECT Name, Title__c FROM Product_Grouping__c order by Name asc]) {
			soList.add(new SelectOption(currPg.Name, currPg.Name + ' - ' + currPg.Title__c));
		}
		return soList;
	}
	
	public List<SelectOption> getPHL2Options(){
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		if(selectedPHL1 != '--None--') {
			for(PHL2__c currPHL : [SELECT PHL2__c, Full_PHL2__c, Description__c FROM PHL2__c WHERE PHL1__c = :selectedPHL1 order by Full_PHL2__c asc]) {
				soList.add(new SelectOption(currPHL.PHL2__c, currPHL.Full_PHL2__c + ' - ' + currPHL.Description__c));
			}
		}
		return soList;
	}
	
	public List<SelectOption> getPHL3Options() {
		List<SelectOption> soList = new List<SelectOption>();
		Map<String, String> sortedSoMap = new Map<String,String>();
		List<String> 		sortedSoList = new List<String>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		if(!currentLine.Formula_Flag__c) {
			for(PricingEngine.PricingData currPd : pricingDataList) {
				if(currPd.rule.Material_Item__r.Material_Code__c == currPd.rule.Material_Item__r.Product_Hierarchy__c) {
					if(currPd.rule.Material_Item__r.Material_Description__c == null){
						sortedSoMap.put(currPd.rule.Material_Item__r.Product_Hierarchy__c,currPd.rule.Material_Item__c);
						sortedSoList.add(currPd.rule.Material_Item__r.Product_Hierarchy__c);
					}else{
						sortedSoMap.put(currPd.rule.Material_Item__r.Product_Hierarchy__c + ' - ' + currPd.rule.Material_Item__r.Material_Description__c,currPd.rule.Material_Item__c);
						sortedSoList.add(currPd.rule.Material_Item__r.Product_Hierarchy__c + ' - ' + currPd.rule.Material_Item__r.Material_Description__c);	
					}				
				}
			}
		}
		
		if (sortedSoList.size() > 0){
			sortedSoList.sort();
			for (String productHier: sortedSoList){
				soList.add(new SelectOption(sortedSoMap.get(productHier),productHier));
			}
		}
		return soList;
	}

	public List<SelectOption> getPHL1OptionsAdvanced() {
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		for(Product_Grouping__c currPg : [SELECT Name, Title__c FROM Product_Grouping__c order by Name asc]) {
			soList.add(new SelectOption(currPg.Name, currPg.Name + ' - ' + currPg.Title__c));
		}

		return soList;
	}
	
	public List<SelectOption> getPHL2OptionsAdvanced() {
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		for(PHL2__c phl2 : [Select PHL2__c, Full_PHL2__c, Description__c From PHL2__c Where PHL1__c = :selectedPHL1Advanced order by Full_PHL2__c asc]){
			soList.add(new SelectOption(phl2.PHL2__c,phl2.Full_PHL2__c + ' -' + phl2.Description__c));
		}
		
		return soList;
	}
	
	public List<SelectOption> getPHL3OptionsAdvanced() {
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		
		if(selectedPHL2Advanced != '--None--'){
			Map<String,String> soLabelOverrides = new Map<String,String>();
			List<Material_Item__c> items = new List<Material_Item__c>();
			Set<String> phs = new Set<String>();
			if(selectedPHL1Advanced != '--None--') {
				items = [SELECT Product_Hierarchy__c, Material_Description__c FROM Material_Item__c WHERE PHL1__c = :selectedPHL1Advanced AND PHL2__c = :selectedPHL2Advanced order by PHL3__c, Product_Hierarchy__c];
			}
			
			for(Material_Item__c mi : items) {
				if(!phs.contains(mi.Product_Hierarchy__c)) {
					phs.add(mi.Product_Hierarchy__c);
					if(mi.Material_Description__c != null){
						soLabelOverrides.put(mi.Product_Hierarchy__c, mi.Product_Hierarchy__c + ' - ' + mi.Material_Description__c);
					}
				}
			}
			
			for(String currStr : phs) {
				if(!soLabelOverrides.containsKey(currStr)){
					soList.add(new SelectOption(currStr, currStr));
				}else{
					soList.add(new SelectOption(currStr, soLabelOverrides.get(currStr)));
				}	
			}
		}
		
		return soList;
	}
	
	public List<SelectOption> getMaterialCodes() {
		List<SelectOption> soList = new List<SelectOption>();
		soList.add(new SelectOption('--None--','--' + System.Label.None + '--'));
		Integer count = 0;
		if(currentLine.Formula_Flag__c) {
			for(PricingEngine.FormulaPricingData fpd : formulaicPricingDataList) {
				if(count < 999) {
					soList.add(new SelectOption(fpd.materialId,  fpd.mapping.Formula__r.Material_Item__r.Material_Description__c + ' - ' + fpd.mapping.Formula__r.Material_Item__r.Material_Code__c));
					count++;
				}
			}				
		} else {
			for(PricingEngine.PricingData currPd : pricingDataList) {
				if(currPd.rule.Material_Item__r.Material_Code__c != currPd.rule.Material_Item__r.Product_Hierarchy__c && count < 999) {
					soList.add(new SelectOption(currPd.rule.Material_Item__c,  currPd.rule.Material_Item__r.Material_Description__c + ' - ' + currPd.rule.Material_Item__r.Material_Code__c));
					count++;
				}
			}			
		}

		return soList;
	}
	
	public String digitsToWords(String convert) {
		convert = convert.replaceAll('0', System.Label.Digit_Zero);
		convert = convert.replaceAll('1', System.Label.Digit_One);
		convert = convert.replaceAll('2', System.Label.Digit_Two);
		convert = convert.replaceAll('3', System.Label.Digit_Three);
		convert = convert.replaceAll('4', System.Label.Digit_Four);
		convert = convert.replaceAll('5', System.Label.Digit_Five);
		convert = convert.replaceAll('6', System.Label.Digit_Six);
		convert = convert.replaceAll('7', System.Label.Digit_Seven);
		convert = convert.replaceAll('8', System.Label.Digit_Eight);
		convert = convert.replaceAll('9', System.Label.Digit_Nine);
		return convert;
	}
	
	public String wordsToDigits(String convert) {
		convert = convert.toLowerCase();
		convert = convert.replaceAll(System.Label.Digit_Zero, '0');
		convert = convert.replaceAll(System.Label.Digit_One, '1');
		convert = convert.replaceAll(System.Label.Digit_Two, '2');
		convert = convert.replaceAll(System.Label.Digit_Three, '3');
		convert = convert.replaceAll(System.Label.Digit_Four, '4');
		convert = convert.replaceAll(System.Label.Digit_Five, '5');
		convert = convert.replaceAll(System.Label.Digit_Six, '6');
		convert = convert.replaceAll(System.Label.Digit_Seven, '7');
		convert = convert.replaceAll(System.Label.Digit_Eight, '8');
		convert = convert.replaceAll(System.Label.Digit_Nine, '9');
		return convert;
	}
	
	public PageReference searchRecords() {
		results = new List<Material_Cost__c>();
		String nameToUse1 = '', nameToUse2 = '', nameToUse3 = '';
		areResults = false;
		
		if(searchDescription == null) {
			searchDescription = '';
		}
		if (searchCode == null){
			searchCode = '';
		}

		if(selectedPHL1Advanced == null || selectedPHL1Advanced == '') {
			selectedPHL1Advanced = '--None--';
		}
		if(selectedPHL3Advanced == null || selectedPHL3Advanced == '') {
			selectedPHL3Advanced = '--None--';
		}

		if(sourceSalesSite == null || sourceSalesSite == '') {
			sourceSalesSite = '--None--';
		}		
		
		if(dummyOpp.AccountId != null || searchPreferred || searchCode != '' || 
		                                  sourceSalesSite != '--None--'  || searchDescription != '' || selectedPHL3Advanced != '--None--' ||
		                                  selectedPHL1Advanced != '--None--') {
			
			//Search for results
			String query = 'SELECT Sales_Site__c, Sales_Site__r.Name, Material_Item__c, Cost__c, Material_Item__r.Id, Material_Item__r.Name, Material_Item__r.Material_Code__c, ' +
						   'Material_Item__r.Product_Hierarchy__c, Material_Item__r.Material_Description__c, Material_Item__r.Material_Category__c, Material_Item__r.PHL1__c, Material_Item__r.PHL2__c, Material_Item__r.PHL3__c FROM Material_Cost__c WHERE';
			
			Integer queryCount = 0;
			
			if(searchDescription != null && searchDescription != '') {				
			//Transform the strings digits to words and words to digits
			    nameToUse1 = '%' + searchDescription + '%';
				nameToUse2 = '%' + digitsToWords(searchDescription) + '%';
				nameToUse3 = '%' + wordsToDigits(searchDescription) + '%';				
				query += ' (Material_Item__r.Material_Description__c like \'' + nameToUse1 + '\' OR';
				query += ' Material_Item__r.Material_Description__c like \'' + nameToUse2 + '\' OR';
				query += ' Material_Item__r.Material_Description__c like \'' + nameToUse3 + '\')';
				queryCount++;
			}

			if(selectedPHL3Advanced != '--None--') {
				if(queryCount > 0) {
					query += ' AND';
				}
				query += ' (Material_Item__r.Product_Hierarchy__c = \'' + selectedPHL3Advanced +'\')';
				queryCount++;
			}
			
			if(selectedPHL1Advanced != '--None--') {
				if(queryCount > 0) {
					query += ' AND';
				}
				query += ' (Material_Item__r.PHL1__c = \'' + selectedPHL1Advanced +'\')';
				queryCount++;
			}
			
			if(searchCode != '' && searchCode != null) {
				if(queryCount > 0) {
					query += ' AND';
				}
				query += ' (Material_Item__r.Material_Code__c like \'%' + searchCode +'%\')';
				queryCount++;
			}
			
			/*
			if(dummyCost.Inventory_Level__c != null) {
				if(queryCount > 0) {
					query += ' AND';
				}
				
				query += ' (Inventory_Level__c = \'' + dummyCost.Inventory_Level__c +'\')';
				queryCount++;
			}*/
			
			if(sourceSalesSite != '--None--') {
				if(queryCount > 0) {
					query += ' AND';
				}
				query += ' (Sales_Site__c = \'' + sourceSalesSite + '\')';
				queryCount++;
			}		
			
			if(searchPreferred) {
				if(queryCount > 0) {
					query += ' AND';
				}
				query += ' Material_Item__r.Preferred__c = true';
				queryCount++;
			}
			
			Boolean accountInterrupt = false;
			if(dummyOpp.AccountId != null) {
		 		try {
					Boolean flagForDel = [SELECT Flag_for_Deletion__c FROM Account WHERE Id = :dummyOpp.AccountId LIMIT 1].Flag_for_Deletion__c;
				} catch(Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
					return null;
		 		}
				List<Quote_Line_Item__c> qliList = [SELECT Material_Item__c FROM Quote_Line_Item__c WHERE Quote__r.Opportunity__r.AccountId = :dummyOpp.AccountId];
				List<Quote_Line_Item__c> useableQli = new List<Quote_Line_Item__c>();
				for(Quote_Line_Item__c currQli : qliList) {
					if(currQli.Material_Item__c != null) {
						useableQli.add(currQli);
					}
				}
				if(useableQli.size() > 0) {
					if(queryCount > 0) {
						query += ' AND';
					}							
					query += ' (';
				} else {
					accountInterrupt = true;
				}
				for(Quote_Line_Item__c currQli : useableQli) {
					query += ' Material_Item__c = \'' + currQli.Material_Item__c + '\' OR';
					queryCount++;
				}
				if(useableQli.size() > 0) {
					query = query.substring(0, query.length()-3);
					query += ')';
				}				
			}
			
			if(queryCount > 0) {
				query += ' AND';
			}
						
			query += ' Sales_Site__r.Company_Site__c = \'' + scenario.Sales_Organization_Primary__r.Company_Site__c + '\'';
			System.debug('QUERY = ' + query);
			if(query.substring(query.length()-5, query.length()) != 'WHERE' && !accountInterrupt) { 
				try {
					results = Database.query(query + ' LIMIT 500');
				} catch(Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));	
				}
				if(results.size() > 499) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_Too_Many_Results));	
				}
			}
			
			//If there are results flag areResults as true
			if(results.size() > 0) {
				areResults = true;
			}
		}
		return null;
	}

	public List<SelectOption> getCustomerSites() {
		List<SelectOption> soList = new List<SelectOption>();
		List<Customer_Sales_Site__c> cssList = new List<Customer_Sales_Site__c>();
		
		if(scenario.Opportunity__r.AccountId != null) {
			cssList = [SELECT Id, CurrencyIsoCode, Sales_Site__r.Region_Site__c, Pricelist__c, INCO__c, Delivery_Sales_Site__c, Service_Type__c, Drilled_By__c, Customer_Group__c, Sales_Site__r.Name, Sales_Site__r.Company_Site__r.Name, Sales_Site__c FROM Customer_Sales_Site__c WHERE Customer__c = :scenario.Opportunity__r.AccountId];
			String companyCodes = [SELECT Company_Codes__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Company_Codes__c;
			for(Customer_Sales_Site__c currCSS : cssList) {
				if(currCSS.Sales_Site__r.Region_Site__c != null && currCSS.Sales_Site__r.Company_Site__c != null && companyCodes.indexOf(currCSS.Sales_Site__r.Company_Site__r.Name) != -1) {
					soList.add(new SelectOption(currCSS.Sales_Site__c, currCSS.Sales_Site__r.Name));
				}
			}
		}
	
		sourceSalesSite = '--None--';
		if(soList.size() > 0) {
			soList.add(0, new SelectOption(sourceSalesSite, '--' + System.Label.None + '--'));
		} else {
			soList.add(new SelectOption(sourceSalesSite, '--' + System.Label.None + '--'));
		}
		
		return soList;
	}
	
	public PageReference displayPopup() {
		showPopup = !showPopup;
		return null;
	}
	
	public PageReference performCancel() {
		return new PageReference('/apex/SLIQuickAdd?id=' + scenario.Id);
	}

	private Boolean validateRecord() {	
		String currentVal;
		/* Fields which are always required */
		for(String req : requiredFields) {
			if(currentLine.get(req) == null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, qliFields.get(req).getDescribe().getLabel() + ' ' + System.Label.QGP_Required));
				return false;				
			}
			currentVal = (''+currentLine.get(req)).trim();
			if(currentVal == '') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, req + ' ' + System.Label.QGP_Required));
				return false;
			}
		}
	    
		/* Fields which are conditionally required */
		if(currentLine.Discount_Surcharge__c && currentLine.Discount_Amount__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Discount_Surcharge_Terms__c.label + ' ' + System.Label.QGP_Required));
			return false;				
		} else if(currentLine.UoM__c == null || currentLine.UoM__c == '--None--' || currentLine.UoM__c.trim() == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.UoM__c.label + ' ' + System.Label.QGP_Required));
			return false;
		} else if(currentLine.Material_Item__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Material_Item__c.label + ' ' + System.Label.QGP_Required));
			return false;				
		} else if(!currentLine.Formula_Flag__c && currentLine.Floor_Price__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Floor_Price__c.label + ' ' + System.Label.QGP_Required));
			return false;
		} else if(currentLine.Formula_Flag__c && selectedFormula == '--None--') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Formula__c.label + ' ' + System.Label.QGP_Required));
			return false;							
		} else if(!currentLine.Formula_Flag__c && currentLine.Target_Price__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Target_Price__c.label + ' ' + System.Label.QGP_Required));
			return false;				
		} else if(currentLine.Actual_Price__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Actual_Price__c.label + ' ' + System.Label.QGP_Required));
			return false;				
		} else if(currentLine.Actual_Price__c == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_Price_Not_0));
			return false;				
		} else if(currentLine.Quantity__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Quantity__c.label + ' ' + System.Label.QGP_Required));
			return false;				
		} else if(currentLine.Per__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Schema.SObjectType.Quote_Line_Item__c.fields.Per__c.label + ' ' + System.Label.QGP_Required));
			return false;				
		} else if(currentLine.Quantity__c < 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_Qty_Greater_0));
			return false;
		} else if(currentLine.Cost_Adjustment__c != 0 && (currentLine.Cost_Adjustment_Reason__c == null || currentLine.Cost_Adjustment_Reason__c.trim() == '')) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_Cost_Adj + ' ' + System.Label.QGP_Required));
			return false;			
		} else {
			for(Quote_Line_Item__c currQli : [SELECT Id, Material_Item__c FROM Quote_Line_Item__c WHERE Quote__c = :scenario.Id]) {
				if(currQli.Material_Item__c == currentLine.Material_Item__c && currQli.Id != currentLine.Id) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Advanced_Add_SLI_exists));
					return false;					
				}
			}
		}
		
		return true;
	}
	
	public PageReference performSave() {
		currentLine.Country__c = scenario.Country__c;
		currentLine.CurrencyIsoCode = scenario.CurrencyIsoCode;
				
		if(currentLine.Cost_Adjustment__c == null) {
			currentLine.Cost_Adjustment__c = 0;
		}
		if(currentLine.Cost__c == null) {
			currentLine.Cost__c = 0;
		}
		if(currentLine.Cost_See_Through__c == null) {
			currentLine.Cost_See_Through__c = 0;
		}		
		if(validateRecord()) {
			if(selectedFormula != '--None--' && currentLine.Formula_Flag__c) {
				currentLine.Formula__c = selectedFormula;
			}	
			currentLine.Extended__c = currentLine.Sales_Site__c == scenario.Sales_Organization_Primary__c;
			upsert currentLine;	
			scenario = queryForQuote(scenario.Id);
			PandLData data = PandLData.getTAIC(scenario.Id);
			scenario.Stored_Ebit__c = data.ebit.value;
			update scenario;			
			calculatePreviouslyApproved();
			return performCancel();
		}
		return null;
	}
	
	private void calculatePreviouslyApproved() {
		scenario.Previously_Approved__c = determinePreviouslyApproved();
		if(scenario.QuoteItemsBelowFlrPrice__c > 250) {
	   		scenario.Product_Manager_Approval_Items__c = System.Label.Approval_Error;	  
		} 
		
		update scenario;
	}	

	private Boolean determinePreviouslyApprovedHelper() {
		String msg1 = '', msg2 = '', msg3 = '';
		/*
		String miName = Schema.SObjectType.Material_Item__c.fields.Name.label, aPrice = Schema.SObjectType.Quote_Line_Item__c.fields.Actual_Price__c.label,
		       perName = Schema.SObjectType.Quote_Line_Item__c.fields.Per__c.label, uomName = Schema.SObjectType.Quote_Line_Item__c.fields.UoM__c.label,
		       totalPName = Schema.SObjectType.Quote_Line_Item__c.fields.Total_Price__c.label, floorPName = Schema.SObjectType.Quote_Line_Item__c.fields.Floor_Price__c.label,
		       targetPName = Schema.SObjectType.Quote_Line_Item__c.fields.Target_Price__c.label;
		*/
		String miName = 'Material Item', aPrice = 'Actual Price', perName = 'Per', uomName = 'UoM', totalPName = 'Total Price', floorPName = 'Floor Price', targetPName = 'Target Price';				
		Boolean found1 = false, found2 = false, found3 = false;		
		for(Quote_Line_Item__c currQLI : [SELECT Id, Material_Item__r.PHL1__c, Material_Item__c, Actual_Price__c, Floor_Price__c, Material_Item__r.Name, Per__c, UoM__c, Total_Price__c, Target_Price__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :scenario.Id]) {
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
		if(msg1 != '') {
			msg1 = currentUser.Product_Manager__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg1 + '<br />';
		}
		if(msg2 != '') {
			msg2 = currentUser.Product_Manager_2__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg2 + '<br />';
		}
		if(msg3 != '') {
			msg3 = currentUser.Product_Manager_3__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg3 + '<br />';
		}		
		scenario.Product_Manager_Approval_Items__c = msg1 + msg2 + msg3;	
		scenario.Include_PHL1_Approver__c = found1;
		scenario.Include_PHL1_Approver_2__c = found2;
		scenario.Include_PHL1_Approver_3__c = found3;	
		
		return scenario.Approval_Status__c == 'Approved';			
	}
	
	private Boolean determinePreviouslyApproved() {
		Integer versionNumber = Integer.valueOf(scenario.Version_Number__c);
		Boolean found1 = false, found2 = false, found3 = false;
		String msg1 = '', msg2 = '', msg3 = '';
		if(scenario.Approval_Status__c == 'Approved') {
			return true;
		}		
		if(versionNumber > 1) {
			/*
			String miName = Schema.SObjectType.Material_Item__c.fields.Name.label, aPrice = Schema.SObjectType.Quote_Line_Item__c.fields.Actual_Price__c.label,
			       perName = Schema.SObjectType.Quote_Line_Item__c.fields.Per__c.label, uomName = Schema.SObjectType.Quote_Line_Item__c.fields.UoM__c.label,
			       totalPName = Schema.SObjectType.Quote_Line_Item__c.fields.Total_Price__c.label, floorPName = Schema.SObjectType.Quote_Line_Item__c.fields.Floor_Price__c.label,
			       targetPName = Schema.SObjectType.Quote_Line_Item__c.fields.Target_Price__c.label;
			*/
			String miName = 'Material Item', aPrice = 'Actual Price', perName = 'Per', uomName = 'UoM', totalPName = 'Total Price', floorPName = 'Floor Price', targetPName = 'Target Price';						
			String vStr = (versionNumber - 1).format();
			List<Quote__c> previousQuotes = [SELECT Id, Previously_Approved__c, Quote_Amount__c FROM Quote__c WHERE Version_Number__c = :vStr AND Opportunity__c = :scenario.Opportunity__c];
			if(previousQuotes.size() > 0 && previousQuotes.get(0).Previously_Approved__c) {
				List<Quote_Line_Item__c> sliList = [SELECT Id, Material_Item__c, Actual_Price__c, Floor_Price__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :previousQuotes.get(0).Id];
				Set<Id> belowFloorIds = new Set<Id>();
				for(Quote_Line_Item__c currQLI : sliList) {
					if(currQLI.Actual_Price__c < currQLI.Floor_Price__c) {
						belowFloorIds.add(currQLI.Material_Item__c);
					}
				}
				
				Boolean previouslyApproved = true;
				for(Quote_Line_Item__c currQLI : [SELECT Id, Material_Item__r.PHL1__c, Material_Item__c, Actual_Price__c, Floor_Price__c, Material_Item__r.Name, Per__c, UoM__c, Total_Price__c, Target_Price__c, Lock_Expiration_Date__c FROM Quote_Line_Item__c WHERE Quote__c = :scenario.Id]) {
					if(currQLI.Actual_Price__c < currQLI.Floor_Price__c && !belowFloorIds.contains(currQLI.Material_Item__c)) {
						previouslyApproved = false;
						
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
				
				if(msg1 != '') {
					msg1 = currentUser.Product_Manager__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg1 + '<br />';
				}
				if(msg2 != '') {
					msg2 = currentUser.Product_Manager_2__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg2 + '<br />';
				}
				if(msg3 != '') {
					msg3 = currentUser.Product_Manager_3__r.Name + ' ' + System.Label.Approval_Please_Provide + '<br />' + msg3 + '<br />';
				}					
				
				scenario.Product_Manager_Approval_Items__c = msg1 + msg2 + msg3;
				scenario.Include_PHL1_Approver__c = found1;
				scenario.Include_PHL1_Approver_2__c = found2;
				scenario.Include_PHL1_Approver_3__c = found3;						
				
				if( belowFloorIds.size() == 0 && previousQuotes.get(0).Quote_Amount__c  < 3000000 && scenario.Approval_Status__c == 'Approved') {
					return true;
				} else { //...if there are items below floor on the previous version or this isnt approved use the previouslyApproved value
					if(scenario.Quote_Amount__c >= 3000000) {
						scenario.Include_3_Million__c = previousQuotes.get(0).Quote_Amount__c  >= 3000000;
						return previouslyApproved && scenario.Include_3_Million__c;
					} else {
						return previouslyApproved;
					}
				} 				
				
				/* ORIGINAL
				if(belowFloorIds.size() == 0 && scenario.Approval_Status__c == 'Approved') {
					return true;
				} else {
					return previouslyApproved;
				}*/
			} else if(previousQuotes.size() > 0 && !previousQuotes.get(0).Previously_Approved__c) {
				return determinePreviouslyApprovedHelper();
			}
		} else {
			return determinePreviouslyApprovedHelper();		
		}
		return false;
	}	
	
}