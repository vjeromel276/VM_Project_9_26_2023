trigger VisionMetrixEventTrigger on VisionMetrix_Event__c (before insert, before update, after insert, after update) {

    List<VisionMetrix_Event__c> events = new List<VisionMetrix_Event__c>();
    events.addAll(Trigger.new);

    // if(Trigger.isBefore){
    //     if(Trigger.isInsert){
    //         
    //     }
    //     if(Trigger.isUpdate){
    //         
    //     }
    // }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            VisionMetrixEventTriggerHandler.onAfterInsert(events);
        }
        // if(Trigger.isUpdate){
        //    
        // }
    }

}