public with sharing class SalesPipelineScatterController {

    public Column_Percentages__c objColumnPercentage {get;set;}

    public SalesPipelineScatterController() {
        List<Column_Percentages__c> listColumnPercentage = new List<Column_Percentages__c>();
        listColumnPercentage = [Select Id, Name, AN__c, IS__c,
                                                                     Ability_to_Diff__c,
                                                                     Competitive_Reaction__c,
                                                                     Margin__c,
                                                                     People__c,
                                                                     Probability_of_Success__c,
                                                                     Segment_Priority__c,
                                                                     Total_CapEx__c
                                                            From Column_Percentages__c
                                                            Where Name =: System.Label.IndustryName
                                                            Limit 1];
        objColumnPercentage = listColumnPercentage[0];
    }

    /**
     * method to fetch the Accounts details
     */
    @RemoteAction
    public static List<SalesPipelineWrapper> fetchAccountDetails() {
        List<Account> listAccount = new List<Account>();
        listAccount = [Select Id, Name, Industry,
                                                    Combined_AN_Products__c,
                                                    Combined_ISPE_Revenue__c,
                                                    Combined_Gross_Margin__c,
                                                    Total_CapEx__c, People__c,
                                                    Ability_to_Diff_Value__c,
                                                    Segment_Value__c,
                                                    Probability_of_Success_Value__c,
                                                    Comp_Reaction_Value__c
                                     From Account
                                     Where Include_in_National_Pipeline_Output__c =: true
                                      AND ParentId =: null];

        List<SalesPipelineWrapper> listSalesPipelineWrapper = new List<SalesPipelineWrapper>();
        for(Account objAccount : listAccount){
            if(objAccount.Combined_AN_Products__c != null &&
                 objAccount.Combined_ISPE_Revenue__c != null &&
                 objAccount.Combined_Gross_Margin__c != null
             ) {
                listSalesPipelineWrapper.add(new SalesPipelineWrapper(objAccount));
            }
        }

        return listSalesPipelineWrapper;

    }

    /**
     * Wrapper class to bind all calculated values for JSON
     */
    public class SalesPipelineWrapper {

        public Map<String, Pipeline_Calculations__c> mapNameToPipeLineCalc = new Map<String, Pipeline_Calculations__c>();

        public String Id;
        public String FIELD1;
        public String FIELD2;
        public Integer AN;
        public Integer IS;
        public Integer Margin;
        public Integer Ability_to_Diff;
        public Integer Segment_Priority;
        public Integer Probability_of_Success;
        public Integer Competitive_Reaction;
        public Decimal Score_x;
        public String FIELD11;
        public String Resources;
        public Decimal TotalCapEx;
        public Decimal People;
        public Decimal Score_y;
        public String FIELD17;
        public Decimal Quadrant;

        SalesPipelineScatterController objController;

        /**
         * constructor of wrapper class to initialize the values
         */
        public SalesPipelineWrapper(Account objAccount) {

            List<Pipeline_Calculations__c> pipeLineCalc = Pipeline_Calculations__c.getAll().values();
           
            for(Pipeline_Calculations__c objPipeLineCalc: pipeLineCalc) {
                 mapNameToPipeLineCalc.put(objPipeLineCalc.Name, objPipeLineCalc);
            }

            if(mapNameToPipeLineCalc.size() > 0) {
                this.Id = objAccount.Id;
                this.FIELD1 = objAccount.Name;
                this.FIELD2 = objAccount.Industry;
                this.AN = calculateCategoryLevel(objAccount.Combined_AN_Products__c, 'AN');
                this.IS = calculateCategoryLevel(objAccount.Combined_ISPE_Revenue__c, 'IS');
                this.Margin = calculateCategoryLevel(objAccount.Combined_Gross_Margin__c, 'GM');
                this.Ability_to_Diff = Integer.valueOf(objAccount.Ability_to_Diff_Value__c);
                this.Segment_Priority = Integer.valueOf(objAccount.Segment_Value__c);
                this.Probability_of_Success = Integer.valueOf(objAccount.Probability_of_Success_Value__c);
                this.Competitive_Reaction = Integer.valueOf(objAccount.Comp_Reaction_Value__c);
                this.Score_x = calculateScore_x(this);
                this.FIELD11 = '';
                this.Resources = '';
                this.TotalCapEx = calculateTotalCapExInvestmentLevel(objAccount.Total_CapEx__c);
                this.People = calculatePeopleInvestmentLevel(objAccount.People__c);
                this.Score_y = calculateScore_y(this);
                this.FIELD17 = '';
                this.Quadrant = calculateQuadrant(this.Score_x, this.Score_y);
            }

        }

        /**
         * method to calculate the category level
         */
        public Integer calculateCategoryLevel(Decimal categoryValue, String strCategoryName) {
            if(mapNameToPipeLineCalc.containsKey(strCategoryName)) {
                Pipeline_Calculations__c objPipeLineCalc = mapNameToPipeLineCalc.get(strCategoryName);
                if(categoryValue >= objPipeLineCalc.Level_10__c) {
                    return 10;
                }
                if(categoryValue >= objPipeLineCalc.Level_9__c) {
                    return 9;
                }
                if(categoryValue >= objPipeLineCalc.Level_8__c) {
                    return 8;
                }
                if(categoryValue >= objPipeLineCalc.Level_7__c) {
                    return 7;
                }
                if(categoryValue >= objPipeLineCalc.Level_6__c) {
                    return 6;
                }
                if(categoryValue >= objPipeLineCalc.Level_5__c) {
                    return 5;
                }
                if(categoryValue >= objPipeLineCalc.Level_4__c) {
                    return 4;
                }
                if(categoryValue >= objPipeLineCalc.Level_3__c) {
                    return 3;
                }
                if(categoryValue >= objPipeLineCalc.Level_2__c) {
                    return 2;
                }
                if(categoryValue >= objPipeLineCalc.Level_1__c) {
                    return 1;
                }

            } // end of if

            return 0;
        } // end of function

        /**
         * method to calculate x axis value
         */
        public Decimal calculateScore_x(SalesPipelineWrapper objSalesPipeLineWrapper) {

            Decimal score_x_value;
            List<Column_Percentages__c> listColumnPercentages = Column_Percentages__c.getAll().values();
            
            for (Column_Percentages__c objColumnPercentage : listColumnPercentages) {
                
                if (objColumnPercentage.Name == System.Label.IndustryName) {
                    
                    score_x_value = (objSalesPipeLineWrapper.AN * (objColumnPercentage.AN__c/100)) +
                                                    (objSalesPipeLineWrapper.IS * (objColumnPercentage.IS__c/100)) +
                                                    (objSalesPipeLineWrapper.Margin * (objColumnPercentage.Margin__c/100) ) +
                                                    (objSalesPipeLineWrapper.Ability_to_Diff * (objColumnPercentage.Ability_to_Diff__c/100) ) +
                                                    (objSalesPipeLineWrapper.Segment_Priority * (objColumnPercentage.Segment_Priority__c/100) ) +
                                                    (objSalesPipeLineWrapper.Probability_of_Success * (objColumnPercentage.Probability_of_Success__c/100) ) +
                                                    (objSalesPipeLineWrapper.Competitive_Reaction * (objColumnPercentage.Competitive_Reaction__c/100) );
                }
            }

            return score_x_value;
        }

        /**
         * method to calculate y axis value
         */
        public Decimal calculateScore_y(SalesPipelineWrapper objSalesPipeLineWrapper) {


             List<Account_Requirement_Calculations__c> listAccRequirementCalc = new List<Account_Requirement_Calculations__c>();
             listAccRequirementCalc = Account_Requirement_Calculations__c.getAll().values();

             Account_Requirement_Calculations__c objPeople = new Account_Requirement_Calculations__c();
             Account_Requirement_Calculations__c objTotalCapEx = new Account_Requirement_Calculations__c();

             for(Account_Requirement_Calculations__c objAccRequirementCalc : listAccRequirementCalc){
                 if(objAccRequirementCalc.Name == System.Label.Account_Req_Cal_Name_People) {
                     objPeople = objAccRequirementCalc;
                 }
                 if(objAccRequirementCalc.Name == System.Label.Account_Req_Cal_Name_TotalCapEx) {
                     objTotalCapEx = objAccRequirementCalc;
                 }
             }

             Decimal score_y_value;

             score_y_value = (objSalesPipeLineWrapper.TotalCapEx * 0.9) +
                                             (objSalesPipeLineWrapper.People * 0.1);
             return score_y_value;
        }

        /**
         * method to calculate the category level
         */
        public Integer calculateInvestmentLevel(Decimal investmentValue, Account_Requirement_Calculations__c objAccRequirementCalc) {

            if(investmentValue >= objAccRequirementCalc.Level3__c) {
                return 3;
            }
            if(investmentValue >= objAccRequirementCalc.Level2__c) {
                return 2;
            }
            if(investmentValue >= objAccRequirementCalc.Level1__c) {
                return 1;
            }
            if(investmentValue >= objAccRequirementCalc.Level0__c) {
                return 0;
            }

            return 0;
        } // end of function

        /**
         * method to calculate Total CapEx Investment
         */
        public Integer calculateTotalCapExInvestmentLevel(Decimal investmentValue) {
            List<Account_Requirement_Calculations__c> listAccRequirementCalc = new List<Account_Requirement_Calculations__c>();
            listAccRequirementCalc = Account_Requirement_Calculations__c.getAll().values();

            Account_Requirement_Calculations__c objPeople = new Account_Requirement_Calculations__c();
            Account_Requirement_Calculations__c objTotalCapEx = new Account_Requirement_Calculations__c();

            for(Account_Requirement_Calculations__c objAccRequirementCalc : listAccRequirementCalc){
                if(objAccRequirementCalc.Name == System.Label.Account_Req_Cal_Name_TotalCapEx) {
                    objTotalCapEx = objAccRequirementCalc;
                }
            }

            return calculateInvestmentLevel(investmentValue, objTotalCapEx);

        }

        /**
         * method to calculate People Investment
         */
        public Integer calculatePeopleInvestmentLevel(Decimal investmentValue) {
            List<Account_Requirement_Calculations__c> listAccRequirementCalc = new List<Account_Requirement_Calculations__c>();
            listAccRequirementCalc = Account_Requirement_Calculations__c.getAll().values();

            Account_Requirement_Calculations__c objPeople = new Account_Requirement_Calculations__c();
            Account_Requirement_Calculations__c objTotalCapEx = new Account_Requirement_Calculations__c();

            for(Account_Requirement_Calculations__c objAccRequirementCalc : listAccRequirementCalc){
                if(objAccRequirementCalc.Name == System.Label.Account_Req_Cal_Name_People) {
                    objPeople = objAccRequirementCalc;
                }
            }

            return calculateInvestmentLevel(investmentValue, objPeople);
        }

        /**
         * method to calclulate quadrant location
         */
        public Decimal calculateQuadrant(Decimal xAxis, Decimal yAxis) {
        if(xAxis >= 8) {
        if(yAxis >= 1.5){
            return 2;
        }
        else {
            return 1;
        }
        }
        else {
        if(yAxis >= 1.5){
            return 4;
        }
        else{
            return 3;
        }
        }
        }


    }

}