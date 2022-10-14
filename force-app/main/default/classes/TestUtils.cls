public with sharing class TestUtils {

	public static User createUserNoInsert(String companyCodes) {
		User u2 = [SELECT Id FROM User LIMIT 1];
		
		User u = new User();
		u.FirstName = 'Test';
		u.LastName = 'U\'Ser';
		u.Alias = 'tuser';
		u.Email = 'tu@tus.com';
		u.Username = 'tu@tus.com';
		u.CommunityNickname = 'tuser';
		u.TimeZoneSidKey = 'America/Chicago';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		u.LanguageLocaleKey = 'en_US';
		u.Company_Codes__c = companyCodes;
		u.State = 'UT';
		u.PostalCode = '84121';
		return u;		
	}

	public static Customer_Sales_Site__c createCSS(Id customerId, Id salesSiteId) {
		Customer_Sales_Site__c toRet = new Customer_Sales_Site__c();
		toRet.Customer__c = customerId;
		toRet.Sales_Site__c = salesSiteId;
		toRet.Customer_Group__c = '02 Retail';
		insert toRet;
		return toRet;
	}

	public static Product_Grouping__c createProductGrouping(String name, String description, String pLine) {
		Product_Grouping__c pg = new Product_Grouping__c();
		pg.Name = name;
		pg.Description__c = description;
		pg.Product_Line__c = pLine;
		insert pg;
		return pg;
	}
	
	public static Copa__c createCopa(Account customer, Sales_Site__c site, Double dHrs, Double ssHrs, Double revenue, Double mileage, Double units, Double invoices, Date currentMonth) {
		Copa__c cpa = new Copa__c();
		cpa.Customer__c = customer.Id;
		cpa.Sales_Site__c = site.Id;
		cpa.DELHRS__c = dHrs;
		cpa.MILES__c = mileage;
		cpa.INVOICES__c = invoices;
		cpa.SHOTHRS__c = ssHrs;
		cpa.LBS__c = units;
		cpa.Net_Revenue__c = revenue;
		cpa.Current_Month__c = currentMonth;
		
		return cpa;
	}
	
	public static Copa__c createCopa(Account customer, Sales_Site__c site, Double dHrs, Double ssHrs, Double revenue, Double mileage, Double units, Double invoices, Date currentMonth, Material_Item__c theMaterial) {
		Copa__c cpa = new Copa__c();
		cpa.Customer__c = customer.Id;
		cpa.Sales_Site__c = site.Id;
		cpa.DELHRS__c = dHrs;
		cpa.MILES__c = mileage;
		cpa.INVOICES__c = invoices;
		cpa.SHOTHRS__c = ssHrs;
		cpa.LBS__c = units;
		cpa.Net_Revenue__c = revenue;
		cpa.Current_Month__c = currentMonth;
		cpa.Material_Item__c = theMaterial.Id;
		
		return cpa;
	}	
	
	public static Cost_Driver_Entry__c createCDE(Account customer, Sales_Site__c site, Double dHrs, Double ssHrs, Double revenue, Double mileage, Double units, Double invoices, Date currentMonth) {
		Cost_Driver_Entry__c cde = new Cost_Driver_Entry__c();
		cde.Account__c = customer.Id;
		cde.Sales_Site__c = site.Id;
		cde.DELHRS__c = dHrs;
		cde.DISTANCE__c = mileage;
		cde.INVOICES__c = invoices;
		cde.SHOTHRS__c = ssHrs;
		cde.UNITS__c = units;
		cde.REVENUE__c = revenue;
		cde.Current_Month__c = currentMonth;
		insert cde;
		return cde;
	}
	
	
	public static PCA__c createPCA(Sales_Site__c site, Date postMonth, Double invoices, Double mhrs, Double mileage, Double units, Double revExp, Double tHrs) {
		PCA__c pca = new PCA__c();
		pca.Sales_Site__c = site.Id;
		pca.Post_Month__c = postMonth;
		pca.Invoice__c = invoices;
		pca.Mhrs__c = mhrs;
		pca.Miles__c = mileage;
		pca.Pounds__c = units;
		pca.Rev_Exp__c = revExp;
		pca.Total_Hrs__c = tHrs;
		insert pca;
		return pca;
	}
	
	public static Pricing_Rule__c createPricingRule(Sales_Site__c orgSite, Sales_Site__c recSite, Material_Item__c matItem, Double fPrice, Double tPrice) {
        Pricing_Rule__c testPr = new Pricing_Rule__c();
        //testPr.Origin_Sales_Site__c = orgSite.Id;
        testPr.Receiving_Sales_Site__c = recSite.Id;
        testPr.Material_Item__c = matItem.Id;
        testPr.Price_Valid_From__c = System.TODAY();
        testPr.Price_Valid_To__c = System.TODAY();
        testPr.Floor_Price__c = fPrice;
        testPr.Target_Price__c = tPrice;
        testPr.Per__c=1.0;
        testPr.UoM__c='LB';
        insert testPr;		
        return testPr;
	} 

	public static Material_Item__c createMaterialItem(String name, String materialCode, String prodHierarchy) {
		Material_Item__c matItem = new Material_Item__c();
		matItem.Name = name;
		matItem.Material_Code__c = materialCode;
		matItem.Product_Hierarchy__c = prodHierarchy;
		if (name.contains('vol')){
			matItem.Volumetric_Parent__c = true;
		}
		insert matItem;
		return matItem;
	}
	public static Material_Item__c createMaterialItem(String name, String materialCode, String prodHierarchy, Id plantId) {
		Material_Item__c matItem = new Material_Item__c();
		matItem.Name = name;
		matItem.Material_Code__c = materialCode;
		matItem.Product_Hierarchy__c = prodHierarchy;
		/*
		if(plantId != null) {
			matItem.Sales_Site__c = plantId;
		}
		*/
		insert matItem;
		return matItem;
	}
	
	public static Quote_Line_Item__c createQli(Material_Item__c matItem, Double price, String roundingMethod, Quote__c theQuote, Double quant) {
		Quote_Line_Item__c qli = new Quote_Line_Item__c();
		qli.Actual_Price__c = price;
		qli.Country__c = 'USA';
		qli.Rounding_Method__c = roundingMethod;
		qli.Per__c = 1;
		qli.UoM__c = 'LB';
		qli.Price_Valid_From__c = System.today();
		qli.Price_Valid_To__c = System.today().addDays(30);
		qli.Quote__c = theQuote.Id;
		if(matItem != null) {
			qli.Material_Item__c = matItem.Id;
		}
		qli.Quantity__c = quant;
		insert qli;
		return qli;
	}
	
	public static Quote_Line_Item__c createQli(Material_Item__c matItem, Double price, String roundingMethod, Quote__c theQuote, Double quant, Sales_Site__c pl) {
		Quote_Line_Item__c qli = new Quote_Line_Item__c();
		qli.Actual_Price__c = price;
		qli.Country__c = 'USA';
		qli.Rounding_Method__c = roundingMethod;
		qli.Per__c = 1;
		qli.UoM__c = 'LB';
		qli.Price_Valid_From__c = System.today();
		qli.Price_Valid_To__c = System.today().addDays(30);
		qli.Quote__c = theQuote.Id;
		qli.Sales_Site__c = pl.Id;
		qli.Source_Sales_Site__c = pl.Id;
		if(matItem != null) {
			qli.Material_Item__c = matItem.Id;
		}
		qli.Quantity__c = quant;
		insert qli;
		return qli;
	}	

	public static Quote__c createQuote(Opportunity theOpp, Id siteId) {
		Quote__c theQuote = new Quote__c();
		theQuote.currencyIsoCode = 'USD';
		theQuote.Active_Quote__c = true;
		theQuote.Price_Valid_From__c = System.today();
		theQuote.Price_Valid_To__c = System.today().addDays(30);
		theQuote.Quote_Valid_From__c = System.today();
		theQuote.Quote_Valid_To__c = System.today().addDays(30);
		theQuote.Opportunity__c = theOpp.Id;
		theQuote.Version_Number__c = '1';
		theQuote.Customer__c = theOpp.AccountId;
		theQuote.Sales_Organization_Primary__c = siteId;
		theQuote.Volume_UoM__c = 'EA';
		theQuote.Bench_Height__c = 10;
		theQuote.Burden__c = 10;
		theQuote.Spacing__c = 10;	
		
		
		Opportunity theOpportunityCheck = [SELECT Id, Name FROM Opportunity WHERE Id =: theOpp.Id LIMIT 1];
		IF(theOpportunityCheck.Name.contains('V-')){
			Material_Item__c testItem = TestUtils.createMaterialItem('vol' +theOpp.Name, 'VMI02' + theOpp.Name, 'PL0000000000000000');
			testItem.Base_Unit_of_Measue__c = 'EA';
			update testItem;
			theQuote.Volumetric_Parent_Product__c = testItem.Id;
		}		
		insert theQuote;
		return theQuote;
	}	
	
	public static Alternate_Unit_of_Measure__c createAUM(Id materialId, String aun, String bun, Integer x, Integer y) {
		Alternate_Unit_of_Measure__c aum = new Alternate_Unit_of_Measure__c();
		aum.AUn__c = aun;
		aum.BUn__c = bun;
		aum.X__c = x;
		aum.Y__c = y;
		aum.Material_Item__c = materialId;
		insert aum;
		return aum;
	}
	
	public static Formula_Mapping__c createFormulaMapping(Id formulaId, Id customerId, Id salesSiteId, Id sourceSalesSiteId, Integer per, String uom) {
		Formula_Mapping__c fm = new Formula_Mapping__c();
		fm.Formula__c = formulaId;
		fm.Customer__c = customerId;
		fm.Sales_Site__c = salesSiteId;
		fm.Source_Sales_Site__c = sourceSalesSiteId;
		fm.Per__c = per;
		fm.UoM__c = uom;
		insert fm;
		return fm;
	}
	
	
	public static Formula__c createFormula(String name, Id materialId, Double gas, Double nh3) {
		Formula__c f = new Formula__c();
		f.Name = name;
		f.Material_Item__c = materialId;
		f.Gas__c = gas;
		f.NH3__c = nh3;
		insert f;
		return f;
	}
	
	public static Formula_Component__c createFormulaComponent(String name, String aGroup, Decimal value) {
		Formula_Component__c fc = new Formula_Component__c();
		fc.Name = name;
		fc.Group__c = aGroup;
		fc.Value__c = value;
		insert fc;
		return fc;
	}
	
	public static Formula_Line_Item__c createFormulaLineItem(Id formulaId, Id formulaComponentId) {
		Formula_Line_Item__c fli = new Formula_Line_Item__c();
		fli.Formula__c = formulaId;
		fli.Formula_Component__c = formulaComponentId;
		insert fli;
		return fli;
	}

	public static Quote__c createQuote(Opportunity theOpp) {
		Quote__c theQuote = new Quote__c();
		theQuote.currencyIsoCode = 'USD';
		theQuote.Active_Quote__c = true;
		theQuote.Price_Valid_From__c = System.today();
		theQuote.Price_Valid_To__c = System.today().addDays(30);
		theQuote.Quote_Valid_From__c = System.today();
		theQuote.Quote_Valid_To__c = System.today().addDays(30);
		theQuote.Opportunity__c = theOpp.Id;
		theQuote.Version_Number__c = '1';
		theQuote.Volume_UoM__c = 'Cubic Yd';
		theQuote.Bench_Height__c = 10;
		theQuote.Burden__c = 10;
		theQuote.Spacing__c = 10;
		theQuote.Customer_Group__c = theOpp.Customer_Group__c;
		Sales_Site__c company = TestUtils.createSalesSite('COMP', null, null);
		Sales_Site__c region = TestUtils.createSalesSite('REG', company.Id, null);
		Sales_Site__c site = TestUtils.createSalesSite('SITE', company.Id, region.Id);
		theQuote.Customer__c = theOpp.AccountId;
		theQuote.Sales_Organization_Primary__c = site.Id;
		insert theQuote;
		return theQuote;
	}
	
	public static Account createAccount(String name, Id parentAcct) {
		Account acct = new Account();
		acct.Name = name;
		acct.ShippingState = 'UT';
        acct.ShippingCountry = 'US';
		acct.ShippingPostalCode = '84121';
		if(parentAcct != null) {
			acct.ParentId = parentAcct;
		}
		insert acct;
		return acct;
	}
    
	public static Contact createContact(String firstName, String lastName, Id parentAcct) {
		Contact cont = new Contact();
		cont.FirstName = firstName;
        cont.LastName = lastName;
		if(parentAcct != null) {
			cont.AccountId = parentAcct;
		}
		insert cont;
		return cont;
	}    
	
	public static Account createAccount(String name, Id parentAcct, String sapNum) {
		Account acct = new Account();
		acct.Name = name;
		acct.ShippingState = 'UT';
        acct.ShippingCountry = 'US';
		acct.ShippingPostalCode = '84121';
		acct.SAP_Account_Number__c = sapNum;
		if(parentAcct != null) {
			acct.ParentId = parentAcct;
		}
		insert acct;
		return acct;
	}	
	
	public static Sales_Site__c createPlant(String name) {
		Sales_Site__c pl = new Sales_Site__c();
		pl.Name = name;
		insert pl;
		return pl;
	}
	
	public static Opportunity createOppty(String name, Id acctId, String stage) {
		Opportunity opp = new Opportunity();
		//opp.Name = name;
		opp.StageName = stage;
        opp.Opportunity_Owner_Contact__c ='003a000002LhWKbAAN';
		opp.CloseDate = System.today();
		if(acctId != null) {
			opp.AccountId = acctId;
		}
		insert opp;
		return opp;
	}
	
	public static Opportunity createOppty(String name, Id acctId, String stage, Id rtId) {
		Opportunity opp = new Opportunity();
		//opp.Name = name;
		opp.StageName = stage;
        opp.Opportunity_Owner_Contact__c ='003a000002LhWKbAAN';
		opp.CloseDate = System.today();
		if(acctId != null) {
			opp.AccountId = acctId;
		}
		if(rtId != null) {
			opp.RecordTypeId = rtId;
		}
		insert opp;
		return opp;
	}	

	public static Opportunity createOppty(String name, Id acctId, String stage, Customer_Sales_Site__c css) {
		Opportunity opp = new Opportunity();
		//opp.Name = name;
		opp.StageName = stage;
        opp.Opportunity_Owner_Contact__c ='003a000002LhWKbAAN';
		opp.CloseDate = System.today();
		if(acctId != null) {
			opp.AccountId = acctId;
		}
		opp.Customer_Sales_Site__c = css.Id;
		insert opp;
		return opp;
	}
	
	//Creates an Opportunity with an Account Reference - AM 5/21
	public static Opportunity createOppty(String name, Id acctId, String stage, Id rtId, Id AccountId) {
		Opportunity opp = new Opportunity();
		//opp.Name = name;
		opp.StageName = stage;
        opp.Opportunity_Owner_Contact__c ='003a000002LhWKbAAN';
		opp.CloseDate = System.today();
		if(acctId != null) {
			opp.AccountId = acctId;
		}
		if(rtId != null) {
			opp.RecordTypeId = rtId;
		}
		insert opp;
		return opp;
	}	
	
	public static Opportunity createOppty(String name, Id acctId, String stage, Id rtId, Sales_Site__c site) {
		Opportunity opp = new Opportunity();
		//opp.Name = name;
		opp.StageName = stage;
        opp.Opportunity_Owner_Contact__c ='003a000002LhWKbAAN';
		opp.CloseDate = System.today();
		opp.Sales_Site__c = site.Id;
		if(acctId != null) {
			opp.AccountId = acctId;
		}
		if(rtId != null) {
			opp.RecordTypeId = rtId;
		}
		insert opp;
		return opp;
	}	
	
	public static Material_Cost__c createMaterialCost(Material_Item__c mi, Sales_Site__c pl, Double cost, String invLevel) {
		Material_Cost__c mc = new Material_Cost__c();
		mc.Cost__c = cost;
		if(mi != null) {
			mc.Material_Item__c = mi.Id;
		}
		mc.Sales_Site__c = pl.Id;
		mc.BUn__c = 'LB';
		insert mc;
		return mc;
	}

	public static Material_Item__c createItemWitCost(Sales_Site__c site) {
		Material_Item__c item = TestUtils.createMaterialItem('Test', 'A1234'+String.valueOf(System.now().getTime()), '', null);
		Material_Cost__c cost = TestUtils.createMaterialCost(item, site, 12.34d, 'normal');
		cost.BUn__c = 'LB';
		update cost;
		
		return item;
	}
	
	public static Material_Item__c createItemWitCost(Sales_Site__c site, Double cost) {
		Material_Item__c item = TestUtils.createMaterialItem('Test', 'A1234'+String.valueOf(System.now().getTime()), '', null);
		Material_Cost__c cst = TestUtils.createMaterialCost(item, site, cost, 'normal');
		cst.BUn__c = 'LB';
		update cst;
		
		return item;
	}
	
	public static Sales_Site__c createSalesSite(String name, Id companySiteId, Id regionSiteId) {
		Sales_Site__c site = new Sales_Site__c(Name=name, Company_Site__c=companySiteId, Region_Site__c = regionSiteId);
		insert site;
		return site;
	}
	
	public static List<Sales_Site__c> createSalesSiteHierarchy(String companyName, String regionName, String siteName) {
		List<Sales_Site__c> sites = new List<Sales_Site__c>();
		sites.add(createSalesSite(companyName, null,null));
		sites.add(createSalesSite(regionName, sites[0].Id,null));
		sites.add(createSalesSite(siteName, sites[0].Id, sites[1].Id));
		
		return sites;
	}

	public static Pricing_Rule__c createPricingRule(Id salesSiteId, Id customerId, Id regionId, Id companyId, Boolean isRetail, Id materialId, Decimal per, String uom, Decimal floorPrice, Decimal targetPrice, Date validFrom, Date validTo) {
		Pricing_Rule__c testPr = new Pricing_Rule__c();
		testPr.Material_Item__c = materialId;
		testPr.Receiving_Sales_Site__c = salesSiteId;
		testPr.Region_Site__c = regionId;
		testPr.Account__c = customerId;
		testPr.Company_Code__c = companyId;
		testPr.Customer_Group__c = (isRetail)?'02 Retail':'01 Wholesale';
		testPr.Price_Valid_From__c = validFrom;
		testPr.Price_Valid_To__c = validTo;
		testPr.Per__c=per;
		testPr.UoM__c=uom;
		testPr.Floor_Price__c=floorPrice;
		testPr.Target_Price__c=targetPrice;
		insert testPr;
		return testPr;
	}

	public static Pricing_Rule__c createPricingRule(Id salesSiteId, Id customerId, Id regionId, Boolean isRetail, Id materialId, Decimal per, String uom, Decimal floorPrice, Decimal targetPrice, Date validFrom, Date validTo) {
		Pricing_Rule__c testPr = new Pricing_Rule__c();
		testPr.Material_Item__c = materialId;
		testPr.Receiving_Sales_Site__c = salesSiteId;
		testPr.Region_Site__c = regionId;
		testPr.Account__c = customerId;
		testPr.Customer_Group__c = (isRetail)?'02 Retail':'01 Wholesale';
		testPr.Price_Valid_From__c = validFrom;
		testPr.Price_Valid_To__c = validTo;
		testPr.Per__c=per;
		testPr.UoM__c=uom;
		testPr.Floor_Price__c=floorPrice;
		testPr.Target_Price__c=targetPrice;
		insert testPr;
		return testPr;
	}
	
	public static Bundled_Service__c createBundledServiceMapping(Id materialId, String service, String holeSize) {
		Bundled_Service__c svc = new Bundled_Service__c(Material_Item__c=materialId, RecordTypeId=[Select Id from RecordType where SObjectType='Bundled_Service__c' and DeveloperName=:service].Id, Hole_Size__c=holeSize);
		insert svc;
		return svc;
	}
}