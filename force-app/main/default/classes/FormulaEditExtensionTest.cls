@isTest
public class FormulaEditExtensionTest {

    @isTest static void FormulaEditExtensionTest() {
		Test.startTest();
		Sales_Site__c testSite = TestUtils.createPlant('TP381');
		Material_Item__c matItem = TestUtils.createMaterialItem('TMI378', 'TMI387', 'PL001', testSite.Id);
		
		Formula__c f = new Formula__c();
		f.Material_Item__c = matItem.Id;
		f.Name = 'FORMULA FAILURE';
		insert f;
		//Test.setCurrentPage(new PageReference(Page.CreateNewScenarioVersionPage.getUrl() + '?Id=' + testQuote.Id));
		ApexPages.StandardController controller = new ApexPages.StandardController(f);
		FormulaEditExtension FDE = new FormulaEditExtension(controller);
		String Test5 = FDE.sectionTitle;
		String Test6 = FDE.sectionSubtitle;
		Test.stopTest();
	}
}