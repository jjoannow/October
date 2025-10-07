/***************
* Originally Created by J Manning on 2022-09-27
** Change Log
*** Modified By J Manning on 2022-09-30
***** Added Comments for clarity
***************/


public with sharing Class AppOpsAPIExample{

    // Class Level Variables
    // Control Org Managed Environment Details via a query
        // Not actually used, but provides the data should we ever need it
    private PDRI__Managed_Environment__c controlOrgME = [SELECT PDRI__Control_Instance__c, Id, Name, PDRI__Instance_Name__c, PDRI__Instance_ID__c, PDRI__Instance_Type__c, PDRI__Instance_URL__c 
                                                            FROM PDRI__Managed_Environment__c 
                                                            WHERE PDRI__Control_Instance__c = TRUE 
                                                            ORDER BY CreatedDate DESC 
                                                            LIMIT 1];
    
    // Create an empty placefolder Deploymenr Request record that may be used and assigned to the record pass in by a manuall execution of the Class                                                                                                                
    Deployment_Request__c deploymentRequestRecord = new Deployment_Request__c();                                                            
                                                            
    // Variables for instance id of Source and Destination envs
     // Part of the Prodly API Managed Class and obtained from the help article
    private PDRI.AppOpsWebServices.ManagedInstance sourceInstance,destinationInstance;
    
    //ID variables for the org Id of Source and Destination
     // Filled in later as part of the execution
     // Will be used to do the actual deployment as these are the three pieces of data that must be defined for the deployment to work
    Id destinationOrgId, sourceOrgId, dataSetId;
    
    // Variables the be used to dill in the Deployment Name and Deployment Notes when manually launched
    String DeploymentRequestName = '';
    String DeploymentRequestNotes = '';
                                                                
    // Default Constructor
        // Used for manualy launched version of the Class
    public AppOpsAPIExample(){
        getSourceAndDestinationInstances(); 
        initiateDeployment();  
    }
 
    // Constructor for Deployment Request Trigger/Approval Process
     // Everything must be in the @Future Method, so the only process that executes is initiateDeploymentFromDeploymentRequest Method
    public AppOpsAPIExample(Deployment_Request__c DRRecord){
        //setSourceDestOrgIdsViaManagedEnvs(DRRecord.Id);
        //getSourceAndDestinationInstances(); 
        initiateDeploymentFromDeploymentRequest(DRRecord.Id);  
    } 

    // Used from Trigger/Approval Process and only executed when the Constructor expecting a Deployment Request record is initiated (the one directly above)
     // @Future (callout=true) Required since there is a callout that happens from the managed Prodly API code
    @Future(callout=true) 
    private static void initiateDeploymentFromDeploymentRequest(Id drRecordID){        
        // Deployment Record Details
         // Must be queried here since the only variabled passed to this Method is the Deployment Request record ID
          // Using that Id allows use to query the record for all data related to it as seen below in the SOQL
        Deployment_Request__c deploymentRequestRecord = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Data_Set__c, Deployment_Name__c, Deployment_Notes__c, Deployment_Plan__c, Initiate_Deployment_After_Approval__c, Work_Item__c, Source_Environment__c, Source_Environment__r.PDRI__Instance_Name__c, Source_Environment__r.PDRI__Instance_ID__c, Destination_Environment__c, Destination_Environment__r.PDRI__Instance_Name__c, Destination_Environment__r.PDRI__Instance_ID__c 
                                     FROM Deployment_Request__c
                                     WHERE Id =: drRecordID 
                                     LIMIT 1]; 
            system.debug('****************deploymentRequestRecord after query for details in initiateDeploymentFromDeploymentRequest method: ' + deploymentRequestRecord);
        
        // Define a sourceOrgId variable and set it to the Source Environment Instance Id (this is an Org record Id) value from the Deployment Request record
        Id sourceOrgId = deploymentRequestRecord.Source_Environment__r.PDRI__Instance_ID__c;
        // Define a destinationOrgId variable and set it to the Destination Environment Instance Id (this is an Org record Id) value from the Deployment Request record        
        Id destinationOrgId = deploymentRequestRecord.Destination_Environment__r.PDRI__Instance_ID__c;
        // Define a dataSetId variable and set it to the Data Set Id value from the Deployment Request record
        Id dataSetId = deploymentRequestRecord.Data_Set__c; 
        
        // Defined variables for ManagedInstances - part of the Prodly API requirements
         // requried code as defined by Help article related to Prodly API
        PDRI.AppOpsWebServices.ManagedInstance sourceInstance,destinationInstance;
           
        //Retrieve managed instances
         // requried code as defined by Help article related to Prodly API
        PDRI.AppOpsWebServices.ManagedInstances managedInstances = PDRI.AppOpsGlobalService.listInstances();        
      
        // Loop through the managed instances that exists for this Control environment
         // Set the required ones against the supplied Source and Destination as defined in the Deployment Request
        for( PDRI.AppOpsWebServices.ManagedInstance instance : managedInstances.instances ) {
            if( instance.platformInstanceId == sourceOrgId ) {
                sourceInstance = instance;
            } else if( instance.platformInstanceId == destinationOrgId ) {
                destinationInstance = instance;
            }
        }            
        
        // Required line in Prodly API code from Help article
        PDRI.AppOpsWebServices.DeploymentServiceRequestV1 deploymentServiceRequest = new PDRI.AppOpsWebServices.DeploymentServiceRequestV1();
        
        // Sets the deployment name for the deployment (found on Deployment Results)
        deploymentServiceRequest.deploymentName = deploymentRequestRecord.Deployment_Name__c;
        // Sets the deployment notes for the deployment (found on Deployment Results)        
        deploymentServiceRequest.deploymentNotes = deploymentRequestRecord.Deployment_Notes__c;
        // Sets the Source Instance for the deployment (found on Deployment Results)        
         // Not the Org Id, this is an instance ID that is maintained in Prodly Backend and is required to do deployments--not something found anywhere in the UI for Prodly
         // Can be ontained and viewed by sfdx Prodly Plugin
        deploymentServiceRequest.source = new PDRI.AppOpsWebServices.DeploymentSource(sourceInstance.Id);
        // Sets the Data Set to be used for the deployment (found on Deployment Results)        
         // Actually Id of the Data Set record in the environment that is defined on the Deployment Request 
        deploymentServiceRequest.data = new List<PDRI.AppOpsWebServices.DataDeploymentRequest> { new PDRI.AppOpsWebServices.DataDeploymentRequest(dataSetId) };
        // Unknown piece of code, but required to process
         // Most likely a method to deploy metadata via the API        
        deploymentServiceRequest.metadata = new PDRI.AppOpsWebServices.MetadataDeploymentRequest();

        // Sets the Destination Instance for the deployment (found on Deployment Results)        
         // Not the Org Id, this is an instance ID that is maintained in Prodly Backend and is required to do deployments--not something found anywhere in the UI for Prodly
         // Can be ontained and viewed by sfdx Prodly Plugin        
        String destinationManagedInstanceId = destinationInstance.id;
        
        // Code to beging the deployment using the variables defined above
        PDRI.AppOpsGlobalService.deploy(deploymentServiceRequest, destinationManagedInstanceId);   
        
        // Added custom to set the Deployment Initiated (Deployment_Initiated__c) check box to TRUE on the Deployment Request record 
         // Basically marks the request as completed and happens concurrently with the Deployment kicking off
         // DOES NOT KNOW IF THE DEPLOYMENT WORKED OR NOT, JUST THAT THIS METHOD EXECUTED
        deploymentRequestRecord.Deployment_Initiated__c = TRUE;
            database.update(deploymentRequestRecord);           
    }   


