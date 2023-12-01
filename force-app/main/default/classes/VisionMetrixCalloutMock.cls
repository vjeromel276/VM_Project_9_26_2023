/**
 * @name              : VisionMetrixCalloutMock.cls
 * @description       : this class is used to make a mock callout to VisionMetrixCallout.visionMetrixLogin() method
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 12-01-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 12-01-2023
 **/
public class VisionMetrixCalloutMock implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"success": true,"token":"8bdb863aec0613028a5d1a31ce2b596d94fe3f6f"}');
        return res;
    }
}