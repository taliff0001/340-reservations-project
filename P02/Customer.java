
public class Customer {

	private long custID; //You said biggest numerical data type possible, yes?
	private String first; 
	private String last;
	private double balance;	
	
	public Customer(long custID, String first, String last, double balance) {
		this.custID = custID;
		this.first = first;
		this.last = last;
		this.balance = balance;
	}
	
	@Override
	public String toString() {
		return "Customer [custID=" + custID + ", first="
	+ first + ", last=" + last + ", balance=" + balance + "]";
	}

	public long getCustID() {
		return custID;
	}
	public void setCustID(long custID) {
		this.custID = custID;
	}
	public String getFirst() {
		return first;
	}
	public void setFirst(String first) {
		this.first = first;
	}
	public String getLast() {
		return last;
	}
	public void setLast(String last) {
		this.last = last;
	}
	public double getBalance() {
		return balance;
	}
	public void setBalance(double balance) {
		this.balance = balance;
	}
	
	
}