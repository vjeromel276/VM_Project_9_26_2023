public with sharing class VisionMetrixHelperMethod {
	public VisionMetrixHelperMethod(){
		
	}
	public static void handleCircuits(HttpResponse res) {
		System.debug('Response: ' + res.getStatusCode());

		if ( res.getStatusCode() == 200 ) {
			String responseBody = res.getBody();
			VisionMetrixWrappers.CircuitList circuitList = ( VisionMetrixWrappers.CircuitList )JSON.deserialize(responseBody, VisionMetrixWrappers.CircuitList.class);
			List<VisionMetrix_Circuit__c> circuits = new List<VisionMetrix_Circuit__c>();

			// System.debug('Circuit List: ' + circuitList);
			// log each circuit to console
			for ( VisionMetrixCircuitWrapper circuit : circuitList.circuits ) {
				System.debug('Circuit: ' + circuit);
				// assigfn values from the wrapper class to the vision metrix circuit object fields
				VisionMetrix_Circuit__c vm_circuit = new VisionMetrix_Circuit__c(  );
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
				vm_circuit.Ethernet_Profile_Desc__c = circuit.ethernet_profile_description.paa_name;
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

			// call queable class to insert circuits
			if ( circuits.size() > 0 ) {
				System.debug('Circuits: ' + circuits);
				System.enqueueJob(new QueueableCircuitInsert(circuits));
			}

		}
		else {
			System.debug('Error: ' + res.getStatus());
		}
	}

	public static void handleLatestEvents(HttpResponse res) {
		System.debug('Response: ' + res.getStatusCode());

		if ( res.getStatusCode() == 200 && res.getBody() != null ) {

			String responseBody = res.getBody();
			VisionMetrixWrappers.EventsList eventsList = ( VisionMetrixWrappers.EventsList )JSON.deserialize(responseBody, VisionMetrixWrappers.EventsList.class);
			List<VisionMetrix_Event__c> events = new List<VisionMetrix_Event__c>();
			// System.debug('Event List: ' + eventList);
			// log each event to console
			if ( eventsList != null ) {
				for ( VisionMetrixWrappers.Event event : eventsList.event ) {
					System.debug('Event: ' + event);

					if ( event.severity == 'Major' && event.severity == 'Critical' ) {

						// assigfn values from the wrapper class to the vision metrix event object fields
						VisionMetrix_Event__c vm_event = new VisionMetrix_Event__c();
						vm_event.Event_Id_In_VisionMetrix__c = event.id;
						// vm_event.Start_Time__c =event.start_time;
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
						vm_event.Severity__c = event.severity;
						vm_event.Category__c = event.category;
						VisionMetrixCallOut.vmEventToAlert(vm_event);
						events.add(vm_event);
					}
				}
			}
		}
		else {

		}
	}

}