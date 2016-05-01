module Alu(Ain, Bin, AluOp, Cout, StatusOut, OverflowOut);
  input [15:0] Ain;
  input [15:0] Bin;
  input [1:0] AluOp;
  output [15:0] Cout;
  output StatusOut, OverflowOut;
  
  reg [15:0] Cout;
  wire [15:0] s;
  
  wire c1, c2 ;         // carry out of last two bits
  wire OverflowOut = c1 ^ c2 ;  // overflow if signs don't match

  `define Add 2'b00
  `define Minus 2'b01
  `define Anded 2'b10
  `define InvertB 2'b11
  
  always @(*) begin
	case(AluOp)
	  `Add:     Cout = Ain+Bin;
	  `Minus:   Cout = Ain-Bin;
	  `Anded:   Cout = Ain&Bin; 
	  `InvertB: Cout = ~Bin; 
	   default  Cout = 16'bxxxxxxxxxxxxxxxx;	
	endcase
  end

  // add non sign bits
  Adder1 #(15) ai(Ain[14:0],Bin[14:0]^{15{AluOp[0]}},AluOp[0],c1,s[14:0]) ;
  // add sign bits
  Adder1 #(1)   as(Ain[15],Bin[15]^AluOp[0],c1,c2,s[15]) ;
  
  assign StatusOut = ~(Cout[0]|Cout[1]|Cout[2]|Cout[3]|Cout[4]|Cout[5]|Cout[6]&Cout[7]|Cout[8]|Cout[9]|Cout[10]|Cout[11]|Cout[12]|Cout[13]|Cout[14]|Cout[15]);
  
endmodule

