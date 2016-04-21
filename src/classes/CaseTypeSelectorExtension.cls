public with sharing class CaseTypeSelectorExtension {
	//Extension to use
	public Case cse {get;set;}
	public String recordId;
	public String caseRecordTypeId;
	public String contactId;
	public String isClosed;
	private Map<String, Id> caseNameMap {get;set;}
	private Map<String, Case_Types__c> callTypeMap {get;set;}
	public CaseTypeSelectorExtension(ApexPages.StandardController stdController) {
		recordId = '';
		contactId = '';
		isClosed = 'Open';
		this.cse = (Case) stdController.getRecord();	
		if(ApexPages.currentPage().getParameters().get('def_account_id') != null)
			recordId=ApexPages.currentPage().getParameters().get('def_account_id');
		if(ApexPages.currentPage().getParameters().get('def_contact_id') != null)	
			contactId=ApexPages.currentPage().getParameters().get('def_contact_id');	
		//record types
		caseNameMap = new Map<String, Id>();
		List<RecordType> caseRecordTypeList = [Select Id, Name From RecordType where SObjectType='Case'];
		for(RecordType rt : caseRecordTypeList) {
			caseNameMap.put(rt.Name, rt.Id);
		}		
		//get all custom settings
		callTypeMap = Case_Types__c.getAll(); 
	}
	public PageReference continueBtn() {
		PageReference pageRef = null;
		if(caseNameMap.containsKey(cse.Case_Type__c)) {
			caseRecordTypeId = caseNameMap.get(cse.Case_Type__c);
		}

		if(callTypeMap.containsKey(cse.Case_Type__c))
			isClosed = callTypeMap.get(cse.Case_Type__c).Default_Status__c;

		String baseUrl = URL.getSalesforceBaseUrl().getHost();
		if(caseRecordTypeId != null) {
			pageRef = new PageReference('https://' + baseUrl + '/500/e?retURL=%2F' + recordId + '&def_contact_id=' + contactId + '&def_account_id=' + recordId + '&RecordType=' + caseRecordTypeId + '&ent=Case&nooverride=1&cas7=' + isClosed);
			pageRef.setRedirect(true);
		} else {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected type is not found on active case record types. Please contact your system administrator.');
			ApexPages.addMessage(msg);
		}
		return pageRef;
	}
}