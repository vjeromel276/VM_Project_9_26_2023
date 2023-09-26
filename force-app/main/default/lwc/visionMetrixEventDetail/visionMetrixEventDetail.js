import { LightningElement, api, track, wire } from 'lwc';

import HAS_VISIONMETRIX_TICKET from '@salesforce/schema/Case.hasVisionMetrixTicket__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addCircuitToVMTicket from '@salesforce/apex/VisionMetrixCallOut.addCircuitToVMTicket';
import addVMTicket from '@salesforce/apex/VisionMetrixCallOut.addVMTicket';
import getAllNodes from '@salesforce/apex/VisionMetrixEventController.getAllNodes';
import getCaseId from '@salesforce/apex/VisionMetrixEventController.getCaseId';
import { refreshApex } from '@salesforce/apex';
import updateNode from '@salesforce/apex/VisionMetrixEventController.updateNode';
import { updateRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    HAS_VISIONMETRIX_TICKET
];

export default class NodeList extends LightningElement {
    @api recordId;
    vmTicketNumber;
    @api buttonLabel;
    @api searchInput = '';
    @api filterValue = '';
    @track allNodes = [];
    @track nodesToAdd = [];
    @track nodes = [];
    @track hasVisionMetrixTicket= false;
    @track areNodesSelected = false;
    @track isSearchActive = false;
    @track selectedRows = [];
    @track selectedNodes = [];
    @track masterNodes = [];
    columns = [
        { label: 'Node Name', fieldName: 'Name' },
        { label: 'Service ID', fieldName: 'Service_ID__c' },
        // { label: 'Vendor From Ring', fieldname: 'Vendor_Value__c' },
    ];
    
    connectedCallback() {
        const thisCaseData = getCaseId( { recordId: this.recordId } );
        thisCaseData.then( result => {
            console.log( 'result: ', result );
            this.hasVisionMetrixTicket = result.hasVisionMetrixTicket__c;
            this.vmTicketNumber = result.CaseNumber;
            console.log( 'has visionmetrix: ' + this.hasVisionMetrixTicket );
            console.log( 'vmTicketNumber: ' + this.vmTicketNumber);
            this.buttonLabel = this.hasVisionMetrixTicket ? 'Add to VM Ticket' : 'Create VM Ticket';
        } )
            .catch( error => {
                console.log( 'error: ', error );
            } );
        
        console.log( 'record id: ' + this.recordId );        
        // Get all nodes from the database
        this.origData = getAllNodes();
        this.origData.then( result => {
            this.allNodes = result.filter( data => {
                if ( data ) {
                    return data;
                } else {
                    return null;
                }
            } );
        } );
    }

    // get isCheckboxDisabled() {
    //     return getFieldValue( this.supportTicket.data, HAS_VISIONMETRIX_TICKET );
    // }
    
    get searchedNodes() {
        return this.filteredNodes.filter( node => node.Name.toLowerCase().includes( this.searchInput.toLowerCase() ) );
    }

    get filteredNodes() {
        return this.allNodes.filter( node => node.Vendor_Value__c === this.filterValue );
    }

