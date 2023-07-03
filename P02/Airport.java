
public class Airport {

	private String code;
	private String city;
	private String state;
	
	public Airport(String cd, String cty, String st) {
		this.code = cd;
		this.city = cty;
		this.state = st;
	}	
	
	@Override
	public String toString() {
		return "Airports [code=" + code + ", city=" + city + ", state=" + state + "]";
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}
	
}
