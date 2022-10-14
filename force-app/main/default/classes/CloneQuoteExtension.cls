public with sharing class CloneQuoteExtension {
	private Id quoteToCloneId;
	
	public CloneQuoteExtension(ApexPages.StandardController con) {
		this.quoteToCloneId = (Id)con.getId();
	}
	
	public PageReference getCloneUrl() {
		Opportunity quote = QuoteUtil.cloneQuote(this.quoteToCloneId);
		return new PageReference('/'+quote.Id);
	}
}