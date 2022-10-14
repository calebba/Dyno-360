/**
 *  ================================================================================================
 *   Version    Date              Comment
 *  ================================================================================================
 *   v1.0      May-5-2017              -Created test class for SalesPipelineScatterChart Page
 */
@isTest
private class SalesPipelineScatterControllerTest {

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
         * Method to create Account record  with Category Level 10
         */
        public static testMethod void testPipeLineCategoryLevel10(){

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
            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
                                        Where Industry = '19 Stone'];
            Test.stopTest();
            System.assertEquals(getDetailsSalesPipeline[0].AN,5);
            System.assertEquals(getDetailsSalesPipeline[0].IS,1);
            System.assertEquals(getDetailsSalesPipeline[0].Margin,1);
            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,10);
            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,10);
            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,10);
            System.assertEquals(getAccount[0].Segment_Value__c,10);

            System.assertEquals(5.20,getDetailsSalesPipeline[0].Score_x);
            System.assertEquals(3,getDetailsSalesPipeline[0].Score_y);
            System.assertEquals(4,getDetailsSalesPipeline[0].Quadrant);

        }

//        /**
//         * Method to create Account record  with Category Level 9
//         */
//        public static testMethod void testPipeLineCategoryLevel9(){
//
//            Account_Requirement_Calculations__c accountRequirementCalObj = createAccountRequirementCalculationsPeople();
//            Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = createAccountRequirementCalculationsTotalCapEx();
//            Account accountObj = createAccount(50000,50000,10000,'High','90%','Low','Metals (Au, Ag, Cu) / Q&C (10)',2000000,5);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,5);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,2);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,2);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,9);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,9);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,9);
//            System.assertEquals(getAccount[0].Segment_Value__c,9);
//
//            System.assertEquals(5.25,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(4,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 8
//         */
//        public static testMethod void testPipeLineCategoryLevel8(){
//
//            Account_Requirement_Calculations__c accountRequirementCalObj = createAccountRequirementCalculationsPeople();
//            Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = createAccountRequirementCalculationsTotalCapEx();
//            Account accountObj = createAccount(75000,75000,10000,'High','80%','Low','Salt (6)',1,1);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,5);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,3);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,3);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,8);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,8);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,8);
//            System.assertEquals(getAccount[0].Segment_Value__c,8);
//
//            System.assertEquals(5.30,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(1,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 7
//         */
//        public static testMethod void testPipeLineCategoryLevel7(){
//
//            Account_Requirement_Calculations__c accountRequirementCalObj = createAccountRequirementCalculationsPeople();
//            Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = createAccountRequirementCalculationsTotalCapEx();
//            Account accountObj = createAccount(100000,100000,10000,'Med-High','70%','Low-Med','Iron Ore (7)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,5);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,4);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,4);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,7);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,7);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,7);
//            System.assertEquals(getAccount[0].Segment_Value__c,7);
//
//            System.assertEquals(5.35,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 6
//         */
//        public static testMethod void testPipeLineCategoryLevel6(){
//            Account accountObj = createAccount(250000,250000,10000,'Medium','60%','Low-Med','Salt (6)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,5);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,5);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,5);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,6);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,6);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,6);
//            System.assertEquals(getAccount[0].Segment_Value__c,6);
//
//            System.assertEquals(5.40,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 5
//         */
//        public static testMethod void testPipeLineCategoryLevel5(){
//            Account accountObj = createAccount(500000,500000,50000,'Medium','50%','Medium','PRB Coal (5)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,10);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,6);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,6);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,5);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,5);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,5);
//            System.assertEquals(getAccount[0].Segment_Value__c,5);
//
//            System.assertEquals(6.20,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 4
//         */
//        public static testMethod void testPipeLineCategoryLevel4(){
//            Account accountObj = createAccount(625000,625000,50000,'Med-Low','40%','Medium','ILB Coal (4)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,10);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,7);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,7);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,4);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,4);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,4);
//            System.assertEquals(getAccount[0].Segment_Value__c,4);
//
//            System.assertEquals(6.25,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 3
//         */
//        public static testMethod void testPipeLineCategoryLevel3(){
//            Account accountObj = createAccount(750000,750000,50000,'Med-Low','30%','Med-Strong','Salt (6)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,10);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,8);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,8);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,3);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,3);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,3);
//            System.assertEquals(getAccount[0].Segment_Value__c,3);
//
//            System.assertEquals(6.30,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 2
//         */
//        public static testMethod void testPipeLineCategoryLevel2(){
//            Account accountObj = createAccount(875000,875000,50000,'Low','20%','Med-Strong','Appalachia Coal (2)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,10);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,9);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,9);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,2);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,2);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,2);
//            System.assertEquals(getAccount[0].Segment_Value__c,2);
//
//            System.assertEquals(6.35,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Category Level 1
//         */
//        public static testMethod void testPipeLineCategoryLevel1(){
//            Account accountObj = createAccount(1000000,1000000,50000,'Low','10%','Strong','Salt (6)',0,0);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(getDetailsSalesPipeline[0].AN,10);
//            System.assertEquals(getDetailsSalesPipeline[0].IS,10);
//            System.assertEquals(getDetailsSalesPipeline[0].Margin,10);
//            System.assertEquals(getAccount[0].Ability_to_Diff_Value__c,1);
//            System.assertEquals(getAccount[0].Probability_of_Success_Value__c,1);
//            System.assertEquals(getAccount[0].Comp_Reaction_Value__c,1);
//            System.assertEquals(getAccount[0].Segment_Value__c,1);
//
//            System.assertEquals(6.40,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(2,getDetailsSalesPipeline[0].Quadrant);
//        }
//
//        /**
//         * Method to create Account record  with Quadrant 3
//         */
//        public static testMethod void testPipeLineCategory(){
//
//            Account_Requirement_Calculations__c accountRequirementCalObj = createAccountRequirementCalculationsPeople();
//            Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = createAccountRequirementCalculationsTotalCapEx();
//            Account accountObj = createAccount(38239400,57337550,57337550,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',3100000,15);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(10,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(3,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(3,getDetailsSalesPipeline[0].Quadrant);
//
//        }
//
//        /**
//         * Method to create Account record  with Quadrant 1
//         */
//        public static testMethod void testPipeLineCategoryQuadrant1(){
//
//            Account_Requirement_Calculations__c accountRequirementCalObj = createAccountRequirementCalculationsPeople();
//            Account_Requirement_Calculations__c accountRequirementCalObjTotalCapEx = createAccountRequirementCalculationsTotalCapEx();
//            Account accountObj = createAccount(38239400,57337550,57337550,'High','100%','No Reaction','Metals (Au, Ag, Cu) / Q&C (10)',0,1);
//            System.assertNotEquals(accountObj,null);
//            Pipeline_Calculations__c pipelineCalObjAN = createPipelineCalculationAN();
//            System.assertNotEquals(pipelineCalObjAN,null);
//            Pipeline_Calculations__c pipelineCalObjGM = createPipelineCalculationGM();
//            System.assertNotEquals(pipelineCalObjGM,null);
//            Pipeline_Calculations__c pipelineCalObjIS = createPipelineCalculationIS();
//            System.assertNotEquals(pipelineCalObjIS,null);
//            Column_Percentages__c columnPercentageObj = createColumnPercentage();
//
//            Test.startTest();
//            SalesPipelineScatterController salesPipelineObj = new SalesPipelineScatterController();
//            List<SalesPipelineScatterController.SalesPipelineWrapper> getDetailsSalesPipeline = SalesPipelineScatterController.fetchAccountDetails();
//            List<Account> getAccount = [Select id,Ability_to_Diff_Value__c,Probability_of_Success_Value__c,Comp_Reaction_Value__c,Segment_Value__c From Account
//                                        Where Industry = '19 Stone'];
//            Test.stopTest();
//            System.assertEquals(10,getDetailsSalesPipeline[0].Score_x);
//            System.assertEquals(0.1,getDetailsSalesPipeline[0].Score_y);
//            System.assertEquals(1,getDetailsSalesPipeline[0].Quadrant);
//
//        }

}