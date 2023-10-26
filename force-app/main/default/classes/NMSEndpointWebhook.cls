/**
 * @description       : 
 * @author            : clabelle@everstream.net
 * @group             : 
 * @last modified on  : 03-28-2023
 * @last modified by  : nbratton@everstream.net
 * 
 * Prod: https://support.everstream.net/services/apexrest/webhooks/NMSEndpoint/handleAlert
 * UAT: https://everstream--uat.sandbox.my.salesforce-sites.com/support/services/apexrest/webhooks/NMSEndpoint/handleAlert
**/

@RestResource(urlMapping='/webhooks/NMSEndpoint/*')
global without sharing class NMSEndpointWebhook {
    private static String NBSP = '&nbsp;<br/>';

    @HttpPost
    global static String handleAlert(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        return run(req, res);
    }

    @HttpGet
    global static String handleAlertGET(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        return run(req, res);
    }

    private static String run(RestRequest req, RestResponse res) {
        Boolean suppressCreatingAlert = false;
        CreateErrorRecord er = new CreateErrorRecord();

        String result = 'failure';
        NMS_Alert__c alert = new NMS_Alert__c();
        MistWrapper mistWrap;
        MistWrapper additionalDetails;
        String requestBodyString = NULL;
        String requestBodyToStore = '';
        String requestHeaderToStore = '';
        //NMSJSONWrappers.WrapperClass jsonWrapper;

        alert.Last_Time_Alert_Recieved__c = System.now();
        alert.Increment_Alert_Count__c = true;
        alert.Status__c = 'Open';

        try {
            Map<String, String> inputParams = new Map<String, String>();
            
            System.debug('req.params = ' + req.params);
            if (!req.params.isEmpty()) {
                alert.Source_Content_Type__c = 'Request Parameters';
                requestBodyString = req.params.toString();

                //Clean those stupid new line characters out of the Solarwinds key values
                for (String key : req.params.keySet()) {
                    requestBodyToStore += key + ' = ' + req.params.get(key) + NBSP;

                    if (key != NULL && key.contains('\n')) {
                        inputParams.put(key.replace('\n', ''), req.params.get(key));
                    } else {
                        inputParams.put(key, req.params.get(key));
                    }
                }
            }

            if (req.requestBody != NULL && req.requestBody.size() > 0) {
                alert.Source_Content_Type__c = 'JSON';
                System.debug('req.requestBody.toString() = ' + req.requestBody.toString());
                
                try {
                    requestBodyString = req.requestBody.toString();
                    Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestBodyString);
                    //https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm#apex_System_Json_deserializeUntyped

                    //Object ob = JSON.deserializeUntyped(requestBodyString);
                    // See if an object
                    //Map<String, Object> params = (Map<String, Object>) ob;
                    for (String key : params.keyset()) {
                        /*if (key.equals('events')) {
                            Map<String, Object> evts = (Map<String, Object>)params.get(key);
                            if (evts != NULL && evts.size() > 0) {
                                for (String e : evts.keyset()) {
                                    inputParams.put(e, (String)evts.get(e));
                                }
                            }
                        } else {*/
                            inputParams.put(key, (String)params.get(key).toString());
                        //}
                    }
                } catch (Exception e) {
                    System.debug(e);
                    er.create('NMSEndpointWebhook', alert.Id, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString() + ' | ' + req.requestBody.toString() + ' | ' + req.params, false, false);
                }
            }
            
            try {
                if (req.headers != NULL) {
                    for (String key : req.headers.keySet()) {
                        requestHeaderToStore += key + ' = ' + req.headers.get(key) + NBSP;
                    }

                    alert.Headers__c = requestHeaderToStore;
                }

                if (alert.Headers__c != NULL && alert.Headers__c.contains('Mist-webhook')) {
                    alert.Source__c = 'Mist';

                    try {
                        mistWrap = (MistWrapper) System.JSON.deserialize(req.requestBody.toString(), MistWrapper.class);
                    } catch (Exception e) {
                        System.debug(e);
                        er.create('NMSEndpointWebhook', alert.Id, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                    }
                } else if (alert.Headers__c != NULL && alert.Headers__c.contains('Palo-Seb')) {
                    alert.Source__c = 'Palo Alto';
                }
            } catch (Exception e) {
                System.debug(e);
                er.create('NMSEndpointWebhook', alert.Id, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
            }

            if (inputParams != NULL && inputParams.size() > 0) {
                alert.AlertType__c = 'Interface';
                //alert.Input_Parameters__c = JSON.serialize(inputParams);
                alert.Input_Parameters__c = requestBodyString;
                

                //https://www.solarwinds.com/documentation/en/flarehelp/orionplatform/content/core-general-alert-variables-sw1121.htm

                try {
                    for (String key : inputParams.keySet()) {
                        requestBodyToStore += key + ' = ' + inputParams.get(key) + NBSP;

                        if (alert.Source__c == NULL && key.equalsIgnoreCase('source')) {
                            alert.Source__c = inputParams.get(key);
                        }
                        
                        if (key.equalsIgnoreCase('organizationUrl')) {
                            if (alert.Source__c == NULL && inputParams.get(key).contains('meraki')) {
                                alert.Source__c = 'Meraki';
                            }
                        }

                        if (key.equalsIgnoreCase('AlertMessage') || key.equalsIgnoreCase('description') || key.equalsIgnoreCase('topic')) {
                            alert.Message__c = inputParams.get(key);

                            if (alert.Message__c != NULL) {
                                alert.Message__c = alert.Message__c.replace('${N=SwisEntity;M=Engine.DisplayName}', '');
                            }
                        }
                        
                        if (key.equalsIgnoreCase('AlertType__c') || key.equalsIgnoreCase('alertType') || key.equalsIgnoreCase('type') || key.equalsIgnoreCase('topic')) {
                            alert.AlertType__c = inputParams.get(key);
                        }

                        if (key.equalsIgnoreCase('ipAddress') || key.equalsIgnoreCase('IP') || key.equalsIgnoreCase('client_ip')) {
                            if (!inputParams.get(key).contains('${N=')) {
                                alert.IP_Address__c = inputParams.get(key);
                            }
                        }
                        
                        if (key.equalsIgnoreCase('NodeName') || key.equalsIgnoreCase('networkId') || key.equalsIgnoreCase('site_name')) {
                            alert.Device_ID__c = inputParams.get(key);
                            if (alert.Device_ID__c != NULL) {
                                alert.Device_ID__c = alert.Device_ID__c.replace('Â', '');
                                alert.Device_ID__c = alert.Device_ID__c.replace('Ã', '');
                            }
                        }

                        if (key.equalsIgnoreCase('InterfaceName') || key.equalsIgnoreCase('ap_name')) {
                            alert.Interface_ID__c = inputParams.get(key);
                            if (alert.Interface_ID__c != NULL) {
                                alert.Interface_ID__c = alert.Interface_ID__c.replace('Â', '');
                                alert.Interface_ID__c = alert.Interface_ID__c.replace('Ã', '');
                            }
                        }
                        
                        if ((key.equalsIgnoreCase('alias') || key.equalsIgnoreCase('AlertID') || key.equalsIgnoreCase('id')) && alert.Identifier__c == NULL) {
                            alert.Identifier__c = inputParams.get(key);
                        }

                        if (key.equalsIgnoreCase('AlertDetailsUrl') || key.equalsIgnoreCase('networkUrl') || key.equalsIgnoreCase('url')) {
                            alert.Alert_URL__c = inputParams.get(key);
                        }

                        if (key.equalsIgnoreCase('AcknowledgeUrl')) {
                            alert.Acknowledge_URL__c = inputParams.get(key);
                        }

                        if (key.equalsIgnoreCase('ServiceID') || key.equalsIgnoreCase('CircuitID')) {
                            if (!inputParams.get(key).contains('${N=')) {
                                alert.Service_ID__c = inputParams.get(key);
                            }
                        }

                        if (key.equalsIgnoreCase('ActionType') || key.equalsIgnoreCase('\nActionType')) {
                            if (inputParams.get(key).contains('Close')) {
                                alert.Status__c = 'Closed';
                                alert.Closed_By_NMS__c = TRUE;
                                alert.ClosedDate__c = System.now();

                                //alert ticket that this is closed
                            }
                        }

                        /*if (key.equalsIgnoreCase('events')) {
                            jsonWrapper = (NMSJSONWrappers.WrapperClass) System.JSON.deserialize(res.responseBody.toString(), NMSJSONWrappers.WrapperClass.class);
                        }*/
                    }

                    if (mistWrap != NULL) {
                        System.debug(mistWrap);
                        System.debug('mistWrap.topic = ' + mistWrap.topic);
                        System.debug('mistWrap.events = ' + mistWrap.events);
                        System.debug(mistWrap);

                        if (mistWrap.topic != NULL && mistWrap.topic.equals('audits')) {
                            System.debug('audit message');
                            alert.Message__c = 'Mist Audit Alert: ' + mistWrap.events.get(0).message;
                        } else if (mistWrap.events != NULL && mistWrap.events.size() > 0 && (mistWrap.events.get(0).switches != NULL) || (mistWrap.events.get(0).device_type != NULL && mistWrap.events.get(0).device_type.equals('switch'))) {
                            System.debug('switch message');
                            alert.Message__c = 'Mist Switch Alert: ' + mistWrap.events.get(0).type + ' at ' + mistWrap.events.get(0).site_name;
                        } else if (mistWrap.events != NULL && mistWrap.events.size() > 0 && (mistWrap.events.get(0).aps != NULL) || (mistWrap.events.get(0).device_type != NULL  && mistWrap.events.get(0).device_type.equals('ap'))) {
                            System.debug('ap message');
                            alert.Message__c = 'Mist AP Alert: ' + mistWrap.events.get(0).type + ' at ' + mistWrap.events.get(0).site_name;
                            
                            if (mistWrap.events.get(0).mac != NULL) {
                                additionalDetails = MistAPI.makeCallout(mistWrap.events.get(0).site_id, mistWrap.events.get(0).mac, mistWrap.events.get(0).site_name);
                            }

                            if (additionalDetails != NULL) {
                                alert.Message__c = 'Mist AP Alert: ';

                                if (additionalDetails.results != NULL && additionalDetails.results.size() > 0) {
                                    alert.IP_Address__c = additionalDetails.results.get(0).ip;
                                    alert.Device_ID__c = additionalDetails.results.get(0).last_hostname;
                                    alert.Interface_ID__c = 'MAC: ' + additionalDetails.results.get(0).mac;
                                    alert.Message__c += additionalDetails.results.get(0).last_hostname + ' is ';
                                }
                                
                                alert.Message__c += mistWrap.events.get(0).type + ' at ' + mistWrap.events.get(0).site_name;
                            } else {
                                alert.Secondary_Callout_Failed__c = true;
                            }
                        } else {
                            System.debug('else hit');
                            suppressCreatingAlert = true;
                            alert.Message__c = 'Mist Alert: ';
                        }
                        
                        if (Disabled_Triggers__c.getValues('NMSMistAllowExtras') != null && Disabled_Triggers__c.getValues('NMSMistAllowExtras').Disabled__c == false) {
                            suppressCreatingAlert = false;
                        }

                        if (!suppressCreatingAlert) {
                            alert.Identifier__c = mistWrap.events.get(0).id;

                            alert.Alert_URL__c = 'https://manage.mist.com/admin/?org_id=' + mistWrap.events.get(0).org_id;
                        }
                    }
                } catch (Exception e) {
                    System.debug(e);
                    er.create('NMSEndpointWebhook', alert.Id, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                }
            }

            /*if (jsonWrapper != NULL) {
                alert.Source_Content_Type__c = 'JSON Wrapper Class';

                if (jsonWrapper.events != NULL) {
                    alert.IP_Address__c = jsonWrapper.events.get(0).client_ip;
                }
            }*/
            
            if (alert.Identifier__c != NULL && alert.Source__c != NULL) {
                alert.Identifier__c = alert.Identifier__c + ' | ' + alert.Source__c;
            }
            
            if (alert.Identifier__c != NULL) {
                alert.Identifier__c = alert.Identifier__c + ' | ' + System.today().format();
            }

            String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
            prefix = prefix.removeEnd('--c');

            if (alert.Source__c == NULL) {
                alert.Source__c = 'Unknown';
            }
            
            if (suppressCreatingAlert) {
                result = 'Suppressed';
            } else {
                if (alert.Identifier__c != NULL && alert.Source__c != 'Postman' && alert.Source__c != 'General Notification') {
                    Boolean isUpsertfirstTime = true;
                    
                    NMS_Alert__c[] existingAlert = [SELECT ID FROM NMS_Alert__c WHERE Identifier__c = :alert.Identifier__c LIMIT 1];

                    upsert alert Identifier__c;
                    
                    if (existingAlert == NULL || existingAlert.size() == 0) {
                        publishPlatformEvent(alert);
                    }
                } else {
                    insert alert;

                    publishPlatformEvent(alert);
                }

                //Store input parameters in history
                if (alert.Id != NULL) {
                    try {
                        if (alert.Source__c != NULL && alert.Source__c.equals('Unknown')) {
                            er.create('NMSEndpointWebhook', alert.Id, 'Unknown NMS Alert Source', null, null, null, false, true);
                        }

                        NMS_Alert_Payload__c instance = new NMS_Alert_Payload__c();
                        instance.NMS_Alert__c = alert.Id;
                        instance.Input_Parameters__c = requestBodyToStore;
                        instance.Headers__c = requestHeaderToStore;
                        instance.RestRequest__c = req.toString();
                        
                        if (mistWrap != NULL) {
                            instance.Input_Parameters__c = mistWrap.toString();
                        }

                        if (additionalDetails != NULL) {
                            instance.Input_Parameters__c += NBSP + NBSP + additionalDetails.toString();
                        }

                        insert instance;
                    } catch (Exception e) {
                        System.debug(e);
                        er.create('NMSEndpointWebhook', alert.Id, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                    }
                }

                result = 'Success';
            }
        } catch (Exception e) {
            System.debug(e);
            er.create('NMSEndpointWebhook', alert.Id, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
        }

        return result;
    }

    public static void publishPlatformEvent(NMS_Alert__c alert) {
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
        
        if (pe.URL__c != NULL && pe.URL__c.contains('support.')) {
            pe.URL__c = pe.URL__c.replace('support.', 'everstream.');
        }
        
        Database.SaveResult sr = EventBus.publish(pe);
    }
}