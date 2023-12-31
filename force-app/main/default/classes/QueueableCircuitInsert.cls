public class QueueableCircuitInsert implements Queueable, Database.AllowsCallouts {
    List<VisionMetrix_Circuit__c> circuitsToInsert;
    public QueueableCircuitInsert(List<VisionMetrix_Circuit__c> circuits) {
        this.circuitsToInsert = circuits;
    }
    public void execute(QueueableContext context) {
        // Determine the chunk size
        Integer chunkSize = 200; // Choose an appropriate size

        // Create a list to hold each chunk
        List<VisionMetrix_Circuit__c> chunk = new List<VisionMetrix_Circuit__c>();

        for (VisionMetrix_Circuit__c record : circuitsToInsert) {
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