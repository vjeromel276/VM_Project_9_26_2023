import { LightningElement, wire, api } from 'lwc';
import getParentCases from '@salesforce/apex/VisionMetrixAppController.getParentCases';
import getChildCases from '@salesforce/apex/VisionMetrixAppController.getChildCases';

export default class VisionMetrixApp extends LightningElement {

    parentCases = [];

    connectedCallback () {
        this.getParentCases();
    }

    getParentCases () {
        getParentCases()
            .then(result => {
                this.parentCases = result;
                this.parentCases.forEach( parentCase => {  
                    console.log( 'parentCase: ' + JSON.stringify( parentCase ));
                    let childCases = [];
                    getChildCases( { parentCaseId: parentCase.Id } )
                        .then( result => {
                            childCases = result;
                            console.log( 'childCases: ' + JSON.stringify( childCases ) );
                            parentCase.childCases = childCases;
                            console.log( 'parentCase: ' + JSON.stringify( parentCase ));
                        } )
                        .catch( error => {
                            this.error = error;
                        } );
                    
                });
            })
            .catch(error => {
                this.error = error;
            });
    }

}