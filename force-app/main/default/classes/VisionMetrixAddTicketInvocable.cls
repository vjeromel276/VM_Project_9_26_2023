public with sharing class VisionMetrixAddTicketInvocable{
    @InvocableMethod(label = 'Add Ticket'description = 'Add Ticket to VisionMetrix')
    public static void addTicket(List<String> ticketId){
        for (String ticket : ticketId){
            VisionMetrixCallOut.addVMTicket(ticket, true);
        }
    }
}