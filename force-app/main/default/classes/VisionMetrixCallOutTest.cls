@isTest
public class VisionMetrixCallOutTest {
    public VisionMetrixCallOutTest() {
    }

    @isTest
    public static void vmLoginCalloutTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCallOutMock());
        Test.startTest();
        
        String response = VisionMetrixCallOut.visionMetrixLogin();
        System.debug('response: ' + response);
        Test.stopTest();
        String token ='8bdb863aec0613028a5d1a31ce2b596d94fe3f6f';
        System.assertEquals(response.length(), token.length());
        

    }

    @isTest
    public static void pullAllCircuitsTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutPullCircuitMock());
        Test.startTest();
        
        VisionMetrixCallOut.pullAllCircuits();
        Test.stopTest();
        
    }
    
    @isTest
    public static void addBulkVMTicketTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutAddBulkVMTicketMock());
        
        List<Case> tickets = new List<Case>();
        
        Test.startTest();
        HttpResponse res = VisionMetrixCallOut.addBulkVMTicket(tickets,'token');
        Test.stopTest();
        System.debug('res: ' + res);
        System.assertEquals(200, res.getStatusCode());
        
    }

    @isTest(SeeAllData=true)
    public static void getLatestEventsTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutGetLatestEventsMock());
        
        Test.startTest();
        VisionMetrixCallOut.getLatestEvents();
        Test.stopTest();
        
    }
}