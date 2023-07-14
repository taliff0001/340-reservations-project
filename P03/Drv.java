
public class Drv {

	public static void main(String[] args) {

		DataSource dataSource = DataSource.getInstance(); //Return uninitialized class instance
		dataSource.openConnection(args); //Singleton initialization with name/pass
		Ctrl control = new Ctrl(); //Default constructor
		control.beginMainLoop(dataSource); //Body of program		
		dataSource.closeConn();		
	}

}

