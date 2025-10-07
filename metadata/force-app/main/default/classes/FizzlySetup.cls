public with sharing class FizzlySetup {
    
    //Placeholder record for the Project to clone
    private agf__PPM_Project__c AAProjectToClone = new agf__PPM_Project__c();
    //Placeholder record for the Project to create from the seeded record
    private agf__PPM_Project__c AAProjectToCreate = new agf__PPM_Project__c();
    
    //Placeholder Epic record to be re-parented to the new Project Record
    private agf__ADM_Epic__c AAEpicToReparent = new agf__ADM_Epic__c();
    //Placeholder List of the Work records that will be cloned and ultimately deleted
    private List<agf__ADM_Work__c> AAWorkRecordsToClone = new List<agf__ADM_Work__c>();
    //Placeholder List of the Work records that will be created 
    private List<agf__ADM_Work__c> AAWorkRecordsToCreate = new List<agf__ADM_Work__c>();    
    
    //Default Constructor
    public FizzlySetup() {
        getProjectToCloneDetails();
        getEpicToReparentId();
        getWorkRecordsToClone();
        setupProjectRecord();
        setupNewWorkRecords();
        insertOrMoveNewRecords();        
        //deleteSeedProjectRecord();        
    }

    private void getProjectToCloneDetails() {
        AAProjectToClone = [SELECT Id, Name, agf__Project_Summary__c, agf__Planned_Start_Date__c, agf__Planned_End_Date__c, PRDLAA__Is_Development_Project__c, agf__Delivery_Scrum_Team__c, agf__Development_Lead__c, agf__Project_Manager__c, agf__Category__c, agf__Project_Health__c 
                                FROM agf__PPM_Project__c 
                                WHERE Name = 'Big-Product-Catalog-Overhaul' 
                                ORDER BY CreatedDate ASC 
                                LIMIT 1];
            system.debug('******* AAProjectToClone record: ' + AAProjectToClone);        
    }
    
    private void getEpicToReparentId() {
        AAEpicToReparent = [SELECT Id, agf__Project__c 
                                FROM agf__ADM_Epic__c 
                                WHERE agf__Project__c =: AAProjectToClone.Id 
                                LIMIT 1];     
            system.debug('******* AAEpicToReparent record: ' + AAEpicToReparent);                
    }
    
    private void getWorkRecordsToClone() {
        AAWorkRecordsToClone = [SELECT Id, Name, agf__Additional_Details__c, agf__Assigned_On__c, agf__Assignee__c, agf__Description__c, agf__Details__c, agf__Due_Date__c, agf__Epic__c, agf__Origin__c, agf__Priority__c, agf__Product_Area__c, agf__Product_Tag__c, agf__QA_Engineer__c, agf__Scheduled_On__c, agf__Status__c, agf__Subject__c, agf__Scrum_Team__c, agf__Tech_Writer__c, agf__Type__c, agf__Product_Owner__c  
                                    FROM agf__ADM_Work__c 
                                    WHERE agf__Epic__c =: AAEpicToReparent.Id AND (agf__Subject__c != 'CPQ Configuration Changes' AND agf__Subject__c != 'Fizzly Product Record Updates')];
            system.debug('******* AAWorkRecordsToClone size (should be 2):' + AAWorkRecordsToClone.size());                             
            system.debug('******* AAWorkRecordsToClone records: ' + AAWorkRecordsToClone);                        
    }
    
    private void setupProjectRecord() {
         AAProjectToCreate.Name = 'Big-Product-Catalog-Overhaul';
         AAProjectToCreate.agf__Project_Summary__c = AAProjectToClone.agf__Project_Summary__c;
         AAProjectToCreate.agf__Planned_Start_Date__c = AAProjectToClone.agf__Planned_Start_Date__c;
         AAProjectToCreate.agf__Planned_End_Date__c = AAProjectToClone.agf__Planned_End_Date__c;
         AAProjectToCreate.PRDLAA__Is_Development_Project__c = TRUE;
         AAProjectToCreate.agf__Delivery_Scrum_Team__c = AAProjectToClone.agf__Delivery_Scrum_Team__c;
         AAProjectToCreate.agf__Development_Lead__c = AAProjectToClone.agf__Development_Lead__c;
         AAProjectToCreate.agf__Project_Manager__c = AAProjectToClone.agf__Project_Manager__c;
         AAProjectToCreate.agf__Category__c = AAProjectToClone.agf__Category__c;
         AAProjectToCreate.agf__Project_Health__c = AAProjectToClone.agf__Project_Health__c;
            system.debug('******* AAProjectToCreate record: ' + AAEpicToReparent);                         
    }
    
    private void setupNewWorkRecords() {
        for (agf__ADM_Work__c oldWorkRecord : AAWorkRecordsToClone) {
            agf__ADM_Work__c newWorkRecord = new agf__ADM_Work__c();
                newWorkRecord.agf__Additional_Details__c =  oldWorkRecord.agf__Additional_Details__c;
                newWorkRecord.agf__Assigned_On__c = oldWorkRecord.agf__Assigned_On__c;
                newWorkRecord.agf__Assignee__c =    oldWorkRecord.agf__Assignee__c;
                newWorkRecord.agf__Description__c = oldWorkRecord.agf__Description__c;
                newWorkRecord.agf__Details__c = oldWorkRecord.agf__Details__c;
                newWorkRecord.agf__Due_Date__c =    oldWorkRecord.agf__Due_Date__c;
                newWorkRecord.agf__Epic__c = oldWorkRecord.agf__Epic__c;
                newWorkRecord.agf__Origin__c =  oldWorkRecord.agf__Origin__c;
                newWorkRecord.agf__Priority__c =    oldWorkRecord.agf__Priority__c;
                newWorkRecord.agf__Product_Area__c =    oldWorkRecord.agf__Product_Area__c;
                newWorkRecord.agf__Product_Tag__c = oldWorkRecord.agf__Product_Tag__c;
                newWorkRecord.agf__QA_Engineer__c = oldWorkRecord.agf__QA_Engineer__c;
                newWorkRecord.agf__Scheduled_On__c =    oldWorkRecord.agf__Scheduled_On__c;
                newWorkRecord.agf__Status__c =  oldWorkRecord.agf__Status__c;
                newWorkRecord.agf__Subject__c = oldWorkRecord.agf__Subject__c;
                newWorkRecord.agf__Scrum_Team__c =  oldWorkRecord.agf__Scrum_Team__c;
                newWorkRecord.agf__Tech_Writer__c = oldWorkRecord.agf__Tech_Writer__c;
                newWorkRecord.agf__Type__c =    oldWorkRecord.agf__Type__c;
                newWorkRecord.agf__Product_Owner__c =   oldWorkRecord.agf__Product_Owner__c;
            AAWorkRecordsToCreate.add(newWorkRecord);
                //system.debug('******* AAWorkRecordsToCreate size in loop: ' + AAWorkRecordsToCreate.size());                                      
        }   
        system.debug('******* AAWorkRecordsToCreate size after loop (should be 2): ' + AAWorkRecordsToCreate.size());        
    }
    
    private void insertOrMoveNewRecords() {
        //Insert the new Project record clone record
            //This should also trigger the Trigger to make the Project record
            /****THIS MUST ALL BE DONE AFTER DOING SOME OF THE DoC required setup
                // Slide the slider and agree to beta
                // Fix the named credential record
                // Click New Project in DoC and establish connection to GitHub
            ****/
        database.insert(AAProjectToCreate);
        
        //reparent the Epic record to the new Project record 
        AAEpicToReparent.agf__Project__c = AAProjectToCreate.Id;
            database.update(AAEpicToReparent);
        
        //Insert the work records -- this should also create the two DoC Work Items
            //It cannot create the work items until the Environments are added and Pipeline is Activiated
        //database.insert(AAWorkRecordsToCreate);                
    }
    
    private void deleteSeedProjectRecord() {
        database.delete(AAProjectToClone);   
        //database.delete(AAWorkRecordsToClone);
    }
    
    
}