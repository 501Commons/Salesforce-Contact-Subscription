trigger C501_CS_LeadTrigger on Lead (after update, after insert) {
    
    System.debug(LoggingLevel.DEBUG, 'C501_CS_LeadTrigger update: ' + String.valueOf(Trigger.isUpdate) + ' size: ' + Trigger.New.size());

    C501_CS_SharedCode.ConvertLeadsByUserId(Trigger.new);
    C501_CS_SharedCode.CheckCampaignMembers(Trigger.new);
}