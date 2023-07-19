
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.sql.Date;


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
			String param3 = null;
			String param4 = null;

			if (parsed.length >= 2)
				param1 = parsed[1];
			if (parsed.length >= 3)
				param2 = parsed[2];
			if (parsed.length >= 4)
				param3 = parsed[3];
			if (parsed.length >= 5)
				param4 = parsed[4];

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
			
			case "fndopen":
				consoleOut = find_open_seat(ds, param1);
				textIO.display(consoleOut);
				break;
				
			case "addcust": 
				consoleOut = addCustomer(param1, param2, param3, ds);
				textIO.display(consoleOut);
				break;
				
			case "addairport":
			    consoleOut = addAirport(param1, param2, param3, ds);
			    textIO.display(consoleOut);
			    break;
			
			case "resflight":
			    consoleOut = resFlight(param1, param2, param3, param4, ds);
			    textIO.display(consoleOut);
			    break;
			    
			case "schedulefl":
				textIO.display(schflSubmenu1());
				String depart = textIO.prompt(prompt);
				
				textIO.display(schflSubmenu2());
				String arrive = consoleIn = textIO.prompt(prompt);
				
				textIO.display(schflSubmenu3());
				String seatAndPriceInfo = textIO.prompt(prompt);
				String[] infoParsed = seatAndPriceInfo.split("\\s+");
				
				consoleOut = scheduleFlight(depart, arrive, Short.parseShort(infoParsed[0]),
						Short.parseShort(infoParsed[1]), Double.parseDouble(infoParsed[2]) , ds);
				textIO.display(consoleOut);
			    break;
				
			case "quit":
				ds.closeConn();
				System.exit(0);

			}
			consoleIn = textIO.prompt(prompt);
		}
	}

	private String resFlight(String param1, String param2, String param3, String param4, DataSource ds) {
		int status = ds.reserveFlight(Long.parseLong(param1),
			Long.parseLong(param2), Short.parseShort(param3), Double.parseDouble(param4));
		//System.out.println(status);
		if(status == -1)
			return "That seat's taken, BRO!\n";
		return "Success!\n";
	}

	private String find_open_seat(DataSource ds, String flightID) {
		int openSeat = ds.find_open_seat(Integer.parseInt(flightID));
		
		if(openSeat == -1)
			return "No open seats\n";
		else
		 return "Found seat# " + openSeat + "\n";
	}

	private String help() {
		
		String commands = "\nhelp -- display a list of commands\n" + "quit -- quit the application.\n"
				+ "lst airports\n"
				+ "fnd <departure airport> <destination airport> -- list all direct "
				+ "flights between the origin and destination.\n" + "prt ticket# <Cust ID#> <ticket number>\n"
		        + "addcust <firstname> <lastname> <balance>\n"
				+ "addairport <airport code> <city> <state> -- Use '_' to separate multi-word city names\n"
		        + "resflight <customer id> <flight number> <seat number> <purchase amount> -- reserves a ticket\n"
				+ "fndopen <flight number> -- returns an open seat if available\n"
				+ "schedulefl -- opens submenu for adding a new flight\n";
		return commands;
	}

	private String printTicket(String param1, String param2, DataSource ds) {
		
		long ticketNo = Long.parseLong(param2);
		Ticket ticket = ds.getTicket(ticketNo);
		long custID = ticket.getCustID();
		Customer cust = ds.findCustomer(custID);
		Legs legs = ds.getLegs(ticketNo);
		ArrayList<Long> fids = legs.getFIDs();
		String results = "\nTicket#\tFirst\tLast\n" + ticketNo + "\t" + cust.getFirst() + "\t" + cust.getLast() + "\n\n"
						+ "Date\t\tLeave\t\tFrom\tTo\tArrive\n";
		Flight flight;
		for(long f : fids) {
		flight = ds.findDirectFlight(f);
		results += flight.getArrivalTime() + "\t" + flight.getJustDepartureTime() + "\t\t" + flight.getDepartureAirportCode()
				+ "\t" + flight.getArrivalAirportCode() + "\t" + flight.getTimeArrive() + "\n";
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
				results += f.getFID() + "\t" + f.getDepartureAirportCode() + "\t" + f.getDateDepart() + " " + f.getJustDepartureTime() + "\t"
						+ f.getArrivalAirportCode() + "\t" + f.getTimeArrive() + "\t" + f.getOpenSeats() + "\n";
		}
		return results;
	}

	private String getAirportList(DataSource ds) {
		
		AirportsDAO aDAO = ds.listAirports();
		ArrayList<Airport> arrayListAirports = aDAO.getAirports();
		String results = "";
		for (Airport a : arrayListAirports)
			results += a.getCode() + "\t" + a.getCity() + "\t\t" + a.getState() + "\n";
		return results;
	}
	
	private String addCustomer(String firstName, String lastName, String balanceStr, DataSource ds) {

        double balance;
        try {
            balance = Double.parseDouble(balanceStr);
        } catch (NumberFormatException e) {
            return "\nInvalid input format. Please provide a valid custID and balance.\n";
        }
        return ds.insertCustomer(firstName, lastName, balance);
    }
	
	private String addAirport(String airportCode, String city, String state, DataSource ds) {
	    if (airportCode != null && city != null && state != null) {
	        System.out.flush(); // Flush the output buffer
	        return ds.insertAirport(airportCode, city, state);
	    } else {
	        return "\nInvalid input. Please provide all airport details.\n";
	    }
	}
	
	private String schflSubmenu1() {
		String sub1 = "\n<Departure Airport Code> <HH:MM> <MM-DD-YYYY>\n>";		
		return sub1;
	}
	
	private String schflSubmenu2() {
		String sub2 = "\n<Arrival Airport Code> <HH:MM> <MM-DD-YYYY>\n>";		
		return sub2;
	}
	private String schflSubmenu3() {
		String sub3 = "\n<rows> <seats per row> <ticket price>\n>";		
		return sub3;
	}

	
	private Date parseDate(String toParse) {
		 String[] parts = toParse.split(" ");
		    String time = parts[0];
		    String date = parts[1];
		    String dateTimeString = time + " " + date;
		    SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm MM-dd-yyyy");
		    java.util.Date utilDate = null;
		    try {
		        utilDate = dateFormat.parse(dateTimeString);
		    } catch (java.text.ParseException e) {
		        e.printStackTrace();
		        
		    }
		    return new java.sql.Date(utilDate.getTime());
	}
	
	private String scheduleFlight(String departureInfo, String arrivalInfo, short rows, short seatsPer, double price, DataSource ds) {
	    String depCode = departureInfo.strip().substring(0, 3);
	    Date depDate = parseDate(departureInfo.substring(4));

	    String arrCode = arrivalInfo.strip().substring(0, 3);
	    Date arrDate = parseDate(arrivalInfo.substring(4));

	    try {
	        int status = ds.scheduleFlight(depCode, depDate, arrCode, arrDate, rows, seatsPer, price);
	        if (status == 1) {
	            return "Flight successfully scheduled!\n";
	        } else {
	            return "Failed to schedule the flight.\n";
	        }
	    } catch (Exception e) {
	        return "An unexpected error occurred: " + e.getMessage() + "\n";
	    }
	}
	
	
	
	
	
}