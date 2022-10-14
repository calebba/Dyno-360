public class EBITBatchPageController {
	public boolean GeneratePressed { get; set; }
	public Id batchId;
	public boolean BatchStarted { get; set; }
	public String batchMessage { get; set; }
	
	public String accountIdsString;
	public String plantString;
	public List<String> plants;
	public String shipToIdsString;
	public String sitesIdsListString;
	public Date dateFrom;
	public Date dateTo;
	public String currentCurrency;
	
	public List<PandLData> plDataReportShipToList { get; set; }
	public List<EBITData.EBITDataHelper> edhShipToList = new List<EBITData.EBITDataHelper>();
	public String currentLanguage { get; set; }
	
	public void EBITBatchPageControllerS() {
		
		accountIdsString = ApexPages.currentPage().getParameters().get('accountIds');
		List<Id> accountIdsList = accountIdsString.split(',',-1);
		Set<Id> accountIds = new Set<Id>();
		for (Id a : accountIdsList) {
			accountIds.add(a);
		}
		shipToIdsString = ApexPages.currentPage().getParameters().get('shipToIds');
		List<Id> shipToIdsList = new List<Id>();
		if (shipToIdsString != null && shipToIdsString != '') {
			shipToIdsList = shipToIdsString.trim().split(',',-1);
		}
		System.debug('shipToIdsList:::' + shipToIdsList);
		System.debug('shipToIdsList.size():::' + shipToIdsList.size());
		Set<Id> shipToIds = new Set<Id>();
		if (shipToIdsList.size() > 0) {
			for (Id s : shipToIdsList) {
				shipToIds.add(s);
			}
		}
		System.debug('shipToIds:::' + shipToIds);
		sitesIdsListString = ApexPages.currentPage().getParameters().get('sitesIdsList');
		System.debug('sitesIdsList:::' + sitesIdsListString);
		List<Id> sitesIdsList = new List<Id>();
		if (sitesIdsListString != null && sitesIdsListString != '') {
			sitesIdsList = sitesIdsListString.trim().split(',',-1);
		}
		Set<Id> sitesIds = new Set<Id>();
		if (sitesIdsList.size() > 0) {
			for (Id s : sitesIdsList) {
				sitesIds.add(s);
			}
		}
		//Set<Id> originalSitesIds = sitesIds;
		
		dateFrom = date.valueOf(ApexPages.currentPage().getParameters().get('dateFrom'));
		dateTo = date.valueOf(ApexPages.currentPage().getParameters().get('dateTo'));
		currentCurrency = ApexPages.currentPage().getParameters().get('currentCurrency');
		
		List<AggregateResult> shipToPlants = [SELECT Customer__c cust, Plant__c pl, Sales_Site__c ss FROM COPA_Aggregate__c 
												WHERE Customer__c IN :shipToIds AND Sales_Site__c IN :sitesIds AND (Current_Month__c >= :dateFrom AND Current_Month__c <= :dateTo)
												GROUP BY Customer__c, Plant__c, Sales_Site__c];
		System.debug('shipToPlants::::' + shipToPlants);
		//shipTo report
		EBITData.EBITDataHelper edhShipTo;
		PandLData plDataReportShipTo;
		Set<Id> shipToIdSet;
		
		Set<Id> shipToUsedIdSet = new Set<Id>();
		for (AggregateResult a : shipToPlants) {
			edhShipTo = new EBITData.EBITDataHelper();
			shipToIdSet = new Set<Id>();
			shipToIdSet.add((String)a.get('cust'));
			shipToUsedIdSet.add((String)a.get('cust'));
			edhShipTo.accountIds = shipToIdSet;
			edhShipTo.plant = (String)a.get('pl');
			//edhShipTo.salesGroup = (String)a.get('sg');
			sitesIds = new Set<Id>();
			sitesIds.add((String)a.get('ss'));
			edhShipTo.siteIds = sitesIds;
			edhShipTo.dateFrom = dateFrom;
			edhShipTo.dateTo = dateTo;
			edhShipTo.currencyUsed = currentCurrency;
			edhShipTo.isMainReport = false;
			edhShipToList.add(edhShipTo);
		}
		System.debug('edhShipToList:::' + edhShipToList.size());
		shipToIds.removeAll(shipToUsedIdSet);
		
		for (String s : shipToIds) {
			edhShipTo = new EBITData.EBITDataHelper();
			shipToIdSet = new Set<Id>();
			shipToIdSet.add(s);
			edhShipTo.accountIds = shipToIdSet;
			edhShipTo.plant = null;
			//edhShipTo.salesGroup = null;
			edhShipTo.siteIds = new Set<Id>();
			edhShipTo.dateFrom = dateFrom;
			edhShipTo.dateTo = dateTo;
			edhShipTo.currencyUsed = currentCurrency;
			edhShipTo.isMainReport = false;
			edhShipToList.add(edhShipTo);
		}
		//generate Batch
		Generate(edhShipToList);
	}
	
	 public void Generate(List<EBITData.EBITDataHelper> edhShipToList) {
		
		EBITShipToReportBatch batch = new EBITShipToReportBatch(edhShipToList);
		batchId = Database.executeBatch(batch, 1);
		BatchStarted = true;
		batchMessage = 'Report 0% completed';
		
		GeneratePressed = true;
	}
	
	public PageReference CheckBatch() {
		
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
										 TotalJobItems, CreatedBy.Email 
										 FROM AsyncApexJob WHERE Id = :batchId];
		if (a.Status != 'Completed' && (!Test.isRunningTest())) {
			if (a.Status == 'Failed' || a.Status == 'Aborted') {
				batchMessage = 'Report has failed or was aborted by user.';
				return null;
			}
			if (a.TotalJobItems == 0) {
				batchMessage = 'Report 0% completed';
			} else {
				batchMessage = 'Report ' + (a.JobItemsProcessed * 100 / a.TotalJobItems)
									+ '% completed';
			}
			return null;
		}
		
		if (a.Status == 'Completed' && batchMessage != 'Report 100% completed') {
			batchMessage = 'Report 100% completed';
			return null;
		}
		
		return setParameters(Page.EBITOutputExcel);
		
	}
	
	public PageReference CancelBatch() {
		List<COPA_ShipTos_Temp__c> auxs = [SELECT Id FROM COPA_ShipTos_Temp__c
												 WHERE BatchId__c = :batchId];
		if (auxs.size() > 0)
			delete auxs;
		BatchStarted = false;
		GeneratePressed = false;
		return Page.EBITReporting;
	}
	
	public PageReference setParameters(PageReference p) {
		PageReference pageRef = p;
		
		if (pageRef != null) {
			pageRef.getParameters().put('batchId', batchId);
			pageRef.getParameters().put('accountIds', accountIdsString);
			pageRef.getParameters().put('shipToIds', shipToIdsString);
			pageRef.getParameters().put('sitesIdsList', sitesIdsListString);
			pageRef.getParameters().put('dateFrom', string.valueOf(dateFrom));
			pageRef.getParameters().put('dateTo', string.valueOf(dateTo));
			pageRef.getParameters().put('currentCurrency', currentCurrency);
		}
		return pageRef;
	}
}