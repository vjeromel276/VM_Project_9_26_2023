public class QueueableAlertInsert implements Queueable, Database.AllowsCallouts  {
    List<NMS_Alert__c> alertsToInsert;
    public QueueableAlertInsert(List<NMS_Alert__c> alerts) {
        this.alertsToInsert = alerts;
    }

    public void execute(QueueableContext context) {
        // Determine the chunk size
        Integer chunkSize = 200; // Choose an appropriate size

        // Create a list to hold each chunk
        List<NMS_Alert__c> chunk = new List<NMS_Alert__c>();

        for (NMS_Alert__c record : alertsToInsert) {
            chunk.add(record);

            // If the chunk is full, insert it and clear it
            if (chunk.size() == chunkSize) {
                upsert chunk;
                chunk.clear();
            }
        }

        // Insert any remaining records
        if (!chunk.isEmpty()) {
            upsert chunk;
        }

         // If there are more records, enqueue another job
        // if (!alertsToInsert.isEmpty()) {
        //     System.enqueueJob(new QueueableAlertInsert(alertsToInsert));
        // }
    } 

    
}