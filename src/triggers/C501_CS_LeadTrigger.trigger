trigger C501_CS_LeadTrigger on Lead (after update, after insert) {
    System.debug(LoggingLevel.DEBUG, '*****C501_CS_LeadTrigger - isInsert: ' + trigger.isInsert);
    C501_CS_SharedCode.ConvertLeadsByUserId();
}