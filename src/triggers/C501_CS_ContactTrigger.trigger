trigger C501_CS_ContactTrigger on Contact (before update, before insert, after insert) {
    C501_CS_SharedCode.ContactTriggerHelper(Trigger.New, Trigger.isInsert);
}