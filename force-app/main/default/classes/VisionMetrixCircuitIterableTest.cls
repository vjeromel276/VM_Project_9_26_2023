@IsTest
public class VisionMetrixCircuitIterableTest {
    public VisionMetrixCircuitIterableTest() {
    }

    @IsTest
    public static void testCircuitIterable() {
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutPullCircuitMock());

        List<HttpResponse> responses = new List<HttpResponse>();
       

        Test.startTest();
         HttpResponse response;
        responses.add(response);
        // Deserializes the JSON string into collections of primitive data types.
        List<VisionMetrix_Circuit__c> circuitList = VisionMetrixHelperMethod.handleCircuits(responses);
        System.debug(circuitList);            
        // Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
        // for ( String key : results.keySet() ) {
        //     System.debug(key + ' : ' + results.get(key));
        // }
        // System.debug(results);
        // List<Object> circuits = ( List<Object> )results.get('circuits');
        // System.debug(circuits);
        Test.stopTest();
    }  
}