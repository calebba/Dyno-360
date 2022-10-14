public class ChooseContractApprovals {
	//tender review
	public List<String> selectedUsers { get; set; }
	public List<SelectOption> usersList { get; set; }
	public List<String> selectedTenderRev { get; set; }
	public List<SelectOption> SelectedTenderRevList { get; set; }
	//tender approval
	public List<String> selectedUsersTenderApp { get; set; }
	public List<SelectOption> usersTenderAppList { get; set; }
	public List<String> selectedTenderApp { get; set; }
	public List<SelectOption> SelectedTenderAppList { get; set; }
	//contract approval
	public List<String> selectedUsersContractApp { get; set; }
	public List<SelectOption> usersContractAppList { get; set; }
	public List<String> selectedContractApp { get; set; }
	public List<SelectOption> SelectedContractAppList { get; set; }
	
	public String contractId { get; set; }
	public String userLicenseId { get; set; }
	public List<Profile> profileIdList { get; set; }
	
	private List<SelectOption> initSelectedList(List<String> selectedElem, List<User> allUsers) {
		List<SelectOption> options = new List<SelectOption>();
		
		Map<String,String> selectedElemMap = new Map<String,String>();
		for(String e : selectedElem) {
			selectedElemMap.put(e,e);
		}
		
		for (User u : allUsers) {
			if (selectedElemMap.containsKey(u.Id)) {
				options.add(new SelectOption(u.Id, u.Name));
			}
		}
		return options;
	}
	
	public ChooseContractApprovals() {
		userLicenseId = [select id, name from userlicense where name = 'Salesforce'].Id;
		profileIdList = [select userLicenseId from profile where userlicenseId = :userLicenseId];
		List<User> allUsersList = [SELECT Id, Name FROM User WHERE IsActive = true AND profileId IN :profileIdList AND Authorized_Approver__c = true order by Name asc];
		
		contractId = ApexPages.currentPage().getParameters().get('contractId');
		Dyno_Nobel_Contract__c contract = [SELECT Id, Status__c, Contract_Approval_Ids__c, Tender_Approval_Ids__c, Tender_Review_Ids__c
											FROM Dyno_Nobel_Contract__c WHERE Id = :contractId];
		
		selectedTenderRev = new List<String>();
		selectedUsers = new List<String>();
		if (contract.Tender_Review_Ids__c != null && contract.Tender_Review_Ids__c != '') {
			SelectedTenderRevList = initSelectedList(contract.Tender_Review_Ids__c.split(','), allUsersList);
			usersList = getUserList(contract.Tender_Review_Ids__c.split(','));
		} else {
			SelectedTenderRevList = new List<SelectOption>();
			usersList = getUserList(selectedTenderRev);
		}
		
		
		selectedTenderApp = new List<String>();
		selectedUsersTenderApp = new List<String>();
		if (contract.Tender_Approval_Ids__c != null && contract.Tender_Approval_Ids__c != '') {
			SelectedTenderAppList = initSelectedList(contract.Tender_Approval_Ids__c.split(','), allUsersList);
			usersTenderAppList = getUserList(contract.Tender_Approval_Ids__c.split(','));
		} else {
			SelectedTenderAppList = new List<SelectOption>();
			usersTenderAppList = getUserList(selectedTenderApp);
		}
		
		
		selectedContractApp = new List<String>();
		selectedUsersContractApp = new List<String>();
		if (contract.Contract_Approval_Ids__c != null && contract.Contract_Approval_Ids__c != '') {
			SelectedContractAppList = initSelectedList(contract.Contract_Approval_Ids__c.split(','), allUsersList);
			usersContractAppList = getUserList(contract.Contract_Approval_Ids__c.split(','));
		} else {
			SelectedContractAppList = new List<SelectOption>();
			usersContractAppList = getUserList(selectedContractApp);
		}
		
	}
	
	public List<SelectOption> getUserList(List<String> selectedIds) {
		List<SelectOption> opt = new List<SelectOption>();
		System.debug('selectedIds:::' + selectedIds );
		//List<User> usersList = [SELECT Id, Name FROM User WHERE Id NOT IN :selectedIds AND IsActive = true AND profileId IN :profileIdList AND Authorized_Approver__c = true order by Name asc];
		List<User> usersList = [SELECT Id, Name FROM User WHERE Id NOT IN :selectedIds AND IsActive = true AND Authorized_Approver__c = true order by Name asc];
		for (User u : usersList) {
			opt.add(new SelectOption(u.Id, u.Name));
		}
		return opt;
	}
	
	public void addTenderRev() {
		SelectedTenderRevList = addElements(selectedUsers, SelectedTenderRevList, usersList);
		System.debug('SelectedTenderRevList.size():::' + SelectedTenderRevList.size());
		
		usersList = removeFromQuery(SelectedTenderRevList);
	}
	
	public void removeTenderRev() {
		SelectedTenderRevList = removeElements(selectedTenderRev,SelectedTenderRevList);
		usersList = removeFromQuery(SelectedTenderRevList);
	}
	
	public void addTenderApp() {
		SelectedTenderAppList = addElements(selectedUsersTenderApp, SelectedTenderAppList, usersTenderAppList);
		usersTenderAppList = removeFromQuery(SelectedTenderAppList);
	}
	
	public void removeTenderApp() {
		SelectedTenderAppList = removeElements(selectedTenderApp,SelectedTenderAppList);
		usersTenderAppList = removeFromQuery(SelectedTenderAppList);
	}
	
	public void addContractApp() {
		SelectedContractAppList = addElements(selectedUsersContractApp, SelectedContractAppList, usersContractAppList);
		usersContractAppList = removeFromQuery(SelectedContractAppList);
	}
	
	public void removeContractApp() {
		SelectedContractAppList = removeElements(selectedContractApp,SelectedContractAppList);
		usersContractAppList = removeFromQuery(SelectedContractAppList);
	}
	
	private List<SelectOption> addElements(List<String> selectedElemList, List<SelectOption> elemList, List<SelectOption> allUserList) {
		Map<String,String> selectedElemMap = new Map<String,String>();
		for(String u : selectedElemList) {
			selectedElemMap.put(u,u);
		}
		if ((selectedElemMap.size() + elemList.size()) > 25) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You can choose maximum 25 approvers!'));
			return elemList;
		}
		System.debug('selectedElemList:::' + selectedElemList);
		for (integer i = 0; i < allUserList.size(); i++) {
			if (selectedElemMap.containsKey(allUserList.get(i).getValue())) {
				elemList.add(new SelectOption(allUserList.get(i).getValue(),allUserList.get(i).getLabel()));
			}
		}
		
		System.debug('elemList:::' + elemList);
		return elemList;
	}
	
	private List<SelectOption> removeElements(List<String> selectedElemList, List<SelectOption> elemList) {
		Map<String,String> selectedElemMap = new Map<String,String>();
		for(String u : selectedElemList) {
			selectedElemMap.put(u,u);
		}
		List<SelectOption> newTenderList = new List<SelectOption>();
		for (integer i = 0; i < elemList.size(); i++) {
			if (!selectedElemMap.containsKey(elemList.get(i).getValue())) {
				newTenderList.add(elemList.get(i));
			}
		}
		elemList = newTenderList;
		return elemList;
	}
	
	private List<SelectOption> removeFromQuery(List<SelectOption> elemList) {
		List<String> removeFromQueryList  = new List<String>();
		for (integer i = 0; i < elemList.size(); i++) {
			removeFromQueryList.add(elemList.get(i).getValue());
		}
		System.debug('elemList:::' + elemList);
		return getUserList(removeFromQueryList);
	}
	
	public PageReference Save(){
		Dyno_Nobel_Contract__c contract = [SELECT Id, Status__c, Contract_Approval_Ids__c, Tender_Approval_Ids__c, Tender_Review_Ids__c, Approver_1__c,
											Approver_2__c, Approver_3__c, Approver_4__c, Approver_5__c, Approver_6__c, Approver_7__c, Approver_8__c, Approver_9__c,
											Approver_10__c, Approver_11__c, Approver_12__c, Approver_13__c, Approver_14__c, Approver_15__c, Approver_16__c, Approver_17__c, 
											Approver_18__c, Approver_19__c, Approver_20__c, Approver_21__c, Approver_22__c, Approver_23__c, Approver_24__c
											 FROM Dyno_Nobel_Contract__c WHERE Id = :contractId];
		System.debug('string:::' + getStringSelectedIds(SelectedTenderRevList));
		contract.Contract_Approval_Ids__c = getStringSelectedIds(SelectedContractAppList);
		contract.Tender_Approval_Ids__c = getStringSelectedIds(SelectedTenderAppList);
		contract.Tender_Review_Ids__c = getStringSelectedIds(SelectedTenderRevList);
		System.debug('contract.Status__c:::' + contract.Status__c);
		if (contract.Status__c == 'Tender Notification' && contract.Tender_Review_Ids__c != '') {
			setApproversIds(contract, contract.Tender_Review_Ids__c.split(','));
		} else if (contract.Status__c == 'Tender Approval' && contract.Tender_Approval_Ids__c != '') {
			setApproversIds(contract, contract.Tender_Approval_Ids__c.split(','));
		} else if (contract.Status__c == ' Final Contract' && contract.Contract_Approval_Ids__c != '') {
			setApproversIds(contract, contract.Contract_Approval_Ids__c.split(','));
		} 
		
		update contract;
		return new PageReference('/' + contractId);
	}
	
	public PageReference Cancel() {
		return new PageReference('/' + contractId);
	}
	
	private void setApproversIds(Dyno_Nobel_Contract__c contract, List<String> idsList) {
		//remove all existing approvers
		for (integer i=0; i < 24; i++) {
			contract.put('Approver_' + (i+1) + '__c', null);
		}
		//set new approvers
		for (integer i=0; i < idsList.size(); i++) {
			contract.put('Approver_' + (i+1) + '__c', idsList.get(i));
		}
		contract.put('Number_of_Approvers__c', idsList.size());
		
		List<Dyno_Nobel_Contract__Share> existingPermissionsList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Dyno_Nobel_Contract__Share 
																WHERE ParentId = :contractId and UserOrGroupId IN :idsList];
		Map<String,String> existingIds = new Map<String,String>();
		for (Dyno_Nobel_Contract__Share perm : existingPermissionsList) {
			if (perm.AccessLevel == 'Read') {
				perm.AccessLevel = 'Edit';
			}
			existingIds.put(perm.UserOrGroupId, perm.UserOrGroupId);
		}
		update existingPermissionsList;
		
		List<Dyno_Nobel_Contract__Share> permissionsList = new List<Dyno_Nobel_Contract__Share>();
		Dyno_Nobel_Contract__Share newPermission;
		for (integer i=0; i < idsList.size(); i++) {
			if (!existingIds.containsKey(idsList.get(i))) {
				//set permission
				newPermission = new Dyno_Nobel_Contract__Share();
				newPermission.AccessLevel = 'Edit';
				newPermission.ParentId = contract.Id;
				newPermission.UserOrGroupId = idsList.get(i);
				permissionsList.add(newPermission);
			}
		}
		
		upsert permissionsList;
	}
	
	private String getStringSelectedIds(List<SelectOption> optSelectedList) {
		String theString = '';
		if (optSelectedList.size() > 0) {
			for (integer i=0; i< optSelectedList.size(); i++) {
				if (theString == '') {
					theString += optSelectedList.get(i).getValue();
				} else {
					theString += ',' + optSelectedList.get(i).getValue();
				}
			}
		}
		return theString;
	}

}