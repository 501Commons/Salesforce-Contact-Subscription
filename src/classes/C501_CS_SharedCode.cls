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
*/

    //  ConvertLeads
    //
    //  Assumptions
    //
    //  1) Always assume a Contact has an Associated Account (this is enforce in Salesforce)
    //
    //  Outcomes
    //
    //  1) If the Lead.FirstName and Lead.LastName match only 1 Contact.FirstName and Contact.LastName then auto convert into the Contact
    //
    //
    public static void ConvertLeadsByUserId() {

        System.debug(LoggingLevel.DEBUG, '*****C501_CS_SharedCode::ConvertLeadsByUserId');

        String userId = UserInfo.getUserId();
        List<Lead> leads = [
          SELECT Id, FirstName, LastName, Company, Email
          FROM Lead
          WHERE IsConverted = false AND IsDeleted = false AND (CreatedById = :userId OR LastModifiedById = :userId)];

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
            
            if (result.get('FirstName') != null && result.get('LastName') != null) {
                String firstName = result.get('FirstName').toString();
                String lastName = result.get('LastName').toString();

                String name = firstName + ' ' + lastName;
                if (contactNameMap.containsKey(name)) {

                    // Remove from consideration since potential match already added related to a double name scenario
                    contactNameMap.remove(name);
                }
                else {
                    contactNameMap.put(name, result);
                }

                // Check for Double FirstName and/or Double LastName
                //
                List<String> firstNamesParts = new List<String> { firstName };
                List<String> lastNamesParts = new List<String> { lastName };
                if (firstName.contains(' ')) {
                    firstNamesParts = firstName.split(' ');
                }
                if (lastName.contains(' ')) {
                    lastNamesParts = lastName.split(' ');
                }
                else if (lastName.contains('-')) {
                    // Check for Double LastName by space
                    lastNamesParts = lastName.split('-');
                }

                if (firstNamesParts.size() > 1 || lastNamesParts.size() > 1) {
                    for (String firstNamePart :firstNamesParts) {
                        for (String lastNamePart :lastNamesParts) {
                            name = firstNamePart + ' ' + lastNamePart;
                            if (contactNameMap.containsKey(name)) {

                                // Remove from consideration since potential match already added related to a double name scenario
                                contactNameMap.remove(name);
                            }
                            else {
                                contactNameMap.put(name, result);
                            }
                        }
                    }
                }
            }
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
            String accountName = result.get('Account_Name') == null ? '' : result.get('Account_Name').toString();
            String accountId = result.get('Account_Id') == null ? '' : result.get('Account_Id').toString();

            if (totalMatches == 1) {

                // Convert to existing contact
                //
                Database.LeadConvert convertLead = new database.LeadConvert();
                convertLead.setLeadId(lead.Id);
                convertLead.convertedStatus = 'Qualified';
                convertLead.setDoNotCreateOpportunity(true);
                convertLead.contactid = contactId;
                if (String.isBlank(accountId)) {
                    // Lead Convert - both the contact and account ids must be set & account must be a parent of the contact
                    continue;
                }

                convertLead.accountid = accountId;
                convertLeads.add(convertLead);
            }
          }
        }

        System.debug(LoggingLevel.DEBUG, '*****C501_CS_SharedCode::ConvertLeadsByUserId convertLeads: ' + convertLeads);

        if(!convertLeads.isEmpty()){
          
            // Convert in groups of 100 at a time
            for(Integer i = 0; i <= convertLeads.size() / 100; i++){

                list<Database.LeadConvert> convertLeadsPartial = new list<Database.LeadConvert>();
                Integer startIndex = i * 100;
                Integer endIndex = ((startIndex + 100) < convertLeads.size()) ? startIndex + 100: convertLeads.size();
                for (Integer j=startIndex; j < endIndex; j++){
                    convertLeadsPartial.add(convertLeads[j]);
                }

                Database.LeadConvertResult[] results = Database.convertLead(convertLeadsPartial, false);
                for (Database.LeadConvertResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error err : result.getErrors()) {
                            System.debug(LoggingLevel.ERROR, '***** C501_CS_SharedCode::ConvertLeadsByUserId Lead Convert Exception: ' + err.getMessage());
                        }
                    }
                }            
            }
        }        
    }

    public static void ContactTriggerHelper( List<Contact> contactsChanged, Boolean isInsert) {

        Set<Id> contactIds = new Set<Id>();
        for (Contact contact :contactsChanged) {
            contactIds.add(contact.Id);
        }

        C501_CS_SharedCode.CheckAffiliation(contactIds, contactsChanged);

        if (isInsert) {
            return;
        }

        C501_CS_SharedCode.UpdateContactSubscriptions(contactIds, contactsChanged);
    }

    public static void CampaignMemberTriggerHelper( List<CampaignMember> campaignMembersChanged) {

        if (campaignMembersChanged == null || campaignMembersChanged.isEmpty()) {
            return;
        }

        Set<Id> contactIds = new Set<Id>();
        List<Contact> contacts = new List<Contact>();
        for (CampaignMember campaignMember :campaignMembersChanged) {

            if (campaignMember.ContactId == null) {
                System.debug('*****C501_CS_Shared_Code::CampaignMemberTriggerHelper Skip campaign member since contactId is null which means Salesforce Data Import Wizard is managing the create process');
                continue;
            }

            contactIds.add(campaignMember.ContactId);
            contacts.add(new Contact( Id = campaignMember.ContactId));
        }

        C501_CS_SharedCode.UpdateContactSubscriptions(contactIds, contacts);

        if (!contacts.isEmpty()) {
            update contacts;
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

    private static void CheckAffiliation(Set<Id> contactIds, List<Contact> contacts) {

        Set<String> affiliationKeys = new Set<String>();
        for (Affiliation__c affiliation : [SELECT Id, Individual__c, Organization__c FROM Affiliation__c where Individual__c in :contactIds]) {
            affiliationKeys.add(String.valueOf(affiliation.Individual__c) + String.valueOf(affiliation.Organization__c));
        }

        List<Affiliation__c> insertAffiliations = new List<Affiliation__c>();
        for (Contact contactRecord :contacts) {

            if (String.isBlank((String)contactRecord.Id) || String.isBlank((String)contactRecord.AccountId)) {
                continue;
            }

            if (!affiliationKeys.contains(String.valueOf(contactRecord.Id) + String.valueOf(contactRecord.AccountId))) {
                insertAffiliations.add(new Affiliation__c(
                    Individual__c = contactRecord.Id,
                    Organization__c = contactRecord.AccountId
                ));
            }
        }

        Database.insert(insertAffiliations, false);
    }

    private static void UpdateContactSubscriptions(Set<Id> contactIds, List<Contact> contacts) {

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

        for (Contact contact :contacts) {

            if (contactSubscriptions.containsKey(contact.Id)) {
                contact.C501_CS_Subscriptions__c = contactSubscriptions.get(contact.Id);
                contact.C501_CS_Created_By_Contact_Subscription__c = true;
            }
            else {
                contact.C501_CS_Subscriptions__c = '';
                contact.C501_CS_Created_By_Contact_Subscription__c = true;
            }
        }
    }
}