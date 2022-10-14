/**
* ==================================================================================
*    Version        Date                          Comment
* ==================================================================================
*    Initial      3-5-2107              Extension class for calculating the
*                                       x and y co-ordinates.
*/
public with sharing class SalesPipelineScatterExtension {

	public Decimal xAxisValue	{get;set;}
	public Decimal yAxisValue	{get;set;}

	public SalesPipelineScatterExtension(ApexPages.StandardController stdController) {

		Account objAccount =  [Select Id, Name, Industry,
													Combined_AN_Products__c,
													Combined_ISPE_Revenue__c,
													Combined_Gross_Margin__c,
													Total_CapEx__c, People__c,
													Ability_to_Diff_Value__c,
													Segment_Value__c,
													Probability_of_Success_Value__c,
													Comp_Reaction_Value__c
									 From Account
									 Where Id =: stdController.getId()];

		SalesPipelineScatterController.SalesPipelineWrapper objSalesPipelineWrapper = new SalesPipelineScatterController.SalesPipelineWrapper(objAccount);

		xAxisValue = objSalesPipelineWrapper.Score_x;
		yAxisValue = objSalesPipelineWrapper.Score_y;
  }
}