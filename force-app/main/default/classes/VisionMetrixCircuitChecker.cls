public with sharing class VisionMetrixCircuitChecker {
    /**
     * vmCircuits method is used to get all the VisionMetrix_Circuit__c records from Salesforce
     * 
     * @return List<VisionMetrix_Circuit__c> - List of VisionMetrix_Circuit__c records
     */
    public static List<VisionMetrix_Circuit__c> getSfCircuits() {
        
        List<VisionMetrix_Circuit__c>  vmCircuits = [SELECT Name, System_Z_Name__c, System_Z_Model__c, System_Z_Manufacturer__c, 
                             System_Z_IPAddress__c, System_Z_Alias__c, System_A_Name__c, System_A_Model__c, 
                             System_A_Manufacturer__c, System_A_IPAddress__c, System_A_Alias__c, Start_Time__c, 
                             Service_Order_Agreement__c, Secondary_Name__c, One_Way_Data_Enabled__c, Max_Ordering_Bandwidth__c, 
                             Event_Notifications_Enabled__c, Ethernet_Profile_Desc__c, Custom_Notifications_Enabled__c, Circuit_Status__c, 
                             Circuit_MRC__c, Circuit_Image__c, Circuit_Alias__c, Circuit_Granularity__c, 
                             Circuit_EIR__c, Circuit_Description__c, Bandwidth__c
                      FROM VisionMetrix_Circuit__c];

        System.debug('getCircuitsSF set size: ' + vmCircuits.size());
        return vmCircuits;
    }
    /**
     * getCircuitSet method is used to get all the VisionMetrix_Circuit__c records from Salesforce and
     * check that the new VisionMetrix_Circuit__c records are not already in Salesforce
     * and if they are in sf make updtaes to the existing records
     */
    public static List<VisionMetrix_Circuit__c> getCircuitSet(List<VisionMetrix_Circuit__c> newVmCircuits) {
        Set<VisionMetrix_Circuit__c> vmCircuitSet = new Set<VisionMetrix_Circuit__c>();
        List<VisionMetrix_Circuit__c> result = getSfCircuits();
        result.addAll(newVmCircuits);
        vmCircuitSet.addAll(result);
        System.debug('getCircuitSet set size: ' + vmCircuitSet.size());
        return result;
    }


}