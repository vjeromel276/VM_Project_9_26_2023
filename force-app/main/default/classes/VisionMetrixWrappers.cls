/**
 * @description       :
 * @author            : vlettau@everstream.net
 * @group             :
 * @last modified on  : 05-10-2023
 * @last modified by  : vlettau@everstream.net
 **/
public with sharing class VisionMetrixWrappers{
    //initial login request wrapper
    public class InitLogin{
        public String username = 'everstreampcol1';//required
        public String password = 'MNBlkjpoi098###';//required
        public String company = 'everstream';//required
    }

    //add user request wrapper
    public class AddUser{
        public AddUser AddUserAttribute(String label, String value){
            if (label == 'username'){
                this.username = value;
            } else if (label == 'email'){
                this.email = value;
            } else if (label == 'level'){
                this.level = value;
            } else if (label == 'active'){
                this.active = value;
            } else if (label == 'timezone'){
                this.timezone = value;
            } else if (label == 'first_name'){
                this.first_name = value;
            } else if (label == 'last_name'){
                this.last_name = value;
            } else if (label == 'sso_user'){
                this.sso_user = value;
            } else if (label == 'password'){
                this.password = value;
            } else if (label == 'company'){
                this.company = value;
            } else if (label == 'phone'){
                this.phone = value;
            } else if (label == 'mobile'){
                this.mobile = value;
            } else if (label == 'address'){
                this.address = value;
            } else if (label == 'city'){
                this.city = value;
            } else if (label == 'state'){
                this.state = value;
            } else if (label == 'zip'){
                this.zip = value;
            } else if (label == 'country'){
                this.country = value;
            } else if (label == 'role'){
                this.role = value;
            } else if (label == 'match'){
                this.match = value;
            }
            return this;
        }

        public String username;//required
        public String email;//required
        public String level;//required
        public String active;//required
        public String timezone;//required
        public String first_name;//required
        public String last_name;//required
        public String sso_user;//required if used, 1 for yes, 0 for no
        public String password;//required
        public String company;//required
        public String phone;
        public String mobile;
        public String address;
        public String city;
        public String state;
        public String zip;
        public String country;
        public String role;//required
        public String match;
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

    //add circuit to a ticket request wrapper
    public class AddCircuitToTicket{
        public String ticket_id;//required
        public String circuit_alias;//required
        public String match;
    }

    //get ticket request wrapper
    public class GetTicket{
        public String ticket_id;//required
    }

    //edit ticket request wrapper
    public class EditTicket{
        public String circuits;//required
        public String open_status;//required
        public String severity;//required
        public String ticket_id;//required
        public String ticket_type;//required
        public Integer start_time;//required
        public String subject;
        public String category;
        public String internal_notes;
        public Integer end_time;
        public String exclusion_type;
        public String exclude_from_reporting;
        public String exclusde_from_mttr_reporting;
        public String description;
        public String support_agent;
        public String match;
    }

    //view cicruit locations request wrapper
    public class ViewCircuitLocations{
        public String circuit_alias;//required
        public String system_a_circuit_specific_location;//1 for TRUE, 0 for FALSE
        public String system_z_circuit_specific_location;//1 for TRUE, 0 for FALSE
        public String URL_String = 'getLocations/';
        public String method = 'GET';
    }

    public class Events{
        public String id;
        public Datetime start_time;
        public Datetime end_time;
        public String event_name;
        public String node_name;
        public String circuit_name;
        public String secondary_circuit_name;
        public String category;
        public String direction;
        public String kpi;
        public String severity;

        //optional
        // public String acknowledged_status;
        // public String acknowledged_by;
        // public Integer acknowledged_time;
        // public String acknowledged_note;
    }

}