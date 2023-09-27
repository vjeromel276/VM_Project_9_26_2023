//* ================================================================================================================
//* Created by      : Vincent Lettau 
//* Date            : 2023-09-23
//* Description     : VisionMetrixTabTriggerHandler
//*                 : This class is used to handle the trigger logic for the VisionMetrix Support Ticket children
//*                 : This class is called from the VisionMetrix.trigger
//* Last Updated By : Vincent Lettau
//* Last Updated On : 2023-09-23
//* ================================================================================================================

public with sharing class VisionMetrixTabTriggerHandler {
    public VisionMetrixTabTriggerHandler() {}

    //@param cases - list of one cases that has had an Account added to it
    //               this method will add gather the needed information for the VM Ticket
    //               then pass it to the Vision Support Ticket Parent to create the VM Ticket
    //               and then send that data through the VM API to create the VM Ticket
    public static void onAfterUpdate(List<Case> cases) {
        System.debug('VisionMetrixTabTriggerHandler.onAfterUpdate');
        for(Case c : cases) {
            System.debug('Case: ' + c);
        }
    }
}