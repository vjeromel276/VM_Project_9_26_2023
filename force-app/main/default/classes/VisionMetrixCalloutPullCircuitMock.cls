/**
 * @name              : VisionMetrixCalloutPullCircuitMock.cls
 * @description       : this class is used to make a mock callout to VisionMetrixCallout.pullAllCircuits() method
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 12-01-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 12-01-2023
 **/
public with sharing class VisionMetrixCalloutPullCircuitMock implements HttpCalloutMock{
    public static HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"success": true,"circuits": [{"circuit_alias": "ATTM.MI.P2P.10107838.1036","secondary_name": "EVM-ETHS-ON-14263","start_time": "1560398400","circuit_image": "point_to_point","description": "VLAN: 1036 Tower: FAC10107838","status": "1","bandwidth": "300","max_ordering_bandwidth": "0","eir": "0","granularity": "1","mrc": "500.0000","event_notifications_enabled": "1",        "custom_notifications_enabled": "1","derive_1_way_data_enabled": "0","system_a_name": "ATT-GDRP-MTSO-NID-1","system_a_alias": "","system_a_ip_address": "10.150.1.91","system_a_manufacturer":"Accedian",     "system_a_model": "MetroNODE LT-S","system_z_name": "ATTMOB.FAC10107838.14263.MI","system_z_alias": "","system_z_ip_address": "10.150.1.53","system_z_manufacturer": "Accedian","system_z_model": "MetroNID GT-S","ethernet_profile_description":{"paa_name": "EVM-ETHS-ON-14263a"}},{"circuit_alias": "ATTM.MI.P2P.10107838.2036","secondary_name": "EVM-ETHS-ON-14264","start_time": "1560398400","circuit_image": "point_to_point","description": "VLAN: 2036 Tower: FAC10107838","status": "1","bandwidth": "300","max_ordering_bandwidth": "0","eir": "0","granularity": "1","mrc": "500.0000","event_notifications_enabled": "1","custom_notifications_enabled": "1","derive_1_way_data_enabled": "0","system_a_name": "ATT-GDRP-MTSO-NID-2","system_a_alias": "","system_a_ip_address": "10.150.1.92","system_a_manufacturer": "Accedian","system_a_model": "MetroNODE LT-S","system_z_name": "ATTMOB.FAC10107838.14263.MI","system_z_alias": "","system_z_ip_address": "10.150.1.53","system_z_manufacturer": "Accedian","system_z_model": "MetroNID GT-S","ethernet_profile_description": {"paa_name": "EVM-ETHS-ON-14263b"}}]}');


        return res;
    }
}