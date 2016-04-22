trigger AccountTrigger on Account (before insert) {
	if(Trigger.IsInsert && Trigger.isBefore)
		AccountTriggerHelper.checkAccountOwner(Trigger.new);
}