Public with sharing class DNAConsultPageController {
	/*
        Public Date startdate {get;set;}
        Public Date enddate {get;set;}
        Public String startdatestring {get;set;}
        Public String enddatestring {get;set;}
        Public Account Accountname {get;set;}
        Public String Shipto {get;set;}
        Public String Soldto {get;set;}
        Public String acctid {get;set;}
        Boolean dateerror {get;set;}
        Public double technicalfee1 {get;set;}
        Public double technicalfee2 {get;set;}
        Public double technicalfee3 {get;set;}
        Public double trainingfee1 {get;set;}
        Public double trainingfee2 {get;set;}
        Public double trainingfee3 {get;set;}
        Public double officefee1 {get;set;}
        Public double officefee2 {get;set;}
        Public double officefee3 {get;set;}
        Public double travelfee1 {get;set;}
        Public double travelfee2 {get;set;}
        Public double travelfee3 {get;set;}
        Public double technicalhr1 {get;set;}
        Public double technicalhr2 {get;set;}
        Public double technicalhr3 {get;set;}
        Public double traininghr1 {get;set;}
        Public double traininghr2 {get;set;}
        Public double traininghr3 {get;set;}
        Public double officehr1 {get;set;}
        Public double officehr2 {get;set;}
        Public double officehr3 {get;set;}
        Public double totaltechnical {get;set;}
        Public double totaltraining {get;set;}
        Public double totaloffice {get;set;}
        Public double travelhr1 {get;set;}
        Public double travelhr2 {get;set;}
        Public double travelhr3 {get;set;}
        Public double totaltravel {get;set;}
        Public double grandtotal {get;set;}
        Public String consultantlist {get;set;}
        Public String consultantdescription {get;set;}
        Public Consulting_Services__c cs {get;set;}
        Public boolean displaydata {get;set;}
        Public Date todaydate {get;set;}
        Public String todaydatestring {get;set;}
        Public Set<String> conset {get;set;}
        Public String displaycurrency {get;set;}
        Public Set<String> ponums {get;set;}
        Public String ponumstring {get;set;}
   */     
        
    public DNAConsultPageController() {
    	/*
        Id id = ApexPages.currentPage().getParameters().get('id');
        if(id!=null) {
            Accountname = [select Id, Name, ParentId, CURRENCYISOCODE, Parent.SAP_Account_Number__c, Parent.Name, SAP_Account_Number__c from Account where Id = :id];
        }
        cs = new Consulting_Services__c();
        /*
        /* cs.ReportStartDate__c = System.today();LEVAC COMMENT
        cs.ReportEndDate__c = System.today();LEVAC COMMENT */
        
        /*
        cs.Full_Account_Name__c = Accountname.id;
        Shipto = Accountname.SAP_Account_Number__c;
        Soldto = Accountname.Parent.SAP_Account_Number__c;
        displaydata = cs.DisplayReportInfo__c;
        todaydate = Date.Today();
        todaydatestring = String.valueOf(todaydate);
        displaycurrency = String.valueof(Accountname.CURRENCYISOCODE);
        */
    }
    
    public PageReference redirect() {
        
        PageReference newPage;
        /*
        if(Accountname!=null)
        {       
                
            newPage = page.DNAConsultPageMain;
            newPage.getParameters().put('id',Accountname.Id);  
           
            
        } else {
            newPage = Page.DNAConsultPageMain;
        }
        
        
        return newPage.setRedirect(true);
        */
        return newPage.setRedirect(true);
    } 
    
    public PageReference generatereport(){
 /*   
        List<Consulting_Services__c> cslist = new List<Consulting_Services__c>();
        Set<String> conset = new Set<String>();
        startdate = cs.ReportStartDate__c;
        enddate = cs.ReportEndDate__c;
        startdatestring = String.valueof(startdate);
        enddatestring = String.valueof(enddate);
        Set<String> ponums = new Set<String>();
        cslist = [SELECT id, Consultant_Name__c, Consulting_Description__c, Consultant_Type__c, Date_Of_Project__c, DisplayReportInfo__c, Full_Account_Name__c, Full_Account_Name__r.SAP_Account_Number__c, Office_Based_Services_Bill_Amount__c
                    , On_Site_Technical_Services_Hours__c, Travel_Hours__c, On_Site_Training_Services_Hours__c, Office_Based_Services_Hours__c, Customer_PO__c
                    , On_Site_Technical_Services_Bill_Amount__c, On_Site_Training_Services_Bill_Amount__c, Total_Travel_Expenses__c FROM Consulting_Services__c WHERE (Full_Account_Name__r.SAP_Account_Number__c = :shipto AND Date_Of_Project__c >= :cs.ReportStartDate__c AND Date_Of_Project__c <= :cs.ReportEndDate__c) ORDER BY Date_Of_Project__c];
        System.Debug('test:' + cslist.size());
        cs.DisplayReportInfo__c = true;
        ponumstring = '';
        displaydata = true;
        technicalfee1 = 0;
        technicalfee2 = 0;
        technicalfee3 = 0;
        trainingfee1 = 0;
        trainingfee2 = 0;
        trainingfee3 = 0;
        officefee1 = 0;
        officefee2 = 0;
        officefee3 = 0;
        travelfee1 = 0;
        travelfee2 = 0;
        travelfee3 = 0;
        technicalhr1 = 0;
        technicalhr2 = 0;
        technicalhr3 = 0;
        traininghr1 = 0;
        traininghr2 = 0;
        traininghr3 = 0;
        officehr1 = 0;
        officehr2 = 0;
        officehr3 = 0;
        travelhr1 = 0;
        travelhr2 = 0;
        travelhr3 = 0;
        totaltechnical = 0;
        totaltraining = 0;
        totaloffice = 0;
        totaltravel = 0;
        grandtotal = 0;
        consultantlist = '';
        consultantdescription = '';
        string tempvar = '';
        
        for (Consulting_Services__c css : cslist){
            if (css.Consultant_Type__c == 'Junior Consultant'){
                technicalfee1 += css.On_Site_Technical_Services_Bill_Amount__c;
                trainingfee1 += css.On_Site_Training_Services_Bill_Amount__c;
                officefee1 += css.Office_Based_Services_Bill_Amount__c;
                travelfee1 += css.Total_Travel_Expenses__c;
                technicalhr1 += (css.On_Site_Technical_Services_Hours__c==Null?0:css.On_Site_Technical_Services_Hours__c) ;
                traininghr1 += (css.On_Site_Training_Services_Hours__c==Null?0:css.On_Site_Training_Services_Hours__c);
                officehr1 += (css.Office_Based_Services_Hours__c==Null?0:css.Office_Based_Services_Hours__c);
                travelhr1 += (css.Travel_Hours__c==Null?0:css.Travel_Hours__c);
                
            } else if (css.Consultant_Type__c == 'Senior Consultant') {
                technicalfee3 += css.On_Site_Technical_Services_Bill_Amount__c;
                trainingfee3 += css.On_Site_Training_Services_Bill_Amount__c;
                officefee3 += css.Office_Based_Services_Bill_Amount__c;
                travelfee3 += css.Total_Travel_Expenses__c;
                technicalhr3 += (css.On_Site_Technical_Services_Hours__c==Null?0:css.On_Site_Technical_Services_Hours__c) ;
                traininghr3 += (css.On_Site_Training_Services_Hours__c==Null?0:css.On_Site_Training_Services_Hours__c);
                officehr3 += (css.Office_Based_Services_Hours__c==Null?0:css.Office_Based_Services_Hours__c);
                travelhr3 += (css.Travel_Hours__c==Null?0:css.Travel_Hours__c);
            } else {
                technicalfee2 += css.On_Site_Technical_Services_Bill_Amount__c;
                trainingfee2 += css.On_Site_Training_Services_Bill_Amount__c;
                officefee2 += css.Office_Based_Services_Bill_Amount__c;
                travelfee2 += css.Total_Travel_Expenses__c;
                technicalhr2 += (css.On_Site_Technical_Services_Hours__c==Null?0:css.On_Site_Technical_Services_Hours__c) ;
                traininghr2 += (css.On_Site_Training_Services_Hours__c==Null?0:css.On_Site_Training_Services_Hours__c);
                officehr2 += (css.Office_Based_Services_Hours__c==Null?0:css.Office_Based_Services_Hours__c);
                travelhr2 += (css.Travel_Hours__c==Null?0:css.Travel_Hours__c);
            }
           
           totaltechnical += css.On_Site_Technical_Services_Bill_Amount__c;
           totaltraining += css.On_Site_Training_Services_Bill_Amount__c;
           totaloffice += css.Office_Based_Services_Bill_Amount__c;
           totaltravel += css.Total_Travel_Expenses__c;
           grandtotal = grandtotal + css.On_Site_Technical_Services_Bill_Amount__c + css.On_Site_Training_Services_Bill_Amount__c + css.Office_Based_Services_Bill_Amount__c + css.Total_Travel_Expenses__c;
           if (!conset.contains(css.Consultant_Name__c)) {
               conset.add(String.valueof(css.Consultant_Name__c));
               if (consultantlist == '') {
                   consultantlist = css.Consultant_Name__c;
               } else {
                   tempvar = css.Consultant_Name__c;
                   consultantlist = consultantlist + ', ' + tempvar;
               }
               
           }
           
           if (!ponums.contains(css.Customer_PO__c)) {
           		ponums.add(css.Customer_PO__c);
           		if (ponumstring == ''){
           			ponumstring = css.Customer_PO__c;
           		} else {
           			ponumstring = ponumstring + ', ' + css.Customer_PO__c;
           		}
           		
           }
           System.debug('TTEST: ' + consultantlist);
           consultantdescription = consultantdescription + '   (' + String.valueof(css.Date_Of_Project__c) + '): ' + css.Consulting_Description__c + '  ';
        
        }
        System.debug('TTEST');
        System.debug(conset);       
        Return null;
        */
        Return null;
    }
    
    public void validatedates() {
    	/*
        dateerror=false;
        displaydata = false;
        if (cs.ReportEndDate__c != Null && cs.ReportStartDate__c != Null) {
            if(cs.ReportEndDate__c < cs.ReportStartDate__c){
            dateerror=true;
            cs.ReportEndDate__c.addError('End Date cannot be before Start Date');
        }
      }*/
    }
    
    public void refreshaccountinfo() {
    	/*
        Accountname = [select Id, Name, ParentId, CURRENCYISOCODE, Parent.SAP_Account_Number__c, Parent.Name, SAP_Account_Number__c from Account where Id = :cs.Full_Account_Name__c];
        Shipto = Accountname.SAP_Account_Number__c;
        Soldto = Accountname.Parent.SAP_Account_Number__c;
        displaydata = false;
        */
    }
    
    Public pagereference generatepdf() {
    	/*
        return page.DNAConsultingInvoice;
        */
        PageReference newPage;
        return newPage.setRedirect(true);
    }
     
     
  
    

}