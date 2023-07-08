
import java.sql.*;

public class DataSource {

	private String user;
	private String pass;
	private TextIO textIO;
	private static Connection conn;
	private static volatile DataSource instance;
	

	private DataSource() {					// DataSource is able to print its error messages directly
		textIO = TextIO.getInstance();
	}

	private DataSource(String[] args) {
		this.textIO = TextIO.getInstance();
		this.user = args[0];
		this.pass = args[1];

		try {
			if (conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
		} catch (SQLException e) {
			System.out.println("Could not establish a connection to the database: " + e);
		}
	}

	public static DataSource getInstance() {
		return new DataSource();
	}

	public void openConnection(String[] args) {
		if (instance == null) {
			synchronized (DataSource.class) {
				if (instance == null) {
					instance = new DataSource(args);
				}
			}
		}
	}

	public void closeConn() {
		try {
			if (conn != null) {
				conn.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} 
	}

	public AirportsDAO listAirports() {
		
		String airportsQuery = "SELECT * FROM Airports_MV";
		AirportsDAO aDAO = null;
		
		try {
			if (conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);

			Statement stmt = conn.createStatement();
			ResultSet rset = stmt.executeQuery(airportsQuery);

			aDAO = new AirportsDAO(); 	// DAO is simply a container for passing a list of airports to the controller

			while (rset.next()) {		// A new instance of the Airport class is created for each airport in the DB
										// and added to a list in the DAO
				aDAO.addAirport(
						new Airport(rset.getString("airport_code"), rset.getString("city"), rset.getString("state")));
			}

		} catch (SQLException e) {
			textIO.display("Could not retrieve airport list from the database: " + e);
		} 
		
		return aDAO;
	}

	
	public Customer findCustomer(long custID) { //If you don't understand this you should read the JDBC documentation

		String custQuery = "SELECT * FROM Customers WHERE Cust_ID = ?";
		Customer cust = null;

		try {
			if (conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
				
			PreparedStatement getCustomer = conn.prepareStatement(custQuery);
			getCustomer.setLong(1, custID);
			ResultSet rset = getCustomer.executeQuery();
			if (rset.next()) {
				cust = new Customer(rset.getLong("cust_ID"), rset.getString("first_name"), rset.getString("last_name"),
						rset.getDouble("balance"));
			}
		} catch (SQLException e) {
			textIO.display("Could not retrieve customer from the database: " + e);
		} 
		
		return cust;
	}

	public FlightsDAO findDirectFlight(String depart, String arrive) { // Same here

		String flightsQuery = "SELECT * FROM Flight_Info_LV WHERE dep_airport = ? AND dest_airport = ? ";
		FlightsDAO fDAO = null;

		try {
			if (conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
			
			PreparedStatement queryDirectFlights = conn.prepareStatement(flightsQuery);
			queryDirectFlights.setString(1, depart);
			queryDirectFlights.setString(2, arrive);
			ResultSet rset = queryDirectFlights.executeQuery();
			fDAO = new FlightsDAO();
			while (rset.next()) {		// Like the Airports DAO, the ResultSet is iterated through and
										// Flight objects are instantiated and added to a list
				fDAO.addFlight(
						new Flight(rset.getLong("FID"), rset.getString("dep_airport"), rset.getString("dest_airport"),
								rset.getDate("dep_date"), rset.getDate("arrival_date"), rset.getShort("Open_Seats")));
			}
		} catch (SQLException e) {
			textIO.display("Could not retrieve flight list from the database: " + e);
		} 
		
		return fDAO;
	}

	public Flight findDirectFlight(long FID) {

		String flightsQuery = "SELECT * FROM Flight_Info_LV WHERE FID = ?";
		Flight flight = null;

		try {
			if(conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
			
			PreparedStatement queryDirectFlights = conn.prepareStatement(flightsQuery);
			queryDirectFlights.setLong(1, FID);
			ResultSet rset = queryDirectFlights.executeQuery();
			
			if (rset.next()) {
				flight = new Flight(rset.getLong("FID"), rset.getString("dep_airport"), rset.getString("dest_airport"),
						rset.getDate("dep_date"), rset.getDate("arrival_date"), rset.getShort("Open_Seats"));

			}
			
		} catch (SQLException e) {
			textIO.display("Could not retrieve flight list from the database: " + e);
			
		} 
		
		return flight;
	}

	public Ticket getTicket(long ticketNo) {

		Ticket ticket = null;
		String ticketsQuery = "SELECT * FROM Tickets WHERE ticket_No = ?";
		
		try {
			if(conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
			
			PreparedStatement queryTickets = conn.prepareStatement(ticketsQuery);
			queryTickets.setLong(1, ticketNo);
			ResultSet rset = queryTickets.executeQuery();
			ticket = new Ticket(ticketNo);
			rset.next();
			ticket.setCustID(rset.getLong("cust_id"));
			ticket.setPurchaseDate(rset.getDate("purchase_date"));
			ticket.setPrice(rset.getDouble("price"));
			
		} catch (SQLException e) {
			textIO.display("Could not retrieve flight list from the database: " + e);
			
		}
		
		return ticket;
	}

	public Legs getLegs(long ticketNo) {

		Legs legs = null;
		String legsQuery = "SELECT FID FROM Legs WHERE ticket_No = ?";
		try {
			if(conn == null)
				conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
			
			PreparedStatement queryLegs = conn.prepareStatement(legsQuery);
			queryLegs.setLong(1, ticketNo);
			ResultSet rset = queryLegs.executeQuery();
			legs = new Legs(ticketNo);
			while (rset.next()) {
				legs.addFID(rset.getLong("FID"));
			}
		} catch (SQLException e) {
			textIO.display("Could not retrieve flight list from the database: " + e);
			
		} 
		
		return legs;
	}
} // End class
