public with sharing class PandLExtension {
	public PandLData data {get;set;}
	public  Date fromDate {get; set;}
	public  Date toDate   {get; set;}
	public  Id   customerId {get;set;}
	public  Id   salesSiteId {get;set;}
	
	
	public PandLExtension(ApexPages.StandardController con) {
	
		 if(ApexPages.currentPage().getParameters().get('salesSiteId') != null) {
		 	System.debug('1');
		 	salesSiteId =ApexPages.currentPage().getParameters().get('salesSiteId');
		 	fromDate	= Date.parse(ApexPages.currentPage().getParameters().get('fd'));
		 	toDate		= Date.parse(ApexPages.currentPage().getParameters().get('td'));
		 	this.data = PandLData.createForSite(salesSiteId, fromDate, toDate);
		 }
		 
		 if(ApexPages.currentPage().getParameters().get('accountId') != null) {
		 	
		 	customerId =ApexPages.currentPage().getParameters().get('accountId');
		 	fromDate	= Date.parse(ApexPages.currentPage().getParameters().get('fd'));
		 	toDate		= Date.parse(ApexPages.currentPage().getParameters().get('td'));
		 	System.debug('Customer Id' + customerID + 'From Date: ' + fromDate + 'To Date' + toDate);
		 	this.data = PandLData.createForCustomer(customerId, fromDate, toDate);
		 }
	else {
		
		if (con.getId() != null)
			this.data = PandLData.createForQuote((Id)con.getId());
		 if(ApexPages.currentPage().getParameters().get('quoteID') != null){
			this.data = PandLData.createForQuote(ApexPages.currentPage().getParameters().get('quoteID'));
		}
	
	}
	}

}