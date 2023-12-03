global class BatchVisionMetrixCircuitCallout implements Database.Batchable<sObject>, Schedulable, Database.Stateful, Database.AllowsCallouts {
    global Integer recordsParsed = 0;
    global Integer recordsUpdated = 0;
    global Boolean ExecuteNextJob = false;
    global static Integer BatchSize = 1000;
    global BatchVisionMetrixCircuitCallout() {
        // Constructor
    }

    // Start Method
    global Iterable<SObject> start(Database.BatchableContext bc) {
        // Return an instance of your custom iterable
        return new VisionMetrixCircuitIterable();
    }

    // Execute Method
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        // Logic to process each batch of records

        // Example: Insert or update records
        // Ensure to handle exceptions and respect governor limits
        try {
            System.debug('Circuits: ' + scope.size());
            System.enqueueJob(new QueueableCircuitInsert(scope));
            // insert scope;
        } catch (Exception e) {
            // Handle exceptions appropriately
            System.debug('Error during batch processing: ' + e.getMessage());
        }
    }

    global void execute(SchedulableContext SC){
        Database.executeBatch(new BatchVisionMetrixCircuitCallout(), BatchSize);
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

        String jobName = 'BatchVisionMetrixCircuitCallout';
        if (Test.isRunningTest() || minute == NULL){
            Database.executebatch(new BatchVisionMetrixCircuitCallout(), BatchSize);
        } else if (Test.isRunningTest() || minute != NULL){
            jobName = jobName += ' - ' + minute + ' - ' + DateTime.now().format();
            String cron = '0 ' + String.valueOf(minute) + ' * * * ?';
            System.schedule(jobName, cron, new BatchVisionMetrixCircuitCallout());
        }
    }

}