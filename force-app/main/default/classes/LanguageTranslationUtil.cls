public with sharing class LanguageTranslationUtil {
	
	public static String queryLanguage(String incomingAccountId){
		Account currentAccount = [SELECT Id, Name, Language__c FROM Account WHERE Id=: incomingAccountId];
		return currentAccount.Language__c;	
	}
}