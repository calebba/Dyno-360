/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Account_RequirementTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Account_RequirementTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Account_Requirement__c());
    }
}