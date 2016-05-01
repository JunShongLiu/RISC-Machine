module lab7_top(CLOCK_50, KEY, LEDR);
	input [3:0] KEY;
	output [9:0] LEDR; 
	
	input CLOCK_50;
				 
	cpu CPU0(~KEY[1], ~KEY[0], LEDR[9:0]);
	
endmodule