    get filterOptions() {
        return [
            { label: 'ATTM Cleveland', value: 'ATTM Cleveland' },
            { label: 'T-Mobile Chicago', value: 'T-Mobile Chicago' },
            { label: 'T-Mobile Cleveland', value: 'T-Mobile Cleveland' },
            { label: 'T-Mobile Columbus', value: 'T-Mobile Columbus' },
            { label: 'T-Mobile Indianapolis', value: 'T-Mobile Indianapolis' },
            { label: 'T-Mobile Michigan', value: 'T-Mobile Michigan' },
            { label: 'T-Mobile St. Louis', value: 'T-Mobile St. Louis' },
            { label: 'T-Mobile West Michigan', value: 'T-Mobile West Michigan' },
            { label: 'TMO Wisconsin RG159', value: 'TMO Wisconsin RG159' },
            { label: 'T-Mobile Wisconsin', value: 'T-Mobile Wisconsin' },
            { label: '(PEG) (UNI) PA Rings', value: '(PEG) (UNI) PA Rings' },
            { label: '(PEG) (UNI) Acquisition', value: '(PEG) (UNI) Acquisition' },
            { label: 'UAM PROJECT (PA)', value: 'UAM PROJECT (PA)' },
            { label: 'Verizon Chicago', value: 'Verizon Chicago' },
            { label: 'Verizon Indianapolis', value: 'Verizon Indianapolis' },
            { label: 'BAU Cleveland', value: 'BAU Cleveland' },
            { label: 'BAU Indianapolis', value: 'BAU Indianapolis' },
            { label: 'BAU INDIANAPOLIS', value: 'BAU INDIANAPOLIS' },
            { label: 'Dish Cleveland', value: 'Dish Cleveland' },
            { label: 'Dish Indianapolis', value: 'Dish Indianapolis' },
            { label: 'DISH INDIANAPOLIS', value: 'DISH INDIANAPOLIS' },
        ];
    }

    handleSearch( event ) {
        this.searchInput = event.target.value;
        this.isSearchActive = !!this.searchInput;
    }

    handleFilter( event ) {
        this.filterValue = event.target.value;
    }

    handleRowSelection( event ) {
        this.selectedRows = event.detail.selectedRows;

        // Merge the newly selected rows with existing selected nodes
        let updatedRecords = [ ...this.selectedNodes, ...this.selectedRows ];

        // Remove duplicates by Id
        let uniqueRecords = Array.from( new Set( updatedRecords.map( r => r.Id ) ) ).map( id => {
            return updatedRecords.find( r => r.Id === id );
        } );

        // Update selectedNodes and log the updated list
        this.selectedNodes = uniqueRecords;
        // console.log('Updated selectedNodes: ', JSON.stringify(this.selectedNodes));
        
    }
    
    addSelectedNodes() {
        if ( !this.hasVisionMetrixTicket ) {            
            var uniqueNodes = [ ...this.masterNodes, ...this.selectedNodes ];
            let uniqueRecords = Array.from( new Set( uniqueNodes.map( r => r.Id ) ) ).map( id => {
                return uniqueNodes.find( r => r.Id === id );
            } );
            this.masterNodes = uniqueRecords;
            this.areNodesSelected = true;
        } else if ( this.hasVisionMetrixTicket ) { 
            var uniqueNodes = [ ...this.nodesToAdd, ...this.selectedNodes ];
            let uniqueRecords = Array.from( new Set( uniqueNodes.map( r => r.Id ) ) ).map( id => {
                return uniqueNodes.find( r => r.Id === id );
            } );
            this.nodesToAdd = uniqueRecords;
            this.areNodesSelected = true;
        }        
        this.selectedNodes = [];
    }

    clearForm() {
        this.masterNodes = [];
    }
    