/************************* CODE BELOW USED FOR MANUAL LAUNCH OF CLASS & TESTING ONLY *************************/    

    private void getSourceAndDestinationInstances(){
        
        //For Testing ONLY
        {
            //destinationOrgId = '00D030000008qrFEAQ';
            //sourceOrgId = '00D8X000000FFiFUAW';
        }
        
        //Retrieve managed instances
        PDRI.AppOpsWebServices.ManagedInstances managedInstances = PDRI.AppOpsGlobalService.listInstances();        
                        
        for( PDRI.AppOpsWebServices.ManagedInstance instance : managedInstances.instances ) {
            if( instance.platformInstanceId == sourceOrgId ) {
                sourceInstance = instance;
            } else if( instance.platformInstanceId == destinationOrgId ) {
                destinationInstance = instance;
            }
        }
    }
    
    private void setSFRecordIds(Id SrcOrgId, Id DestOrgId, Id DSetId){
        sourceOrgId = SrcOrgId;   
        destinationOrgId = DestOrgId; 
        dataSetId = DSetId;    
    }       
   
    private void initiateDeploymentFromDeploymentRequest(String DRName, String DRNotes){        
        PDRI.AppOpsWebServices.DeploymentServiceRequestV1 deploymentServiceRequest = new PDRI.AppOpsWebServices.DeploymentServiceRequestV1();
        
        deploymentServiceRequest.deploymentName = DRName;
        deploymentServiceRequest.deploymentNotes = DRNotes;
        deploymentServiceRequest.source = new PDRI.AppOpsWebServices.DeploymentSource(sourceInstance.Id);
        deploymentServiceRequest.data = new List<PDRI.AppOpsWebServices.DataDeploymentRequest> { new PDRI.AppOpsWebServices.DataDeploymentRequest(dataSetId) };
        deploymentServiceRequest.metadata = new PDRI.AppOpsWebServices.MetadataDeploymentRequest();
        
        String destinationManagedInstanceId = destinationInstance.id;
        
        PDRI.AppOpsGlobalService.deploy(deploymentServiceRequest, destinationManagedInstanceId);   
    }    
        
    private void initiateDeployment(){
        //For Testing Only
        {
            //"**Demo Seeding [Account] - CLONED"
            //dataSetId = 'a5j8X0000037ESyQAM';
        }
        
        PDRI.AppOpsWebServices.DeploymentServiceRequestV1 deploymentServiceRequest = new PDRI.AppOpsWebServices.DeploymentServiceRequestV1();
        
        deploymentServiceRequest.deploymentName = 'Sample Apex Deploy 2';
        deploymentServiceRequest.deploymentNotes = 'Just a test deployment';
        deploymentServiceRequest.source = new PDRI.AppOpsWebServices.DeploymentSource(sourceInstance.Id);
        deploymentServiceRequest.data = new List<PDRI.AppOpsWebServices.DataDeploymentRequest> { new PDRI.AppOpsWebServices.DataDeploymentRequest(dataSetId) };
        deploymentServiceRequest.metadata = new PDRI.AppOpsWebServices.MetadataDeploymentRequest();
        
        String destinationManagedInstanceId = destinationInstance.id;
        
        PDRI.AppOpsGlobalService.deploy(deploymentServiceRequest, destinationManagedInstanceId);   
    }

/****************************************************************************************************/   

   /**
   **Deprecated b/c all work must be done in FUTURE method
    private void setSourceDestOrgIdsViaManagedEnvs(Id drRecordID){
        deploymentRequestRecord = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Data_Set__c, Deployment_Name__c, Deployment_Notes__c, Deployment_Plan__c, Initiate_Deployment_After_Approval__c, Work_Item__c, Source_Environment__c, Source_Environment__r.PDRI__Instance_Name__c, Source_Environment__r.PDRI__Instance_ID__c, Destination_Environment__c, Destination_Environment__r.PDRI__Instance_Name__c, Destination_Environment__r.PDRI__Instance_ID__c 
                                     FROM Deployment_Request__c
                                     WHERE Id =: drRecordID 
                                     LIMIT 1]; 
            system.debug('****************deploymentRequestRecord after query for details in getSourceDestOrgIdsViaManagedEnvs method: ' + deploymentRequestRecord);
        
        sourceOrgId = deploymentRequestRecord.Source_Environment__r.PDRI__Instance_ID__c;
        destinationOrgId = deploymentRequestRecord.Destination_Environment__r.PDRI__Instance_ID__c;
        dataSetId = deploymentRequestRecord.Data_Set__c;                               
    }                                                    
   */ 

}