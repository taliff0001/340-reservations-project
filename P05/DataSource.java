
import java.sql.*;

public class DataSource {

    private String user;
    private String pass;
    private final TextIO textIO;
    private static Connection conn;
    private static volatile DataSource instance;
    private static final String DB_URL = "jdbc:oracle:thin:@Worf.radford.edu:1521:itec3";

    private DataSource() {
        textIO = TextIO.getInstance();
    }

    private DataSource(String[] args) {
        this.textIO = TextIO.getInstance();
        this.user = args[0];
        this.pass = args[1];
    }

    public static DataSource getInstance() {
        return new DataSource();
    }

    public void initialize(String[] args) {
        this.user = args[0];
        this.pass = args[1];
        if (instance == null) {
            synchronized (DataSource.class) {
                if (instance == null) {
                    instance = new DataSource(args);
                }
            }
        }
    }

    private Connection openConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, user, pass);
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

    public int reserve_em(String firstFID, String res2, String res3, String res4) {

        int status = 0;
        int resem_cust_id = 5;
        int resem_param_2 = 3;
        int resem_param_3 = 4;

        try (
                Connection conn = openConnection();
                CallableStatement cs = conn.prepareCall("{? = call reserve.reserve_em(?,?,?,?)}")
        ) {

            cs.registerOutParameter(1, Types.INTEGER);

            cs.setLong(2, Long.parseLong(firstFID));

            if(res3 == null && res4 == null) {

                cs.setLong(resem_param_2, -1);
                cs.setLong(resem_param_3, -1);
                cs.setLong(resem_cust_id, Long.parseLong(res2));

            } else if (res4 == null) {

                cs.setLong(resem_param_3, -1);
                cs.setLong(resem_param_2, Long.parseLong(res2));
                cs.setLong(resem_cust_id, Long.parseLong(res3));

            } else {
                cs.setLong(resem_param_2, Long.parseLong(res2));
                cs.setLong(resem_param_3, Long.parseLong(res3));
                cs.setLong(resem_cust_id, Long.parseLong(res4));
            }

            cs.executeUpdate();
            status = cs.getInt(1);
            System.out.println("status: " + status);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return status;
    }



    public AirportsDAO listAirports() {

        // get all airports with select statement
        String airportsQuery = "SELECT * FROM Airports_MV";
        AirportsDAO aDAO = null;
        try (
                Connection conn = openConnection();
                Statement stmt = conn.createStatement();
                ResultSet rset = stmt.executeQuery(airportsQuery)) {

            aDAO = new AirportsDAO();

            while (rset.next()) {
                aDAO.addAirport(
                        new Airport(rset.getString("airport_code"), rset.getString("city"), rset.getString("state")));
            }

        } catch (SQLException e) {
            textIO.display("Could not retrieve airport list from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return aDAO;
    }

    public int find_open_seat(long fid) {
        int open_seat = -1;
        try (
                Connection conn = openConnection();
                CallableStatement cs = conn.prepareCall("{? = call find_open_seat(?)}")) {
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setLong(2, fid);
            cs.executeUpdate();
            open_seat = cs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }

        return open_seat;
    }

    public int reserveFlight(long cust_id, long fid, short seat, double ticketPrice) {

        int status = -1;

        try (
                Connection conn = openConnection();
                CallableStatement cs = conn.prepareCall("{call reserve_flight(?,?,?,?)}")) {
            cs.setLong(1, cust_id);
            cs.setLong(2, fid);
            cs.setShort(3, seat);
            cs.setDouble(4, ticketPrice);
            status = cs.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return status;
    }

    public Customer findCustomer(long custID) {

        String custQuery = "SELECT * FROM Customers WHERE Cust_ID = ?";
        Customer cust = null;

        try (
                Connection conn = openConnection();
                PreparedStatement getCustomer = conn.prepareStatement(custQuery)) {
            getCustomer.setLong(1, custID);
            ResultSet rset = getCustomer.executeQuery();
            if (rset.next()) {
                cust = new Customer(rset.getLong("cust_ID"), rset.getString("first_name"), rset.getString("last_name"),
                        rset.getDouble("balance"));
            }
        } catch (SQLException e) {
            textIO.display("Could not retrieve customer from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return cust;
    }

    public Itenerary findDirectFlight(String depart, String arrive) {

        String flightsQuery = "SELECT * FROM Flight_Info_LV WHERE dep_airport = ? AND dest_airport = ? ";
        Itenerary fDAO = null;

        try
                (
                        Connection conn = openConnection();
                        PreparedStatement queryDirectFlights = conn.prepareStatement(flightsQuery)) {
            queryDirectFlights.setString(1, depart);
            queryDirectFlights.setString(2, arrive);
            ResultSet rset = queryDirectFlights.executeQuery();
            fDAO = new Itenerary();
            while (rset.next()) {
                fDAO.addFlight(
                        new Flight(rset.getLong("FID"), rset.getString("dep_airport"), rset.getString("dest_airport"),
                                rset.getDate("dep_date"), rset.getDate("arrival_date"), rset.getShort("Open_Seats")));
            }
        } catch (SQLException e) {
            textIO.display("Could not retrieve flight list from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return fDAO;
    }

    public Flight findDirectFlight(long FID) {

        String flightsQuery = "SELECT * FROM Flight_Info_LV WHERE FID = ?";
        Flight flight = null;

        try (
                Connection conn = openConnection();
                PreparedStatement queryDirectFlights = conn.prepareStatement(flightsQuery)) {
            queryDirectFlights.setLong(1, FID);
            ResultSet rset = queryDirectFlights.executeQuery();
            if (rset.next()) {
                flight = new Flight(rset.getLong("FID"), rset.getString("dep_airport"), rset.getString("dest_airport"),
                        rset.getDate("dep_date"), rset.getDate("arrival_date"), rset.getShort("Open_Seats"));

            }
        } catch (SQLException e) {
            textIO.display("Could not retrieve flight list from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return flight;
    }

    public Itenerary getAllFlights() {

        String flightsQuery = "SELECT * FROM Flight_Info_LV";
        Itenerary itenerary = null;
        try {

            Connection conn = openConnection();
            Statement stmt = conn.createStatement();
            ResultSet rset = stmt.executeQuery(flightsQuery);
            itenerary = new Itenerary();

            while (rset.next()) {
                itenerary.addFlight(
                        new Flight(rset.getLong("FID"), rset.getString("dep_airport"),
                                rset.getString("dest_airport"), rset.getDate("dep_date"),
                                rset.getDate("arrival_date"), rset.getShort("Open_Seats")));
            }
        } catch (SQLException e) {
            textIO.display("Could not retrieve flight list from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return itenerary;
    }


    public Ticket getTicket(long ticketNo) {

        Ticket ticket = null;
        String ticketsQuery = "SELECT * FROM Tickets WHERE ticket_No = ?";

        try (
                Connection conn = openConnection();
                PreparedStatement queryTickets = conn.prepareStatement(ticketsQuery)) {
            queryTickets.setLong(1, ticketNo);
            ResultSet rset = queryTickets.executeQuery();
            ticket = new Ticket(ticketNo);
            rset.next();
            ticket.setCustID(rset.getLong("cust_id"));
            ticket.setPurchaseDate(rset.getDate("purchase_date"));
            ticket.setPrice(rset.getDouble("price"));
        } catch (SQLException e) {
            textIO.display("Could not retrieve flight list from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return ticket;
    }

    public Legs getLegs(long ticketNo) { // All legs for a single ticket

        Legs legs = null;
        String legsQuery = "SELECT FID FROM Legs WHERE ticket_No = ?";
        try (
                Connection conn = openConnection();
                PreparedStatement queryLegs = conn.prepareStatement(legsQuery)) {
            queryLegs.setLong(1, ticketNo);
            ResultSet rset = queryLegs.executeQuery();
            legs = new Legs(ticketNo);
            while (rset.next()) {
                legs.addFID(rset.getLong("FID"));
            }
        } catch (SQLException e) {
            textIO.display("Could not retrieve flight list from the database: " + e);
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return legs;
    }

    public String insertCustomer(String firstName, String lastName, double balance) {
        String insertQuery = "INSERT INTO Customers (Cust_ID, first_name, last_name, balance) VALUES (cust_seq.NEXTVAL, ?, ?, ?)";

        try (
                Connection conn = openConnection();
                PreparedStatement insertCustomer = conn.prepareStatement(insertQuery)) {
            insertCustomer.setString(1, firstName);
            insertCustomer.setString(2, lastName);
            insertCustomer.setDouble(3, balance);

            int rowsAffected = insertCustomer.executeUpdate();

            if (rowsAffected > 0) {
                return "Customer added successfully!\n";
            } else {
                return "Failed to add customer.";
            }
        } catch (SQLException e) {
            return "Error inserting customer: " + e.getMessage();
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
    }

    public String insertAirport(String airportCode, String city, String state) {
        String insertQuery = "INSERT INTO Airports (airport_code, city, state) VALUES (?, ?, ?)";

        try (
                Connection conn = openConnection();
                PreparedStatement insertAirport = conn.prepareStatement(insertQuery)) {
            insertAirport.setString(1, airportCode);
            insertAirport.setString(2, city);
            insertAirport.setString(3, state);

            int rowsAffected = insertAirport.executeUpdate();

            if (rowsAffected > 0) {
                return "Airport added successfully!\n";
            } else {
                return "Failed to add airport.";
            }
        } catch (SQLException e) {
            return "Error inserting airport: " + e.getMessage();
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
    }

    public int scheduleFlight(String depCode, Date depDate, String arrCode, Date arrDate, short rows, short seatsPer,
                              double price) {
        int status = -1;


        try (
                Connection conn = openConnection();
                CallableStatement cs = conn.prepareCall("{call schedule_flight(?,?,?,?,?,?,?)}")) {
            if (!isAirportExists(depCode) || !isAirportExists(arrCode)) {
                throw new IllegalArgumentException("Departure or Arrival airport does not exist.");
            }
            cs.setDate(1, depDate);
            cs.setString(2, depCode.strip());
            cs.setDate(3, arrDate);
            cs.setString(4, arrCode.strip());
            cs.setShort(5, rows);
            cs.setShort(6, seatsPer);
            cs.setDouble(7, price);
            status = cs.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Error scheduling flight: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
        }
        return status;
    }

    // Helper method to check if an airport exists in the airport table
    private boolean isAirportExists(String airportCode) throws SQLException {
        String query = "SELECT COUNT(*) FROM Airports WHERE airport_code = ?";
        try ( Connection conn = openConnection();
                PreparedStatement statement = conn.prepareStatement(query)) {
            statement.setString(1, airportCode);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    int count = resultSet.getInt(1);
                    return count > 0;
                }
            }
        }
        return false;
    }

} // End class