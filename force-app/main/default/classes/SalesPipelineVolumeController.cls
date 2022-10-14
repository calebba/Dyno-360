/**
 *  ================================================================================================
 *   Version    Date              Comment
 *  ================================================================================================
 *   v1.0      Mar-15-2017       -Created controller class for SalesPipelineVolume Page
 */

public without sharing class SalesPipelineVolumeController {

    public String totalRevenue                                                {get; set;}
    public String totalMargin                                                 {get; set;}
    public Pipeline_Volume__c objPipelineVolume                               {get; set;}
    public Pipeline_Volume__c objPipelineVolumeNewRecord                      {get; set;}
    public Id recordId                                                        {get; set;}
    public String selelctedValue                                              {get; set;}
    public Boolean showNewRecordDiv                                           {get; set;}
    public Boolean hideCurrentRecordDiv                                       {get; set;}
    public Boolean displayOkButton                                            {get; set;}
    public Boolean hideSelectListButtons                                      {get; set;}
    public Boolean enableDeleteButton                                         {get; set;}
    public Boolean enableMakeActiveButton                                     {get; set;}
    public Boolean refreshPage                                                {get; set;}
    public Map<Id,Pipeline_Volume__c> mapPipelineVolume;
    public List<Pipeline_Volume__c> listPipelineVolumes;
    public List<Pipeline_Volume__c> updateListPipelineVolumes;
    private static final String STRING_QUERY = 'select id, AN_Prill_Incumbent__c,'+
                                                    'AN_Prill_UOM__c, '+
                                                    'AN_Prill_Volume__c, '+
                                                    'AN_Prill_Revenue__c, '+
                                                    'AN_Prill_GM__c, '+
                                                    'ANFO_GM__c,' +
                                                    'ANFO_Incumbent__c,' +
                                                    'ANFO_Revenue__c,' +
                                                    'ANFO_UOM__c,' +
                                                    'ANFO_Volume__c,' +
                                                    'Bulk_Emulsion_Incumbent__c, '+
                                                    'Bulk_Emulsion_UOM__c, '+
                                                    'Bulk_Emulsion_Volume__c, '+
                                                    'Bulk_Emulsion_Revenue__c, '+
                                                    'Bulk_Emulsion_GM__c, '+
                                                    'Small_Packaged_Incumbent__c, '+
                                                    'Small_Packaged_UOM__c, '+
                                                    'Small_Packaged_Volume__c, '+
                                                    'Small_Packaged_Revenue__c, '+
                                                    'Small_Packaged_GM__c, '+
                                                    'Large_Packaged_Incumbent__c, '+
                                                    'Large_Packaged_UOM__c, '+
                                                    'Large_Packaged_Volume__c, '+
                                                    'Large_Packaged_Revenue__c, '+
                                                    'Large_Packaged_GM__c, '+
                                                    'Dynamite_Incumbent__c, '+
                                                    'Dynamite_UOM__c, '+
                                                    'Dynamite_Volume__c, '+
                                                    'Dynamite_Revenue__c, '+
                                                    'Dynamite_GM__c, '+
                                                    'Boosters_Incumbent__c, '+
                                                    'Boosters_UOM__c, '+
                                                    'Boosters_Volume__c, '+
                                                    'Boosters_Revenue__c, '+
                                                    'Boosters_GM__c, '+
                                                    'Cord_Incumbent__c, '+
                                                    'Cord_UOM__c, '+
        											'CurrencyIsoCode,'+
                                                    'Cord_Volume__c, '+
                                                    'Cord_Revenue__c, '+
                                                    'Cord_GM__c, '+
                                                    'Nonelectrics_Incumbent__c, '+
                                                    'Nonelectrics_UOM__c, '+
                                                    'Nonelectrics_Volume__c, '+
                                                    'Nonelectrics_Revenue__c, '+
                                                    'Nonelectrics_GM__c, '+
                                                    'Electronics_Incumbent__c, '+
                                                    'Electronics_UOM__c , '+
                                                    'Electronics_Volume__c, '+
                                                    'Electronics_Revenue__c, '+
                                                    'Electronics_GM__c, '+
                                                    'Service_Incumbent__c, '+
                                                    'Service_Volume__c, '+
                                                    'Service_Revenue__c,  '+
                                                    'Service_GM__c, '+
                                                    'Other_Incumbent__c, '+
                                                    'Other_Volume__c, '+
                                                    'Other_Revenue__c , '+
                                                    'Other_GM__c, '+
                                                    'Active__c, ' +
                                                    'Name, ' +
                                                    'Fiscal_Year__c, ' +
                                                    'CreatedDate, ' +
                                                    'Total_Estimated_Revenue__c '+
                                                    'FROM Pipeline_Volume__c ' +
                                                    'Where Account__c =: recordId ' +
                                                    'ORDER BY CreatedDate DESC';

    /** The extension constructor initializes the private member
     * variable mysObject by using the getRecord method from the standard
     * controller.
     */
    public SalesPipelineVolumeController(ApexPages.StandardController controller) {
        recordId = controller.getId();
        refreshPage = true;
        objPipelineVolumeNewRecord = new Pipeline_Volume__c();
        //showNewRecordDiv = false;
        //hideCurrentRecordDiv = true;
        //enableDeleteButton = false;
        //enableMakeActiveButton = false;
        listPipelineVolumes = Database.Query(STRING_QUERY);
        if(listPipelineVolumes.size() >0){
                  mapPipelineVolume = new Map<Id, Pipeline_Volume__c>(listPipelineVolumes);
                  for(Pipeline_Volume__c pipelineObj : listPipelineVolumes){
                      if(pipelineObj.Active__c == true){
                           selelctedValue = pipelineObj.Id;
                           system.debug('selelctedValue---'+selelctedValue);
                           break;
                      }
                      else{
                         selelctedValue = pipelineObj.Id;
                      }
                  }
                  system.debug('selelctedValue--end ---for-'+selelctedValue);
                  if(mapPipelineVolume.containsKey(selelctedValue)){
                    objPipelineVolume = mapPipelineVolume.get(selelctedValue);
                    hideCurrentRecordDiv = true;
                    hideSelectListButtons = true;
                    enableDeleteButton = true;
                    enableMakeActiveButton = true;
                    totalRevenue = getTotalrevenue(objPipelineVolume);
                    totalMargin = getTotalMargin(objPipelineVolume);
                }
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Info_Message_No_Records));
            displayOkButton = true;
            hideCurrentRecordDiv = false;
            hideSelectListButtons = true;
            enableDeleteButton = false;
            enableMakeActiveButton = false;
        }
        //displayOkButton = false;
        //showDetailEntry();
        //cancelrecord();
        system.debug('selelctedValue--outsidde for-'+selelctedValue);


    }

    /**
     * Method to show options in Select List
     */
    public List<SelectOption>  getpipeline(){

        List<SelectOption> options = new List<SelectOption>();
        String CreateDateTotalEstimatedRevenue = '';
        for(Pipeline_Volume__c pipelineVolumeObj : listPipelineVolumes){
            Date createdDate = Date.newinstance(pipelineVolumeObj.CreatedDate.year(),pipelineVolumeObj.CreatedDate.month(),pipelineVolumeObj.CreatedDate.day());
            string datetimestr = pipelineVolumeObj.CreatedDate.format('MM/dd/yyyy');
            
            CreateDateTotalEstimatedRevenue = datetimestr + ' - ' + pipelineVolumeObj.Name +' ('+pipelineVolumeObj.Fiscal_Year__c +')';
            if(pipelineVolumeObj.Active__c == true){
                CreateDateTotalEstimatedRevenue = CreateDateTotalEstimatedRevenue + ': Active';
            }
            options.add(new SelectOption(pipelineVolumeObj.Id,CreateDateTotalEstimatedRevenue));
        }
        if(listPipelineVolumes.size() == 0){
            options.add(new SelectOption('--None--','--None--'));
        }
        return options;
    }

    /**
    * Method to update the PipeLine Volume record
    */
   public void saveRecord(){

       Boolean validIsSuccess = validateRecord(objPipelineVolume);
       if(validIsSuccess == false){
           displayOkButton = true;
       }
       else{
           displayOkButton = false;
               try {
                   update objPipelineVolume;
                   totalRevenue = getTotalrevenue(objPipelineVolume);
                   totalMargin = getTotalMargin(objPipelineVolume);
                   
                   //updating parent account with child aggregations
                        AggregateChildAccountsToParent();
                    //End to update
                   
                   if(ApexPages.hasMessages()) {
                       refreshPage = false;
                   }
                   else {
                       refreshPage = true;
                   }
               } catch(DmlException e) {
                   refreshPage = false;
                   ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                   return;
               }
       }
   }

   /**
    * Method to save record on click of Add button following Save button
    */
   public void saveNewRecord(){

       Boolean validIsSuccess = validateRecord(objPipelineVolumeNewRecord);
       if(validIsSuccess == true){
           hideSelectListButtons = true;
           enableDeleteButton = true;
           enableMakeActiveButton = true;
           objPipelineVolumeNewRecord.Account__c = recordId;
           insert objPipelineVolumeNewRecord;
           
           //updating parent account with child aggregations
        		AggregateChildAccountsToParent();
        	//End to update
        
           List<Pipeline_Volume__c> newListPipelineVolume = [Select Id,CreatedDate,Total_Estimated_Revenue__c,AN_Prill_Incumbent__c,AN_Prill_UOM__c,AN_Prill_Volume__c,
                                                            AN_Prill_Revenue__c,AN_Prill_GM__c,Bulk_Emulsion_Incumbent__c,Bulk_Emulsion_UOM__c,
                                                            Bulk_Emulsion_Volume__c,Bulk_Emulsion_Revenue__c,Bulk_Emulsion_GM__c,Small_Packaged_Incumbent__c,Small_Packaged_UOM__c,
                                                            Small_Packaged_Volume__c,Small_Packaged_Revenue__c,Small_Packaged_GM__c,Large_Packaged_Incumbent__c,Large_Packaged_UOM__c,
                                                            Large_Packaged_Volume__c, Large_Packaged_Revenue__c,Large_Packaged_GM__c, Dynamite_Incumbent__c,Dynamite_UOM__c,
                                                            Dynamite_Volume__c,Dynamite_Revenue__c,Dynamite_GM__c,Boosters_Incumbent__c,Boosters_UOM__c,Boosters_Volume__c,
                                                            Boosters_Revenue__c,Boosters_GM__c,Cord_Incumbent__c, Cord_UOM__c,Cord_Volume__c, Cord_Revenue__c, Cord_GM__c,
                                                            Nonelectrics_Incumbent__c, Nonelectrics_UOM__c, Nonelectrics_Volume__c, Nonelectrics_Revenue__c, Nonelectrics_GM__c,
                                                            Electronics_Incumbent__c, Electronics_UOM__c , Electronics_Volume__c, Electronics_Revenue__c, Electronics_GM__c,
                                                            Service_Incumbent__c, Service_Volume__c, Service_Revenue__c, Service_GM__c,Other_Incumbent__c, Other_Volume__c,
                                                            Other_Revenue__c , Other_GM__c, Active__c, ANFO_GM__c, ANFO_Incumbent__c, ANFO_Revenue__c,  ANFO_UOM__c, ANFO_Volume__c, Name, Fiscal_Year__c
                                                            From Pipeline_Volume__c
                                                            Where Id =: objPipelineVolumeNewRecord.Id Limit 1];

           listPipelineVolumes.add(newListPipelineVolume[0]);
           objPipelineVolume = objPipelineVolumeNewRecord;
           totalRevenue = getTotalrevenue(objPipelineVolume);
           totalMargin = getTotalMargin(objPipelineVolume);
           objPipelineVolumeNewRecord = new Pipeline_Volume__c();
           showNewRecordDiv = false;
           ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Info_Message_Record_Save));
           hideCurrentRecordDiv = true;
           displayOkButton = true;
       }
       else{
           displayOkButton = true;
           for(ApexPages.Message errMsg : ApexPages.getMessages()) {
           if(errMsg.getSummary() == 'Sales Pipeline Volume Name: You must enter a value'){
                displayOkButton = true;
           }
           }
       }
   }

    /**
     * Method to display Pipeline_Volume__c record onchange of SelectOption
     */
    public void displayPipelineVolume(){
        if(mapPipelineVolume.containsKey(selelctedValue)){
            objPipelineVolume = mapPipelineVolume.get(selelctedValue);
            totalRevenue = getTotalrevenue(objPipelineVolume);
            totalMargin = getTotalMargin(objPipelineVolume);
        }
    }

    /**
     * Method to delete Pipeline_Volume__c record on click of delete button
     */
    public void deletePipelineVolume(){

        Id getIDPipelineVolme = objPipelineVolume.ID;
        delete objPipelineVolume;
        /*if(objPipelineVolume != null){
            delete objPipelineVolume;
        }*/
        for(Integer index = 0; index < listPipelineVolumes.size(); index++){
            if(listPipelineVolumes[index].Id == getIDPipelineVolme){
                //delete objPipelineVolume;
                listPipelineVolumes.remove(index);

            }
        }
        if(listPipelineVolumes.size() == 0){
            hideCurrentRecordDiv = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Info_Message_No_Records));
            displayOkButton = true ;
            enableDeleteButton = false;
            enableMakeActiveButton = false;
        }
        else{
            objPipelineVolume = listPipelineVolumes[0];
            totalRevenue = getTotalrevenue(objPipelineVolume);
            totalMargin = getTotalMargin(objPipelineVolume);
        }


    }

    /**
     * Method to clear ApexPage Message
     */
    public void clearMessage() {
      ApexPages.getMessages().clear();
          displayOkButton = false;
    }

    /**
     * Method to mark Active__c field on Pipeline_Volume__c record to true and other records to false
     */
    public PageReference updateCurrentSalesPipelineVloume(){
        system.debug('-----in updateCurrentSalesPipelineVloume--' + refreshPage);
        updateListPipelineVolumes = new List<Pipeline_Volume__c>();
        objPipelineVolume.Active__c = true;
        updateListPipelineVolumes.add(objPipelineVolume);
        for(Pipeline_Volume__c pipelineVolumeObj  :listPipelineVolumes){
            if(pipelineVolumeObj.ID != objPipelineVolume.Id){
                pipelineVolumeObj.Active__c = false;
                updateListPipelineVolumes.add(pipelineVolumeObj);
            }
        }
        update updateListPipelineVolumes;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Info_Message_Record_Active));
        displayOkButton = true;
        
        
        //updating parent account with child aggregations
        	AggregateChildAccountsToParent();
        //End to update

        system.debug('-----in updateCurrentSalesPipelineVloume after changes--' + refreshPage);
        return null;
    }


    /**
     * Method to display NewRecord div and hide currentRecord showing div
     */
    public void showDetailEntry(){
        showNewRecordDiv = true;
        hideCurrentRecordDiv = false;
        hideSelectListButtons = false;
    }

    /**
     * Method to display currentRecord div and hide newRecord showing div
     */
    public void cancelrecord(){
        showNewRecordDiv = false;
        //hideCurrentRecordDiv = true;
        if(selelctedValue == '--None--'){
            hideSelectListButtons = false;
            hideCurrentRecordDiv = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Info_Message_No_Records));
            displayOkButton = true;
            hideSelectListButtons = true;
            enableDeleteButton = false;
            enableMakeActiveButton = false;
        }
        else{
            hideSelectListButtons = true;
            hideCurrentRecordDiv = true;
            enableDeleteButton = true;
            enableMakeActiveButton = true;
        }

    }
    
    private String formatAndAddCents(Decimal numValue) {
        List<String> args = new String[]{'0','number','###,###,##0.00'};
        String textValue = String.format(numValue.format(), args);    
        if (!textValue.contains('.')) {
            textValue = textValue  + '.00'; 
        } 
        return textValue;
    }

    /**
     * Method to get Total Revenue of Pipeline Volume record
     */
    public String getTotalrevenue(Pipeline_Volume__c pipelineVolume){
        Decimal totalRevenue = (pipelineVolume.AN_Prill_Revenue__c != null ? pipelineVolume.AN_Prill_Revenue__c : 0)+
                (pipelineVolume.ANFO_Revenue__c != null ? pipelineVolume.ANFO_Revenue__c : 0)+
                (pipelineVolume.Bulk_Emulsion_Revenue__c != null ? pipelineVolume.Bulk_Emulsion_Revenue__c : 0)+
                (pipelineVolume.Small_Packaged_Revenue__c != null ? pipelineVolume.Small_Packaged_Revenue__c : 0)+
                (pipelineVolume.Large_Packaged_Revenue__c != null ? pipelineVolume.Large_Packaged_Revenue__c : 0)+
                (pipelineVolume.Dynamite_Revenue__c != null ? pipelineVolume.Dynamite_Revenue__c : 0)+
                (pipelineVolume.Boosters_Revenue__c != null ? pipelineVolume.Boosters_Revenue__c : 0)+
                (pipelineVolume.Cord_Revenue__c != null ? pipelineVolume.Cord_Revenue__c : 0)+
                (pipelineVolume.Nonelectrics_Revenue__c != null ? pipelineVolume.Nonelectrics_Revenue__c : 0)+
                (pipelineVolume.Electronics_Revenue__c != null ? pipelineVolume.Electronics_Revenue__c : 0)+
                (pipelineVolume.Service_Revenue__c != null ? pipelineVolume.Service_Revenue__c : 0)+
                (pipelineVolume.Other_Revenue__c != null ? pipelineVolume.Other_Revenue__c : 0);
        return formatAndAddCents(totalRevenue);
    }

    /**
     * Method to get Total Margin of Pipeline Volume record
     */
    public String getTotalMargin(Pipeline_Volume__c pipelineVolume){
        Decimal totalMargin = (pipelineVolume.AN_Prill_GM__c != null ? pipelineVolume.AN_Prill_GM__c : 0)+
               (pipelineVolume.ANFO_GM__c != null ? pipelineVolume.ANFO_GM__c : 0)+
               (pipelineVolume.Bulk_Emulsion_GM__c != null ? pipelineVolume.Bulk_Emulsion_GM__c : 0)+
               (pipelineVolume.Small_Packaged_GM__c != null ? pipelineVolume.Small_Packaged_GM__c : 0)+
               (pipelineVolume.Large_Packaged_GM__c != null ? pipelineVolume.Large_Packaged_GM__c : 0)+
               (pipelineVolume.Dynamite_GM__c != null ? pipelineVolume.Dynamite_GM__c : 0)+
               (pipelineVolume.Boosters_GM__c != null ? pipelineVolume.Boosters_GM__c : 0)+
               (pipelineVolume.Cord_GM__c != null ? pipelineVolume.Cord_GM__c : 0)+
               (pipelineVolume.Nonelectrics_GM__c != null ? pipelineVolume.Nonelectrics_GM__c : 0)+
               (pipelineVolume.Electronics_GM__c != null ? pipelineVolume.Electronics_GM__c : 0)+
               (pipelineVolume.Service_GM__c != null ? pipelineVolume.Service_GM__c : 0)+
               (pipelineVolume.Other_GM__c != null ? pipelineVolume.Other_GM__c : 0);
        return formatAndAddCents(totalMargin);
    }

   /**
    * Method to validate fields of the PipeLine Volume record
    */
    public Boolean validateRecord(Pipeline_Volume__c pipeLineVolumneObj){
        String Row_must_contain_value = System.Label.Row_must_contain_value;


        if (!((pipeLineVolumneObj.AN_Prill_Incumbent__c == null || pipeLineVolumneObj.AN_Prill_Incumbent__c == '--None--') &&  pipeLineVolumneObj.AN_Prill_Volume__c == null
            && pipeLineVolumneObj.AN_Prill_Revenue__c == null && pipeLineVolumneObj.AN_Prill_GM__c == null) &&
            !((pipeLineVolumneObj.AN_Prill_Incumbent__c != null && pipeLineVolumneObj.AN_Prill_Incumbent__c != '--None--') &&  pipeLineVolumneObj.AN_Prill_Volume__c != null
            && pipeLineVolumneObj.AN_Prill_Revenue__c != null && pipeLineVolumneObj.AN_Prill_GM__c != null)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
            return false;
        }

        else if (!((pipeLineVolumneObj.ANFO_Incumbent__c == null || pipeLineVolumneObj.ANFO_Incumbent__c == '--None--') && pipeLineVolumneObj.ANFO_Volume__c == null
                 && pipeLineVolumneObj.ANFO_Revenue__c == null && pipeLineVolumneObj.ANFO_GM__c == null) &&
                 !((pipeLineVolumneObj.ANFO_Incumbent__c != null && pipeLineVolumneObj.ANFO_Incumbent__c != '--None--') && pipeLineVolumneObj.ANFO_Volume__c != null
                 && pipeLineVolumneObj.ANFO_Revenue__c != null && pipeLineVolumneObj.ANFO_GM__c != null)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
            return false;
        }

        else if (!((pipeLineVolumneObj.Bulk_Emulsion_Incumbent__c == null || pipeLineVolumneObj.Bulk_Emulsion_Incumbent__c == '--None--') && pipeLineVolumneObj.Bulk_Emulsion_Volume__c == null
                 && pipeLineVolumneObj.Bulk_Emulsion_Revenue__c == null && pipeLineVolumneObj.Bulk_Emulsion_GM__c == null) &&
                 !((pipeLineVolumneObj.Bulk_Emulsion_Incumbent__c != null && pipeLineVolumneObj.Bulk_Emulsion_Incumbent__c != '--None--') && pipeLineVolumneObj.Bulk_Emulsion_Volume__c != null
                 && pipeLineVolumneObj.Bulk_Emulsion_Revenue__c != null && pipeLineVolumneObj.Bulk_Emulsion_GM__c != null)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
            return false;
        }

        else if (!((pipeLineVolumneObj.Small_Packaged_Incumbent__c == null || pipeLineVolumneObj.Small_Packaged_Incumbent__c == '--None--') && pipeLineVolumneObj.Small_Packaged_Volume__c == null
                && pipeLineVolumneObj.Small_Packaged_Revenue__c == null && pipeLineVolumneObj.Small_Packaged_GM__c == null) &&
                !((pipeLineVolumneObj.Small_Packaged_Incumbent__c != null && pipeLineVolumneObj.Small_Packaged_Incumbent__c != '--None--')&& pipeLineVolumneObj.Small_Packaged_Volume__c != null
                && pipeLineVolumneObj.Small_Packaged_Revenue__c != null && pipeLineVolumneObj.Small_Packaged_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Large_Packaged_Incumbent__c == null || pipeLineVolumneObj.Large_Packaged_Incumbent__c == '--None--') && pipeLineVolumneObj.Large_Packaged_Volume__c == null
                && pipeLineVolumneObj.Large_Packaged_Revenue__c == null && pipeLineVolumneObj.Large_Packaged_GM__c == null) &&
                !((pipeLineVolumneObj.Large_Packaged_Incumbent__c != null && pipeLineVolumneObj.Large_Packaged_Incumbent__c != '--None--') && pipeLineVolumneObj.Large_Packaged_Volume__c != null
                && pipeLineVolumneObj.Large_Packaged_Revenue__c != null && pipeLineVolumneObj.Large_Packaged_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Dynamite_Incumbent__c == null || pipeLineVolumneObj.Dynamite_Incumbent__c == '--None--') && pipeLineVolumneObj.Dynamite_Volume__c == null
                && pipeLineVolumneObj.Dynamite_Revenue__c == null && pipeLineVolumneObj.Dynamite_GM__c == null) &&
                !((pipeLineVolumneObj.Dynamite_Incumbent__c != null && pipeLineVolumneObj.Dynamite_Incumbent__c != '--None--') && pipeLineVolumneObj.Dynamite_Volume__c != null
                && pipeLineVolumneObj.Dynamite_Revenue__c != null && pipeLineVolumneObj.Dynamite_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Boosters_Incumbent__c == null || pipeLineVolumneObj.Boosters_Incumbent__c == '--None--') && pipeLineVolumneObj.Boosters_Volume__c == null
                && pipeLineVolumneObj.Boosters_Revenue__c == null && pipeLineVolumneObj.Boosters_GM__c == null) &&
                !((pipeLineVolumneObj.Boosters_Incumbent__c != null && pipeLineVolumneObj.Boosters_Incumbent__c != '--None--') && pipeLineVolumneObj.Boosters_Volume__c != null
                && pipeLineVolumneObj.Boosters_Revenue__c != null && pipeLineVolumneObj.Boosters_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Cord_Incumbent__c == null || pipeLineVolumneObj.Cord_Incumbent__c == '--None--' ) && pipeLineVolumneObj.Cord_Volume__c == null
                && pipeLineVolumneObj.Cord_Revenue__c == null && pipeLineVolumneObj.Cord_GM__c == null) &&
                !((pipeLineVolumneObj.Cord_Incumbent__c != null  && pipeLineVolumneObj.Cord_Incumbent__c != '--None--' ) && pipeLineVolumneObj.Cord_Volume__c != null
                && pipeLineVolumneObj.Cord_Revenue__c != null && pipeLineVolumneObj.Cord_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Nonelectrics_Incumbent__c == null ||pipeLineVolumneObj.Nonelectrics_Incumbent__c == '--None--' ) && pipeLineVolumneObj.Nonelectrics_Volume__c == null
                && pipeLineVolumneObj.Nonelectrics_Revenue__c == null && pipeLineVolumneObj.Nonelectrics_GM__c == null) &&
                !((pipeLineVolumneObj.Nonelectrics_Incumbent__c != null && pipeLineVolumneObj.Nonelectrics_Incumbent__c != '--None--' )  && pipeLineVolumneObj.Nonelectrics_Volume__c != null
                && pipeLineVolumneObj.Nonelectrics_Revenue__c != null && pipeLineVolumneObj.Nonelectrics_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (! (  (pipeLineVolumneObj.Electronics_Incumbent__c == null || pipeLineVolumneObj.Electronics_Incumbent__c == '--None--') && pipeLineVolumneObj.Electronics_Volume__c == null
                && pipeLineVolumneObj.Electronics_Revenue__c == null && pipeLineVolumneObj.Electronics_GM__c == null) &&
                !((pipeLineVolumneObj.Electronics_Incumbent__c != null && pipeLineVolumneObj.Electronics_Incumbent__c != '--None--')  && pipeLineVolumneObj.Electronics_Volume__c != null
                && pipeLineVolumneObj.Electronics_Revenue__c != null && pipeLineVolumneObj.Electronics_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Service_Incumbent__c == null || pipeLineVolumneObj.Service_Incumbent__c == '--None--') && pipeLineVolumneObj.Service_Volume__c == null
                && pipeLineVolumneObj.Service_Revenue__c == null && pipeLineVolumneObj.Service_GM__c == null) &&
                !((pipeLineVolumneObj.Service_Incumbent__c != null && pipeLineVolumneObj.Service_Incumbent__c != '--None--') && pipeLineVolumneObj.Service_Volume__c != null
                && pipeLineVolumneObj.Service_Revenue__c != null && pipeLineVolumneObj.Service_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }

        else if (!((pipeLineVolumneObj.Other_Incumbent__c == null || pipeLineVolumneObj.Other_Incumbent__c == '--None--') && pipeLineVolumneObj.Other_Volume__c == null
                && pipeLineVolumneObj.Other_Revenue__c == null && pipeLineVolumneObj.Other_GM__c == null) &&
                !((pipeLineVolumneObj.Other_Incumbent__c != null && pipeLineVolumneObj.Other_Incumbent__c != '--None--') && pipeLineVolumneObj.Other_Volume__c != null
                && pipeLineVolumneObj.Other_Revenue__c != null && pipeLineVolumneObj.Other_GM__c != null)){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Row_must_contain_value));
                return false;
        }
        return true;
    }
    
    public void AggregateChildAccountsToParent(){
    	//updating parent account with child aggregations
        Account updatedAccount = [SELECT Id,Name, ParentId FROM Account WHERE Id =: recordId];
        String parentAccountId = updatedAccount.ParentId;
       	if(parentAccountId == null || parentAccountId =='')
        	{
               //system.debug('Empty parentId' + updatedAccount.ParentId);
            }else{
              //system.debug('Test Efficiency' + updatedAccount.ParentId);
           		AggregateResult[] sumChildAccount = [SELECT ParentId, SUM(Account_Revenue_Rollup__c)acctrr,SUM(Account_Dyno_Revenue_Rollup__c)acctdrr,
                                                  SUM(Account_Gross_Margin_Rollup__c)acctgmr,SUM(Account_Dyno_Gross_Margin_Rollup__c)acctdgmr,
                                                  SUM(Account_ISPE_Revenue_Rollup__c)acctirr,SUM(Account_Dyno_ISPE_Revenue_Rollup__c)acctdir,
                                                  SUM(Account_AN_Products__c)acctap,SUM(Account_AN_Products_Rollup__c)acctapr,SUM(Account_Dyno_AN_Products_Rollup__c)acctdapr
                                                  FROM Account WHERE ParentId =: updatedAccount.ParentId GROUP BY ParentId];
                       
          		Account ParentAccount = [SELECT Id,ParentId,Total_Child_Revenue__c,Total_Child_Dyno_Revenue__c,
                                             Total_Child_Gross_Margin__c,Total_Child_Dyno_Gross_Margin__c,
                                             Total_Child_ISPE_Revenue__c,Total_Child_Dyno_ISPE_Revenue__c,
                                             Total_Child_AN_Products__c,Total_Child_Dyno_AN_Products__c
                                             FROM Account WHERE Id =: updatedAccount.ParentId];
                       
         		ParentAccount.Total_Child_Revenue__c 	=  (Decimal)sumChildAccount[0].get('acctrr');
             	ParentAccount.Total_Child_Dyno_Revenue__c 	=  (Decimal)sumChildAccount[0].get('acctdrr');
               	ParentAccount.Total_Child_Gross_Margin__c 	=  (Decimal)sumChildAccount[0].get('acctgmr');
             	ParentAccount.Total_Child_Dyno_Gross_Margin__c =  (Decimal)sumChildAccount[0].get('acctdgmr');
           		ParentAccount.Total_Child_ISPE_Revenue__c 	=  (Decimal)sumChildAccount[0].get('acctirr');
    			ParentAccount.Total_Child_Dyno_ISPE_Revenue__c 	=  (Decimal)sumChildAccount[0].get('acctdir');
            	ParentAccount.Total_Child_AN_Products__c 	=  (Decimal)sumChildAccount[0].get('acctapr');
              	ParentAccount.Total_Child_Dyno_AN_Products__c 	=  (Decimal)sumChildAccount[0].get('acctdapr');
                
                       	update ParentAccount;                       
      		}
        	//End to update
		}

}