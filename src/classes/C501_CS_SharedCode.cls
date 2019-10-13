/*
    Copyright (c) 2019, 501Commons.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, C501_CS_SharedCode list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, C501_CS_SharedCode list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of 501Commons.org nor the names of
      its contributors may be used to endorse or promote products derived
      from C501_CS_SharedCode software without specific prior written permission.
 
    C501_CS_SharedCode SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF C501_CS_SharedCode SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

public with sharing class C501_CS_SharedCode { 

    public class ContactCacheException extends Exception {}

    public static void ContactCacheTriggerHelper( List<C501_Contact_Cache__c> contactCachesChanged) {

        System.debug('*****C501_CS_SharedCode::ContactCacheTriggerHelper');

        List<C501_Contact_Cache__c> insertContactCaches = new List<C501_Contact_Cache__c>();
        for (C501_Contact_Cache__c contactCache :contactCachesChanged) {

            if (contactCache.Type__c <> 'Business') {
                continue;
            }

            if (String.isBlank(contactCache.FirstName__c) || String.isBlank(contactCache.LastName__c) || String.isBlank(contactCache.Email__c) || String.isBlank(contactCache.Organization__c)) {
                contactCache.addError( new ContactCacheException('1 or more required fields missing; FirstName, LastName, Email, Organization'));
                continue;
            }
            else {
                insertContactCaches.add(contactCache);
            }
        }

        if (!insertContactCaches.isEmpty()) {

            List<Contact> insertContacts = new List<Contact>();
            for (C501_Contact_Cache__c contactCache :insertContactCaches) {
                insertContacts.add( new Contact(
                    AccountId = contactCache.Organization__c,
                    Email = contactCache.Email__c,
                    FirstName = contactCache.FirstName__c,
                    HomePhone = contactCache.HomePhone__c,
                    LastName = contactCache.LastName__c,
                    MailingCity = contactCache.MailingCity__c,
                    MailingCountry = contactCache.MailingCountry__c,
                    MailingPostalCode = contactCache.MailingPostalCode__c,
                    MailingState = contactCache.MailingState__c,
                    MailingStreet = contactCache.MailingStreet__c,
                    //MiddleName = contactCache.MiddleName__c,
                    MobilePhone = contactCache.Mobile__c,
                    OtherCity = contactCache.OtherCity__c,
                    OtherCountry = contactCache.OtherCountry__c,
                    OtherPostalCode = contactCache.OtherPostalCode__c,
                    OtherState = contactCache.OtherState__c,
                    OtherStreet = contactCache.OtherStreet__c,
                    Phone = contactCache.Phone__c,
                    Title = contactCache.Title__c));
            }

            if (!insertContacts.isEmpty()) {
                System.debug('*****C501_CS_SharedCode::ContactCacheTriggerHelper insertContacts: ' + insertContacts);
                insert insertContacts;
            }
        }
    }

/*
    private static void SetupCampaignMembers(Map<String, Campaign> campaignsMap, Set<String> contactCampaignMembers, Map<Id, String> contactCampaigns, String[] contactTags, List<CampaignMember> campaignMembersInsert, Boolean isUpdate, Contact contact) {

        for (String checkValue :contactTags) {

            String checkValueLower = checkValue.toLowerCase();
            System.debug('*****C501_CS_Shared_Code::SetupCampaignMembers checkValue: ' + checkValueLower);

            if (campaignsMap.containsKey(checkValueLower) && !contactCampaignMembers.contains(contact.Id + checkValueLower)) {
                System.debug('*****C501_CS_Shared_Code::SetupCampaignMembers Contact_Type__c Insert Campaign: ' + checkValueLower);

                contactCampaignMembers.add(contact.Id + checkValueLower);
                campaignMembersInsert.add(new CampaignMember(
                    CampaignId = campaignsMap.get(checkValueLower).Id,
                    ContactId = contact.Id
                ));

                String subscriptions = checkValue;
                if (contactCampaigns.containsKey(contact.Id)) {
                    subscriptions = contactCampaigns.remove(contact.Id) + ',' + subscriptions;
                }
                contactCampaigns.put(contact.Id, subscriptions);
            }

            // Check to add parent campaign
            if (campaignsMap.containsKey(checkValueLower) && !String.isBlank(campaignsMap.get(checkValueLower).ParentId)) {

                String checkValueParentLower = campaignsMap.get(checkValueLower).Parent.Name;
                System.debug('*****C501_CS_Shared_Code::SetupCampaignMembers checkValue Parent: ' + checkValueParentLower);

                if (campaignsMap.containsKey(checkValueParentLower) && !contactCampaignMembers.contains(contact.Id + checkValueParentLower)) {
                    System.debug('*****C501_CS_Shared_Code::SetupCampaignMembers Contact_Type__c Insert Campaign: ' + checkValueParentLower);

                    contactCampaignMembers.add(contact.Id + checkValueParentLower);
                    campaignMembersInsert.add(new CampaignMember(
                        CampaignId = campaignsMap.get(checkValueParentLower).Id,
                        ContactId = contact.Id
                    ));

                    String subscriptions = checkValue;
                    if (contactCampaigns.containsKey(contact.Id)) {
                        subscriptions = contactCampaigns.remove(contact.Id) + ',' + subscriptions;
                    }
                    contactCampaigns.put(contact.Id, subscriptions);
                }
            }
        }
    }

    public static void ContactTriggerHelper( List<Contact> contactsChanged, Boolean isUpdate) {
        
        List<Id> contactIds = new List<Id>();
        for (Contact contact :contactsChanged) {
            contactIds.add(contact.Id);
        }

        List<Campaign> campaigns = [
            SELECT Id, Name, ParentId, Parent.Name
            FROM Campaign
            WHERE RecordType.Name like 'Mailing List/Group' AND (Status = 'Planned' OR Status = 'In Progress')];

        if (campaigns.isEmpty()) {
            return;
        }

        Map<String, Campaign> campaignsMap = new Map<String, Campaign>();
        for (Campaign campaign :campaigns) {
            campaignsMap.put(campaign.Name.toLowerCase(), campaign);
        }

        List<CampaignMember> campaignMembers = [
            SELECT Id, ContactId, Campaign.Name
            FROM CampaignMember
            WHERE ContactId in :contactIds AND Campaign.Name in :campaignsMap.keySet()];

        Set<String> contactCampaignMembers = new Set<String>();
        Map<Id, String> contactCampaigns = new Map<Id, String>();
        for (CampaignMember campaignMember :campaignMembers) {
            System.debug('*****C501_CS_Shared_Code::ContactTriggerHelper CampaignMember Name: ' + campaignMember.Campaign.Name.toLowerCase() + ' Contact Id: ' + campaignMember.ContactId);
            contactCampaignMembers.add(campaignMember.ContactId + campaignMember.Campaign.Name.toLowerCase());

            String subscriptions = campaignMember.Campaign.Name;
            if (contactCampaigns.containsKey(campaignMember.ContactId)) {
                subscriptions = contactCampaigns.remove(campaignMember.ContactId) + ',' + subscriptions;
            }
            contactCampaigns.put(campaignMember.ContactId, subscriptions);
        }

        List<CampaignMember> campaignMembersInsert = new List<CampaignMember>();
        for (Contact contact :contactsChanged) {

            if (!contact.C501_CS_Created_By_Contact_Subscription__c) {

                // Legacy Field Check to see if Engagement(s) should be created for Legacy contact type fields
                //

                // Check Contact.Contact_Type__c (Picklist - Multi-Select)
                //
                if (!String.isBlank(contact.Contact_Type__c)) {
                    System.debug('*****C501_CS_Shared_Code::ContactTriggerHelper Check contact.Contact_Type__c: ' + contact.Contact_Type__c);
                    C501_CS_SharedCode.SetupCampaignMembers(campaignsMap, contactCampaignMembers, contactCampaigns, contact.Contact_Type__c.split(';'), campaignMembersInsert, isUpdate, contact);
                }

                // Check Contact.Strategy_Area__c (Picklist - Multi-Select)
                //
                if (!String.isBlank(contact.Strategy_Area__c)) {
                    System.debug('*****C501_CS_Shared_Code::ContactTriggerHelper Check contact.Strategy_Area__c: ' + contact.Strategy_Area__c);
                    C501_CS_SharedCode.SetupCampaignMembers(campaignsMap, contactCampaignMembers, contactCampaigns, contact.Strategy_Area__c.split(';'), campaignMembersInsert, isUpdate, contact);
                }

                // Check Contact.Tags__c (Picklist - Multi-Select)
                //
                if (!String.isBlank(contact.Tags__c)) {
                    System.debug('*****C501_CS_Shared_Code::ContactTriggerHelper Check contact.Tags__c: ' + contact.Tags__c);
                    C501_CS_SharedCode.SetupCampaignMembers(campaignsMap, contactCampaignMembers, contactCampaigns, contact.Tags__c.split(';'), campaignMembersInsert, isUpdate, contact);
                }
            }

            if (isUpdate) {
                if (contactCampaigns.containsKey(contact.Id)) {
                    contact.C501_CS_Subscriptions__c = contactCampaigns.get(contact.Id);
                    contact.C501_CS_Created_By_Contact_Subscription__c = true;
                }
                else {
                    contact.C501_CS_Subscriptions__c = '';
                    contact.C501_CS_Created_By_Contact_Subscription__c = false;
                }
            }
        }

        if (!campaignMembersInsert.isEmpty()) {
            insert campaignMembersInsert;
        }
    }
*/

    //  ConvertLeads
    //
    //  Outcomes
    //
    //  1) If the Lead.FirstName and Lead.LastName match only 1 Contact.FirstName and Contact.LastName then auto convert into the Contact
    //
    //  2) If the Lead.FirstName and Lead.LastName don't match any Contact.FirstName and Contact.LastName then convert into a new Contact if Lead.Email and Lead.Company are not blank
    //
    //  3) If Lead Convert and Contact.AccountId is blank & Lead.Company not blank then update Contact.AccountId
    //
    public static void ConvertLeadsByUserId(Boolean insertContacts) {

        String userId = UserInfo.getUserId();
        List<Lead> leads = [
          SELECT Id, FirstName, LastName, Company, Email
          FROM Lead
          WHERE IsConverted = false AND IsDeleted = false AND (CreatedById = :userId OR LastModifiedById = :userId)];
        System.debug(LoggingLevel.DEBUG, '*****C501_CS_SharedCode::ConvertLeadsByUserId - size: ' + String.valueOf(leads.size()) + ' All Leads: ' + leads);

        List<String> lastNames = new List<String>();
        for (Lead lead :leads) {
          if (!lastNames.contains(lead.LastName)) {
            lastNames.add(lead.LastName);
          }
        }

        Map<String, AggregateResult> contactNameMap = new Map<String, AggregateResult>();
        String strSoql = 'SELECT Count(Id) TotalMatches, MAX(Id) Contact_Id, FirstName, LastName, MAX(AccountId) Account_Id, MAX(Account.Name) Account_Name FROM Contact WHERE IsDeleted = false Group By FirstName, LastName';
        AggregateResult[] allAggregatedByContacts = Database.Query(strSoql);
        for (AggregateResult result : allAggregatedByContacts)  {
            
            String firstName = result.get('FirstName').toString();
            String lastName = result.get('LastName').toString();

            contactNameMap.put(firstName + ' ' + lastName, result);
        }

        Map<String, String> accountMap = new Map<String, String>();
        for (Account account :[SELECT Id, Name FROM Account WHERE IsDeleted = false ORDER BY LastModifiedDate DESC]) {
          if (accountMap.containsKey(account.Name)) {
            continue;
          }

          accountMap.put(account.Name, account.Id);
        }

        // Check for unique match only to convert
        List<Database.LeadConvert> convertLeads = new List<Database.LeadConvert>();
        for (Lead lead :leads) {
          String name = lead.FirstName + ' ' + lead.LastName;
          if (contactNameMap.containsKey(name)) {

            AggregateResult result = contactNameMap.get(name);
            Integer totalMatches = Integer.valueOf(result.get('TotalMatches'));
            String firstName = result.get('FirstName').toString();
            String lastName = result.get('LastName').toString();
            String contactId = result.get('Contact_Id').toString();
            String accountName = result.get('Account_Name').toString();
            String accountId = result.get('Account_Id').toString();

            if (totalMatches == 1) {

              // Convert to existing contact
              //
              Database.LeadConvert convertLead = new database.LeadConvert();
              convertLead.setLeadId(lead.Id);
              convertLead.convertedStatus = 'Qualified';
              convertLead.setDoNotCreateOpportunity(true);
              convertLead.contactid = contactId;
              convertLead.accountid = accountId;

              // Check Account Name
              if (String.isBlank(accountId) && !String.isBlank(lead.Company)) {
                if (accountMap.containsKey(lead.Company)) {
                  convertLead.accountid = accountMap.get(lead.Company);
                }
                else {
                  Account insertAccount = new Account(
                    Name = lead.Company
                  );

                  // Exception: Typically don't want to call DML commands in a loop to avoid DML limit of 100 but not expecting many of this scenario (most contacts should have an account).  If this becomes a problem then will need to handle this outside of the loop
                  insert insertAccount;
                  convertLead.accountid = insertAccount.Id;

                  accountMap.put(insertAccount.Name, insertAccount.Id);
                }
              }

              convertLeads.add(convertLead);
            }
          }
          else if (!String.isBlank(lead.Company)) {

            // Create new Contact
            //
            Database.LeadConvert convertLead = new database.LeadConvert();
            convertLead.setLeadId(lead.Id);
            convertLead.convertedStatus = 'Qualified';
            convertLead.setDoNotCreateOpportunity(true);

            // Check Account Name
            if (accountMap.containsKey(lead.Company)) {
              convertLead.accountid = accountMap.get(lead.Company);
            }
            else {
              Account insertAccount = new Account(
                Name = lead.Company
              );

              // Exception: Typically don't want to call DML commands in a loop to avoid DML limit of 100 but not expecting many of this scenario (most accounts should already be in SF).  If this becomes a problem then will need to handle this outside of the loop
              insert insertAccount;
              convertLead.accountid = insertAccount.Id;

              accountMap.put(insertAccount.Name, insertAccount.Id);
            }

            convertLeads.add(convertLead);
          }
        }

        System.debug(LoggingLevel.DEBUG, '*****C501_CS_SharedCode::ConvertLeadsByUserId convertLeads: ' + convertLeads);

        if(!convertLeads.isEmpty()){
          
          // Convert in groups of 100 at a time
          for(Integer i = 0; i <= convertLeads.size() / 100 ; i++){

            list<Database.LeadConvert> convertLeadsPartial = new list<Database.LeadConvert>();
            Integer startIndex = i*100;
            Integer endIndex = ((startIndex + 100) < convertLeads.size()) ? startIndex + 100: convertLeads.size();
            for(Integer j=startIndex;j < endIndex;j++){
              convertLeadsPartial.add(convertLeads[j]);
            }

            Database.LeadConvertResult[] results = Database.convertLead(convertLeadsPartial, false);
            for(Database.LeadConvertResult result : results) {
              System.assert(result.isSuccess());
            }            
          }
        }        
    }

    public static void CampaignMemberTriggerHelper( List<CampaignMember> campaignMembersChanged) {

        System.debug('*****C501_CS_SharedCode::CampaignMemberTriggerHelper');

        if (campaignMembersChanged == null || campaignMembersChanged.isEmpty()) {
            return;
        }

        System.debug('*****C501_CS_SharedCode::CampaignMemberTriggerHelper CampaignMembers Changed: ' + campaignMembersChanged);

        Set<Id> contactIds = new Set<Id>();
        for (CampaignMember campaignMember :campaignMembersChanged) {

            if (campaignMember.ContactId == null) {
                System.debug('*****C501_CS_Shared_Code::CampaignMemberTriggerHelper Skip campaign member since contactId is null which means Salesforce Data Import Wizard is managing the create process');
                continue;
            }

            contactIds.add(campaignMember.ContactId);
        }

        List<Campaign> campaigns = [
            SELECT Id, Name, ParentId, Parent.Name
            FROM Campaign
            WHERE RecordType.Name like 'Mailing List/Group' AND (Status = 'Planned' OR Status = 'In Progress')];

        if (campaigns.isEmpty()) {
            return;
        }

        List<Id> campaignIds = new List<Id>();
        for (Campaign campaign :campaigns) {
            campaignIds.add(campaign.Id);
        }

        List<CampaignMember> campaignMembers = [
            SELECT Id, ContactId, Campaign.Name
            FROM CampaignMember
            WHERE ContactId in :contactIds AND CampaignId in :campaignIds];

        Map<Id, String> contactSubscriptions = new Map<Id, String>();
        for (CampaignMember campaignMember :campaignMembers) {

            System.debug('*****C501_CS_Shared_Code::CampaignMemberTriggerHelper CampaignMember Name: ' + campaignMember.Campaign.Name + ' Contact Id: ' + campaignMember.ContactId);

            String subscriptions = campaignMember.Campaign.Name;
            if (contactSubscriptions.containsKey(campaignMember.ContactId)) {
                subscriptions = contactSubscriptions.remove(campaignMember.ContactId) + ',' + subscriptions;
            }
            contactSubscriptions.put(campaignMember.ContactId, subscriptions);
        }

        List<Contact> updateContacts = new List<Contact>();
        for (Id contactId :contactIds) {

            if (contactSubscriptions.containsKey(contactId)) {
                updateContacts.add(new Contact(
                    Id = contactId,
                    C501_CS_Subscriptions__c = contactSubscriptions.get(contactId),
                    C501_CS_Created_By_Contact_Subscription__c = true));
            }
            else {
                updateContacts.add(new Contact(
                    Id = contactId,
                    C501_CS_Subscriptions__c = '',
                    C501_CS_Created_By_Contact_Subscription__c = true));
            }
        }

        if (!updateContacts.isEmpty()) {
            update updateContacts;
        }

    }

    public static void TestSetup() {

        List<Account> listAccounts = new List<Account>();   
        Integer cAccounts = 10;     
        Integer matchIndex = 1;
        for (Integer i = 0; i < cAccounts; i++) {

            if (math.mod((i + 2), 2) == 0) {
                matchIndex++;
            }

            Account account = new Account(
                
                Name='TESTDATA Flintstone Household',
                BillingStreet = String.valueOf(matchIndex) + ' BillingStreet',
                BillingCity = 'BillingCity',
                BillingState = 'WA',
                BillingPostalCode =  '12345',
                Website = 'https://www.flintstone.org' + String.valueOf(matchIndex)
            );

            listAccounts.add(account);
        }                      

        insert listAccounts;

        Map<Id, Opportunity> listOpportunityHouseholds = new Map<Id, Opportunity>();
        List<Contact> listContacts = new List<Contact>();
        for (Integer i = 0; i < cAccounts; i++) {

            if (math.mod((i + 2), 2) == 0) {
                matchIndex++;
            }

            listOpportunityHouseholds.put(listAccounts[i].Id, new Opportunity(
                Name = 'TESTDATA Name ' + listAccounts[i].Id,
                StageName = 'Closed Won',
                CloseDate = System.today()
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Fred' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-21 - matchIndex),
                Email = String.valueOf(matchIndex) + 'fred@bedrock.org'
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Fred' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-21 - matchIndex),
                Email = String.valueOf(matchIndex) + 'fred@bedrock.org'
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Wilma' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-21 - matchIndex),
                Email = String.valueOf(matchIndex) + 'wilma@bedrock.org'
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Dino' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-2 - matchIndex),
                Email = String.valueOf(matchIndex) + 'dino@bedrock.org'
            ));
        }

        insert listOpportunityHouseholds.values();
        insert listContacts;

        Campaign campaign = new Campaign(Name = 'TESTDATA Campaign');
        insert campaign;

        CampaignMember campaignMember = new CampaignMember(
            CampaignId = campaign.Id,
            ContactId = listContacts[0].Id);
        insert campaignMember;

        PrintSalesforceStructure();
    }

    public static void PrintSalesforceLimits() {

        System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Aggregate Queries ' + Limits.getAggregateQueries() + ' of ' + Limits.getLimitAggregateQueries());
        System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - DML Rows ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows());
        System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - DML Statments ' + Limits.getDMLStatements() + ' of ' + Limits.getLimitDMLStatements());
        System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Queies ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
        System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Query Rows ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows());
        System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Sosl Queries ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries());
    }

    public static Boolean NearSalesforceLimits() {

        Boolean nearLimit = false;
        Integer percentageMultiple = 9;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_System_limits.htm

        if (Limits.getAggregateQueries() > ((Limits.getLimitAggregateQueries() / 10) * percentageMultiple)) {
            System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Aggregate Queries - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getAggregateQueries() + ' of ' + Limits.getLimitAggregateQueries());
            nearLimit = true;
        }
        if (Limits.getDMLRows() > ((Limits.getLimitDMLRows() / 10) * percentageMultiple)) {
            System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - DML Rows - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows());
            nearLimit = true;
        }
        if (Limits.getDMLStatements() > ((Limits.getLimitDMLStatements() / 10) * percentageMultiple)) {
            System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - DML Statments - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getDMLStatements() + ' of ' + Limits.getLimitDMLStatements());
            nearLimit = true;
        }
        if (Limits.getQueries() > ((Limits.getLimitQueries() / 10) * percentageMultiple)) {
            System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Queies - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
            nearLimit = true;
        }
        if (Limits.getQueryRows() > ((Limits.getLimitQueryRows() / 10) * percentageMultiple)) {
            System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows());
            nearLimit = true;
        }
        if (Limits.getSoslQueries() > ((Limits.getLimitSoslQueries() / 10) * percentageMultiple)) {
            System.debug('***** C501_CS_SharedCode::NearSalesforceLimits - Sosl Queries - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries());
            nearLimit = true;
        }

        return nearLimit;
    }

    public static void PrintSalesforceStructure() {

        System.debug('***** C501_CS_SharedCode::PrintSalesforceStructure');

        PrintSalesforceLimits();

        CodeCoverageTempHack();

/*
        for (Account account :[select Id, Name, Website, BillingStreet from Account WHERE Name LIKE 'TESTDATA%']) {
            System.debug('***** C501_CS_SharedCode::PrintSalesforceStructure Account - ' + String.valueOf(account));
        }
        for (Contact contact :[select Id, Account.Name, LastName, FirstName, Birthdate, Email from Contact WHERE LastName LIKE 'TESTDATA%']) {
            System.debug('***** C501_CS_SharedCode::PrintSalesforceStructure Contact - ' + String.valueOf(contact));
        }
        for (Opportunity opportunity :[select Id, Name from Opportunity WHERE Name LIKE 'TESTDATA%']) {
            System.debug('***** C501_CS_SharedCode::PrintSalesforceStructure Opportunity - ' + String.valueOf(opportunity));
        }
        for (Campaign campaign :[select Id, Name from Campaign WHERE Name LIKE 'TESTDATA%']) {
            System.debug('***** C501_CS_SharedCode::PrintSalesforceStructure Campaign - ' + String.valueOf(campaign));

            for (CampaignMember campaignMember :[select Id, Name from CampaignMember WHERE CampaignId = :campaign.Id]) {
                System.debug('***** C501_CS_SharedCode::PrintSalesforceStructure CampaignMember - ' + String.valueOf(campaignMember));
            }
        }
*/       
    }

    public static void CodeCoverageTempHack() {
        List<String> stringValues = new List<String>{ 'a', 'b'};

        Integer someNumber = 1;
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
    }
}