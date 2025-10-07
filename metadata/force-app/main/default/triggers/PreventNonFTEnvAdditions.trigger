trigger PreventNonFTEnvAdditions on PDRI__Connection__c (before insert) {
    List<PDRI__Connection__c> FTControlConnection = [SELECT Id, PDRI__Instance_URL__c, Name FROM PDRI__Connection__c WHERE Name != 'zArchived' AND PDRI__Local_Connection__c = TRUE]; 
        system.debug('******************** FTControlConnection List: ' + FTControlConnection);        
    String FTControlConnectionInstanceurl = '';

    if(FTControlConnection.size() > 0) {
        FTControlConnectionInstanceurl = (String) FTControlConnection[0].get('PDRI__Instance_URL__c');
            system.debug('******************** FTControlConnectionInstanceurl after retrieve from query: ' + FTControlConnectionInstanceurl);        
        FTControlConnectionInstanceurl = FTControlConnectionInstanceurl.subString(0,FTControlConnectionInstanceurl.indexOf('.'));
            system.debug('******************** FTControlConnectionInstanceurl after subString with Index: ' + FTControlConnectionInstanceurl);
    }

    for (PDRI__Connection__c c : Trigger.New) {
         // Allowed to go through as this should be the control org first establishment        
        if(c.PDRI__Org_Type__c == 'Production' && c.PDRI__OrganizationId__c == UserInfo.getOrganizationId()) {
            system.debug('******************** Entered the first if statement--Establish Control Org case.');
            system.debug('******************** Process allowed as this is the expected and only Prod org that should be part of the Free Trial.');                                                                                                
        }
         // Scratch Orgs are fine!         
        else if(c.PDRI__Org_Type__c == 'Scratch Org') {
            system.debug('******************** Scratch org condition--do nothing as scratch orgs are always allowed.');                            
        }
         // Allowing Personal Access Tokens for Work Mgmt and VC Integrations for now
          // As of 26-DEC-2024
          // Keep an eye on this for possible abuse during Free Trials
        else if(c.PDRI__Connection_Type__c == 'Personal_Access_Token') {
            system.debug('******************** Personal Access Token check entered and allowed as this is only used for Work Mgmt and VC integrations.');                                        
        }          
         // Cannot add another a Prod org that isn't the control org
        else if(c.PDRI__Org_Type__c == 'Production' && c.PDRI__OrganizationId__c != UserInfo.getOrganizationId()) {   
            system.debug('******************** Entered if statement for trying to connect to a Prod org that is not this Control org.');
            system.debug('******************** Process will be stopped and "500" error returned to Environments Page.');                                                                
            c.addError('Production Orgs, other than the Control org, are not allowed as part of the Free Trial.');
            system.debug('******************** Exited if statement for trying to connect to a Prod org that is not this Control org.');                                                               
        }
         // Cannot add any env that doesn't have the same base instance url, i.e. "prodly97"
        else if(FTControlConnectionInstanceurl != '' && !c.PDRI__Instance_URL__c.contains(FTControlConnectionInstanceurl)) {
            system.debug('******************** Entered if statement for trying to connect to a sandbox org that does not share a common instance url.');
            system.debug('******************** Process will be stopped and "500" error returned to Environments Page.');                                            
            c.addError('You may only manage sandbox environments created from your Free Trial Control Org.');
            system.debug('******************** Exited if statement for trying to connect to an org that does not share a common instance url.');                                               
        }
         // Nothing left to check--pass on through
        else {
            system.debug('******************** Code-required catch all final ELSE statement. Nothing left to check based upon above conditions, so pass through without error.');                          
        }               
    }

}