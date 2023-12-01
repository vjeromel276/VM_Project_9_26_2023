/**
 * @name              : VisionMetrixCallOut.cls
 * @description       : this class is used to make callouts to the VisionMetrix API
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 7-11-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 11-08-2023
 **/
public class VisionMetrixCallOut {
    /**
     * genAuthPayload()
     *
     * Method to generate the payload for the login call outs
     *
     * @return                          String                  the payload for the callout
     *
     * @uses        InitLogin           VisionMetrixWrapper     to create the login wrapper
     */
    private static String genAuthPayload() {
        VisionMetrixWrappers.InitLogin login = new VisionMetrixWrappers.InitLogin();
        // System.debug(login);
        return JSON.serialize(login);
    }

    /**************************************************************************************************************************************** */

    /**
     * visionMetrixLogin()
     *
     * Method to login to VisionMetrix and get the token for the header
     *
     * @return                          String          the token for the header
     *
     * @uses        genAuthPayload()    Function        to generate the payload for the callout
     */
    public static String visionMetrixLogin() {

        Http http = new Http(  );
        HttpRequest request = new HttpRequest(  );

        String authPayload = genAuthPayload();
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/login/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(authPayload.length()));
        request.setHeader('Connection', 'keep-alive');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setBody(authPayload);
        // System.debug(authPayload);

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        if ( response.getStatusCode() == 200 ) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
            // System.debug(results);

