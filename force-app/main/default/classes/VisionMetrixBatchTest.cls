/**
 * @name              : VisionMetrixBatchTest.cls
 * @description       : this class is used for testing VisionMetrixBatch class
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 12-01-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 12-01-2023
 **/
@isTest(SeeAllData=true)
public with sharing class VisionMetrixBatchTest {
    
    // Helper method to create test data
    private static List<Case> createTestCases() {
        List<Case> cases = new List<Case>();
        // Add logic to create Case records as per your schema
        return cases;
    }

    // Mock class to simulate callout response
    private class MockVisionMetrixCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('Mock response');
            return response;
        }
    }

    @isTest static void testBatchExecution() {
        // Set up test data
        List<Case> testCases = createTestCases();
        insert testCases;

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockVisionMetrixCallout());

        Test.startTest();
        // Execute batch
        VisionMetrixBatch batch = new VisionMetrixBatch();
        Database.executeBatch(batch, VisionMetrixBatch.BatchSize);
        Test.stopTest();
    }

    @isTest static void testSchedulableExecution() {
        // Set up test data
        List<Case> testCases = createTestCases();
        insert testCases;

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockVisionMetrixCallout());

        Test.startTest();
        // Schedule the batch and execute
        String cronExpr = '0 0 12 * * ?'; // daily at noon
        VisionMetrixBatch batch = new VisionMetrixBatch();
        System.schedule('Test VisionMetrixBatch', cronExpr, batch);
        Test.stopTest();
    }
}