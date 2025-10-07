/*********************
Originally created by J Manning on 06-MAR-2023
* Last Updated on 06-MAR-2023 by J Manning
*********************/

public with sharing Class DeploymentPlanResultRecordRollup {

   // Class-level Variables
    List<PDRI__Deployment_Plan_Result__c> DeploymentPlanResults = new List<PDRI__Deployment_Plan_Result__c>();
    List<PDRI__Deployment_Plan_Result__c> DeploymentPlanResultsToUpdate = new List<PDRI__Deployment_Plan_Result__c>();
    public List<Id> DeploymentPlanResultIds = new List<Id>();

   // Default Constructor
    // Mostly used for testing
    public DeploymentPlanResultRecordRollup() {

    }
    
   // Constructor with passed List of Deployment Plan Result Records
    public DeploymentPlanResultRecordRollup(List<PDRI__Deployment_Plan_Result__c> DPRRecords) {
         if(UserInfo.getOrganizationID().left(15) != '00D4x00000320BO'){
            if(DPRRecords.size() != 0){
                DeploymentPlanResults = DPRRecords;
                    for(PDRI__Deployment_Plan_Result__c dprRecord : DPRRecords){
                        DeploymentPlanResultIds.add(dprRecord.Id);
                    }
                createRecordSums();
                updateDPRRecords();              
            }
        }
    }

   // Method to do the counting by Deployment Plan Result record to get top-level sums of processed, successful and failed records for easy visbility 
    public void createRecordSums(){        
        for(PDRI__Deployment_Plan_Result__c dpr : [SELECT ID, Name, Deployment_Plan_Successful_Records__c, Deployment_Plan_Failed_Records__c FROM PDRI__Deployment_Plan_Result__c WHERE Id =: DeploymentPlanResultIds AND Deployment_Plan_Successful_Records__c = null AND Deployment_Plan_Failed_Records__c = null]){
           // Counters that reset to 0 for each Deployment Plan Result reecord processed
            double successCounter = 0;
            double failureCounter = 0;
        
            for(PDRI__Deployment_Batch_Result__c dbr : [SELECT ID, PDRI__Data_Records_Processed__c, PDRI__Data_Records_Succeeded__c, PDRI__Data_Records_Failed__c FROM PDRI__Deployment_Batch_Result__c WHERE PDRI__Deployment_Plan_Step_Result__r.PDRI__Deployment_Plan_Result__c =: dpr.ID]){
                successCounter = successCounter + dbr.PDRI__Data_Records_Succeeded__c;   
                failureCounter = failureCounter + dbr.PDRI__Data_Records_Failed__c;
            }            
                system.debug('*************** successCounter for ' + dpr.Name + ' after counting: ' + successCounter);
                system.debug('*************** failureCounter for ' + dpr.Name + ' after counting: ' + failureCounter);
            
            dpr.Deployment_Plan_Successful_Records__c = successCounter;
            dpr.Deployment_Plan_Failed_Records__c = failureCounter;
            DeploymentPlanResultsToUpdate.add(dpr);
                system.debug('*************** DeploymentPlanResultsToUpdate after calcs and adding to list: ' + DeploymentPlanResultsToUpdate);
                            
        }        
    }
    
   // Does the actual DML call
    public void updateDPRRecords(){
        database.update(DeploymentPlanResultsToUpdate);
    }

}