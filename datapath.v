module datapath(clk, tsel, incp, execb, cond, readnum, sximm5, sximm8, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, status, 
				reset, mwrite, msel, loadir, IRout, LEDin);
	input clk, loada, loadb, asel, bsel, loadc, loads, write, tsel, incp, execb;
	input [15:0] sximm5, sximm8;
	input [1:0] shift, ALUop, vsel;
	input [2:0] readnum, writenum, cond;
	output [2:0] status;
	output [15:0] IRout;
	output [9:0] LEDin;
	wire [15:0] datapath_out;
	
	input reset, msel, loadir, mwrite;
	wire [7:0] PCout, counterOut, loadpcMuxOut, resetMuxOut, addr, pcrel, pctgt, pc_next;
	wire [15:0] mdata,sximm5,sximm8, R0out;
	
	`define MAin 16'b0000000000000000 
	
	wire [15:0] data_in, data_out, LERAout, LERBout, Ain, S0out, Bin, ALUout;
	wire ALUSout, ALUOout, loadpc, taken;
	
	assign LEDin = R0out[9:0];
	
	// Selects between the datapath_in and datapath_out
	Mux4 #(16) M4(mdata, sximm8, {8'b00000000,PCout}, datapath_out, vsel, data_in);
	// MUX for A with 16'b0
	Mux2 #(16) MA(`MAin, LERAout, asel, Ain);
	// MUX for B with {11'b0, datapath_in[4:0]}
	Mux2 #(16) MB(sximm5, S0out, bsel, Bin);
	
	// Main register
	register R0(writenum, write, data_in, clk, readnum, data_out, R0out);
	
	// Load-enabled register for A
	vDFFE #(16) LERA(clk, loada, data_out, LERAout);
	// Load-enabled register for B
	vDFFE #(16) LERB(clk, loadb, data_out, LERBout);
	// status
	vDFFE #(3) LERS(clk, loads, {ALUSout,ALUout[15],ALUOout}, status);
	// Load-enabled register for C
	vDFFE #(16) LERC(clk, loadc, ALUout, datapath_out);
	
	// Shifter
	shifter S0(shift, LERBout, S0out);
	
	// ALU
	Alu ALU0(Ain, Bin, ALUop, ALUout, ALUSout, ALUOout);	
	
	// PC and RAM
	Mux2 #(8) loadpcMux(pc_next, PCout, loadpc, loadpcMuxOut);
	Mux2 #(8) resetMux(8'b00000000, loadpcMuxOut, reset, resetMuxOut);
	vDFF #(8) PC(clk, resetMuxOut, PCout);
	Mux2 #(8) mselMux(datapath_out[7:0], PCout, msel, addr);
	RAM #(16, 8) memory(clk, addr, addr, mwrite, LERBout, mdata);
	vDFFE #(16) IR(clk, loadir, mdata, IRout);
	
	// Added in Lab 7
	Adder3 #(8) ADD0(sximm8[7:0], PCout, pcrel);
	Mux2 #(8) PCTGTMux(pcrel, LERAout[7:0], tsel, pctgt);
	Mux2 #(8) PC_NEXTMux(PCout + 1'b1, pctgt, incp, pc_next);
	
	branchUnit Branch(execb, status, cond, taken);
	
	assign loadpc = incp | taken;
endmodule

// adapted from Slide 17 of SS8
module Adder3(a,b,s) ;
	parameter n = 8 ;
	input [n-1:0] a, b ;
	output [n-1:0] s ;
	wire [n-1:0] s;

	assign s = a + b;
endmodule 

module Adder1(a,b,cin,cout,s) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 


module branchUnit(execb, status, cond, taken);
	input execb;
	input [2:0] status, cond;
	output taken;
	
	reg taken;
	
	always @(*) begin
		casex({execb, status, cond})
			7'b1xxx000: taken = 1'b1;
			
			7'b11xx001: taken = 1'b1;
			
			7'b10xx010: taken = 1'b1;
			
			7'b1x10011: taken = 1'b1;
			7'b1x01011: taken = 1'b1;
			
			7'b11xx100: taken = 1'b1;
			7'b1x10100: taken = 1'b1;
			7'b1x01100: taken = 1'b1;
			
			7'b1xxx111: taken = 1'b1;
			default: taken = 1'b0;
		endcase
	end
endmodule

	