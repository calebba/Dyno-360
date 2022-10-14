trigger ProjectsSummary on Vertiba_Project_Role__c (after insert, after update, after delete) {

    /*Set<Id> affectedProjectIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Vertiba_Project_Role__c pr : Trigger.New)
            if (!affectedProjectIds.contains(pr.Project__c))
                affectedProjectIds.add(pr.Project__c);
    } else {
        for (Vertiba_Project_Role__c pr : Trigger.Old)
            if (!affectedProjectIds.contains(pr.Project__c))
                affectedProjectIds.add(pr.Project__c);
    }
    
    List<Vertiba_Project__c> affectedProjects = [SELECT Id FROM Vertiba_Project__c WHERE Id in :affectedProjectIds];
    
    List<AggregateResult> affectedProjectRoles = [SELECT Project__c Project__c,
                                                         SUM(Budget_At_Completion__c) Budget_At_Completion__c,
                                                         SUM(Budgeted_Hours_Remaining__c) Budgeted_Hours_Remaining,
                                                         SUM(Cost_of_Hours_Worked__c) Cost_of_Hours_Worked__c,
                                                         SUM(Cost_of_Remaining_Effort__c) Cost_of_Remaining_Effort,
                                                         SUM(Cost_to_Complete__c) Cost_to_Complete__c,
                                                         SUM(Cost_Variance__c) Cost_Variance__c,
                                                         SUM(Hour_Budget__c) Hours_Budgeted__c,
                                                         SUM(Hours_Burned__c) Hours_Burned__c,
                                                         SUM(Planned_Hours__c) Hours_Remaining__c,
                                                         SUM(Hour_Variance__c) Hour_Variance__c
                                                    FROM Vertiba_Project_Role__c
                                                   WHERE Project__c in :affectedProjectIds GROUP BY Project__c];
    Map<Id, AggregateResult> prMap = new Map<Id, AggregateResult>();
    for (AggregateResult ar : affectedProjectRoles)
        prMap.put((Id)ar.get('Project__c'), ar);
    
    for (Vertiba_Project__c affectedProject : affectedProjects) {
    
        if (prMap.containsKey(affectedProject.Id)) {
            AggregateResult ar = prMap.get(affectedProject.Id);
            affectedProject.Budget_At_Completion__c = (decimal)ar.get('Budget_At_Completion__c');
            affectedProject.Budgeted_Hours_Remaining__c = (decimal)ar.get('Budgeted_Hours_Remaining');
            affectedProject.Cost_of_Hours_Worked__c = (decimal)ar.get('Cost_of_Hours_Worked__c');
            affectedProject.Cost_of_Remaining_Effort__c = (decimal)ar.get('Cost_of_Remaining_Effort');
            affectedProject.Cost_to_Complete__c = (decimal)ar.get('Cost_to_Complete__c');
            affectedProject.Cost_Variance__c = (decimal)ar.get('Cost_Variance__c');
            affectedProject.Hours_Budgeted__c = (decimal)ar.get('Hours_Budgeted__c');
            affectedProject.Hours_Burned__c = (decimal)ar.get('Hours_Burned__c');
            affectedProject.Hours_Remaining__c = (decimal)ar.get('Hours_Remaining__c');
            affectedProject.Hour_Variance__c = (decimal)ar.get('Hour_Variance__c');
        } else {
            affectedProject.Budget_At_Completion__c = 0;
            affectedProject.Budgeted_Hours_Remaining__c = 0;
            affectedProject.Cost_of_Hours_Worked__c = 0;
            affectedProject.Cost_of_Remaining_Effort__c = 0;
            affectedProject.Cost_to_Complete__c = 0;
            affectedProject.Cost_Variance__c = 0;
            affectedProject.Hours_Budgeted__c = 0;
            affectedProject.Hours_Burned__c = 0;
            affectedProject.Hours_Remaining__c = 0;
            affectedProject.Hour_Variance__c = 0;
        }
    
    }
 
    update affectedProjects;*/ 

}