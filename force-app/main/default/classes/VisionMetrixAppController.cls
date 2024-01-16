public with sharing class VisionMetrixAppController {
    @AuraEnabled(cacheable = true)
    public static List<Case> getParentCases() {
        return [SELECT Id, CaseNumber, hasVisionMetrixTicket__c, Account_Name_Text__c, 
                       AccountId, ParentId, RecordTypeId, Case_Record_Type__c, 
                       VisionMETRIX_Ticket_Created_Date__c, VisionMETRIX_Ticket_Number__c, VisionMetrix_Parent_Case__c, NotificationType__c, 
                       Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, 
                       Maintenance_End__c
                FROM Case
                WHERE hasVisionMetrixTicket__c != true AND Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND AccountId IN ( '0010B00001skFrkQAE', '0013g00000Tfxq2AAB', '001U000001jMJS6IAO', '0013g00000TfxtOAAR', '0010B00001p6Z3VQAU', '001U000001jMJVdIAO' ) AND ParentId = null];
    }

    @AuraEnabled(cacheable = true)
    public static List<Case> getChildCases(String parentCaseID) {
        return [SELECT Id, CaseNumber
                FROM Case
                WHERE ParentId = :parentCaseID];
    }

}