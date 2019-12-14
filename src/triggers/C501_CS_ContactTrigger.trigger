trigger C501_CS_ContactTrigger on Contact (before update, after update, before insert, after insert) {
    C501_CS_SharedCode.ContactTriggerHelper(Trigger.newMap, Trigger.New, Trigger.isInsert, Trigger.isAfter);
}