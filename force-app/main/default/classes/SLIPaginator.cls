public with sharing class SLIPaginator implements ObjectPaginatorListener {
	
	public List<SLIQuickAddController.ScenarioLine> slList {get; set;}
	public ObjectPaginator paginator {get; set;}
	
	public SLIPaginator() {
		Integer perPage = Integer.valueOf(System.Label.QuickAddPerPage);
		slList = new List<SLIQuickAddController.ScenarioLine>();
		paginator = new ObjectPaginator(perPage, this);	
	}
	
	public void setRecords(List<SLIQuickAddController.ScenarioLine> lines) {
		paginator.setRecords(lines);
	}
	
	public void handlePageChange(List<Object> lines) {
		slList.clear();
		if(lines != null){
			for(Object sl : lines){
				slList.add((SLIQuickAddController.ScenarioLine)sl);
			}
		}	
	}
	
	public List<SLIQuickAddController.ScenarioLine> getAll() {
		return (List<SLIQuickAddController.ScenarioLine>) paginator.all;
	}
	
	public PageReference changePer() {
		String ruleID = ApexPages.currentPage().getParameters().get('ruleID');
		for(SLIQuickAddController.ScenarioLine sl : slList) {
			System.debug('SLI ID:' + sl.Id);
			if(sl.id == ruleID) {
				if(sl.sli.Per__c == null || sl.sli.Per__c < 1) {
					sl.sli.Per__c = 1;
				}
				sl.sli.Target_Price__c = sl.sli.Base_Target__c / (sl.per / sl.sli.Per__c);
				sl.sli.Floor_Price__c = sl.sli.Base_Floor__c / (sl.per / sl.sli.Per__c);
				sl.sli.Cost__c = sl.sli.Base_Cost__c / (1 / sl.sli.Per__c);
				sl.sli.Cost_See_Through__c = sl.sli.Base_Cost_ST__c / (1 / sl.sli.Per__c);
				sl.sli.Actual_Price__c = sl.sli.Target_Price__c;
			}		
		}
		return null;
	}
	
	public PageReference obtainAUMForSelectedStandard() {
		Id matId = (Id) ApexPages.currentPage().getParameters().get('materialID');
		
		for(SLIQuickAddController.ScenarioLine sl : slList) {
			if(sl.isSelected && sl.miRecord.Id == matId && sl.aumRecords.size() == 0) {
				sl.availableUoMs.clear();
				for(Alternate_Unit_of_Measure__c currAum : [SELECT Id, Name, X__c, Y__c, AUn__c, BUn__c, Material_Item__c  FROM Alternate_Unit_of_Measure__c WHERE Material_Item__c = :matId AND BUn__c = :sl.uom order by AUn__c]) {
					sl.availableUoMs.add(new SelectOption(currAum.AUn__c, currAum.AUn__c));
					sl.aumRecords.add(currAum);
				}
				sl.sli.UoM__c = sl.uom;
			}
		} 
		
		return null;
	}
	
	public PageReference performConversion() {
		String ruleID = ApexPages.currentPage().getParameters().get('ruleID');
		String prevUoM = ApexPages.currentPage().getParameters().get('prevUoM');
		Boolean found = false;
		for(SLIQuickAddController.ScenarioLine sl : slList) {
			if(sl.id == ruleID) {
				//Old UoM -> Base UoM	
				for(Alternate_Unit_of_Measure__c currAum : sl.aumRecords) {
					if(currAum.AUn__c == prevUoM && sl.uom == currAum.BUn__c) {
						sl.sli.Base_Target__c = convertQuantity(sl.sli.Base_Target__c, currAum, false);
						sl.sli.Base_Floor__c = convertQuantity(sl.sli.Base_Floor__c, currAum, false);
						sl.sli.Base_Cost__c = convertQuantity(sl.sli.Base_Cost__c, currAum, false);
						sl.sli.Base_Cost_ST__c = convertQuantity(sl.sli.Base_Cost_ST__c, currAum, false);
						found = true;
					}	
				}
				if(!found) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bad conversion 1!'));
				}
				//Base UoM -> New UoM
				for(Alternate_Unit_of_Measure__c currAum : sl.aumRecords) {
					if(currAum.AUn__c == sl.sli.UoM__c && currAum.BUn__c == sl.uom) {
						found = true;
						sl.sli.Base_Floor__c = convertQuantity(sl.sli.Base_Floor__c, currAum, true);
						sl.sli.Base_Target__c = convertQuantity(sl.sli.Base_Target__c, currAum, true);
						sl.sli.Base_Cost__c = convertQuantity(sl.sli.Base_Cost__c, currAum, true);
						sl.sli.Base_Cost_ST__c = convertQuantity(sl.sli.Base_Cost_ST__c, currAum, true);						
					}
				}
				if(!found) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bad conversion 2!'));
				}				
				sl.sli.Target_Price__c = (sl.sli.Base_Target__c / (sl.per / sl.sli.Per__c)).setScale(2);
				sl.sli.Floor_Price__c = (sl.sli.Base_Floor__c / (sl.per / sl.sli.Per__c)).setScale(2);
				sl.sli.Cost__c = sl.sli.Base_Cost__c / (1/sl.sli.Per__c);
				sl.sli.Cost_See_Through__c = sl.sli.Base_Cost_ST__c / (1/sl.sli.Per__c);
				sl.sli.Actual_Price__c = sl.sli.Target_Price__c.setScale(2);
			}
		}
		
		return null;
	}
	
	private static Decimal convertQuantity(Decimal quant, Alternate_Unit_of_Measure__c aum, Boolean toAum) {
		if(toAum) {
			return quant * (aum.X__c / aum.Y__c);
		}
		return quant * (aum.Y__c / aum.X__c);
	}	
}