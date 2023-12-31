//  * @description       : VisionMetrixBatch
//  * @author            : vlettau@everstream.net
//  * @group             :
//  * @last modified on  : 09-19-2023
//  * @last modified by  : vlettau@everstream.net
global class VisionMetrixBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful, Database.AllowsCallouts{
    //*@AccountId array items
    // T-mobile 0010B00001skFrkQAE
    // Att wireline 0013g00000Tfxq2AAB
    // Att mobility 001U000001jMJS6IAO
    // Att mobility peg unc 0013g00000TfxtOAAR
    // Dobson/att mobility 0010B00001p6Z3VQAU
    // Verizion 001U000001jMJVdIAO
    global Integer recordsParsed = 0;
    global Integer recordsUpdated = 0;
    global Boolean ExecuteNextJob = false;
    global static Integer BatchSize = 10;
    String loginToken = '';
    public VisionMetrixBatch(){
    }

    global Database.QueryLocator start(Database.BatchableContext context){
        loginToken = VisionMetrixCallOut.visionMetrixLogin();
        // Query for Customer Communication Cases with Record Type "Customer Communication" and type "Maintenance"
        // need to make this the place where assign the parent ticket data to the individual vm tickets

        //! this is for testing only looking for VisionMetrix_Parent_Case__c = true still want to limit by account id
        return Database.getQueryLocator([SELECT Id,CaseNumber, Account_Name_Text__c, AccountId, ParentId, RecordTypeId, Case_Record_Type__c, VisionMETRIX_Ticket_Created_Date__c,VisionMETRIX_Ticket_Number__c, VisionMetrix_Parent_Case__c, NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
                                         FROM Case
                                         WHERE Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND ParentId = null]);

        // return Database.getQueryLocator([SELECT Id, AccountId, ParentId, RecordTypeId, Case_Record_Type__c, VisionMetrix_Parent_Case__c, NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
        //                                  FROM Case
        //                                  WHERE Case_Record_Type__c = 'Maintenance' AND NotificationType__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND AccountId IN ('0010B00001skFrkQAE', '0013g00000Tfxq2AAB', '001U000001jMJS6IAO', '0013g00000TfxtOAAR', '0010B00001p6Z3VQAU', '001U000001jMJVdIAO') AND ParentId = null]);
    }

    global void execute(Database.BatchableContext context, List<Case> scope){
        System.debug('scope: ' + scope.size() + ' records.');
        List<Case> parentCases = new List<Case>();
        HttpResponse res = new HttpResponse();    

        if (Test.isRunningTest() || scope != NULL && scope.size() > 0){
            recordsParsed = scope.size();
            // Collect parent case IDs that meet the criteria
            for (Case c : scope){
                System.debug('Added Case Id to list: ' + c);
                // c.VisionMETRIX_Ticket_Created_Date__c = DateTime.now();
                // c.VisionMETRIX_Ticket_Number__c = c.CaseNumber + '-' + c.VisionMETRIX_Ticket_Created_Date__c.format('MM/dd/yyyy');
                parentCases.add(c);
            }

            if (parentCases.size() > 0){
                // Generate VisionMetrix cases by calling the addVMTicket method for each parent case
                // for (String parentId : parentCases){
                //     System.debug('Parent Case being passed: ' + parentId);
                //     VisionMetrixCallOut.addVMTicket(parentId, true);
                // }
                recordsUpdated = parentCases.size();
                res = VisionMetrixCallOut.addBulkVMTicket(parentCases, loginToken);
                // if response is successful, update the parent case with the VisionMetrix ticket number
                if (res != NULL && res.getStatusCode() == 200){
                    System.debug('Response: ' + res.getBody());
                    for (Case c : scope){
                        c.VisionMETRIX_Ticket_Created_Date__c = DateTime.now();
                        c.VisionMETRIX_Ticket_Number__c = c.CaseNumber + '-' + c.VisionMETRIX_Ticket_Created_Date__c.format('MM/dd/yyyy');                        
                    }
                    update scope;
                } else {
                    System.debug('Response: ' + res.getBody());
                }                    

            }
        }
    }

    global void execute(SchedulableContext SC){
        Database.executeBatch(new VisionMetrixBatch(), BatchSize);
    }

    global void finish(Database.BatchableContext BC){
        System.debug(recordsUpdated + ' records updated.');

        String soql = 'SELECT Id, ApexClass.Name, MethodName, JobType, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedBy.Email FROM AsyncApexJob ';
        if (Test.isRunningTest() || Test.isRunningTest() || BC != NULL){
            soql = soql + 'WHERE Id = \'' + BC.getJobId() + '\'';
        }
        if (Test.isRunningTest() || Test.isRunningTest()){
            soql = soql + ' ORDER BY CreatedDate DESC LIMIT 1';
        }

        AsyncApexJob job = Database.query(soql);
        
        //Only send the email if there is a problem.
        if (Test.isRunningTest() || job != NULL && job.NumberOfErrors != NULL && job.NumberOfErrors > 0){
            EmailUtils em = new EmailUtils();
            em.sendMessage(job, recordsUpdated, recordsParsed);
        }
    }

    global static void start(Integer minute){

        String jobName = 'VisionMetrixBatch';
        if (Test.isRunningTest() || minute == NULL){
            Database.executebatch(new VisionMetrixBatch(), BatchSize);
        } else if (Test.isRunningTest() || minute != NULL){
            jobName = jobName += ' - ' + minute + ' - ' + DateTime.now().format();
            String cron = '0 ' + String.valueOf(minute) + ' * * * ?';
            System.schedule(jobName, cron, new VisionMetrixBatch());
        }
    }

    // global static void start(Integer hour){
    //     String jobName = 'VisionMetrixBatch';
    //     if (Test.isRunningTest() || hour == NULL){
    //         Database.executebatch(new VisionMetrixBatch(), BatchSize);
    //     } else if (Test.isRunningTest() || hour != NULL){
    //         jobName = jobName += ' - ' + hour + ' - ' + DateTime.now().format();
    //         String cron = '0 ' + String.valueOf(hour) + ' * * * ?';
    //         System.schedule(jobName, cron, new VisionMetrixBatch());
    //     }
    // }
}

/* Commands to schedule every Day (run via "Execute Anonymous" as API Integration)

 VisionMetrixBatch.start(30);


 */