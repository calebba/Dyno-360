global class RealizationReportBatchStep3 implements Database.Batchable<sObject>, Database.Stateful {

    private Id batchId;
    private String csvFileStr;
    private string userEmail;
    
    private GroupingStructure GroupStructure;
    private Map<String, Level1Group> groups;
    
    global RealizationReportBatchStep3(Id previousBatchId, string email, GroupingStructure GStruct) {
        batchId = previousBatchId;
        csvFileStr = '"Grouping","Count","Account Number","PHL1","PHL2","PHL3","Material Code","Previous Price","Current Price","Per","UOM","Current Volume","Price Change($)","Previous Price Rev($)","Current Price Rev($)","Realization(%)","Realization($)"\n';
        userEmail = email;
        GroupStructure = GStruct;
        groups = new Map<String, Level1Group>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if (Test.isRunningTest())
			return Database.getQueryLocator('SELECT Key__c, Quote_SLI__c, Actual_SLI__c, ' +
	        									'Quote_SLI__r.Actual_Price__c, Quote_SLI__r.Material_Item__c, Quote_SLI__r.Material_Item__r.Base_Unit_of_Measue__c, Quote_SLI__r.Material_Item__r.Material_Code__c, Quote_SLI__r.Per__c, Quote_SLI__r.PHL1__c, Quote_SLI__r.PHL2__c, Quote_SLI__r.PHL3__c, Quote_SLI__r.Quantity__c, Quote_SLI__r.Quote__r.Customer__r.SAP_Account_Number__c, Quote_SLI__r.UoM__c, ' +
	        									'Actual_SLI__r.Actual_Price__c, Actual_SLI__r.Material_Item__c, Actual_SLI__r.Per__c, Actual_SLI__r.UoM__c, ' +
	        									'Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, ' +
	        									'Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, ' +
	        									'Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Name, ' +
	        									'Quote_SLI__r.Material_Item__r.Name, ' +
	        									'Quote_SLI__r.Quote__r.Customer__r.Sales_Manager__c, ' +
	        									'Quote_SLI__r.Quote__r.Customer__r.Account_Manager__c ' +
	        								'FROM RealizationReportAux__c WHERE Quote_SLI__c != null LIMIT 100');
		else
        	return Database.getQueryLocator('SELECT Key__c, Quote_SLI__c, Actual_SLI__c, ' +
	        									'Quote_SLI__r.Actual_Price__c, Quote_SLI__r.Material_Item__c, Quote_SLI__r.Material_Item__r.Base_Unit_of_Measue__c, Quote_SLI__r.Material_Item__r.Material_Code__c, Quote_SLI__r.Per__c, Quote_SLI__r.PHL1__c, Quote_SLI__r.PHL2__c, Quote_SLI__r.PHL3__c, Quote_SLI__r.Quantity__c, Quote_SLI__r.Quote__r.Customer__r.SAP_Account_Number__c, Quote_SLI__r.UoM__c, ' +
	        									'Actual_SLI__r.Actual_Price__c, Actual_SLI__r.Material_Item__c, Actual_SLI__r.Per__c, Actual_SLI__r.UoM__c, ' +
	        									'Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name, ' +
	        									'Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name, ' +
	        									'Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Name, ' +
	        									'Quote_SLI__r.Material_Item__r.Name, ' +
	        									'Quote_SLI__r.Quote__r.Customer__r.Sales_Manager__c, ' +
	        									'Quote_SLI__r.Quote__r.Customer__r.Account_Manager__c ' +
	        								'FROM RealizationReportAux__c WHERE BatchJob__c = \'' + batchId + '\'');
    }
    
    global void execute(Database.BatchableContext BC, list<RealizationReportAux__c> lines) {
    	
    	List<String> toUoms = new List<String>();
		List<Id> mItems = new List<Id>();
		for (RealizationReportAux__c line : lines) {
			if (line.Actual_SLI__r.UoM__c != line.Quote_SLI__r.UoM__c)
				{
					toUoms.add(line.Quote_SLI__r.UoM__c);
					mItems.add(line.Actual_SLI__r.Material_Item__c);
				}
		}
			
    	List<Alternate_Unit_of_Measure__c> aums = [SELECT AUn__c, BUn__c, X__c, Y__c, Material_Item__c FROM Alternate_Unit_of_Measure__c WHERE AUn__c in :toUoms AND Material_Item__c in :mItems];
    	
		for (RealizationReportAux__c line : lines) {
    		
    		if (line.Quote_SLI__c == null || line.Actual_SLI__c == null)
    			continue;
    		
    		string uom;
    		decimal per;
    		decimal pPrice;
    		decimal cPrice;
    		if (line.Quote_SLI__r.UOM__c == line.Actual_SLI__r.UOM__c) {
				uom = line.Quote_SLI__r.UOM__c;
				per = line.Quote_SLI__r.Per__c;
				pPrice = line.Actual_SLI__r.Actual_Price__c * line.Quote_SLI__r.Per__c / line.Actual_SLI__r.Per__c;
				cPrice = line.Quote_SLI__r.Actual_Price__c;
			} else {
				uom = line.Quote_SLI__r.Material_Item__r.Base_Unit_of_Measue__c;
				per = line.Quote_SLI__r.Per__c;
				for (Alternate_Unit_of_Measure__c aum : aums) {
					if (aum.Material_Item__c == line.Quote_SLI__r.Material_Item__c && aum.BUn__c == uom && aum.AUn__c == line.Actual_SLI__r.UOM__c) {
						pPrice = line.Actual_SLI__r.Actual_Price__c * aum.X__c / aum.Y__c * line.Quote_SLI__r.Per__c / line.Actual_SLI__r.Per__c;
					}
					if (aum.Material_Item__c == line.Quote_SLI__r.Material_Item__c && aum.BUn__c == uom && aum.AUn__c == line.Quote_SLI__r.UOM__c) {
						cPrice = line.Quote_SLI__r.Actual_Price__c * aum.X__c / aum.Y__c;
					}
				}
			}
			
			if (cPrice == 0 || pPrice == 0 || line.Quote_SLI__r.Quantity__c == 0)
				continue;
				
			string linestr = '"","",';
				
			try {
    			linestr += '"' + line.Quote_SLI__r.Quote__r.Customer__r.SAP_Account_Number__c + '",';
			} catch (Exception ex) { linestr += '"",'; }
    		try {
    			linestr += '"' + line.Quote_SLI__r.PHL1__c + '",';
    		} catch (Exception ex) { linestr += '"",'; }
    		try {
    			linestr += '"' + line.Quote_SLI__r.PHL2__c + '",';
    		} catch (Exception ex) { linestr += '"",'; }
    		try {
    			linestr += '"' + line.Quote_SLI__r.PHL3__c + '",';
    		} catch (Exception ex) { linestr += '"",'; }
    		try {
    			linestr += '"' + line.Quote_SLI__r.Material_Item__r.Material_Code__c + '",';
    		} catch (Exception ex) { linestr += '"",'; }
    		try {
    			linestr += '' + pPrice + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
    			linestr += '' + cPrice + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
    			linestr += '' + per + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
    			linestr += '"' + uom + '",';
    		} catch (Exception ex) { linestr += '"",'; }
    		try {
    			linestr += '' + line.Quote_SLI__r.Quantity__c + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
    			linestr += '' + (cPrice - pPrice) + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
    			linestr += '' + (line.Quote_SLI__r.Quantity__c * pPrice) + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
    			linestr += '' + (line.Quote_SLI__r.Quantity__c * cPrice) + ',';
    		} catch (Exception ex) { linestr += ','; }
    		try {
	    		if (pPrice != 0)
	    			linestr += '' + (cPrice * 100 / pPrice - 100) + '%,';
	    		else
	    			linestr += '"-",';
	    	} catch (Exception ex) { linestr += '"-",'; }
    		try {
    			linestr += '' + (line.Quote_SLI__r.Quantity__c * (cPrice - pPrice)) + '\n';
    		} catch (Exception ex) { linestr += ','; }
    		
    		if (GroupStructure == null) {
    			csvFileStr += linestr;
    		} else {
    			PutLineInRightGrouping(line, linestr, pPrice, cPrice);
    		}
    	}
    	
    	delete lines;
    }
    
    private void PutLineInRightGrouping(RealizationReportAux__c line, string linestr, decimal pPrice, decimal cPrice) {
    	// First Level
    	string gLevel1 = '';
    	if (GroupStructure.FirstGroupSe == 'Organization') {
			if (GroupStructure.FirstGroupBy == 'Company') {
				gLevel1 = 'Company: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name;
			}
			if (GroupStructure.FirstGroupBy == 'Region') {
				gLevel1 = 'Region: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name;
			}
			if (GroupStructure.FirstGroupBy == 'Sales Site') {
				gLevel1 = 'Sales Site: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Name;
			}
		}
		if (GroupStructure.FirstGroupSe == 'Product') {
			if (GroupStructure.FirstGroupBy == 'PHL1') {
				gLevel1 = 'PHL1: ' + line.Quote_SLI__r.PHL1__c;
			}
			if (GroupStructure.FirstGroupBy == 'PHL2') {
				gLevel1 = 'PHL2: ' + line.Quote_SLI__r.PHL1__c + line.Quote_SLI__r.PHL2__c;
			}
			if (GroupStructure.FirstGroupBy == 'PHL3') {
				gLevel1 = 'PHL3: ' + line.Quote_SLI__r.PHL1__c + line.Quote_SLI__r.PHL2__c + line.Quote_SLI__r.PHL3__c;
			}
			if (GroupStructure.FirstGroupBy == 'Material Code') {
				gLevel1 = 'Material Item: ' + line.Quote_SLI__r.Material_Item__r.Name;
			}
		}
		if (GroupStructure.FirstGroupSe == 'Sales Structure') {
			if (GroupStructure.FirstGroupBy == 'Sales Manager') {
				gLevel1 = 'Sales Manager: ' + line.Quote_SLI__r.Quote__r.Customer__r.Sales_Manager__c;
			}
			if (GroupStructure.FirstGroupBy == 'Account Manager') {
				gLevel1 = 'Account Manager: ' + line.Quote_SLI__r.Quote__r.Customer__r.Account_Manager__c;
			}
		}
		
		if (!groups.containsKey(gLevel1))
			groups.put(gLevel1, new Level1Group(gLevel1));
		Level1Group group1 = groups.get(gLevel1);
		
		group1.Count += 1;
		if (line.Quote_SLI__r != null && line.Quote_SLI__r.Quantity__c != null && pPrice != null)
			group1.PreviousPriceRev += line.Quote_SLI__r.Quantity__c * pPrice;
		if (line.Quote_SLI__r != null && line.Quote_SLI__r.Quantity__c != null && cPrice != null)
			group1.CurrentPriceRev += line.Quote_SLI__r.Quantity__c * cPrice;
		if (GroupStructure.SecondGroupSe == null || GroupStructure.SecondGroupSe == '')
			group1.Values += linestr;
		else {
			// Second Level
	    	string gLevel2 = '';
	    	if (GroupStructure.SecondGroupSe == 'Organization') {
				if (GroupStructure.SecondGroupBy == 'Company') {
					gLevel2 = 'Company: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name;
				}
				if (GroupStructure.SecondGroupBy == 'Region') {
					gLevel2 = 'Region: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name;
				}
				if (GroupStructure.SecondGroupBy == 'Sales Site') {
					gLevel2 = 'Sales Site: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Name;
				}
			}
			if (GroupStructure.SecondGroupSe == 'Product') {
				if (GroupStructure.SecondGroupBy == 'PHL1') {
					gLevel2 = 'PHL1: ' + line.Quote_SLI__r.PHL1__c;
				}
				if (GroupStructure.SecondGroupBy == 'PHL2') {
					gLevel2 = 'PHL2: ' + line.Quote_SLI__r.PHL1__c + line.Quote_SLI__r.PHL2__c;
				}
				if (GroupStructure.SecondGroupBy == 'PHL3') {
					gLevel2 = 'PHL3: ' + line.Quote_SLI__r.PHL1__c + line.Quote_SLI__r.PHL2__c + line.Quote_SLI__r.PHL3__c;
				}
				if (GroupStructure.SecondGroupBy == 'Material Code') {
					gLevel2 = 'Material Item: ' + line.Quote_SLI__r.Material_Item__r.Name;
				}
			}
			if (GroupStructure.SecondGroupSe == 'Sales Structure') {
				if (GroupStructure.SecondGroupBy == 'Sales Manager') {
					gLevel2 = 'Sales Manager: ' + line.Quote_SLI__r.Quote__r.Customer__r.Sales_Manager__c;
				}
				if (GroupStructure.SecondGroupBy == 'Account Manager') {
					gLevel2 = 'Account Manager: ' + line.Quote_SLI__r.Quote__r.Customer__r.Account_Manager__c;
				}
			}
			
			if (!group1.Groups.containsKey(gLevel2))
				group1.Groups.put(gLevel2, new Level2Group(gLevel2));
			Level2Group group2 = group1.Groups.get(gLevel2);
			
			group2.Count += 1;
			if (line.Quote_SLI__r != null && line.Quote_SLI__r.Quantity__c != null && pPrice != null)
				group2.PreviousPriceRev += line.Quote_SLI__r.Quantity__c * pPrice;
			if (line.Quote_SLI__r != null && line.Quote_SLI__r.Quantity__c != null && cPrice != null)
				group2.CurrentPriceRev += line.Quote_SLI__r.Quantity__c * cPrice;
			if (GroupStructure.ThirdGroupSe == null || GroupStructure.ThirdGroupSe == '')
				group2.Values += linestr;
			else {
				// Third Level
		    	string gLevel3 = '';
		    	if (GroupStructure.ThirdGroupSe == 'Organization') {
					if (GroupStructure.ThirdGroupBy == 'Company') {
						gLevel3 = 'Company: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Company_Site__r.Name;
					}
					if (GroupStructure.ThirdGroupBy == 'Region') {
						gLevel3 = 'Region: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Region_Site__r.Name;
					}
					if (GroupStructure.ThirdGroupBy == 'Sales Site') {
						gLevel3 = 'Sales Site: ' + line.Quote_SLI__r.Quote__r.Sales_Organization_Primary__r.Name;
					}
				}
				if (GroupStructure.ThirdGroupSe == 'Product') {
					if (GroupStructure.ThirdGroupBy == 'PHL1') {
						gLevel3 = 'PHL1: ' + line.Quote_SLI__r.PHL1__c;
					}
					if (GroupStructure.ThirdGroupBy == 'PHL2') {
						gLevel3 = 'PHL2: ' + line.Quote_SLI__r.PHL1__c + line.Quote_SLI__r.PHL2__c;
					}
					if (GroupStructure.ThirdGroupBy == 'PHL3') {
						gLevel3 = 'PHL3: ' + line.Quote_SLI__r.PHL1__c + line.Quote_SLI__r.PHL2__c + line.Quote_SLI__r.PHL3__c;
					}
					if (GroupStructure.ThirdGroupBy == 'Material Code') {
						gLevel3 = 'Material Item: ' + line.Quote_SLI__r.Material_Item__r.Name;
					}
				}
				if (GroupStructure.ThirdGroupSe == 'Sales Structure') {
					if (GroupStructure.ThirdGroupBy == 'Sales Manager') {
						gLevel3 = 'Sales Manager: ' + line.Quote_SLI__r.Quote__r.Customer__r.Sales_Manager__c;
					}
					if (GroupStructure.ThirdGroupBy == 'Account Manager') {
						gLevel3 = 'Account Manager: ' + line.Quote_SLI__r.Quote__r.Customer__r.Account_Manager__c;
					}
				}
				
				if (!group2.Groups.containsKey(gLevel3))
					group2.Groups.put(gLevel3, new Level3Group(gLevel3));
				Level3Group group3 = group2.Groups.get(gLevel3);
				
				group3.Count += 1;
				if (line.Quote_SLI__r != null && line.Quote_SLI__r.Quantity__c != null && pPrice != null)
					group3.PreviousPriceRev += line.Quote_SLI__r.Quantity__c * pPrice;
				if (line.Quote_SLI__r != null && line.Quote_SLI__r.Quantity__c != null && cPrice != null)
					group3.CurrentPriceRev += line.Quote_SLI__r.Quantity__c * cPrice;
				group3.Values += linestr;
			}
		} 
    }
    
    global void finish(Database.BatchableContext BC) {
    	
    	if (GroupStructure != null) {
    		for (Level1Group l1g : groups.values()) {
    			csvFileStr += '"' + l1g.Text + '",';
    			csvFileStr += '' + l1g.Count + ',';
    			csvFileStr += ',,,,,,,,,,,';
    			csvFileStr += '' + l1g.PreviousPriceRev + ',';
    			csvFileStr += '' + l1g.CurrentPriceRev + ',';
    			csvFileStr += '' + l1g.RealizationPercent + ',';
    			csvFileStr += '' + l1g.Realization + '\n';
    			if (GroupStructure.SecondGroupSe == null)
    				csvFileStr += l1g.Values;
    			else {
    				for (Level2Group l2g : l1g.Groups.values()) {
    					csvFileStr += '"' + l2g.Text + '",';
		    			csvFileStr += '' + l2g.Count + ',';
		    			csvFileStr += ',,,,,,,,,,,';
		    			csvFileStr += '' + l2g.PreviousPriceRev + ',';
		    			csvFileStr += '' + l2g.CurrentPriceRev + ',';
		    			csvFileStr += '' + l2g.RealizationPercent + ',';
		    			csvFileStr += '' + l2g.Realization + '\n';
		    			if (GroupStructure.ThirdGroupSe == null)
		    				csvFileStr += l2g.Values;
		    			else {
		    				for (Level3Group l3g : l2g.Groups.values()) {
		    					csvFileStr += '"' + l3g.Text + '",';
				    			csvFileStr += '' + l3g.Count + ',';
				    			csvFileStr += ',,,,,,,,,,,';
				    			csvFileStr += '' + l3g.PreviousPriceRev + ',';
				    			csvFileStr += '' + l3g.CurrentPriceRev + ',';
				    			csvFileStr += '' + l3g.RealizationPercent + ',';
				    			csvFileStr += '' + l3g.Realization + '\n';
				    			csvFileStr += l3g.Values;
		    				}
		    			}
    				}
    			}
    		}
    	}
    	
    	Document doc = new Document();
    	doc.Name = 'Realization Report ' + DateTime.now().format('yyyy-MM-dd HH-mm-ss') + '.csv';
    	Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Realization_Reports'];
    	doc.FolderId = folder.Id;
    	doc.Body = Blob.valueOf(csvFileStr);
    	insert doc;
    	
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        string urlBase = URL.getSalesforceBaseUrl().toExternalForm();
        String body = 'Realization Report has completed.<br /><br />';
        body += '<a href="' + urlBase + '/' + doc.Id + '">Click here for the file</a>';
        
        mail.setToAddresses(new String[] {userEmail});
        mail.setSenderDisplayName('Realization Report Batch');
        mail.setSubject('Realization Report Batch Process Completed');
        mail.setHtmlBody(body);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    global class GroupingStructure {
    	public string FirstGroupSe;
    	public string FirstGroupBy;
    	public string SecondGroupSe;
    	public string SecondGroupBy;
    	public string ThirdGroupSe;
    	public string ThirdGroupBy;
    }
    
    public class Level1Group {
    	public string Text;
    	public integer Count;
    	public decimal PreviousPriceRev;
    	public decimal CurrentPriceRev;
    	public decimal RealizationPercent { 
			get {
				if (PreviousPriceRev == 0)
					return null;
				return CurrentPriceRev * 100 / PreviousPriceRev - 100;
			}
		}
		public decimal Realization {
			get {
				return CurrentPriceRev - PreviousPriceRev;
			}
		}
    	public Map<String, Level2Group> Groups;
    	public string Values;
    	
    	public Level1Group(string txt) {
    		Text = txt;
    		Count = 0;
    		PreviousPriceRev = 0;
    		CurrentPriceRev = 0;
    		Groups = new Map<String, Level2Group>();
    		Values = '';
    	}
    }
    
    public class Level2Group {
    	public string Text;
    	public integer Count;
    	public decimal PreviousPriceRev;
    	public decimal CurrentPriceRev;
    	public decimal RealizationPercent { 
			get {
				if (PreviousPriceRev == 0)
					return null;
				return CurrentPriceRev * 100 / PreviousPriceRev - 100;
			}
		}
		public decimal Realization {
			get {
				return CurrentPriceRev - PreviousPriceRev;
			}
		}
    	public Map<String, Level3Group> Groups;
    	public string Values;
    	
    	public Level2Group(string txt) {
    		Text = txt;
    		Count = 0;
    		PreviousPriceRev = 0;
    		CurrentPriceRev = 0;
    		Groups = new Map<String, Level3Group>();
    		Values = '';
    	}
    }
    
    public class Level3Group {
    	public string Text;
    	public integer Count;
    	public decimal PreviousPriceRev;
    	public decimal CurrentPriceRev;
    	public decimal RealizationPercent { 
			get {
				if (PreviousPriceRev == 0)
					return null;
				return CurrentPriceRev * 100 / PreviousPriceRev - 100;
			}
		}
		public decimal Realization {
			get {
				return CurrentPriceRev - PreviousPriceRev;
			}
		}
    	public string Values;
    	
    	public Level3Group(string txt) {
    		Text = txt;
    		Count = 0;
    		PreviousPriceRev = 0;
    		CurrentPriceRev = 0;
    		Values = '';
    	}
    }

}