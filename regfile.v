// Implements 8 registers of 16-bits each
module register(writenum, write, data_in, clk, readnum, data_out, R0out);
	input [2:0] writenum, readnum; 
	input write, clk;
	input [15:0] data_in;
	output [15:0] data_out, R0out;
	
	wire [7:0] writenumOH, readnumOH;
	wire [15:0] R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
		
	decoder #(3, 8) writenumDEC(writenum, writenumOH);
	
	decoder #(3, 8) readnumDEC(readnum, readnumOH);

	vDFFE #(16) R0(clk, writenumOH[0] & write, data_in, R0out);
	vDFFE #(16) R1(clk, writenumOH[1] & write, data_in, R1out);
	vDFFE #(16) R2(clk, writenumOH[2] & write, data_in, R2out);
	vDFFE #(16) R3(clk, writenumOH[3] & write, data_in, R3out);
	vDFFE #(16) R4(clk, writenumOH[4] & write, data_in, R4out);
	vDFFE #(16) R5(clk, writenumOH[5] & write, data_in, R5out);
	vDFFE #(16) R6(clk, writenumOH[6] & write, data_in, R6out);
	vDFFE #(16) R7(clk, writenumOH[7] & write, data_in, R7out);
	
	Mux8 #(16) mux8_0(R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, readnumOH, data_out);
endmodule

// Adapted from Slide 50 of Slide Set 7
// Implements a register with load enable
module vDFFE(clk, load, in, out);
	parameter n = 1; // width
	input clk, load;
	input 	[n-1:0] in;
	output 	[n-1:0] out;
	reg		[n-1:0] out;
	wire	[n-1:0] next_out;
	
	assign next_out = load ? in : out;
		
	always @(posedge clk)
		out = next_out;	
endmodule

// Adapted from Slide 50 of Slide Set 4
// Two input k-wide mux with binary select
module Mux2(a0, a1, s, b);
	parameter k = 1;
	
	input [k-1:0] 	a0, a1; // inputs
	input 			s; // binary select
	output [k-1:0]	b;
	
	wire [k-1:0] b = s ? a0 : a1;
endmodule

// Adapted from Slide 50 of Slide Set 4
// 8 input k-wide MUX with one-hot select
module Mux8(a0, a1, a2, a3, a4, a5, a6, a7, s, b);
	parameter k = 1;
	
	input [k-1:0] 	a0, a1, a2, a3, a4, a5, a6, a7;
	input [7:0]		s; // one-hot select
	output [k-1:0]	b;
	
	wire [k-1:0] b = ({k{s[0]}} & a0) |
					 ({k{s[1]}} & a1) |
					 ({k{s[2]}} & a2) |
					 ({k{s[3]}} & a3) |
					 ({k{s[4]}} & a4) |
					 ({k{s[5]}} & a5) |
					 ({k{s[6]}} & a6) |
					 ({k{s[7]}} & a7) ;
endmodule

// This code is from Slide 37 of Slide Set 4
// a - binary input 	(n bits wide)
// b - one hot output	(m bits wide)
module decoder(a, b);
	parameter n = 2;
	parameter m = 4;
	
	input 	[n-1:0] a;
	output 	[m-1:0] b;
	
	wire [m-1:0] b = 1<<a;
endmodule
