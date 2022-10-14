public class AccountLMSControllerExtension {

   public Decimal totalHRS {get; set;}
   public Decimal totalMiles {get; set;}
   public Integer totalInvoices {get; set;}
   public Decimal totalShotHRS {get; set;}
   public Decimal totalRevenue {get; set;}
   public Decimal totalGrossMargin {get; set;}
   public Decimal totalPounds {get; set;}
   public Boolean displayLinkBlock {get; set;}
   Public PVA__c PVA;
   Public String AccountName {get; set;}
   Public List<string> phlLabels {get; set;}
   Public List<decimal> phlRev {get; set;}
   Public List<decimal> phlGrossMarg {get; set;}
   Public List<decimal> phlPounds {get; set;}
      
   Public class LMSAgg{
       public Decimal year {get;set;}
       public String month {get;set;}
       public Decimal revenue {get;set;}
       public Decimal grossmargin{get;set;}
       public Integer invoices {get;set;}
       public Decimal hrs {get;set;}
       public Decimal shothrs {get;set;}
       public Decimal miles {get;set;}
       public Decimal pounds {get;set;}
       
       public LMSAgg(Decimal a,string b, Decimal c, Decimal d, Integer e, Decimal f, Decimal g, Decimal h, Decimal i){
            this.year=a;
            this.month=b;
            this.revenue=c;
            this.grossmargin=d;
            this.invoices=e;
            this.hrs=f;
            this.shothrs=g;
            this.miles=h;
            this.pounds = i;
        }
   }
    
   Public List<aggregateResult> details; 
   Public List<LMSAgg> LMSAggList;
   Public List<aggregateResult> materialResults;
   public List<Summary> SummaryList {get;set;}
   public List<Material_Item__c> MaterialList;
   List<Id> Ids;
   public Map<Id, Material_Item__c> IdMaterial;
   
       
   public LMSAgg[] results3 {
        get{
            return LMSAggList;
          }    
    }
    
    public aggregateResult[] results4 {
        get{
            return materialResults;
           }
    } 
    
    public AccountLMSControllerExtension(ApexPages.StandardController controller) {
         PVA = (PVA__c)controller.getRecord();
        
        displayLinkBlock = false;

        // if in test mode, we do not want to assign the account id as it is already specified
        if (!Test.isRunningTest())
        {
            if (PVA == null) {
                PVA  = new PVA__c();
            }
            
            String accountID = System.currentPageReference().getParameters().get('accountID');
            PVA.Account__c = accountID;            
        }
    }
    
     public Void CalculateTable() {
        List<aggregateResult> results;
        List<aggregateResult> phlResults;
        
        
        //First set up PHL Map for PHL descriptions
        Map<String, String> phlMap = new Map<String, String>();
        for (Product_Grouping__c p : [SELECT name, Title__c FROM Product_Grouping__c]) {
           phlMap.put(p.name, p.Title__c);
        }
        
        phlLabels = new List<String>();
        phlRev = new List<Decimal>();
        phlGrossMarg = new List<Decimal>();
        phlPounds = new List<Decimal>();
               
        String monthLabel;
        
       LMSAggList = new List<LMSAgg>();
  
        results = [SELECT SUM(DELHRS__c) totHrs,   SUM(MILES__c) totMiles,  SUM(INVOICES__c) totInvoices, SUM(SHOTHRS__c) totShtHRS, SUM(Net_Revenue__c) totRevenue, SUM(Gross_Margin__c) totGrossMarg, SUM(LBS__c) totPounds FROM Copa__c  Where Customer__c = :PVA.Account__c  AND Current_Month__c >= :PVA.PVA_Start_Date__c AND Current_Month__c <= :PVA.PVA_End_Date__c];
        AccountName = [SELECT Name From Account WHERE ID = :PVA.Account__c][0].Name;
       
       if (results.size() > 0){
            totalInvoices = integer.valueOf((Decimal)results[0].get('totInvoices'));
            totalRevenue = (Decimal)results[0].get('totRevenue');
            totalGrossMargin = (Decimal)results[0].get('totGrossMarg');
            totalHRS = (Decimal)results[0].get('totHRS');
            totalMiles = (Decimal)results[0].get('totMiles');
            totalShotHRS = (Decimal)results[0].get('totShtHRS');
            totalPounds = (Decimal)results[0].get('totPounds');
            
                        
        }else{
             totalInvoices = 0;
            totalRevenue = 0;
        }

        details = [SELECT Current_Month__c, CALENDAR_YEAR(Current_Month__c) CurrYear, CALENDAR_MONTH(Current_Month__c) CurrMonth, SUM(DELHRS__c) totHrs, SUM(MILES__c) totMiles,  SUM(INVOICES__c) totInvoices, SUM(SHOTHRS__c) totShtHRS, SUM(Net_Revenue__c) totRevenue, SUM(Gross_Margin__c) totGrossMarg, SUM(LBS__c) totPounds FROM Copa__c  Where Customer__c = :PVA.Account__c AND Current_Month__c >= :PVA.PVA_Start_Date__c AND Current_Month__c <= :PVA.PVA_End_Date__c GROUP BY Current_Month__c ORDER BY Current_Month__c DESC];
        for (AggregateResult line : details)  {
        
            monthLabel = DateTime.newInstanceGMT(System.Date.newInstance(2000, (Integer)line.get('CurrMonth'), 1), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMM');        
            LMSAggList.add(new LMSAgg((Decimal)line.get('CurrYear'),string.valueOf((Integer)line.get('CurrYear')) + '-' + monthLabel,(Decimal)line.get('totRevenue'), (Decimal)line.get('totGrossMarg'), integer.valueOf((Decimal)line.get('totInvoices')), (Decimal)line.get('totHrs'), (Decimal)line.get('totShtHRS'), (Decimal)line.get('totMiles'), (Decimal)line.get('totPounds')));
        }
        
        phlResults = [SELECT Material_Item__r.PHL1__c phl, SUM(Net_Revenue__c) totRevenue, SUM(Gross_Margin__c) totGrossMarg, SUM(LBS__c) totPounds FROM Copa__c  Where Customer__c = :PVA.Account__c AND Current_Month__c >= :PVA.PVA_Start_Date__c AND Current_Month__c <= :PVA.PVA_End_Date__c GROUP BY Material_Item__r.PHL1__c];
        for( AggregateResult row : phlResults){
           
            phlLabels.add( (String)row.get('phl') + ': ' + phlMap.Get((String)row.get('phl')));
            phlRev.add( (Decimal)row.get('totRevenue'));
           phlGrossMarg.add( (Decimal)row.get('totGrossMarg'));
           phlPounds.add( (Decimal)row.get('totPounds'));
        }
        
        
        SummaryList = new List<Summary>();  
        Ids = new List<Id>();
        MaterialList = new List<Material_Item__c>();
        IdMaterial = new Map<Id, Material_Item__c>();
        
        //materialResults = [SELECT Material_Item__c, SUM(Net_Revenue__c) totRevenue, SUM(Gross_Margin__c) totGrossMarg, SUM(LBS__c) totVolume FROM Copa__c  Where Customer__c = :PVA.Account__c AND Current_Month__c >= :PVA.PVA_Start_Date__c AND Current_Month__c <= :PVA.PVA_End_Date__c GROUP BY Material_Item__c];
        
        materialResults = [SELECT Material_Item__c, SUM(Net_Revenue__c) totRevenue, SUM(Gross_Margin__c) totGrossMarg, SUM(LBS__c) totVolume FROM Copa__c  Where Material_Item__c != null AND Customer__c = :PVA.Account__c AND Current_Month__c >= :PVA.PVA_Start_Date__c AND Current_Month__c <= :PVA.PVA_End_Date__c GROUP BY Material_Item__c];
        
        for(AggregateResult a : materialResults) {   
            Ids.add((Id)a.get('Material_Item__c'));
        }
        
        MaterialList = [SELECT Name,PHL1__c  FROM Material_Item__c WHERE Id IN : Ids];
        for(Material_Item__c m : MaterialList) {
            IdMaterial.put(m.Id, m);            
        }
        
        for(AggregateResult a : materialResults) {
            Material_Item__c TempMaterial = new Material_Item__c();            
            TempMaterial = IdMaterial.get((Id)(a.get('Material_Item__c')));
            
            SummaryList.add(new Summary(TempMaterial.Name, TempMaterial.PHL1__c + ': ' + phlMap.Get(TempMaterial.PHL1__c), a));  
                          
        }    
        SummaryList.Sort();           
        displayLinkBlock = true;
   
    }
    
    public class Summary implements Comparable{
        public String MatName {get;set;}
        public String ProdGroup {get;set;}
        public Decimal Revenue {get;set;}
        public Decimal GrossMargin {get;set;}
        public Decimal Volume {get;set;}
                
        public Summary(String MaterialName, String ProductGroup, AggregateResult a) {
            MatName = MaterialName;
            ProdGroup = ProductGroup; 
            Revenue =  (Decimal)a.get('totRevenue');
            GrossMargin = (Decimal)a.get('totGrossMarg');
            Volume = (Decimal)a.get('totVolume');
            
        }
        
        public Integer compareTo(Object compareTo) {
            Summary compareToSummary = (Summary)compareTo;
            if (MatName == compareToSummary.MatName) return 0;
            if (MatName > compareToSummary.MatName) return 1;
            return -1;
        }
    }

}