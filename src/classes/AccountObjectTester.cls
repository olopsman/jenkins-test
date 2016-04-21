@isTest
private class AccountObjectTester {
    /*
    public static User createPaymarkUser(String firstName, String lastName, String emailAdd, String profileId, String RoleId, String oldSFDCId){


        User newUser = new User( ProfileId = profileId, Firstname=firstName, Lastname=lastName,
            Username = firstName + '@paymark.co.nz', Alias = firstName,
            Email=emailAdd,  EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', LocaleSidKey='en_US',TimeZoneSidKey='Pacific/Auckland', Old_Salesforce_Id__c=oldSFDCId);
        return newUser;
    }

    @isTest
    static void TestAccountTrigger()
    {
        //Create Test Data
        Map<String,Id> profileNameMap = new Map<String, Id>();
        List<Profile> profileList = new List<Profile>([SELECT Id, Name FROM Profile WHERE Name IN ('Sales Administrator','Account Manager')]);
        for(Profile p:profileList){
            profileNameMap.put(p.Name, p.Id);
        }            


        List<UserRole> userRoleList = [Select Id, Name From userRole];

        Map<String, Id> userRoleMap = new Map<String, Id>();
        for(UserRole ur : userRoleList) {
            userRoleMap.put(ur.Name, ur.Id);
        }
        User paymarkSalesAdminUser = createPaymarkUser('Andrew', 'Gilbert', 'andrew.gilbert@paymark.co.nz', profileNameMap.get('Sales Administrator'), userRoleMap.get('Sales Admin'),  null);
        insert paymarkSalesAdminUser;
        //Create New SFDC User
        User paymarkSalesUser = createPaymarkUser('Sales', 'User', 'paulo.orquillo@davanti.co.nz',profileNameMap.get('Account Manager'), userRoleMap.get('Account Manager'),  '00528000002FzPO');
        insert paymarkSalesUser;

        Test.startTest();
        //insert SFDC data
        Account acc = new Account();
        acc.OwnerId = '00528000002FzPO'; //fake owner id
        acc.Name = 'Test';
        acc.Hierarchy_ID__c= null;
        insert acc;

        //insert Exadata data
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.Hierarchy_ID__c= 'MH1';
        insert acc1;
        Test.stopTest();

        //record owner is found on new sfdc and given a new owner id
        Account accInsert = [Select Id, Ownerid From Account where Id=:acc.Id];
        system.assertEquals(accInsert.OwnerId, paymarkSalesUser.Id);

        //record owner is default sales admin
        Account acc1Insert = [Select Id, Ownerid From Account where Id=:acc1.Id];
        system.assertEquals(acc1Insert.OwnerId, paymarkSalesAdminUser.Id);

    }
    */
    @isTest
    static void TestBatchMerge()    {
        List<Account> accList = new List<Account>();
        
        //Exadata
        Account acc1 = new Account();
        acc1.Name = 'ABC';
        acc1.Hierarchy_ID__c= 'MH1';
        accList.add(acc1);
        Account acc2 = new Account();
        acc2.Name = 'DEF';
        acc2.Hierarchy_ID__c= 'MH2';
        accList.add(acc2);

        insert accList;

        //SFDC Data - match
        Account acc3 = new Account();
        acc3.Name = 'ABC';
        acc3.Hierarchy_ID__c= null;
        acc3.ParentId = acc2.Id;
        insert acc3;

        Contact con3 = new Contact();
        con3.AccountId = acc3.Id;
        con3.Lastname = 'Paulo';
        con3.Email = 'paulo.orquillo@davanti.co.nz';
        insert con3;

        Opportunity opp3 = new Opportunity();
        opp3.AccountId = acc3.Id;
        opp3.Name = 'Test';
        opp3.StageName = 'Prospecting';
        opp3.CloseDate = date.Today();
        insert opp3;

        //SFDC Data - no match
        Account acc4 = new Account();
        acc4.Name = 'XYZ';
        acc4.Hierarchy_ID__c= null;
        insert acc4;


        Test.startTest();
        Database.executeBatch(new Batch_MergeAccounts());
        Test.stopTest();

        Contact con3Insert = [Select Id, AccountId from Contact where Id=:con3.Id];
        //assert con and opps have been reparented
        system.assertEquals(con3Insert.AccountId, acc1.Id);

    }
}