trigger ContractActionRenew on Contract_Action__c (after update) {
	
	List<Contract_Action__c> newCas = new List<Contract_Action__c>();
	for (Contract_Action__c ca1 : Trigger.old) {
		Contract_Action__c ca2 = Trigger.newMap.get(ca1.Id);
		if (ca1.Status__c == 'Pending' && ca2.Status__c == 'Complete') {
			Contract_Action__c newCa = new Contract_Action__c();
			newCa.Dyno_Nobel_Contract__c = ca2.Dyno_Nobel_Contract__c;
			newCa.Status__c = 'Pending';
				newCa.Action_Type__c = ca2.Action_Type__c;
			newCa.Adjustment_Frequency__c = ca2.Adjustment_Frequency__c;
			newCa.Last_Update_Date__c = null;
			newCa.Start_Date__c = ca2.Start_Date__c;
			newCa.Valid_To_Date__c = ca2.Valid_To_Date__c;
			if (ca2.Adjustment_Frequency__c == 'Monthly')
				newCa.Next_Due_Date__c = ca2.Next_Due_Date__c.addMonths(1);
			if (ca2.Adjustment_Frequency__c == 'Quarterly')
				newCa.Next_Due_Date__c = ca2.Next_Due_Date__c.addMonths(3);
			if (ca2.Adjustment_Frequency__c == 'Annual')
				newCa.Next_Due_Date__c = ca2.Next_Due_Date__c.addYears(1);
					
			if (newCa.Valid_To_Date__c >= newCa.Next_Due_Date__c)
				newCas.add(newCa);
			
		}
	}
	if (newCas.size() > 0)
		insert newCas;
}