
class Ctrl {
	
		private DataSource ds;
		private TextIO textIO;
		private String queryRslt;
	
	public Ctrl(String[] args) {
		
		ds = DataSource.getInstance(args);
		
	}
		
		public void doStuff(){
		
			textIO = TextIO.getInstance();
		
			String promptMsg = "\nEnter \"lst\" to display all employees or \"ext\" to exit"
			+ "\nOptional arguments: \"-i\": display employee ID's, \"-a\": display all employee data";
		
			String input = textIO.prompt(promptMsg);
				
			String[] parsed = input.split("\\s+");
			
			String one = parsed[0];
			String two = null;			
			
			if(parsed.length > 1)
					two = parsed[1];
				
			while(!one.equals("ext")) {
			
				if(one.equals("lst")){								
					queryRslt = ds.empList(two);
					textIO.display("\nReturned:\n\n" + queryRslt);
			}
			
			input = textIO.prompt(promptMsg);
			parsed = input.split("\\s+");
			
			one = parsed[0];
			two = null;			
			
			if(parsed.length > 1)
					two = parsed[1];
			
		}
		ds.close();
	}

	
}