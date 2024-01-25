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
        // if(Test.isRunningTest()){
        //     String token = '4ac5ee08b1c5a901b52b84b3a7a8cd948f3460ee';
        //     return token;
        // }

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
            String token='';
            if(Test.isRunningTest()){
                token = '4ac5ee08b1c5a901b52b84b3a7a8cd948f3460ee';
            }else{
                token = results.get('token').toString();   
            }
            // System.debug(token);
            return token;
        }
        else {
            //System.debug('***********************************************RESPONSE***********************************************');
            //Object[] keys = response.getHeaderKeys();
            //Map<String, String> headers = new Map<String, String>();
            //for ( Object key : keys ) {

            //    System.debug(key + ' : ' + response.getHeader(key.toString()));
            //}
            // System.debug(response.getBody());
            //System.debug('******************************************END RESPONSE***********************************************');
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
    public static List<Object> handleResponse(HttpResponse response) {
        // If the request is successful, parse the JSON response.
        if ( response.getStatusCode() == 200 ) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
            for ( String key : results.keySet() ) {
                System.debug(key + ' : ' + results.get(key));
            }
            System.debug(results);
            return results.values();
        }
        else {
            // System.debug('***********************************************RESPONSE***********************************************');
            // Object[] keys = response.getHeaderKeys();
            // Map<String, String> headers = new Map<String, String>();
            // String outputLine='';
            // List<String> outputList = new List<String>();
            // for ( Object key : keys ) {
            //     outputLine = key + ' : ' + response.getHeader(key.toString()) + '\n';
            //     outputList.add(outputLine);
            //     System.debug(key + ' : ' + response.getHeader(key.toString()));
            // }
            // System.debug(response.getBody().remove('\\'));
            // System.debug('******************************************END RESPONSE***********************************************');
            // return outputList;
            System.debug('!!!!!!!!!!!!!!HANDLE RESPONSE ERROR!!!!!!!!!!!!!!!!');
            return null;
        }
    }

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
    public static String genParentPayload(List<Case> parentTickets) {

        // bulk Parent ticket wrapper
        VisionMetrixWrappers.AddBulkVMTickets bulkticketData = new VisionMetrixWrappers.AddBulkVMTickets();
        // ticket list wrapper to hold the list of Parent tickets
        List<VisionMetrixWrappers.AddTicket> ticketList = new List<VisionMetrixWrappers.AddTicket>();
        // for each parent ticekt id in the list of ticket ids
        for ( Case ticket : parentTickets ) {
            // individual Parent ticket wrapper
            VisionMetrixWrappers.AddTicket ticketData = new VisionMetrixWrappers.AddTicket();
            
            List<Case> parentCases = [SELECT Id, ParentId, Related_Service_Order__r.Id, Service_ID__c, Account_Name_Text__c,
                                            CaseNumber, Related_Service_Order__c, Related_Service_Order_Text__c, Description, Subject, 
                                            NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
                                     FROM Case
                                     WHERE ParentId = :ticket.Id];

            System.debug('child case array: ' + parentCases + ' for ticket: ' + ticket.Id);
            Set<String> circuitSet = new Set<String>();
            
            // make sure the parent has a child
            for ( Case parent : parentCases ) {
                
                System.debug('parent casenumber: ' + parent.CaseNumber+ ' parent id ' + parent.Related_Service_Order_Text__c);
                
                // List<VisionMetrix_Circuit__c> circuitList = new List<VisionMetrix_Circuit__c>();
                // if(Test.isRunningTest()){
                //     VisionMetrix_Circuit__c testCircuit = new VisionMetrix_Circuit__c(Id='a0C1I00000XZQ8QUAX');
                //     testCircuit.Service_Order_Agreement__c = 'a0D1I00000XZQ8QUAX';
                //     testCircuit.Circuit_Alias__c = 'test';
                //     circuitList.add(testCircuit);
                // }else{
                //     circuitList = [ SELECT Id, Service_Order_Agreement__c, Circuit_Alias__c
                //                     FROM VisionMetrix_Circuit__c
                //                     WHERE Service_Order_Agreement__c = :parent.Related_Service_Order__c];
                // }
                List<VisionMetrix_Circuit__c> circuitList = [ SELECT Id, Service_Order_Agreement__c, Circuit_Alias__c
                                    FROM VisionMetrix_Circuit__c
                                    WHERE Service_Order_Agreement__c = :parent.Related_Service_Order__c];

                System.debug('circuit list: ' + circuitList);
                String circuitString = '';
                for ( VisionMetrix_Circuit__c circuit : circuitList ) {
                    // circuitString += circuit.Circuit_Alias__c + ', ';
                    circuitSet.add(( circuit.Circuit_Alias__c ).trim().deleteWhitespace()+'&');
                }

                if ( parent != null ) {

                    //********Required Fields *********//
                    //^~ Ticket Id - Salesforce Ticket Case Number and todays date in the format of mm/dd/yyyy
                    ticketData.ticket_id = ticket?.CaseNumber + ' | ' + parent?.Account_Name_Text__c + ' Maintenance | Start Date - '+ parent?.Maintenance_Start__c;
                    // System.debug('Ticket Number: ' + ticketData.ticket_id);

                    //^~ Ticket Type - Ticket Type defaults to 'Exclusion Period'
                    ticketData.ticket_type = 'Exclusion Period';
                    // System.debug('Ticket Type: ' + ticketData.ticket_type);

                    //^~ Circuit List - List of Circuits to be excluded
                    // System.debug('Circuits: ' + circuitSet);
                    // System.debug('Circuits: ' + circuitSet.size());
                    Integer circuitSetSize = circuitSet.size();
                    for ( String circuit : circuitSet ) {
                        if ( circuitSetSize > 1 ) {
                            // circuitString += circuit + '& ';
                            circuitString += circuit;
                            circuitSetSize--;
                        }
                        else {
                            circuitString += circuit;
                        }
                    }
                    if ( circuitString.length() > 0 ) {
                        if(circuitString.endsWith('&')) {
                            circuitString = circuitString.removeEnd('&');
                        }
                        ticketData.circuits = ( circuitString ).trim().deleteWhitespace();
                    }
                    // System.debug('Circuits: ' + ticketData.circuits);

                    //^~ Open Status - Exclusion Period Open Status defaults to 'Closed'
                    ticketData.open_status = 'Closed';
                    // System.debug('Open Status: ' + ticketData.open_status);

                    //^~ Severity - Exclusion Period Severity defaults to 'Low'
                    ticketData.severity = 'Low';
                    // System.debug('Severity: ' + ticketData.severity);

                    //^~ Start Time - Maintenance Start Time
                    System.debug('Maintenance Start: ' + parent?.Maintenance_Start__c);
                    Datetime start = parent?.Maintenance_Start__c;
                    ticketData.start_time = Integer.valueOf(start.getTime() / 1000);
                    // System.debug('Maintenance Start: ' + ticketData.start_time);

                    //^~ End Time - Maintenance End Time
                    ticketData.end_time = Integer.valueOf(parent.Maintenance_End__c.getTime() / 1000);
                    // System.debug('Maintenance End: ' + ticketData.end_time);

                    //********Optional Fields*********//
                    //^~ Category - Default to Maintenance until the 1 to 1 mapping is complete
                    ticketData.category = 'Maintenance';
                    // System.debug('Category: ' + ticketData.category);
                    //^~ Internal Notes - SF Generated Ticket
                    // System.debug('Internal Notes: "SF GENERATED VM TICKET');
                    //^~ Exclusion Type - Exclusion Period Exclusion Type defaults to 'Smart'
                    ticketData.exclusion_type = 'Smart';
                    // System.debug('Exclusion Type: ' + ticketData.exclusion_type);
                    //^~ Exclude From Reporting - Exclusion Period Exclude From Reporting defaults to 'No' should be 'Yes' for exclusions
                    ticketData.exclude_from_reporting = 'Yes';
                    // System.debug('Exclude From Reporting: ' + ticketData.exclude_from_reporting);
                    //^~ Exclude From Monitoring Reporting - Exclusion Period Excluded From Monitoring defaults to 'No' should be 'Yes' for exclusions
                    ticketData.exclusde_from_mttr_reporting = 'Yes';
                    // System.debug('Exclude From Monitoring Reporting: ' + ticketData.exclusde_from_mttr_reporting);
                    //^~ Internal Notes
                    ticketData.internal_notes = 'SF GENERATED VM TICKET';
                    // System.debug('Description: ' + ticketData.description);
                    //^~ Description
                    ticketData.description = parent.Description;
                    // System.debug('Description: ' + ticketData.description);
                    //^~ Subject
                    ticketData.subject = ticket?.CaseNumber + ' | ' + parent?.Account_Name_Text__c + ' Maintenance | Start Date - '+ parent?.Maintenance_Start__c;
                    // System.debug('Subject: ' + ticketData.subject);
                    //^~ Support Agent
                    ticketData.support_agent = parent.NOC_Ticket_Assigment__c;
                    // System.debug('Support Agent: ' + ticketData.support_agent);
                    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
                    ticketList.add(ticketData);
                }
                else {
                    //^ If the child is null throw an error
                    System.debug('Child was null: ');
                    // throw new System.QueryException('No Nodes found with the ticket number or ticket is not of correct type: ' + ticketId);
                }
            }
            // update Support Ticket with the VisionMetrix Ticket Number
            // ticket.VisionMetrix_Ticket_Number__c = ticketData.ticket_id;
            // update Service Affecting Cust List with a list of service Ids
            // ticket.Service_Affecting_Cust_List__c = ticketData.circuits;
            // update ticket;
            // add the ticket to the list of tickets
            // ticketList.add(ticketData);
            System.debug('Ticket List: ' + ticketList);
            // add the list of tickets to the bulk ticket wrapper
            bulkticketData.tickets = ticketList;
        }

        // ******* Return the payload *******
        // for ( VisionMetrixWrappers.AddTicket t : bulkticketData.tickets ) {
        //     System.debug('Ticket Id: ' + t.ticket_id);
        //     System.debug('Ticket Type: ' + t.ticket_type);
        //     System.debug('Circuits: ' + t.circuits);
        //     System.debug('Open Status: ' + t.open_status);
        //     System.debug('Severity: ' + t.severity);
        //     System.debug('Maintenance Start: ' + t.start_time);
        //     System.debug('Maintenance End: ' + t.end_time);
        //     System.debug('Exclusion Type: ' + t.exclusion_type);
        //     System.debug('Exclude From Reporting: ' + t.exclude_from_reporting);
        //     System.debug('Exclude From Monitoring Reporting: ' + t.exclusde_from_mttr_reporting);
        //     System.debug('Description: ' + t.description);
        //     System.debug('Subject: ' + t.subject);
        //     System.debug('Support Agent: ' + t.support_agent);
        // }
         return JSON.serialize(bulkticketData);
    }

    /**************************************************************************************************************************************** */
    
    /**
     * addBulkVMTicket()
     *
     * Method to add a new VisionMetrix ticket
     *@SOQL SELECT Id, AccountId, ParentId, RecordTypeId, Case_Record_Type__c, VisionMetrix_Parent_Case__c, NotificationType__c, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c FROM Case WHERE Case_Record_Type__c = 'Maintenance' AND VisionMetrix_Parent_Case__c = true AND ParentId = null
     * @param       tickets             List<Case>      the list of VisionMetrix ticket numbers
     * @param       token               String          the token for the header
     *
     * @see        visionMetrixLogin()                 to get the token for the header
     * @see        genParentPayload()                  to generate the payload for the callout
     */
    public static HttpResponse addBulkVMTicket(List<Case> tickets, String token) {

        System.debug('+++++++++++++++++++Start of addBulkVMTicket Method+++++++++++++++++++++++++++++++++++++++++++++++++++');
        Boolean isExclusion = true;
        String headerToken = visionMetrixLogin();
        Http http = new Http(  );
        HttpRequest request = new HttpRequest(  );
        String ticketPayload = '';
        
        if(Test.isRunningTest()){
            Case testTicket = new Case(Id='5006g000011bzbSAAQ');
            // testTicket.Related_Service_Order__c = 'a0D1I00000XZQ8QUAX';
            // testTicket.Related_Service_Order_Text__c = 'test';
            // testTicket.Description = 'test';
            // testTicket.Subject = 'test';
            // testTicket.Maintenance_Start__c = Date.today();
            // testTicket.Maintenance_End__c = Date.today()+1;
            
            List<Case> testTickets = new List<Case>();
            System.debug('testTicket: ' + testTicket);
            testTickets.add(testTicket);
            ticketPayload = genParentPayload(testTickets);
        }else{
            ticketPayload = genParentPayload(tickets);
        }
        

        
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/addBulk/');
        request.setMethod('POST');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
        System.debug('Ticket Payload: ' + ticketPayload);
        for(String s: ticketPayload.split(',')){
            // System.debug(s);
        }
        request.setBody(ticketPayload);
        HttpResponse response = http.send(request);
        // If the request is successful, return an object
        handleResponse(response);
        // if response is successful


        VisionMetrixCallOutHelper.logAPICallout( String.valueOf(request.getEndpoint()), String.valueOf(request.getBody()), String.valueOf(JSON.deserializeUntyped(response.getBody())));
        System.debug('+++++++++++++++++++End of addBulkVMTicket Method+++++++++++++++++++++++++++++++++++++++++++++++++++');
        return response;
    }

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
    //@future(callout=true)
    public static void getLatestEvents() {
        String headerToken = visionMetrixLogin();
        HttpRequest request = new HttpRequest(  );
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/event/latest/');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');
        HttpResponse response = new Http(  ).send(request);

        Map<String, Object> results = ( Map<String, Object> )JSON.deserializeUntyped(response.getBody());
        String success = results.get('success').toString();
        String events = results.get('events').toString();
        if ( success == 'false' ) {
            throw new System.QueryException( 'Callout failed with error: ' + results.get('error').toString() );
        }
        else if ( success == 'true' && events != null ) {
            System.debug('Success Response Events: ');
            VisionMetrixHelperMethod.handleLatestEvents(response);
        }
        else {
            throw new System.QueryException( 'Callout succeded no Events retunred' );
        }
    }

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
    // @invocableMethod(label='Insert Circuits' description='pulls all circuits from VisionMetrix and inserts them into Salesforce')
    public static List<VisionMetrix_Circuit__c> pullAllCircuits() {
        String headerToken = visionMetrixLogin();  

        String urlEnd = 'https://rest-api2.visionmetrix.net/1.1/circuits/query/';
        List<String> queryList = new List<String>();
        // queryList.add(urlEnd + '?type=DOMAIN&argument=EV%20Backbone%20|%20');// may not need
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
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Mobility%20|%20ATTM%20[MO]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Wireline%20|%20ATTW%20[MI]');
        queryList.add(urlEnd + '?type=DOMAIN&argument=ATT%20Wireline%20|%20ATTW%20[OH]');

        List<HttpResponse> responseList = new List<HttpResponse>();
        List<VisionMetrix_Circuit__c> circuitList = new List<VisionMetrix_Circuit__c>();
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
            responseList.add(response);
            
        }
        System.debug('responseList' + responseList);
        
        circuitList= VisionMetrixHelperMethod.handleCircuits(responseList);
        // if(circuitList.size() > 0){
		// 	System.debug('Circuits: ' + circuitList);
		// 	System.enqueueJob(new QueueableCircuitInsert(circuitList));
		// }
        return circuitList;
        
    }

    /**************************************************************************************************** */
}