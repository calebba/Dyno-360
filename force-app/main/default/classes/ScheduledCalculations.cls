global class ScheduledCalculations implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        String mail = [SELECT Email
            FROM User
            WHERE Id = :UserInfo.getUserId()].Email;
        
        if (Test.isrunningtest())
            id batchinstanceidt = database.executeBatch(new BatchForScheduled(mail), 200);
        else
            id batchinstanceid = database.executeBatch(new BatchForScheduled(mail), 1);
        
        
    }    
    
    static testmethod  void testExecute() {
        ScheduledCalculations sc = new ScheduledCalculations();
       // Integer before = [SELECT COUNT() FROM Material_Cost__c];
        
        Test.startTest();
        sc.execute(null);
        Test.stopTest();
        
       /* Integer after = [SELECT COUNT() FROM Material_Cost__c];
        System.assert(before >= after);*/
    }
}