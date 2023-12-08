/**
 * @name              : BatchVisionMetrixCircuitCalloutTEST.cls
 * @description       : this class is used to test the batch class for VisionMetrix_Circuit__c
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 12-04-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 12-04-2023
 **/
@isTest
public class BatchVisionMetrixCircuitCalloutTEST {
    public BatchVisionMetrixCircuitCalloutTEST() {

    }
    @isTest
    public static void circuitsTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutPullCircuitMock2());
        Test.startTest();
        HttpResponse res = new HttpResponse();
        
        // System.assertEquals(1, circuits.size());
       
        BatchVisionMetrixCircuitCallout.start(0);
        Test.stopTest();
        
    }
}