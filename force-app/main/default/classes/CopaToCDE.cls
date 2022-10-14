public with sharing class CopaToCDE {
	
	@future
	public static void sumAndInsertToCDE(List <Id> incRecs){
		
		List<Copa__c> incRecords = [SELECT Id, Current_Month__c, Sales_Site__c FROM Copa__c WHERE Id in :incRecs];
		
		Set<Date> datesToSearch = new Set<Date>();
		Set<Id> sssToSearch = new Set<Id>();
		for (Copa__c cpa : incRecords)
		{
			if (!datesToSearch.contains(cpa.Current_Month__c))
				datesToSearch.add(cpa.Current_Month__c);
			if (!sssToSearch.contains(cpa.Sales_Site__c))
				sssToSearch.add(cpa.Sales_Site__c);
		}
		
		List<AggregateResult> aggregateCopa = [SELECT CALENDAR_YEAR(c.Current_Month__c)theYear, CALENDAR_MONTH(c.Current_Month__c)theMonth,SUM(c.LBS__c)sumLBS,
													  SUM(c.DELHRS__c)sumDELHRS, SUM(c.SHOTHRS__c)sumSHOTHRS, SUM(c.MILES__c)sumMILES, SUM(c.INVOICES__c)sumINVOICES,
													  SUM(c.Net_Revenue__c)sumREVENUE, SUM(c.Total_Cogs__c)sumCOGS, Sales_Site__c
							 					 FROM Copa__c c
							 					 WHERE Current_Month__c in :datesToSearch AND Sales_Site__c in :sssToSearch AND Copa_Type__c = 'Actual'
							 					 GROUP BY Sales_Site__c,  CALENDAR_YEAR(c.Current_Month__c), CALENDAR_MONTH(c.Current_Month__c)];
	
		List <Cost_Driver_Entry__c> CDEList = new List<Cost_Driver_Entry__c>();
		Map<String, Cost_Driver_Entry__c> keyToCDE = new Map<String, Cost_Driver_Entry__c>();
		List<String> constraintKeys = new List<String>();
		Integer tempYear, tempMonth;	
		Date t;
		String cKey;
		for(AggregateResult d: aggregateCopa) {
			tempYear = integer.valueOf(d.get('theYear') + '');
			tempMonth = integer.valueOf(d.get('theMonth') + '');
			t = date.newinstance(tempYear, tempMonth,01);
			cKey = d.get('Sales_Site__c') + '-' + t;
			constraintKeys.add(cKey);		
		}
		
		List<Cost_Driver_Entry__c> cdes = [SELECT Id, Total_Cogs__c, Constraint_Key__c, Current_Month__c, DELHRS__c, SHOTHRS__c, DISTANCE__c, Sales_Site__c, UNITS__c, REVENUE__c, INVOICES__c FROM Cost_Driver_Entry__c WHERE Constraint_Key__c in :constraintKeys];
		for(Cost_Driver_Entry__c cde : cdes) {
			cde.DELHRS__c = 0;
			cde.SHOTHRS__c = 0;
			cde.DISTANCE__c	= 0;		
			cde.UNITS__c = 0;
			cde.REVENUE__c = 0;
			cde.INVOICES__c = 0;		
			cde.Total_Cogs__c = 0; 
			keyToCDE.put(cde.Constraint_Key__c, cde);
		}
		
		Decimal sumDelHrs, sumShotHrs, sumMiles, sumLbs, sumRev, sumInv, sumCogs;
		Cost_Driver_Entry__c newCDE;

		for (AggregateResult d: aggregateCopa){
			tempYear = integer.valueOf(d.get('theYear') + '');
			tempMonth = integer.valueOf(d.get('theMonth') + '');
			t = date.newinstance(tempYear, tempMonth,01);
			cKey = d.get('Sales_Site__c') + '-' + t;
			
			sumDelHrs = d.get('sumDELHRS') == null ? 0 : decimal.valueOf(d.get('sumDELHRS') + '');
			sumShotHrs = d.get('sumSHOTHRS') == null ? 0 : decimal.valueOf(d.get('sumSHOTHRS') + '');
			sumMiles = d.get('sumMILES') == null ? 0 : decimal.valueOf(d.get('sumMILES') + '');
			sumLbs = d.get('sumLBS') == null ? 0 : decimal.valueOf(d.get('sumLBS') + '');
			sumRev = d.get('sumREVENUE') == null ? 0 : decimal.valueOf(d.get('sumREVENUE') + '');
			sumInv = d.get('sumINVOICES') == null ? 0 : decimal.valueOf(d.get('sumINVOICES') + '');
			sumCogs = d.get('sumCOGS') == null ? 0 :  decimal.valueOf(d.get('sumCOGS') + '');
			
			if(keyToCDE.containsKey(cKey)) {
				newCDE = keyToCDE.get(cKey);
				newCDE.DELHRS__c		 += sumDelHrs;
				newCDE.SHOTHRS__c		 += sumShotHrs;
				newCDE.DISTANCE__c		 += sumMiles;		
				newCDE.UNITS__c			 += sumLbs;
				newCDE.REVENUE__c		 += sumRev;
				newCDE.INVOICES__c		 += sumInv;		
				newCDE.Total_Cogs__c     += sumCogs;
				CDEList.add(newCDE);						
			} else {
				newCDE = new Cost_Driver_Entry__c();
				newCDE.Constraint_Key__c = cKey;
				newCDE.DELHRS__c		 = sumDelHrs;
				newCDE.SHOTHRS__c		 = sumShotHrs;
				newCDE.DISTANCE__c		 = sumMiles;
				newCDE.Current_Month__c	 = t;
				newCDE.Sales_Site__c 	 = (Id)(d.get('Sales_Site__c') + '');
				newCDE.UNITS__c			 = sumLbs;
				newCDE.REVENUE__c		 = sumRev;
				newCDE.INVOICES__c		 = sumInv;
				newCDE.Total_Cogs__c     = sumCogs;
				CDEList.add(newCDE);
			}
		}
		
		upsert CDEList;			
	}
		
	
}