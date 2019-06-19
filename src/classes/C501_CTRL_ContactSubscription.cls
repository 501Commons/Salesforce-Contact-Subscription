/*
    Copyright (c) 2016, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

global virtual with sharing class C501_CTRL_ContactSubscription {

    private List<String> listStrFields;
    
    global boolean redirect { get; private set; }
    global ID idRedirect { get; private set; }
    
    global Contact contactRecord {
        get {
            if (contactRecord == null) {
                contactRecord = new Contact();
            }

            return contactRecord;
        }
        set;
    }

    // constructor
    global C501_CTRL_ContactSubscription() {

        System.debug('***** C501_CTRL_ContactSubscription::C501_CTRL_ContactSubscription Constructor');

        redirect = false;
        
        // handle optional parameters (must use string, not ID, to handle null)
        string id = ApexPages.currentPage().getParameters().get('id');
        if (id != null && id != '') contactRecord.Id = id;

        // Get list of fields FROM fieldset
        listStrFields = new List<String>();
        for (Schema.FieldSetMember f : this.getFields()) {
            listStrFields.add(f.getFieldPath());
        }

        // Required fields
        if (!ListPartialContains(listStrFields, 'Id')) {
            listStrFields.add('Id');
        }
        if (!ListPartialContains(listStrFields, 'LastName')) {
            listStrFields.add('LastName');
        }
    }   
    
    private Boolean ListPartialContains(List<String> listStrFields, String fieldValue) {

        if (listStrFields == null) {
            return false;
        }

        for (String listValue :listStrFields) {
            if (listValue.contains(fieldValue)) {
                return true;
            }
        }

        return false;
    }

    global Schema.FieldSet fieldSetActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.ContactSubscription;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.contains('ContactSubscription_custom')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // getter - reference in Visualforce as fields
    global List<Schema.FieldSetMember> getFields() {
        return fieldSetActive.getFields();
    }

    // status string for reporting the results of saving.
    global String strSaveResults { get; set; }
      
    // The list of contact subscriptions.
    global List<CampaignMember> listContactSubscriptions {
        get {
            if (listContactSubscriptions == null) {
                FillContactSubscriptions();
            }

            return listContactSubscriptions;
        }
        
        set;
    }
        
    // helper function that the client can override, to query for the appropriate fields in contacts.
    global virtual void FillContactSubscriptions() {

        String strSoql = 'SELECT Campaign.Name, Campaign.Parent.Name FROM CampaignMember WHERE ContactId = :contactRecord.Id Order By Campaign.Parent.Name, Campaign.Name ASC';
        listContactSubscriptions = Database.Query(strSoql);
    }
    
    global virtual PageReference AddSubscription() {
        
        if (listContactSubscriptions == null) {
            listContactSubscriptions = new List<CampaignMember>();
        }

        if (String.isBlank(contactRecord.Group__c)) {
            return null;
        }

        Id groupId;

        List<Campaign> campaigns = [SELECT Id, Name, Parent.Name from Campaign];
        for (Campaign campaignRecord :campaigns) {
            if (campaignRecord.Name == contactRecord.Group__c) {
                groupId = campaignRecord.Id;
                break;
            }
        }

        if (groupId == null) {
            return null;
        }

        // Check if group already added
        for (CampaignMember subscription :listContactSubscriptions) {
            if (subscription.Campaign.Name.equals(contactRecord.Group__c)) {
                System.debug('*****C501_CTRL_ContactSubscrition::FillContactSubscriptions - Group: ' + contactRecord.Group__c + ' already subscribed');
                return null;
            }
        }

        // Add subscription
        listContactSubscriptions.add( new CampaignMember(
            CampaignId = groupId
        ));

        return null;
    }

    //save the Contacts created or modified
    global virtual PageReference SaveContact() {
        
        if (listContactSubscriptions == null) return null;
        
        strSaveResults = null;
        
        try {
            System.debug('***** C501_CTRL_ContactSubscription::SaveContact listContactSubscriptions: ' + String.valueOf(listContactSubscriptions));

            List<CampaignMember> insertContactSubscriptions = new List<CampaignMember>();
            List<CampaignMember> removeContactSubscriptions = new List<CampaignMember>();
            for (CampaignMember contactSubscription : listContactSubscriptions) {

                if (contactSubscription.C501_CS_Action__c == 'Remove' && !String.isBlank(contactSubscription.Id)) {
                    removeContactSubscriptions.add(contactSubscription);
                }
                else if (String.isBlank(contactSubscription.Id)) {
                    insertContactSubscriptions.add(contactSubscription);
                }
            }

            if (!removeContactSubscriptions.isEmpty()) {
                delete removeContactSubscriptions;
            }

            if (!insertContactSubscriptions.isEmpty()) {
                insert insertContactSubscriptions;
            }

            update contactRecord;

            return null;

        } catch (Exception e) {
            strSaveResults = Label.CS_labelContactSubscriptionErrorOnSave;
            ApexPages.addMessages(e); 
            return null;
        }
    }

    //save the Contacts modified, and then close the page.
    global virtual PageReference SaveAndCloseContact() {
        SaveContact();
        if (ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
           ApexPages.hasMessages(ApexPages.Severity.FATAL) ||
            ApexPages.hasMessages(ApexPages.Severity.WARNING)) {
                return null; // don't close window.
        }
        return Cancel();    
    }
    
    // user wants to close this page
    global virtual PageReference Cancel() {
        //idRedirect = contactRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;
        return null;
    }
}