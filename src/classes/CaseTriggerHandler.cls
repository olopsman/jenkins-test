public with sharing class CaseTriggerHandler {
	//gets the record type name and retrieves the category from the category/type picklist dependency 
	//lazy loading
	private static CaseTriggerHandler instance = null;
	private static Map<String, String> typeMap {get;private set;}
	private static Map<Id, RecordType> recordTypeMap {get;private set;}

	//create a constructor
	public CaseTriggerHandler() {
		//get all record types in a map
		recordTypeMap = new Map<Id, RecordType>([Select Id, Name From RecordType Where SobjectType='Case']);
		typeMap = CaseTriggerHandler.retrieveControllingPicklist();
	} 


	public static void setCaseDefaults(List<Case> caseList) {
		if(instance == null) instance = new CaseTriggerHandler();		
		for(Case cse : caseList) {
			String subjectValue = recordTypeMap.get(cse.RecordTypeId).Name;
			cse.Subject = subjectValue;
			cse.Category__c = typeMap.get(subjectValue);
		}		
	}

	public static Map<String, String>  retrieveControllingPicklist() {
		String controllingField ='Category__c';
		String dependentField = 'Case_Type__c';
		//Get schema details for object
		Schema.DescribeSObjectResult objectDescribe = Case.SobjectType.getDescribe();
		//create a map of fields
		Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
		//get schema picklist for controlling entry
		List<Schema.PicklistEntry> contrEntries = fieldMap.get(controllingField).getDescribe().getPicklistValues();
		//get schema picklist for controlling entry
		List<Schema.PicklistEntry> depEntries = fieldMap.get(dependentField).getDescribe().getPicklistValues();

		Bitset bitSetObj = new Bitset();
		Map<String,List<String>> objResults = new Map<String,List<String>>();
		List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
		List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        system.debug('## objResults =>' + objResults);
        //convert map<string,list<string> to map<String, String>
        Map<String, String> typeMethodMap = new Map<String, String>();
        for(String str : objResults.keySet()) {
        	for(String strDependentField : objResults.get(str)) {
        		typeMethodMap.put(strDependentField, str);
        	}
        }
        system.debug('## typeMethodMap =>' + typeMethodMap);
        return typeMethodMap;
		
	}


	public class PicklistEntryWrapper{
	    public PicklistEntryWrapper(){            
	    }
	    public String active {get;set;}
	    public String defaultValue {get;set;}
	    public String label {get;set;}
	    public String value {get;set;}
	    public String validFor {get;set;}
	}

}