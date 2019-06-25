trigger C501_CS_ContactTrigger on Contact (before insert, before update) {

    String errorMessage = 'New contact needs to go through the Create button using the Contact Subscription process.';
    List<Contact> insertContacts = Trigger.New;
    for (Contact contact :insertContacts) {
        if (!contact.C501_CS_Created_By_Contact_Subscription__c) {
//            contact.addError(errorMessage);
        }
    }
}