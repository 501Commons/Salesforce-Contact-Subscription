trigger C501_CS_CampaignMemberTrigger on CampaignMember (after insert, after update, after undelete, after delete) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUnDelete)) {
        C501_CS_SharedCode.CampaignMemberTriggerHelper(Trigger.New);
    }
    else if (Trigger.isAfter && Trigger.isDelete) {
        C501_CS_SharedCode.CampaignMemberTriggerHelper(Trigger.Old);
    }

}