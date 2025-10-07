Global with sharing Class ProdlySDOSetupClass {
   // User emails to update - this address will get confirmations to complete the update
    List<User> usersToUpdate = [SELECT Id, Email, UserName, Date_of_First_Login__c, First_Login_Plus_7_Days__c, First_Login_Plus_14_Days__c, CreatedDate FROM User WHERE IsActive = TRUE and Id !=: UserInfo.getUserId() AND Profile.Name IN ('System Administrator','SM With Prodly','Chatter Free User') LIMIT 25000];
   // Running User's information
    User runningUser = [SELECT Id, Email, Firstname, Lastname, Date_of_First_Login__c, First_Login_Plus_7_Days__c, First_Login_Plus_14_Days__c, CreatedDate FROM USER where Id =: UserInfo.getUserId() LIMIT 1];
   // List of Contacts in the system for email updates
    List<Contact> contactsToUpdate = [SELECT Id, FirstName, LastName, Email FROM Contact ORDER BY Email ASC, FirstName ASC, LastName ASC LIMIT 25000];
   // List of Leads in the system for email updates
    List<Lead> leadsToUpdate = [SELECT Id, Company, FirstName, LastName, Email FROM Lead ORDER BY Email ASC, FirstName ASC, LastName ASC LIMIT 25000];
    public Organization thisOrg = [SELECT Id, Name, IsSandbox, InstanceName, CreatedDate FROM Organization LIMIT 1];        
   // Email from the user on the Setup Page to use in the Class (getter method is below)
    public String emailAddressFromUser {get; set;}
    public String updatedTruePageParameter {get; set;}    
    public String expirationDate {get; set;}
    public String mdTextString = 'Metadata Compare, Diff View & Deployments';
    public String cpqReleaseString = 'CPQ Development & Release Management';
    public String usageGuideLink {get; set;}
    
    // Default Constructor and all that is needed based upon use case
    public ProdlySDOSetupClass() {
       // Big check to do nothing in the case of this being a Sandbox--return a message in the VF page to the user
        if(!thisOrg.isSandbox){                   
           // Set some variables based upon the url of the page
            // These variables are set with the PageReference entries below
            updatedTruePageParameter = Apexpages.currentPage().getParameters().get('SuccessfulUpdate');
            emailAddressFromUser = Apexpages.currentPage().getParameters().get('EnteredEmail');
                system.debug('******************* updatedTruePageParameter: ' + updatedTruePageParameter);    
            
           // Check to see if the user has previously run the process as leads and contacts will have email addresses that are not from the TSO 
            // All Leads start with info@salesforce.com as their email address 
            if(leadsToUpdate[0].Email != 'info@salesforce.com'){
                updatedTruePageParameter = 'TRUE';    
            }
            else{
                // Do Nothing
            }
            
            if (updatedTruePageParameter == 'TRUE'){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Emails Updated');
            }
            else if(updatedTruePageParameter == 'FALSE'){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You must provide a valid Email Address format!');
            }
        }
    }
    
    //Updates the User and Contact email addresses based upon value from user on Setup Page    
    public PageReference updateEmails(){
        system.debug('******************* emailAddressFromUser: ' + emailAddressFromUser);
       // Counter for the cool gmail +# alias option
        Integer i = 1;
       // Loop through the Contacts and set email addresses
        // Include the +# aliasing if the email provided is a gmail.com email address
        if(emailAddressFromUser == null || emailAddressFromUser == '' || !emailAddressFromUser.contains('@') || !emailAddressFromUser.contains('.')){
            system.debug('******************* Email Address not provided');
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You must provide a valid Email Address format!');           
            
            //PageReference pageRefFail = new PageReference('/apex/ProdlyFreeTrialLandingPage?UpdateMessage=Update Failed - Missing or Bad Email Address Provided&SuccessfulUpdate=FALSE&EnteredEmail=' + emailAddressFromUser);
            PageReference pageRefFail = new PageReference('/lightning/page/home?UpdateMessage=Update Failed - Missing or Bad Email Address Provided&SuccessfulUpdate=FALSE&EnteredEmail=' + emailAddressFromUser);
              system.debug('******************* pageRefFail: ' + pageRefFail);                
                pageRefFail.setRedirect(true);
            
            return pageRefFail;          
        }
        else{
            for(Contact c : contactsToUpdate){
                if(c.Email != 'aog@acme.co'){
                    if(emailAddressFromUser.contains('@gmail.com')){
                        c.Email = emailAddressFromUser.replace('@gmail.com', '+' + i + '@gmail.com');
                        i++;     
                    }
                    else {
                        c.Email = emailAddressFromUser;    
                    }
                }
            }
            for(Lead l : leadsToUpdate){
                if(emailAddressFromUser.contains('@gmail.com')){
                    l.Email = emailAddressFromUser.replace('@gmail.com', '+' + i + '@gmail.com');
                    i++;     
                }
                else {
                    l.Email = emailAddressFromUser;    
                }
            }                
        
           // User loop 
            // Add this user to the list so their email updates too
            if(runningUser != null){
                usersToUpdate.add(runningUser);
            }
            
            for(User u : usersToUpdate){
                u.email = emailAddressFromUser;
            }
            
            // Do the DML processes in SF
             // Not running these in the TSO via Org Id by design     
            if(UserInfo.getOrganizationId().left(15) != '00D4x00000320BO') 
            {               
                database.update(contactsToUpdate);            
                database.update(leadsToUpdate); 
                database.update(usersToUpdate);
                             
            }
            //PageReference pageRef = new PageReference('/apex/ProdlyFreeTrialLandingPage?UpdateMessage=Email Addresses Updated&SuccessfulUpdate=TRUE');
            PageReference pageRef = new PageReference('/lightning/page/home?UpdateMessage=Email Addresses Updated&SuccessfulUpdate=TRUE');
                pageRef.setRedirect(true);
            
            sendEmailAlertWithEmailUpdater();
            
            return pageRef;    
        }       
    }
    
    // Get the value from the VF page
    public void getemailAddressFromUser(){          
    }

    // Email Alert Method
    private void sendEmailAlertWithEmailUpdater(){               
      // Send J Manning at Prodly an email when someone completes this step
        // Purely for reference, but should also signal the License expiration date to be set to no more than 7 Days from the receipt of the this message
        
        // Needed because the original user query has a value in First Login Date = null. Only after the first time the Setup page loads does this value get set on the user's record.
        User UpdatedUserDetails = [SELECT Id, Email, Firstname, Lastname, Date_of_First_Login__c, First_Login_Plus_7_Days__c, First_Login_Plus_14_Days__c FROM USER where Id =: UserInfo.getUserId() LIMIT 1];
        
        Messaging.SingleEmailMessage emailsUpdatedAlert = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'jmanning@prodly.co'}; 
            emailsUpdatedAlert.setToAddresses(toAddresses);
            emailsUpdatedAlert.setReplyTo('support@prodly.co');
            emailsUpdatedAlert.setSenderDisplayName('Free Trial \'Email Updater\' Alert Bot');    
            emailsUpdatedAlert.setSubject('Emails Updated For Org Id: ' + UserInfo.getOrganizationID());  
            emailsUpdatedAlert.setPlainTextBody('The Email Address Updater (' + UpdatedUserDetails.FirstName + ' ' + UpdatedUserDetails.LastName + ' [' + UpdatedUserDetails.Email + ']' + ') has been used for Org ID: ' + UserInfo.getOrganizationId() + '. Reach out when appropriate. Prodly access should expire no later than ' + UpdatedUserDetails.First_Login_Plus_14_Days__c + ' (YYYY-MM-DD).');
            emailsUpdatedAlert.setHtmlBody('The Email Address Updater (' + UpdatedUserDetails.FirstName + ' ' + UpdatedUserDetails.LastName + ' [' + UpdatedUserDetails.Email + ']' + ') has been used for Org ID: ' + UserInfo.getOrganizationId() + '. Reach out when appropriate. Prodly access should expire no later than ' + UpdatedUserDetails.First_Login_Plus_14_Days__c + ' (YYYY-MM-DD).');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailsUpdatedAlert });  
    }

    public void updateFirstLoginDate(){
        //User defaultOrgUser = [SELECT Id, Email, UserName, Date_of_First_Login__c, First_Login_Plus_7_Days__c FROM User WHERE Title = 'Default User' ORDER BY LastModifiedDate DESC LIMIT 1];
        Organization Org = [SELECT ID, Name FROM Organization LIMIT 1];
        
        if(runningUser.Date_of_First_Login__c == null && UserInfo.getOrganizationId().left(15) != '00D4x00000320BO'){
            runningUser.Date_of_First_Login__c = System.TODAY();
                database.update(runningUser);
                
        system.debug('************* in updateFirstLoginDate method and runningUser.Date_of_First_Login__c == null **************');
                
          // Send J Manning at Prodly an email the first time a user logs into a new Free Trial Org
            Messaging.SingleEmailMessage firstLoginAlert = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'jmanning@prodly.co'}; 
                firstLoginAlert.setToAddresses(toAddresses);
                firstLoginAlert.setReplyTo('support@prodly.co');
                firstLoginAlert.setSenderDisplayName('First Login Email');
                firstLoginAlert.setSubject('First Login For Org Id: ' + Org.ID);      
                firstLoginAlert.setPlainTextBody('A User (' + runningUser.FirstName + ' ' + runningUser.LastName + ' [' + runningUser.Email + ']' + ') has logged in for the first time into Org ID: ' + Org.ID + '. Please make sure access to Prodly expires by ' + System.TODAY().addDays(14) + ' (YYYY-MM-DD).');
                firstLoginAlert.setHtmlBody('A User (' + runningUser.FirstName + ' ' + runningUser.LastName + ' [' + runningUser.Email + ']' + ') has logged in for the first time into Org ID: ' + Org.ID + '. Please make sure access to Prodly expires by ' + System.TODAY().addDays(14) + ' (YYYY-MM-DD).');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { firstLoginAlert });                                          
        }
    }
    
    private void setUsageGuideLink(){
    
    } 
    
    public String getmdTextString(){
        return mdTextString;
    }
    
    public String getcpqReleaseString(){
        return cpqReleaseString;
    }
    
    public Boolean getIsSandbox(){
        return thisOrg.IsSandbox;
    }
    
    public String getThisOrgId(){
        String thisOrgs18CharId = (String) thisOrg.Id;
        return thisOrgs18CharId.subString(0,15);
    }    
            

   // Unused b/c @future found to be unnecessary using the action VF command 
    /*
    @future
    public static void updateFirstLoginDateFuture(){
        User defaultOrgUser = [SELECT Id, Email, UserName, Date_of_First_Login__c, First_Login_Plus_7_Days__c FROM User WHERE Title = 'Default User' ORDER BY LastModifiedDate DESC LIMIT 1];
        Organization Org = [SELECT ID, Name FROM Organization LIMIT 1];
        
        if(defaultOrgUser.Date_of_First_Login__c == null){
            defaultOrgUser.Date_of_First_Login__c = System.TODAY();
                database.update(defaultOrgUser);
                
        system.debug('************* in updateFirstLoginDate method and runningUser.Date_of_First_Login__c == null **************');
                
          // Send J Manning at Prodly an email the first time a user logs into a new Free Trial Org
            Messaging.SingleEmailMessage firstLoginAlert = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'jmanning@prodly.co'}; 
                firstLoginAlert.setToAddresses(toAddresses);
                firstLoginAlert.setReplyTo('support@prodly.co');
                firstLoginAlert.setSenderDisplayName('First Login Email');
                firstLoginAlert.setSubject('First Login For Org Id: ' + Org.ID);      
                firstLoginAlert.setPlainTextBody('A User has logged in for the first time into Org ID: ' + Org.ID + '. Please make sure access to Prodly expires by ' + System.TODAY()+7 + '.');
                firstLoginAlert.setHtmlBody('A User has logged in for the first time into Org ID: ' + Org.ID + '. Please make sure access to Prodly expires by ' + System.TODAY()+7 + '.');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { firstLoginAlert });                                          
        }

    }
    */

}