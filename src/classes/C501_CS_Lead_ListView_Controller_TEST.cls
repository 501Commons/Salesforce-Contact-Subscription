/*
    Copyright (c) 2019, 501Commons.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of 501Commons.org nor the names of
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

@isTest
public class C501_CS_Lead_ListView_Controller_TEST {
    
    //==================== TEST METHOD(s) ======================================

    @isTest(SeeAllData='false')
    public static void ConvertListViewTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::ConvertListViewTests');

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', Company = 'Company_TESTDATA')};
        insert leadsBeforeConvert;

        List<Account> accounts = new List<Account> { new Account(Name = 'Company_TESTDATA')};
        insert accounts;

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', AccountId = accounts[0].Id)};
        insert contacts;

        Test.StartTest();

        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(leadsBeforeConvert);
        C501_CS_Lead_ListView_Controller controller = new C501_CS_Lead_ListView_Controller(standardController);

        controller.leadAutoConvertTrigger();   

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::ConvertListViewTests - expected all leads to be converted - leadsBeforeConvert: ' + leadsBeforeConvert.size() +  ' leadsAfterConvert: ' + leadsAfterConvert.size());
    }

    @isTest(SeeAllData='false')
    public static void ConvertTriggerTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerTests');

        List<Account> accounts = new List<Account> { new Account(Name = 'Company_TESTDATA')};
        insert accounts;

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', AccountId = accounts[0].Id)};
        insert contacts;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerTests - expected all leads to be converted - leadsBeforeConvert: ' + leadsBeforeConvert.size() +  ' leadsAfterConvert: ' + leadsAfterConvert.size());
    }

    @isTest(SeeAllData='false')
    public static void ConvertTriggerDoubleFirstNameSpaceTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerDoubleFirstNameSpaceTests');

        List<Account> accounts = new List<Account> { new Account(Name = 'Company_TESTDATA')};
        insert accounts;

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName1_TESTDATA FirstName2_TESTDATA', LastName = 'LastName1_TESTDATA LastName2_TESTDATA', AccountId = accounts[0].Id)};
        insert contacts;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName1_TESTDATA', LastName = 'LastName1_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerDoubleFirstNameSpaceTests - expected all leads to be converted - leadsBeforeConvert: ' + leadsBeforeConvert.size() +  ' leadsAfterConvert: ' + leadsAfterConvert.size());
    }

    @isTest(SeeAllData='false')
    public static void ConvertTriggerDoubleLastNameSpaceTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerDoubleLastNameSpaceTests');

        List<Account> accounts = new List<Account> { new Account(Name = 'Company_TESTDATA')};
        insert accounts;

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName1_TESTDATA LastName2_TESTDATA', AccountId = accounts[0].Id)};
        insert contacts;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName1_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerDoubleLastNameSpaceTests - expected all leads to be converted - leadsBeforeConvert: ' + leadsBeforeConvert.size() +  ' leadsAfterConvert: ' + leadsAfterConvert.size());
    }

    @isTest(SeeAllData='false')
    public static void ConvertTriggerDoubleLastNameHyphenTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerDoubleLastNameHyphenTests');

        List<Account> accounts = new List<Account> { new Account(Name = 'Company_TESTDATA')};
        insert accounts;

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName1_TESTDATA-LastName2_TESTDATA', AccountId = accounts[0].Id)};
        insert contacts;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName2_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::ConvertTriggerDoubleLastNameHyphenTests - expected all leads to be converted - leadsBeforeConvert: ' + leadsBeforeConvert.size() +  ' leadsAfterConvert: ' + leadsAfterConvert.size());
    }

    @isTest(SeeAllData='false')
    public static void ConvertExistingAccountTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::ConvertExistingAccountTests');

        List<Account> accounts = new List<Account> { new Account(Name = 'Company_TESTDATA')};
        insert accounts;

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', AccountId = accounts[0].Id)};
        insert contacts;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Account> accountsAfterConvert = [SELECT Id, Name FROM ACCOUNT WHERE Name like '%TESTDATA%'];
        System.assert(accountsAfterConvert.size() == 1, 'C501_CS_Lead_ListView_Controller_TEST::ConvertExistingAccountTests - expected a single account to be created - accountsAfterConvert: ' + accountsAfterConvert);

        List<Contact> contactsAfterConvert = [SELECT Id, AccountId FROM Contact WHERE LastName like '%TESTDATA%'];
        System.assert(contactsAfterConvert.size() == 1, 'C501_CS_Lead_ListView_Controller_TEST::ConvertExistingAccountTests - expected a single contact to be created - contactsAfterConvert: ' + contactsAfterConvert);
        System.assert(accountsAfterConvert[0].Id == contactsAfterConvert[0].AccountId, 'C501_CS_Lead_ListView_Controller_TEST::ConvertExistingAccountTests - expected Contact.AccountId: ' + contactsAfterConvert[0].AccountId + ' to equal Account.Id: ' + accountsAfterConvert[0].Id);
    }

    @isTest(SeeAllData='false')
    public static void DoNotDuplicateContactTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::DoNotDuplicateContactTests');

        List<Contact> contactsBeforeConvert = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_NOMATCH_TESTDATA')};
        insert contactsBeforeConvert;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Contact> contactsAfterConvert = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA')};
        System.assert(contactsBeforeConvert.size() == contactsAfterConvert.size(), 'C501_CS_Lead_ListView_Controller_TEST::DoNotDuplicateContactTests - expected no new contacts created - contactsBeforeConvert: ' + contactsBeforeConvert + ' contactsAfterConvert: ' + contactsAfterConvert);
    }

    @isTest(SeeAllData='false')
    public static void DoNotConvertMissingAccountTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::DoNotConvertMissingAccountTests');

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA')};
        insert contacts;

        List<Campaign> campaign = new List<Campaign> { new Campaign(Name = 'Campaign_TESTDATA')};
        insert campaign;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', Company = 'Company_TESTDATA', Engagement_Id__c = campaign[0].Id)};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(!leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::DoNotConvertMissingAccountTests - expected leads to not be converted since missing Contact-Account relationship');
    }

    @isTest(SeeAllData='false')
    public static void DoNotConvertMissingCampaignTests() {

        System.debug(LoggingLevel.DEBUG, 'C501_CS_Lead_ListView_Controller_TEST::DoNotConvertMissingAccountTests');

        List<Contact> contacts = new List<Contact> { new Contact(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA')};
        insert contacts;

        Test.StartTest();

        List<Lead> leadsBeforeConvert = new List<Lead> { new Lead(FirstName = 'FirstName_TESTDATA', LastName = 'LastName_TESTDATA', Company = 'Company_TESTDATA')};
        insert leadsBeforeConvert;

        Test.StopTest();

        List<Lead> leadsAfterConvert = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE LastName like '%TESTDATA%' AND IsConverted = false];
        System.assert(!leadsAfterConvert.isEmpty(), 'C501_CS_Lead_ListView_Controller_TEST::DoNotConvertMissingCampaignTests - expected leads to not be converted since missing Lead-Engagement relationship');
    }   
}