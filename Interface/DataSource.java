import java.sql.*;

public class DataSource {

    private String user;
    private String pass;
    private Connection conn;
	
	private static volatile DataSource instance;

	public DataSource(String[] args) {
        this.user = args[0];
        this.pass = args[1];
        conn = null;

        try {
            conn = DriverManager.getConnection("jdbc:oracle:thin:@Worf.radford.edu:1521:itec3", user, pass);
        } catch (SQLException e) {
            System.out.println("Could not establish a connection to the database: " + e);
        }
    }

	public static DataSource getInstance(String[] args) {
	   if (instance == null) {
		 synchronized (DataSource.class)
		 {
			 if (instance == null){
				instance = new DataSource(args);
			 }
		 }
	   }
	   return instance;
	  }

/*     public String empList() {
        String employeeList = "";
        String query = "SELECT fname, lname FROM employees ORDER BY fname";

        try (Statement stmt = conn.createStatement();
             ResultSet rset = stmt.executeQuery(query)) {
            while (rset.next()) {
                employeeList += rset.getString("fname") + " " + rset.getString("lname") + ", ";
            }
        } catch (SQLException e) {
            System.out.println("Could not retrieve employee list from the database: " + e);
        }
        employeeList = employeeList.substring(0, employeeList.length() - 2).strip();
        return employeeList;
    } */

    public String empList(String optional) {
		
        String employeeList = "";
		String query = "";
		
		if(optional != null && optional.equals("-i")){
			query = "SELECT * FROM employees ORDER BY fname";

			try (Statement stmt = conn.createStatement();
				 ResultSet rset = stmt.executeQuery(query)) {
				while (rset.next()) {
					employeeList += rset.getString("empid") + " | " + rset.getString("fname") + " | " + rset.getString("lname") + "\n";
				}
			} catch (SQLException e) {
				System.out.println("Could not retrieve employee list from the database: " + e);
			}
		}
		else if (optional != null && optional.equals("-a")){
			query = "SELECT * FROM employees ORDER BY fname";

			try (Statement stmt = conn.createStatement();
				 ResultSet rset = stmt.executeQuery(query)) {
				while (rset.next()) {
					employeeList += rset.getString("empID") + " | " + rset.getString("fname") + " | " + rset.getString("lname")
					+ " | " + rset.getString("sex") + rset.getString("dept") + " | " + rset.getString("phone")  + " | " + rset.getString("salary") + "\n";
				}
			} catch (SQLException e) {
				System.out.println("Could not retrieve employee list from the database: " + e);
			}
		}
		else{
			query = "SELECT * FROM employees ORDER BY fname";

			try (Statement stmt = conn.createStatement();
				 ResultSet rset = stmt.executeQuery(query)) {
				while (rset.next()) {
					employeeList += rset.getString("fname") + " | " + rset.getString("lname") + "\n";
				}
			} catch (SQLException e) {
				System.out.println("Could not retrieve employee list from the database: " + e);
			}
		}
        return employeeList;
    }

    public void close() {
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
