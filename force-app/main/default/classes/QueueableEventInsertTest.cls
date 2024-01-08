
@isTest
public with sharing class QueueableEventInsertTest {

    @isTest(SeeAllData=true)
     static void testEventInsert() {
        // Step 1: Set up test data
        List<VisionMetrix_Event__c> testEvents = new List<VisionMetrix_Event__c>();
        // Assuming VisionMetrix_Event__c has a field 'Circuit__c' for simplicity. Replace with actual fields.
        for (Integer i = 0; i < 210; i++) { // Creating more than 200 records to test chunking
            testEvents.add(new VisionMetrix_Event__c(Circuit__c = 'Test Circuit ' + i));
        }

        Test.startTest();
        // Step 2: Instantiate your Queueable class with test data
        QueueableEventInsert queueable = new QueueableEventInsert(testEvents);

        // Step 3: Enqueue the job
        ID jobID = System.enqueueJob(queueable);

        // Step 4: Stop the test to execute the queueable
        Test.stopTest();

        // Step 5: Asserts
        // Verify that the records were inserted
        List<VisionMetrix_Event__c> insertedEvents = [SELECT Name FROM VisionMetrix_Event__c];
        System.assertEquals(210, insertedEvents.size(), 'Incorrect number of records inserted');

        
    }
}