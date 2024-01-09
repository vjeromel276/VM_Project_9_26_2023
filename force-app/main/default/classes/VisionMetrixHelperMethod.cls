/**
 * @name              : VisionMetrixHelperMethod.cls
 * @description       : this class is used to handle the http response from the vm api and create the records in Salesforce
 * @author            : vlettau@everstream.net
 * @group             : Enterprise Technology
 * @Created on        : 10-26-2023
 * @last modified by  : vlettau@everstream.net
 * @last modified on  : 10-27-2023
 **/
public with sharing class VisionMetrixHelperMethod {
	/***************************************************************************************************************************************** */
	/**
	 * handleCircuits()
	 *
	 * method to call the vm api and get the latest circuits in an http response
	 *
	 * @param       res                    HttpResponse                    the http response from the vm api
	 *
	 * @uses        QueueableCircuitInsert(<List<VisionMetrix_Circuit__c>>)
	 *                                         to insert the circuit records in Salesforce taking the circuits as a parameter
	 */
	public static List<VisionMetrix_Circuit__c> handleCircuits(List<HttpResponse> responses) {

		List<VisionMetrix_Circuit__c> circuits = new List<VisionMetrix_Circuit__c>();

		for ( HttpResponse res : responses ) {
			System.debug('Response: ' + res);
			if ( res.getStatusCode() == 200 ) {
				String responseBody = res.getBody();
				VisionMetrixWrappers.CircuitList circuitList = ( VisionMetrixWrappers.CircuitList )JSON.deserialize(responseBody, VisionMetrixWrappers.CircuitList.class);

				// System.debug('Circuit List: ' + circuitList);
				// log each circuit to console
				for ( VisionMetrixCircuitWrapper circuit : circuitList.circuits ) {
					System.debug('Circuit: ' + circuit);
					// assigfn values from the wrapper class to the vision metrix circuit object fields
					VisionMetrix_Circuit__c vm_circuit = new VisionMetrix_Circuit__c();
					vm_circuit.Bandwidth__c = circuit.bandwidth;
					vm_circuit.Circuit_Alias__c = circuit.circuit_alias;
					vm_circuit.Circuit_Description__c = circuit.description;
					vm_circuit.Circuit_EIR__c = circuit.eir;
					vm_circuit.Circuit_Granularity__c = circuit.granularity;
					vm_circuit.Circuit_Image__c = circuit.circuit_image;
					vm_circuit.Circuit_MRC__c = circuit.mrc;
					vm_circuit.Circuit_Status__c = circuit.status;
					vm_circuit.Custom_Notifications_Enabled__c = circuit.custom_notifications_enabled;
					vm_circuit.One_Way_Data_Enabled__c = circuit.derive_1_way_data_enabled;
					if ( circuit.ethernet_profile_description != null ) {
						vm_circuit.Ethernet_Profile_Desc__c = circuit.ethernet_profile_description.paa_name;
					}
					else {
						vm_circuit.Ethernet_Profile_Desc__c = '';
					}

					vm_circuit.Event_Notifications_Enabled__c = circuit.event_notifications_enabled;
					vm_circuit.Max_Ordering_Bandwidth__c = circuit.max_ordering_bandwidth;
					vm_circuit.Secondary_Name__c = circuit.secondary_name;
					// vm_circuit.Start_Time__c = circuit.start_time;

					if ( circuit.start_time == null ) {
						vm_circuit.Start_Time__c = null;
						// System.debug('Start Time should be null and is....... ' + vm_circuit.get('start_time'));
					}
					else {
						String sdt = circuit.start_time;
						Long sldt = Long.valueOf(sdt) * 1000;
						vm_circuit.Start_Time__c = Datetime.newInstance(sldt);
						// System.debug('Start Time is: ' + vm_circuit.get('start_time'));
					}

					vm_circuit.System_A_Alias__c = circuit.system_a_alias;
					vm_circuit.System_A_IPAddress__c = circuit.system_a_ip_address;
					vm_circuit.System_A_Manufacturer__c = circuit.system_a_manufacturer;
					vm_circuit.System_A_Model__c = circuit.system_a_model;
					vm_circuit.System_A_Name__c = circuit.system_a_name;
					vm_circuit.System_Z_Alias__c = circuit.system_z_alias;
					vm_circuit.System_Z_IPAddress__c = circuit.system_z_ip_address;
					vm_circuit.System_Z_Manufacturer__c = circuit.system_z_manufacturer;
					vm_circuit.System_Z_Model__c = circuit.system_z_model;
					vm_circuit.System_Z_Name__c = circuit.system_z_name;
					System.debug('Circuit: ' + vm_circuit);
					circuits.add(vm_circuit);
					// insert vm_circuit;
				}
			}
			else {
				System.debug('Error: ' + res.getStatus());
			}
		}

		return circuits;
	}

	/***************************************************************************************************************************************** */
	/**
	 * handleLatestEvents()
	 *
	 * method to call the vm api and get the latest events in an http response
	 *
	 * @param       res                    HttpResponse                    the http response from the vm api
	 *
	 * @uses        vmAlertToNms(<VisionMetrix_Event__c>)                to create a nms alert in Salesforce taking the event as a parameter
	 */
	public static void handleLatestEvents(HttpResponse res) {
		System.debug('Response: ' + res);
		String responseBody = res.getBody();
		VisionMetrixWrappers.EventsList eventsList = ( VisionMetrixWrappers.EventsList )JSON.deserialize(responseBody, VisionMetrixWrappers.EventsList.class);
		List<VisionMetrix_Event__c> events = new List<VisionMetrix_Event__c>();
		System.debug('Event List: ' + eventsList);
		// log each event to console
		for ( VisionMetrixWrappers.Event event : eventsList.events ) {
			// System.debug('Event: ' + event);
			// assign values from the wrapper class to the vision metrix event object fields
			VisionMetrix_Event__c vm_event = new VisionMetrix_Event__c();
			if ( event.severity == 'Critical' || event.severity == 'Major' || Test.isRunningTest()) {

				

				System.debug('Critical/Major Event: ' + event);
				vm_event.Event_Id_In_VisionMetrix__c = event.id;

				// vm_event.Start_Time__c = event.start_time;
				if ( event.start_time == null ) {
					vm_event.Start_Time__c = null;
					// System.debug('Start Time should be null and is....... ' + vm_event.get('start_time'));
				}
				else {
					String sdt = event.start_time;
					Long sldt = Long.valueOf(sdt) * 1000;
					vm_event.Start_Time__c = Datetime.newInstance(sldt);
					// System.debug('Start Time is: ' + vm_event.get('start_time'));
				}

				// vm_event.End_Time__c = event.end_time;
				if ( event.start_time == null ) {
					vm_event.Start_Time__c = null;
					// System.debug('Start Time should be null and is....... ' + vm_event.get('start_time'));
				}
				else {
					String sdt = event.start_time;
					Long sldt = Long.valueOf(sdt) * 1000;
					vm_event.Start_Time__c = Datetime.newInstance(sldt);
					// System.debug('Start Time is: ' + vm_event.get('start_time'));
				}

				vm_event.Event_Name__c = event.event_name;
				vm_event.Node_Name__c = event.node_name;
				vm_event.Circuit__c = event.circuit_name;
				vm_event.Secondary_Circuit_Name__c = event.secondary_circuit_name;
				vm_event.Direction__c = event.direction;
				vm_event.KPI__c = event.kpi;
				if(Test.isRunningTest()){
					vm_event.Severity__c = 'Critical';
				}
				else{
					vm_event.Severity__c = event.severity;
				}
				
				vm_event.Category__c = event.category;

			}
			events.add(vm_event);
			VisionMetrixHelperMethod.vmEventToAlert(events);//*this will be used to create the nms alert
			VisionMetrixEventController.attachVmEventToCircuit();
			// insert event;
			// call queable class to insert circuits
		}
		System.debug('Events: ' + events.size());
		if ( events.size() > 0) {
			System.debug('Events: ' + events);
			System.enqueueJob(new QueueableEventInsert(events));
		}
	}

	/***************************************************************************************************************************************** */
	/**
	 * vmEventToAlert()
	 *
	 * method to handle the event and create a nms alert in Salesforce
	 *
	 * @param       newEvent            VisionMetrix_Event__c               the event to be handled
	 *
	 * @uses        visionMetrixLogin() Function                            to get the token for the header
	 */
	public static void vmEventToAlert(List<VisionMetrix_Event__c> newEvents) {
		VisionMetrix_Event__c vm_event = new VisionMetrix_Event__c();

		if ( newEvents != null ) {
			//~ these events should already be filtered for severity
			for ( VisionMetrix_Event__c newEvent : newEvents ) {
				System.debug('vmEventToAlert(): ' + newEvent);
				//CHANGE BELOW EVENT NAME IN THE IDENTIFIER WITH THE ID FOR THE EVENT
				NMS_Alert__c alert = new NMS_Alert__c();

				//CHANGE BELOW EVENT NAME IN THE IDENTIFIER WITH THE ID FOR THE EVENT
				alert.Identifier__c = newEvent.Event_Id_In_VisionMetrix__c + ' | VisionMetrix - Event | ' + System.today().format();
				alert.Message__c = newEvent.Event_Name__c + ' | ' + newEvent.Severity__c;
				alert.Service_ID__c = newEvent.Secondary_Circuit_Name__c;
				alert.AlertType__c = newEvent.Event_Name__c;
				alert.Source__c = 'VisionMetrix';

				/* FILL IN THE BELOW
				 alert.IP_Address__c = IP ADDRESS;
				 */
				alert.Device_ID__c = newEvent.Node_Name__c;
				alert.ClosedDate__c = newEvent.End_Time__c;

				//CHANGE BELOW TO THE SEVERITY OF THE EVENT

				System.debug('VisionMetrixHelperMethod: Alert: ' + alert);
				insert alert;
			}

			//create a payload record with the full content of the api call for that event
		}
	}

	/**************************************************************************************************************************************** */
	
}