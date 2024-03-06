public with sharing class PracticeClass {
    //~ a reworked method
    public static String genParentPayload(List<Case> parentTickets) {

        System.debug('+++++++++++++++++++Start of genParentPayload Method+++++++++++++++++++++++++++++++++++++++++++++++++++');

        // bulk Parent ticket wrapper
        VisionMetrixWrappers.AddBulkVMTickets bulkticketData = new VisionMetrixWrappers.AddBulkVMTickets();
        // ticket list wrapper to hold the list of Parent tickets
        List<VisionMetrixWrappers.AddTicket> ticketList = new List<VisionMetrixWrappers.AddTicket>();
        // for each parent ticekt id in the list of ticket ids
        System.debug('genParentPayload parentTickets: ' + parentTickets.size());
        // new style loop
        for ( Case ticket : parentTickets ) {
            System.debug('genParentPayload ticket: ' + ticket);
            // individual Parent ticket wrapper
            VisionMetrixWrappers.AddTicket ticketData = new VisionMetrixWrappers.AddTicket();
            Set<String> circuitSet = new Set<String>();
            String circuitString = '';

            for ( Case child : [SELECT Id, ParentId, Related_Service_Order__r.Id, Service_ID__c, 
                                       Account_Name_Text__c, CaseNumber, Related_Service_Order__c, Related_Service_Order_Text__c, 
                                       Description, Subject, NOC_Ticket_Assigment__c, Maintenance_Start__c, 
                                       Maintenance_End__c
                                FROM Case
                                WHERE ParentId = :ticket.Id] ) {
                System.debug('genParentPayload child case: ' + child);

                for ( VisionMetrix_Circuit__c circuit : [SELECT Id, Service_Order_Agreement__c, Circuit_Alias__c
                                                         FROM VisionMetrix_Circuit__c
                                                         WHERE Service_Order_Agreement__c = :child.Related_Service_Order__c] ) {
                    // circuitString += circuit.Circuit_Alias__c + ', ';
                    circuitSet.add(( circuit.Circuit_Alias__c ).trim().deleteWhitespace() + '&');
                }
            }
            //********Required Fields *********//
            //^~ Ticket Id - Salesforce Ticket Case Number and todays date in the format of mm/dd/yyyy
            ticketData.ticket_id = ticket?.CaseNumber + ' | ' + ticket?.Account_Name_Text__c + ' Maintenance | Start Date - ' + ticket?.Maintenance_Start__c;
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
                if ( circuitString.endsWith('&') ) {
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
            // System.debug('Maintenance Start: ' + ticket?.Maintenance_Start__c);
            Datetime start = ticket?.Maintenance_Start__c;
            ticketData.start_time = Integer.valueOf(start.getTime() / 1000);
            // System.debug('Maintenance Start: ' + ticketData.start_time);

            //^~ End Time - Maintenance End Time
            ticketData.end_time = Integer.valueOf(ticket.Maintenance_End__c.getTime() / 1000);
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
            ticketData.description = ticket.Description;
            // System.debug('Description: ' + ticketData.description);
            //^~ Subject
            ticketData.subject = ticket?.CaseNumber + ' | ' + ticket?.Account_Name_Text__c + ' Maintenance | Start Date - ' + ticket?.Maintenance_Start__c;
            // System.debug('Subject: ' + ticketData.subject);
            //^~ Support Agent
            ticketData.support_agent = ticket.NOC_Ticket_Assigment__c;
            // System.debug('Support Agent: ' + ticketData.support_agent);
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

            // add the ticket to the list of tickets
            ticketList.add(ticketData);
            System.debug('Ticket List: ' + ticketList);
            // add the list of tickets to the bulk ticket wrapper
            System.debug('genParentPayload Bulk Ticket Data: ' + bulkticketData);

        }
        // add the list of tickets to the bulk ticket wrapper
        bulkticketData.tickets = ticketList;
        System.debug('+++++++++++++++++++End of genParentPayload Method+++++++++++++++++++++++++++++++++++++++++++++++++++');
        return JSON.serialize(bulkticketData);
    }

}