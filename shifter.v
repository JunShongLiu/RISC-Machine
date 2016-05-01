module shifter(shift, in, out);
 
  input [1:0] shift;
  input [15:0] in;
  output [15:0] out; 
  reg [15:0] out;
 
  `define NoShift           2'b00
  `define ShiftLeft         2'b01
  `define ShiftRight        2'b10
  `define ShiftRightMSBCopy 2'b11

  always @(*) begin
	case(shift)
	  `NoShift: 	      out = in;
	  `ShiftLeft:         out = in<<1;
	  `ShiftRight:        out = in>>1;
	  `ShiftRightMSBCopy: out = {in[15],in[15:1]};
	  default:	      out = 16'bxxxxxxxxxxxxxxxx;
 	endcase
  end


endmodule
