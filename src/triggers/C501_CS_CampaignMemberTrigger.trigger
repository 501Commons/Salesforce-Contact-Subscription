trigger C501_CS_CampaignMemberTrigger on CampaignMember (after insert, after update, after undelete, after delete) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUnDelete)) {
        system.debug(LoggingLevel.DEBUG, 'Insert, Update, Undelete Data: ' + Trigger.New);
        C501_CS_SharedCode.CampaignMemberTriggerHelper(Trigger.New);
    }
    else if (Trigger.isAfter && Trigger.isDelete) {
        system.debug(LoggingLevel.DEBUG, 'Delete Data: ' + Trigger.Old);
        C501_CS_SharedCode.CampaignMemberTriggerHelper(Trigger.Old);
    }

}