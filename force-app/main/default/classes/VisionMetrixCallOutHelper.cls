/**
 * @name              : VisionMetrixCallOutHelper
 * @description       : this is for any methods that need to be called out to VisionMetrixCallOut
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 10-11-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 10-11-2023
 **/
public with sharing class VisionMetrixCallOutHelper {
    /**
     * parseCSV()
     *
     * This method will parse a CSV file and return a list of maps
     *
     * @param csvFile - Blob - the csv file to parse
     * @return List<Map<String, String>> - the list of maps
     */
    public static void parseCSV(Blob csvFile) {
        List<Map<String, String>> records = new List<Map<String, String>>();
        List<String> lines = csvFile.toString().split('\n');
        Map<String, String> record = new Map<String, String>();
        for ( String line : lines ) {
            List<String> fields = line.split(',');
            System.debug('fields: ' + fields);
            if ( !fields.isEmpty() ) {

                record.put(fields[0], fields[1]);
                if ( fields.size() == 3 ) {
                    record.put(fields[2], fields[2]);
                }
            }
            records.add(record);
        }
    }

    /**
     * runParseCSV()
     *
     * This method will run the parseCSV method in this class
     * will import testCKTS.csv
     * from C:\DeskTopCleanUP_1_1_23\Everstream_Salesforce_ENV\VM_Project_9_26_2023\force-app\main\default\data\csvdata\testCKTs.csv
     *
     */
    public static void runParseCSV() {
        parseCSV(Blob.valueOf('testCKTs.csv'));
    }

    /**
     * makeVisionMetrixPayloadTextFile()
     *
     * This method will call out to VisionMetrix and return the response
     *
     * @param payload - String - the url to call out to
     * @param endpoint - String - the endpoint to call out to
     *
     *
     */
    public static void logAPICallout(String endpoint, String request, String response) {
        Callout_Log__c log = new Callout_Log__c();
        log.Endpoint__c = endpoint.deleteWhitespace().trim();
        log.Payload__c = request.deleteWhitespace().trim();
        log.Response__c = response.deleteWhitespace().trim();
        insert log; // Handle exceptions as appropriate
    }

}