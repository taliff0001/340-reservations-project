package airports;


class Ctrl {
		
	public Ctrl(String[] args) {
		
		DataSource datasource = DataSource.getInstance(); //Return uninitialized class instance
		datasource.openConnection(args)
	}
		
		public void beginMainLoop(){
		
			TextIO textIO = TextIO.getInstance(); // 2 Methods - display and prompt
			String prompt = ">";
			String consoleIn = textIO.prompt(prompt);
			String[] parsed = input.split("\\s+");
			
			String cmd = parsed[0];
			String param1 = null;
			String param2 = null;			
			
			if(parsed.length >= 2)
				param1 = parsed[1];
			if(parsed.length == 3)
				param2 = parsed[2];
			
			switch(cmd){
				
				case "help":
					help();
				case "quit":
					quit();
				case "lst":
					listAirports();
					break;
				case "fnd":
					findDirectFlight(param1, param2);
					break;
				case "prt":
					printTicket(param1); //need a cast here
				
			}




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