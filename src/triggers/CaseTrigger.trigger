trigger CaseTrigger on Case (before insert) {
	CaseTriggerHandler.setCaseDefaults(Trigger.new);
}