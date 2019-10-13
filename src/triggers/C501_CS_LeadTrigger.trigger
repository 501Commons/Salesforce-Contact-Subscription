trigger C501_CS_LeadTrigger on Lead (after update, after insert) {
    C501_CS_SharedCode.ConvertLeadsByUserId(false);
}