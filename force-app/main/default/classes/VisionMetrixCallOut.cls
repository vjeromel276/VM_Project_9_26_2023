public class VisionMetrixCallOut{
    // Practice Methoid used to test the call out
    public static void practiceMethod(String name){
        List<String> b = name.split('\\.');
        for (String x : b){
            System.debug(x);
        }
    }

    // Method to generate the payload for the login call out
    private static String genAuthPayload(){
        VisionMetrixWrappers.InitLogin login = new VisionMetrixWrappers.InitLogin();
        // System.debug(login);
        return JSON.serialize(login);
    }

    // Method to  get the token for the header
    public static String visionMetrixLogin(){

        Http http = new Http();
        HttpRequest request = new HttpRequest();

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
        if (response.getStatusCode() == 200){
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            // System.debug(results);

            String token = results.get('token').toString();
            // System.debug(token);
            return token;
        } else{
            System.debug('***********************************************RESPONSE***********************************************');
            Object[] keys = response.getHeaderKeys();
            Map<String, String> headers = new Map<String, String>();
            for (Object key : keys){

                System.debug(key + ' : ' + response.getHeader(key.toString()));
            }
            // System.debug(response.getBody());
            System.debug('******************************************END RESPONSE***********************************************');
            return null;
        }
    }

    // Method to handle the http response
    public static List<Object> handleResponse(HttpResponse response){
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200){
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            for (String key : results.keySet()){
                System.debug(key + ' : ' + results.get(key));
            }
            System.debug(results);
            return results.values();
        } else{
            System.debug('***********************************************RESPONSE***********************************************');
            Object[] keys = response.getHeaderKeys();
            Map<String, String> headers = new Map<String, String>();
            for (Object key : keys){

                System.debug(key + ' : ' + response.getHeader(key.toString()));
            }
            System.debug(response.getBody());
            System.debug('******************************************END RESPONSE***********************************************');
            return null;
        }
    }

    // Method to generate the payload for the ticket call outs
    public static String genExclusionPayload(String ticketId){
        // Call the wrapper class
        VisionMetrixWrappers.AddTicket ticketData = new VisionMetrixWrappers.AddTicket();

        // Case c = [SELECT Id, Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
        //           FROM Case
        //           WHERE Id = :ticketId];

        Case c = [SELECT Id, Related_Service_Order__r.Id, Related_Service_Order__r.Node__c,
                    Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, Maintenance_End__c
                    FROM Case
                    WHERE Id = :ticketId
                    LIMIT 1];

        Id serviceOrderId = c.Related_Service_Order__r.Id;

        //~ node id aEt3g000000XZNkCAO, aEt6g000000015CCAQ
        //~ ticket id 5003g00000B5Z3FAAV
        List<Node__c> nodeList = [SELECT Id, Name
                                  FROM Node__c
                                  WHERE Service_Order_Agreement__c = :serviceOrderId];

        if (nodeList != null){

            List<Id> nodeIds = new List<Id>();
            // Loop through the list of Node records and do something with each one if we want to
            for (Node__c n : nodeList){
                nodeIds.add(n.Id);
                System.debug('Node: ' + n.Name);
            }
            //********Required Fields *********//
            //^~ Ticket Id - Salesforce Ticket Case Number
            ticketData.ticket_id = ticketId;
            System.debug('Ticket Number: ' + ticketId);

            //^~ Ticket Type - Ticket Type defaults to 'Exclusion Period'
            ticketData.ticket_type = 'Exclusion Period';
            System.debug('Ticket Type: ' + ticketData.ticket_type);

            //^~ Circuit List - List of Circuits to be excluded
            ticketData.circuits = String.valueOf(nodeIds);
            System.debug('Circuits: ' + ticketData.circuits);

            //^~ Open Status - Exclusion Period Open Status defaults to 'Closed'
            ticketData.open_status = 'Closed';
            System.debug('Open Status: ' + ticketData.open_status);

            //^~ Severity - Exclusion Period Severity defaults to 'Low'
            ticketData.severity = 'Low';
            System.debug('Severity: ' + ticketData.severity);

            //^~ Start Time - Maintenance Start Time
            ticketData.start_time = Integer.valueOf(c.Maintenance_Start__c.getTime() / 1000);
            System.debug('Maintenance Start: ' + ticketData.start_time);

            //^~ End Time - Maintenance End Time
            ticketData.end_time = Integer.valueOf(c.Maintenance_End__c.getTime() / 1000);
            System.debug('Maintenance End: ' + ticketData.end_time);

            //********Optional Fields*********//
            //^~ Category - Default to Maintenance until the 1 to 1 mapping is complete
            System.debug('Category: ');
            //^~ Internal Notes - SF Generated Ticket
            System.debug('Internal Notes: "SF GENERATED VM TICKET');
            //^~ Exclusion Type - Exclusion Period Exclusion Type defaults to 'Smart'
            ticketData.exclusion_type = 'Smart';
            System.debug('Exclusion Type: ' + ticketData.exclusion_type);
            //^~ Exclude From Reporting - Exclusion Period Exclude From Reporting defaults to 'No' should be 'Yes' for exclusions
            ticketData.exclude_from_reporting = 'Yes';
            System.debug('Exclude From Reporting: ' + ticketData.exclude_from_reporting);
            //^~ Exclude From Monitoring Reporting - Exclusion Period Excluded From Monitoring defaults to 'No' should be 'Yes' for exclusions
            ticketData.exclusde_from_mttr_reporting = 'Yes';
            System.debug('Exclude From Monitoring Reporting: ' + ticketData.exclusde_from_mttr_reporting);
            //^~ Description
            ticketData.description = c.Description;
            System.debug('Description: ' + ticketData.description);
            //^~ Subject
            ticketData.subject = c.Subject;
            System.debug('Subject: ' + ticketData.subject);
            //^~ Support Agent
            ticketData.support_agent = c.NOC_Ticket_Assigment__c;
            System.debug('Support Agent: ' + ticketData.support_agent);
            //^ Match - Common tag to associate tickets together
        } else{
            //^If no Nodes are found, throw an error
            System.debug('No Nodes found on ticket: ' + ticketId);
            throw new System.QueryException('No Nodes found with the ticket number or ticket is not of correct type: ' + ticketId);
        }


        //******* Return the payload *******
        System.debug('Exclusion Peiod Ticket: ' + ticketData.ticket_id);
        return JSON.serialize(ticketData);
        // return null;
    }

    // Method to generate the payload for the ticket call outs
    public static String genNonExclusionPayload(String ticketId){
        return null;
    }

    //method to generate the payload for adding circuits to an existing vm ticket
    public static String genAddCircuitPayload(String vmTicketNumber, String selectedNodes){

        VisionMetrixWrappers.AddCircuitToTicket ticketData = new VisionMetrixWrappers.AddCircuitToTicket();
        ticketData.ticket_id = vmTicketNumber;
        ticketData.circuit_alias = selectedNodes;
        System.debug('Ticket Number: ' + ticketData.ticket_id);
        System.debug('Circuit Alias: ' + ticketData.circuit_alias);

        System.debug('Ids added to Exclusion Peiod Ticket: ' + ticketData.ticket_id);
        return JSON.serialize(ticketData);
    }

    // Method to add a ticket to VisionMetrix takes SF Support Ticket Number as input
    @AuraEnabled(cacheable = true)
    public static void addVMTicket(String ticketId, Boolean isExclusion){

        String headerToken = visionMetrixLogin();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String ticketPayload;
        if (isExclusion){

            ticketPayload = genExclusionPayload(ticketId);
        } else{
            ticketPayload = genNonExclusionPayload(ticketId);
        }

        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/add/');
        request.setMethod('POST');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));

        System.debug(ticketPayload);
        request.setBody(ticketPayload);

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        handleResponse(response);
    }

    // Method to get a ticket from VisionMetrix takes SF Support Ticket Number as input
    //! This method is not working
    public static void getVMTicket(String ticketId){

        String headerToken = visionMetrixLogin();
        String urlEnd = 'tickets/get?ticket_id=' + ticketId;
        String endpoint = 'https://rest-api2.visionmetrix.net/1.1/' + urlEnd;

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        System.debug(endpoint);
        request.setEndpoint(endpoint.trim());
        request.setMethod('GET');
        request.setHeader('Accept', 'text/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Lngth', '118');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        System.debug(response.getStatus());
        handleResponse(response);
    }

    public static void editVMTicket(String ticketId, List<Id> selectedNodes){

        String headerToken = visionMetrixLogin();

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String ticketPayload = genExclusionPayload(ticketId);
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/edit/');
        request.setMethod('POST');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
        request.setBody(ticketPayload);

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        handleResponse(response);
    }

    //^ Method to add a circuit to an existing VisionMetrix ticket by calling genAddCircuitPayload()
    @AuraEnabled
    public static void addCircuitToVMTicket(String vmTicketNumber, String selectedNodes){

        String headerToken = visionMetrixLogin();

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String ticketPayload = genAddCircuitPayload(vmTicketNumber, selectedNodes);
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/addCircuitToTicket/');
        request.setMethod('POST');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
        request.setBody(ticketPayload);

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        handleResponse(response);
    }

    @AuraEnabled
    public static void removeCircuitFromTicket(String vmTicketNumber, String selectedNodes){
        String headerToken = visionMetrixLogin();

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String ticketPayload = genAddCircuitPayload(vmTicketNumber, selectedNodes);
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/tickets/removeCircuitFromTicket/');
        request.setMethod('POST');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(ticketPayload.length()));
        request.setBody(ticketPayload);

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        handleResponse(response);
    }

    // invocableMethod for getting the latest events from VisionMetrix called from a flow
    @invocableMethod(label = 'Get Latest Events')
    public static void getLatestEventsInvocable(){
        getLatestEvents();
    }

    //& Method calls the VisionMetrix API to get the latest events and will create a new ticket in Salesforce or attach the event to an existing ticket
    @future(callout = true)
    public static void getLatestEvents(){

        String headerToken = visionMetrixLogin();

        HttpRequest request = new HttpRequest();

        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/event/latest/');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');

        HttpResponse response = new Http().send(request);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

        String success = results.get('success').toString();

        // System.debug('success: ' + success);
        if (success == 'false'){
            throw new System.QueryException('Callout failed with error: ' + results.get('error').toString());
        }

        String event = results.get('events').toString();
        System.debug('event: ' + event);

        List<String> eventList = event.split('}, ');
        if (eventList.size() > 1){
            for (String eventString : eventList){
                eventString = eventString.replace('(', '');
                eventString = eventString.replace(')', '');
                eventString = eventString.replace('{', '');
                List<String> kvps = eventString.split(',');
                // System.debug('kvps: ' + kvps);

                Map<String, String> eventMap = new Map<String, String>();
                VisionMetrix_Event__c newEvent = new VisionMetrix_Event__c();

                if (kvps.size() > 1){

                    for (String kvp : kvps){
                        // System.debug(kvp);
                        List<String> kvpList = kvp.split('=');
                        // System.debug(kvpList);
                        if (kvpList.size() > 1){
                            kvpList[0] = kvpList[0].trim().deleteWhitespace();
                            kvpList[1] = kvpList[1].trim().deleteWhitespace();
                            // kvpList[0] is the key, kvpList[1] is the value add to map
                            // System.debug('Label: ' + kvpList[0] + ' - Value:' + kvpList[1]);
                            eventMap.put(kvpList[0], kvpList[1]);
                        }
                    }
                }

                // eventMap has the key value pairs for the event the key matches the field name in the VM_Event__c object
                if (eventMap.size() > 1){
                    //^ Category
                    if (eventMap.get('category') != null && eventMap != null){
                        newEvent.Category__c = eventMap.get('category').trim().deleteWhitespace();
                    }
                    //^ Circuit Name
                    if (eventMap.get('circuit_name') != null && eventMap != null){
                        String circuitName = eventMap.get('circuit_name').trim().deleteWhitespace();
                        newEvent.Circuit__c = circuitName;
                        List<String> circuitNameList = circuitName.split('\\.');
                        if (circuitNameList.size() > 1){
                            // newEvent.Vendor__c = circuitNameList[0];
                            // newEvent.Market__c = circuitNameList[1];
                            // newEvent.Ring__c = circuitNameList[2];
                            // newEvent.Node__c = circuitNameList[3];
                            // String VLAN = circuitNameList[4];
                            // newEvent.VLAN__c = VLAN != null ? VLAN : '';
                        }
                    }
                    //^ Direction
                    if (eventMap.get('direction') != null && eventMap != null){
                        System.debug('direction: ' + eventMap.get('direction'));
                        newEvent.Direction__c = eventMap.get('direction');
                    }
                    //^ VisionMetrix Event Id
                    if (eventMap.get('id') != null && eventMap != null){
                        newEvent.Event_Id_In_VisionMetrix__c = eventMap.get('id').trim().deleteWhitespace();
                    }
                    //^ Event Name
                    if (eventMap.get('event_name') != null && eventMap != null){
                        newEvent.Event_Name__c = eventMap.get('event_name').trim().deleteWhitespace();
                    }
                    //^ KPI
                    if (eventMap.get('kpi') != null && eventMap != null){
                        newEvent.KPI__c = eventMap.get('kpi').trim().deleteWhitespace();
                    }
                    //^ Node Name
                    if (eventMap.get('node_name') != null && eventMap != null){
                        newEvent.Node_Name__C = eventMap.get('node_name').trim().deleteWhitespace();
                    }
                    //^ Secondary Circuit Name
                    if (eventMap.get('secondary_circuit_name') != null && eventMap != null){
                        newEvent.Secondary_Circuit_Name__c = eventMap.get('secondary_circuit_name');
                        //TODO: Add logic to get the related service order agreement from the secondary circuit name
                    }
                    //^ Severity
                    if (eventMap.get('severity') != null && eventMap != null){
                        if (eventMap.get('severity').Contains('nfo')){
                            newEvent.Severity__c = 'Informational';
                        } else if (eventMap.get('severity').Contains('inor')){
                            newEvent.Severity__c = 'Minor';
                        } else if (eventMap.get('severity').Contains('ajor')){
                            newEvent.Severity__c = 'Major';
                        } else if (eventMap.get('severity').Contains('ritical')){
                            newEvent.Severity__c = 'Critical';
                        }
                    }
                    //^ Start Time
                    if (eventMap.get('start_time') == null || eventMap.get('start_time') == ''){
                        newEvent.Start_Time__c = null;
                        // System.debug('Start Time should be null and is....... ' + eventMap.get('start_time'));
                    } else{
                        String sdt = eventMap.get('start_time').trim().deleteWhitespace();
                        Long sldt = Long.valueOf(sdt) * 1000;
                        newEvent.Start_Time__c = Datetime.newInstance(sldt);
                        // System.debug('Start Time is: ' + eventMap.get('start_time'));
                    }
                    //^ Start Time

                    //^ End Time
                    if (eventMap.get('end_time') == null || eventMap.get('end_time') == ''){
                        newEvent.End_Time__c = null;
                    } else{
                        String sdt = eventMap.get('end_time').trim().deleteWhitespace();
                        Long eldt = Long.valueOf(sdt) * 1000;
                        newEvent.End_Time__c = Datetime.newInstance(eldt);
                    }

                    //& this will be what make support tickets out of the events
                    // handleEvent(newEvent);
                    insert newEvent;
                }
            }
        } else{
            System.debug('No new events found');
        }
    }

    // method to handle the event and create a ticket in Salesforce
    public static void handleEvent(VisionMetrix_Event__c newEvent){
        if (newEvent != null){
            Case c = new Case();
            c.RecordTypeId = '012U0000000DpFKIA0';
            c.Subject = newEvent.Event_Name__c + ' | ' + newEvent.Secondary_Circuit_Name__c + ' | ' + newEvent.Severity__c;
            c.Description = newEvent.Circuit__c;
            c.Type__c = 'Vision Metrics';
            c.Origin = 'Proactive';
            insert c;
        }
    }

    public static void getLatestEventsFiltered(List<String> filterTerms){

        // String headerToken = visionMetrixLogin();
        String headerToken = '4ac5ee08b1c5a901b52b84b3a7a8cd948f3460ee';

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://rest-api2.visionmetrix.net/1.1/event/latest/');
        request.setMethod('GET');
        // request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('X-ocularip-username', 'everstreampcol1');
        request.setHeader('X-ocularip-token', headerToken);
        request.setHeader('X-ocularip-company', 'Everstream');


        HttpResponse response = new Http().send(request);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

        System.debug(results);
    }

}