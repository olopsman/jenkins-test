public with sharing class AccountTriggerHelper {
    public static void checkAccountOwner(List<Account> accList) {
    /*
        //query the existing users
        Map<Id,User> userMap = new Map<Id,User>([Select Id, email,UserRoleId,Old_Salesforce_Id__c from User where IsActive=true Order by email]);
        Map<Id,Id> oldSalesforceUserMap = new Map<Id,Id>();
        String defaultUser = UserInfo.getUserId();

        if(!userMap.isEmpty()) {
            for(User usr: userMap.values()) {
                //create old salesforce user map
                if(usr.Old_Salesforce_Id__c != null){
                    oldSalesforceUserMap.put(usr.Old_Salesforce_Id__c, usr.Id);
                }

                //get one sales admin user
                system.debug('## usr.email =>' + usr.email);
                if(usr.email == 'andrew.gilbert@paymark.co.nz')
                    defaultUser = usr.Id;
                        
                
            }

            system.debug('## oldSalesforceUserMap =>' + oldSalesforceUserMap);
            system.debug('## defaultUser =>' + defaultUser);
            for(Account acc : accList){
                //only run for sfdc data - disable the trigger after dataload
                if(acc.Hierarchy_ID__c== null) {
                    system.debug('## original acc =>' + acc.OwnerId);
                     if(oldSalesforceUserMap.containsKey(acc.OwnerId)) {
                            acc.OwnerId = oldSalesforceUserMap.get(acc.OwnerId);
                            system.debug('## acc =>' + acc.Name);   
                    } else {
                        acc.OwnerId = defaultUser;
                    }
                } else {
                    acc.OwnerId = defaultUser;
                }
            }
            
        }
        */
    }
}