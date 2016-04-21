global class Batch_MergeAccounts implements Database.Batchable<sObject>, Database.Stateful {
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Database.Querylocator query = Database.getQueryLocator(
                        [SELECT Id, Name FROM Account WHERE Hierarchy_ID__c!= null]); 
        return query;       
    } 


    global void execute(Database.BatchableContext BC, List<Account> scope) {
        system.debug('## exa =>' + scope.size());
        List<Account> sfdcAccountList = new List<Account>([Select Id, Name, OwnerId, BillingCity, BillingCountry, BillingPostalCode,
                                    BillingState, BillingStreet, Description, Fax, Industry, ParentId,
                                    ShippingCity, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingPostalCode, ShippingState,
                                    ShippingStreet, Type, Website, Phone,
             (Select Id, AccountId FROM Contacts), (Select Id, AccountId From Opportunities), (Select Id, Body, OwnerId, Title, ParentId From Notes) From Account WHERE Hierarchy_ID__c= null]);

        system.debug('## sfdcAccountList =>' + sfdcAccountList.size());

        //to store the sfdc matches and for deletion after
        List<Account> sfdcMatchList = new List<Account>();
        //create map for exadata by name
        Map<String, Id> exadataMap = new Map<String, Id>();
        //list of parentid with no matching name from the sfdc list
        List<Account> noParentIdMatchList = new List<Account>();

        for(Account exadata : scope) {
            exadataMap.put(exadata.Name, exadata.Id);
        }
        //loop through the exadata and existing sf data to match by Name
        Map<Id, Id> sfdcDataToExadataMap = new Map<Id, Id>();
        //list of no name match
        List<Account> noNameMatchList = new List<Account>();
        for(Account sfdcData : sfdcAccountList) {
            if(exadataMap.containsKey(sfdcData.Name)){
                //put the account id and the exada id
                sfdcDataToExadataMap.put(sfdcData.Id, exadataMap.get(sfdcData.Name));
                sfdcMatchList.add(sfdcData);
            } else {
                noNameMatchList.add(sfdcData);
            }

        }
        system.debug('## exadataMap =>' + exadataMap);
        system.debug('## noNameMatchList =>' + noNameMatchList.size());
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        List<Contact> conUpdateList = new List<Contact>();
        List<Note> noteUpdateList = new List<Note>();
        //matching exadata to be updated with sfdc data
        List<Account> accountExadataUpdateList = new List<Account>();
        //no matching exadata but check if parentId field matches exadata
        List<Account> accountSFDCUpdateList = new List<Account>();

        system.debug('## sfdcDataToExadataMap =>' + sfdcDataToExadataMap);
        system.debug('## sfdcMatchList =>' + sfdcMatchList);
        //process all the matching sfdc data
        if(sfdcDataToExadataMap.size() > 0) {       
            for(Account acc: sfdcMatchList) {
                //reparent opportunities
                if(acc.Opportunities.size() > 0) {
                    for(Opportunity opp: acc.Opportunities) {
                        //get the exadata id from the sfdc account match
                        opp.AccountId = sfdcDataToExadataMap.get(opp.AccountId);
                        oppUpdateList.add(opp);
                    }
                }
                //reparent contacts
                if(acc.Contacts.size() > 0) {
                    for(Contact con: acc.Contacts) {
                        //get the exadata id from the sfdc account match
                        system.debug('## con.AccountId =>' + con.AccountId);
                        con.AccountId = sfdcDataToExadataMap.get(con.AccountId);
                        conUpdateList.add(con);
                    }
                }


                //copy sfdc details to exadata
                Account sfdcExa = new Account(Id = sfdcDataToExadataMap.get(acc.Id));
                sfdcExa.OwnerId = acc.OwnerId;
                //Map the fields
                sfdcExa.BillingCity = acc.BillingCity;
                sfdcExa.BillingCountry = acc.BillingCountry;
                sfdcExa.BillingPostalCode = acc.BillingPostalCode;
                sfdcExa.BillingCountry = acc.BillingCountry;
                sfdcExa.BillingState = acc.BillingState;
                sfdcExa.BillingStreet = acc.BillingStreet;
                sfdcExa.Description = acc.Description;
                sfdcExa.Fax = acc.Fax;
                sfdcExa.Industry = acc.Industry;
                //check ParentId is not null
                if(acc.ParentId != null) {
                    //check that the parentId matches the account name
                    if(sfdcDataToExadataMap.containsKey(acc.ParentId)) {
                        sfdcExa.ParentId = sfdcDataToExadataMap.get(acc.ParentId);
                    }
                }
                //no need
                //sfdc.RecordTypeId
                sfdcExa.Phone = acc.Phone;
                sfdcExa.ShippingCity = acc.ShippingCity;
                sfdcExa.ShippingCountry = acc.ShippingCountry;
                sfdcExa.ShippingLatitude = acc.ShippingLatitude;
                sfdcExa.ShippingLongitude = acc.ShippingLongitude;
                sfdcExa.ShippingPostalCode = acc.ShippingPostalCode;
                sfdcExa.ShippingState = acc.ShippingState;
                sfdcExa.ShippingStreet = acc.ShippingStreet;
                sfdcExa.Type = acc.Type;                
                sfdcExa.Website = acc.Website;

                accountExadataUpdateList.add(sfdcExa);  
            }
        }
        //check the noname matches if their parentId matches exadata
        if(noNameMatchList.size() > 0) {
            for(Account acc: noNameMatchList) {
                //check ParentId is not null
                if(acc.ParentId != null) {
                    //check that the parentId matches the account name
                    if(sfdcDataToExadataMap.containsKey(acc.ParentId)) {
                        acc.ParentId = sfdcDataToExadataMap.get(acc.ParentId);
                        accountSFDCUpdateList.add(acc);
                    }
                }
            }
        }


        Savepoint sp = Database.setSavePoint();
        //update the opps 
        if(oppUpdateList.size() > 0) {
            try{
                update oppUpdateList;
            } catch (Exception e) {
                Database.rollback(sp);
                system.debug('## error updating opportunities =>' + e.getMessage());
            }
        }
        //update the contacts
        if(conUpdateList.size() > 0) {
            try{
                update conUpdateList;
                system.debug('## conUpdateList =>' + conUpdateList);
            } catch (Exception e) {
                Database.rollback(sp);
                system.debug('## error updating contacts =>' + e.getMessage());
            }
        }       
        //update exadata with matched sfdc date
        if(accountExadataUpdateList.size() > 0) {
            try{
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                List<Database.SaveResult> srList = Database.update(accountExadataUpdateList, dml);
            } catch (Exception e) {
                Database.rollback(sp);
                system.debug('## error updating exadata accounts =>' + e.getMessage());
            }
        }


        //update sfdc data with no match but could have parentId match
        if(accountSFDCUpdateList.size() > 0) {
            try{
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                List<Database.SaveResult> srList = Database.update(accountSFDCUpdateList, dml);
            } catch (Exception e) {
                Database.rollback(sp);
                system.debug('## error updating sfdc accounts =>' + e.getMessage());
            }
        }

        //delete the re-parented sfdc
        
        if(sfdcMatchList.size() > 0) {
            try{
                delete sfdcMatchList;
            } catch (Exception e) {
                Database.rollback(sp);
                system.debug('## error deleting sfdc accounts =>' + e.getMessage());
            }
        }
        


    }
    
    global void finish(Database.BatchableContext BC){
        // Sends email if errors occur
        AsyncApexJob aj = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
                from AsyncApexJob where Id =:BC.getJobId()];
            // May need to do a data rollback also as first batch may have been processed.          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {userinfo.getUserEmail()};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Apex Reparenting ' + aj.Status);
            mail.setPlainTextBody
            ('The batch Apex job processed ' + aj.TotalJobItems +
            ' batches with '+ aj.NumberOfErrors + ' failures.');
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}