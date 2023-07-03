import java.util.Arrays;

public class AirportsDAO {

	private Airports[] airports;
	
	public AirportsDAO(Airports[] aa) {
		airports = aa;
	}

	@Override
	public String toString() {
		return "AirportsDAO [airports=" + Arrays.toString(airports) + "]";
	}

	public Airports[] getAirports() {
		return airports;
	}

	public void setAirports(Airports[] airports) {
		this.airports = airports;
	}
	
}