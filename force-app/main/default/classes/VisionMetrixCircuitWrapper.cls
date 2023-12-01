public class VisionMetrixCircuitWrapper {
    
    public String circuit_alias;
    public String secondary_name;
    public String start_time;
    public String circuit_image; 
    public String description;
    public String status;
    public String bandwidth;
    public String max_ordering_bandwidth;
    public String eir;
    public String granularity;
    public String mrc;
    public String event_notifications_enabled;
    public String custom_notifications_enabled;
    public String derive_1_way_data_enabled;
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
    public EthernetProfile ethernet_profile_description;

    public class EthernetProfile{
        public String paa_name;
    }
    
}