
import java.util.ArrayList;
import java.util.Date;

class Ctrl {

	public void beginMainLoop(DataSource ds) {

		TextIO textIO = TextIO.getInstance();
		String prompt = ">";
		String consoleIn = textIO.prompt(prompt);

		while (true) {

			String consoleOut = null;
			String[] parsed = consoleIn.split("\\s+");

			String cmd = parsed[0];
			String param1 = null;
			String param2 = null;

			if (parsed.length >= 2)
				param1 = parsed[1];
			if (parsed.length == 3)
				param2 = parsed[2];

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
				consoleOut = printTicket(param1, param2, ds); // need a cast here
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

	private String help() {
		String commands = "\nhelp -- display a list of commands\n" + "quit -- quit the application.\n"
				+ "lst airports -- list all airports in the system.\n"
				+ "fnd <departure airport> <destination airport> -- list all direct "
				+ "flights between the origin and destination.\n" + "prt ticket#\n";
		return commands;
	}

	private String printTicket(String param1, String param2, DataSource ds) {
//		System.out.println("Param 2 = " + param2);
		long ticketNo = Long.parseLong(param2);
		Ticket ticket = ds.getTicket(ticketNo);
		long custID = ticket.getCustID();
		Customer cust = ds.findCustomer(custID);
		Legs legs = ds.getLegs(ticketNo);
		ArrayList<Long> fids = legs.getFIDs();
		String results = "\nTicket#\tFirst\tLast\n" + ticketNo + "\t" + cust.getFirst() + "\t" + cust.getLast() + "\n\n"
						+ "Date\tLeave\tFrom\tTo\tArrive\n";
			Flight flight;
			for(long f : fids) {
			flight = ds.findDirectFlight(f);
			results += flight.getDepartureTime() + "\t" + flight.getDepartureAirportCode()
					+ "\t" + flight.getArrivalAirportCode() + "\t" + flight.getArrivalTime() + "\n";
		}
		return results;
	}

	private String findDirectFlight(String param1, String param2, DataSource ds) {
		FlightsDAO flightsDAO = ds.findDirectFlight(param1, param2);
		ArrayList<Flight> arraylistf = flightsDAO.getFlightsList();
		String results = "";
		if (arraylistf.isEmpty())
			results += "\nNo flights found. Make sure airport codes are in uppercase, I'm not converting them for you SUCKA!\n\n";
		else {
			results = "\nFID\tFrom\tTime\tTo\tTime\tOpen Seats\n";
			for (Flight f : arraylistf)
				results += f.getFID() + "\t" + f.getDepartureAirportCode() + "\t" + f.getDepartureTime() + "\t"
						+ f.getArrivalAirportCode() + "\t" + f.getArrivalTime() + "\t" + f.getOpenSeats() + "\n";
		}
		return results;
	}

	private String getAirportList(DataSource ds) {
		AirportsDAO aDAO = ds.listAirports();
		ArrayList<Airport> arrayListAirports = aDAO.getAirports();
		String results = "";
		for (Airport a : arrayListAirports)
			results += a.getCode() + "\t" + a.getCity() + "\t" + a.getState() + "\n";
		return results;
	}

}