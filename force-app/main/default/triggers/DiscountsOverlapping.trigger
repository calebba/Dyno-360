trigger DiscountsOverlapping on Account_Discount__c (after insert) {

    List<Id> accountIds = new List<Id>();
    List<Id> traccIds = new List<Id>();
    
    for (Account_Discount__c ad : Trigger.new) {
        if (ad.Account__c != null)
            accountIds.add(ad.Account__c);
        if (ad.Transfer_Pricing_Account__c != null)
            traccIds.add(ad.Transfer_Pricing_Account__c);
    }
    
    List<Account_Discount__c> oldAds = [SELECT Id, Account__c, Start_Date__c, End_Date__c, Transfer_Pricing_Account__c, 
                                               Discount_Type2__c, PHL1__c, PHL2__c, PHL3__c, Discount_Percent__c, Material_Item__c 
                                          FROM Account_Discount__c WHERE (Account__c in :accountIds OR Transfer_Pricing_Account__c in :traccIds) AND Id not in :Trigger.new];
    List<Account_Discount__c> delAds = new List<Account_Discount__c>();
    List<Account_Discount__c> newAds = new List<Account_Discount__c>();
    
    for (Account_Discount__c newAd : Trigger.new) {
        for (Account_Discount__c oldAd : oldAds) {
            if (oldAd.Account__c == newAd.Account__c && oldAd.Transfer_Pricing_Account__c == newAd.Transfer_Pricing_Account__c &&
                    oldAd.Discount_Type2__c == newAd.Discount_Type2__c && oldAd.PHL1__c == newAd.PHL1__c && oldAd.PHL2__c == newAd.PHL2__c &&
                    oldAd.PHL3__c == newAd.PHL3__c && oldAd.Material_Item__c == newAd.Material_Item__c) {
                
                Date oldSD = oldAd.Start_Date__c; 
                Date oldED = oldAd.End_Date__c;
                boolean modified = false;
                if (oldSD < newAd.Start_Date__c && oldEd >= newAd.Start_Date__c) {
                    oldAd.End_Date__c = newAd.Start_Date__c.addDays(-1);
                    modified = true;
                }
                if (oldED > newAd.End_Date__c && oldSD <= newAd.End_Date__c) {
                    if (!modified)
                        oldAd.Start_Date__c = newAd.End_Date__c.addDays(1);
                    else {
                        Account_Discount__c oldAd2 = oldAd.Clone(false, true);
                        oldAd2.End_Date__c = oldED;
                        oldAd2.Start_Date__c = newAd.End_Date__c.addDays(1);
                        newAds.add(oldAd2);
                    }
                }
                if (oldSD >= newAd.Start_Date__c && oldEd <= newAd.End_Date__c)
                    delAds.add(oldAd);
            }
        }
    }
    
    if (newAds.size() > 0)
        insert newAds;
    update oldAds;
    if (delAds.size() > 0)
        delete delAds;

}