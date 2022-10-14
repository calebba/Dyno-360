/**
 * The batch job which rotates the encryption key for the a set of records and fields dictated by the user.
 */

global with sharing class SLICloneBatch implements Database.Batchable<SObject> {
	
	private Quote__c newScenario;
	private List<Quote_Line_Item__c> extendedSLIs;
	private Id customerId;
	private Id companyId;
	private String customerGroup; 
	private Id oldScenarioId;
	private String toEmail;
	private String url;
	private String name;
	private String failureMessage;
	private SLIAdjustments adjustments;
	
	global SLICloneBatch(String nameParam, String urlParam, String toEmailParam, Quote__c newScenarioParam, Id oldScenarioIdParam, List<Quote_Line_Item__c> extendedSLIsParam, Id customerIdParam, Id companyIdParam, String customerGroupParam, SLIAdjustments adjs) {
		newScenario = newScenarioParam;
		extendedSLIs = extendedSLIsParam;
		customerId = customerIdParam;
		companyId = companyIdParam;
		customerGroup = customerGroupParam;
		oldScenarioId = oldScenarioIdParam;
		toEmail = toEmailParam;
		url = urlParam;
		name = nameParam;
		failureMessage = '';
		adjustments = adjs;
	} 
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
			return Database.getQueryLocator('Select PHL1__c, Extended__c, CurrencyIsoCode, Quote__c, Actual_Price__c, Available_Credit_Limit__c, Avg_Sell_Price__c, Bundled_Flag__c, Calculated_Monthly_Purchases__c, Credit_Limit__c, Description__c, Floor_Price__c, Formula__c, Formula_Flag__c, MFN_Flag__c, Material_Item__c, Monthly_Purchases__c, Notify_Credit__c, Per__c, Percent__c, Sales_Site__c, Price_Valid_From__c, Price_Valid_To__c, Pricing_Rule__c, Quantity__c, Reason__c, Source_Sales_Site__c, Target_Price__c, UoM__c, Volume_Based__c, Country__c, Cost__c, Discount_Surcharge__c, Discount_Surcharge_Terms__c, Discount_Amount__c, AUn__c, Adder_Notes__c, Substitution__c, Substitution_Comments__c, Is_Bundled__c, Cost_See_Through__c, Product_Description__c From Quote_Line_Item__c WHERE Quote__c = :oldScenarioId');
	}
	
	global void execute(Database.BatchableContext bc, List<SObject> scope) {
		List<Quote_Line_Item__c> sliScope = (List<Quote_Line_Item__c>) scope;
		List<Id> materialIds = new List<Id>();
		for(Quote_Line_Item__c sli : sliScope) {
			materialIds.add(sli.Material_Item__c);
		}
		
			
		try {
			QuoteUtil.cloneStandardSLI(newScenario, sliScope, materialIds, customerId, companyId, customerGroup, adjustments);
		} catch(Exception e) {
			failureMessage += e.getMessage();
		}
	}
	
	global void finish(Database.BatchableContext bc) {
		newScenario.Being_Cloned__c = false;
		update newScenario;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new List<String>{toEmail});
		mail.setSenderDisplayName('Batch Processing');
		if(failureMessage == '') {
			mail.setSubject(System.label.BC_Email_Success_Subject);
			mail.setHtmlBody(System.label.BC_Email_Success_Body + ' <a href=\'' + url + '\'>' + name + '</a>');
		} else {
			mail.setSubject(System.label.BC_Email_Failure_Subject);
			mail.setHtmlBody(System.label.BC_Email_Failure_Body + ' ' + failureMessage + '<br /> Scenario: <a href=\'' + url + '\'>' + name + '</a>');			
		}
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	testMethod static void testSLICloneBatch() {
		SLICloneBatch slicb = new SLIcloneBatch('a','b','c', new Quote__c(), null, new List<Quote_Line_Item__c>(), null, null, 'd', null);
		System.assertNotEquals(null, slicb);
	}
	
}