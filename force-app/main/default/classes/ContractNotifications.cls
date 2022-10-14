public with sharing class ContractNotifications {
        
        private Dyno_Nobel_Contract__c mcontract;
        
        public ContractNotifications(ApexPages.StandardController contractController) {
                
                Id cId = contractController.getId();
                mcontract = [SELECT What_are_we_offering__c FROM Dyno_Nobel_Contract__c WHERE Id = :cId];
                
        }
        
        public boolean hasISSelected {
                get {
                        return mcontract.What_are_we_offering__c != null && mcontract.What_are_we_offering__c.contains('IS');
                }
        }
        
        public boolean hasANSelected {
                get {
                        return mcontract.What_are_we_offering__c != null && mcontract.What_are_we_offering__c.contains('AN');
                }
        }
        
        public boolean hasServiceSelected {
                get {
                        return mcontract.What_are_we_offering__c != null && mcontract.What_are_we_offering__c.contains('Service');
                }
        }
        
        public boolean hasTransportationSelected {
                get {
                        return mcontract.What_are_we_offering__c != null && mcontract.What_are_we_offering__c.contains('Transportation');
                }
        }
        
}