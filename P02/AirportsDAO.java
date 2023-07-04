
import java.util.ArrayList;

public class AirportsDAO {

	private ArrayList<Airport> airports;

	public AirportsDAO(){
		airports = new ArrayList<>();
	}
	
	@Override
	public String toString() {
		return "AirportsDAO [airports=" + airports + "]";
	}

	public void addAirport(Airport airport) {
		airports.add(airport);
	}	
	
	public ArrayList<Airport> getAirports() {
		return airports;
	}

	public void setAirports(ArrayList<Airport> airports) {
		this.airports = airports;
	}
	
}
