public with sharing class VisionMetrixEventController{
    @AuraEnabled(cacheable = true)
    public static List<VisionMetrix_Event__c> getVisionMetrixEvents(){
        return [SELECT Id, Name, VLAN__c, Start_Time__c, Severity__c, Service_Order_Agreement__c, Ring_Name__c, Ring__c, Node_Name__c, Node_formula__c, Node__c, KPI__c, Event_Name__c
                FROM VisionMetrix_Event__c
                LIMIT 100];
    }

    @AuraEnabled(cacheable = true)
    public static List<VisionMetrix_Event__c> getRelatedEvents(Id serviceOrderAgreementId){
        return [SELECT Id, Event_Name__c, VLAN__c, Start_Time__c, Severity__c
                FROM VisionMetrix_Event__c
                WHERE Service_Order_Agreement__c = :serviceOrderAgreementId];
    }

    @AuraEnabled(cacheable = true)
    public static List<Node__c> getRelatedNodes(String caseId){
        return [SELECT Id, Name, Service_ID__c, Node_Name_Link__c, Ring__r.Name, Ring__r.Project_Name__c, Vendor_Value__c, VisionMetrix_Circuit_Id__c
                FROM Node__c];
                
    }

    @AuraEnabled(cacheable = true)
    public static List<Node__c> getAllNodes(){
        return [SELECT Id, Name, Service_ID__c, Node_Name_Link__c, Ring__r.Name, Ring__r.Project_Name__c, Vendor_Value__c, VisionMetrix_Circuit_Id__c
                FROM Node__c];
    }

    @AuraEnabled
    public static Case getCaseId(String recordId){
        Case c = [SELECT Id, CaseNumber, hasVisionMetrixTicket__c, CreatedDate, Subject
                  FROM Case
                  WHERE Id = :recordId
                  LIMIT 1];
        return c;
    }

    @AuraEnabled
    public static void updateNode(String recordId, List<Node__c> nodes){
        //~ node id aEt3g000000XZNkCAO, aEt6g000000015CCAQ
        //~ CaseId 5003J000009auYRQAY
        List<Node__c> nodesToUpdate = new List<Node__c>();
        Node__c n = new Node__c();
        System.debug('nodes: ' + nodes);
        for (Node__c node : nodes){
            n = [SELECT Id, Name, Service_ID__c, Node_Name_Link__c, Ring__r.Name, Ring__r.Project_Name__c, VisionMetrix_Circuit_Id__c
                 FROM Node__c
                 where Id = :node.Id
                 LIMIT 1];
            // n.Support_Ticket__c = recordId;
            // System.debug('Support ticket: ' + n.Support_Ticket__c);
            nodesToUpdate.add(n);
        }
        update nodesToUpdate;
    }

    @AuraEnabled
    public static void updateNodeById(String recordId, List<Id> nodes){
        //~ node id aEt3g000000XZNkCAO, aEt6g000000015CCAQ
        //~ CaseId 5003J000009auYRQAY
        System.debug('nodes: ' + nodes);
        List<Node__c> nodesToUpdate = new List<Node__c>();
        Node__c n = new Node__c();
        // deserialize nodes to list of Ids
        // List<Id> nodeIds = (List<Id>)JSON.deserialize(JSON.serialize(nodes), List<Id>.class);
        for (Id node : nodes){
            System.debug('node: ' + node);
            n = [SELECT Id, Name, Service_ID__c, Node_Name_Link__c, Ring__r.Name, Ring__r.Project_Name__c, VisionMetrix_Circuit_Id__c
                 FROM Node__c
                 where Id = :node
                 LIMIT 1];
            // n.Support_Ticket__c = recordId;
            // System.debug('Support ticket: ' + n.Support_Ticket__c);
            nodesToUpdate.add(n);
        }
        update nodesToUpdate;
    }

    @AuraEnabled
    public static void practiceMethod(String recordId, String strVar){
        System.debug('str: ' + strVar);
        Id[] strList = strVar.split(',');
        List<Node__c> nodesToUpdate = new List<Node__c>();
        Node__c n = new Node__c();
        // deserialize nodes to list of Ids
        // List<Id> nodeIds = (List<Id>)JSON.deserialize(strVar, List<Id>.class);
        for (Id node : strList){
            System.debug('node: ' + node);
            n = [SELECT Id, Name, Service_ID__c, Node_Name_Link__c, Ring__r.Name, Ring__r.Project_Name__c
                 FROM Node__c
                 where Id = :node
                 LIMIT 1];
            // n.Support_Ticket__c = recordId;
            // System.debug('Support ticket: ' + n.Support_Ticket__c);
            nodesToUpdate.add(n);
        }
        update nodesToUpdate;
    }

}