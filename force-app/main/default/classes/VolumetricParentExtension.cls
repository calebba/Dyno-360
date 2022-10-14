public with sharing class VolumetricParentExtension {
        private Quote__c myQuote;
        
        public VolumetricParentExtension(ApexPages.StandardController control){
            myQuote = (Quote__c)control.getRecord();
        }
        
        public void updatequoteheaderfield() {
        	
        	if (myQuote.Scenario_Output_Header_Name__c != Null){
        		//User headerowner = [select Id, Scenario_Output_Line_1__c, Scenario_Output_Line_2__c, Scenario_Output_Line_3__c, Scenario_Output_Line_4__c, Scenario_Output_Line_5__c, Scenario_Output_Line_6__c from User WHERE Id = :Quote__c.Scenario_Output_Header_Name__c ]; 
                //User headerowner = Quote__c.Scenario_Output_Header_Name__c.id; 
                //string lineone = Quote__c.Scenario_Output_Header_Name__r.Scenario_Output_Line_1__c;
                string theidval = String.valueof(myQuote.Scenario_Output_Header_Name__c);
                
                
                User[] headerowner = [select Id, Scenario_Output_Line_1__c, Scenario_Output_Line_2__c, Scenario_Output_Line_3__c, Scenario_Output_Line_4__c, Scenario_Output_Line_5__c, Scenario_Output_Line_6__c from User WHERE Id = :theidval]; 
                if (headerowner.size()>0){
                	string scenline1 = headerowner[0].Scenario_Output_Line_1__c;
                	string scenline2 = headerowner[0].Scenario_Output_Line_2__c;
                	string scenline3 = headerowner[0].Scenario_Output_Line_3__c;
                	string scenline4 = headerowner[0].Scenario_Output_Line_4__c;
                	string scenline5 = headerowner[0].Scenario_Output_Line_5__c;
                	string scenline6 = headerowner[0].Scenario_Output_Line_6__c;
                	if (scenline1==Null){
                		scenline1 = '';
                	}
                	if (scenline2==Null){
                		scenline2 = '';
                	}
                	if (scenline3==Null){
                		scenline3 = '';
                	}
                	if (scenline4==Null){
                		scenline4 = '';
                	}
                	if (scenline5==Null){
                		scenline5 = '';
                	}
                	if (scenline6==Null){
                		scenline6 = '';
                	}
                	string scentotal = scenline1 +'\n'+ scenline2+'\n'+ scenline3+'\n'+ scenline4+'\n'+ scenline5+'\n'+ scenline6;
                	
                	
                	myQuote.Scenario_Output_Header_Info__c = scentotal;
                }
                
        	}
        	
        }
        
        public void updatequoteheaderfieldcontact() {
        	
        	if (myQuote.Scenario_Output_Header_Contact__c != Null){
        		//User headerowner = [select Id, Scenario_Output_Line_1__c, Scenario_Output_Line_2__c, Scenario_Output_Line_3__c, Scenario_Output_Line_4__c, Scenario_Output_Line_5__c, Scenario_Output_Line_6__c from User WHERE Id = :Quote__c.Scenario_Output_Header_Name__c ]; 
                //User headerowner = Quote__c.Scenario_Output_Header_Name__c.id; 
                //string lineone = Quote__c.Scenario_Output_Header_Name__r.Scenario_Output_Line_1__c;
                
                string idUser = [Select User__c From Contact Where id = :myQuote.Scenario_Output_Header_Contact__c ].User__c;
                
                
                string theidval = String.valueof(idUser);
                
                
                User[] headerowner = [select Id, Scenario_Output_Line_1__c, Scenario_Output_Line_2__c, Scenario_Output_Line_3__c, Scenario_Output_Line_4__c, Scenario_Output_Line_5__c, Scenario_Output_Line_6__c from User WHERE Id = :theidval]; 
                if (headerowner.size()>0){
                	string scenline1 = headerowner[0].Scenario_Output_Line_1__c;
                	string scenline2 = headerowner[0].Scenario_Output_Line_2__c;
                	string scenline3 = headerowner[0].Scenario_Output_Line_3__c;
                	string scenline4 = headerowner[0].Scenario_Output_Line_4__c;
                	string scenline5 = headerowner[0].Scenario_Output_Line_5__c;
                	string scenline6 = headerowner[0].Scenario_Output_Line_6__c;
                	if (scenline1==Null){
                		scenline1 = '';
                	}
                	if (scenline2==Null){
                		scenline2 = '';
                	}
                	if (scenline3==Null){
                		scenline3 = '';
                	}
                	if (scenline4==Null){
                		scenline4 = '';
                	}
                	if (scenline5==Null){
                		scenline5 = '';
                	}
                	if (scenline6==Null){
                		scenline6 = '';
                	}
                	string scentotal = scenline1 +'\n'+ scenline2+'\n'+ scenline3+'\n'+ scenline4+'\n'+ scenline5+'\n'+ scenline6;
                	
                	
                	myQuote.Scenario_Output_Header_Info__c = scentotal;
                	myQuote.Scenario_Output_Header_Name__c = idUser;
                }
                
        	}
        	
        }
        
        
        public List<SelectOption> getVolumetricParentMaterials(){
                List<SelectOption> soList = new List<SelectOption>();
                List<Material_Item__c> vpmList = new List<Material_Item__c>();
                
                vpmList = [Select Volumetric_Parent__c, Name, Id 
                                        From Material_Item__c 
                                        Where Volumetric_Parent__c = true
                                        Order by Name];
                
                for(Material_Item__c m : vpmList){
                        soList.add(new SelectOption(m.Id,m.Name));
                }

                return soList;
        }
}
// QuoteEditTest contains testMethods for this class