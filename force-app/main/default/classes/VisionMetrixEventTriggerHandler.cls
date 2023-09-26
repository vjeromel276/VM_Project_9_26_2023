public with sharing class VisionMetrixEventTriggerHandler{
    public VisionMetrixEventTriggerHandler(){
    }

    public static void handleEvents(List<VisionMetrix_Event__c> newEvents){
        if (newEvents == null || newEvents.isEmpty()){
            List<Case> vmSupportTickets = new List<Case>();
            for (VisionMetrix_Event__c event : newEvents){
                Case c = new Case();
                c.RecordTypeId = '012U0000000DpFKIA0';
                c.Subject = event.Event_Name__c + ' | ' + event.Secondary_Circuit_Name__c + ' | ' + event.Id;
                c.Description = event.Circuit__c;
                c.Type__c = 'Vision Metrics';
                c.Origin = 'Proactive';
                vmSupportTickets.add(c);
            }
            insert vmSupportTickets;
        }
    }
}