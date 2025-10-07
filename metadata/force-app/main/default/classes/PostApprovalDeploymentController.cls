public Class PostApprovalDeploymentController{

    Deployment_Request__c dr = new Deployment_Request__c();
    String dataSetId,deploymentPlanId,sourceConnectionId,destinationConnectionID;
    
    // Default Constructor
    public PostApprovalDeploymentController(Id DeploymentRequestId)
    {
        getDRDetails(DeploymentRequestId);   
        doDeploy();
    }

    private void getDRDetails(Id drRecordId){
        dr = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Deployment_Plan__c, Data_Set__c, Source_Connection__c, Destination_Connection__c, Deployment_Name__c, Deployment_Notes__c, Work_Item__c, Initiate_Deployment_After_Approval__c FROM Deployment_Request__c WHERE Id =:  drRecordId];
            system.debug('************ dr: ' + dr);        
    }

    private void doDeploy(){
        
        system.debug('***************** dr.Data_Set__c: ' + dr.Data_Set__c);
        //Data Set version of Deploy call
        if(dr.Data_Set__c != null)
        {        
            system.debug('*********** got into the dr.Data_Set__c != null if statement ***********');
            
            List<String> MDTypes = new List<String>();
                MDTypes.add('WorkflowRule');
            
            //ID deploymentResultId = PDRI.AppOpsWebServices.DeploymentServiceRequestV1(dr.Deployment_Name__c, dr.Deployment_Notes__c, MDTypes, dr.Data_Set__c, dr.Source_Connection__c);            
            //ID deploymentResultId1 = PDRI.DeploymentServiceRequestV1(deploymentName, deploymentNotes, metadataMethod, dataMethod, sourceID);
            
            String deploymentplanId = '';
            String queryFilterString = '';
            String dataSetString = String.valueOf(dr.Data_Set__c);
            
            PDRI.AppOpsWebServices.EventControlOptions eco = new PDRI.AppOpsWebServices.EventControlOptions(FALSE);
            PDRI.AppOpsWebServices.QueryFilter qf = new PDRI.AppOpsWebServices.QueryFilter(queryFilterString);
                          
            //ID deploymentResultId = PDRI.AppOpsWebServices.DataDeploymentRequest(dataSetString, deploymentplanId, FALSE, eco, qf);            
                           
            HttpRequest req = new HttpRequest();                
                req.setEndpoint('callout:ProdlyInvokeNC/services/apexrest/PDRI/dataset/deploy/' + dr.Data_Set__c + '?targetConnectionId=' + dr.Destination_Connection__c + '&sourceConnectionId=' + dr.Source_Connection__c);                

                //req.setEndpoint('callout:ProdlyInvokeNC/services/apexrest/PDRI/v1/dataset/deploy/' + dr.Data_Set__c + '?targetConnectionId=' + dr.Destination_Connection__c + '&sourceConnectionId=' + dr.Source_Connection__c);
                //req.setEndpoint('https://NA213.salesforce.com/services/apexrest/PDRI/dataset/deploy/' + dr.Data_Set__c + '?targetConnectionId=' + dr.Destination_Connection__c + '&sourceConnectionId=' + dr.Source_Connection__c);
                
                /* /apexrest/PDRI/v1/instances/{instanceId}/deploy */ 
                req.setMethod('GET');                       
                
            Http http = new Http();
            HTTPResponse res = http.send(req);
            /*
            while (res.getStatusCode() == 302) 
            {
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
            }                            
            */
                system.debug(res.getBody());
        }
        
        //Deployment Plan version of Deploy call
        if(dr.Deployment_Plan__c != null)
        {
            //ID deploymentResultId = PDRI.DeploymentService.deployPlan(dr.Deployment_Plan__c, dr.Source_Connection__c, dr.Destination_Connection__c);     
            
            // From Prodly Help site
                 //ID deploymentResultId = PDRI.DeploymentService.deploy(rootDataSetId, sourceConnectionId, targetConnectionIds);       
        }
    }


}