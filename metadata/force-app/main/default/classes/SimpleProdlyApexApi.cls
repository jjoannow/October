public with sharing Class SimpleProdlyApexApi {

    // Class level variables
    String dataSetId = '';
    String deploymentPlanId = '';
    String sourceOrgId = '';
    Boolean isDataSetId = TRUE;
    List<String> destinationOrgIds = new List<String>{};
    
    // default constructor
    public SimpleProdlyApexApi(){
        system.debug('*********** Got into the default constructor--nothing happens after this in here');
    }
    
    // constructor expecting inputs to define the deployment
    public SimpleProdlyApexApi(String sourceOrgIdPassed, List<String> destOrgIdsPassed, String DSorDPIdPassed){
        system.debug('*********** Got into the useful constructor');
        
        configureVariables(sourceOrgIdPassed, destOrgIdsPassed, DSorDPIdPassed);
        // initiate the deployment        
        doDeployment();

    }
    
    // constructor taking in a Deployment Request record specifically
    public SimpleProdlyAPEXApi(Deployment_Request__c drRecord){
        system.debug('*********** Got into the Deployment Request constructor');
        system.debug('*********** drRecord in the Deployment Request constructor: ' + drRecord);
        
        // initiate the deployment        
        doFutureDeployment(drRecord.Id);   
    } 
    
    private void configureVariables(String sourceOrgIdPassed, List<String> destOrgIdsPassed, String DSorDPIdPassed){

        sourceOrgId =  sourceOrgIdPassed; 
            system.debug('*********** sourceOrgId  after setting it to the passed value: ' + sourceOrgId);
             
        destinationOrgIds = destOrgIdsPassed;
            system.debug('*********** destinationOrgIds after setting it to the passed value: ' + destinationOrgIds);
        
        // check to see if the passed info is a Data Set or a Deployment Plan
        List<PDRI__DataSet__c> passedDataSet = [SELECT ID FROM PDRI__DataSet__c WHERE Id =: DSorDPIdPassed LIMIT 1];
            system.debug('*********** passedDataSet.size() after running the query. Should be 1 or 0: ' + passedDataSet.size());
        
        if(passedDataSet.size() > 0){
            dataSetId = DSorDPIdPassed;        
        }
        else{
            deploymentPlanId = DSorDPIdPassed;
            isDataSetId = FALSE;
        }
            system.debug('*********** isDataSetId running through the query check: ' + isDataSetId);            
            system.debug('*********** dataSetId running through the query check: ' + dataSetId);
            system.debug('*********** deploymentPlanId running through the query check: ' + deploymentPlanId);      
      
    }
    
    private void doDeployment(){
        if(isDataSetId){
            PDRI.AppOpsGlobalService.deploy('Simple API Deployment ' + System.now(), 'Test Deployment Notes', 
              sourceOrgId,
              destinationOrgIds,
              dataSetId,
              null);
        }
        else{
            PDRI.AppOpsGlobalService.deploy('Simple API Deployment ' + System.now(), 'Test Deployment Notes', 
              sourceOrgId,
              destinationOrgIds,
              null,
              deploymentPlanId);
        }
    }
    
    @future(callout=true)
    private static void doFutureDeployment(Id drRecordId){
        String DSorDPId = '';
        Boolean isDataSetId = TRUE;
        List<String> DestOrgIds = new List<String>();
        
        Deployment_Request__c deploymentRequestRecord = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Data_Set__c, Deployment_Name__c, Deployment_Notes__c, Deployment_Plan__c, Initiate_Deployment_After_Approval__c, Work_Item__c, Source_Environment__c, Source_Environment__r.PDRI__Instance_Name__c, Source_Environment__r.PDRI__Instance_ID__c, Destination_Environment__c, Destination_Environment__r.PDRI__Instance_Name__c, Destination_Environment__r.PDRI__Instance_ID__c 
                                     FROM Deployment_Request__c 
                                     WHERE Id =: drRecordId 
                                     LIMIT 1]; 
            system.debug('****************deploymentRequestRecord after query for details in initiateDeploymentFromDeploymentRequest method: ' + deploymentRequestRecord);

        if((String) deploymentRequestRecord.Data_Set__c == ''){
            DSorDPId = (String) deploymentRequestRecord.Deployment_Plan__c;
            isDataSetId = FALSE;
        }
        else{
            DSorDPId = (String) deploymentRequestRecord.Data_Set__c;
        }
        
        DestOrgIds.add(deploymentRequestRecord.Destination_Environment__r.PDRI__Instance_ID__c);
            
        if(isDataSetId){
            PDRI.AppOpsGlobalService.deploy('Deployment Request Deployment for ' + deploymentRequestRecord.Name, 'Automatically launched based on Approval Process', 
              deploymentRequestRecord.Source_Environment__r.PDRI__Instance_ID__c, 
              DestOrgIds,
              DSorDPId,
              null);
        }
        else{
            PDRI.AppOpsGlobalService.deploy('Deployment Request Deployment for ' + deploymentRequestRecord.Name, 'Automatically launched based on Approval Process', 
              deploymentRequestRecord.Source_Environment__r.PDRI__Instance_ID__c, 
              DestOrgIds,
              null,
              DSorDPId);
        }
        
        deploymentRequestRecord.Deployment_Initiated__c = TRUE;       
            database.update(deploymentRequestRecord);            
    }    
        
        
}

/******************** TESTING Snippet for Dev Console
String sourceId = '';
String dataSet = '';
String deploymentPlan = '';
List<String> destIds = new List<String>();

// dataSet or deploymentPlan can be passed to the last argument in the below.
SimpleProdlyApexApi spaa = new SimpleProdlyApexApi(sourceId, destIds, dataSet);

********************/