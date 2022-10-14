/**
 *  ================================================================================================
 *   Version    Date              Comment
 *  ================================================================================================
 *   v1.0      May-5-2017       -Created test class for SalesPipelineScatter Page
 */
@isTest
private class SalesPipelineScatterExtensionTest{


    /**
     * Method to create Account record
    */
    public static Account createAccount(Integer TotalIspeRevenue,Integer TotalGrossMargin,Integer TotalANProducts,
                                        String abilityToDiff,String proabilitySuccess,String compReaction,String segment,Integer totalCapEx,Integer people){
        Account accountObj = new Account();
        accountObj.Name = 'test Account';
        accountObj.Industry = '19 Stone';
        accountObj.Ability_to_Diff__c = abilityToDiff;
        accountObj.Probability_of_Succ__c = proabilitySuccess;
        accountObj.Comp_Reaction__c = compReaction;
        accountObj.Segment_Priority__c = segment;
        accountObj.Include_in_National_Pipeline_Output__c = true;
        accountObj.Total_Child_ISPE_Revenue__c = TotalIspeRevenue;
        accountObj.Account_ISPE_Revenue__c = 367;
        accountObj.Total_Child_Gross_Margin__c = TotalGrossMargin;
        accountObj.Account_Gross_Margin__c = 134;
        accountObj.Total_Child_AN_Products__c = TotalANProducts;
        accountObj.Account_AN_Products__c = 235;
        accountObj.Total_CapEx__c = totalCapEx;
        accountObj.People__c = people;

        insert accountObj;
        return accountObj;
    }

    /**
     * Method to create custom setting - Column_Percentages__c record
    */
    public static  Column_Percentages__c createColumnPercentage(){
        Column_Percentages__c columnPercentageObj = new Column_Percentages__c();
        columnPercentageObj.Name = 'Customer';
        columnPercentageObj.AN__c=15;
        columnPercentageObj.IS__c =15;
        columnPercentageObj.Ability_to_Diff__c=15;
        columnPercentageObj.Competitive_Reaction__c=5;
        columnPercentageObj.Margin__c=30;
        columnPercentageObj.People__c=10;
        columnPercentageObj.Probability_of_Success__c=10;
        columnPercentageObj.Segment_Priority__c=10;
        columnPercentageObj.Total_CapEx__c=90;

        insert columnPercentageObj;
        return columnPercentageObj;
    }

    /**
     * Method to create custom setting - Pipeline_Calculations__c AN record
    */
    public static  Pipeline_Calculations__c createPipelineCalculationAN(){
        Pipeline_Calculations__c pipelineCalObj = new Pipeline_Calculations__c();
        pipelineCalObj.Name = 'AN';
        pipelineCalObj.Level_1__c = 2000;
        pipelineCalObj.Level_2__c = 4000;
        pipelineCalObj.Level_3__c= 6000;
        pipelineCalObj.Level_4__c = 8000;
        pipelineCalObj.Level_5__c = 10000;
        pipelineCalObj.Level_6__c = 20000;
        pipelineCalObj.Level_7__c = 30000;
        pipelineCalObj.Level_8__c = 40000;
        pipelineCalObj.Level_9__c = 45000;
        pipelineCalObj.Level_10__c = 50000 ;

        insert pipelineCalObj;
        return pipelineCalObj;
    }

    /**
     * Method to create custom setting - Pipeline_Calculations__c GM record
    */
    public static  Pipeline_Calculations__c createPipelineCalculationGM(){
        Pipeline_Calculations__c pipelineCalObj = new Pipeline_Calculations__c();
        pipelineCalObj.Name = 'GM';
        pipelineCalObj.Level_1__c = 25000;
        pipelineCalObj.Level_2__c = 50000;
        pipelineCalObj.Level_3__c=  75000;
        pipelineCalObj.Level_4__c = 100000;
        pipelineCalObj.Level_5__c = 250000;
        pipelineCalObj.Level_6__c = 500000;
        pipelineCalObj.Level_7__c = 625000;
        pipelineCalObj.Level_8__c = 750000;
        pipelineCalObj.Level_9__c = 875000;
        pipelineCalObj.Level_10__c = 1000000 ;

        insert pipelineCalObj;
        return pipelineCalObj;
    }

    /**
     * Method to create custom setting - Pipeline_Calculations__c IS record
    */
    public static  Pipeline_Calculations__c createPipelineCalculationIS(){
        Pipeline_Calculations__c pipelineCalObj = new Pipeline_Calculations__c();
        pipelineCalObj.Name = 'IS';
        pipelineCalObj.Level_1__c = 25000;
        pipelineCalObj.Level_2__c = 50000;
        pipelineCalObj.Level_3__c=  75000;
        pipelineCalObj.Level_4__c = 100000;
        pipelineCalObj.Level_5__c = 250000;
        pipelineCalObj.Level_6__c = 500000;
        pipelineCalObj.Level_7__c = 625000;
        pipelineCalObj.Level_8__c = 750000;
        pipelineCalObj.Level_9__c = 875000;
        pipelineCalObj.Level_10__c = 1000000 ;

        insert pipelineCalObj;
        return pipelineCalObj;
    }

    /**
     * Method to create custom setting - Account_Requirement_Calculations__c People record
    */
    public static  Account_Requirement_Calculations__c createAccountRequirementCalculationsPeople(){
        Account_Requirement_Calculations__c accountRequirementCalObj = new Account_Requirement_Calculations__c();
        accountRequirementCalObj.Name = 'People';
        accountRequirementCalObj.Level0__c = 0;
        accountRequirementCalObj.Level1__c = 1;
        accountRequirementCalObj.Level2__c=  5;
        accountRequirementCalObj.Level3__c = 10;

        insert accountRequirementCalObj;
        return accountRequirementCalObj;
    }

    /**
     * Method to create custom setting - Account_Requirement_Calculations__c Total CapEx record
    */
    public static  Account_Requirement_Calculations__c createAccountRequirementCalculationsTotalCapEx(){
        Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = new Account_Requirement_Calculations__c();
        accountRequirementCalObjTotalCapEx.Name = 'Total CapEx';
        accountRequirementCalObjTotalCapEx.Level0__c = 0;
        accountRequirementCalObjTotalCapEx.Level1__c = 1;
        accountRequirementCalObjTotalCapEx.Level2__c=  2000000;
        accountRequirementCalObjTotalCapEx.Level3__c = 3000000;

        insert accountRequirementCalObjTotalCapEx;
        return accountRequirementCalObjTotalCapEx;
    }

    /**
     * Method to call constructor
    */
    public static testMethod void testExtension(){

        Account_Requirement_Calculations__c accountRequirementCalObj = createAccountRequirementCalculationsPeople();
        Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = createAccountRequirementCalculationsTotalCapEx();
        Account accountObj = createAccount(25000,25000,10000,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3000000,15);
        System.assertNotEquals(accountObj,null);
        Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
        System.assertNotEquals(pipelineCalObjAN,null);
        Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
        System.assertNotEquals(pipelineCalObjGM,null);
        Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
        System.assertNotEquals(pipelineCalObjIS,null);
        Column_Percentages__c columnPercentageObj = createColumnPercentage();
        System.assertNotEquals(columnPercentageObj,null);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accountObj);
        SalesPipelineScatterExtension pipelineScatterExtensionObj = new SalesPipelineScatterExtension(sc);
        Test.stopTest();
        System.assertEquals(5.20,pipelineScatterExtensionObj.xAxisValue);
        System.assertEquals(3,pipelineScatterExtensionObj.yAxisValue);
    }
}