/**
 * @name              : VisionMetrixCallOutTest.cls
 * @description       : this class is used to test the VisionMetrixCallOut class
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 12-01-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 12-01-2023
 **/
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
}