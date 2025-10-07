/***************
* Originally Created by J Manning on 2022-04-21
** Change Log
*** Modified By J Manning on 2022-09-30
***** Added Comments for clarity
***************/

trigger InitiateDataDeployment on Deployment_Request__c (before update) {
    
    //instantiate the AppOppsAPIExample Class that will do the deployment request
    // Checks for any ABOUT TO BE UPDATED Deployment Requests and filters through them one at a time
        // to make sure that is is something we should initiate the deployment against
            // The check is the Deployment Approved (Initiate_Deployment_After_Approval__c) check box is TRUE and
            // the Deployment Initiated (Deployment_Initiated__c) is FALSE
    for (Deployment_Request__c updatedDeploymentRequest : Trigger.new) {
        if(updatedDeploymentRequest.Initiate_Deployment_After_Approval__c == TRUE && updatedDeploymentRequest.Deployment_Initiated__c != TRUE){  
            system.debug('********* entered the trigger when for ' + updatedDeploymentRequest.Name);
            
            // kick off the deployment using the Source & Desintation Managed Environments and the supplied Data Set on the Deployment Request record that was just Approved
            AppOppsAPIExample AOAPIE = new AppOppsAPIExample(updatedDeploymentRequest);
        }
        else{
            // Do nothing here so avoid unecessary and runaway execution of the trigger and class 
        }
    }    
    
}