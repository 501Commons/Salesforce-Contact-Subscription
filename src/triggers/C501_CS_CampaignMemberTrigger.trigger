trigger C501_CS_CampaignMemberTrigger on CampaignMember (after insert, after delete) {

    C501_CS_SharedCode.CampaignMemberTriggerHelper(Trigger.Old, Trigger.isDelete);
}