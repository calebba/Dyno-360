public with sharing class TransferPricing {

        public List<SelectOption> TPAs { get; set; }
        public List<String> SelectedTPAs { get; set; }
        
        public List<SelectOption> PBs { get; set; }
        public String SelectedPB { get; set; }
        
        public Transfer_Data__c dummyTD { get; set; }
        
        /*public List<ErrorElement> ErrorElements { get; set; }
        public boolean HasErrors {
                get {
                        return ErrorElements != null && ErrorElements.size() > 0;
                }
        }*/
        
        public boolean Generated { get; set; }
        /*public integer RecordsCreated { get; set; }
        public integer RecordsUpdated { get; set; }*/
        
        public boolean ReviewError { get; set; }
        
        public boolean Published { get; set; }
        public integer RecordsPublished { get; set; }
                
        public TransferPricing() {
                TPAs = new List<SelectOption>();
                for (Transfer_Pricing_Account__c tpa : [SELECT Id, Name FROM Transfer_Pricing_Account__c ORDER BY Name])
                        TPAs.add(new SelectOption(tpa.Id, tpa.Name));

                PBs = new List<SelectOption>();
                for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name])
                        PBs.add(new SelectOption(pb.Id, pb.Name));
                        
                dummyTD = new Transfer_Data__c();
                
                Generated = false;
                Published = false;
                ReviewError = false;
                RedirectToReview = false;
        }
        
        public void Generate() {
                
                Published = false;
                Generated = false;
                
                Map<Id, Transfer_Pricing_Account__c> exTpas = new Map<Id, Transfer_Pricing_Account__c>([SELECT Id, CurrencyIsoCode, Name FROM Transfer_Pricing_Account__c WHERE Id in :SelectedTPAs]);
                
                List<Account_Discount__c> existingAds = [SELECT Id, Start_Date__c, End_Date__c, CurrencyIsoCode, Transfer_Pricing_Account__c, PHL1__c, PHL2__c, PHL3__c, PHL1__r.Name, PHL2__r.Full_PHL2__c, PHL3__r.Full_PHL3__c, Material_Item__c, Discount_Percent__c FROM Account_Discount__c WHERE Transfer_Pricing_Account__c in :SelectedTPAs];
                
                List<Transfer_Data__c> existingTDs = [SELECT Id, Transfer_Pricing_Account__c, Valid_From__c, Valid_To__c, Pricelist__c, Material__c,
                                                                                                        Base_Price__c, Discount__c, Discount_From__c FROM Transfer_Data__c WHERE Transfer_Pricing_Account__c in :SelectedTPAs];
                                                                                                        
                TransferPricingbatch.Criteria bCriteria = new TransferPricingbatch.Criteria();
                bCriteria.ExistingAds = existingAds;
                bCriteria.ExistingTDs = existingTDs;
                bCriteria.ExTpas = exTpas;
                bCriteria.PricebookId = SelectedPB;
                bCriteria.UserEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;
                bCriteria.ValidFrom = dummyTD.Valid_From__c;
                bCriteria.ValidTo = dummyTD.Valid_To__c;
                
                database.executeBatch(new TransferPricingBatch(bCriteria), 10);
                
                
                Generated = true;
                RedirectToReview = false;
        }
        
        public boolean RedirectToReview { get; set; }
        public string ReviewLink { get; set; }
        
        public void Review() {
                
                RedirectToReview = false;
                ReviewError = false;
                
                Transfer_Pricing_Report_URL__c tpru = null;
                try {
                        tpru = [SELECT Name, Report_Id__c FROM Transfer_Pricing_Report_URL__c LIMIT 1];
                } catch (Exception ex) {
                        ReviewError = true;
                        return;
                }
                
                List<Transfer_Pricing_Account__c> Tpas = [SELECT Id, Name FROM Transfer_Pricing_Account__c WHERE Id in :SelectedTPAs];
                string tpastr = '';
                for (Transfer_Pricing_Account__c Tpa : Tpas) {
                        if (tpastr != '')
                                tpastr += ',';
                        tpastr += Tpa.Name;
                }
                
                RedirectToReview = true;
                ReviewLink = '/' + tpru.Report_Id__c + '?pv0=' + tpastr;
        }
        
        public void Publish() {
                
                Published = false;
                Generated = false;
                
                List<Transfer_Data__c> tds = [SELECT Id FROM Transfer_Data__c WHERE Ready_For_Transfer__c = false AND (Date_Difference__c = null OR Date_Difference__c > 0)];
                
                for (Transfer_Data__c td : tds)
                        td.Ready_For_Transfer__c = true;
                        
                update tds;
                
                RecordsPublished = tds.size();
                
                Published = true;
                RedirectToReview = false;
        }
        
        /*public class ErrorElement {
                public Product2 Product { get; set; }
                public Transfer_Pricing_Account__c TPA { get; set; }
                public ErrorElement(Product2 prod, Transfer_Pricing_Account__c tpacc) {
                        Product = prod;
                        TPA = tpacc;
                }
        }*/

}