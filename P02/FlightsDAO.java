import java.util.ArrayList;

// The only purpose of this class is to maintain separation between the
// data retrieved from the DB and its access and use by the controller

public class FlightsDAO {

	private ArrayList<Flight> flightsList;
		
	public FlightsDAO() {
		this.flightsList = new ArrayList<>();
	}
	
	@Override
	public String toString() {
		return "FlightsDAO [flightsList=" + flightsList + "]";
	}

	public void addFlight(Flight f) {
		flightsList.add(f);
	}

	public ArrayList<Flight> getFlightsList() {
		return flightsList;
	}

	public void setFlightsList(ArrayList<Flight> flightsList) {
		this.flightsList = flightsList;
	} 
	
}
