trigger CostDriverEntryTrigger on Cost_Driver_Entry__c (after insert) {
    if (!COPAAllocator.isRunning)
        COPAAllocator.execute(Trigger.new);
}