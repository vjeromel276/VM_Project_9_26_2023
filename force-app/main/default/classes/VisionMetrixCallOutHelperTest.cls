@isTest
public with sharing class VisionMetrixCallOutHelperTest {

    @IsTest
    public static void calloutHelperTest() {
        VisionMetrixCallOutHelper.logAPICallout('endpoint', 'request', 'response') ;
    }
}