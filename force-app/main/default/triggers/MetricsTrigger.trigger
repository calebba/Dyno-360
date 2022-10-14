trigger MetricsTrigger on ROI_Metric__c (after insert) {
    List<ROI_Metric_Period__c> metricPeriods= new List<ROI_Metric_Period__c>();
    public String previous{get;set;}
    public String accId{get;set;}
    public List<ROI_Metric_Period__c> temp= new List<ROI_Metric_Period__c>();
    
    Decimal dBaseLine;
    Decimal dTarget;
    Date dtMetricDate;
    
    
    Set<Id> MetPeriodIds = new Set<Id>();
    for (ROI_Metric__c aPeriod: Trigger.new){
          MetPeriodIds.add(aPeriod.Id);
    }

    Map<ID,ROI_Metric__c> inititiveList = new Map<ID,ROI_Metric__c>([Select id, Initiative__r.Initiative_Name_Combined__c FROM ROI_Metric__c Where id IN :MetPeriodIds]); 
        
    for(ROI_Metric__c metric : trigger.new)
    {
        previous = null;
        Date dtStart = metric.Start_Date__c;
        Date dtEnd = metric.End_Date__c;
        Integer periods = dtStart.monthsBetween(dtEnd);
        if (dtEnd.day() > dtStart.day()) periods++;
        periods--;
        accId = metric.Account__c;
        if(metric.Reporting_Interval__c == 'Weekly')periods = periods*4;
        Integer week= (periods/10);
        periods+= week;
        System.debug(periods);
        
        //Short Circut for Sharing Types - also if One Time is selected for Measuerment per
        If(metric.Dyno_Sharing_in_Value__c == 'Gain Sharing Payment' || 
        metric.Dyno_Sharing_in_Value__c == 'Acceptance of price adjustment' || 
        metric.Dyno_Sharing_in_Value__c == 'Tender Avoidance' || metric.Value_Per__c == 'One Time' ){
            periods = 1;
            dtMetricDate = dtEnd;
            dBaseLine = metric.Baseline_Value__c;
            dTarget = metric.Goal_Value__c;
            
        }else{
            //Need to send over baseline,target,and Metric cost.  
            dtMetricDate = dtStart;
            if(metric.Value_Per__c == 'Year'){
                dBaseLine = metric.Baseline_Value__c/12;
                dTarget = metric.Goal_Value__c/12;
            }else if(metric.Value_Per__c == 'Month'){
                dBaseLine = metric.Baseline_Value__c;
                dTarget = metric.Goal_Value__c;
            }else if(metric.Value_Per__c == 'Week'){
                dBaseLine = metric.Baseline_Value__c *52 / 12;
                dTarget = metric.Goal_Value__c *52 / 12;
            }else if(metric.Value_Per__c == 'Daily (7 Day Week)'){
                dBaseLine = metric.Baseline_Value__c *7 * 52 / 12;
                dTarget = metric.Goal_Value__c *7 * 52 / 12;
            }else if(metric.Value_Per__c == 'Daily (5 Day Week)'){
                dBaseLine = metric.Baseline_Value__c *5 * 52 / 12;             
                dTarget = metric.Goal_Value__c *5 * 52 / 12;
            } 
        }
       
        for(Integer i = 0;i<periods;i++)
        {
            ROI_Metric_Period__c period = new ROI_Metric_Period__c ();
            period.Period_Date__c = dtMetricDate.addMonths(i); 
            period.name = period.Period_Date__c.month() + '/' + period.Period_Date__c.year();
            period.Initiative__c = metric.Initiative__c;
               
            
            period.Baseline_Value__c = dBaseLine;
            period.Goal_Value__c = dTarget; 
            period.UoM_Conversion__c = metric.UoM_Conversion__c;
            period.Initiative_Name_Parent__c =inititiveList.get(metric.id).Initiative__r.Initiative_Name_Combined__c;
            
            period.Period_Number__c = i;
            period.Metric__c = metric.id;
            period.Account__c = accId; 
            temp.add(period);
        }
        
            
    }
    
    Insert temp;
    for(ROI_Metric_Period__c rp:temp)
    {
            rp.Previous_Period__c = previous; 
            previous= rp.id;
    }
    update temp;
        
}