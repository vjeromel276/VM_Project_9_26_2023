public with sharing class VisionMetrixCircuitChecker {
    /**
     * vmCircuits method is used to get all the VisionMetrix_Circuit__c records from Salesforce
     *
     * @return List<VisionMetrix_Circuit__c> - List of VisionMetrix_Circuit__c records
     */
    public static List<VisionMetrix_Circuit__c> getSfCircuits() {

        List<VisionMetrix_Circuit__c> vmCircuits = [SELECT Name, System_Z_Name__c, System_Z_Model__c, System_Z_Manufacturer__c, 
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

    public static String extractServiceId(String serviceId) {

        String sId = serviceId;
        // take service id and if
        if ( sId != null ) {
            System.debug('sId: ' + sId);
            if ( sId.endsWith(' a\\b')==false ) {

                if ( sId.length() > 0 ) {
                    sId = sId.trim().deleteWhitespace();

                    if ( sId.endsWithIgnoreCase('a') ) {
                        sId = sId.removeEndIgnoreCase('a');
                        sId = sId.trim() + ' a\\b';
                    }
                    if ( sId.endsWithIgnoreCase('b') ) {
                        sId = sId.removeEndIgnoreCase('b');
                        sId = sId.trim() + ' a\\b';
                    }
                    if ( sId.endsWithIgnoreCase('ab') ) {
                        sId = sId.removeEndIgnoreCase('ab');
                        sId = sId.trim() + ' a\\b';
                    }
                    else {
                        sId = sId.trim() + ' a\\b';
                    }

                }
            }
            System.debug('sId to return: ' + sId);

        }
        return sId;
    }

    public static void serviceIdMatch() {
        List<VisionMetrix_Circuit__c> vmc = [Select Service_Order_Agreement__c, Circuit_Alias__c, Secondary_Name__c
                                             From VisionMetrix_Circuit__c
                                             WHERE Service_Order_Agreement__c = null
                                             LIMIT 75];

        List<VisionMetrix_Circuit__c> vmc2update = new List<VisionMetrix_Circuit__c>();
        Order order = new Order();

        for ( VisionMetrix_Circuit__c v : vmc ) {

            String inputString = v.Secondary_Name__c; // Replace with your input string
            System.debug('inputString: ' + inputString);
            inputString = inputString.trim().deleteWhitespace();
            String serviceId = extractServiceId(inputString);
            serviceId = serviceId.trim();
            System.debug('serviceId: ' + serviceId);

            if ( serviceId != null || serviceId != '' ) {
                order = [SELECT Id, Service_ID__c
                         FROM Order
                         WHERE Service_ID__c =:serviceId
                         LIMIT 1];

                if ( order != null ) {
                    System.debug('order Id' + order.Id);
                    v.Service_Order_Agreement__c = order.Id;
                }
                else {
                    System.debug('order is null');
                    v.Service_Order_Agreement__c = null;
                }

                System.debug('v' + v);
                update v;

            }
        }
        // update vmc;
    }

}