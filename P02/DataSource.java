package airports;

import java.sql.*;

public class DataSource {

	private String user;
	private String pass;
	private TextIO textIO;
	private Connection conn;
	private static volatile DataSource instance;

	private DataSource(String[] args) {
		this.textIO = TextIO.getInstance();
		this.user = args[0];
		this.pass = args[1];

		try {
			conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
		} catch (SQLException e) {
			System.out.println("Could not establish a connection to the database: " + e);
		} finally {
			closeConn();
		}
	}

	public static DataSource getInstance() {
		DataSource datasource = null;
		return datasource;
	}

	public static DataSource openConnection(String[] args) { // No Params
		if (instance == null) {
			synchronized (DataSource.class) {
				if (instance == null) {
					instance = new DataSource(args);
				}
			}
		}
		return instance;
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

		// get all airports with select statement
		String airportsQuery = "SELECT * FROM Airports_MV";
		AirportsDAO aDAO = null;
		try (Statement stmt = conn.createStatement(); ResultSet rset = stmt.executeQuery(airportsQuery)) {

			aDAO = new AirportsDAO();

			while (rset.next()) {
				aDAO.addAirport(
					new Airport(rset.getString("airport_code"),
					rset.getString("city"), rset.getString("state")));
			}

		} catch (SQLException e) {
			textIO.display("Could not retrieve airport list from the database: " + e);
		}
		return aDAO;
	}

	/*****************************************************************************************/

	public String empList(String optional) {

		String employeeList = "";
		String query = "";

		if (optional != null && optional.equals("-i")) {
			query = "SELECT * FROM employees ORDER BY fname";

			try (Statement stmt = conn.createStatement(); ResultSet rset = stmt.executeQuery(query)) {
				while (rset.next()) {
					employeeList += rset.getString("empid") + " | " + rset.getString("fname") + " | "
							+ rset.getString("lname") + "\n";
				}
			} catch (SQLException e) {
				System.out.println("Could not retrieve employee list from the database: " + e);
			}
		} else if (optional != null && optional.equals("-a")) {
			query = "SELECT * FROM employees ORDER BY fname";

			try (Statement stmt = conn.createStatement(); ResultSet rset = stmt.executeQuery(query)) {
				while (rset.next()) {
					employeeList += rset.getString("empID") + " | " + rset.getString("fname") + " | "
							+ rset.getString("lname") + " | " + rset.getString("sex") + rset.getString("dept") + " | "
							+ rset.getString("phone") + " | " + rset.getString("salary") + "\n";
				}
			} catch (SQLException e) {
				System.out.println("Could not retrieve employee list from the database: " + e);
			}
		} else {
			query = "SELECT * FROM employees ORDER BY fname";

			try (Statement stmt = conn.createStatement(); ResultSet rset = stmt.executeQuery(query)) {
				while (rset.next()) {
					employeeList += rset.getString("fname") + " | " + rset.getString("lname") + "\n";
				}
			} catch (SQLException e) {
				System.out.println("Could not retrieve employee list from the database: " + e);
			}
		}
		return employeeList;
	}

}

//  public String empList(String optional) {
//		
//        String employeeList = "";
//		String query = "";
//		
//		if(optional != null && optional.equals("-i")){
//			query = "SELECT * FROM employees ORDER BY fname";
//
//			try (Statement stmt = conn.createStatement();
//				 ResultSet rset = stmt.executeQuery(query)) {
//				while (rset.next()) {
//					employeeList += rset.getString("empid") + " | " + rset.getString("fname") + " | " + rset.getString("lname") + "\n";
//				}
//			} catch (SQLException e) {
//				System.out.println("Could not retrieve employee list from the database: " + e);
//			}
//		}
//		else if (optional != null && optional.equals("-a")){
//			query = "SELECT * FROM employees ORDER BY fname";
//
//			try (Statement stmt = conn.createStatement();
//				 ResultSet rset = stmt.executeQuery(query)) {
//				while (rset.next()) {
//					employeeList += rset.getString("empID") + " | " + rset.getString("fname") + " | " + rset.getString("lname")
//					+ " | " + rset.getString("sex") + rset.getString("dept") + " | " + rset.getString("phone")  + " | " + rset.getString("salary") + "\n";
//				}
//			} catch (SQLException e) {
//				System.out.println("Could not retrieve employee list from the database: " + e);
//			}
//		}
//		else{
//			query = "SELECT * FROM employees ORDER BY fname";
//
//			try (Statement stmt = conn.createStatement();
//				 ResultSet rset = stmt.executeQuery(query)) {
//				while (rset.next()) {
//					employeeList += rset.getString("fname") + " | " + rset.getString("lname") + "\n";
//				}
//			} catch (SQLException e) {
//				System.out.println("Could not retrieve employee list from the database: " + e);
//			}
//		}
//        return employeeList;
//    }
//    
//    
//
