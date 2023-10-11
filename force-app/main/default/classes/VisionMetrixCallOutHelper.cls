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
    public VisionMetrixCallOutHelper() {
    }
    
    public void parseCSV(Blob csvFile){
        List<Map<String, String>> records = new List<Map<String, String>>();
        List<String> lines = csvFile.toString().split('\n');
        Map<String, String> record = new Map<String, String>();
        for(String line : lines){
            List<String> fields = line.split(',');  
            if(!fields.isEmpty()){
                record.put(fields[0], fields[1]);
                if(fields.size()==3){
                    record.put(fields[2], fields[2]);
                }
            }
            records.add(record);
        }
    }

}