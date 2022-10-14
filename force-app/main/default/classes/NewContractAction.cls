public with sharing class NewContractAction {

    public Contract_Action__c newAction { get; set; }
    public integer step { get; set; }
    String cid;
    Dyno_Nobel_Contract__c dnc;
    
    public NewContractAction(ApexPages.StandardController con) {
        
        cid = ApexPages.currentPage().getParameters().get('CF00NV0000000aLwr_lkid');
        if (cid == null) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No contract id specified.'));
            return;
        }
        dnc = new Dyno_Nobel_Contract__c();
        dnc = [SELECT id, Name, Project_Name__c from Dyno_Nobel_Contract__c Where id = :cid];
        newAction = new Contract_Action__c();
        newAction.Dyno_Nobel_Contract__c = cid;
        newAction.Status__c = 'Pending';
        newAction.Start_Date__c = Date.today();
        newAction.Due_Date_Reminder_Assignee__c = UserInfo.getUserId();
        newAction.Valid_To_Date_Reminder_Assignee__c = UserInfo.getUserId();
        newAction.Due_Date_Reminder__c = false;
        newAction.Valid_To_Date_Reminder__c = false;
        newAction.Due_Date_Reminder_Date__c = System.Today();
        newAction.Valid_To_Date_Reminder_Date__c = System.Today();
        
        step = 1;
    }
    
    public boolean Step1 { get { return step == 1; } }
    public boolean Step2 { get { return step == 2; } }
    public boolean Step3 { get { return step == 3; } }
    public boolean Step4 { get { return step == 4; } }
    
    public void NextStep() {
        if (step < 4)
            step++;
    }
    
    public void PrevStep() {
        if (step > 1)
            step--;
    }
    
    public PageReference Save() {
        try {
            insert newAction;
            //check and create tasks based on the entered info.
            List<Task> newtasks = new List<Task>();
            string subline;
            if (newAction.Action_Type__c != Null&&newAction.Adjustment_Frequency__c!=Null){
                subline = newAction.Action_Type__c + ': ' + newAction.Adjustment_Frequency__c;
            } else if (newAction.Action_Type__c != Null){
                subline = newAction.Action_Type__c;
            } else if (newAction.Adjustment_Frequency__c!=Null){
                subline = newAction.Adjustment_Frequency__c;
            } else {
                subline = 'Need Subject value';
            }
            if (newAction.Valid_To_Date_Reminder__c == true&&newAction.Valid_To_Date_Reminder_Date__c!=Null&&newAction.Valid_To_Date_Reminder_Assignee__c!=Null){
                Task newtask;
                newtask = new Task();
                newTask.Subject = subline;
                newTask.Status = 'Not Started';
                newTask.Description = 'Task associated to Contract: ' + dnc.Name + '(' + dnc.Project_Name__c + ')';
                newTask.OwnerId = newAction.Valid_To_Date_Reminder_Assignee__c;
                newTask.ActivityDate = newAction.Valid_To_Date_Reminder_Date__c;
                newTask.WhatId = newAction.Dyno_Nobel_Contract__c;
                newtasks.add(newTask);
            }
            if (newAction.Due_Date_Reminder__c == true&&newAction.Due_Date_Reminder_Date__c!=Null&&newAction.Due_Date_Reminder_Assignee__c!=Null){
                Task newtask;
                newtask = new Task();
                newTask.Subject = subline;
                newTask.Status = 'Not Started';
                newTask.Description = 'Task associated to Contract: ' + dnc.Name + '(' + dnc.Project_Name__c + ')';
                newTask.OwnerId = newAction.Due_Date_Reminder_Assignee__c;
                newTask.ActivityDate = newAction.Due_Date_Reminder_Date__c;
                newTask.WhatId = newAction.Dyno_Nobel_Contract__c;
                newtasks.add(newTask);
            }
            if (newtasks.size() > 0){
                Insert newtasks;
            }
            
            return new PageReference('/' + newAction.Dyno_Nobel_Contract__c);
        } catch (Exception ex) {
            return null;
        }
    }
    
    public PageReference Cancel() {
        return new PageReference('/' + newAction.Dyno_Nobel_Contract__c);
    }
    
    public testMethod static void test1() {
        
        Account a = new Account();
        a.Name = 'Lucian447745';
        insert a;
        
        Dyno_Nobel_Contract__c dnc = new Dyno_Nobel_Contract__c();
        dnc.Commencement_Date__c = Date.today();
        dnc.Contract_Expires_on__c = Date.today();
        dnc.Customer_Name__c = 'Lucian448567';
        dnc.Distributors_JVs__c = 'Lucian446734';
        //dnc.Hedging_Remedy_Clause__c = 'Lucian319845';
        dnc.How_Could_we_have_done_Better__c = 'Lucian100548';
        //dnc.Maximum_Amount__c = 100;
        //dnc.Minimum_Amount__c = 10;
        dnc.What_did_we_learn__c = 'Lucian000429';
        dnc.Services_to_Be_Supplied__c = 'Lucian332478';
        dnc.Term_In_Months__c = 12;
        //dnc.Parent_Company__c = a.Id;
        insert dnc;
        
        ApexPages.currentPage().getParameters().put('CF00NV0000000aLwr_lkid', dnc.Id);
        
        NewContractAction nca = new NewContractAction(new ApexPages.StandardController(new Contract_Action__c()));
        boolean test;
        test = nca.Step1;
        test = nca.Step2;
        test = nca.Step3;
        test = nca.Step4;
        nca.NextStep(); 
        nca.PrevStep();
        nca.Cancel();
        nca.Save();
        
        List<Contract_Action__c> cas = [SELECT Id FROM Contract_Action__c WHERE Dyno_Nobel_Contract__c = :dnc.Id];
    }

}