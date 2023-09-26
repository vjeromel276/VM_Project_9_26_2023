trigger VisionMetrix on Case(after update ){
	System.debug('VisionMetrix Trigger');
	if (Disabled_Triggers__c.getValues('VisionMetrix') == null || Disabled_Triggers__c.getValues('VisionMetrix').Disabled__c == false){
		for (Case c : Trigger.new ){
			// get list of companies from Chemito
			List<String> vmCompName = new List<String>();
			// vmCompName.add('everstream');
			vmCompName.add('t-mobile');
			vmCompName.add('att wireless');
			if (c.Account_Name_Text__c != null){
				String companyName = c.Account_Name_Text__c.trim().toLowerCase();
				// if companyName is in the list of companies from Chemito
				// after the case is updated
				// then start visionmetrix process
				// else do nothing
				if (companyName != null && companyName != ''){

					System.debug('Company Name: ' + companyName);
					for (String str : vmCompName){
						if (c.Related_Service_Order__c != null){
							System.debug('Service Order: ' + c.Related_Service_Order__c);
							if (companyName == str){
								// start visionmetrix process
								Case[] cases = new Case[]{ c };
								System.debug('VisionMetrix Process Started');
								System.debug('Case ID: ' + c.Id);
								VisionMetrixTabTriggerHandler.onAfterUpdate(cases);
							} else{
								System.debug('Company Name is not VisionMetrix TrackedCompany');
							}
						}else{
							System.debug('Service Order is null');
						}
					}
				}
			} else{
				System.debug('Account Name is null');
			}
		}
	}
}