
import java.util.ArrayList;
import java.util.Date;

/**
 * @author tmali
 *
 */
/**
 * @author tmali
 *
 */
class Ctrl {

	public void beginMainLoop(DataSource ds) {

		TextIO textIO = TextIO.getInstance();
		String prompt = ">";
		String consoleIn = textIO.prompt(prompt);

		
		
		while (true) {

			String consoleOut = null;
			String[] parsed = consoleIn.split("\\s+"); // Parameters from console are split into an array

			String cmd = parsed[0]; // There will always be at least one parameter - the first one
			String param1 = null;
			String param2 = null;

			if (parsed.length >= 2) // Get the 2nd param if there is one
				param1 = parsed[1]; 
			if (parsed.length == 3) // Get the 3nd param if there is one
				param2 = parsed[2];

			
			// Pass 1st param to switch to determine next action.
			// Switch determines which action to take and passes
			// requisite parameters to the corresponding function,
			// along with a reference to the one instance of the
			// DataSource class. All functions return a String for
			// TextIO to print.
			
			
			switch (cmd) { 

			case "lst":
				consoleOut = getAirportList(ds);
				textIO.display(consoleOut);
				break;

			case "fnd":
				consoleOut = findDirectFlight(param1, param2, ds);
				textIO.display(consoleOut);
				break;

			case "prt":
				consoleOut = printTicket(param1, param2, ds);
				textIO.display(consoleOut);
				break;

			case "help":
				consoleOut = help();
				textIO.display(consoleOut);
				break;

			case "quit":
				ds.closeConn();
				System.exit(0);

			}
			consoleIn = textIO.prompt(prompt);
		}
	}

	/**
	 *  @return a listing of available commands
	*/
	
	private String help() {
		
		String commands = "\nhelp -- display a list of commands\n" + "quit -- quit the application.\n"
				+ "lst airports -- list all airports in the system.\n"
				+ "fnd <departure airport> <destination airport> -- list all direct "
				+ "flights between the origin and destination.\n" + "prt ticket#\n";
		return commands;
	}


	
	public String printTicket(String param1, String param2, DataSource ds) {
		
		long ticketNo = Long.parseLong(param2); // Ticket number is parsed as a long, the largest integer type in Java
		
		Ticket ticket = ds.getTicket(ticketNo); // Get the desired ticket from the DB
		
		long custID = ticket.getCustID(); // Use the getter method of ticket to return the associated customer
		
		Customer cust = ds.findCustomer(custID); // Get the customer
		
		Legs legs = ds.getLegs(ticketNo); // Get all associated legs
		
		ArrayList<Long> fids = legs.getFIDs(); // FID's are store in an ArrayList in legs
		
		String results = "\nTicket#\tFirst\tLast\n" + ticketNo + "\t" + cust.getFirst() + "\t" + cust.getLast() + "\n\n"
						+ "Date\t\tLeave\tFrom\tTo\tArrive\n"; // Add header info to the result String
		
		Flight flight;
		for(long f : fids) { // Iterate through the ArrayList of legs for the ticket and add info for each flight
			
		flight = ds.findDirectFlight(f);
		results += flight.getArrivalTime() + "\t" + flight.getJustDepartureTime() + "\t" + flight.getDepartureAirportCode()
				+ "\t" + flight.getArrivalAirportCode() + "\t" + flight.getArrivalTime() + "\n";
		}
		return results;
	}

	private String findDirectFlight(String param1, String param2, DataSource ds) {
		
		FlightsDAO flightsDAO = ds.findDirectFlight(param1, param2); 	// Get the Data Access Object containing all flights from location1 to location2
		
		ArrayList<Flight> arraylistf = flightsDAO.getFlightsList(); 	// Flights are returned as an ArrayList
		
		String results = "";
		
		if (arraylistf.isEmpty()) 										// Check if any flights were found
			results += "\nNo flights found. Make sure airport codes are in uppercase, I'm not converting them for you SUCKA!\n\n";
		
		else { 															// Add a header and all results to the return String 
			results = "\nFID\tFrom\tTime\t\tTo\tTime\tOpen Seats\n";
			for (Flight f : arraylistf)
				results += f.getFID() + "\t" + f.getDepartureAirportCode() + "\t" + f.getDateDepart() + " " + f.getJustDepartureTime() + "\t"
						+ f.getArrivalAirportCode() + "\t" + f.getDateAndTimeArrive() + "\t\t" + f.getOpenSeats() + "\n";
		}
		return results;
	}

	private String getAirportList(DataSource ds) {
		
		AirportsDAO aDAO = ds.listAirports(); // Get the Data Access Object containing all flights
		
		ArrayList<Airport> arrayListAirports = aDAO.getAirports(); // Get the list of flights
		
		String results = "";
		for (Airport a : arrayListAirports)
			results += a.getCode() + "\t" + a.getCity() + "\t\t" + a.getState() + "\n";
		return results;
	}

}