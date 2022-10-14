public class ManualCopaAggregate {
	private String retURL;
	public string month { get; set; }
	public string year { 
		get{
			if (year == null) {
				year = '2013';
			}
			return year;
		} 
		set; 
	}
	
	public ManualCopaAggregate(ApexPages.StandardSetController controller) {
		retURL = ApexPages.currentPage().getParameters().get('retURL');
	}
	
	public List<SelectOption> getYears() {
		List<SelectOption> yearsList = new List<SelectOption>();
		for (integer i=2000; i<= date.today().year(); i++) {
			yearsList.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
		}
		return yearsList;
	}
	
	public PageReference SendInfo() {
		String userId = UserInfo.getUserId();
		User myUser = [SELECT email FROM User where Id = :userId LIMIT 1];
		
		BatchCopaAggregate bca = new BatchCopaAggregate(myUser.email, month, year);
		Database.executeBatch(bca,1);
		return new PageReference('/' + getKeyPrefix());
	}
	
	public PageReference GoBack() {
	
		return new PageReference('/' + getKeyPrefix());
	
	}
	
	public String getKeyPrefix() {
		Schema.DescribeSObjectResult dsr = COPA_Aggregate__c.SObjectType.getDescribe();
		return dsr.getKeyPrefix();
	}
}