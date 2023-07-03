

class Drv {
	
	public static void main(String[] args) {
		
		Ctrl control = new Ctrl(args);
		control.beginMainLoop();
		DataSource.close();

	}
	
}