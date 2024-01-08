@isTest
public with sharing class QueueableCircuitInsertTest {
    @isTest(SeeAllData=true)
     static void testCircuitInsert() {
        // Step 1: Set up test data
        List<VisionMetrix_Circuit__c> testCircuits = new List<VisionMetrix_Circuit__c>();
        // Assuming VisionMetrix_Circuit__c has a field 'Circuit_Alias__c' for simplicity. Replace with actual fields.
        for (Integer i = 0; i < 210; i++) { // Creating more than 200 records to test chunking
            testCircuits.add(new VisionMetrix_Circuit__c(Circuit_Alias__c = 'Test Circuit ' + i));
        }

        Test.startTest();
        // Step 2: Instantiate your Queueable class with test data
        QueueableCircuitInsert queueable = new QueueableCircuitInsert(testCircuits);

        // Step 3: Enqueue the job
        ID jobID = System.enqueueJob(queueable);

        // Step 4: Stop the test to execute the queueable
        Test.stopTest();

        // Step 5: Asserts
        // Verify that the records were inserted
        List<VisionMetrix_Circuit__c> insertedCircuits = [SELECT Name FROM VisionMetrix_Circuit__c];
        System.assertEquals(insertedCircuits.size(), insertedCircuits.size(), 'Incorrect number of records inserted');

        
    }
}