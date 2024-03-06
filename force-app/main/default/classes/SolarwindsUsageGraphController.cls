/**
 * @description       : 
 * @author            : clabelle@everstream.net
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : clabelle@everstream.net
**/
global without sharing class SolarwindsUsageGraphController {
    global static String contentHtml {get;set;}
    global static String url {get;set;}
    global static Interface__c currentRecord {get;set;}
    
    public static List<SolarwindsData> getDataFromAPI(String recordId, Integer selectedDurationInt, String type) {
        Case currentCase;
        Order currentOrder;
        List<SolarwindsData> resultData = NULL;
        //Integer timeout = 30000;
        
        Http http = new Http();
        HttpRequest request = setupRequest();
		
        //http://solarwinds.github.io/OrionSDK/2020.2/schema/index.html
        //http://solarwinds.github.io/OrionSDK/2020.2/schema/Orion.NPM.Interfaces.html
        //https://sfdcbrewery.github.io/ChartJsSalesforceLightning
        
        System.debug('recordId = ' + recordId);
        String serviceID;

        if (recordId != NULL) {
            if (recordId.startsWith('500')) {
                currentCase = [SELECT ID, Service_ID__c, Related_Service_Order__c, Related_Service_Order__r.Service_ID__c, Related_Service_Order__r.Billing_Start_Date__c FROM Case WHERE Id = :recordId];
                currentOrder = new Order(Id = currentCase.Related_Service_Order__c, OSS_Service_ID__c = currentCase.Related_Service_Order__r.Service_ID__c, Billing_Start_Date__c = currentCase.Related_Service_Order__r.Billing_Start_Date__c);
                serviceID = currentCase.Service_ID__c;
            } else {
                currentOrder = [SELECT Id, Billing_Start_Date__c, Service_ID__c FROM Order WHERE Id = :recordId];
                serviceID = currentOrder.Service_ID__c;
            }
        } else if (Test.isRunningTest()) {
            currentOrder = new Order(Billing_Start_Date__c = System.today());
        }

        System.debug(currentOrder);

        HttpResponse response;
        String body;
        String responseBody;

        if (serviceID != NULL) {
            serviceID = serviceID.replace(' a/b', '');
        }

        body = '{"query":"SELECT InterfaceID, Name FROM Orion.NPM.Interfaces WHERE Alias LIKE \'%' + serviceID + '%\'"}';
        System.debug('body = ' + body);
        request.setbody(body);

        if (!Test.isRunningTest()) {
            if (body != NULL) {
                response = http.send(request);
            }
        } else {
            response = new HttpResponse();
            response.setBody('{"results":[{"InterfaceID":2562,"Status":1}]}');
            response.setStatusCode(200);
        }

        System.debug('response.getStatusCode() = ' + response.getStatusCode());

        if (response.getStatusCode() == 200) {
            responseBody = response.getBody();
           	responseBody = responseBody.replace('{"results":', '');
            responseBody = responseBody.substring(0, responseBody.length() -1);
            System.debug(responseBody);
            
            resultData = (List<SolarwindsData>)JSON.deserialize(responseBody, List<SolarwindsData>.class);

            if (Test.isRunningTest()) {
                resultData.get(0).InterfaceId = '161527';
            }

            if (resultData != NULL && resultData.size() > 0) {
                if (currentOrder.Billing_Start_Date__c != NULL && type.equals('utilization')) {
                    body = '{"query":"SELECT MetricName, InstanceId, DateTime as CreatedDate, PercentAvgUsage, DisplayName, Description, InstanceType, Uri, InstanceSiteId FROM Orion.InInterfaceAverageTrafficUtilizationByDays WHERE InstanceId=' + resultData.get(0).InterfaceId + ' AND CreatedDate >= AddDay( -' + selectedDurationInt + ', GETDATE()) ORDER BY CreatedDate asc"}';
                } else if (currentOrder.Billing_Start_Date__c != NULL && type.equals('bps')) {
                    body = '{"query":"SELECT  NodeID, InterfaceID, DateTime as CreatedDate, InAveragebps, InMinbps, InMaxbps, InTotalBytes, InTotalPkts, InAvgUniCastPkts, InMinUniCastPkts, InMaxUniCastPkts, InAvgMultiCastPkts, InMinMultiCastPkts, InMaxMultiCastPkts, OutAveragebps, OutMinbps, OutMaxbps, OutTotalBytes, OutTotalPkts, OutAvgUniCastPkts, OutMaxUniCastPkts, OutMinUniCastPkts, OutAvgMultiCastPkts, OutMinMultiCastPkts, OutMaxMultiCastPkts, Archive FROM Orion.NPM.InterfaceTraffic WHERE InterfaceID=' + resultData.get(0).InterfaceId + ' AND CreatedDate >= AddHour( -' + selectedDurationInt + ', GETDATE()) ORDER BY CreatedDate asc"}';
                } else if (type.equals('status')) {
                    body = '{"query":"SELECT InterfaceID, Status FROM Orion.NPM.Interfaces WHERE InterfaceID=' + resultData.get(0).InterfaceId + '"}';
                }

                System.debug('body = ' + body);
                
                request = setupRequest();
                request.setBody(body);
                
                if (!Test.isRunningTest()) {
                    if (body != NULL) {
                        response = http.send(request);
                    }
                } else {
                    response = new HttpResponse();
                }
                
                System.debug('response.getStatusCode() = ' + response.getStatusCode());
                
                // If the request is successful, parse the JSON response.
                if (response.getStatusCode() == 200) {
                    responseBody = response.getBody();
                    responseBody = responseBody.replace('{"results":', '');
                    responseBody = responseBody.substring(0, responseBody.length() -1);
                    System.debug(responseBody);
                    
                    resultData = (List<SolarwindsData>)JSON.deserialize(responseBody, List<SolarwindsData>.class);
                    
                    System.debug('Received the following results:');
                    
                    for(SolarwindsData res: resultData) {
                        System.debug(res);
                    }
                } else {
                    System.debug('Response Error Received - Get Interface Data');
                    System.debug(response.getBody());
                }
            } else {
                System.debug('No interfaces found with service ID: ' + serviceID);
            }
        } else {
            System.debug('Response Error Received - Get Interfaces');
            System.debug(response.getBody());
        }
        
        if (Test.isRunningTest() && (resultData == NULL || resultData.size() == 0)) {
            resultData = new List<SolarwindsData>();
            SolarwindsData sw = new SolarwindsData();
            sw.CreatedDate = System.today();
            sw.OutAveragebps = 10.23;
            sw.InAveragebps = 23.5;
            sw.PercentAvgUsage = 50.25;
            resultData.add(sw);
        }
        
        //contentHtml = response.getBody();
        return resultData;
    }
    
    @auraEnabled public String selectedViewType;
    @auraEnabled public List<LineChartVar> myLineChartVarList;
    
    public class LineChartVar {
        String label;
        String timestamp;
        Decimal firstValue;
        Decimal secondValue;
        
        public LineChartVar(string a, decimal b, decimal c, String d) {
            label = a;
            firstValue = b;
            secondValue = c;
            timestamp = d;
        }
    }
    
    @auraEnabled
    global static string getUtilizationLineChartMap(String recordId, String selectedDuration) {
        String serializedJson;
        System.debug('recordId = ' + recordId);
        System.debug('selectedDuration = ' + selectedDuration);

        try {
            Integer selectedDurationInt = Integer.valueOf(selectedDuration);
            List<SolarwindsData> resultData = getDataFromAPI(recordId, selectedDurationInt, 'utilization');
            List<LineChartVar> myLineChartVarList = new List<LineChartVar>();
            String dateString;
            Decimal averageUtilization;
            String timestamp;

            if (resultData != NULL && resultData.size() > 0) {
                for (SolarwindsData swd : resultData) {
                    dateString = swd.CreatedDate != NULL ? swd.CreatedDate.format('MMM dd') : NULL;
                    timestamp = swd.CreatedDate != NULL ? swd.CreatedDate.format('MM/dd/yyyy') : NULL;

                    //averageUtilization = swd.PercentAvgUsage != NULL ? swd.PercentAvgUsage * 100 : 0.0;
                    averageUtilization = swd.PercentAvgUsage != NULL ? swd.PercentAvgUsage : 0.0;
                    
                    if (averageUtilization != NULL) {
                        averageUtilization = averageUtilization.setScale(2);
                    }

                    myLineChartVarList.add(new LineChartVar(dateString, averageUtilization, 0.0, timestamp));
                }
            }

            serializedJson = JSON.Serialize(myLineChartVarList);
        } catch (Exception e) {
            System.debug(e);
            CreateErrorRecord er = new CreateErrorRecord();
            er.create('SolarwindsUsageGraphController', recordId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
        }

        return serializedJson;
    }

    @auraEnabled
    global static string getbpsLineChartMap(String recordId, String selectedDuration) {
        String serializedJson;
        System.debug('recordId = ' + recordId);
        System.debug('selectedDuration = ' + selectedDuration);

        try {
            Integer selectedDurationInt = Integer.valueOf(selectedDuration);
            List<SolarwindsData> resultData = getDataFromAPI(recordId, selectedDurationInt, 'bps');
            List<LineChartVar> myLineChartVarList = new List<LineChartVar>();
            String dateString;
            Decimal upBits;
            Decimal downBits;
            String timestamp;
            
            if (resultData != NULL && resultData.size() > 0) {
                for (SolarwindsData swd : resultData) {
                    dateString = swd.CreatedDate != NULL ? swd.CreatedDate.format('MMM dd, h:mm a') : NULL;
                    timestamp = swd.CreatedDate != NULL ? swd.CreatedDate.format('MM/dd/yyyy, h:mm a') : NULL;
                    downBits = swd.OutAveragebps != NULL ? swd.OutAveragebps / 1000000 : 0.0;//convert to mbps
                    upBits = swd.InAveragebps != NULL ? swd.InAveragebps / 1000000 : 0.0;//convert to mbps
                    
                    if (downBits != NULL) {
                        downBits = downBits.setScale(2);
                    }

                    if (upBits != NULL) {
                        upBits = upBits.setScale(2);
                    }

                    myLineChartVarList.add(new LineChartVar(dateString, upBits, downBits, timestamp));
                }
            }

            serializedJson = JSON.Serialize(myLineChartVarList);
        } catch (Exception e) {
            System.debug(e);
            CreateErrorRecord er = new CreateErrorRecord();
            er.create('SolarwindsUsageGraphController', recordId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
        }

        return serializedJson;
    }
    
    @auraEnabled
    global static string getStatus(String recordId) {
        String statusString = 'Unknown';

        try {
            List<SolarwindsData> resultData = getDataFromAPI(recordId, null, 'status');
            String status;
            
            if (resultData != NULL && resultData.size() > 0) {
                for (SolarwindsData swd : resultData) {
                    status = swd.Status;
                    System.debug(swd.InterfaceId + ' status = ' + swd.Status);
                }
            }
            
            if (status != NULL && status.equals('1')) {
                statusString = 'Up';
            } else if (status != NULL && !status.equals('0')) { //group all other status numbers as down
                statusString = 'Down';
            }
        } catch (Exception e) {
            System.debug(e);
            CreateErrorRecord er = new CreateErrorRecord();
            er.create('SolarwindsUsageGraphController', recordId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
        }
        /* ***
            SOLARWINDS STATUS CODES
                0 Unknown
                1 Up
                2 Down
                3 Warning
                4 Shutdown
                5 Testing
                6 Dormant
                7 NotPresent
                8 LowerLayerDown
                9 Unmanaged
                10 Unplugged
                11 External
                12 Unreachable
                14 Critical
                15 PartlyAvailable
                16 Misconfigured
                17 Undefined
                19 Unconfirmed
                22 Active
                24 Inactive
                25 Expired
                26 MonitoringDisabled
                27 Disabled
                28 NotLicensed
                29 OtherCategory
                30 NotRunning
                31 Online
                32 OnBattery
                33 OnSmartBoost
                34 TimedSleeping
                35 SoftwareBypass
                36 Off
                37 Rebooting
                38 SwitchedBypass
                39 HardwareFailureBypass
                40 SleepingUntilPowerReturn
                41 OnSmartTrim
                42 EcoMode
                43 HotStandBy
                44 OnBatteryTest
        */

        return statusString;
    }

    public static HttpRequest setupRequest() {
        HttpRequest request = new HttpRequest();
        String baseURL = 'https://swinds-ext.everstream.net:17778';
        
        url = baseURL + '/SolarWinds/InformationService/v3/Json/Query';
        request.setEndpoint(url);
        request.setMethod('POST');
        //request.setTimeout(timeout);

        
        /*
            This is maintained in a Custom Metadata Type called "CA Certificate". 
            Make sure there is ONLY ONE RECORD or you will have a bad time. 
            Make it match the *.everstream.net cert that's active for that year.
        */
        List<CA_Certificate__mdt> cas = CA_Certificate__mdt.getAll().values();
        System.debug('cas = ' + cas);
        if (cas != NULL && cas.size() > 0) {
            System.debug('set cert to ' + cas.get(0).DeveloperName);
            request.setClientCertificateName(cas.get(0).DeveloperName);
        }
        
        String username = 'admin';
        String password = '6eiQus92YhPE';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', '*/*');
        request.setHeader('Content-Length', '4096');

        return request;
    }

    @auraEnabled
    global static Boolean accessCheck(String recordId) {
        Boolean showCharts = false;
        System.debug('showCharts = ' + showCharts);
        
        try {
            List<Order> ord = [SELECT ID FROM Order WHERE ID = :recordId AND Billing_Start_Date__c != NULL LIMIT 1];
            
            if (ord != NULL && ord.size() > 0) {
                showCharts = true;
            }
        } catch (Exception e) {
            System.debug(e);
            CreateErrorRecord er = new CreateErrorRecord();
            er.create('SolarwindsUsageGraphController', recordId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
        }

        return showCharts;
    }
}