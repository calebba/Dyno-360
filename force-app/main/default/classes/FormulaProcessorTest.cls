@isTest
public class FormulaProcessorTest {
  
  @isTest static void testFormulaProcessing() {
  	System.assertEquals(4, FormulaProcessor.process('2+2'));
	System.assertEquals(0, FormulaProcessor.process('2-2'));
	System.assertEquals(1, FormulaProcessor.process('2/2'));
	System.assertEquals(4, FormulaProcessor.process('2*2'));
	System.assertEquals(31.32, FormulaProcessor.process('23.32+(4*2)'));
	System.assertEquals(823.32, FormulaProcessor.process('(23.32+(4*200))'));
	System.assertEquals(0, FormulaProcessor.process('0+0'));
	System.assertEquals(0, FormulaProcessor.process('2/0'));
	System.assertEquals(8, FormulaProcessor.process('2+2+2+2'));
	System.assertEquals(-4, FormulaProcessor.process('1-2-3'));
	System.assertEquals(2, FormulaProcessor.process('-1+3'));
	System.assertEquals(4, FormulaProcessor.process('2*(-1+3)'));
	System.assertEquals(-8, FormulaProcessor.process('2*(-1+-3)'));
	System.assertEquals(6, FormulaProcessor.process('2*(-1*-3)'));
	System.assertEquals(1.0, FormulaProcessor.process('3*(-1/-3)'));//0.9999999999999999
	System.assertEquals(9, FormulaProcessor.process('3/(-1/-3)'));
	System.assertEquals(10, FormulaProcessor.process('3/(-1/-3)+1'));
	System.assertEquals(7, FormulaProcessor.process('3+(-1*-3)+1'));
	System.assertEquals(1200003, FormulaProcessor.process('3+(-3*-200000)*2'));
	System.assertEquals(100000, FormulaProcessor.process('100000+100000-100000'));
	System.assertEquals(100000, FormulaProcessor.process('100000+100000+-100000'));
	System.assertEquals(0, FormulaProcessor.process(''));
  }
  
  @isTest static void testFormulaProcessingWithComponents() {
  	// Create 3 Formula Components
  	List<Formula_Component__c> components = new List<Formula_Component__c>();
  	components.add(new Formula_Component__c(Name='Component1', Value__c=1));
  	components.add(new Formula_Component__c(Name='Component2', Value__c=2));
  	components.add(new Formula_Component__c(Name='Component3', Value__c=3));
  	insert components;
  	
  	// Create Material
  	Material_Item__c material = TestUtils.createMaterialItem('TEST', 'TEST', 'TEST', null);
  	
  	// Create Formula
  	Formula__c formula = new Formula__c(Name='Test Formula', Material_Item__c=material.Id, Formula_Text__c='Component1+Component2+Component3');
  	insert formula;
  	
  	// Link them
  	List<Formula_Line_Item__c> lineItems = new List<Formula_Line_Item__c>();
  	for (Formula_Component__c component : components) {
  		lineItems.add(new Formula_Line_Item__c(Formula__c=formula.Id, Formula_Component__c=component.Id));
  	} 	
  	insert lineItems;
  	lineItems = [Select Formula_Component__r.Name, Formula_Component__r.Value__c From Formula_Line_Item__c where Id in :lineItems];
  	
  	// Parse Formula text
  	System.assertEquals(6, FormulaProcessor.process(formula.Formula_Text__c, lineItems));
  	
  	System.assertEquals(6, FormulaProcessor.process(formula));
  }
}