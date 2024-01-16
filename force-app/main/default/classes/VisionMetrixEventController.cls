/**
 * @name              : VisionMetrixEventController
 * @description       : this controller is for the VisionMetrixEvent component
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 10-11-2023  
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 10-11-2023  
 **/
public with sharing class VisionMetrixEventController{
   
    

    /**
     * where the vm event circuit id is equal to the vm circuit id pass the vm circuit id's sf record id to vm event circuit look up fields
     */
    public static void attachVmEventToCircuit(){
        List<VisionMetrix_Event__c> newEvents = [
            SELECT Id, Name, VisionMetrix_Circuit__c, Circuit__c
            FROM VisionMetrix_Event__c
            WHERE VisionMetrix_Circuit__c = null
            AND Circuit__c != null
        
        ];
        Map<VisionMetrix_Event__c,String> eventCircuitMap = new Map<VisionMetrix_Event__c,String>();
        for (VisionMetrix_Event__c event : newEvents){
            eventCircuitMap.put(event,event.Circuit__c);
        }
        List<VisionMetrix_Circuit__c> circuits = [
            SELECT Id, Name, Circuit_Alias__c
            FROM VisionMetrix_Circuit__c
            WHERE Circuit_Alias__c IN :eventCircuitMap.values()
        ];
        Map<String,Id> circuitIdMap = new Map<String,Id>();
        for (VisionMetrix_Circuit__c circuit : circuits){
            circuitIdMap.put(circuit.Circuit_Alias__c,circuit.Id);
        }
        List<VisionMetrix_Event__c> eventsToUpdate = new List<VisionMetrix_Event__c>();
        for (VisionMetrix_Event__c event : eventCircuitMap.keySet()){
            event.VisionMetrix_Circuit__c = circuitIdMap.get(eventCircuitMap.get(event));
            System.debug('VisionMetrixEventController: event: ' + event);
            eventsToUpdate.add(event);
        }
        update eventsToUpdate;
    }
}