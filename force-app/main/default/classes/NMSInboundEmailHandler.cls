/**
 * @description       : 
 * @author            : nbratton@everstream.net
 * @group             : 
  * @last modified on  : 12-01-2022
 * @last modified by  : clabelle@everstream.net
**/
global class NMSInboundEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        system.debug('****  NMSInboundEmailHandler  ****');
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try {

            NMS_Alert__c alert = ProcessEmail(email);
            
            //query for filters by source
            List<Email_String_Filter__c> filters = [SELECT Id, RegEx_String__c, Filter_Decision__c FROM Email_String_Filter__c WHERE Source__c = :alert.Source__c];

            String decision = '';
            if (filters != NULL && filters.size() > 0) {
                //if not null, check each filter
                Boolean match = FALSE;
                
                for (Email_String_Filter__c f: filters) {
                    match = Pattern.compile(f.RegEx_String__c).matcher(alert.Message__c + alert.Input_Parameters__c.stripHtmlTags()).find();
                    if(match){
                        decision = f.Filter_Decision__c;
                        break;
                    }
                }
            }
            
            if((filters == NULL || filters.size() == 0) || (decision == 'Allow' && alert.Source__c == 'Celestis' )) {
                if(alert.Identifier__c != NULL) {
                    Boolean isUpsertfirstTime = true;
                    
                    try {
                        upsert alert Identifier__c;
                    } catch (DMLException e) {
                        System.debug('Re-trying');
                        String uniqueString = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128)).substring(0, 10);
                        alert.Identifier__c += '|' + uniqueString;
                        if(isUpsertfirstTime) {
                            upsert alert Identifier__c;
                            isUpsertfirstTime = false;
                        }
                    }
                } else {
                    insert alert;

                    Record_Creation__e pe = new Record_Creation__e();
                    Formula.recalculateFormulas(new List<NMS_Alert__c> { alert });
                    pe.Record_Id__c = alert.Id;
                    pe.Acknowledge_URL_c__c = alert.Acknowledge_URL__c;
                    pe.Acknowledged_c__c = alert.Acknowledged__c;
                    pe.Acknowledged_By_c__c = alert.Acknowledged_By__c;
                    pe.Acknowledged_Date_Time_c__c = alert.Acknowledged_Date_Time__c;
                    pe.Alert_URL_c__c = alert.Alert_URL__c;
                    pe.AlertType_c__c = alert.AlertType__c;
                    pe.ClosedDate_c__c = alert.ClosedDate__c;
                    pe.CreatedDate__c = alert.CreatedDate;
                    pe.Device_ID_c__c = alert.Device_ID__c;
                    pe.Identifier_c__c = alert.Identifier__c;
                    pe.Increment_Alert_Count_c__c = alert.Increment_Alert_Count__c;
                    pe.Input_Parameters_c__c = alert.Input_Parameters__c;
                    pe.Instigator_c__c = alert.Instigator__c;
                    pe.Interface_ID_c__c = alert.Interface_ID__c;
                    pe.IP_Address_c__c = alert.IP_Address__c;
                    pe.Message__c = alert.Message__c;
                    //pe.Record_Name__c = alert.Name;
                    pe.Record_Name__c = alert.Alert_Name__c;//try new name
                    pe.Service_ID_c__c = alert.Service_ID__c;
                    pe.Source_c__c = alert.Source__c;
                    pe.Status_c__c = alert.Status__c;
                    pe.Times_Alert_Received_c__c = alert.Times_Alert_Received__c;
                    pe.URL__c = 'https://' + URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0] + '.lightning.force.com/lightning/r/NMS_Alert__c/' + alert.Id + '/view';
                    pe.open__c = true;
                    Database.SaveResult sr = EventBus.publish(pe);
                }

                if (alert.Id != NULL) {
                    EmailMessage emailMessage = EmailToEmail(email, alert.Id);
                    insert emailMessage;
                }

                result.success = true;
            }

        } catch (Exception e) {
            // If there's an exception, create an error which notifies development team.
            String sub = NULL;
            if (email != NULL && email.subject != NULL) {   sub = email.subject;    }
            
            CreateErrorRecord er = new CreateErrorRecord();
            er.create('NMSInboundEmailHandler', NULL, e.getMessage() + ' -- ' + sub, e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
            result.success = false;
        }
        
        //Final bit to process the email.
        return result;
    }

    /**
     * Helper method to stuff all the parts from the incoming email into an NMS_Alert__c object
     */
    private NMS_Alert__c ProcessEmail(Messaging.InboundEmail email) {
        NMS_Alert__c alert = new NMS_Alert__c();
        List<String> subjectParams = new List<String>();
        
        alert.Last_Time_Alert_Recieved__c = System.now();
        alert.Increment_Alert_Count__c = true;
        alert.Source_Content_Type__c = 'Email';

        String toAddressesString = '';
        if (email.toAddresses != null && email.toAddresses.size() > 0 ) {
            for (String emailAddressTemp : email.toAddresses) {
                toAddressesString += emailAddressTemp + ';';
            }
            toAddressesString.toLowerCase();
        }

        if (email.subject != NULL) {
            alert.Message__c = email.subject;
        } else {
            alert.Message__c = '(No Subject)';
        }
        
        if (email.fromAddress != NULL && (email.fromAddress.contains('celestis') || email.fromAddress.contains('kjones@everstream.net') || email.fromAddress.contains('hramsey@everstream.net'))) {
            alert.Source__c = 'Celestis';

            //Attempt to build the unique identifier
            if (email.subject.contains(',')) {
                alert.Identifier__c = email.subject.split(',')[0];
                alert.Identifier__c = alert.Identifier__c.replace('Alarm status for ', '');
                alert.Identifier__c = alert.Identifier__c.trim();
                alert.Identifier__c = alert.Identifier__c + ' | Celestis | ' + System.today().format();
            }

            //this is probably more complicated than it needs to be.... made it more concise..
            /*if (email.subject.contains('-')) {
                subjectParams = email.subject.split('-');
                if (subjectParams != NULL && subjectParams.size() >= 2) {
                    String firstParam = subjectParams.get(0).trim();
                    if (firstParam.contains(' ')) {
                        List<String> firstParams = firstParam.split(' ');
                        firstParam = firstParams.get(firstParams.size() - 1).trim();
                    }

                    alert.Identifier__c = firstParam + ' - ' + subjectParams.get(1).trim() + ' - ' + subjectParams.get(2).trim();
                    if (alert.Identifier__c.contains(',')) {
                        alert.Identifier__c = alert.Identifier__c.split(',')[0];
                    }
                }
            }*/
        // being throrough with this check
        } else if (email.fromAddress != null && (toAddressesString.contains('power.alert') || email.fromAddress.contains('power.alert') || toAddressesString.contains('power_alert') || email.fromAddress.contains('power_alert'))) {
            alert.Source__c = 'Power Alert';
            alert.Identifier__c = email.subject;
            if (alert.Identifier__c.length() > 215) { // field capped at 255, leaving room for timestamp
                alert.Identifier__c.substring(0, 215);
            }
            alert.Identifier__c = alert.Identifier__c + ' | Power Alert Email | ' + System.now();
            
        } else {
            alert.Source__c = 'Unknown';
        }

        if (email.plainTextBody != NULL) {
            alert.Input_Parameters__c = email.plainTextBody;
        } else if (email.htmlBody != NULL) {
            alert.Input_Parameters__c = email.htmlBody;
        }

        Integer maxSize = 131072;
        if (alert.Input_Parameters__c != NULL && alert.Input_Parameters__c.length() > maxSize) {
            alert.Input_Parameters__c = alert.Input_Parameters__c.substring(0, maxSize);
        }

        // to do : parse the body of the email and fit it into alert object
        return alert;
    }

    /**
     * Helper method to convert Messaging.InboundEmail to EmailMessage
     * relatedId is the Id of the previously created alarm
     */
    private EmailMessage EmailToEmail(Messaging.InboundEmail email, Id relatedId) {
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.Status = '0'; // "New"
        emailMessage.FromAddress = email.FromAddress;
        if ( email.toAddresses != NULL && email.toAddresses.size() > 0 )
            emailMessage.ToAddress = String.join( email.toAddresses, ';' );
        if ( email.ccAddresses != null && email.ccAddresses.size() > 0 )
            emailMessage.CcAddress = String.join( email.ccAddresses, ';' );
        if ( email.FromName != NULL ) emailMessage.FromName = email.FromName;
        if ( email.subject != NULL ) {
            emailMessage.subject = email.subject;
        } else {
            emailMessage.subject = '(No Subject)';
        }
        String headersString = '';
        for (Messaging.InboundEmail.Header hdr : email.headers) {
            if (hdr == NULL || hdr.name == NULL || hdr.value == NULL) {
                continue;
            }
            if (headersString != '') {
                headersString += '\n';
            }
            headersString += hdr.name;
            headersString += ': ';
            headersString += hdr.value;
        }
        emailMessage.Headers = headersString;
        if ( email.PlainTextBody != NULL ) {
            if (email.plainTextBody.length() > 131072) {
                emailMessage.TextBody = email.plainTextBody.substring(0,131072);
            } else {
                emailMessage.TextBody = email.plainTextBody;
            }
        }
        if ( email.HtmlBody != NULL ) {
            if (email.HtmlBody.length() > 131072 ) {
                emailMessage.HtmlBody = email.HtmlBody.substring(0,131072);
            } else {
                emailMessage.HtmlBody = email.HtmlBody;
            }
        }
        emailMessage.NMS_Alert__c = relatedId;
        emailMessage.RelatedToId = relatedId;
        return emailMessage;
    }
}