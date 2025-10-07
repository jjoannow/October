global class DPRRollupScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
       // Set up the List of Deployment Plan Results to pass to the Class
        // Will be further trimmed down to only those DPR records that haven't already been processed by this Class (checks for null in the two "Roll-up fields")
        // Status != null means it will not pick up Deployments that are currently underway
        List<PDRI__Deployment_Plan_Result__c> dprRecordList = [SELECT ID From PDRI__Deployment_Plan_Result__c WHERE PDRI__Status__c != '' LIMIT 90];
        
       // Method that does the Roll-up work
        DeploymentPlanResultRecordRollup dprrr = new DeploymentPlanResultRecordRollup(dprRecordList); 
    }    
    
}