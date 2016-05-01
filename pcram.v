module pcram(LERBout, datapath_out, clk, loadpc, reset, mwrite, msel, loadir, IRout);
	input loadpc, reset, msel, loadir, mwrite, clk;
	input [15:0] LERBout, datapath_out;
	wire [7:0] PCout, counterOut, loadpcMuxOut, resetMuxOut, addr;
	wire [15:0] mdata;
	output [15:0] IRout;
	
	Mux2 #(8) loadpcMux(PCout + 1'b1, PCout, loadpc, loadpcMuxOut);
	Mux2 #(8) resetMux(8'b00000000, loadpcMuxOut, reset, resetMuxOut);
	vDFF #(8) PC(clk, resetMuxOut, PCout);
	Mux2 #(8) mselMux(datapath_out[7:0], PCout, msel, addr);
	RAM #(16, 8) memory(clk, addr, addr, mwrite, LERBout, mdata);
	vDFFE #(16) IR(clk, loadir, mdata, IRout);
	
endmodule