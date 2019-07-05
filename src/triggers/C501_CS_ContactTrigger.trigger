trigger C501_CS_ContactTrigger on Contact (before insert, before update) {

    String errorMessage = 'New contact needs to go through the Create button using the Contact Subscription process.  Click on the Individuals tab, select a View then click Go - from that screen click the Create button';
    List<Contact> insertContacts = Trigger.New;
    for (Contact contact :insertContacts) {
        if (!contact.C501_CS_Created_By_Contact_Subscription__c) {
            // NOTE: Disabled because contacts created from Outlook sync would throw an error - need to figure out how to ignore those new contacts or another method to block.
        //    contact.addError(errorMessage);
        }
    }
}