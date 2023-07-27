
import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

public class Flight {

	private long FID;
	private String departureAirportCode;
	private String arrivalAirportCode;
	private Date departureTime;
	private Date arrivalTime;
	private String dateAndTimeDepart;
	private String timeArrive;
	private String justDepartureTime;
	
	private short openSeats;
	
	public Flight(long fID, String departureAirportCode, String arrivalAirportCode, Date departureTime,
			Date arrivalTime, short openSeats) {
		FID = fID;
		this.departureAirportCode = departureAirportCode;
		this.arrivalAirportCode = arrivalAirportCode;
		this.departureTime = departureTime;
		this.arrivalTime = arrivalTime;
		this.openSeats = openSeats;
		DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
		this.dateAndTimeDepart = df.format(departureTime);
		df = DateFormat.getTimeInstance(DateFormat.SHORT);
		this.setTimeArrive(df.format(arrivalTime));
		this.justDepartureTime = df.format(departureTime);		
	}
	
	@Override
	public String toString() {
		return  getFID() + "\t" + getDepartureAirportCode() + "\t" + getDateDepart() + " " + getJustDepartureTime() + "\t"
				+ getArrivalAirportCode() + "\t" + getTimeArrive() + "\t" + getOpenSeats() + "\n";
	}

	public long getFID() {
		return FID;
	}
	public void setFID(long fID) {
		FID = fID;
	}
	public String getDepartureAirportCode() {
		return departureAirportCode;
	}
	public void setDepartureAirportCode(String departureAirportCode) {
		this.departureAirportCode = departureAirportCode;
	}
	public String getArrivalAirportCode() {
		return arrivalAirportCode;
	}
	public void setArrivalAirportCode(String arrivalAirportCode) {
		this.arrivalAirportCode = arrivalAirportCode;
	}
	public Date getDepartureTime() {
		return departureTime;
	}
	public void setDepartureTime(Date departureTime) {
		this.departureTime = departureTime;
	}
	public Date getArrivalTime() {
		return arrivalTime;
	}
	public void setArrivalTime(Date arrivalTime) {
		this.arrivalTime = arrivalTime;
	}
	public short getOpenSeats() {
		return openSeats;
	}
	public void setOpenSeats(short openSeats) {
		this.openSeats = openSeats;
	}
	public String getDateDepart() {
		return dateAndTimeDepart;
	}
	public void setDateAndTimeDepart(String dateAndTimeDepart) {
		this.dateAndTimeDepart = dateAndTimeDepart;
	}
//	public String getDateAndTimeArrive() {
//		return dateAndTimeArrive;
//	}
//	public void setDateAndTimeArrive(String dateAndTimeArrive) {
//		this.dateAndTimeArrive = dateAndTimeArrive;
//	}
	public String getJustDepartureTime() {
		return justDepartureTime;
	}
	public void setJustDepartureTime(String justDepartureTime) {
		this.justDepartureTime = justDepartureTime;
	}

	public String getTimeArrive() {
		return timeArrive;
	}

	public void setTimeArrive(String timeArrive) {
		this.timeArrive = timeArrive;
	}
	
	
}
