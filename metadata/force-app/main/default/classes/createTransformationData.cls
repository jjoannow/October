public class createTransformationData{

    //class level variables
    public List<Professional_Entity__c> newPFs = new List<Professional_Entity__c>();
    public List<Custom_Contact__c> newCCs = new List<Custom_Contact__c>();
        
    //default constructor
    public createTransformationData(){

        //Call the method to make the records
        createTransformationRecord();
    }

    //populate the class level Lists with data to insert in next method
    private void createTransformationRecord(){
        //setup the first Professional Entity
        Professional_Entity__c pe1 = new Professional_Entity__c();
            pe1.Name = 'New Professional Entity Won';
            pe1.Entity_City__c = 'Mead';
            pe1.Entity_Notes__c = 'These are my notes, my only notes, my friend.';
            pe1.Entity_Website__c = 'www.web.site';
                newPFs.add(pe1);
                
        //setup the second Professional Entity
        Professional_Entity__c pe2 = new Professional_Entity__c();
            pe2.Name = 'New Professional Entity Too';
            pe2.Entity_City__c = 'Longmont';
            pe2.Entity_Notes__c = 'Hope Springs Eternal, but Fear Bounces Internal!';
            pe2.Entity_Website__c = 'www.dummy.site';
                newPFs.add(pe2);

        // Do the PE Inserts
        database.insert(newPFs);
        
        for(Professional_Entity__c pe : newPFs)
        {
            Custom_Contact__c newCC1 = new Custom_Contact__c();
                newCC1.Name = 'Final';
                newCC1.First_Name__c = 'Firsty';
                newCC1.Email_Address__c = 'email@email.test';
                newCC1.Notes__c = 'These are notes for Firsty Final';
                newCC1.Phone_Number__c = '3033355555';
                newCC1.Professional_Entity__c = pe.Id;
                    newCCs.add(newCC1);

            Custom_Contact__c newCC2 = new Custom_Contact__c();
                newCC2.Name = 'Last';
                newCC2.First_Name__c = 'Best';
                newCC2.Email_Address__c = 'email@email.test';
                newCC2.Notes__c = 'These are notes for Best Last';
                newCC2.Phone_Number__c = '5555555556';
                newCC2.Professional_Entity__c = pe.Id;
                    newCCs.add(newCC2);                                            
        }
        
        // Do the CCInserts    
        database.insert(newCCs);
                                
    }


}