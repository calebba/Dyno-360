public with sharing class QuoteServiceDetailsController {
	public Decimal quantityOfEDB {get; private set;}
	public String currentLanguage {get; private set;}
	public Quote__c record {get; private set;}
	public List<Quote_Line_Item__c> lineItems {get; private set;}
	public CurrencyData quoteAmount {get; set;}
	public CurrencyData delHrs {get; set;}
	public CurrencyData ssHrs {get; set;}
	public CurrencyData totalHrs {get; set;}
	public CurrencyData roundTripTruckDistance {get; set;}
	public CurrencyData qEDB {get; set;}
	public CurrencyData totalInvoices {get; set;}
	
	private static final String EXPLOSIVES = System.label.QSD_Explosives;
	private static final String DETONATORS = System.label.QSD_Detonator;
	private static final String BOOSTERS = System.label.QSD_booster;
	
	public QuoteServiceDetailsController() {
		this.record = [Select Id, Quote_Amount__c, Customer__r.Name, Customer__r.CurrencyIsoCode, Customer__r.SAP_Account_Number__c, Customer__r.Company_Code__c, Sales_Organization_Primary__r.Company_Site__r.Name, Sales_Organization_Primary__r.Region__c, Sales_Organization_Primary__r.Name, Name, Delivery_Hours__c, Shot_Service_Load_Assistance_Hours__c, Round_Trip_Truck_Distance__c, Total_Number_of_Invoices__c,CurrencyIsoCode,Quote_Description__c from Quote__c where Id=:ApexPages.currentPage().getParameters().get('quoteID')];
		this.lineItems = [Select Id, Material_Item__r.Name, Material_Item__r.PHL1__c, Quantity__c, Material_Item__r.Product_Hierarchy__c from Quote_Line_Item__c where Quote__c = :this.record.Id];
		this.quoteAmount = new CurrencyData(record.CurrencyIsoCode, record.Quote_Amount__c == null ? 0.00 : record.Quote_Amount__c);
		this.delHrs = new CurrencyData('', record.Delivery_Hours__c == null ? 0.00 : record.Delivery_Hours__c);
		this.ssHrs = new CurrencyData('', record.Shot_Service_Load_Assistance_Hours__c == null ? 0.00 : record.Shot_Service_Load_Assistance_Hours__c);
		this.totalHrs = new CurrencyData('', delHrs.value + ssHrs.value);
		this.roundTripTruckDistance = new CurrencyData('', record.Round_Trip_Truck_Distance__c == null ? 0.00 : record.Round_Trip_Truck_Distance__c);
		this.totalInvoices = new CurrencyData('', record.Total_Number_of_Invoices__c == null ? 0.00 : record.Total_Number_of_Invoices__c);
		if (this.record.Customer__c != null)
			currentLanguage = LanguageTranslationUtil.queryLanguage(this.record.Customer__c);
		else
			currentLanguage = 'US'; 
		
		Set<String> productNames = new Set<String>();
		for(Quote_Line_Item__c qli : this.lineItems) {
			productNames.add(qli.Material_Item__r.PHL1__c);
		}
		
		this.quantityOfEDB = 0.0;
		List<Product_Grouping__c> productGroupings = [select Name, Title__c from Product_Grouping__c where Name in: productNames];
		for (Quote_Line_Item__c qli : this.lineItems) {
			for(Product_Grouping__c pg : productGroupings) {
				if(qli.Material_Item__r.Product_Hierarchy__c.contains(pg.Name) && (pg.Title__c.toLowerCase().contains(EXPLOSIVES) || pg.Title__c.toLowerCase().contains(DETONATORS) || pg.Title__c.toLowerCase().contains(BOOSTERS)))
					quantityOfEDB += qli.Quantity__c;
			}
		}
		this.qEDB = new CurrencyData('', quantityOfEDB);		
	}
}