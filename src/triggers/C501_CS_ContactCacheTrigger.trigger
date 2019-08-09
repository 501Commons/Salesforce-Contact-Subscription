trigger C501_CS_ContactCacheTrigger on C501_Contact_Cache__c (before update) {
    C501_CS_SharedCode.ContactCacheTriggerHelper(Trigger.New);
}