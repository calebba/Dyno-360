trigger SetPREndDate on Vertiba_Project_Role__c (before insert, before update) {
   
    for (Vertiba_Project_Role__c line : Trigger.new)
    	line.End_Date__c = null;
    /*for (Vertiba_Project_Role__c line : Trigger.new) {
        if (line.Calc_Type__c == 'End Date') {
            if (line.Start_Date__c == null || line.Utilization__c == null || line.Budgeted_Hours_Remaining__c == null) {
                line.End_Date__c = null;
                continue;
            }
                
            Date currDate = line.Start_Date__c;
            if (currDate < Date.today())
                currDate = Date.today();
            Decimal NoDays = Math.Ceil(line.Budgeted_Hours_Remaining__c / (8 * line.Utilization__c / 100));
            currDate = currDate.addDays(-1);
           
            while (NoDays > 0) {
                currDate = currDate.addDays(1);
                integer diff = currDate.daysbetween(currDate.toStartOfWeek());
                if (diff != 0 && diff != -6)
                    NoDays --;
            }
            line.End_Date__c = currDate;
        } else {
            if (line.Start_Date__c == null || line.End_Date__c == null || line.Hour_Budget__c == null) {
                line.Utilization__c = null;
                continue;
            }
            
            Date currDate = line.Start_Date__c;
            if (currDate < Date.today())
                currDate = Date.today();
            Integer NoDays = 1;
            while (currDate < line.End_Date__c) {
                currDate = currDate.addDays(1);
                integer diff = currDate.daysbetween(currDate.toStartOfWeek());
                if (diff != 0 && diff != -6)
                    NoDays ++;
            }
            
            line.Utilization__c = line.Budgeted_Hours_Remaining__c * 100 / (noDays * 8);
            if (line.Utilization__c > 999)
                line.Utilization__c = 999;
            if (line.Utilization__c < 0)
                line.Utilization__c = 0;
        }
    }*/
 
}