public Class getFreeTrialUseGuideCDId{

    public string UsageGuideContentDocumentID {get; set;}
    public Boolean isSandbox {get; set;}
    
    //Default Controller
    public getFreeTrialUseGuideCDId(){
        getOrganizationType();
        getContentDocumentID();
    }

    public void getOrganizationType(){
        Organization currentOrg = [SELECT OrganizationType, Name, InstanceName, Id, IsSandbox FROM Organization LIMIT 1];
        isSandbox = currentOrg.IsSandbox;
    }
    
    public void getContentDocumentID(){
        List<ContentVersion> UsageGuideCV = [select Id, title, contentdocumentid from contentversion where title = 'Prodly Free Trial Usage Guide' and islatest = TRUE LIMIT 1];
            system.debug('UsageGuideCV after query: ' + UsageGuideCV);
        
        if(UsageGuideCV.size() != 0){
            UsageGuideContentDocumentID = (String) UsageGuideCV[0].contentdocumentid;
        }        
    }
    

}