    addNodesToVMTicket() {

        const ticketNumber = this.recordId;
        const ticketNumber_VM = this.vmTicketNumber;

        if ( !this.hasVisionMetrixTicket || this.masterNodes.length > 0 ) {
            console.log('No Vision Metrix Ticket');
            const nodes = JSON.stringify( JSON.parse( JSON.stringify( this.masterNodes ) ) );
        
            updateNode( { recordId: ticketNumber, nodes: nodes } )
                .then( result => {
                    console.log( 'result: ', 'Success' );
                    const evt = new ShowToastEvent( {
                        title: 'Success!! You DID IT!!',
                        message: 'Nodes Added to Support Ticket',
                        variant: 'success',
                    } );
                    this.dispatchEvent( evt );
                } )
                .catch( error => {
                    console.log( 'error: ', error );
                    const evt = new ShowToastEvent( {
                        title: 'Nodes Not Added to Support Ticket',
                        message: 'If the error persists, please contact your system administrator.',
                        variant: 'error',
                    } );
                    this.dispatchEvent( evt );
                } );
            
            addVMTicket( { ticketId: ticketNumber, isExclusion: true } )
                .then( result => {
                    console.log( 'result: ', 'Success' );
                    this.hasVisionMetrixTicket = true;
                    const evt = new ShowToastEvent( {
                        title: 'Success!! You DID IT!!',
                        message: 'Vision Metrix Ticket Created',
                        variant: 'success',
                    } );
                    this.dispatchEvent( evt );
                } )
                .catch( error => {
                    console.log( 'error: ', error );
                    const evt = new ShowToastEvent( {
                        title: 'Vision Metrix Ticket Creation Failed',
                        message: 'If the error persists, please contact your system administrator.',
                        variant: 'error',
                    } );
                    this.dispatchEvent( evt );
                } );
            this.clearForm();
            this.hasVisionMetrixTicket = true;
            this.searchInput = '';
            this.isSearchActive = false;
            this.filterValue = '';
            this.areNodesSelected = false;

            //~ make a case record to pass to the updateRecord function
            const fields = {};
            fields.Id = ticketNumber;
            fields.hasVisionMetrixTicket__c = true;
            const recordInput = { fields };
            //~ update the record to set the hasVisionMetrixTicket__c field to true
            updateRecord( recordInput )
                .then( result => {
                    console.log( 'result: ', 'Success' );
                } )
                // .refreshApex( this.supportTicket )
                .catch( error => {
                    console.log( 'error: ', error );
                } );

        } else if ( this.hasVisionMetrixTicket ) {
            console.log( 'Has Vision Metrix Ticket' );
            const nodeIdsToPass = this.nodesToAdd.map(node => node.Id).join(',').toString();
            console.log('nodeIdsToPass: ', nodeIdsToPass);
            console.log('nodeIdsToPass: ', typeof nodeIdsToPass);
        
            addCircuitToVMTicket( { vmTicketNumber: ticketNumber_VM ,selectedNodes: nodeIdsToPass } )
                .then( result => {
                    console.log( 'result: ', 'Success' );
                    const evt = new ShowToastEvent( {
                        title: 'Success!! You DID IT!!',
                        message: 'Circuits Added To VM Ticket Created',
                        variant: 'success',
                    } );
                    this.dispatchEvent( evt );
                } )
                .catch( error => {
                    console.log( 'error: ', error );
                    const evt = new ShowToastEvent( {
                        title: 'Failed To Add Circuits To VM Ticket',
                        message: 'If the error persists, please contact your system administrator.',
                        variant: 'error',
                    } );
                    this.dispatchEvent( evt );
                } );
                
            this.clearForm();
            this.searchInput = '';
            this.isSearchActive = false;
            this.filterValue = '';
            this.areNodesSelected = false;
        }
    
    }
    
    removeSelectedNodes() {
        const nodeIdsToPass = this.nodesToAdd.map( node => node.Id ).join( ',' ).toString();
        const ticketNumber_VM = this.vmTicketNumber;
        deleteCircuitsFromVMTicket({ 
            vmTicketNumber: ticketNumber_VM, 
            selectedNodes: nodeIdsToPass 
        })
        .then(result => {
            // Handle the successful result
            console.log( 'Circuits deleted successfully:', 'success' );
            const evt = new ShowToastEvent( {
                        title: 'Success!! You DID IT!!',
                        message: 'Circuits Added To VM Ticket Created',
                        variant: 'success',
                    } );
                    this.dispatchEvent( evt );
        })
        .catch(error => {
            // Handle any errors
            console.error( 'Error deleting circuits:', error );
            const evt = new ShowToastEvent( {
                        title: 'Failed To Add Circuits To VM Ticket',
                        message: 'If the error persists, please contact your system administrator.',
                        variant: 'error',
                    } );
                    this.dispatchEvent( evt );
        });
     }
        
}