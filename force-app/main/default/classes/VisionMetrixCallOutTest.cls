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
    
    @isTest
    public static void addBulkVMTicketTest(){
        Test.setMock(HttpCalloutMock.class, new VisionMetrixCalloutAddBulkVMTicketMock());
        
        List<Case> tickets = [SELECT Id,CaseNumber, Account_Name_Text__c, AccountId, ParentId, RecordTypeId, Case_Record_Type__c, VisionMETRIX_Ticket_Created_Date__c,VisionMETRIX_Ticket_Number__c, VisionMetrix_Parent_Case__c, NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
                                                FROM Case
                                                WHERE Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND ParentId = null
                                                Limit 1];
        Test.startTest();
        
        HttpResponse res = VisionMetrixCallOut.addBulkVMTicket(tickets,'token');
        Test.stopTest();
        System.debug('res: ' + res);
        System.assertEquals(200, res.getStatusCode());
        
    }
}