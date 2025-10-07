Global with sharing Class ProdlySFCPQDataCreatorController{
    public String updatedTruePageParameter {get; set;}   
    Product2 newBundleProduct = new Product2();
    public Organization thisOrg = [SELECT Id, Name, IsSandbox, InstanceName FROM Organization LIMIT 1];
         
    // Default Constructor and all that is needed based upon use case
    public ProdlySFCPQDataCreatorController() {
        updatedTruePageParameter = Apexpages.currentPage().getParameters().get('SuccessfulUpdate');
        if (updatedTruePageParameter == 'TRUE'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Data Created Successfully');
        }
        else if(updatedTruePageParameter == 'FALSE'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Refresh and Try again!');
        }
        
    }

    public PageReference createNewRecords(){
        // Create a new Bundle Parent Product
        newBundleProduct.Name = 'End User Training';
        newBundleProduct.ProductCode = 'EUT-BUN';
        newBundleProduct.IsActive = TRUE;
            database.insert(newBundleProduct);
       
        // Get Products to  use as Option SKU for the below Product Options
        List<Product2> optionalSKUProds = [SELECT ID, Name FROM Product2 WHERE Name IN ('1-5 User Training','6-25 User Training','25+ User Training','Company Wide Training') ORDER BY Name ASC LIMIT 25000];        
        
        // List of Product Options to Insert
        List<SBQQ__ProductOption__c> POsToInsert = new List<SBQQ__ProductOption__c>();
        
        if(optionalSKUProds.size() == 4) {                        
            SBQQ__ProductOption__c PO1 = new SBQQ__ProductOption__c();
                PO1.SBQQ__Number__c = 10;
                PO1.SBQQ__ConfiguredSKU__c = newBundleProduct.Id;
                PO1.SBQQ__Quantity__c = 1;
                PO1.SBQQ__OptionalSKU__c = optionalSKUProds[0].Id;
                POsToInsert.Add(PO1);  
                            
            SBQQ__ProductOption__c PO2 = new SBQQ__ProductOption__c();
                PO2.SBQQ__Number__c = 20;
                PO2.SBQQ__ConfiguredSKU__c = newBundleProduct.Id;
                PO2.SBQQ__Quantity__c = 1;
                PO2.SBQQ__OptionalSKU__c = optionalSKUProds[1].Id;
                POsToInsert.Add(PO2);  
                            
            SBQQ__ProductOption__c PO3 = new SBQQ__ProductOption__c();
                PO3.SBQQ__Number__c = 30;
                PO3.SBQQ__ConfiguredSKU__c = newBundleProduct.Id;
                PO3.SBQQ__Quantity__c = 1;
                PO3.SBQQ__OptionalSKU__c = optionalSKUProds[2].Id;
                POsToInsert.Add(PO3);  
                
            SBQQ__ProductOption__c PO4 = new SBQQ__ProductOption__c();
                PO4.SBQQ__Number__c = 40;
                PO4.SBQQ__ConfiguredSKU__c = newBundleProduct.Id;
                PO4.SBQQ__Quantity__c = 1;
                PO4.SBQQ__OptionalSKU__c = optionalSKUProds[3].Id;
                POsToInsert.Add(PO4);  
            
            database.insert(POsToInsert); 
            
            SBQQ__PriceRule__c newPriceRule = new SBQQ__PriceRule__c();
                newPriceRule.Name = 'Dev SB Price Rule';
                newPriceRule.SBQQ__TargetObject__c = 'Calculator';
                newPriceRule.SBQQ__ConditionsMet__c = 'Any';
                    database.insert(newPriceRule);
                
            SBQQ__PriceCondition__c newPriceCondition = new SBQQ__PriceCondition__c();
                newPriceCondition.SBQQ__Rule__c = newPriceRule.Id;
                newPriceCondition.SBQQ__Object__c = 'Quote';
                newPriceCondition.SBQQ__Field__c = 'Handling_Fee__c';
                newPriceCondition.SBQQ__Operator__c = 'Equals';                
                newPriceCondition.SBQQ__FilterType__c = 'Value'; 
                newPriceCondition.SBQQ__Value__c = '15';
                    database.insert(newPriceCondition);
            
            List<SBQQ__PriceAction__c> PAsToInsert = new List<SBQQ__PriceAction__c>();
                    
            SBQQ__PriceAction__c PA1 = new SBQQ__PriceAction__c();
                PA1.SBQQ__Rule__c = newPriceRule.Id;
                PA1.SBQQ__TargetObject__c = 'Quote';
                PA1.SBQQ__Field__c = 'Discount (%)';
                PA1.SBQQ__Value__c = '5';
                    PAsToInsert.add(PA1);    
                    
            SBQQ__PriceAction__c PA2 = new SBQQ__PriceAction__c();
                PA2.SBQQ__Rule__c = newPriceRule.Id;
                PA2.SBQQ__TargetObject__c = 'Quote';
                PA2.SBQQ__Field__c = 'Discount (Amt)';
                PA2.SBQQ__Value__c = '50';
                    PAsToInsert.add(PA2);                        
                    
            database.insert(PAsToInsert );

            PageReference pageRefSuccess = new PageReference('/apex/ProdlySFCPQSBDataCreator?UpdateMessage=Data Created&SuccessfulUpdate=TRUE');
                system.debug('******************* pageRefSuccess: ' + pageRefSuccess);
                pageRefSuccess.setRedirect(true);
                
            return pageRefSuccess;                          
        }
        else{
            PageReference pageRefFail = new PageReference('/apex/ProdlySFCPQSBDataCreator?UpdateMessage=Something went wrong. Please Refresh and try again.&SuccessfulUpdate=FALSE');
                system.debug('******************* pageRefFail: ' + pageRefFail);
                pageRefFail.setRedirect(true);
            
            return pageRefFail;              
        }
    }
    
    public Boolean getIsSandbox(){
        return thisOrg.IsSandbox;
    }
        

}