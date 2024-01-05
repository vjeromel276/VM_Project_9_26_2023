/**
 * @description       :
 * @author            : vlettau@everstream.net
 * @group             :
 * @last modified on  : 01-05-2024
 * @last modified by  : vlettau@everstream.net
 **/
public with sharing class VisionMetrixWrappers{
    //initial login request wrapper
    public class InitLogin{
        public String username = 'everstreampcol1';//required
        public String password = 'MNBlkjpoi098###';//required
        public String company = 'everstream';//required
    }

    //add_ticket request wrapper
    public class AddTicket{
        public String circuits;//required
        public String open_status;//required
        public String severity;//required
        public String ticket_id;//required
        public String ticket_type;//required
        public Integer start_time;//required
        public String category;
        public String internal_notes;
        public Integer end_time;
        public String exclusion_type;
        public String exclude_from_reporting;
        public String exclusde_from_mttr_reporting;
        public String description;
        public String subject;
        public String support_agent;
        public String match;
    }

    //add bulk vm tickets request wrapper
    public class AddBulkVMTickets{
        public List<AddTicket> tickets;//required
        // public String match;
    }
    
    //edit vm tickets request wrapper
    public class Circuit{
        public String circuit_alias;//required
        public String secondary_name;
        public Integer start_time;
        public String circuit_image;
        public String description;
        public String status;
        public String bandwidth;
        public String max_ordering_bandwidth;
        public String eir;
        public String granularity;
        public String mrc;
        public String event_notifications_enabled;
        public String event_notifications_enabled_time;
        public String custom_notifications_enabled;
        public String system_a_name;
        public String system_a_alias;
        public String system_a_ip_address;
        public String system_a_manufacturer;
        public String system_a_model;
        public String system_z_name;
        public String system_z_alias;
        public String system_z_ip_address;
        public String system_z_manufacturer;
        public String system_z_model;
        public String ethernet_profile_description;
        public String util_profile_a_az_name;
        public String util_profile_a_za_name;
        public String util_profile_z_az_name;
    }

    //add circuit to a ticket request wrapper
    // public class AddCircuitToTicket{
    //     public String ticket_id;//required
    //     public String circuit_alias;//required
    //     public String match;
    // }

    //get ticket request wrapper
    // public class GetTicket{
    //     public String ticket_id;//required
    // }

    //edit ticket request wrapper
    // public class EditTicket{
    //     public String circuits;//required
    //     public String open_status;//required
    //     public String severity;//required
    //     public String ticket_id;//required
    //     public String ticket_type;//required
    //     public Integer start_time;//required
    //     public String subject;
    //     public String category;
    //     public String internal_notes;
    //     public Integer end_time;
    //     public String exclusion_type;
    //     public String exclude_from_reporting;
    //     public String exclusde_from_mttr_reporting;
    //     public String description;
    //     public String support_agent;
    //     public String match;
    // }

    //view cicruit locations request wrapper
    // public class ViewCircuitLocations{
    //     public String circuit_alias;//required
    //     public String system_a_circuit_specific_location;//1 for TRUE, 0 for FALSE
    //     public String system_z_circuit_specific_location;//1 for TRUE, 0 for FALSE
    //     public String URL_String = 'getLocations/';
    //     public String method = 'GET';
    // }

    // public class Events{
    //     public String id;
    //     public Datetime start_time;
    //     public Datetime end_time;
    //     public String event_name;
    //     public String node_name;
    //     public String circuit_name;
    //     public String secondary_circuit_name;
    //     public String category;
    //     public String direction;
    //     public String kpi;
    //     public String severity;

    //     //optional
    //     // public String acknowledged_status;
    //     // public String acknowledged_by;
    //     // public Integer acknowledged_time;
    //     // public String acknowledged_note;
    // }

    public class Event{
        public String id;
        public String start_time;
        public String end_time;
        public String event_name;
        public String node_name;
        public String circuit_name;
        public String secondary_circuit_name;
        public String direction;
        public String kpi;
        public String severity;
        public String category;
    }
    public class EventsList{
        public List<VisionMetrixWrappers.Event> events;
    }

    public class CircuitList{
        public List<VisionMetrixCircuitWrapper> circuits;
    }
}