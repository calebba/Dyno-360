public class AccountDiscountController {
    
    Public Account_Discount__c ad {get; set;}
    
    public String selectedPHL1 {get; set;}
    public String selectedPHL2 {get; set;}
    public String selectedPHL3 {get; set;}
    public String materialCode {get; set;}
    
    public AccountDiscountController (ApexPages.StandardController controller){
        if (controller.getId() == null) {
            ad = new Account_Discount__c();
            ad.Account__c = ApexPages.currentPage().getParameters().get('eid');
            ad.Transfer_Pricing_Account__c = ApexPages.currentPage().getParameters().get('CF00NV0000000aTiU_lkid');
        } else {
            ad = [SELECT Id, Account__c, Transfer_Pricing_Account__c, Discount_Percent__c, Start_Date__c, End_Date__c, Discount_Type2__c, PHL1__c, PHL1__r.Name, PHL2__c, PHL2__r.PHL2__c, PHL3__c, PHL3__r.PHL3__c, Material_Item__c, Material_Item__r.Material_Code__c FROM Account_Discount__c WHERE Id = :controller.getId()];
        }
        
        selectedPHL1 = '';
        loadPHL1Options();
        if (ad.PHL1__c != null)
            selectedPHL1 = ad.PHL1__r.Name;
        selectedPHL2 = '';
        loadPHL2Options();
        if (ad.PHL2__c != null)
            selectedPHL2 = ad.PHL2__r.PHL2__c;
        selectedPHL3 = '';
        loadPHL3Options();
        if (ad.PHL3__c != null)
            selectedPHL3 = ad.PHL3__r.PHL3__c;
        materialCode = '';
        loadMatOptions();
        if (ad.Material_Item__c != null)
            materialCode = ad.Material_Item__r.Material_Code__c;
    }
    
    public List<SelectOption> phl1Options { get; set; }
    public void loadPHL1Options() {
        phl1Options = new List<SelectOption>();
        phl1Options.add(new SelectOption('','--' + System.Label.None + '--'));
        selectedPHL1 = '';
        for(Product_Grouping__c currPg : [SELECT Name, Title__c FROM Product_Grouping__c order by Name asc])
            phl1Options.add(new SelectOption(currPg.Name, currPg.Name + ' - ' + currPg.Title__c));
        loadPHL2Options();
    }
    
    public List<SelectOption> phl2Options { get; set; }
    public void loadPHL2Options() {
        phl2Options = new List<SelectOption>();
        phl2Options.add(new SelectOption('','--' + System.Label.None + '--'));
        selectedPHL2 = '';
        if (selectedPHL1 != null && selectedPHL1 != '')
            for(PHL2__c currPg : [SELECT PHL2__c, Full_PHL2__c, Description__c FROM PHL2__c WHERE PHL1__c = :selectedPHL1 order by PHL2__c])
                phl2Options.add(new SelectOption(currPg.PHL2__c, currPg.Full_PHL2__c + ' - ' + currPg.Description__c));
        loadPHL3Options();
    }
    
    public List<SelectOption> phl3Options { get; set; }
    public void loadPHL3Options() {
        phl3Options = new List<SelectOption>();
        phl3Options.add(new SelectOption('','--' + System.Label.None + '--'));
        selectedPHL3 = '';
        if (selectedPHL2 != null && selectedPHL2 != '')
            for(PHL3__c currPg : [SELECT PHL3__c, Full_PHL3__c, Description__c FROM PHL3__c WHERE PHL1__c = :selectedPHL1 AND PHL2__c = :selectedPHL2 order by PHL3__c])
                phl3Options.add(new SelectOption(currPg.PHL3__c, currPg.Full_PHL3__c + ' - ' + currPg.Description__c));
        loadMatOptions();
    }

    public List<SelectOption> matOptions { get; set; }
    public void loadMatOptions() {
        matOptions = new List<SelectOption>();
        matOptions.add(new SelectOption('','--' + System.Label.None + '--'));
        materialCode = '';
        System.Debug('selectedPHLs ->' + selectedPHL1 + '<->' + selectedPHL2 + '<->' + selectedPHL3 + '<-');
        if ((selectedPHL1 != null && selectedPHL1 != '') || (selectedPHL2 != null && selectedPHL2 != '') || (selectedPHL3 != null && selectedPHL3 != '')) {
            boolean gotCond = false;
            string matQuery = 'SELECT Id, Material_Code__c, Name FROM Material_Item__c ';
            if (selectedPHL1 != null && selectedPHL1 != '') {
                matQuery += ' WHERE PHL1__c = \'' + selectedPHL1 + '\'';
                gotCond = true;
            }
            if (selectedPHL2 != null && selectedPHL2 != '') {
                if (gotCond)
                    matQuery += ' AND PHL2__c = \'' + selectedPHL2 + '\'';
                else
                    matQuery += ' WHERE PHL2__c = \'' + selectedPHL2 + '\'';
                gotCond = true;
            }
            if (selectedPHL3 != null && selectedPHL3 != '') {
                if (gotCond)
                    matQuery += ' AND PHL3__c = \'' + selectedPHL3 + '\'';
                else
                    matQuery += ' WHERE PHL3__c = \'' + selectedPHL3 + '\'';
                gotCond = true;
            }
            matQuery += ' ORDER BY Material_Code__c';
            for(Material_Item__c currPg : database.query(matQuery))
                matOptions.add(new SelectOption(currPg.Material_Code__c, currPg.Name));
        }
    }
    
    public boolean displayMaterialsSelectList {
    	get {
    		return (selectedPHL1 != '' || selectedPHL2 != '' || selectedPHL3 != '') && matOptions.size() < 1000;
    	}
    }
    
    public PageReference SaveAD() {
        if (selectedPHL1 != null && selectedPHL1 != '')
            ad.PHL1__c = [SELECT Id FROM Product_Grouping__c WHERE Name = :selectedPHL1 LIMIT 1].Id;
        else
            ad.PHL1__c = null;
        if (selectedPHL2 != null && selectedPHL2 != '')
            ad.PHL2__c = [SELECT Id FROM PHL2__c WHERE PHL1__c = :selectedPHL1 AND PHL2__c = :selectedPHL2 LIMIT 1].Id;
        else
            ad.PHL2__c = null;
        if (selectedPHL3 != null && selectedPHL3 != '')
            ad.PHL3__c = [SELECT Id FROM PHL3__c WHERE PHL1__c = :selectedPHL1 AND PHL2__c = :selectedPHL2 AND PHL3__c = :selectedPHL3 LIMIT 1].Id;
        else
            ad.PHL3__c = null;
        try {
            if (materialCode != null && materialCode != '')
                ad.Material_Item__c = [SELECT Id FROM Material_Item__c WHERE Material_Code__c = :materialCode LIMIT 1].Id;
            else
                ad.Material_Item__c = null;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Material Code not found'));
            return null;
        }
        if (ad.PHL1__c == null && ad.PHL2__c == null && ad.PHL3__c == null && ad.Material_Item__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You need to select at least PHL1 or Material'));
            return null;
        }
        try {
            upsert ad;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        
        if (ad.Account__c != null)
            return new PageReference('/' + ad.Account__c);
            
        if (ad.Transfer_Pricing_Account__c != null)
            return new PageReference('/' + ad.Transfer_Pricing_Account__c);
        
        return null;
    }
    
    public PageReference SaveAndNew() {
            if (selectedPHL1 != null && selectedPHL1 != '')
            ad.PHL1__c = [SELECT Id FROM Product_Grouping__c WHERE Name = :selectedPHL1 LIMIT 1].Id;
        else
            ad.PHL1__c = null;
        if (selectedPHL2 != null && selectedPHL2 != '')
            ad.PHL2__c = [SELECT Id FROM PHL2__c WHERE PHL1__c = :selectedPHL1 AND PHL2__c = :selectedPHL2 LIMIT 1].Id;
        else
            ad.PHL2__c = null;
        if (selectedPHL3 != null && selectedPHL3 != '')
            ad.PHL3__c = [SELECT Id FROM PHL3__c WHERE PHL1__c = :selectedPHL1 AND PHL2__c = :selectedPHL2 AND PHL3__c = :selectedPHL3 LIMIT 1].Id;
        else
            ad.PHL3__c = null;
        try {
            if (materialCode != null && materialCode != '')
                ad.Material_Item__c = [SELECT Id FROM Material_Item__c WHERE Material_Code__c = :materialCode LIMIT 1].Id;
            else
                ad.Material_Item__c = null;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Material Code not found'));
            return null;
        }
        if (ad.PHL1__c == null && ad.PHL2__c == null && ad.PHL3__c == null && ad.Material_Item__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You need to select at least PHL1 or Material'));
            return null;
        }
        try {
            upsert ad;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        
        string urlBase = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference pageRef = null;
        if (ad.Account__c != null)
            pageRef = new PageReference(urlBase + '/apex/AccountDiscountEditPage?CF00NQ0000000rmtp_lkid=' + ad.Account__c);
        if (ad.Transfer_Pricing_Account__c != null)
            pageRef = new PageReference(urlBase + '/apex/AccountDiscountEditPage?CF00NQ0000000tOfG_lkid=' + ad.Transfer_Pricing_Account__c);
    
        return pageRef;
    }
    
    public static testMethod void test1() {
        Account a = new Account();
        a.Name = 'Lucian233743';
        insert a;
        
        AccountDiscountController adc = new AccountDiscountController(new ApexPages.StandardController(new Account_Discount__c()));
        adc.selectedPHL1 = adc.phl1Options[1].getValue();  
        adc.loadPHL2Options();
        adc.selectedPHL2 = adc.phl2Options[1].getValue();  
        adc.loadPHL3Options();
        adc.ad.Account__c = a.Id;
        adc.ad.Discount_Percent__c = 1;
        adc.ad.Start_Date__c = Date.today().addDays(-1);
        adc.ad.End_Date__c = Date.today().addDays(1);
        adc.SaveAD();
        adc.SaveAndNew();
        
        Account_Discount__c ad = [SELECT Id, Discount_Percent__c FROM Account_Discount__c WHERE Account__c = :a.Id LIMIT 1];
        System.assertEquals(1, ad.Discount_Percent__c);
    }
  
}