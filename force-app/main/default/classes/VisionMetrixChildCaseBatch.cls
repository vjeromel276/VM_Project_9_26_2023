global class VisionMetrixChildCaseBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful, Database.AllowsCallouts {
    global Integer recordsParsed = 0;
    global Integer recordsUpdated = 0;
    global Boolean ExecuteNextJob = false;
    global static Integer BatchSize = 10;


    global Database.QueryLocator start(Database.BatchableContext context) {
        VisionMetrixCallOut.getLatestEvents();
        return Database.getQueryLocator([SELECT Id, CaseNumber, Customer_List__c, hasVisionMetrixTicket__c, 
                                                Account_Name_Text__c, AccountId, ParentId, RecordTypeId, 
                                                Case_Record_Type__c, VisionMETRIX_Ticket_Created_Date__c, VisionMETRIX_Ticket_Number__c, VisionMetrix_Parent_Case__c, 
                                                NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, 
                                                Maintenance_Start__c, Maintenance_End__c
                                         FROM Case
                                         WHERE hasVisionMetrixTicket__c != true AND Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND AccountId IN ( '0010B00001skFrkQAE', '0013g00000Tfxq2AAB', '001U000001jMJS6IAO', '0013g00000TfxtOAAR', '0010B00001p6Z3VQAU', '001U000001jMJVdIAO' ) AND ParentId = null]);
    }

    global void execute(Database.BatchableContext context, List<Case> scope) {
        VisionMetrixHelperMethod.handleCreateChildCases(scope);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new VisionMetrixChildCaseBatch(), BatchSize);
    }

    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new VisionMetrixBatch());
    }

    global static void start(Integer minute) {

        String jobName = 'VisionMetrixChildCaseBatch';
        if ( Test.isRunningTest() || minute == NULL ) {
            Database.executebatch(new VisionMetrixChildCaseBatch(), BatchSize);
        }
        else if ( Test.isRunningTest() || minute != NULL ) {
            jobName = jobName += ' - ' + minute + ' - ' + DateTime.now().format();
            String cron = '0 ' + String.valueOf(minute) + ' * * * ?';
            System.schedule(jobName, cron, new VisionMetrixChildCaseBatch());
        }
    }

}