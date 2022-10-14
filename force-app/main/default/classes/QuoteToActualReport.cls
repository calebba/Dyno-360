public with sharing class QuoteToActualReport {

	public Quote__c dummyQuote { get; set; }
	public Contact dummyContact1 { get; set; }
	public Contact dummyContact2 { get; set; }
	
	public Quote__c scenario { get; set; }

	public PandLData quoteData { get; set; }
	public PandLData actualData { get; set; }
	public Map<String, integer> diffData { get; set; }
	
	public boolean dataExists {
		get {
			return quoteData != null && actualData != null;
		}
	}
	
	public boolean BatchRunning { get; set; }
	public Id BatchId { get; set; }
	public String BatchText { get; set; }
	
	public QuoteToActualReport() {
		
		BatchRunning = false;
		BatchId = null;
		
		dummyQuote = new Quote__c();
		dummyContact1 = new Contact();
		dummyContact2 = new Contact();
		
		Id scenarioId = ApexPages.currentPage().getParameters().get('id');
		
		scenario = [SELECT Id, Name, Customer__c, Customer__r.Account_Group__c, Sales_Organization_Primary__c, Sales_Organization_Primary__r.Region_Site__c,
						Sales_Organization_Primary__r.Company_Site__c, Price_Valid_From__c, Price_Valid_To__c, Customer__r.Name, Customer__r.SAP_Account_Number__c,
						Quote_Valid_From__c, Quote_Valid_To__c FROM Quote__c WHERE Id = :scenarioId];
		
		//Regenerate();
	}
	
	public void Regenerate() {
		
		if (dummyContact1.BirthDate == null || dummyContact2.BirthDate == null)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.QtA_Empty_Dates_Error));
   			return;
		}
		
		try {
    		COPA__c lastCopa = [SELECT Current_Month__c FROM COPA__c ORDER BY Current_Month__c DESC LIMIT 1];
    		PCA__c lastPca = [SELECT Post_Month__c FROM PCA__c ORDER BY Post_Month__c DESC LIMIT 1];
    		if (lastCopa.Current_Month__c < dummyContact2.BirthDate.toStartOfMonth() || lastPca.Post_Month__c < dummyContact2.BirthDate.toStartOfMonth()) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PandL_Date_Error));
    			return;
    		}
    	} catch (Exception ex) {
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PandL_Date_Error));
   			return;
    	}
    	
		decimal actualDays = dummyContact1.BirthDate.daysBetween(dummyContact2.BirthDate) + 1;
		decimal quoteDays = Date.isLeapYear(scenario.Price_Valid_From__c.year()) ? 366 : 365; // Quote is always considered to be 1 year long
		
		System.debug('->' + actualDays + '<->' + quoteDays + '<-');
		
		quoteData = PandLData.createForQuote(scenario.Id, actualDays / quoteDays);
		
		if (scenario.Customer__r.Account_Group__c == '0002 Ship-to party') {
			actualData = PandLData.createForPandLGenerator2(dummyContact1.BirthDate, dummyContact2.BirthDate, 
															scenario.Customer__c, false, scenario.Sales_Organization_Primary__c, 
															scenario.Sales_Organization_Primary__r.Region_Site__c,
															scenario.Sales_Organization_Primary__r.Company_Site__c,
															null, null, null, UserInfo.getDefaultCurrency(), null, false);
			BatchRunning = false;
			CalculateDiffData();
		} else { 
			BatchId = Database.executeBatch(new QuoteToActualBatch(scenario, dummyContact1.BirthDate, dummyContact2.BirthDate, UserInfo.getDefaultCurrency()), 1);
			BatchRunning = true;
			BatchText = 'Job 0% completed';
		}
		
	}
	
	public void CheckBatchStatus() {
		
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BatchId];
		if (a.Status != 'Completed') {
			if (a.Status == 'Failed' || a.Status == 'Aborted') {
				BatchText = 'Job has failed or was aborted by user.';
				return;
			}
			if (a.TotalJobItems == 0)
				BatchText = 'Job 0% completed';
			else
				BatchText = 'Job ' + (a.JobItemsProcessed * 100 / a.TotalJobItems) + '% completed';
			return;
		}
		
		List<QuoteToActualAux__c> qaas = [SELECT Id, totalst__c, unitsst__c FROM QuoteToActualAux__c WHERE BatchJob__c = :BatchId];
		List<PandLData> pds = new List<PandLData>();
		for (QuoteToActualAux__c qaa : qaas) {
			PandLData pd = new PandLData();
			pd.totalst = qaa.totalst__c;
			pd.unitsst = qaa.unitsst__c;
			pds.add(pd);
		}
		delete qaas;
		actualData = PandLData.createForPandLGenerator2(dummyContact1.BirthDate, dummyContact2.BirthDate, 
														scenario.Customer__c, true, scenario.Sales_Organization_Primary__c, 
														scenario.Sales_Organization_Primary__r.Region_Site__c,
														scenario.Sales_Organization_Primary__r.Company_Site__c,
														null, null, null, UserInfo.getDefaultCurrency(), pds, false);
		CalculateDiffData();
		BatchRunning = false;
	}
	
	public PageReference CancelBatch() {
		System.abortJob(BatchId);
		List<QuoteToActualAux__c> qaas = [SELECT Id, totalst__c, unitsst__c FROM QuoteToActualAux__c WHERE BatchJob__c = :BatchId];
		delete qaas;
		return new PageReference('/' + scenario.Id);
	}
	
	private void CalculateDiffData() {
														
		diffData = new Map<String, integer>();
		
		// PL005
		if (quoteData.productGmData.PL005.netRevenue.value == 0)
			diffData.put('PL005.netRevenue', 0);
		else
			diffData.put('PL005.netRevenue', Math.Round(100 * (actualData.productGmData.PL005.netRevenue.value - quoteData.productGmData.PL005.netRevenue.value) / quoteData.productGmData.PL005.netRevenue.value));
						
		if (quoteData.productGmData.PL005.costOfGoodsSold.value == 0)
			diffData.put('PL005.costOfGoodsSold', 0);
		else
			diffData.put('PL005.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL005.costOfGoodsSold.value - quoteData.productGmData.PL005.costOfGoodsSold.value) / quoteData.productGmData.PL005.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL005.gm.value == 0)
			diffData.put('PL005.gm', 0);
		else
			diffData.put('PL005.gm', Math.Round(100 * (actualData.productGmData.PL005.gm.value - quoteData.productGmData.PL005.gm.value) / quoteData.productGmData.PL005.gm.value));
						
		if (quoteData.productGmData.PL005.gmPercentage == 0)
			diffData.put('PL005.gmPercentage', 0);
		else
			diffData.put('PL005.gmPercentage', Math.Round(100 * (actualData.productGmData.PL005.gmPercentage - quoteData.productGmData.PL005.gmPercentage) / quoteData.productGmData.PL005.gmPercentage));
						
		if (quoteData.productGmData.PL005.gmSeeThrough.value == 0)
			diffData.put('PL005.gmSeeThrough', 0);
		else
			diffData.put('PL005.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL005.gmSeeThrough.value - quoteData.productGmData.PL005.gmSeeThrough.value) / quoteData.productGmData.PL005.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL005.gmSeeThroughPercentage == 0)
			diffData.put('PL005.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL005.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL005.gmSeeThroughPercentage - quoteData.productGmData.PL005.gmSeeThroughPercentage) / quoteData.productGmData.PL005.gmSeeThroughPercentage));
						
		// PL030
		if (quoteData.productGmData.PL030.netRevenue.value == 0)
			diffData.put('PL030.netRevenue', 0);
		else
			diffData.put('PL030.netRevenue', Math.Round(100 * (actualData.productGmData.PL030.netRevenue.value - quoteData.productGmData.PL030.netRevenue.value) / quoteData.productGmData.PL030.netRevenue.value));
						
		if (quoteData.productGmData.PL030.costOfGoodsSold.value == 0)
			diffData.put('PL030.costOfGoodsSold', 0);
		else
			diffData.put('PL030.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL030.costOfGoodsSold.value - quoteData.productGmData.PL030.costOfGoodsSold.value) / quoteData.productGmData.PL030.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL030.gm.value == 0)
			diffData.put('PL030.gm', 0);
		else
			diffData.put('PL030.gm', Math.Round(100 * (actualData.productGmData.PL030.gm.value - quoteData.productGmData.PL030.gm.value) / quoteData.productGmData.PL030.gm.value));
						
		if (quoteData.productGmData.PL030.gmPercentage == 0)
			diffData.put('PL030.gmPercentage', 0);
		else
			diffData.put('PL030.gmPercentage', Math.Round(100 * (actualData.productGmData.PL030.gmPercentage - quoteData.productGmData.PL030.gmPercentage) / quoteData.productGmData.PL030.gmPercentage));
						
		if (quoteData.productGmData.PL030.gmSeeThrough.value == 0)
			diffData.put('PL030.gmSeeThrough', 0);
		else
			diffData.put('PL030.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL030.gmSeeThrough.value - quoteData.productGmData.PL030.gmSeeThrough.value) / quoteData.productGmData.PL030.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL030.gmSeeThroughPercentage == 0)
			diffData.put('PL030.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL030.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL030.gmSeeThroughPercentage - quoteData.productGmData.PL030.gmSeeThroughPercentage) / quoteData.productGmData.PL030.gmSeeThroughPercentage));
						
		// PL032
		if (quoteData.productGmData.PL032.netRevenue.value == 0)
			diffData.put('PL032.netRevenue', 0);
		else
			diffData.put('PL032.netRevenue', Math.Round(100 * (actualData.productGmData.PL032.netRevenue.value - quoteData.productGmData.PL032.netRevenue.value) / quoteData.productGmData.PL032.netRevenue.value));
						
		if (quoteData.productGmData.PL032.costOfGoodsSold.value == 0)
			diffData.put('PL032.costOfGoodsSold', 0);
		else
			diffData.put('PL032.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL032.costOfGoodsSold.value - quoteData.productGmData.PL032.costOfGoodsSold.value) / quoteData.productGmData.PL032.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL032.gm.value == 0)
			diffData.put('PL032.gm', 0);
		else
			diffData.put('PL032.gm', Math.Round(100 * (actualData.productGmData.PL032.gm.value - quoteData.productGmData.PL032.gm.value) / quoteData.productGmData.PL032.gm.value));
						
		if (quoteData.productGmData.PL032.gmPercentage == 0)
			diffData.put('PL032.gmPercentage', 0);
		else
			diffData.put('PL032.gmPercentage', Math.Round(100 * (actualData.productGmData.PL032.gmPercentage - quoteData.productGmData.PL032.gmPercentage) / quoteData.productGmData.PL032.gmPercentage));
						
		if (quoteData.productGmData.PL032.gmSeeThrough.value == 0)
			diffData.put('PL032.gmSeeThrough', 0);
		else
			diffData.put('PL032.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL032.gmSeeThrough.value - quoteData.productGmData.PL032.gmSeeThrough.value) / quoteData.productGmData.PL032.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL032.gmSeeThroughPercentage == 0)
			diffData.put('PL032.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL032.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL032.gmSeeThroughPercentage - quoteData.productGmData.PL032.gmSeeThroughPercentage) / quoteData.productGmData.PL032.gmSeeThroughPercentage));
						
		// PL035
		if (quoteData.productGmData.PL035.netRevenue.value == 0)
			diffData.put('PL035.netRevenue', 0);
		else
			diffData.put('PL035.netRevenue', Math.Round(100 * (actualData.productGmData.PL035.netRevenue.value - quoteData.productGmData.PL035.netRevenue.value) / quoteData.productGmData.PL035.netRevenue.value));
						
		if (quoteData.productGmData.PL035.costOfGoodsSold.value == 0)
			diffData.put('PL035.costOfGoodsSold', 0);
		else
			diffData.put('PL035.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL035.costOfGoodsSold.value - quoteData.productGmData.PL035.costOfGoodsSold.value) / quoteData.productGmData.PL035.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL035.gm.value == 0)
			diffData.put('PL035.gm', 0);
		else
			diffData.put('PL035.gm', Math.Round(100 * (actualData.productGmData.PL035.gm.value - quoteData.productGmData.PL035.gm.value) / quoteData.productGmData.PL035.gm.value));
						
		if (quoteData.productGmData.PL035.gmPercentage == 0)
			diffData.put('PL035.gmPercentage', 0);
		else
			diffData.put('PL035.gmPercentage', Math.Round(100 * (actualData.productGmData.PL035.gmPercentage - quoteData.productGmData.PL035.gmPercentage) / quoteData.productGmData.PL035.gmPercentage));
						
		if (quoteData.productGmData.PL035.gmSeeThrough.value == 0)
			diffData.put('PL035.gmSeeThrough', 0);
		else
			diffData.put('PL035.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL035.gmSeeThrough.value - quoteData.productGmData.PL035.gmSeeThrough.value) / quoteData.productGmData.PL035.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL035.gmSeeThroughPercentage == 0)
			diffData.put('PL035.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL035.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL035.gmSeeThroughPercentage - quoteData.productGmData.PL035.gmSeeThroughPercentage) / quoteData.productGmData.PL035.gmSeeThroughPercentage));
						
		// PL040
		if (quoteData.productGmData.PL040_2.netRevenue.value == 0)
			diffData.put('PL040.netRevenue', 0);
		else
			diffData.put('PL040.netRevenue', Math.Round(100 * (actualData.productGmData.PL040_2.netRevenue.value - quoteData.productGmData.PL040_2.netRevenue.value) / quoteData.productGmData.PL040_2.netRevenue.value));
						
		if (quoteData.productGmData.PL040_2.costOfGoodsSold.value == 0)
			diffData.put('PL040.costOfGoodsSold', 0);
		else
			diffData.put('PL040.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL040_2.costOfGoodsSold.value - quoteData.productGmData.PL040_2.costOfGoodsSold.value) / quoteData.productGmData.PL040_2.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL040_2.gm.value == 0)
			diffData.put('PL040.gm', 0);
		else
			diffData.put('PL040.gm', Math.Round(100 * (actualData.productGmData.PL040_2.gm.value - quoteData.productGmData.PL040_2.gm.value) / quoteData.productGmData.PL040_2.gm.value));
						
		if (quoteData.productGmData.PL040_2.gmPercentage == 0)
			diffData.put('PL040.gmPercentage', 0);
		else
			diffData.put('PL040.gmPercentage', Math.Round(100 * (actualData.productGmData.PL040_2.gmPercentage - quoteData.productGmData.PL040_2.gmPercentage) / quoteData.productGmData.PL040_2.gmPercentage));
						
		if (quoteData.productGmData.PL040_2.gmSeeThrough.value == 0)
			diffData.put('PL040.gmSeeThrough', 0);
		else
			diffData.put('PL040.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL040_2.gmSeeThrough.value - quoteData.productGmData.PL040_2.gmSeeThrough.value) / quoteData.productGmData.PL040_2.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL040_2.gmSeeThroughPercentage == 0)
			diffData.put('PL040.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL040.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL040_2.gmSeeThroughPercentage - quoteData.productGmData.PL040_2.gmSeeThroughPercentage) / quoteData.productGmData.PL040_2.gmSeeThroughPercentage));
						
		// PL045
		if (quoteData.productGmData.PL045_7.netRevenue.value == 0)
			diffData.put('PL045.netRevenue', 0);
		else
			diffData.put('PL045.netRevenue', Math.Round(100 * (actualData.productGmData.PL045_7.netRevenue.value - quoteData.productGmData.PL045_7.netRevenue.value) / quoteData.productGmData.PL045_7.netRevenue.value));
						
		if (quoteData.productGmData.PL045_7.costOfGoodsSold.value == 0)
			diffData.put('PL045.costOfGoodsSold', 0);
		else
			diffData.put('PL045.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL045_7.costOfGoodsSold.value - quoteData.productGmData.PL045_7.costOfGoodsSold.value) / quoteData.productGmData.PL045_7.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL045_7.gm.value == 0)
			diffData.put('PL045.gm', 0);
		else
			diffData.put('PL045.gm', Math.Round(100 * (actualData.productGmData.PL045_7.gm.value - quoteData.productGmData.PL045_7.gm.value) / quoteData.productGmData.PL045_7.gm.value));
						
		if (quoteData.productGmData.PL045_7.gmPercentage == 0)
			diffData.put('PL045.gmPercentage', 0);
		else
			diffData.put('PL045.gmPercentage', Math.Round(100 * (actualData.productGmData.PL045_7.gmPercentage - quoteData.productGmData.PL045_7.gmPercentage) / quoteData.productGmData.PL045_7.gmPercentage));
						
		if (quoteData.productGmData.PL045_7.gmSeeThrough.value == 0)
			diffData.put('PL045.gmSeeThrough', 0);
		else
			diffData.put('PL045.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL045_7.gmSeeThrough.value - quoteData.productGmData.PL045_7.gmSeeThrough.value) / quoteData.productGmData.PL045_7.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL045_7.gmSeeThroughPercentage == 0)
			diffData.put('PL045.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL045.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL045_7.gmSeeThroughPercentage - quoteData.productGmData.PL045_7.gmSeeThroughPercentage) / quoteData.productGmData.PL045_7.gmSeeThroughPercentage));
						
		// PL048
		if (quoteData.productGmData.PL048.netRevenue.value == 0)
			diffData.put('PL048.netRevenue', 0);
		else
			diffData.put('PL048.netRevenue', Math.Round(100 * (actualData.productGmData.PL048.netRevenue.value - quoteData.productGmData.PL048.netRevenue.value) / quoteData.productGmData.PL048.netRevenue.value));
						
		if (quoteData.productGmData.PL048.costOfGoodsSold.value == 0)
			diffData.put('PL048.costOfGoodsSold', 0);
		else
			diffData.put('PL048.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL048.costOfGoodsSold.value - quoteData.productGmData.PL048.costOfGoodsSold.value) / quoteData.productGmData.PL048.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL048.gm.value == 0)
			diffData.put('PL048.gm', 0);
		else
			diffData.put('PL048.gm', Math.Round(100 * (actualData.productGmData.PL048.gm.value - quoteData.productGmData.PL048.gm.value) / quoteData.productGmData.PL048.gm.value));
						
		if (quoteData.productGmData.PL048.gmPercentage == 0)
			diffData.put('PL048.gmPercentage', 0);
		else
			diffData.put('PL048.gmPercentage', Math.Round(100 * (actualData.productGmData.PL048.gmPercentage - quoteData.productGmData.PL048.gmPercentage) / quoteData.productGmData.PL048.gmPercentage));
						
		if (quoteData.productGmData.PL048.gmSeeThrough.value == 0)
			diffData.put('PL048.gmSeeThrough', 0);
		else
			diffData.put('PL048.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL048.gmSeeThrough.value - quoteData.productGmData.PL048.gmSeeThrough.value) / quoteData.productGmData.PL048.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL048.gmSeeThroughPercentage == 0)
			diffData.put('PL048.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL048.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL048.gmSeeThroughPercentage - quoteData.productGmData.PL048.gmSeeThroughPercentage) / quoteData.productGmData.PL048.gmSeeThroughPercentage));
						
		// PL049
		if (quoteData.productGmData.PL049_50.netRevenue.value == 0)
			diffData.put('PL049.netRevenue', 0);
		else
			diffData.put('PL049.netRevenue', Math.Round(100 * (actualData.productGmData.PL049_50.netRevenue.value - quoteData.productGmData.PL049_50.netRevenue.value) / quoteData.productGmData.PL049_50.netRevenue.value));
						
		if (quoteData.productGmData.PL049_50.costOfGoodsSold.value == 0)
			diffData.put('PL049.costOfGoodsSold', 0);
		else
			diffData.put('PL049.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL049_50.costOfGoodsSold.value - quoteData.productGmData.PL049_50.costOfGoodsSold.value) / quoteData.productGmData.PL049_50.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL049_50.gm.value == 0)
			diffData.put('PL049.gm', 0);
		else
			diffData.put('PL049.gm', Math.Round(100 * (actualData.productGmData.PL049_50.gm.value - quoteData.productGmData.PL049_50.gm.value) / quoteData.productGmData.PL049_50.gm.value));
						
		if (quoteData.productGmData.PL049_50.gmPercentage == 0)
			diffData.put('PL049.gmPercentage', 0);
		else
			diffData.put('PL049.gmPercentage', Math.Round(100 * (actualData.productGmData.PL049_50.gmPercentage - quoteData.productGmData.PL049_50.gmPercentage) / quoteData.productGmData.PL049_50.gmPercentage));
						
		if (quoteData.productGmData.PL049_50.gmSeeThrough.value == 0)
			diffData.put('PL049.gmSeeThrough', 0);
		else
			diffData.put('PL049.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL049_50.gmSeeThrough.value - quoteData.productGmData.PL049_50.gmSeeThrough.value) / quoteData.productGmData.PL049_50.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL049_50.gmSeeThroughPercentage == 0)
			diffData.put('PL049.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL049.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL049_50.gmSeeThroughPercentage - quoteData.productGmData.PL049_50.gmSeeThroughPercentage) / quoteData.productGmData.PL049_50.gmSeeThroughPercentage));
						
		// PL060
		if (quoteData.productGmData.PL060_1.netRevenue.value == 0)
			diffData.put('PL060.netRevenue', 0);
		else
			diffData.put('PL060.netRevenue', Math.Round(100 * (actualData.productGmData.PL060_1.netRevenue.value - quoteData.productGmData.PL060_1.netRevenue.value) / quoteData.productGmData.PL060_1.netRevenue.value));
						
		if (quoteData.productGmData.PL060_1.costOfGoodsSold.value == 0)
			diffData.put('PL060.costOfGoodsSold', 0);
		else
			diffData.put('PL060.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL060_1.costOfGoodsSold.value - quoteData.productGmData.PL060_1.costOfGoodsSold.value) / quoteData.productGmData.PL060_1.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL060_1.gm.value == 0)
			diffData.put('PL060.gm', 0);
		else
			diffData.put('PL060.gm', Math.Round(100 * (actualData.productGmData.PL060_1.gm.value - quoteData.productGmData.PL060_1.gm.value) / quoteData.productGmData.PL060_1.gm.value));
						
		if (quoteData.productGmData.PL060_1.gmPercentage == 0)
			diffData.put('PL060.gmPercentage', 0);
		else
			diffData.put('PL060.gmPercentage', Math.Round(100 * (actualData.productGmData.PL060_1.gmPercentage - quoteData.productGmData.PL060_1.gmPercentage) / quoteData.productGmData.PL060_1.gmPercentage));
						
		if (quoteData.productGmData.PL060_1.gmSeeThrough.value == 0)
			diffData.put('PL060.gmSeeThrough', 0);
		else
			diffData.put('PL060.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL060_1.gmSeeThrough.value - quoteData.productGmData.PL060_1.gmSeeThrough.value) / quoteData.productGmData.PL060_1.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL060_1.gmSeeThroughPercentage == 0)
			diffData.put('PL060.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL060.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL060_1.gmSeeThroughPercentage - quoteData.productGmData.PL060_1.gmSeeThroughPercentage) / quoteData.productGmData.PL060_1.gmSeeThroughPercentage));
						
		// PL065
		if (quoteData.productGmData.PL065.netRevenue.value == 0)
			diffData.put('PL065.netRevenue', 0);
		else
			diffData.put('PL065.netRevenue', Math.Round(100 * (actualData.productGmData.PL065.netRevenue.value - quoteData.productGmData.PL065.netRevenue.value) / quoteData.productGmData.PL065.netRevenue.value));
						
		if (quoteData.productGmData.PL065.costOfGoodsSold.value == 0)
			diffData.put('PL065.costOfGoodsSold', 0);
		else
			diffData.put('PL065.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL065.costOfGoodsSold.value - quoteData.productGmData.PL065.costOfGoodsSold.value) / quoteData.productGmData.PL065.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL065.gm.value == 0)
			diffData.put('PL065.gm', 0);
		else
			diffData.put('PL065.gm', Math.Round(100 * (actualData.productGmData.PL065.gm.value - quoteData.productGmData.PL065.gm.value) / quoteData.productGmData.PL065.gm.value));
						
		if (quoteData.productGmData.PL065.gmPercentage == 0)
			diffData.put('PL065.gmPercentage', 0);
		else
			diffData.put('PL065.gmPercentage', Math.Round(100 * (actualData.productGmData.PL065.gmPercentage - quoteData.productGmData.PL065.gmPercentage) / quoteData.productGmData.PL065.gmPercentage));
						
		if (quoteData.productGmData.PL065.gmSeeThrough.value == 0)
			diffData.put('PL065.gmSeeThrough', 0);
		else
			diffData.put('PL065.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL065.gmSeeThrough.value - quoteData.productGmData.PL065.gmSeeThrough.value) / quoteData.productGmData.PL065.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL065.gmSeeThroughPercentage == 0)
			diffData.put('PL065.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL065.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL065.gmSeeThroughPercentage - quoteData.productGmData.PL065.gmSeeThroughPercentage) / quoteData.productGmData.PL065.gmSeeThroughPercentage));
						
		// PL070
		if (quoteData.productGmData.PL070.netRevenue.value == 0)
			diffData.put('PL070.netRevenue', 0);
		else
			diffData.put('PL070.netRevenue', Math.Round(100 * (actualData.productGmData.PL070.netRevenue.value - quoteData.productGmData.PL070.netRevenue.value) / quoteData.productGmData.PL070.netRevenue.value));
						
		if (quoteData.productGmData.PL070.costOfGoodsSold.value == 0)
			diffData.put('PL070.costOfGoodsSold', 0);
		else
			diffData.put('PL070.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL070.costOfGoodsSold.value - quoteData.productGmData.PL070.costOfGoodsSold.value) / quoteData.productGmData.PL070.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL070.gm.value == 0)
			diffData.put('PL070.gm', 0);
		else
			diffData.put('PL070.gm', Math.Round(100 * (actualData.productGmData.PL070.gm.value - quoteData.productGmData.PL070.gm.value) / quoteData.productGmData.PL070.gm.value));
						
		if (quoteData.productGmData.PL070.gmPercentage == 0)
			diffData.put('PL070.gmPercentage', 0);
		else
			diffData.put('PL070.gmPercentage', Math.Round(100 * (actualData.productGmData.PL070.gmPercentage - quoteData.productGmData.PL070.gmPercentage) / quoteData.productGmData.PL070.gmPercentage));
						
		if (quoteData.productGmData.PL070.gmSeeThrough.value == 0)
			diffData.put('PL070.gmSeeThrough', 0);
		else
			diffData.put('PL070.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL070.gmSeeThrough.value - quoteData.productGmData.PL070.gmSeeThrough.value) / quoteData.productGmData.PL070.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL070.gmSeeThroughPercentage == 0)
			diffData.put('PL070.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL070.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL070.gmSeeThroughPercentage - quoteData.productGmData.PL070.gmSeeThroughPercentage) / quoteData.productGmData.PL070.gmSeeThroughPercentage));
						
		// PL080
		if (quoteData.productGmData.PL080.netRevenue.value == 0)
			diffData.put('PL080.netRevenue', 0);
		else
			diffData.put('PL080.netRevenue', Math.Round(100 * (actualData.productGmData.PL080.netRevenue.value - quoteData.productGmData.PL080.netRevenue.value) / quoteData.productGmData.PL080.netRevenue.value));
						
		if (quoteData.productGmData.PL080.costOfGoodsSold.value == 0)
			diffData.put('PL080.costOfGoodsSold', 0);
		else
			diffData.put('PL080.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL080.costOfGoodsSold.value - quoteData.productGmData.PL080.costOfGoodsSold.value) / quoteData.productGmData.PL080.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL080.gm.value == 0)
			diffData.put('PL080.gm', 0);
		else
			diffData.put('PL080.gm', Math.Round(100 * (actualData.productGmData.PL080.gm.value - quoteData.productGmData.PL080.gm.value) / quoteData.productGmData.PL080.gm.value));
						
		if (quoteData.productGmData.PL080.gmPercentage == 0)
			diffData.put('PL080.gmPercentage', 0);
		else
			diffData.put('PL080.gmPercentage', Math.Round(100 * (actualData.productGmData.PL080.gmPercentage - quoteData.productGmData.PL080.gmPercentage) / quoteData.productGmData.PL080.gmPercentage));
						
		if (quoteData.productGmData.PL080.gmSeeThrough.value == 0)
			diffData.put('PL080.gmSeeThrough', 0);
		else
			diffData.put('PL080.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL080.gmSeeThrough.value - quoteData.productGmData.PL080.gmSeeThrough.value) / quoteData.productGmData.PL080.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL080.gmSeeThroughPercentage == 0)
			diffData.put('PL080.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL080.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL080.gmSeeThroughPercentage - quoteData.productGmData.PL080.gmSeeThroughPercentage) / quoteData.productGmData.PL080.gmSeeThroughPercentage));
						
		// PL084
		if (quoteData.productGmData.PL084.netRevenue.value == 0)
			diffData.put('PL084.netRevenue', 0);
		else
			diffData.put('PL084.netRevenue', Math.Round(100 * (actualData.productGmData.PL084.netRevenue.value - quoteData.productGmData.PL084.netRevenue.value) / quoteData.productGmData.PL084.netRevenue.value));
						
		if (quoteData.productGmData.PL084.costOfGoodsSold.value == 0)
			diffData.put('PL084.costOfGoodsSold', 0);
		else
			diffData.put('PL084.costOfGoodsSold', Math.Round(100 * (actualData.productGmData.PL084.costOfGoodsSold.value - quoteData.productGmData.PL084.costOfGoodsSold.value) / quoteData.productGmData.PL084.costOfGoodsSold.value));
		
		if (quoteData.productGmData.PL084.gm.value == 0)
			diffData.put('PL084.gm', 0);
		else
			diffData.put('PL084.gm', Math.Round(100 * (actualData.productGmData.PL084.gm.value - quoteData.productGmData.PL084.gm.value) / quoteData.productGmData.PL084.gm.value));
						
		if (quoteData.productGmData.PL084.gmPercentage == 0)
			diffData.put('PL084.gmPercentage', 0);
		else
			diffData.put('PL084.gmPercentage', Math.Round(100 * (actualData.productGmData.PL084.gmPercentage - quoteData.productGmData.PL084.gmPercentage) / quoteData.productGmData.PL084.gmPercentage));
						
		if (quoteData.productGmData.PL084.gmSeeThrough.value == 0)
			diffData.put('PL084.gmSeeThrough', 0);
		else
			diffData.put('PL084.gmSeeThrough', Math.Round(100 * (actualData.productGmData.PL084.gmSeeThrough.value - quoteData.productGmData.PL084.gmSeeThrough.value) / quoteData.productGmData.PL084.gmSeeThrough.value));
						
		if (quoteData.productGmData.PL084.gmSeeThroughPercentage == 0)
			diffData.put('PL084.gmSeeThroughPercentage', 0);
		else
			diffData.put('PL084.gmSeeThroughPercentage', Math.Round(100 * (actualData.productGmData.PL084.gmSeeThroughPercentage - quoteData.productGmData.PL084.gmSeeThroughPercentage) / quoteData.productGmData.PL084.gmSeeThroughPercentage));
			
			
		// REVENUE AND GROSS MARGIN
		if (quoteData.netRevenue.value == 0)
			diffData.put('netRevenue', 0);
		else
			diffData.put('netRevenue', Math.Round(100 * (actualData.netRevenue.value - quoteData.netRevenue.value) / quoteData.netRevenue.value));
						
		if (quoteData.costOfGoodsSold.value == 0)
			diffData.put('costOfGoodsSold', 0);
		else
			diffData.put('costOfGoodsSold', Math.Round(100 * (actualData.costOfGoodsSold.value - quoteData.costOfGoodsSold.value) / quoteData.costOfGoodsSold.value));
		
		if (quoteData.grossMargin.value == 0)
			diffData.put('grossMargin', 0);
		else
			diffData.put('grossMargin', Math.Round(100 * (actualData.grossMargin.value - quoteData.grossMargin.value) / quoteData.grossMargin.value));
						
		if (quoteData.grossMarginPercentage == 0)
			diffData.put('grossMarginPercentage', 0);
		else
			diffData.put('grossMarginPercentage', Math.Round(100 * (actualData.grossMarginPercentage - quoteData.grossMarginPercentage) / quoteData.grossMarginPercentage));
						
		if (quoteData.revenueModifier.value == 0)
			diffData.put('revenueModifier', 0);
		else
			diffData.put('revenueModifier', Math.Round(100 * (actualData.revenueModifier.value - quoteData.revenueModifier.value) / quoteData.revenueModifier.value));
						
		if (quoteData.costOfGoodsSoldSeeThrough.value == 0)
			diffData.put('costOfGoodsSoldSeeThrough', 0);
		else
			diffData.put('costOfGoodsSoldSeeThrough', Math.Round(100 * (actualData.costOfGoodsSoldSeeThrough.value - quoteData.costOfGoodsSoldSeeThrough.value) / quoteData.costOfGoodsSoldSeeThrough.value));
						
		if (quoteData.grossMarginSeeThrough.value == 0)
			diffData.put('grossMarginSeeThrough', 0);
		else
			diffData.put('grossMarginSeeThrough', Math.Round(100 * (actualData.grossMarginSeeThrough.value - quoteData.grossMarginSeeThrough.value) / quoteData.grossMarginSeeThrough.value));
				
		if (quoteData.grossMarginSeeThroughPercentage == 0)
			diffData.put('grossMarginSeeThroughPercentage', 0);
		else
			diffData.put('grossMarginSeeThroughPercentage', Math.Round(100 * (actualData.grossMarginSeeThroughPercentage - quoteData.grossMarginSeeThroughPercentage) / quoteData.grossMarginSeeThroughPercentage));
			
			
		// DIRECT LABOR COSTS AND CONTRIBUTION MARGIN
		if (quoteData.deliveryHours == 0)
			diffData.put('deliveryHours', 0);
		else
			diffData.put('deliveryHours', Math.Round(100 * (actualData.deliveryHours - quoteData.deliveryHours) / quoteData.deliveryHours));
						
		if (quoteData.deliveryHoursRate.value == 0)
			diffData.put('deliveryHoursRate', 0);
		else
			diffData.put('deliveryHoursRate', Math.Round(100 * (actualData.deliveryHoursRate.value - quoteData.deliveryHoursRate.value) / quoteData.deliveryHoursRate.value));
						
		if (quoteData.directCostDeliveryHrs.value == 0)
			diffData.put('directCostDeliveryHrs', 0);
		else
			diffData.put('directCostDeliveryHrs', Math.Round(100 * (actualData.directCostDeliveryHrs.value - quoteData.directCostDeliveryHrs.value) / quoteData.directCostDeliveryHrs.value));
						
		if (quoteData.shotHours == 0)
			diffData.put('shotHours', 0);
		else
			diffData.put('shotHours', Math.Round(100 * (actualData.shotHours - quoteData.shotHours) / quoteData.shotHours));
						
		if (quoteData.shotHoursRate.value == 0)
			diffData.put('shotHoursRate', 0);
		else
			diffData.put('shotHoursRate', Math.Round(100 * (actualData.shotHoursRate.value - quoteData.shotHoursRate.value) / quoteData.shotHoursRate.value));
						
		if (quoteData.directCostShotHrs.value == 0)
			diffData.put('directCostShotHrs', 0);
		else
			diffData.put('directCostShotHrs', Math.Round(100 * (actualData.directCostShotHrs.value - quoteData.directCostShotHrs.value) / quoteData.directCostShotHrs.value));
						
		if (quoteData.directCosts.value == 0)
			diffData.put('directCosts', 0);
		else
			diffData.put('directCosts', Math.Round(100 * (actualData.directCosts.value - quoteData.directCosts.value) / quoteData.directCosts.value));
						
		if (quoteData.contributionMargin.value == 0)
			diffData.put('contributionMargin', 0);
		else
			diffData.put('contributionMargin', Math.Round(100 * (actualData.contributionMargin.value - quoteData.contributionMargin.value) / quoteData.contributionMargin.value));
						
		if (quoteData.contributionMarginPercentage == 0)
			diffData.put('contributionMarginPercentage', 0);
		else
			diffData.put('contributionMarginPercentage', Math.Round(100 * (actualData.contributionMarginPercentage - quoteData.contributionMarginPercentage) / quoteData.contributionMarginPercentage));
						
		
		// SITE, REGION, AND COMPANY ALLOCATED INDIRECT COSTS
		// Direct Hours
		if (quoteData.totalHours.value == 0)
			diffData.put('totalHours', 0);
		else
			diffData.put('totalHours', Math.Round(100 * (actualData.totalHours.value - quoteData.totalHours.value) / quoteData.totalHours.value));
						
		if (quoteData.siteTotalHrs.value == 0)
			diffData.put('siteTotalHrs', 0);
		else
			diffData.put('siteTotalHrs', Math.Round(100 * (actualData.siteTotalHrs.value - quoteData.siteTotalHrs.value) / quoteData.siteTotalHrs.value));
						
		if (quoteData.totalHoursRate.value == 0)
			diffData.put('totalHoursRate', 0);
		else
			diffData.put('totalHoursRate', Math.Round(100 * (actualData.totalHoursRate.value - quoteData.totalHoursRate.value) / quoteData.totalHoursRate.value));
						
		if (quoteData.regionTotalHrs.value == 0)
			diffData.put('regionTotalHrs', 0);
		else
			diffData.put('regionTotalHrs', Math.Round(100 * (actualData.regionTotalHrs.value - quoteData.regionTotalHrs.value) / quoteData.regionTotalHrs.value));
						
		if (quoteData.rateTotalHrs.value == 0)
			diffData.put('rateTotalHrs', 0);
		else
			diffData.put('rateTotalHrs', Math.Round(100 * (actualData.rateTotalHrs.value - quoteData.rateTotalHrs.value) / quoteData.rateTotalHrs.value));
						
		if (quoteData.totalHoursRate.value + quoteData.rateTotalHrs.value == 0)
			diffData.put('totalHoursSum', 0);
		else
			diffData.put('totalHoursSum', Math.Round(100 * ((actualData.totalHoursRate.value + actualData.rateTotalHrs.value) - (quoteData.totalHoursRate.value + quoteData.rateTotalHrs.value)) / (quoteData.totalHoursRate.value + quoteData.rateTotalHrs.value)));
						
		if (quoteData.totalHrsTotal.value == 0)
			diffData.put('totalHrsTotal', 0);
		else
			diffData.put('totalHrsTotal', Math.Round(100 * (actualData.totalHrsTotal.value - quoteData.totalHrsTotal.value) / quoteData.totalHrsTotal.value));
						
		// Distance
		if (quoteData.distance.value == 0)
			diffData.put('distance', 0);
		else
			diffData.put('distance', Math.Round(100 * (actualData.distance.value - quoteData.distance.value) / quoteData.distance.value));
						
		if (quoteData.siteDistance.value == 0)
			diffData.put('siteDistance', 0);
		else
			diffData.put('siteDistance', Math.Round(100 * (actualData.siteDistance.value - quoteData.siteDistance.value) / quoteData.siteDistance.value));
						
		if (quoteData.distanceRate.value == 0)
			diffData.put('distanceRate', 0);
		else
			diffData.put('distanceRate', Math.Round(100 * (actualData.distanceRate.value - quoteData.distanceRate.value) / quoteData.distanceRate.value));
						
		if (quoteData.regionDistance.value == 0)
			diffData.put('regionDistance', 0);
		else
			diffData.put('regionDistance', Math.Round(100 * (actualData.regionDistance.value - quoteData.regionDistance.value) / quoteData.regionDistance.value));
						
		if (quoteData.rateDistance.value == 0)
			diffData.put('rateDistance', 0);
		else
			diffData.put('rateDistance', Math.Round(100 * (actualData.rateDistance.value - quoteData.rateDistance.value) / quoteData.rateDistance.value));
						
		if (quoteData.distanceRate.value + quoteData.rateDistance.value == 0)
			diffData.put('distanceSum', 0);
		else
			diffData.put('distanceSum', Math.Round(100 * ((actualData.distanceRate.value + actualData.rateDistance.value) - (quoteData.distanceRate.value + quoteData.rateDistance.value)) / (quoteData.distanceRate.value + quoteData.rateDistance.value)));
						
		if (quoteData.distanceTotal.value == 0)
			diffData.put('distanceTotal', 0);
		else
			diffData.put('distanceTotal', Math.Round(100 * (actualData.distanceTotal.value - quoteData.distanceTotal.value) / quoteData.distanceTotal.value));
						
		// Units
		if (quoteData.units.value == 0)
			diffData.put('units', 0);
		else
			diffData.put('units', Math.Round(100 * (actualData.units.value - quoteData.units.value) / quoteData.units.value));
						
		if (quoteData.siteUnits.value == 0)
			diffData.put('siteUnits', 0);
		else
			diffData.put('siteUnits', Math.Round(100 * (actualData.siteUnits.value - quoteData.siteUnits.value) / quoteData.siteUnits.value));
						
		if (quoteData.unitsRate.value == 0)
			diffData.put('unitsRate', 0);
		else
			diffData.put('unitsRate', Math.Round(100 * (actualData.unitsRate.value - quoteData.unitsRate.value) / quoteData.unitsRate.value));
						
		if (quoteData.regionUnits.value == 0)
			diffData.put('regionUnits', 0);
		else
			diffData.put('regionUnits', Math.Round(100 * (actualData.regionUnits.value - quoteData.regionUnits.value) / quoteData.regionUnits.value));
						
		if (quoteData.rateUnits.value == 0)
			diffData.put('rateUnits', 0);
		else
			diffData.put('rateUnits', Math.Round(100 * (actualData.rateUnits.value - quoteData.rateUnits.value) / quoteData.rateUnits.value));
						
		if (quoteData.unitsRate.value + quoteData.rateUnits.value == 0)
			diffData.put('unitsSum', 0);
		else
			diffData.put('unitsSum', Math.Round(100 * ((actualData.unitsRate.value + actualData.rateUnits.value) - (quoteData.unitsRate.value + quoteData.rateUnits.value)) / (quoteData.unitsRate.value + quoteData.rateUnits.value)));
						
		if (quoteData.unitsTotal.value == 0)
			diffData.put('unitsTotal', 0);
		else
			diffData.put('unitsTotal', Math.Round(100 * (actualData.unitsTotal.value - quoteData.unitsTotal.value) / quoteData.unitsTotal.value));
						
		// Invoices
		if (quoteData.invoices.value == 0)
			diffData.put('invoices', 0);
		else
			diffData.put('invoices', Math.Round(100 * (actualData.invoices.value - quoteData.invoices.value) / quoteData.invoices.value));
						
		if (quoteData.siteInvoices.value == 0)
			diffData.put('siteInvoices', 0);
		else
			diffData.put('siteInvoices', Math.Round(100 * (actualData.siteInvoices.value - quoteData.siteInvoices.value) / quoteData.siteInvoices.value));
						
		if (quoteData.invoicesRate.value == 0)
			diffData.put('invoicesRate', 0);
		else
			diffData.put('invoicesRate', Math.Round(100 * (actualData.invoicesRate.value - quoteData.invoicesRate.value) / quoteData.invoicesRate.value));
						
		if (quoteData.regionInvoices.value == 0)
			diffData.put('regionInvoices', 0);
		else
			diffData.put('regionInvoices', Math.Round(100 * (actualData.regionInvoices.value - quoteData.regionInvoices.value) / quoteData.regionInvoices.value));
						
		if (quoteData.rateInvoices.value == 0)
			diffData.put('rateInvoices', 0);
		else
			diffData.put('rateInvoices', Math.Round(100 * (actualData.rateInvoices.value - quoteData.rateInvoices.value) / quoteData.rateInvoices.value));
						
		if (quoteData.invoicesRate.value + quoteData.rateInvoices.value == 0)
			diffData.put('invoicesSum', 0);
		else
			diffData.put('invoicesSum', Math.Round(100 * ((actualData.invoicesRate.value + actualData.rateInvoices.value) - (quoteData.invoicesRate.value + quoteData.rateInvoices.value)) / (quoteData.invoicesRate.value + quoteData.rateInvoices.value)));
						
		if (quoteData.invoicesTotal.value == 0)
			diffData.put('invoicesTotal', 0);
		else
			diffData.put('invoicesTotal', Math.Round(100 * (actualData.invoicesTotal.value - quoteData.invoicesTotal.value) / quoteData.invoicesTotal.value));
						
		// Sales Revenue
		if (quoteData.indirectNetRevenue.value == 0)
			diffData.put('indirectNetRevenue', 0);
		else
			diffData.put('indirectNetRevenue', Math.Round(100 * (actualData.indirectNetRevenue.value - quoteData.indirectNetRevenue.value) / quoteData.indirectNetRevenue.value));
						
		if (quoteData.siteNetRev.value == 0)
			diffData.put('siteNetRev', 0);
		else
			diffData.put('siteNetRev', Math.Round(100 * (actualData.siteNetRev.value - quoteData.siteNetRev.value) / quoteData.siteNetRev.value));
						
		if (quoteData.netRevenueRate.value == 0)
			diffData.put('netRevenueRate', 0);
		else
			diffData.put('netRevenueRate', Math.Round(100 * (actualData.netRevenueRate.value - quoteData.netRevenueRate.value) / quoteData.netRevenueRate.value));
						
		if (quoteData.regionNetRev.value == 0)
			diffData.put('regionNetRev', 0);
		else
			diffData.put('regionNetRev', Math.Round(100 * (actualData.regionNetRev.value - quoteData.regionNetRev.value) / quoteData.regionNetRev.value));
						
		if (quoteData.rateNetRevenue.value == 0)
			diffData.put('rateNetRevenue', 0);
		else
			diffData.put('rateNetRevenue', Math.Round(100 * (actualData.rateNetRevenue.value - quoteData.rateNetRevenue.value) / quoteData.rateNetRevenue.value));
						
		if (quoteData.netRevenueRate.value + quoteData.rateNetRevenue.value == 0)
			diffData.put('netRevenueSum', 0);
		else
			diffData.put('netRevenueSum', Math.Round(100 * ((actualData.netRevenueRate.value + actualData.rateNetRevenue.value) - (quoteData.netRevenueRate.value + quoteData.rateNetRevenue.value)) / (quoteData.netRevenueRate.value + quoteData.rateNetRevenue.value)));
						
		if (quoteData.netRevTotal.value == 0)
			diffData.put('netRevTotal', 0);
		else
			diffData.put('netRevTotal', Math.Round(100 * (actualData.netRevTotal.value - quoteData.netRevTotal.value) / quoteData.netRevTotal.value));
						
		// Totals
		if (quoteData.total2.value == 0)
			diffData.put('total2', 0);
		else
			diffData.put('total2', Math.Round(100 * (actualData.total2.value - quoteData.total2.value) / quoteData.total2.value));
		
		if (quoteData.total3.value == 0)
			diffData.put('total3', 0);
		else
			diffData.put('total3', Math.Round(100 * (actualData.total3.value - quoteData.total3.value) / quoteData.total3.value));
		
		if (quoteData.total5.value == 0)
			diffData.put('total5', 0);
		else
			diffData.put('total5', Math.Round(100 * (actualData.total5.value - quoteData.total5.value) / quoteData.total5.value));
		
		
		// EBITA
		if (quoteData.ebitWith.value == 0)
			diffData.put('ebitWith', 0);
		else
			diffData.put('ebitWith', Math.Round(100 * (actualData.ebitWith.value - quoteData.ebitWith.value) / quoteData.ebitWith.value));
			
		if (quoteData.ebitPercentageWith == 0)
			diffData.put('ebitPercentageWith', 0);
		else
			diffData.put('ebitPercentageWith', Math.Round(100 * (actualData.ebitPercentageWith - quoteData.ebitPercentageWith) / quoteData.ebitPercentageWith));
	}
	
	public static testmethod void test1() {
		
		List<Quote__c> quotes = [SELECT Id, Customer__c FROM Quote__c WHERE Customer__r.Account_Group__c != '0002 Ship-to party' LIMIT 1];
		for (Quote__c quote : quotes) {
			ApexPages.currentPage().getParameters().put('id', quote.Id);
			QuoteToActualReport qar = new QuoteToActualReport();
			integer year = Date.today().year();
			qar.dummyContact1.BirthDate = Date.newInstance(year - 1, 1, 1);
			qar.dummyContact2.BirthDate = Date.newInstance(year - 1, 12, 31);
			Test.startTest();
			qar.Regenerate();
			Test.stopTest();
			qar.CheckBatchStatus();
			qar.CancelBatch();
		}
		quotes = [SELECT Id, Customer__c, Customer__r.Account_Group__c FROM Quote__c WHERE Customer__r.Account_Group__c = '0002 Ship-to party' LIMIT 4];
		for (Quote__c quote : quotes) {
			ApexPages.currentPage().getParameters().put('id', quote.Id);
			QuoteToActualReport qar = new QuoteToActualReport();
			integer year = Date.today().year();
			qar.dummyContact1.BirthDate = Date.newInstance(year - 1, 1, 1);
			qar.dummyContact2.BirthDate = Date.newInstance(year - 1, 12, 31);
			qar.dummyQuote.Customer__c = quote.Customer__c;
			qar.Regenerate();
		}
		
	}

}