            String token = results.get('token').toString();
            // System.debug(token);
            return token;
        }
        else {
            System.debug('***********************************************RESPONSE***********************************************');
            Object[] keys = response.getHeaderKeys();
            Map<String, String> headers = new Map<String, String>();
            for ( Object key : keys ) {

                System.debug(key + ' : ' + response.getHeader(key.toString()));
            }
            // System.debug(response.getBody());
            System.debug('******************************************END RESPONSE***********************************************');
            return null;
        }
    }

    /**************************************************************************************************************************************** */

    /**
     * handleResponse()
     *
     * Method to handle the response from the call outs
     *
     * @param       response            HttpResponse    the response from the call out
     * @return                          List<Object>    the list of values from the response
     */
    // public static List<Object> handleResponse(HttpResponse response) {
    //     // If the request is successful, parse the JSON response.
    //     if ( response.getStatusCode() == 200 ) {
    //         // Deserializes the JSON string into collections of primitive data types.
    //         Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
    //         for ( String key : results.keySet() ) {
    //             System.debug(key + ' : ' + results.get(key));
    //         }
    //         System.debug(results);
    //         return results.values();
    //     }
    //     else {
    //         System.debug('***********************************************RESPONSE***********************************************');
    //         Object[] keys = response.getHeaderKeys();
    //         Map<String, String> headers = new Map<String, String>();
    //         String outputLine='';
    //         List<String> outputList = new List<String>();
    //         for ( Object key : keys ) {
    //             outputLine = key + ' : ' + response.getHeader(key.toString()) + '\n';
    //             outputList.add(outputLine);
    //             System.debug(key + ' : ' + response.getHeader(key.toString()));
    //         }
    //         System.debug(response.getBody().remove('\\'));
    //         System.debug('******************************************END RESPONSE***********************************************');
    //         return outputList;
    //     }
    // }

    /**************************************************************************************************************************************** */

    /**
     * genExclusionPayload()
     *
     * Method to generate the payload for the exclusion call outs
     *
     * @param       ticketId            String          the VisionMetrix ticket number
     * @return                          String          the payload for the callout
     */
    // public static String genExclusionPayload(Case ticket) {
    //     VisionMetrixWrappers.AddTicket ticketData = new VisionMetrixWrappers.AddTicket();
    //     String circuitString = '';
    //     List<VisionMetrix_Circuit__c> circuitList = [SELECT Id, Service_Order_Agreement__c, Circuit_Alias__c
    //                                                  FROM VisionMetrix_Circuit__c
    //                                                  WHERE Service_Order_Agreement__c = :ticket.Related_Service_Order__c];
    //     Set<String> circuitSet = new Set<String>();
    //     for ( VisionMetrix_Circuit__c circuit : circuitList ) {
    //         // circuitString += circuit.Circuit_Alias__c + ', ';
    //         circuitSet.add(( circuit.Circuit_Alias__c ).trim().deleteWhitespace());
    //     }

    //     if ( ticket != null ) {

    //         //********Required Fields *********//
    //         //^~ Ticket Id - Salesforce Ticket Case Number and todays date in the format of mm/dd/yyyy
    //         ticketData.ticket_id = ticket.CaseNumber + '-' + String.valueOf(Date.today().day()) + '/' + String.valueOf(Date.today().month()) + '/' + String.valueOf(Date.today().year());
    //         // System.debug('Ticket Number: ' + ticketData.ticket_id);

    //         //^~ Ticket Type - Ticket Type defaults to 'Exclusion Period'
    //         ticketData.ticket_type = 'Exclusion Period';
    //         // System.debug('Ticket Type: ' + ticketData.ticket_type);

    //         //^~ Circuit List - List of Circuits to be excluded
    //         // System.debug('Circuits: ' + circuitSet);
    //         // System.debug('Circuits: ' + circuitSet.size());
    //         Integer circuitSetSize = circuitSet.size();
    //         for ( String circuit : circuitSet ) {
    //             if ( circuitSetSize > 1 ) {
    //                 circuitString += circuit + '& ';
    //                 circuitSetSize--;
    //             }
    //             else {
    //                 circuitString += circuit;
    //             }
    //         }
    //         if ( circuitString.length() > 0 ) {
    //             ticketData.circuits = ( circuitString ).trim().deleteWhitespace();
    //         }
    //         // System.debug('Circuits: ' + ticketData.circuits);

    //         //^~ Open Status - Exclusion Period Open Status defaults to 'Closed'
    //         ticketData.open_status = 'Closed';
    //         // System.debug('Open Status: ' + ticketData.open_status);

    //         //^~ Severity - Exclusion Period Severity defaults to 'Low'
    //         ticketData.severity = 'Low';
    //         // System.debug('Severity: ' + ticketData.severity);

    //         //^~ Start Time - Maintenance Start Time
    //         ticketData.start_time = Integer.valueOf(ticket.Maintenance_Start__c.getTime() / 1000);
    //         // System.debug('Maintenance Start: ' + ticketData.start_time);

    //         //^~ End Time - Maintenance End Time
    //         ticketData.end_time = Integer.valueOf(ticket.Maintenance_End__c.getTime() / 1000);
    //         // System.debug('Maintenance End: ' + ticketData.end_time);

    //         //********Optional Fields*********//
    //         //^~ Category - Default to Maintenance until the 1 to 1 mapping is complete
    //         ticketData.category = 'Maintenance';
    //         // System.debug('Category: ' + ticketData.category);
    //         //^~ Internal Notes - SF Generated Ticket
    //         // System.debug('Internal Notes: "SF GENERATED VM TICKET');
    //         //^~ Exclusion Type - Exclusion Period Exclusion Type defaults to 'Smart'
    //         ticketData.exclusion_type = 'Smart';
    //         // System.debug('Exclusion Type: ' + ticketData.exclusion_type);
    //         //^~ Exclude From Reporting - Exclusion Period Exclude From Reporting defaults to 'No' should be 'Yes' for exclusions
    //         ticketData.exclude_from_reporting = 'Yes';
    //         // System.debug('Exclude From Reporting: ' + ticketData.exclude_from_reporting);
    //         //^~ Exclude From Monitoring Reporting - Exclusion Period Excluded From Monitoring defaults to 'No' should be 'Yes' for exclusions
    //         ticketData.exclusde_from_mttr_reporting = 'Yes';
    //         // System.debug('Exclude From Monitoring Reporting: ' + ticketData.exclusde_from_mttr_reporting);
    //         //^~ Description
    //         ticketData.description = ticket.Description;
    //         // System.debug('Description: ' + ticketData.description);
    //         //^~ Subject
    //         ticketData.subject = ticket.Subject;
    //         // System.debug('Subject: ' + ticketData.subject);
    //         //^~ Support Agent
    //         ticketData.support_agent = ticket.NOC_Ticket_Assigment__c;
    //         // System.debug('Support Agent: ' + ticketData.support_agent);
    //         //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
    //         // ticketList.add(ticketData);
    //     }
    //     else {
    //         //^ If the child is null throw an error
    //         System.debug('Child was null: ');
    //         // throw new System.QueryException('No Nodes found with the ticket number or ticket is not of correct type: ' + ticketId);
    //     }
    //     return JSON.serialize(ticketData);
    // }

    /**************************************************************************************************************************************** */

    /**
     * genParentPayload()
     *
     * Method to generate the payload for the Parent ticket call outs
     *
     * @param       tickets             List<Case>              the list of SF Support Ticket numbers
     * @return                          String                  the payload for the callout
     *
     * @see        AddBulkVMTickets    VisionMetrixWrapper     to create the bulk ticket wrapper
     */
    // public static String genParentPayload(List<Case> parentTickets) {

        // bulk Parent ticket wrapper
        // VisionMetrixWrappers.AddBulkVMTickets bulkticketData = new VisionMetrixWrappers.AddBulkVMTickets();
        // // ticket list wrapper to hold the list of Parent tickets
        // List<VisionMetrixWrappers.AddTicket> ticketList = new List<VisionMetrixWrappers.AddTicket>();
        // for each parent ticekt id in the list of ticket ids
        // for ( Case ticket : parentTickets ) {
        //     // individual Parent ticket wrapper
        //     VisionMetrixWrappers.AddTicket ticketData = new VisionMetrixWrappers.AddTicket();

        //     List<Case> parentCases = [SELECT Id, ParentId, Related_Service_Order__r.Id, Service_ID__c, Account_Name_Text__c,
        //                                     CaseNumber, Related_Service_Order__c, Related_Service_Order_Text__c, Description, Subject, 
        //                                     NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
        //                              FROM Case
        //                              WHERE ParentId = :ticket.Id];

            // System.debug('child case array: ' + parentCases + ' for ticket: ' + ticket.Id);
            // Set<String> circuitSet = new Set<String>();
            
            // make sure the parent has a child
            // for ( Case parent : parentCases ) {
            //     System.debug('parent casenumber: ' + parent.CaseNumber+ ' parent id ' + parent.Related_Service_Order_Text__c);                

            //     List<VisionMetrix_Circuit__c> circuitList = [SELECT Id, Service_Order_Agreement__c, Circuit_Alias__c
            //                                                  FROM VisionMetrix_Circuit__c
            //                                                  WHERE Service_Order_Agreement__c = :parent.Related_Service_Order__c];

            //     System.debug('circuit list: ' + circuitList);
            //     String circuitString = '';
            //     for ( VisionMetrix_Circuit__c circuit : circuitList ) {
            //         // circuitString += circuit.Circuit_Alias__c + ', ';
            //         circuitSet.add(( circuit.Circuit_Alias__c ).trim().deleteWhitespace()+'&');
            //     }

            //     if ( parent != null ) {

            //         //********Required Fields *********//
            //         //^~ Ticket Id - Salesforce Ticket Case Number and todays date in the format of mm/dd/yyyy
            //         ticketData.ticket_id = ticket.CaseNumber + ' | ' + parent.Account_Name_Text__c + ' Maintenance | Start Date - '+ parent.Maintenance_Start__c.format('MM/dd/yyyy');
            //         // System.debug('Ticket Number: ' + ticketData.ticket_id);

            //         //^~ Ticket Type - Ticket Type defaults to 'Exclusion Period'
            //         ticketData.ticket_type = 'Exclusion Period';
            //         // System.debug('Ticket Type: ' + ticketData.ticket_type);

            //         //^~ Circuit List - List of Circuits to be excluded
            //         // System.debug('Circuits: ' + circuitSet);
            //         // System.debug('Circuits: ' + circuitSet.size());
            //         Integer circuitSetSize = circuitSet.size();
            //         for ( String circuit : circuitSet ) {
            //             if ( circuitSetSize > 1 ) {
            //                 // circuitString += circuit + '& ';
            //                 circuitString += circuit;
            //                 circuitSetSize--;
            //             }
            //             else {
            //                 circuitString += circuit;
            //             }
            //         }
            //         if ( circuitString.length() > 0 ) {
            //             if(circuitString.endsWith('&')) {
            //                 circuitString = circuitString.removeEnd('&');
            //             }
            //             ticketData.circuits = ( circuitString ).trim().deleteWhitespace();
            //         }
            //         // System.debug('Circuits: ' + ticketData.circuits);

            //         //^~ Open Status - Exclusion Period Open Status defaults to 'Closed'
            //         ticketData.open_status = 'Closed';
            //         // System.debug('Open Status: ' + ticketData.open_status);

            //         //^~ Severity - Exclusion Period Severity defaults to 'Low'
            //         ticketData.severity = 'Low';
            //         // System.debug('Severity: ' + ticketData.severity);

            //         //^~ Start Time - Maintenance Start Time
            //         ticketData.start_time = Integer.valueOf(parent.Maintenance_Start__c.getTime() / 1000);
            //         // System.debug('Maintenance Start: ' + ticketData.start_time);

            //         //^~ End Time - Maintenance End Time
            //         ticketData.end_time = Integer.valueOf(parent.Maintenance_End__c.getTime() / 1000);
            //         // System.debug('Maintenance End: ' + ticketData.end_time);

            //         //********Optional Fields*********//
            //         //^~ Category - Default to Maintenance until the 1 to 1 mapping is complete
            //         ticketData.category = 'Maintenance';
            //         // System.debug('Category: ' + ticketData.category);
            //         //^~ Internal Notes - SF Generated Ticket
            //         // System.debug('Internal Notes: "SF GENERATED VM TICKET');
            //         //^~ Exclusion Type - Exclusion Period Exclusion Type defaults to 'Smart'
            //         ticketData.exclusion_type = 'Smart';
            //         // System.debug('Exclusion Type: ' + ticketData.exclusion_type);
            //         //^~ Exclude From Reporting - Exclusion Period Exclude From Reporting defaults to 'No' should be 'Yes' for exclusions
            //         ticketData.exclude_from_reporting = 'Yes';
            //         // System.debug('Exclude From Reporting: ' + ticketData.exclude_from_reporting);
            //         //^~ Exclude From Monitoring Reporting - Exclusion Period Excluded From Monitoring defaults to 'No' should be 'Yes' for exclusions
            //         ticketData.exclusde_from_mttr_reporting = 'Yes';
            //         // System.debug('Exclude From Monitoring Reporting: ' + ticketData.exclusde_from_mttr_reporting);
            //         //^~ Internal Notes
            //         ticketData.internal_notes = 'SF GENERATED VM TICKET';
            //         // System.debug('Description: ' + ticketData.description);
            //         //^~ Description
            //         ticketData.description = parent.Description;
            //         // System.debug('Description: ' + ticketData.description);
            //         //^~ Subject
            //         ticketData.subject = parent.Subject;
            //         // System.debug('Subject: ' + ticketData.subject);
            //         //^~ Support Agent
            //         ticketData.support_agent = parent.NOC_Ticket_Assigment__c;
            //         // System.debug('Support Agent: ' + ticketData.support_agent);
            //         //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
            //         // ticketList.add(ticketData);
            //     }
            //     else {
            //         //^ If the child is null throw an error
            //         System.debug('Child was null: ');
            //         // throw new System.QueryException('No Nodes found with the ticket number or ticket is not of correct type: ' + ticketId);
            //     }
            // }
        //     // update Support Ticket with the VisionMetrix Ticket Number
        //     // ticket.VisionMetrix_Ticket_Number__c = ticketData.ticket_id;
        //     // update Service Affecting Cust List with a list of service Ids
        //     // ticket.Service_Affecting_Cust_List__c = ticketData.circuits;
        //     // update ticket;
        //     // add the ticket to the list of tickets
        //     ticketList.add(ticketData);
        //     System.debug('Ticket List: ' + ticketList);
        //     // add the list of tickets to the bulk ticket wrapper
        //     bulkticketData.tickets = ticketList;
        // }

        //******* Return the payload *******
    //     // for ( VisionMetrixWrappers.AddTicket t : bulkticketData.tickets ) {
    //     //     System.debug('Ticket Id: ' + t.ticket_id);
    //     //     System.debug('Ticket Type: ' + t.ticket_type);
    //     //     System.debug('Circuits: ' + t.circuits);
    //     //     System.debug('Open Status: ' + t.open_status);
    //     //     System.debug('Severity: ' + t.severity);
    //     //     System.debug('Maintenance Start: ' + t.start_time);
    //     //     System.debug('Maintenance End: ' + t.end_time);
    //     //     System.debug('Exclusion Type: ' + t.exclusion_type);
    //     //     System.debug('Exclude From Reporting: ' + t.exclude_from_reporting);
    //     //     System.debug('Exclude From Monitoring Reporting: ' + t.exclusde_from_mttr_reporting);
    //     //     System.debug('Description: ' + t.description);
    //     //     System.debug('Subject: ' + t.subject);
    //     //     System.debug('Support Agent: ' + t.support_agent);
    //     // }
    //      return JSON.serialize(bulkticketData);
    // }

    /**************************************************************************************************************************************** */
    
    /**
     * addBulkVMTicket()
     *
     * Method to add a new VisionMetrix ticket
     *@SOQL SELECT Id, AccountId, ParentId, RecordTypeId, Case_Record_Type__c, VisionMetrix_Parent_Case__c, NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c FROM Case WHERE Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND ParentId = null
     * @param       tickets             List<Case>      the list of VisionMetrix ticket numbers
     * @param       token               String          the token for the header
     *
     * @uses        visionMetrixLogin()                 to get the token for the header
     * @uses        genParentPayload()                  to generate the payload for the callout
     */
    // public static HttpResponse addBulkVMTicket(List<Case> tickets, String token) {

    //     System.debug('+++++++++++++++++++Start of addBulkVMTicket Method+++++++++++++++++++++++++++++++++++++++++++++++++++');
    //     Boolean isExclusion = true;
    //     String headerToken = visionMetrixLogin();
    //     // String headerToken = token;
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     String ticketPayload;

    //     ticketPayload = genParentPayload(tickets);

    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/addBulk/');
    //     request.setMethod('POST');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
    //     System.debug('Ticket Payload: ' + ticketPayload);
    //     for(String s: ticketPayload.split(',')){
    //         System.debug(s);
    //     }
    //     request.setBody(ticketPayload);
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, return an object
    //     handleResponse(response);
    //     // if response is successful


    //     VisionMetrixCallOutHelper.logAPICallout( String.valueOf(request.getEndpoint()), String.valueOf(request.getBody()), String.valueOf(JSON.deserializeUntyped(response.getBody())));
    //     System.debug('+++++++++++++++++++End of addBulkVMTicket Method+++++++++++++++++++++++++++++++++++++++++++++++++++');
    //     return response;
    // }

    /**************************************************************************************************************************************** */
    /**
     * genNonExclusionPayload()
     *
     * Method to generate the payload for the nonExclusion call outs
     *
     * @param       ticketId            String      the VisionMetrix ticket number
     *
     * @uses        visionMetrixLogin()             to get the token for the header
     * @uses        genExclusionPayload()           to generate the payload for the callout
     *
     * @return      String                          the payload for the callout
     */
    // public static String genNonExclusionPayload(String ticketId) {
    //     return null;
    // }

    /**************************************************************************************************************************************** */
    /**
     * genAddCircuitPayload()
     *
     * Method to generate the payload for the addCircuitToTicket call outs
     *
     * @param       vmTicketNumber      String      the VisionMetrix ticket number
     * @param       selectedNodes       String      the circuit alias to be added to the ticket
     * @return      String                          the payload for the callout
     * @uses        visionMetrixLogin()             to get the token for the header
     */
    // public static String genAddCircuitPayload(String vmTicketNumber, String selectedNodes) {
    //     VisionMetrixWrappers.AddCircuitToTicket ticketData = new VisionMetrixWrappers.AddCircuitToTicket();
    //     ticketData.ticket_id = vmTicketNumber;
    //     ticketData.circuit_alias = selectedNodes;
    //     System.debug('Ticket Number: ' + ticketData.ticket_id);
    //     System.debug('Circuit Alias: ' + ticketData.circuit_alias);
    //     System.debug('Ids added to Exclusion Peiod Ticket: ' + ticketData.ticket_id);
    //     return JSON.serialize(ticketData);
    // }

    /**************************************************************************************************************************************** */
    /**
     * Method to add a new VisionMetrix ticket
     * @param ticketId - the VisionMetrix ticket number
     * @param isExclusion - boolean to determine if the ticket is an exclusion or not
     * @uses visionMetrixLogin() to get the token for the header
     * @uses genExclusionPayload() to generate the payload for the callout
     */
    // public static void addVMTicket(Case ticket, Boolean isExclusion) {
    //     String headerToken = visionMetrixLogin();
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     String ticketPayload;
    //     if ( isExclusion ) {

    //         ticketPayload = genExclusionPayload(ticket);
    //     }
    //     else {
    //         ticketPayload = genNonExclusionPayload('ticketId');
    //     }
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/add/');
    //     request.setMethod('POST');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
    //     System.debug(ticketPayload);
    //     request.setBody(ticketPayload);
                
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, parse the JSON response.
    //     handleResponse(response);
    //     VisionMetrixCallOutHelper.logAPICallout( String.valueOf(request.getEndpoint()), String.valueOf(request.getBody()), String.valueOf(JSON.deserializeUntyped(response.getBody())));
    // }

    /**************************************************************************************************************************************** */
    /**
     * Method to get an existing VisionMetrix ticket
     * @param ticketId - the VisionMetrix ticket number
     * @uses visionMetrixLogin() to get the token for the header
     */
    // public static void getVMTicket(String ticketId) {
    //     String headerToken = visionMetrixLogin();
    //     String urlEnd = 'tickets/get?ticket_id=' + ticketId;
    //     String endpoint = 'https://rest-api2.visionmetrix.net/1.1/' + urlEnd;
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     System.debug(endpoint);
    //     request.setEndpoint(endpoint.trim());
    //     request.setMethod('GET');
    //     request.setHeader('Accept', 'text/json');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Lngth', '118');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, parse the JSON response.
    //     System.debug(response.getStatus());
    //     handleResponse(response);
    // }

    /**************************************************************************************************************************************** */
    /**
     * Method to edit an existing VisionMetrix ticket
     * @param ticketId - the VisionMetrix ticket number
     * @param selectedNodes - the circuit alias to be added to the ticket
     * @uses visionMetrixLogin() to get the token for the header
     * @uses genExclusionPayload() to generate the payload for the callout
     */
    // public static void editVMTicket(Case ticket, List<Id> selectedNodes) {
    //     String headerToken = visionMetrixLogin();
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     String ticketPayload = genExclusionPayload(ticket);
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/edit/');
    //     request.setMethod('POST');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
    //     request.setBody(ticketPayload);
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, parse the JSON response.
    //     handleResponse(response);
    // }

    /**************************************************************************************************************************************** */
    /**
     * Method to add a circuit to an existing VisionMetrix ticket
     * @param vmTicketNumber - the VisionMetrix ticket number
     * @param selectedNodes - the circuit alias to be added to the ticket
     * @uses genAddCircuitPayload() to generate the payload for the callout
     */
    // @AuraEnabled
    // public static void addCircuitToVMTicket(String vmTicketNumber, String selectedNodes) {
    //     String headerToken = visionMetrixLogin();
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     String ticketPayload = genAddCircuitPayload(vmTicketNumber, selectedNodes);
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/addCircuitToTicket/');
    //     request.setMethod('POST');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
    //     request.setBody(ticketPayload);
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, parse the JSON response.
    //     handleResponse(response);
    // }

    /**************************************************************************************************************************************** */
    /**
     * Method to remove a circuit from an existing VisionMetrix ticket
     * @param vmTicketNumber - the VisionMetrix ticket number
     * @param selectedNodes - the circuit alias to be removed from the ticket
     * @uses genAddCircuitPayload() to generate the payload for the callout
     */
    // @AuraEnabled
    // public static void removeCircuitFromTicket(String vmTicketNumber, String selectedNodes) {
    //     String headerToken = visionMetrixLogin();
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     String ticketPayload = genAddCircuitPayload(vmTicketNumber, selectedNodes);
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/removeCircuitFromTicket/');
    //     request.setMethod('POST');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
    //     request.setBody(ticketPayload);
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, parse the JSON response.
    //     handleResponse(response);
    // }

    /**************************************************************************************************************************************** */
    // invocableMethod for getting the latest events from VisionMetrix called from a flow
    // @invocableMethod(label = 'Get Latest Events')
    // public static void getLatestEventsInvocable() {
    //     getLatestEvents();
    // }

    /**************************************************************************************************************************************** */
    /**
     * getLatestEvents()
     *
     * Method calls the VisionMetrix API to get the latest events and will create a new ticket in Salesforce or attach the event to an existing ticket
     *
     * @insert      newEvent                VisionMetrix_Event__c       the event to be handled
     *
     * @uses        visionMetrixLogin()     Function                    to get the token for the header
     *
     */
    // @future(callout = true)
    // public static void getLatestEvents() {
    //     String headerToken = visionMetrixLogin();
    //     HttpRequest request = new HttpRequest(  );
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/event/latest/');
    //     request.setMethod('GET');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     HttpResponse response = new Http(  ).send(request);

    //     Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
    //     String success = results.get('success').toString();
    //     String events = results.get('events').toString();
    //     if ( success == 'false' ) {
    //         throw new System.QueryException( 'Callout failed with error: ' + results.get('error').toString() );
    //     }
    //     else if ( success == 'true' && events != null ) {
    //         System.debug('Success Response Events: ');
    //         VisionMetrixHelperMethod.handleLatestEvents(response);
    //     }
    //     else {
    //         throw new System.QueryException( 'Callout succeded no Events retunred' );
    //     }
    // }

    /**
     * Method to retrieve a filtered list of events from VisionMetrix
     *
     * getLatestEventsFiltered()
     *
     * @param       response            String                  the response from the callout
     *
     * @uses        visionMetrixLogin() Function                to get the token for the header
     */
    // public static void getLatestEventsFiltered(List<String> filterTerms) {
    //     // String headerToken = visionMetrixLogin();
    //     String headerToken = '4ac5ee08b1c5a901b52b84b3a7a8cd948f3460ee';
    //     HttpRequest request = new HttpRequest(  );
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/event/latest/');
    //     request.setMethod('GET');
    //     // request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     HttpResponse response = new Http(  ).send(request);
    //     Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
    //     System.debug(results);
    // }

    /**************************************************************************************************************************************** */
    /**
     * genEditCircuitPayload()
     *
     * Method to update the circuit id in VisionMetrix
     *
     * @param       oldId               String                  old circuit id
     * @param       newId               String                  the new circuit id
     *
     * @uses        circuitIdChange     VisionMetrixWrappers    the wrapper class to hold the old and new circuit ids
     *
     * @return                          String                   the payload for the callout
     */
    // public static String genEditCircuitPayload(String oldId, String newId) {
    //     VisionMetrixWrappers.EditCircuitInVisionMetrix circuitIdChange = new VisionMetrixWrappers.EditCircuitInVisionMetrix();
    //     circuitIdChange.old_circuit_alias = oldId;
    //     circuitIdChange.new_circuit_alias = newId;
    //     System.debug('Circuit Id Change Payload: ' + circuitIdChange);
    //     return JSON.serialize(circuitIdChange);
    // }

    /**************************************************************************************************************************************** */
    /**
     * updateCircuitIdInVM()
     *
     * Method to update the circuit id in VisionMetrix
     *
     * @param       oldId               String      the old circuit id
     * @param       newId               String      the new circuit id
     *
     * @uses        visionMetrixLogin()             to get the token for the header
     * @uses        genEditCircuitPayload()         to generate the payload for the callout
     * @uses        handleResponse()                to handle the response from the callout
     */
    // public static void updateCircuitIdInVM(String oldId, String newId) {
    //     String headerToken = visionMetrixLogin();
    //     Http http = new Http(  );
    //     HttpRequest request = new HttpRequest(  );
    //     String ticketPayload = genEditCircuitPayload(oldId, newId);
    //     request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/circuits/edit/');
    //     request.setMethod('POST');
    //     request.setHeader('X-ocularip-username', 'everstreampcol1');
    //     request.setHeader('X-ocularip-token', headerToken);
    //     request.setHeader('X-ocularip-company', 'Everstream');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
    //     request.setHeader('Connection', 'keep-alive');
    //     request.setHeader('Accept-Encoding', 'gzip, deflate, br');
    //     request.setBody(ticketPayload);
    //     HttpResponse response = http.send(request);
    //     // If the request is successful, parse the JSON response.
    //     handleResponse(response);
    // }

    /**************************************************************************************************************************************** */
    /**
     * pullAllCircuits()
     *
     * Method to pull all circuits from VisionMetrix
     *
     * @uses        visionMetrixLogin()             to get the token for the header
     * @uses        handleResponse()                to handle the response from the callout
     *
     */
    public static void pullAllCircuits() {
        List<VisionMetrix_Circuit__c> circuitList = new List<VisionMetrix_Circuit__c>();
        String headerToken = visionMetrixLogin();
        String urlEnd = 'https://rest-api2.visionmetrix.net/1.1/circuits/query/';
        List<String> queryList = new List<String>();
        queryList.add(urlEnd + '?type=DOMAIN&argument=EV%20Backbone%20|%20');// may not need
        queryList.add(urlEnd + '?type=DOMAIN&argument=Verizon%20|%20VZW%20[MI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=Verizon%20|%20VZW%20[OH]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=Consumers%20|%20CMS%20[MI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[IL]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[IN]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[MI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[MO]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[OHCL]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[OHCO]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[PA]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=T-Mobile%20|%20TMO%20[WI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Mobility%20|%20ATTM%20[MI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Mobility%20|%20ATTM%20[OH]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Mobility%20|%20ATTM%20[PA]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Wireline%20|%20ATTW%20[MI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Wireline%20|%20ATTW%20[OH]');

        // List<HttpResponse> responseList = new List<HttpResponse>();
        // List<Map<String, Object>> resultsMapList = new List<Map<String, Object>>();
        for ( String query : queryList ) {
            System.debug('endpoint' + query.trim().deleteWhitespace());
            HttpRequest request = new HttpRequest(  );
            request.setEndpoint(query.trim().deleteWhitespace());
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json,utf-8');
            request.setHeader('X-ocularip-username', 'everstreampcol1');
            request.setHeader('X-ocularip-token', headerToken);
            request.setHeader('X-ocularip-company', 'Everstream');
            HttpResponse response = new Http(  ).send(request);
            System.debug('response' + response);
            VisionMetrixHelperMethod.handleCircuits(response);
            // responseList.add(response);
            // Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
            // System.debug('results' + results);
            // resultsMapList.add(results);
        }
    }

    /**************************************************************************************************** */
}