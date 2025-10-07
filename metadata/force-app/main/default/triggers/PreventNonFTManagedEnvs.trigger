trigger PreventNonFTManagedEnvs on PDRI__Managed_Environment__c (before insert) {
    List<PDRI__Connection__c> FTControlConnection = [SELECT Id, PDRI__Instance_URL__c, Name FROM PDRI__Connection__c WHERE Name != 'zArchived' AND PDRI__Local_Connection__c = TRUE]; 
    String FTControlConnectionInstanceurl;
    
    if(FTControlConnection.size() > 0){
        FTControlConnectionInstanceurl = (String) FTControlConnection[0].get('PDRI__Instance_URL__c');
            system.debug('******************** FTControlConnectionInstanceurl after retrieve from query: ' + FTControlConnectionInstanceurl);        
        FTControlConnectionInstanceurl = FTControlConnectionInstanceurl.subString(0,FTControlConnectionInstanceurl.indexOf('.'));
            system.debug('******************** FTControlConnectionInstanceurl after subString with Index: ' + FTControlConnectionInstanceurl);
        
        for (PDRI__Managed_Environment__c me : Trigger.New){
            if(!me.PDRI__Instance_URL__c.contains(FTControlConnectionInstanceurl) ){
                me.addError('You may only manage sandbox environments created from your Free Trial Control Org.');    
            }
        }
    }
    
}