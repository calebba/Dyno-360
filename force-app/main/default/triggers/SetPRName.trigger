trigger SetPRName on Vertiba_Project_Role__c (before insert, before update) {


    List<Id> prjIds = new List<Id>();
    List<Id> rolIds = new List<Id>();

    for (Vertiba_Project_Role__c pr : Trigger.new) {
        prjIds.add(pr.Project__c);
        rolIds.add(pr.Role__c);
    }

    /*Map<Id, Product2> rols = new Map<Id, Product2>([SELECT Name FROM Product2 WHERE Id in :rolIds]);
    Map<Id, Vertiba_Project__c> prjs = new Map<Id, Vertiba_Project__c>([SELECT Name, Account__r.Name FROM Vertiba_Project__c WHERE Id in :prjIds]);

    for (Vertiba_Project_Role__c pr : Trigger.new) {
        string roleName = '';
        try { roleName = rols.get(pr.Role__c).Name; } catch (Exception ex) {}
        if (roleName == null) roleName = '';
        string accName = '';
        try { accName = prjs.get(pr.Project__c).Account__r.Name; } catch (Exception ex) {}
        if (accName == null) accName = '';
        string projName = '';
        try { projName = prjs.get(pr.Project__c).Name; } catch (Exception ex) {}
        if (projName == null) projName = '';
        if ((roleName.length() + accName.length() + projName.length()) > 77) {
            if (roleName.length() > 20) {
                roleName = roleName.substring(0, 20);
            }
            if (accName.length() > 42) {
                accName = accName.substring(0, 42);
            }
            if (projName.length() > 15) {
                projName = projName.substring(0, 15);
            }
        }
        pr.Name = roleName + '-' + accName + '(' + projName + ')';
    }*/
  
}