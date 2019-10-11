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
 
    THIS GroupFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS GroupFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

global virtual with sharing class C501_CTRL_ContactSubscription {

    private List<String> listStrFields;
    private Set<String> listContactSubscriptionRequests;
    
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
        new C501_CTRL_ContactSubscription(null);
    }

    global C501_CTRL_ContactSubscription(ApexPages.StandardController controller) {

        System.debug('***** C501_CTRL_ContactSubscription::C501_CTRL_ContactSubscription Constructor');

        redirect = false;
        listContactSubscriptionRequests = new Set<String>();
        
        // Get list of fields FROM fieldset
        listStrFields = new List<String>();
        for (Schema.FieldSetMember f : this.getStandardFields()) {
            listStrFields.add(f.getFieldPath());
        }
        for (Schema.FieldSetMember f : this.getPhonecontactFields()) {
            listStrFields.add(f.getFieldPath());
        }
        for (Schema.FieldSetMember f : this.getAssistantFields()) {
            listStrFields.add(f.getFieldPath());
        }
        for (Schema.FieldSetMember f : this.getAddressFields()) {
            listStrFields.add(f.getFieldPath());
        }
        for (Schema.FieldSetMember f : this.getDescriptionFields()) {
            listStrFields.add(f.getFieldPath());
        }

        // Required fields
        if (!listStrFields.contains('Id')) {
            listStrFields.add('Id');
        }
        if (!listStrFields.contains('LastName')) {
            listStrFields.add('LastName');
        }
        if (!listStrFields.contains('C501_CS_Group__c')) {
            listStrFields.add('C501_CS_Group__c');
        }
        if (!listStrFields.contains('C501_CS_Sub_Group__c')) {
            listStrFields.add('C501_CS_Sub_Group__c');
        }

        this.contactRecord = (Contact)controller.getRecord();

        if (controller != null && this.contactRecord.Id != null) {
            System.debug('***** C501_CTRL_ContactSubscription::C501_CTRL_ContactSubscription getRecord: ' + this.contactRecord);
            System.debug('***** C501_CTRL_ContactSubscription::C501_CTRL_ContactSubscription getRecordId: ' + this.contactRecord.Id);

            String strSoql = 'SELECT ' + String.join(listStrFields, ',');
            strSoql += ' FROM Contact WHERE Id = \'' + this.contactRecord.Id + '\'';

            System.debug('***** C501_CTRL_ContactSubscription::C501_CTRL_ContactSubscription soql: ' + strSoql);

            for (Contact contactRecord :Database.query(strSoql)) {
                this.contactRecord = contactRecord;
                System.debug('***** C501_CTRL_ContactSubscription::C501_CTRL_ContactSubscription query record: ' + this.contactRecord);
                break;
            }
        }
        else {
            this.contactRecord = new Contact();
        }
    }   
    
    // getter - reference in Visualforce as StandardFields
    global List<Schema.FieldSetMember> getStandardFields() {
        return fieldSetStandardActive.getFields();
    }

    global Schema.FieldSet fieldSetStandardActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CS_Standard_Information;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Standard Information')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // getter - reference in Visualforce as PhoneContactFields
    global List<Schema.FieldSetMember> getPhoneContactFields() {
        return fieldSetPhoneContactActive.getFields();
    }

    global Schema.FieldSet fieldSetPhoneContactActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CS_Phone_Contact_Information;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Phone Contact Information')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // getter - reference in Visualforce as AssistantFields
    global List<Schema.FieldSetMember> getAssistantFields() {
        return fieldSetAssistantActive.getFields();
    }

    global Schema.FieldSet fieldSetAssistantActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CS_Assistant_Information;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Assistant Information')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // getter - reference in Visualforce as AddressFields
    global List<Schema.FieldSetMember> getAddressFields() {
        return fieldSetAddressActive.getFields();
    }

    global Schema.FieldSet fieldSetAddressActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CS_Address_Information;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Address Information')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // getter - reference in Visualforce as DescriptionFields
    global List<Schema.FieldSetMember> getDescriptionFields() {
        return fieldSetDescriptionActive.getFields();
    }

    global Schema.FieldSet fieldSetDescriptionActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CS_Description_Information;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Description Information')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // status string for reporting the results of saving.
    global String strSaveResults { get; set; }

    global List<SelectOption> listGroups {
        get {
            if (listGroups == null )
                listGroups = this.ListGroups();

            return listGroups;
        }

        set;
        }

    global List<SelectOption> listSubGroups {
        get {
            if (listSubGroups == null )
                listSubGroups = this.ListSubGroups(contactRecord.C501_CS_Group__c);

            return listSubGroups;
        }

        set;
    }

    // The list of contact subscriptions.
    global List<Campaign> listContactSubscriptions {
        get {
            if (listContactSubscriptions == null) {
                System.debug('*****C501_CTRL_ContactSubscrition::listContactSubscriptions');

                listContactSubscriptions = new List<Campaign>();
                FillContactSubscriptions();
            }

            return listContactSubscriptions;
        }
        
        set;
    }

    global List<SelectOption> ListGroups() {

        Set<String> setGroupUnique = new Set<String>();
        List<SelectOption> listGroup = new List<SelectOption>();
        listGroup.add(new SelectOption('', ''));

        for (Campaign campaignRecord :[SELECT Id, Name FROM Campaign WHERE RecordType.Name = 'Mailing List/Group' AND Parent.Id = null AND (Status = 'Planned' OR Status = 'In Progress') ORDER BY Name ASC]) {
            listGroup.add(new SelectOption(
                campaignRecord.Id,
                campaignRecord.Name));
        }

        return listGroup;
    }

    global List<SelectOption> ListSubGroups(String groupFilter) {

        Set<String> setGroupUnique = new Set<String>();
        List<SelectOption> listGroup = new List<SelectOption>();
        listGroup.add(new SelectOption('', ''));

        if (String.isBlank(groupFilter)) {
            return null;
        }

        System.debug('*****C501_CTRL_ContactSubscrition::ListGroups groupFilter: ' + groupFilter);

        for (Campaign campaignRecord :[SELECT Id, Name FROM Campaign WHERE RecordType.Name = 'Mailing List/Group' AND Parent.Id = :groupFilter AND (Status = 'Planned' OR Status = 'In Progress') ORDER BY Name ASC]) {
            listGroup.add(new SelectOption(
                campaignRecord.Id,
                campaignRecord.Name));
        }

        return listGroup;
    }

    // helper function that the client can override, to query for the appropriate fields in contacts.
    global virtual void FillContactSubscriptions() {

        List<String> subscribedCampaignIds = new List<String>();
        if (!String.isBlank(contactRecord.Id)) {

            List<CampaignMember> members = [SELECT CampaignId FROM CampaignMember WHERE ContactId = :contactRecord.Id];
            if (!members.isEmpty()) {

                for (CampaignMember memberRecord :members) {
                    subscribedCampaignIds.add(memberRecord.CampaignId);
                }
            }
        }

        System.debug('*****C501_CTRL_ContactSubscrition::FillContactSubscriptions subscribedCampaignIds: ' + subscribedCampaignIds + ' listContactSubscriptionRequests: ' + listContactSubscriptionRequests);

        // Add Active Subscriptions
        String strSoql = 'SELECT C501_CS_Remove__c, C501_CS_Subscription__c, Name, Parent.Name FROM Campaign WHERE Id in :subscribedCampaignIds';
        for (Campaign campaignRecord :Database.Query(strSoql)) {
            campaignRecord.C501_CS_Subscription__c = 'Active';
            listContactSubscriptions.add(campaignRecord);
        }

        // Add Requested Subscriptions
        strSoql = 'SELECT C501_CS_Remove__c, C501_CS_Subscription__c, Name, Parent.Name FROM Campaign WHERE (NOT Id in :subscribedCampaignIds) AND Id in :listContactSubscriptionRequests';
        for (Campaign campaignRecord :Database.Query(strSoql)) {
            campaignRecord.C501_CS_Subscription__c = 'Requested';
            listContactSubscriptions.add(campaignRecord);
        }
    }
    
    // the user has changed the Group dropdown
    global virtual PageReference ChangeGroup() {

        contactRecord.C501_CS_Sub_Group__c = '';
        listSubGroups = null;
        strSaveResults = null;

        return null;
    }

    // the user has changed the Group Action dropdown
    global virtual PageReference RefreshSubscriptions() {

        System.debug('*****C501_CTRL_ContactSubscrition::RefreshSubscriptions');

        // Future Change - on refresh Remove value on any active subscriptions will be reset back to false.
        //      Fix would be here to update related campaign member by adding/updating C501_CS_Remove__c field.

        // Clear out list so will get rebuilt
        listContactSubscriptions = null;

        return null;
    }

    // the user has changed the Group Action dropdown
    global virtual PageReference OnChangeRemoveSubscription() {

        for (Campaign contactSubscription : listContactSubscriptions) {

            if (contactSubscription.C501_CS_Subscription__c == 'Requested') {
        
                if (contactSubscription.C501_CS_Remove__c) {

                    System.debug('***** C501_CTRL_ContactSubscription::OnChangeRemoveSubscription Remove Request contactSubscription: ' + contactSubscription);
                    listContactSubscriptionRequests.remove(contactSubscription.Id);
                }
                else {
                    System.debug('***** C501_CTRL_ContactSubscription::OnChangeRemoveSubscription Subscribe Request contactSubscription: ' + contactSubscription);
                    listContactSubscriptionRequests.add(contactSubscription.Id);
                }
            }
        }

        return null;
    }

    global virtual PageReference AddSubscription() {

        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription');

        if (String.isBlank(contactRecord.C501_CS_Group__c)) {
            return null;
        }

        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - listContactSubscriptions: ' + listContactSubscriptions);

        Campaign groupCampaign;
        Campaign subGroupCampaign;

        List<Campaign> campaigns = [SELECT Id, Name, Parent.Name from Campaign];
        for (Campaign campaignRecord :campaigns) {

            System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription Campaign - campaignRecordId: ' + campaignRecord.Id + ' contactRecord.C501_CS_Group__c: ' + contactRecord.C501_CS_Group__c + ' contactRecord.C501_CS_Sub_Group__c: ' + contactRecord.C501_CS_Sub_Group__c);

            // Check for Group Match
            if (campaignRecord.Id == contactRecord.C501_CS_Group__c) {
                groupCampaign = campaignRecord;
            }

            // Check for Sub Group Match
            if (!String.isBlank(contactRecord.C501_CS_Sub_Group__c)) {
                if (campaignRecord.Id == contactRecord.C501_CS_Sub_Group__c) {
                    subGroupCampaign = campaignRecord;
                }
            }
        }

        if (groupCampaign == null || groupCampaign.Id == null) {
            return null;
        }

        // Check if group already added
        if (listContactSubscriptions != null) {
            for (Campaign subscription :listContactSubscriptions) {

                if (!String.isBlank(contactRecord.C501_CS_Sub_Group__c)) {
                    if (subscription.Id.equals(contactRecord.C501_CS_Sub_Group__c)) {
                        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Sub Group: ' + contactRecord.C501_CS_Sub_Group__c + ' already subscribed');
                        return null;
                    }
                } else if (subscription.Id.equals(contactRecord.C501_CS_Group__c)) {
                    System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Group: ' + contactRecord.C501_CS_Group__c + ' already subscribed');
                    return null;
                }
            }
        }

        // Add subscription request
        if (subGroupCampaign == null || subGroupCampaign.Id == null) {
            System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Add Group: ' + groupCampaign.Id + ' into list: ' + listContactSubscriptionRequests);
            listContactSubscriptionRequests.add(groupCampaign.Id);
        }
        else {
            System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Add Sub Group: ' + subGroupCampaign.Id + ' into list: ' + listContactSubscriptionRequests);
            listContactSubscriptionRequests.add(subGroupCampaign.Id);
        }

        // Clear out list so will get rebuilt
        listContactSubscriptions = null;

        return null;
    }

    //save the Contacts created or modified
    global virtual PageReference SaveContact() {
        
        if (listContactSubscriptions == null) return null;
        
        strSaveResults = null;
        
        try {

            System.debug('***** C501_CTRL_ContactSubscription::SaveContact listContactSubscriptions: ' + String.valueOf(listContactSubscriptions));

            List<String> insertContactSubscriptions = new List<String>();
            List<String> removeContactSubscriptions = new List<String>();
            Integer numberOfSubscriptions = 0;
            for (Campaign contactSubscription : listContactSubscriptions) {

                if (contactSubscription.C501_CS_Remove__c) {
                    removeContactSubscriptions.add(contactSubscription.Id);
                }
                else if (contactSubscription.C501_CS_Subscription__c == 'Requested') {
                    numberOfSubscriptions++;
                    insertContactSubscriptions.add(contactSubscription.Id);
                }
                else if (contactSubscription.C501_CS_Subscription__c == 'Active') {
                    numberOfSubscriptions++;
                }
            }

            if (numberOfSubscriptions <= 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Contact must have at least 1 subscription'));
                return null;
            }

            contactRecord.C501_CS_Created_By_Contact_Subscription__c = true;
            
            if (String.isBlank(contactRecord.Id)) {
                insert contactRecord;
            }
            else {
                update contactRecord;
            }

            if (!removeContactSubscriptions.isEmpty()) {
                List<CampaignMember> removeMembers = [SELECT Id FROM CampaignMember where ContactId = :contactRecord.Id AND CampaignId in :removeContactSubscriptions];
                if (!removeMembers.isEmpty()) {
                    delete removeMembers;
                }
            }

            if (!insertContactSubscriptions.isEmpty()) {
                List<CampaignMember> insertMembers = new List<CampaignMember>();
                for (String campaignId :insertContactSubscriptions) {
                    insertMembers.add(new CampaignMember(
                        CampaignId = campaignId,
                        ContactId = contactRecord.Id
                    ));
                }

                if (!insertMembers.isEmpty()) {

                    insert insertMembers;
        
                    C501_CS_SharedCode.CampaignMemberTriggerHelper(insertMembers);
                }
            }

            listContactSubscriptionRequests.clear();
            listContactSubscriptions = null;

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
        idRedirect = contactRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;
        return null;
    }
}