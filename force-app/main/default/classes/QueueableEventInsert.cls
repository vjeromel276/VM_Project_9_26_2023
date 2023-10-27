public class QueueableEventInsert implements Queueable, Database.AllowsCallouts {
    List<VisionMetrix_Event__c> eventsToInsert;
    public QueueableEventInsert(List<VisionMetrix_Event__c> events) {
        this.eventsToInsert = events;
    }
    public void execute(QueueableContext context) {
        // Determine the chunk size
        Integer chunkSize = 200; // Choose an appropriate size

        // Create a list to hold each chunk
        List<VisionMetrix_Event__c> chunk = new List<VisionMetrix_Event__c>();

        for (VisionMetrix_Event__c record : eventsToInsert) {
            chunk.add(record);

            // If the chunk is full, insert it and clear it
            if (chunk.size() == chunkSize) {
                insert chunk;
                chunk.clear();
            }
        }

        // Insert any remaining records
        if (!chunk.isEmpty()) {
            insert chunk;
        }
    } 
}