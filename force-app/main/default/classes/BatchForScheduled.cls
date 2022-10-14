global class BatchForScheduled implements Database.Batchable<sObject>{
    private String userEmail;
    
    global BatchForScheduled(String mail) {
        userEmail = mail;       
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        /*Integer nosites = [SELECT Count() FROM Sales_Site__c];
        System.debug('There are ' + nosites + ' distinct sites!!');*/
        return Database.getQueryLocator('SELECT Id, name FROM Sales_Site__c');
    } 
    
    global void execute(Database.BatchableContext BC, list<Sales_Site__c> sites) {
        System.debug('There are ' + sites.size() + ' distinct sites!!');
        Sales_Site__c mysite = sites[0];
        System.debug('Working on the materials costs for site ' + mysite.name + ' !!');
        
        Date d3 = Date.today().addMonths(-3);
        Date d6 = Date.today().addMonths(-6);  
        List<AggregateResult> results3 = [
            SELECT SUM(True_Total_Cogs__c) tcogs,SUM(LBS__c) tlbs, Material_Item__c 
            FROM Copa__c       
            WHERE Copa_type__c = 'Actual' AND Current_Month__c > :d3 AND Material_Item__c != null AND Sales_Site__c = :mysite.Id
            GROUP BY  Material_Item__c];
        List<AggregateResult> results6 = [
            SELECT SUM(True_Total_Cogs__c) tcogs,SUM(LBS__c) tlbs, Material_Item__c 
            FROM Copa__c       
            WHERE Copa_type__c = 'Actual' AND Current_Month__c > :d6 AND Material_Item__c != null AND Sales_Site__c = :mysite.Id
            GROUP BY Material_Item__c];
            
        System.debug('We found ' + results3.size()+ ' results for the last 3 months.');
        System.debug('We found ' + results6.size()+ ' results for the last 6 months.');
        
        Set<String> materials = new Set<String>();
        
        Map<String, Material_Cost__c> map1 = new Map<String, Material_Cost__c>();

        for(AggregateResult a: results6) {
            string mymatr = (Id) a.get('Material_Item__c');
            if (!materials.contains(mymatr))
                materials.add(mymatr);
        }
        
        List<Material_Cost__c> costs = [
            SELECT Sales_Site__c, Material_Item__c, X3_Month_Cost__c, X6_Month_Cost__c, Don_t_autocalculate_3_months_cost__c, Don_t_autocalculate_6_months_cost__c
            FROM Material_Cost__c 
            WHERE Sales_Site__c = :mysite.Id AND Material_Item__c != null];
            
        System.Debug('We have ' + costs.size() + ' materials from sales site ' + mysite.name);
            
        for (Material_Cost__c c:costs)
        {
            c.X3_Month_Cost__c = null;
            c.X6_Month_Cost__c = null;
            map1.put(c.Material_Item__c, c);
        }           
            
       
        
        for(AggregateResult a: results3) {
            
            Boolean found = false;
            
            if (map1.get((string)a.get('Material_Item__c')) != null) {
                Material_Cost__c c = map1.get((string)a.get('Material_Item__c'));
                if (c.Don_t_autocalculate_3_months_cost__c)
                    continue;
                if (a.get('tlbs') == 0) {
                    c.X3_Month_Cost__c = 0;
                } else {
                    c.X3_Month_Cost__c = Math.ABS(((Decimal)a.get('tcogs'))/((Decimal)a.get('tlbs')));
                }
                found = true;
            }
            /*if(!found) {
                Material_Cost__c mc = new Material_Cost__c();
                mc.Sales_Site__c = mysite.id;
                mc.Material_Item__c =(Id) a.get('Material_Item__c');
                if (a.get('tlbs') == 0)
                {
                    mc.X3_Month_Cost__c = 0;
                } else {
                    mc.X3_Month_Cost__c = Math.ABS(((Decimal)a.get('tcogs'))/((Decimal)a.get('tlbs')));
                }
                costs.add(mc);
                
                map1.put(mc.Material_Item__c, mc);
            }*/
        }
        
        for(AggregateResult a: results6) {
            
            Boolean found = false;
            
            if (map1.get((string)a.get('Material_Item__c')) != null) {
                Material_Cost__c c = map1.get((string)a.get('Material_Item__c'));
                if (c.Don_t_autocalculate_6_months_cost__c)
                    continue;
                if (a.get('tlbs') == 0) {
                    c.X6_Month_Cost__c = 0;
                } else {
                    c.X6_Month_Cost__c = Math.ABS(((Decimal)a.get('tcogs'))/((Decimal)a.get('tlbs')));
                }
                found = true;
            }
            /*if(!found) {
                Material_Cost__c mc = new Material_Cost__c();
                mc.Sales_Site__c = mysite.id;
                mc.Material_Item__c =(Id) a.get('Material_Item__c');
                if (a.get('tlbs') == 0) {
                    mc.X6_Month_Cost__c = 0;
                } else {
                    mc.X6_Month_Cost__c = Math.ABS(((Decimal)a.get('tcogs'))/((Decimal)a.get('tlbs')));
                }
                costs.add(mc);
                
                map1.put(mc.Material_Item__c, mc);
            }*/
        }
                
        upsert costs;
              
    }
       
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new String[] {userEmail});
        //mail.setReplyTo('batch@acme.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}