public with sharing class FormulaEditExtension {
	public List<Formula_Line_Item__c> lineItems {get; private set;}
	public String sectionTitle {
		get{ 
			return String.format(System.Label.Edit_Title, new List<String>{Schema.SObjectType.Formula__c.getLabel()});
		}
	}
	
	public String sectionSubtitle {
		get{
			return String.format(System.Label.New_Title, new List<String>{Schema.SObjectType.Formula__c.getLabel()});
		}
	}
	
	public FormulaEditExtension(ApexPages.StandardController con) {
		this.lineItems = [Select Formula_Component__r.Name,  Formula_Component__r.Group__c,  Formula_Component__r.Value__c from Formula_Line_Item__c where Formula__c = :con.getId()];	
	}
	
}