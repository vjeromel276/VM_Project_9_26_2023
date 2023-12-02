public with sharing class VisionMetrixCalloutAddBulkVMTicketMock implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"success": true,"token":"8bdb863aec0613028a5d1a31ce2b596d94fe3f6f"}');
        
        return res;
    }
}