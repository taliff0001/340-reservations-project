
class TestDrv {
	
	public static void main(String[] args) {
		
		DataSource dataSource = DataSource.getInstance();
		dataSource.openConnection(args);
		DataSource ds = DataSource.getInstance();
		ds.openConnection(args);
		Ctrl control = new Ctrl();
		
		
		// -----  Airports Test  -------------------------------------------------------------//
		
		String airportsFromDB;
		String airportsTestValues;
		
		airportsTestValues = "Code RIC City Richmond State VA".replaceAll("\\s+", "")
							+ "Code BWI City Baltimore State MD".replaceAll("\\s+", "")
							+ "Code MDT City Harrisburg State PA".replaceAll("\\s+", "");
		
		airportsFromDB = ds.listAirports().getAirports().get(0).toString().replaceAll("\\s+", "")
						+ ds.listAirports().getAirports().get(1).toString().replaceAll("\\s+", "")
						+ ds.listAirports().getAirports().get(2).toString().replaceAll("\\s+", "");
		
		
		String passOrFail = null;
		
		passOrFail = airportsTestValues.equals(airportsFromDB) ? "Pass" : "Fail";
		
		System.out.println("1st airports --\t" + passOrFail);
		
		
		// -----  Flights Test  -------------------------------------------------------------//
		
		String[] flightsFromDB = new String [3];
		String[] flightsTestValue = new String [3];
		
		// Desired output with whitespace removed
		
		flightsTestValue[0] = "1000RIC8/3/235:48AMDTW7:29AM56";
		flightsTestValue[1] = "1001DTW8/10/235:20AMATL7:16AM57";
		flightsTestValue[2] = "1002ATL8/10/238:04AMRIC9:40AM59";
		
		// Strings returned from DataSource methods, whitespace removed
		
		flightsFromDB[0] = ds.findDirectFlight("RIC", "DTW").getFlightsList().get(0).toString().replaceAll("\\s+", "");
		flightsFromDB[1] = ds.findDirectFlight("DTW", "ATL").getFlightsList().get(0).toString().replaceAll("\\s+", "");
		flightsFromDB[2] = ds.findDirectFlight("ATL", "RIC").getFlightsList().get(0).toString().replaceAll("\\s+", "");
		
		
		passOrFail = null;;
		
		// Iterative comparison of the three Strings
		
		for(int i=0;i<flightsTestValue.length;++i) {
			if(!flightsTestValue[i].equals(flightsFromDB[i])) {
				passOrFail = "Fail";
				break;
			}
			else
				passOrFail = "Pass";
		}
					
		System.out.println("fnd flights --\t" + passOrFail);
			

		// -----  Airports Test  -------------------------------------------------------------//
		
		String legsDB;
		String legsTest;
		
		legsTest = "Ticket# First Last 4004 Tommy Aliff Date Leave From To Arrive".replaceAll("\\s+", "")
				+ "2023-08-03 9:45PM ATL LAS 2023-08-03 2023-08-04 5:45AM LAS LAX 2023-08-04".replaceAll("\\s+", "");
		
		legsDB = control.printTicket("ticket#", "4004", ds).replaceAll("\\s+", ""); // Method called from the controller for simplicity

		passOrFail = null;
		
		passOrFail = airportsTestValues.equals(airportsFromDB) ? "Pass" : "Fail";
		
		System.out.println("prt ticket# --\t" + passOrFail);
				
		dataSource.closeConn();
}

	}
	