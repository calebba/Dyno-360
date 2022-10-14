public with sharing class RatioAnalysisController {
	
	public Opportunity dummyOpp {get; set;}
	public Quote__c dummyQuote {get; set;}
	public Account currAccount {get; set;}
	public Sales_Site__c currSite {get; set;}
	public Datetime startDate {get; set;}
	public Datetime endDate {get; set;}
	
	public String fancyStartDate {get; set;}
	public String fancyEndDate {get; set;}
	public String fancyRevenue {get; set;}
	public String fancyEBIT {get; set;}
	public String fancyInvoices {get; set;}
	public String fancyHours {get; set;}
	public String fancyMileage {get; set;}
	public String fancyUnits {get; set;}
	
	public String fancyInvoicesSo {get; set;}
	public String fancyHoursSo {get; set;}
	public String fancyMileageSo {get; set;}
	public String fancyUnitsSo {get; set;}
	
	public Decimal ebitap {get; set;}
	public Decimal gmp {get; set;}
	public Decimal cmp {get; set;}
	
	public Decimal netRevenue {get; set;}
	public Decimal ebita {get; set;}
	public Decimal gm {get; set;}
	public Decimal gmst {get; set;}
	public Decimal cm {get; set;}
	public Decimal delHrs {get; set;}
	public Decimal ssHrs {get; set;}
	
	public Decimal soInvoices {get; set;}
	public Decimal soHours {get; set;}
	public Decimal soMileage {get; set;}
	public Decimal soUnits {get; set;}
	public Decimal cmInvoices {get; set;}
	public Decimal cmHours {get; set;}
	public Decimal cmMileage {get; set;}
	public Decimal cmUnits {get; set;}
	
	public CurrencyData netRevenue_cmInvoices {get; set;}
	public CurrencyData netRevenue_cmHours	  {get; set;}
	public CurrencyData netRevenue_cmMileage  {get; set;}
	public CurrencyData netRevenue_cmUnits 	  {get; set;}
	public CurrencyData netRevenue_soInvoices {get; set;}
	public CurrencyData netRevenue_soHours    {get; set;}
	public CurrencyData netRevenue_soMileage  {get; set;}
	public CurrencyData netRevenue_soUnits    {get; set;}

	public CurrencyData gm_cmInvoices {get; set;}
	public CurrencyData gm_cmHours	  {get; set;}
	public CurrencyData gm_cmMileage  {get; set;}
	public CurrencyData gm_cmUnits 	  {get; set;}
	public CurrencyData gm_soInvoices {get; set;}
	public CurrencyData gm_soHours    {get; set;}
	public CurrencyData gm_soMileage  {get; set;}
	public CurrencyData gm_soUnits    {get; set;}

	public CurrencyData gmst_cmInvoices {get; set;}
	public CurrencyData gmst_cmHours	{get; set;}
	public CurrencyData gmst_cmMileage  {get; set;}
	public CurrencyData gmst_cmUnits 	{get; set;}
	public CurrencyData gmst_soInvoices {get; set;}
	public CurrencyData gmst_soHours    {get; set;}
	public CurrencyData gmst_soMileage  {get; set;}
	public CurrencyData gmst_soUnits    {get; set;}


	public CurrencyData cm_cmInvoices {get; set;}
	public CurrencyData cm_cmHours	{get; set;}
	public CurrencyData cm_cmMileage  {get; set;}
	public CurrencyData cm_cmUnits 	{get; set;}
	public CurrencyData cm_soInvoices {get; set;}
	public CurrencyData cm_soHours    {get; set;}
	public CurrencyData cm_soMileage  {get; set;}
	public CurrencyData cm_soUnits    {get; set;}
	
	
	public CurrencyData delHrs_cmInvoices {get; set;}
	public CurrencyData delHrs_cmHours	{get; set;}
	public CurrencyData delHrs_cmMileage  {get; set;}
	public CurrencyData delHrs_cmUnits 	{get; set;}
	public CurrencyData delHrs_soInvoices {get; set;}
	public CurrencyData delHrs_soHours    {get; set;}
	public CurrencyData delHrs_soMileage  {get; set;}
	public CurrencyData delHrs_soUnits    {get; set;}


	public CurrencyData ssHrs_cmInvoices {get; set;}
	public CurrencyData ssHrs_cmHours	   {get; set;}
	public CurrencyData ssHrs_cmMileage  {get; set;}
	public CurrencyData ssHrs_cmUnits    {get; set;}
	public CurrencyData ssHrs_soInvoices {get; set;}
	public CurrencyData ssHrs_soHours    {get; set;}
	public CurrencyData ssHrs_soMileage  {get; set;}
	public CurrencyData ssHrs_soUnits    {get; set;}
	
	
	public CurrencyData cmHours_cmInvoices {get; set;}
	public CurrencyData cmHours_cmHours	   {get; set;}
	public CurrencyData cmHours_cmMileage  {get; set;}
	public CurrencyData cmHours_cmUnits    {get; set;}
	public CurrencyData cmHours_soInvoices {get; set;}
	public CurrencyData cmHours_soHours    {get; set;}
	public CurrencyData cmHours_soMileage  {get; set;}
	public CurrencyData cmHours_soUnits    {get; set;}
	
	public CurrencyData cmMileage_cmInvoices {get; set;}
	public CurrencyData cmMileage_cmHours	{get; set;}
	public CurrencyData cmMileage_cmMileage  {get; set;}
	public CurrencyData cmMileage_cmUnits 	{get; set;}
	public CurrencyData cmMileage_soInvoices {get; set;}
	public CurrencyData cmMileage_soHours    {get; set;}
	public CurrencyData cmMileage_soMileage  {get; set;}
	public CurrencyData cmMileage_soUnits    {get; set;}

	public CurrencyData cmInvoices_cmInvoices {get; set;}
	public CurrencyData cmInvoices_cmHours	{get; set;}
	public CurrencyData cmInvoices_cmMileage  {get; set;}
	public CurrencyData cmInvoices_cmUnits 	{get; set;}
	public CurrencyData cmInvoices_soInvoices {get; set;}
	public CurrencyData cmInvoices_soHours    {get; set;}
	public CurrencyData cmInvoices_soMileage  {get; set;}
	public CurrencyData cmInvoices_soUnits    {get; set;}
	
	public CurrencyData cmUnits_cmInvoices {get; set;}
	public CurrencyData cmUnits_cmHours	{get; set;}
	public CurrencyData cmUnits_cmMileage  {get; set;}
	public CurrencyData cmUnits_cmUnits 	{get; set;}
	public CurrencyData cmUnits_soInvoices {get; set;}
	public CurrencyData cmUnits_soHours    {get; set;}
	public CurrencyData cmUnits_soMileage  {get; set;}
	public CurrencyData cmUnits_soUnits    {get; set;}
	
	public CurrencyData ebita_cmInvoices {get; set;}
	public CurrencyData ebita_cmHours	 {get; set;}
	public CurrencyData ebita_cmMileage  {get; set;}
	public CurrencyData ebita_cmUnits  	 {get; set;}
	public CurrencyData ebita_soInvoices {get; set;}
	public CurrencyData ebita_soHours    {get; set;}
	public CurrencyData ebita_soMileage  {get; set;}
	public CurrencyData ebita_soUnits    {get; set;}
	
	/* Suggested Actions */
    public Decimal EBITAGoal                		{get; set;}
    public Decimal ebitaPerc               			{get; set;}
    public Decimal invoices              		  	{get; set;}
    public Decimal revenue   	                	{get; set;}
    public Decimal gmPer                    		{get; set;}	
    public Decimal suggested_1              		{get; set;}
    public Decimal suggested_2              		{get; set;}
    public Decimal suggested_3              		{get; set;}
    public Decimal suggested_4              		{get; set;}
    public Decimal suggested_5              		{get; set;}
    public Decimal suggested_6              		{get; set;}
    public Decimal suggested_7              		{get; set;}
    	
	public RatioAnalysisController() {
        suggested_1 = 0;
        suggested_2 = 0;
        suggested_3 = 0;
        suggested_4 = 0;
        suggested_5 = 0;
        suggested_6 = 0;
        suggested_7 = 0;
        EBITAGoal = 0.00;

		dummyOpp = new Opportunity();
		dummyQuote = new Quote__c();
		dummyOpp.AccountId = null;
		dummyQuote.Sales_Organization_Primary__c = null;
		currAccount = null;
		currSite = null;
		soInvoices = null;
		soHours = null;
		soMileage = null;
		soUnits = null;
		cmInvoices = null;
		cmHours = null;
		cmMileage = null;
		cmUnits = null;
		netRevenue = null;
		
		ebita = null;
		gm = null;
		gmst = null;
		cm = null;
		delHrs = null;
		ssHrs = null;
		startDate = null;
		endDate = null;
		ebitap = null;
		gmp = null;
		cmp = null;
		fancyRevenue 	= null;
		fancyEBIT		= null;
		fancyInvoices 	= null;
		fancyHours 		= null;
		fancyMileage	= null;
		fancyUnits		= null;
		fancyInvoicesSo	= null;
		fancyHoursSo	= null;
		fancyMileageSo	= null;
		fancyUnitsSo	= null;
	
	 netRevenue_cmInvoices = null;
	 netRevenue_cmHours	  = null;
	 netRevenue_cmMileage  = null;
	 netRevenue_cmUnits 	  = null;
	 netRevenue_soInvoices = null;
	 netRevenue_soHours    = null;
	 netRevenue_soMileage  = null;
	 netRevenue_soUnits    = null;

	 gm_cmInvoices = null;
	 gm_cmHours	  = null;
	 gm_cmMileage  = null;
	 gm_cmUnits 	  = null;
	 gm_soInvoices = null;
	 gm_soHours    = null;
	 gm_soMileage  = null;
	 gm_soUnits    = null;

	 gmst_cmInvoices = null;
	 gmst_cmHours	= null;
	 gmst_cmMileage  = null;
	 gmst_cmUnits 	= null;
	 gmst_soInvoices = null;
	 gmst_soHours    = null;
	 gmst_soMileage  = null;
	 gmst_soUnits    = null;


	 cm_cmInvoices = null;
	 cm_cmHours	= null;
	 cm_cmMileage  = null;
	 cm_cmUnits 	= null;
	 cm_soInvoices = null;
	 cm_soHours    = null;
	 cm_soMileage  = null;
	 cm_soUnits    = null;
	
	
	 delHrs_cmInvoices = null;
	 delHrs_cmHours	= null;
	 delHrs_cmMileage  = null;
	 delHrs_cmUnits 	= null;
	 delHrs_soInvoices = null;
	 delHrs_soHours    = null;
	 delHrs_soMileage  = null;
	 delHrs_soUnits    = null;


	 ssHrs_cmInvoices = null;
	 ssHrs_cmHours	   = null;
	 ssHrs_cmMileage  = null;
	 ssHrs_cmUnits    = null;
	 ssHrs_soInvoices = null;
	 ssHrs_soHours    = null;
	 ssHrs_soMileage  = null;
	 ssHrs_soUnits    = null;
	
	
	 cmHours_cmInvoices = null;
	 cmHours_cmHours	   = null;
	 cmHours_cmMileage  = null;
	 cmHours_cmUnits    = null;
	 cmHours_soInvoices = null;
	 cmHours_soHours    = null;
	 cmHours_soMileage  = null;
	 cmHours_soUnits    = null;
	
	 cmMileage_cmInvoices = null;
	 cmMileage_cmHours	= null;
	 cmMileage_cmMileage  = null;
	 cmMileage_cmUnits 	= null;
	 cmMileage_soInvoices = null;
	 cmMileage_soHours    = null;
	 cmMileage_soMileage  = null;
	 cmMileage_soUnits    = null;


	 cmInvoices_cmInvoices = null;
	 cmInvoices_cmHours	= null;
	 cmInvoices_cmMileage  = null;
	 cmInvoices_cmUnits 	= null;
	 cmInvoices_soInvoices = null;
	 cmInvoices_soHours    = null;
	 cmInvoices_soMileage  = null;
	 cmInvoices_soUnits    = null;
	 
	 cmUnits_cmInvoices = null;
	 cmUnits_cmHours	= null;
	 cmUnits_cmMileage  = null;
	 cmUnits_cmUnits 	= null;
	 cmUnits_soInvoices = null;
	 cmUnits_soHours    = null;
	 cmUnits_soMileage  = null;
	 cmUnits_soUnits    = null;
	
	 
	 ebita_cmInvoices = null;
	 ebita_cmHours	  = null;
	 ebita_cmMileage  = null;
	 ebita_cmUnits    = null;
	 ebita_soInvoices = null;
	 ebita_soHours    = null;
	 ebita_soMileage  = null;
	 ebita_soUnits    = null;	
	}
	
	
	public CurrencyData findCurrencyValue(decimal incBvn, decimal incBvd, Boolean incPrice){
		
		double bvn = incBvn.doubleValue();
		double bvd = incBvd.doubleValue();
		if (incPrice  == TRUE){
			if (currAccount != null && bvn != null && bvd != null && bvd != 0 && bvn != 0){
				return new CurrencyData(currAccount.CurrencyISOCode, Double.valueOf(bvn/bvd));	
			}
			return new CurrencyData('$', 0);
		}
		
		if (currAccount != null && bvn != null && bvd != null && bvd != 0 && bvn != 0){
            	System.debug(double.valueOf(bvn/bvd));	
				return new CurrencyData(' ', Double.valueOf(bvn/bvd));
				
			}
			return new CurrencyData(' ', 0);
	}
	
	public void performAnalyzation() {
		if(dummyQuote.Price_Valid_From__c != null && dummyQuote.Price_Valid_To__c != null && dummyOpp.AccountId != null && dummyQuote.Sales_Organization_Primary__c != null) {
			//Preliminary setup
			try {
				currAccount = [SELECT Id, Parent.SAP_Account_Number__c, Name, SAP_Account_Number__c, CurrencyISOCode, ShippingCountry FROM Account WHERE Id = :dummyOpp.AccountId LIMIT 1];
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QEC_Security));
				return;
			}
			currSite = [SELECT Id, Name, SAP_Account_Number__c, Company_Site__r.Name FROM Sales_Site__c WHERE Id = :dummyQuote.Sales_Organization_Primary__c LIMIT 1];
			PandLData quoteData = PandLData.createForCustomer(dummyOpp.AccountId, dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_To__c);
			PandLData siteData = PandLData.createForSite(dummyQuote.Sales_Organization_Primary__c, dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_To__c);
			PandLData data = PandLData.createForCustomerSalesSite(dummyOpp.AccountId, dummyQuote.Sales_Organization_Primary__c, dummyQuote.Price_Valid_From__c, dummyQuote.Price_Valid_To__c);
			
			
			/* Suggested Actions in here, else is Ratio Analysis */
			if(EBITAGoal != 0) {
	            Decimal mileageSA             = data.distance.value;
	            Decimal poundsSA              = data.units.value;  
	            Decimal ebitaPercSA           = data.ebitPercentage;
	            Decimal invoicesSA            = data.invoices.value;
	            Decimal revenueSA             = data.netRevenue.value;
	            Decimal gmPerSA               = data.grossMarginPercentage;  
	            Decimal totDirSA              = data.directCostDeliveryHrs.value  + data.directCostShotHrs.value;
	            Decimal totIndSA              = data.indirectCostTotalHours.value;
	            Decimal totHrsSA              = totDirSA+ totIndSA;
	            Decimal ebitaSA               = data.ebit.value;
	            Decimal gmSA                  = data.grossMargin.value;
	            Decimal cmSA                  = data.contributionMargin.value;	
	            
	            try{
	                suggested_1 = ((EBITAGoal - (ebitaPercSA /100)) * revenueSA/poundsSA * 100).setScale(4);
	            }
	            catch(exception e){
	            	suggested_1 = 0;
	            }
	            try {
	            	suggested_2 = ((EBITAGoal - (ebitaPercSA/100)) * revenueSA/invoicesSA / (gmPerSA/100)).setScale(4);
	            }
	            catch(exception e){
	            	suggested_2 = 0;	
	            }
	             try {
	            	suggested_3 = ((((EBITAGoal - (ebitaPercSA/100)) * revenueSA) / (totDirSA/ totHrsSA)) / invoicesSA).setScale(4);
	            }
	            catch(exception e){
	            	suggested_3 = 0;	
	            }
	            try {
	            	suggested_4 = ((((EBITAGoal - (ebitaPercSA/100)) * revenueSA) / invoicesSA) / ((totDirSA / invoicesSA) + (totIndSA / invoicesSA))).setScale(4);
	            }
	            catch(exception e){
	            	suggested_4 = 0;	
	            }
	            try {
	            	suggested_5 = ((((EBITAGoal - (ebitaPercSA/100)) * revenueSA) / invoicesSA) / (totHrsSA / invoicesSA)).setScale(4);
	            }
	            catch(exception e){
	            	suggested_5 = 0;	
	            }
	            try {
	            	suggested_6 = ((((EBITAGoal - (ebitaPercSA/100)) * revenueSA)) / invoicesSA).setScale(4);
	            }
	            catch(exception e){
	            	suggested_6 = 0;	
	            }
	            try {
	            	suggested_7 = ((((EBITAGoal - (ebitaPercSA/100)) * revenueSA) / invoicesSA) / (mileageSA / invoicesSA)).setScale(4);
	            }
	            catch(exception e){
	            	suggested_7 = 0;	
	            }
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.RAAndSA_Error));	
			}
			/* Suggested Actions in here, else is Ratio Analysis */
			
			//Query for Account Info
			startDate = dummyQuote.Price_Valid_From__c;
			endDate = dummyQuote.Price_Valid_To__c;
			fancyStartDate = startDate.addDays(1).format('dd-MMM-yyyy');
			fancyEndDate = endDate.addDays(1).format('dd-MMM-yyyy');
			netRevenue = quoteData.netRevenue.value;
			fancyRevenue = netRevenue.setScale(0).format();
			fancyInvoices = quoteData.invoices.value.setScale(0).format();
			ebita = quoteData.ebit.value;
			fancyEBIT = ebita.setScale(0).format();
			ebitap = quoteData.ebitPercentage;
			cmHours = quoteData.totalHours.value;
			cmInvoices = quoteData.invoices.value;
			cmMileage = quoteData.distance.value;
			cmUnits = quoteData.units.value;
			gm = quoteData.grossMargin.value;
			gmp = quoteData.grossMarginPercentage;
			cm = quoteData.contributionMargin.value;
			cmp = quoteData.contributionMarginPercentage;
			delHrs = quoteData.deliveryHours;
			ssHrs = quoteData.shotHours;
			gmst = quoteData.grossMarginSeeThrough.value;
			
			
			fancyHours		= cmHours.setScale(0).format();
			fancyMileage	= cmHours.setScale(0).format();
			fancyUnits		= cmUnits.setScale(0).format();

			//Query for Sales Org Info
			soHours = siteData.totalHours.value;
			soInvoices =siteData.invoices.value;
			soMileage = siteData.distance.value;
			soUnits = siteData.units.value;
			
			fancyInvoicesSo	= soInvoices.setScale(0).format();
			fancyHoursSo	= soHours.setScale(0).format();
			fancyMileageSo	= soMileage.setScale(0).format();
			fancyUnitsSo	= soUnits.setScale(0).format();
			
			
	 netRevenue_cmInvoices = findCurrencyValue(netRevenue, cmInvoices, true);
	 netRevenue_cmHours	  = findCurrencyValue(netRevenue, cmHours, true);
	 netRevenue_cmMileage  = findCurrencyValue(netRevenue, cmMileage, true );
	 netRevenue_cmUnits 	  = findCurrencyValue(netRevenue, cmUnits, true);
	 netRevenue_soInvoices = findCurrencyValue(netRevenue, soInvoices, true );
	 netRevenue_soHours    = findCurrencyValue(netRevenue, soHours, true);
	 netRevenue_soMileage  = findCurrencyValue(netRevenue, soMileage, true);
	 netRevenue_soUnits    = findCurrencyValue(netRevenue, soUnits, true);

 	gm_cmInvoices = findCurrencyValue(gm, cmInvoices, true);
	 gm_cmHours	  = findCurrencyValue(gm, cmHours, true);
	 gm_cmMileage  = findCurrencyValue(gm, cmMileage, true);
	 gm_cmUnits 	  = findCurrencyValue(gm, cmUnits, true);
	 gm_soInvoices = findCurrencyValue(gm, soInvoices, true);
	 gm_soHours    = findCurrencyValue(gm, soHours, true);
	 gm_soMileage  = findCurrencyValue(gm, soMileage, true);
	 gm_soUnits    = findCurrencyValue(gm, soUnits, true);

 	 gmst_cmInvoices = findCurrencyValue(gmst, cmInvoices, true);
	 gmst_cmHours	  = findCurrencyValue(gmst, cmHours, true);
	 gmst_cmMileage  = findCurrencyValue(gmst, cmMileage, true);
	 gmst_cmUnits 	  = findCurrencyValue(gmst, cmUnits, true);
	 gmst_soInvoices = findCurrencyValue(gmst, soInvoices, true);
	 gmst_soHours    = findCurrencyValue(gmst, soHours, true);
	 gmst_soMileage  = findCurrencyValue(gmst, soMileage, true);
	 gmst_soUnits    = findCurrencyValue(gmst, soUnits, true);


	 cm_cmInvoices = findCurrencyValue(cm, cmInvoices, true);
	 cm_cmHours	= findCurrencyValue(cm, cmHours, true);
	 cm_cmMileage  = findCurrencyValue(cm, cmMileage, true);
	 cm_cmUnits 	= findCurrencyValue(cm, cmUnits, true);
	 cm_soInvoices = findCurrencyValue(cm, soInvoices, true);
	 cm_soHours    = findCurrencyValue(cm, soHours, true);
	 cm_soMileage  = findCurrencyValue(cm, soMileage, true);
	 cm_soUnits    = findCurrencyValue(cm, soUnits, true);
	
	
	 delHrs_cmInvoices = findCurrencyValue(delHrs, cmInvoices, false);
	 delHrs_cmHours	= findCurrencyValue(delHrs, cmHours, false);
	 delHrs_cmMileage  = findCurrencyValue(delHrs, cmMileage, false);
	 delHrs_cmUnits 	= findCurrencyValue(delHrs, cmUnits, false);
	 delHrs_soInvoices = findCurrencyValue(delHrs, soInvoices, false);
	 delHrs_soHours    = findCurrencyValue(delHrs, soHours, false);
	 delHrs_soMileage  = findCurrencyValue(delHrs, soMileage, false);
	 delHrs_soUnits    = findCurrencyValue(delHrs, soUnits, false);


	 ssHrs_cmInvoices = findCurrencyValue(ssHrs, cmInvoices, false);
	 ssHrs_cmHours	   = findCurrencyValue(ssHrs, cmHours, false);
	 ssHrs_cmMileage  = findCurrencyValue(ssHrs, cmMileage, false);
	 ssHrs_cmUnits    = findCurrencyValue(ssHrs, cmUnits, false);
	 ssHrs_soInvoices = findCurrencyValue(ssHrs, soInvoices, false);
	 ssHrs_soHours    = findCurrencyValue(ssHrs, soHours, false);
	 ssHrs_soMileage  = findCurrencyValue(ssHrs, soMileage, false);
	 ssHrs_soUnits    = findCurrencyValue(ssHrs, soUnits, false);
	
	
	 cmHours_cmInvoices = findCurrencyValue(cmHours, cmInvoices, false);
	 cmHours_cmHours	   = findCurrencyValue(cmHours, cmHours, false);
	 cmHours_cmMileage  = findCurrencyValue(cmHours, cmMileage, false);
	 cmHours_cmUnits    = findCurrencyValue(cmHours, cmUnits, false);
	 cmHours_soInvoices = findCurrencyValue(cmHours, soInvoices, false);
	 cmHours_soHours    = findCurrencyValue(cmHours, soHours, false);
	 cmHours_soMileage  = findCurrencyValue(cmHours, soMileage, false);
	 cmHours_soUnits    = findCurrencyValue(cmHours, soUnits, false);
	
	 cmMileage_cmInvoices = findCurrencyValue(cmMileage, cmInvoices, false);
	 cmMileage_cmHours	= findCurrencyValue(cmMileage, cmHours, false);
	 cmMileage_cmMileage  = findCurrencyValue(cmMileage, cmMileage, false);
	 cmMileage_cmUnits 	= findCurrencyValue(cmMileage, cmUnits, false);
	 cmMileage_soInvoices = findCurrencyValue(cmMileage, soInvoices, false);
	 cmMileage_soHours    = findCurrencyValue(cmMileage, soHours, false);
	 cmMileage_soMileage  = findCurrencyValue(cmMileage, soMileage, false);
	 cmMileage_soUnits    = findCurrencyValue(cmMileage, soUnits, false);
	 
	 cmInvoices_cmInvoices = findCurrencyValue(cmInvoices, cmInvoices, false);
	 cmInvoices_cmHours	= findCurrencyValue(cmInvoices, cmHours, false);
	 cmInvoices_cmMileage  = findCurrencyValue(cmInvoices, cmMileage, false);
	 cmInvoices_cmUnits 	= findCurrencyValue(cmInvoices, cmUnits, false);
	 cmInvoices_soInvoices = findCurrencyValue(cmInvoices, soInvoices, false);
	 cmInvoices_soHours    = findCurrencyValue(cmInvoices, soHours, false);
	 cmInvoices_soMileage  = findCurrencyValue(cmInvoices, soMileage, false);
	 cmInvoices_soUnits    = findCurrencyValue(cmInvoices, soUnits, false);
	 

	 cmUnits_cmInvoices = findCurrencyValue(cmUnits, cmInvoices, false);
	 cmUnits_cmHours	= findCurrencyValue(cmUnits, cmHours, false);
	 cmUnits_cmMileage  = findCurrencyValue(cmUnits, cmMileage, false);
	 cmUnits_cmUnits 	= findCurrencyValue(cmUnits, cmUnits, false);
	 cmUnits_soInvoices = findCurrencyValue(cmUnits, soInvoices, false);
	 cmUnits_soHours    = findCurrencyValue(cmUnits, soHours, false);
	 cmUnits_soMileage  = findCurrencyValue(cmUnits, soMileage, false);
	 cmUnits_soUnits    = findCurrencyValue(cmUnits, soUnits, false);
	
     ebita_cmInvoices = findCurrencyValue(ebita, cmInvoices, true);
	 ebita_cmHours	= findCurrencyValue(ebita, cmHours, true);
	 ebita_cmMileage  = findCurrencyValue(ebita, cmMileage, true);
	 ebita_cmUnits  	= findCurrencyValue(ebita, cmUnits, true);
	 ebita_soInvoices = findCurrencyValue(ebita, soInvoices, true);
	 ebita_soHours    = findCurrencyValue(ebita, soHours, true);
	 ebita_soMileage  = findCurrencyValue(ebita, soMileage, true);
	 ebita_soUnits    = findCurrencyValue(ebita, soUnits, true);
			
			
		} else {
			currAccount = null;
			currSite = null;
		}
	}
	
}