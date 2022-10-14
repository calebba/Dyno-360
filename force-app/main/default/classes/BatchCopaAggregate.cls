global class BatchCopaAggregate implements Database.Batchable<Sobject> {
	private String userEmail;
	private Date firstDate;
	private Date lastDate;
	
	global BatchCopaAggregate(String mail, String month, String year) {
		userEmail = mail;
		String stringDate = year + '-' + month + '-1';
		Date myDate = date.valueOf(stringDate);
		if (myDate.month() != date.Today().month()) {
			firstDate = myDate;
			lastDate = myDate.addMonths(1).addDays(-1);
		} else {
			firstDate = myDate;
			lastDate = date.Today();
		}
	}
	
	global Database.Querylocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id, Account_Group__c FROM Account');
	}
	
	global void execute(Database.BatchableContext bc, List<Account> accns) {
		Account myAccount = accns[0];
		//Date lastMonth = Date.Today().addMonths(-1);
		
		Set<Id> myAccountSoldTo = new Set<Id>();
		//myAccountSoldTo.add(myAccount.Id);
		
		List<AggregateResult> result = new List<AggregateResult>();
		List<COPA_Aggregate__c> copaAggList;
		
		copaAggList = [SELECT Id FROM COPA_Aggregate__c WHERE Customer__c = :myAccount.Id AND (Current_Month__c >= :firstDate AND Current_Month__c <= :lastDate)];
		if (copaAggList.size() > 0) {
			delete copaAggList;
		}
			
		if (myAccount.Account_Group__c == '0002 Ship-to party') {
			result = [SELECT Current_Month__c, Sales_Site__c, Material_Item__r.PHL1__c mi,
						SUM(Manual_Cost_Per_Ton__c) mcpt, SUM(Total_Cogs__c) tc, SUM(Calculated_COGS__c) cc, SUM(Tons__c) t,
						SUM(DELHRS__c) delhrs, SUM(SHOTHRS__c) shothrs, SUM(MILES__c) miles, SUM(LBS__c) pounds, SUM(INVOICES__c) inv,
						SUM(Net_Revenue__c) nrev, SUM(True_Total_Cogs__c) ttcogs, SUM(COGS_See_Through__c) cst, Plant__c pl
						FROM Copa__c WHERE Customer__c = :myAccount.Id AND (Current_Month__c >= :firstDate AND Current_Month__c <= :lastDate)
						GROUP BY Current_Month__c, Sales_Site__c, Plant__c, Material_Item__r.PHL1__c];
		} else if (myAccount.Account_Group__c == '0001 Sold-to party') {
			List<Account> myAccountList = [SELECT Id FROM Account WHERE ParentId = :myAccount.Id];
			for (Account a : myAccountList) {
				myAccountSoldTo.add(a.Id);
			}
			result = [SELECT Current_Month__c, Sales_Site__c, Material_Item__r.PHL1__c mi,
						SUM(Manual_Cost_Per_Ton__c) mcpt, SUM(Total_Cogs__c) tc, SUM(Calculated_COGS__c) cc, SUM(Tons__c) t,
						SUM(DELHRS__c) delhrs, SUM(SHOTHRS__c) shothrs, SUM(MILES__c) miles, SUM(LBS__c) pounds, SUM(INVOICES__c) inv,
						SUM(Net_Revenue__c) nrev, SUM(True_Total_Cogs__c) ttcogs, SUM(COGS_See_Through__c) cst, Plant__c pl
						FROM Copa__c WHERE Customer__c IN :myAccountSoldTo AND (Current_Month__c >= :firstDate AND Current_Month__c <= :lastDate)
						GROUP BY Current_Month__c, Sales_Site__c, Plant__c, Material_Item__r.PHL1__c];
		}
		
		copaAggList = new List<COPA_Aggregate__c>();
		COPA_Aggregate__c ca; 
		for (AggregateResult a : result) {
			ca = new COPA_Aggregate__c();
			ca.Customer__c = myAccount.Id;
			System.debug('id:::' + ca.Customer__c);
			ca.Current_Month__c = (Date)a.get('Current_Month__c');
			ca.Sales_Site__c = (Id)a.get('Sales_Site__c');
			ca.Material_PHL1__c = (String)a.get('mi');
			ca.DELHRS__c = (Decimal)a.get('delhrs');
			ca.SHOTHRS__c = (Decimal)a.get('shothrs');
			ca.MILES__c = (Decimal)a.get('miles');
			ca.LBS__c = (Decimal)a.get('pounds');
			ca.INVOICES__c = (Decimal)a.get('inv');
			ca.Net_Revenue__c = (Decimal)a.get('nrev');
			//ca.True_Total_Cogs__c = (Decimal)a.get('ttcogs');
			ca.COGS_See_Through__c = (Decimal)a.get('cst');
			ca.Manual_Cost_Per_Ton__c = (Decimal)a.get('mcpt');
			ca.Total_Cogs__c = (Decimal)a.get('tc');
			ca.Calculated_COGS__c = (Decimal)a.get('cc');
			ca.Tons__c = (Decimal)a.get('t');
			ca.Plant__c = (String)a.get('pl');
			System.debug('ca:::' + ca);
			copaAggList.add(ca);
		}
		
		if (copaAggList.size() > 0) {
			insert copaAggList;
		}
	}
	
	global void finish(Database.BatchableContext bc) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses(new String[] {userEmail});
		//mail.setReplyTo('batch@acme.com');
		mail.setSenderDisplayName('Batch Processing');
		mail.setSubject('Batch Process Completed');
		mail.setPlainTextBody('Batch Process has completed');
		
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

}