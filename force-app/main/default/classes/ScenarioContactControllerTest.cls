@isTest
public class ScenarioContactControllerTest {

    @isTest static void scenarioContactControllerTest() {
		Test.startTest();
		Opportunity testOpp 	 = TestUtils.createOppty('TO001', null, 'Prospecting');
		Quote__c testQuote		 = TestUtils.createQuote(testOpp);
		
		Test.setCurrentPage(new PageReference(Page.CloneQuotePage.getUrl() + '?Id=' + testQuote.Id));
		ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
		ScenarioContactController SCC = new ScenarioContactController(controller);
		PageReference testLoc 		= SCC.saveScenarioContact();
		PageReference retScenario 	= SCC.returnToScenario();
		
		Opportunity testOpp2 	 = TestUtils.createOppty('TO0012', null, 'Prospecting');
		Quote__c testQuote2		 = TestUtils.createQuote(testOpp2);
		Test.setCurrentPage(new PageReference(Page.CloneQuotePage.getUrl() + '?Id=' + testQuote2.Id));
		ApexPages.StandardController controller2 = new ApexPages.StandardController(testQuote2);
		ScenarioContactController SCC2 = new ScenarioContactController(controller2);
		PageReference testLoc2 		= SCC2.saveAndNewScenarioContact();
	}
}