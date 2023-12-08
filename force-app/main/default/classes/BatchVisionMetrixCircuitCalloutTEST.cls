@isTest
public class BatchVisionMetrixCircuitCalloutTEST {
    public BatchVisionMetrixCircuitCalloutTEST() {

    }
    @isTest
    public static void circuitsTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutPullCircuitMock());
        Test.startTest();
        HttpResponse res = new HttpResponse();
        
        // System.assertEquals(1, circuits.size());
       
        BatchVisionMetrixCircuitCallout.start(0);
        Test.stopTest();
        
    }
}