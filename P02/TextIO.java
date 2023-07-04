
/**
 * This class handles all user interaction. 
 * @author Jeff Pittges
 * @version 29-MAY-2021
 */

import java.util.*;

public class TextIO {

	private Scanner scan;
	
	private TextIO() 
	  {
		this.scan = new Scanner(System.in); 
	  }
	  
	private static volatile TextIO instance;
	
	 public static TextIO getInstance() {
	   if (instance == null) {
		 synchronized (TextIO.class)
		 {
			 if (instance == null){
				instance = new TextIO();
			 }
		 }
	   }
	   return instance;
	  }
 

  public void display(String msg) 
  {
    System.out.print(msg);
  }

  public String prompt(String msg) 
  {
    this.display(msg); 
    return this.scan.nextLine(); 
  }
}

