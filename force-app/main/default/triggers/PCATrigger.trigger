trigger PCATrigger on PCA__c (after insert) {
	if (!ExpenseAllocator.isRunning)
		ExpenseAllocator.allocate(Trigger.new);
}