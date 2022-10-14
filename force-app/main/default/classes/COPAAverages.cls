public class COPAAverages {

    public  Id   salesSiteId { get; set; }
    public  Id   materialItemId { get; set; }
        
    public String message { get; set; }
    public String returnToUrl { get; set; }
        
    public void calculateAverages() {
        Boolean done = false;
        if (ApexPages.currentPage().getParameters().get('salesSiteId') != null) {
            System.debug('1');
            salesSiteId = ApexPages.currentPage().getParameters().get('salesSiteId');
            refreshForSite(salesSiteId);
            done = true;
            message = 'The averages for this site have been recalculated.';
            returnToUrl = '/' + salesSiteId;
        }
             
        if (ApexPages.currentPage().getParameters().get('MaterialItemId') != null) {
            materialItemId =ApexPages.currentPage().getParameters().get('MaterialItemId');
            refreshForMaterial(materialItemId);
            done = true;
            message = 'The averages for this material have been recalculated.';
            returnToUrl = '/' + materialItemId;
        }
        
        if (!done) {
            new ScheduledCalculations().execute(null);
            message = 'The averages for this COPA are being recalculated. An email will be sent upon completion of the batch apex.';
            returnToUrl = '/' + ApexPages.currentPage().getParameters().get('Id');
        }
    }
        
    public COPAAverages() {
                
    }
        
    public void refreshForSite(Id salesSiteId) {
                
        Date d3 = Date.today().addMonths(-3); 
        Date d6 = Date.today().addMonths(-6);  
        List<AggregateResult> results3 = [
                SELECT SUM(True_Total_Cogs__c) tcogs,SUM(LBS__c) tlbs, Material_Item__c 
                FROM Copa__c       
                WHERE Copa_type__c = 'Actual' AND Current_Month__c > :d3 AND Material_Item__c != null AND Sales_Site__c = :salesSiteId
                GROUP BY  Material_Item__c];
        List<AggregateResult> results6 = [
                SELECT SUM(True_Total_Cogs__c) tcogs,SUM(LBS__c) tlbs, Material_Item__c 
                FROM Copa__c       
                WHERE Copa_type__c = 'Actual' AND Current_Month__c > :d6 AND Material_Item__c != null AND Sales_Site__c = :salesSiteId
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
                WHERE Sales_Site__c = :salesSiteId AND Material_Item__c IN :materials];
            
        System.Debug('We have ' + costs.size() + ' materials from sales site with ID ' + salesSiteId);
            
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
        }
                
        upsert costs;
                
    }
        
    public void refreshForMaterial(Id materialItemId) {
        Date d3 = Date.today().addMonths(-3); 
        Date d6 = Date.today().addMonths(-6);  
        List<AggregateResult> results3 = [
                SELECT SUM(True_Total_Cogs__c) tcogs,SUM(LBS__c) tlbs, Sales_Site__c 
                FROM Copa__c       
                WHERE Copa_type__c = 'Actual' AND Current_Month__c > :d3 AND Sales_Site__c != null AND Material_Item__c = :materialItemId
                GROUP BY  Sales_Site__c];
        List<AggregateResult> results6 = [
                SELECT SUM(True_Total_Cogs__c) tcogs,SUM(LBS__c) tlbs, Sales_Site__c 
                FROM Copa__c       
                WHERE Copa_type__c = 'Actual' AND Current_Month__c > :d6 AND Sales_Site__c != null AND Material_Item__c = :materialItemId
                GROUP BY Sales_Site__c];
            
        System.debug('We found ' + results3.size()+ ' results for the last 3 months.');
        System.debug('We found ' + results6.size()+ ' results for the last 6 months.');
        
        Set<String> sites = new Set<String>();
        
        Map<String, Material_Cost__c> map1 = new Map<String, Material_Cost__c>();

        for(AggregateResult a: results6) {
            string mymatr = (Id) a.get('Sales_Site__c');
            if (!sites.contains(mymatr))
                sites.add(mymatr);
        }
        
        List<Material_Cost__c> costs = [
                SELECT Sales_Site__c, Material_Item__c, X3_Month_Cost__c, X6_Month_Cost__c, Don_t_autocalculate_3_months_cost__c, Don_t_autocalculate_6_months_cost__c
                FROM Material_Cost__c 
                WHERE Material_Item__c = :materialItemId AND Sales_Site__c IN :sites];
            
        System.Debug('We have ' + costs.size() + ' materials from sales site with ID ' + salesSiteId);
            
        for (Material_Cost__c c:costs)
        {
            c.X3_Month_Cost__c = null;
            c.X6_Month_Cost__c = null;
            map1.put(c.Sales_Site__c, c);
        }
        
        for(AggregateResult a: results3) {
            
            Boolean found = false;
            
            if (map1.get((string)a.get('Sales_Site__c')) != null) {
                Material_Cost__c c = map1.get((string)a.get('Sales_Site__c'));
                if (c.Don_t_autocalculate_3_months_cost__c) {
                    c.X3_Month_Cost__c = null;
                    continue;
                }
                if (a.get('tlbs') == 0) {
                    c.X3_Month_Cost__c = 0;
                } else {
                    c.X3_Month_Cost__c = Math.ABS(((Decimal)a.get('tcogs'))/((Decimal)a.get('tlbs')));
                }
                found = true;
            }
        }
        
        for(AggregateResult a: results6) {
            
            Boolean found = false;
            
            if (map1.get((string)a.get('Sales_Site__c')) != null) {
                Material_Cost__c c = map1.get((string)a.get('Sales_Site__c'));
                if (c.Don_t_autocalculate_6_months_cost__c) {
                    c.X6_Month_Cost__c = null;
                    continue;
                }
                if (a.get('tlbs') == 0) {
                    c.X6_Month_Cost__c = 0;
                } else {
                    c.X6_Month_Cost__c = Math.ABS(((Decimal)a.get('tcogs'))/((Decimal)a.get('tlbs')));
                }
                found = true;
            }
        }
                
        upsert costs;
                
    }

    public PageReference back() {
        return new PageReference(returnToUrl);
    }
        
    private static testmethod void testCOPAAverages() {
           
        Sales_Site__c myComSalesSite = new Sales_Site__c();
        insert myComSalesSite;
        
        Sales_Site__c myRegSalesSite = new Sales_Site__c();
        myRegSalesSite.Company_Site__c = myComSalesSite.Id;
        insert myRegSalesSite;
        
        Sales_Site__c mySalesSite = new Sales_Site__c();
        mySalesSite.Company_Site__c = myComSalesSite.Id;
        mySalesSite.Region_Site__c = myRegSalesSite.Id;
        insert mySalesSite;
        
        Material_Item__c myMaterialItem = new Material_Item__c();
        insert myMaterialItem;
        
        Material_Cost__c myMatCost = new Material_Cost__c();
        myMatCost.Material_Item__c = myMaterialItem.Id;
        myMatCost.Sales_Site__c = mySalesSite.Id;
        myMatCost.X3_Month_Cost__c = 0;
        myMatCost.X6_Month_Cost__c = 0;
        myMatCost.Don_t_autocalculate_3_months_cost__c = false;
        myMatCost.Don_t_autocalculate_6_months_cost__c = false;
        insert myMatCost;
        
        COPA__c myCOPA = new COPA__c();
        myCopa.Sales_Site__c = mySalesSite.Id;
        myCopa.Material_Item__c = myMaterialItem.Id;
        myCopa.Current_Month__c = Date.Today().addDays(-7);
        myCopa.Total_Cogs__c = 1;
        myCopa.LBS__c = 1;
        insert myCOPA;
                
        PageReference pageRef = Page.COPAAverages;
        Test.setCurrentPage(pageRef);
        
        Id siteId = mySalesSite.Id;
        Id materialId = myMaterialItem.Id;
        Id copaId = myCopa.Id;
        
        test.startTest();

        ApexPages.currentPage().getParameters().put('salesSiteId', siteId);
        COPAAverages cfc1 = new COPAAverages();
        cfc1.CalculateAverages();
        
        ApexPages.currentPage().getParameters().remove('salesSiteId');
        ApexPages.currentPage().getParameters().put('MaterialItemId', materialId);
        COPAAverages cfc2 = new COPAAverages();
        cfc2.CalculateAverages();
        
        ApexPages.currentPage().getParameters().remove('MaterialItemId');
        ApexPages.currentPage().getParameters().put('Id', copaId);
        COPAAverages cfc3 = new COPAAverages();
        cfc3.CalculateAverages();
        cfc3.back();
        
        myMatCost = [SELECT X3_Month_Cost__c FROM Material_Cost__c WHERE Id = :myMatCost.Id];
        System.assertEquals(1, myMatCost.X3_Month_Cost__c);

        Test.stopTest();
    }
    
}