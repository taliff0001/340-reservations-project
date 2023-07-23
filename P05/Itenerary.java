import java.util.ArrayList;

public class Itenerary {

	private ArrayList<Flight> flightsList;
		
	public Itenerary() {
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
