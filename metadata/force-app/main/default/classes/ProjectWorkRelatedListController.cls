public class ProjectWorkRelatedListController {
    
    private final agf__PPM_Project__c thisProject;
    public List<agf__ADM_Work__c> projectWorkRecords = new List<agf__ADM_Work__c>();
    private List<agf__ADM_Epic__c> projectEpicList = new List<agf__ADM_Epic__c>();
    public string newWorkRecordUrl {get; set;}

    // The extension constructor initializes the private member
        // variable acct by using the getRecord method from the standard controller.
    public ProjectWorkRelatedListController(ApexPages.StandardController stdController) {
        this.thisProject = (agf__PPM_Project__c)stdController.getRecord();
        queryForWorkRecords();
        createNewWorkRecordURL();
    } 

    private void queryForWorkRecords(){
        projectEpicList = [SELECT Id, Name FROM agf__ADM_Epic__c WHERE agf__Project__c =: thisProject.Id ORDER BY Name ASC];
            system.debug('******************** projectEpicList: ' + projectEpicList);
        if(projectEpicList.size() != 0)
        {        
            projectWorkRecords = [SELECT Id, Name, agf__Subject__c, agf__Status__c FROM agf__ADM_Work__c WHERE agf__Epic__c =: projectEpicList.get(0).Id ORDER BY agf__Status__c ASC];      
                system.debug('******************** projectWorkRecords: ' + projectWorkRecords);
        }
    }
    
    public List<agf__ADM_Work__c> getWorkRecords()
    {
        if(projectWorkRecords.size()==0 || projectEpicList.size()==0)
        {
            return null;
        }
        else
        {
            return projectWorkRecords;
        }
    }
    
    public string createNewWorkRecordURL()
    {
        Id workUserStoryRTID = Schema.SObjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId();

        newWorkRecordUrl = '/lightning/o/agf__ADM_Work__c/new?recordTypeId=' + workUserStoryRTID + '&additionalParams=';        
        return newWorkRecordUrl;        
    }
    
    
}