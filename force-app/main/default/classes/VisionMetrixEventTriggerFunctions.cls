public with sharing class VisionMetrixEventTriggerFunctions {

    public static void attachRelatedObjects(List<VisionMetrix_Event__c> newEvents) {
        List<VisionMetrix_Event__c> updatedEvents = new List<VisionMetrix_Event__c>();
        for(VisionMetrix_Event__c event : newEvents) {
            VisionMetrix_Circuit__c circuit = [
                SELECT Id
                FROM VisionMetrix_Circuit__c
                WHERE Circuit_Alias__c = :event.Circuit__c
                Limit 1
            ];
            if(circuit != null) {
                event.VisionMetrix_Circuit__c = circuit.Id;
            }
            updatedEvents.add(event);
        }
        System.enqueueJob(new QueueableEventInsert(updatedEvents));
    }

}