public with sharing class VisionMetrixAddTicketInvocable{
    @InvocableMethod(label = 'Add Bulk VM Ticket'description = 'Add Tickets to VisionMetrix')
    public static void addBulkTicket(List<Case> ticketIds){
        
            VisionMetrixCallOut.addBulkVMTicket(ticketIds,'tpken');
        
    }
}