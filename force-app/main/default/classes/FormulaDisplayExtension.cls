public with sharing class FormulaDisplayExtension {
	private Formula__c formula;
	public List<Formula_Line_Item__c> items {get; set;}
	public Double formulaValue {get; set;}
	
	public String sectionTitle {
		get{
			return String.format(System.Label.Detail_Title, new List<String>{Schema.SObjectType.Formula__c.getLabel()});
		}
	}
	
	public String parsedFormula {
		get {
			return FormulaProcessor.parse(this.formula.Formula_Text__c, this.items);
		}
	}
	
	public FormulaDisplayExtension(ApexPages.StandardController con) {
		this.formula = (Formula__c)con.getRecord();
		this.items = [Select Id, Formula_Component__r.Name, Formula_Component__r.Value__c, Formula_Component__r.Group__c From Formula_Line_Item__c where Formula__c = :this.formula.Id];
		formulaValue = -1;
			try {
				formulaValue = FormulaProcessor.process(this.formula.Formula_Text__c, this.items);
			} catch (Exception e) {
				formulaValue = 0.00;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Formula_Display_Corrupted));
			}		
	}
	
	public class FormulaException extends Exception {}
	
}