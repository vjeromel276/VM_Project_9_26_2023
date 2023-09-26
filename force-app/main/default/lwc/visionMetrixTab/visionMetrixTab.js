import { LightningElement, api, track, wire } from 'lwc';

import ACCT_ID_CASE from '@salesforce/schema/Case.AccountId';
import ACCT_NAME_CASE from '@salesforce/schema/Case.Account_Name_Text__c';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import CASE_SUBJECT from '@salesforce/schema/Case.Subject';
import HAS_VM_TKT from '@salesforce/schema/Case.hasVisionMetrixTicket__c';
import IS_VM_PARENT_TKT from '@salesforce/schema/Case.VisionMetrix_Parent_Case__c';
import IS_VM_TKT_CHILD from '@salesforce/schema/Case.VisionMetrix_Child_Case__c';
import RELATED_SOF from '@salesforce/schema/Case.Related_Service_Order__c';
import { getRecord } from 'lightning/uiRecordApi';

export default class VisionMetrixTab extends LightningElement {
    @api recordId;
    @api caseNumber;
    @track caseData;
    @track acctId;
    @track acctName;
    
    hasCase;
    @api hasVMAcct=false;
    isVMChildTkt;
    hasVMParentTkt;
    isVMParentTkt;
    vmAccts = [ "ATT Wireless", "T-Mobile" ];
    fields = [ CASE_NUMBER, ACCT_ID_CASE, HAS_VM_TKT, ACCT_NAME_CASE,CASE_SUBJECT, IS_VM_TKT_CHILD, RELATED_SOF, IS_VM_PARENT_TKT ];
    
    @wire( getRecord, { recordId: '$recordId', fields: '$fields' } )
    wiredRecord( { error, data } ) {
        if ( error ) {
            console.log( error );
        } else if ( data ) {
            console.log( data );
            this.hasCase = true;
            this.caseData = data;
            this.acctId = data.fields.AccountId.value;
            this.acctName = data.fields.Account_Name_Text__c.value;
            this.caseNumber = data.fields.CaseNumber.value;
            this.isVMChildTkt = data.fields.VisionMetrix_Child_Case__c.value;
            this.caseSubject = data.fields.Subject.value;
            this.relatedSOF = data.fields.Related_Service_Order__c.value;
            this.hasVMParentTkt = data.fields.hasVisionMetrixTicket__c.value;
            this.isVMParentTkt = data.fields.VisionMetrix_Parent_Case__c.value;
        }
        console.log( 'acctId: ' + this.acctId );
        console.log( 'acctName: ' + this.acctName );
        console.log( 'caseNumber: ' + this.caseNumber );
        console.log( 'isVMChildTkt: ' + this.isVMChildTkt );
        console.log( 'caseSubject: ' + this.caseSubject );
        console.log( 'relatedSOF: ' + this.relatedSOF );
        console.log( 'hasVMParentTkt: ' + this.hasVMParentTkt );
        console.log( 'isVMParentTkt: ' + this.isVMParentTkt );
        console.log( 'hasCase: ' + this.hasCase );
        console.log( 'hasVMAcct: ' + this.hasVMAcct );
        
        
        const ticketNumber = this.caseNumber;
        if( this.vmAccts.includes( this.acctName )) {
            this.hasVMAcct = true;
            console.log( 'hasVMAcct: ' + this.hasVMAcct );
            if ( this.isVMChildTkt ) {
               // pull vm ticket data
            } else {
                // create vm ticket
                
            }
        }
    }
    
    
}