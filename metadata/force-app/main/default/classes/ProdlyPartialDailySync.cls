global with sharing class ProdlyPartialDailySync {

    // Default Constructor
    global ProdlyPartialDailySync(){
        intiateDeployment();
    }
  
    @future(callout=true)
    global static void intiateDeployment(){
        // Variables below are placeholder from TF master
            // Replace with values from your Org
        String deploymentName = 'Daily Staging Data Sync';
        String deploymentNotes = 'Keeping Staging up-to-date';
        String dataSetId = '';
        String deploymentPlanId = 'a5vHs000001AXh6IAG';
        String sourceOrgId = '00DHs000000PpUCMA0';
        List<String> destinationOrgIds = new List<String>{};
        
        // Add desired Destination Org Ids below
            // Use case here is to keep Staging in sync, so that should be added
            // Id below is placeholder
        destinationOrgIds.add('00DDe0000008hJbMAI');
        destinationOrgIds.add('00DDe0000008h9aMET');
                
        // Shown below is the version expected a Deployment Plan Id
        PDRI.AppOpsGlobalService.deploy(deploymentName, deploymentNotes, 
          sourceOrgId,
          destinationOrgIds,
          null,
          deploymentPlanId);
    }
    
}