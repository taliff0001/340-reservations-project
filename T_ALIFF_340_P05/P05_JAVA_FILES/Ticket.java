import java.util.Date;

public class Ticket {

	private long ticketNum;
	private long custID;
	private Date purchaseDate;
	private double price;

	public Ticket() {
	}

	public Ticket(long ticketNum) {
		this.ticketNum = ticketNum;	
	}

	
	
	@Override
	public String toString() {
		return "Ticket [ticketNum=" + ticketNum + ", cust="+ custID
			+ ", purchaseDate=" + purchaseDate + ", price=" + price + "]";
	}

	public long getTicketNum() {
		return ticketNum;
	}

	public void setTicketNum(long ticketNum) {
		this.ticketNum = ticketNum;
	}

	public Date getPurchaseDate() {
		return purchaseDate;
	}

	public void setPurchaseDate(Date purchaseDate) {
		this.purchaseDate = purchaseDate;
	}

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}

	public long getCustID() {
		return custID;
	}

	public void setCustID(long custID) {
		this.custID = custID;
	}

}
