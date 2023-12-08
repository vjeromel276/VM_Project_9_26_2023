public with sharing class VisionMetrixCircuitChecker {

    public static Set<VisionMetrix_Circuit__c> getSfCircuits() {
        List<VisionMetrix_Circuit__c>  vmCircuits = [SELECT Name, System_Z_Name__c, System_Z_Model__c, System_Z_Manufacturer__c, 
                             System_Z_IPAddress__c, System_Z_Alias__c, System_A_Name__c, System_A_Model__c, 
                             System_A_Manufacturer__c, System_A_IPAddress__c, System_A_Alias__c, Start_Time__c, 
                             Service_Order_Agreement__c, Secondary_Name__c, One_Way_Data_Enabled__c, Max_Ordering_Bandwidth__c, 
                             Event_Notifications_Enabled__c, Ethernet_Profile_Desc__c, Custom_Notifications_Enabled__c, Circuit_Status__c, 
                             Circuit_MRC__c, Circuit_Image__c, Circuit_Alias__c, Circuit_Granularity__c, 
                             Circuit_EIR__c, Circuit_Description__c, Bandwidth__c
                      FROM VisionMetrix_Circuit__c];

        Set<VisionMetrix_Circuit__c> vmCircuitSet = new Set<VisionMetrix_Circuit__c>();
        vmCircuitSet.addAll(vmCircuits);
        return vmCircuitSet;
    }

    public static List<VisionMetrix_Circuit__c> getCircuitSet(List<VisionMetrix_Circuit__c> newVmCircuits) {
        Set<VisionMetrix_Circuit__c> vmCircuitSet = getSfCircuits();
        List<VisionMetrix_Circuit__c> result = new List<VisionMetrix_Circuit__c>();
        vmCircuitSet.addAll(newVmCircuits);
        
        result.addAll(vmCircuitSet);
        return result;
    }

}