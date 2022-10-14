@isTest
private class Test_SetPREndDate_Trigger {
	

  static testMethod void testSetEndDateInsert(){ 
      
      Account myAccount = new Account();
      myAccount.Name = 'New Account';
      insert myAccount;
         
      Date myDate = Date.today().toStartOfWeek().adddays(7);
         
      //Get the Standard PriceBook and make sure it is active
      PriceBook2 pb = [select Id from PriceBook2 where IsStandard=True];
      pb.IsActive=true;
      update pb;
         
      Product2 myProduct = new Product2();
      myProduct.Name = 'My product';
      insert myProduct;
         
      //Create pricebook entries for the products
      List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
      pbEntryList.add(new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=myProduct.Id, UnitPrice=100.00, IsActive=true));
         
      insert pbEntryList;
         
      Vertiba_Project__c myOppty = new Vertiba_Project__c();
      myOppty.Name = 'My Opportunity';
      myOppty.Account__c = myAccount.Id; 
      myOppty.Start_Date__c = myDate - 1;
      myOppty.End_Date__c = myDate + 2;
      insert myOppty;
         
      Vertiba_Project_Role__c myOpptyLineItem = new Vertiba_Project_Role__c();
      myOpptyLineItem.Start_Date__c = Date.today().toStartOfWeek().adddays(7);//date.newInstance(2011, 9, 12);
      myOpptyLineItem.Project__c = myOppty.Id;
      myOpptyLineItem.Hour_Budget__c = 80;
      myOpptyLineItem.BillRate__c = 250;
      myOpptyLineItem.Utilization__c = 100;
      myOpptyLineItem.End_Date__c = Date.today().toStartOfWeek().adddays(14);//date.newInstance(2011, 9, 16);
      myOpptyLineItem.Calc_Type__c = 'End Date';
      
      Vertiba_Project_Role__c myOpptyLineItem2 = new Vertiba_Project_Role__c();
      myOpptyLineItem2.Project__c = myOppty.Id;
      myOpptyLineItem2.Hour_Budget__c = 1;
      myOpptyLineItem2.BillRate__c = 230;
      myOpptyLineItem2.Calc_Type__c = 'End Date';
      
         
      Vertiba_Project_Role__c myOpptyLineItem3 = new Vertiba_Project_Role__c();
      myOpptyLineItem3.Start_Date__c = myDate;
      myOpptyLineItem3.Project__c = myOppty.Id;
      myOpptyLineItem3.Hour_Budget__c = 32;
      myOpptyLineItem3.BillRate__c = 250;
      myOpptyLineItem3.Utilization__c = 100;
      myOpptyLineItem3.End_Date__c = myDate + 3;
      myOpptyLineItem3.Calc_Type__c = 'Utilization';
      
      Vertiba_Project_Role__c myOpptyLineItem4 = new Vertiba_Project_Role__c();
      myOpptyLineItem4.Project__c = myOppty.Id;
      myOpptyLineItem4.Hour_Budget__c = 1;
      myOpptyLineItem4.BillRate__c = 230;
      myOpptyLineItem4.End_Date__c = myDate + 2;
      myOpptyLineItem4.Calc_Type__c = 'Utilization';
      
     
      test.startTest();
      insert myOpptyLineItem;
      insert myOpptyLineItem2;
      insert myOpptyLineItem3;
      insert myOpptyLineItem4;
      
      /*Vertiba_Project_Role__c allItems = [SELECT Id, End_Date__c, Start_Date__c, Utilization__c FROM Vertiba_Project_Role__c WHERE Id=:myOpptyLineItem.Id];
      Vertiba_Project_Role__c allItems2 = [SELECT Id, End_Date__c, Start_Date__c, Utilization__c FROM Vertiba_Project_Role__c WHERE Id=:myOpptyLineItem2.Id];
      Vertiba_Project_Role__c allItems3 = [SELECT Id, End_Date__c, Start_Date__c, Utilization__c FROM Vertiba_Project_Role__c WHERE Id=:myOpptyLineItem3.Id];
      Vertiba_Project_Role__c allItems4 = [SELECT Id, End_Date__c, Start_Date__c, Utilization__c FROM Vertiba_Project_Role__c WHERE Id=:myOpptyLineItem4.Id];
      
      System.assertequals(Date.today().toStartOfWeek().adddays(19), allItems.End_Date__c);
      System.assertequals(null, allItems2.Start_Date__c);
      System.assertequals(100, allItems3.Utilization__c);
      System.assertequals(null,allItems4.Utilization__c);*/
      test.stopTest();
  }

}