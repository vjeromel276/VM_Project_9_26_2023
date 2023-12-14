@isTest
public with sharing class VisionMetrixBatchTest {

    // Set up test data
    @TestSetup
    public static void setup() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test case
        Case testCase = new Case(AccountId = '0010B00001skFrkQAE', Subject = 'Test Case', Description = 'Test Case Description', RecordTypeId='0120B000000AJaoQAG',VisionMetrix_Parent_Case__c = true, ParentId = null, Origin='Reported (Email)', NotificationType__c = 'Maintenance', NOC_Ticket_Assigment__c = 'NOC', Maintenance_Start__c = System.today(), Maintenance_End__c = System.today());
        insert testCase;
    }
 
    @isTest
    static void testBatchExecution() {
        
		List<Case> tickets = [SELECT Id,CaseNumber, Account_Name_Text__c, AccountId, ParentId, RecordTypeId, Case_Record_Type__c, VisionMETRIX_Ticket_Created_Date__c,VisionMETRIX_Ticket_Number__c, VisionMetrix_Parent_Case__c, NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
                              FROM Case
                              WHERE Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND ParentId = null];

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutMock());

        Test.startTest();
        // Execute batch
        VisionMetrixBatch.start(0);
        Test.stopTest();
    }

}