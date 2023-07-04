
import java.util.Date;

public class Flight {

	private long FID;
	private String departureAirportCode;
	private String arrivalAirportCode;
	private Date departureTime;
	private Date arrivalTime;
	private short openSeats;
	
	public Flight(long fID, String departureAirportCode, String arrivalAirportCode, Date departureTime,
			Date arrivalTime, short openSeats) {
		FID = fID;
		this.departureAirportCode = departureAirportCode;
		this.arrivalAirportCode = arrivalAirportCode;
		this.departureTime = departureTime;
		this.arrivalTime = arrivalTime;
		this.openSeats = openSeats;
	}
	@Override
	public String toString() {
		return "Flights [FID=" + FID + ", departureAirportCode=" + departureAirportCode + ", arrivalAirportCode="
				+ arrivalAirportCode + ", departureTime=" + departureTime + ", arrivalTime=" + arrivalTime
				+ ", openSeats=" + openSeats + "]";
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
	
	
}
