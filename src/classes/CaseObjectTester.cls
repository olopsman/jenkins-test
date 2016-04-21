@isTest
private class CaseObjectTester {
	
	//Test the CaseTypeSelectorExtension 
	@isTest static void testCaseTypeSweetPathSelector() {
		// create account
		Account acc = new Account();
		acc.Name = 'PM Dawn';
		insert acc;
		// create case
		Case cse = new Case();
		cse.Category__c = 'Billing';
		cse.Case_Type__c = 'Balance Query';
		//call the standardcontroller - sweet path
		ApexPages.StandardController sc = new ApexPages.StandardController(cse);		
		CaseTypeSelectorExtension caseCon = new CaseTypeSelectorExtension(sc);
		ApexPages.currentPage().getParameters().put('def_account_id', acc.Id);
		caseCon.continueBtn();
		
	}

	//Test the CaseTypeSelectorExtension 
	@isTest static void testCaseTypeSelectorNegative() {
		// create case
		Case cse = new Case();
		cse.Category__c = 'Billing';
		//call the standardcontroller - sweet path
		ApexPages.StandardController sc = new ApexPages.StandardController(cse);		
		CaseTypeSelectorExtension caseCon = new CaseTypeSelectorExtension(sc);
		caseCon.continueBtn();	
	}

	//Test the CaseTypeSelectorExtension 
	@isTest static void testSetCaseDefaultsTrigger() {
		// create account
		Account acc = new Account();
		acc.Name = 'PM Dawn';
		insert acc;
		// create case
		Case cse = new Case();
		cse.Case_Type__c = 'Balance Query';
		cse.AccountId = acc.Id;
		cse.Status = 'Open';
		insert cse;

		Case cseInsert = [Select Id, Category__c, Case_Type__c, Subject from Case where Id=:cse.Id];
		//assert case category is billing
		system.assertEquals('Billing', cseInsert.Category__c);
		//assert case subject is the balance query
		system.assertEquals(cse.Case_Type__c, cseInsert.Case_Type__c);
	}	

	//Test the CaseTypeSelectorExtension in bulk
	@isTest static void testSetCaseDefaultsBulkTrigger() {
		// create account
		Account acc = new Account();
		acc.Name = 'PM Dawn';
		insert acc;
		List<Case> caseList = new List<Case>();
		//test bulk 201 load
		for(Integer i = 0; 201 > i; i++ ) {
			// create case
			Case cse = new Case();
			cse.Case_Type__c = 'Balance Query';
			cse.AccountId = acc.Id;
			cse.Status = 'Open';
			caseList.add(cse);
		}

		insert caseList;

	}

}