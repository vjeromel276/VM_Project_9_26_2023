import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

export default class VisionMetrixTab extends LightningElement {
    @api recordId;
    @api caseNumber;
    @track caseData;
    @track acctId;
    @track acctName;
    @api caseSubject;
    hasCase;
    @api hasVMAcct=false;
    isVMChildTkt;
    hasVMTkt;
    isVMParentTkt;
    parentTicket;
    vmAccts = [ "ATT Wireless", "T-Mobile" ];
    fields = [
        'Case.CaseNumber',
        'Case.AccountId',
        'Case.hasVisionMetrixTicket__c',
        'Case.Account_Name_Text__c',
        'Case.Subject',
        'Case.VisionMetrix_Child_Case__c',
        'Case.Related_Service_Order__c',
        "Case.VisionMetrix_Parent_Case__c",
        'Case.ParentId',
    ];
    
    @wire( getRecord, { recordId: '$recordId', fields: '$fields' } )
    wiredRecord( { error, data } ) {
        if ( error ) {
            console.log( error );
        } else if ( data ) {
            console.log( data );
            this.hasCase = true;
            this.caseData = data;
            this.parentTicket = data.fields.ParentId.value;
            this.acctId = data.fields.AccountId.value;
            this.acctName = data.fields.Account_Name_Text__c.value;
            this.caseNumber = data.fields.CaseNumber.value;
            this.isVMChildTkt = data.fields.VisionMetrix_Child_Case__c.value;
            this.caseSubject = data.fields.Subject.value;
            this.relatedSOF = data.fields.Related_Service_Order__c.value;
            this.hasVMTkt = data.fields.hasVisionMetrixTicket__c.value;
            this.isVMParentTkt = data.fields.VisionMetrix_Parent_Case__c.value;
        }
        console.log( 'acctId: ' + this.acctId );
        console.log( 'acctName: ' + this.acctName );
        console.log( 'caseNumber: ' + this.caseNumber );
        console.log( 'isVMChildTkt: ' + this.isVMChildTkt );
        console.log( 'caseSubject: ' + this.caseSubject );
        console.log( 'relatedSOF: ' + this.relatedSOF );
        console.log( 'hasVMTkt: ' + this.hasVMTkt );
        console.log( 'isVMParentTkt: ' + this.isVMParentTkt );
        console.log( 'hasCase: ' + this.hasCase );
        console.log( 'hasVMAcct: ' + this.hasVMAcct );
        console.log( 'parent ticket data: ' + this.parentTicket );

        if( this.acctName && this.vmAccts.includes( this.acctName ) ) {
            this.hasVMAcct = true;
            console.log( 'Has VM Assc Acct: ' + this.hasVMAcct );
        }
    }   
}