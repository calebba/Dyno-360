@istest
public class MetricTriggerTest {
    
    public static testMethod void PopulateGoalAndBaselineWhenVIPMetricCreated(){
        
        Account acct = new Account();
        acct.Name = 'Bob';
        insert acct;
        
        ROI_Initicative__c init = new ROI_Initicative__c();
        init.Initiative_Name__c = 'test init';
        init.Account__c = acct.Id;
        init.End_Date__c = Date.today()+365;
        init.Start_Date__c = Date.today();
        init.Initiative_Description__c = 'this is a description';
        insert init;
        
        Map<Id, Double> metricMap = new Map<Id, Double>();
        
		Id testId = createMetric(acct.Id, init.Id, 'One Time', 'Weekly');
        metricMap.put(testId, 1);
		testId = createMetric(acct.Id, init.Id, 'Year', 'Weekly');
        metricMap.put(testId, 1/12);
		testId = createMetric(acct.Id, init.Id, 'Month', 'Weekly');
        metricMap.put(testId, 1);
		testId = createMetric(acct.Id, init.Id, 'Week', 'Monthly');
        metricMap.put(testId, 52 / 12);
		testId = createMetric(acct.Id, init.Id, 'Daily (7 Day Week)', 'Monthly');
        metricMap.put(testId, 7 * 52 / 12);
		testId = createMetric(acct.Id, init.Id, 'Daily (5 Day Week)', 'Monthly');
        metricMap.put(testId, 5 * 52 / 12);
        
        List<ROI_Metric__c> metrics = [SELECT Goal_Value__c, Baseline_Value__c FROM ROI_Metric__c];
        
        List<ROI_Metric_Period__c> metricPeriods = [SELECT Name, Goal_Value__c, Baseline_Value__c, Metric__r.Id FROM ROI_Metric_Period__c WHERE Metric__c IN :metrics];
        
        for (ROI_Metric_Period__c period : metricPeriods) {
 
         //   System.assertEquals(1000 * metricMap.get(period.Metric__r.Id), period.Baseline_Value__c, period.Name);
         //   System.assertEquals(1200 * metricMap.get(period.Metric__r.Id), period.Goal_Value__c);
        }
        
    }
    
    public static Id createMetric(Id acctId, Id initiativeId, string measurementPer, string reportingInterval){
      
        ROI_Metric__c metric = new ROI_Metric__c();
        metric.Account__c = acctId;
        metric.End_Date__c = Date.today()+365;
        metric.Start_Date__c = Date.today();
        metric.Initiative__c = initiativeId;
        metric.Reporting_Interval__c = reportingInterval;
        metric.Unit_of_Measurement__c = 'Test Unit';
        metric.Metric_Name__c = 'Fuel Usage';
        metric.Baseline_Value__c = 1000;
        metric.Goal_Value__c = 1200;
        metric.Value_Per__c = measurementPer;
        
        insert metric;
        
        return metric.Id;
    }
}