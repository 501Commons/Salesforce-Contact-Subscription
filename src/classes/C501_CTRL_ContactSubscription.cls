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

        if (controller != null) {
            this.contactRecord = (Contact)controller.getRecord();
        }
        else {
            this.contactRecord = new Contact();
        }

        redirect = false;
        listContactSubscriptionRequests = new Set<String>();
        
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

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CS_Information;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Information')) {
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

        for (Campaign campaignRecord :[SELECT Id, Name FROM Campaign WHERE Status = 'Planned' OR Status = 'In Progress' ORDER BY Name ASC]) {
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

        for (Campaign campaignRecord :[SELECT Id, Name FROM Campaign WHERE Parent.Id = :groupFilter AND (Status = 'Planned' OR Status = 'In Progress') ORDER BY Name ASC]) {
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

        listSubGroups = null;
        strSaveResults = null;

        return null;
    }

    // the user has changed the Group Action dropdown
    global virtual PageReference ChangeGroupAction() {

        System.debug('*****C501_CTRL_ContactSubscrition::ChangeGroupAction');

        for (Campaign contactSubscription : listContactSubscriptions) {

            if (contactSubscription.C501_CS_Remove__c && contactSubscription.C501_CS_Subscription__c == 'Requested') {
        
                System.debug('***** C501_CTRL_ContactSubscription::ChangeGroupAction Remove Request contactSubscription: ' + contactSubscription);
                listContactSubscriptionRequests.remove(contactSubscription.Id);
            }
        }

        System.debug('*****C501_CTRL_ContactSubscrition::ChangeGroupAction - reset listContactSubscriptions');

        // Clear out list so will get rebuilt
        listContactSubscriptions = null;

        return null;
    }

    global virtual PageReference AddSubscription() {

        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription');

        if (String.isBlank(contactRecord.C501_CS_Group__c)) {
            return null;
        }

        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Group Id: ' + contactRecord.C501_CS_Group__c);

        Campaign groupCampaign;

        List<Campaign> campaigns = [SELECT Id, Name, Parent.Name from Campaign];
        for (Campaign campaignRecord :campaigns) {

            System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription Campaign - campaignRecord: ' + campaignRecord.Name);

            if (campaignRecord.Id == contactRecord.C501_CS_Group__c) {
                groupCampaign = campaignRecord;
                break;
            }
        }

        if (groupCampaign.Id == null) {
            return null;
        }

        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Group Found: ' + groupCampaign.Name);

        // Check if group already added
        if (listContactSubscriptions != null) {
            for (Campaign subscription :listContactSubscriptions) {
                if (subscription.Name.equals(contactRecord.C501_CS_Group__c)) {
                    System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - Group: ' + contactRecord.C501_CS_Group__c + ' already subscribed');
                    return null;
                }
            }
        }

        // Add subscription request
        listContactSubscriptionRequests.add(groupCampaign.Id);

        System.debug('*****C501_CTRL_ContactSubscrition::AddSubscription - reset listContactSubscriptions');

        // Clear out list so will get rebuilt
        listContactSubscriptions = null;

        return null;
    }

    //save the Contacts created or modified
    global virtual PageReference SaveContact() {
        
        if (listContactSubscriptions == null) return null;
        
        strSaveResults = null;
        
        try {

            if (String.isBlank(contactRecord.Id)) {
                insert contactRecord;
            }
            else {
                update contactRecord;
            }

            System.debug('***** C501_CTRL_ContactSubscription::SaveContact listContactSubscriptions: ' + String.valueOf(listContactSubscriptions));

            List<String> insertContactSubscriptions = new List<String>();
            List<String> removeContactSubscriptions = new List<String>();
            for (Campaign contactSubscription : listContactSubscriptions) {

                if (contactSubscription.C501_CS_Remove__c) {
                    removeContactSubscriptions.add(contactSubscription.Id);
                }
                else if (String.isBlank(contactSubscription.Id)) {
                    insertContactSubscriptions.add(contactSubscription.Id);
                }
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
                }
            }

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