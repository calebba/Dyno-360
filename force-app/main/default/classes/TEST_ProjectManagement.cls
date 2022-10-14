/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TEST_ProjectManagement {

    static testMethod void CreateNewDefect() {
    	Project__c testProject = new Project__c();
    	testProject.Name = 'Test Project';
    	testProject.Project_Type__c = 'New Development';
    	testProject.Priority__c = 'Important';
    	testProject.Stage__c = 'Planning';
    	testProject.Explanation_of_Problem__c = 'Test explanation';
    	testProject.Solution__c = 'Test solution';
    	testProject.Start_Date__c = Date.today();
    	testProject.Go_Live_Date__c = Date.today().addDays(30);
    	
    	insert testProject;
    	
        Defect__c testDefect = new Defect__c();
        
        PageReference pr = Page.pm_Defect;
        Test.setCurrentPage(pr);
        
        ApexPages.currentPage().getParameters().put('project',testProject.Id);
        
        ApexPages.StandardController scon = new ApexPages.StandardController(testDefect);
        pm_DefectController conExt = new pm_DefectController(scon);
        
        //populate our defect
        conExt.defect.Defect_Description__c = 'This is my test defect with a great description';
        conExt.defect.Assigned_to__c = UserInfo.getUserId();
        conExt.defect.Status__c = 'Not Started';
        conExt.defect.Due_Date__c = Date.today().addDays(30);
        
        //and make a comment
        conExt.newComment.Defect_Comment__c = 'This is a really important comment.';
        
        conExt.ExtSave();
    }
    
    static testMethod void EditExistingDefect() {
    	Project__c testProject = new Project__c();
    	testProject.Name = 'Test Project';
    	testProject.Project_Type__c = 'New Development';
    	testProject.Priority__c = 'Important';
    	testProject.Stage__c = 'Planning';
    	testProject.Explanation_of_Problem__c = 'Test explanation';
    	testProject.Solution__c = 'Test solution';
    	testProject.Start_Date__c = Date.today();
    	testProject.Go_Live_Date__c = Date.today().addDays(30);
    	
    	insert testProject;
    	
        Defect__c testDefect = new Defect__c();
        //populate our defect
        testDefect.Defect_Description__c = 'This is my test defect with a great description';
        testDefect.Assigned_to__c = UserInfo.getUserId();
        testDefect.Status__c = 'Not Started';
        testDefect.Due_Date__c = Date.today().addDays(30);
        testDefect.Project__c = testProject.Id;
        
        insert testDefect;
        
        PageReference pr = Page.pm_Defect;
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController scon = new ApexPages.StandardController(testDefect);
        pm_DefectController conExt = new pm_DefectController(scon);
        
        //edit our defect description a little
        conExt.MakeDescriptionEditable();
        conExt.defect.Defect_Description__c = conExt.defect.Defect_Description__c + ' a little change';
        
        //make a comment
        conExt.newComment.Defect_Comment__c = 'This is a really important comment.';
        
        conExt.ExtSave();
    }
    
    static testMethod void EditExistingDefect_SaveException() {
    	Project__c testProject = new Project__c();
    	testProject.Name = 'Test Project';
    	testProject.Project_Type__c = 'New Development';
    	testProject.Priority__c = 'Important';
    	testProject.Stage__c = 'Planning';
    	testProject.Explanation_of_Problem__c = 'Test explanation';
    	testProject.Solution__c = 'Test solution';
    	testProject.Start_Date__c = Date.today();
    	testProject.Go_Live_Date__c = Date.today().addDays(30);
    	
    	insert testProject;
    	
        Defect__c testDefect = new Defect__c();
        //populate our defect
        testDefect.Defect_Description__c = 'This is my test defect with a great description';
        testDefect.Assigned_to__c = UserInfo.getUserId();
        testDefect.Status__c = 'Not Started';
        testDefect.Due_Date__c = Date.today().addDays(30);
        testDefect.Project__c = testProject.Id;
        
        insert testDefect;
        
        PageReference pr = Page.pm_Defect;
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController scon = new ApexPages.StandardController(testDefect);
        pm_DefectController conExt = new pm_DefectController(scon);
        
        //edit our defect description a little
        conExt.MakeDescriptionEditable();
        conExt.defect.Defect_Description__c = conExt.defect.Defect_Description__c + ' a little change';
        
        //make a comment
        conExt.newComment.Defect_Comment__c = 'This is a really important comment.';
        
        //mark as test so we throw an error
        conExt.IS_TEST = true;
        
        conExt.ExtSave();
    }
}