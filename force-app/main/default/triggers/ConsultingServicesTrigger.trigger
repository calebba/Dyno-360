trigger ConsultingServicesTrigger on Consulting_Services__c (before insert, before update) {
     
    for (Consulting_Services__c cs : trigger.new) {
        Account a = [SELECT Id, Name, CURRENCYISOCODE From Account WHERE id = :cs.Full_Account_Name__c];
        cs.CURRENCYISOCODE = a.CURRENCYISOCODE;
    
    }
}