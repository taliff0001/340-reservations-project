import java.util.ArrayList;

public class Legs {
	
	private long ticketNo;
	private ArrayList <Long> FIDs;
	
	public Legs(long ticketNo) {
		this.ticketNo = ticketNo;
		FIDs = new ArrayList<>();
	}

	@Override
	public String toString() {
		return "Legs [ticketNo=" + ticketNo + ", FIDs=" + FIDs + "]";
	}
	
	public void addFID(long fid) {
		FIDs.add(fid);
	}
	
	public long getTicketNo() {
		return ticketNo;
	}

	public void setTicketNo(long ticketNo) {
		this.ticketNo = ticketNo;
	}

	public ArrayList<Long> getFIDs() {
		return FIDs;
	}

	public void setFIDs(ArrayList<Long> fIDs) {
		FIDs = fIDs;
	}
	
}
