module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "fib21.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);
  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule

// Counter adapted from Slide 51 of SS7
module Counter(clk,rst,out) ;
	parameter n = 8;
  input rst, clk ; // reset and clock
  output [n-1:0] out ;
  reg    [n-1:0] next ;

  vDFF #(n) count(clk, next, out) ;

  always@(rst) begin
    case(rst)
      1'b1: next = 0 ;
      1'b0: next = out+1 ;
    endcase
  end
endmodule


// Flip-Flop
module vDFF(clk, in, out) ;
  parameter n = 1;  // width
  input clk ;
  input [n-1:0] in ;
  output [n-1:0] out ;
  reg [n-1:0] out ;

  always @(posedge clk)
    out = in ;
endmodule

//Mux 4 
module Mux4(a0, a1, a2, a3, s, b);
  parameter k = 1;
  input [k-1:0] 	a0, a1, a2, a3;
  input [1:0]		s; // bin select
  output [k-1:0]	b;
  reg [k-1:0] b;

  always @(*) begin
	case(s)
	  2'b00: b=a3;
	  2'b01: b=a2;
	  2'b10: b=a1;
	  2'b11: b=a0;
	  default b=15'bxxxxxxxxxxxxxxx;
	endcase
  end
endmodule	
 
