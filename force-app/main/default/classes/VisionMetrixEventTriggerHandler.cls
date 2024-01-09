public with sharing class VisionMetrixEventTriggerHandler {
    public VisionMetrixEventTriggerHandler() {

    }

    public static void onAfterInsert(List<VisionMetrix_Event__c> newEvents) {
        VisionMetrixHelperMethod.vmEventToAlert(newEvents);//*this will be used to create the nms alert
        VisionMetrixEventController.attachVmEventToCircuit();//*this will be used to attach the vm event to the circuit
    }

    // public void onAfterUpdate(List<VisionMetrixEvent__c> newEvents, Map<Id, VisionMetrixEvent__c> oldEvents) {
        
    // }

    // public void onBeforeInsert(List<VisionMetrixEvent__c> newEvents) {
        
    // }

    // public void onBeforeUpdate(List<VisionMetrixEvent__c> newEvents, Map<Id, VisionMetrixEvent__c> oldEvents) {
        
    // }
}