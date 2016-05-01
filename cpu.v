module cpu(clk, reset, LEDin);
	input clk, reset;
	output [9:0] LEDin;
	wire [8:0] TBD;
	wire [1:0] mwriting, vsel, shift, ALUop, op;
	wire [2:0] readnum, writenum, status, opcode, nsel, cond;
	wire [15:0] IRout, sximm5, sximm8;
	wire execb, tsel;
	
	datapath DP0(.clk(clk), .tsel(tsel), .incp(incp), .execb(execb), .cond(cond), .readnum(readnum), .sximm5(sximm5), .sximm8(sximm8), .vsel(TBD[8:7]), .loada(TBD[5]), .loadb(TBD[4]), .shift(shift), 
				.asel(TBD[2]), .bsel(TBD[1]), .ALUop(ALUop), .loadc(TBD[3]), .loads(TBD[0]), .writenum(writenum), .write(TBD[6]),  
				.status(status), .reset(reset), .mwrite(mwriting[1]), .msel(mwriting[0]), .loadir(loadir), .IRout(IRout),
				.LEDin(LEDin));
		
	controller C0(.clk(clk), .reset(reset), .opcode(opcode), .op(op), .nsel(nsel), .loadir(loadir), .incp(incp), .TBD(TBD), .mwriting(mwriting),
				.execb(execb), .tsel(tsel));
	
	instructionDecoder ID0(IRout, nsel, opcode, op, writenum, readnum, shift, sximm8, sximm5, ALUop, cond);
endmodule

module controller(clk, reset, opcode, op, nsel, loadir, incp, TBD, mwriting, execb, tsel);
	input clk, reset;
	input [2:0] opcode;
	input [1:0] op;
	output loadir, incp, execb, tsel;
	output [2:0] nsel;
	output [8:0] TBD;
	output [1:0] mwriting;
	
	wire [3:0] state;
	reg [3:0] nextstate;	
	reg loadir, incp, execb, tsel;
	reg [2:0] nsel;
	reg [8:0] TBD;
	reg [1:0] mwriting;
	
	
	`define MOV 5'b11010
	`define MOVS 5'b11000
	`define ADD 5'b10100
	`define CMP 5'b10101
	`define AND 5'b10110
	`define MVN 5'b10111
	`define LDR 5'b01100
	`define STR 5'b10000	
	
	`define BRANCH 5'b00100
	`define BL 5'b01011
	`define BX 5'b01000
	`define BLX 5'b01010
	`define HALT 5'b111xx
	
	
	vDFF #(4) vDFF0(clk, nextstate, state); 
	
	always @(*) begin
		casex({opcode, op, state})
			{5'bxxxxx, 4'b0000}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b1, 1'b0, 9'b000000000, 2'b00, 4'b0001, 1'b0, 1'b1};
			{5'bxxxxx, 4'b0001}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b1, 1'b0, TBD, 2'b00, 4'b0010, 1'b0, 1'b1};
			{5'bxxxxx, 4'b0010}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b1, TBD, 2'b00, 4'b0011, 1'b0, 1'b1};
			
			{`MOV, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b101000000, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`MOVS, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b001, 1'b0, 1'b0, 9'b000010100, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`MOVS, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000001100, 2'b00, 4'b0101, 1'b0, 1'b1};
			{`MOVS, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b001001100, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`ADD, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000100000, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`ADD, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b001, 1'b0, 1'b0, 9'b000010000, 2'b00, 4'b0101, 1'b0, 1'b1};	
			{`ADD, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000001000, 2'b00, 4'b0110, 1'b0, 1'b1};	
			{`ADD, 4'b0110}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b001001000, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`CMP, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000100000, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`CMP, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b001, 1'b0, 1'b0, 9'b000010000, 2'b00, 4'b0101, 1'b0, 1'b1};
			{`CMP, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b001, 1'b0, 1'b0, 9'b000000001, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`AND, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000100000, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`AND, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b001, 1'b0, 1'b0, 9'b000010000, 2'b00, 4'b0101, 1'b0, 1'b1};
			{`AND, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000001000, 2'b00, 4'b0110, 1'b0, 1'b1};
			{`AND, 4'b0110}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b001001000, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`MVN, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b001, 1'b0, 1'b0, 9'b000010100, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`MVN, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000001100, 2'b00, 4'b0101, 1'b0, 1'b1};
			{`MVN, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b001001100, 2'b00, 4'b0000, 1'b0, 1'b1};
						
			{`LDR, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000100010, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`LDR, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000001010, 2'b00, 4'b0101, 1'b0, 1'b1};
			{`LDR, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000001010, 2'b01, 4'b0110, 1'b0, 1'b1};
			{`LDR, 4'b0110}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0111, 1'b0, 1'b1};
			{`LDR, 4'b0111}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b111000000, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`STR, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000100010, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`STR, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000001010, 2'b00, 4'b0101, 1'b0, 1'b1};
			{`STR, 4'b0101}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000010000, 2'b01, 4'b0110, 1'b0, 1'b1};
			{`STR, 4'b0110}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000000000, 2'b11, 4'b0111, 1'b0, 1'b1};
			{`STR, 4'b0111}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`BRANCH, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0100, 1'b1, 1'b1};
			{`BRANCH, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1};
			
			{`BL, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b011000000, 2'b00, 4'b0100, 1'b0, 1'b1};
			{`BL, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0101, 1'b1, 1'b1};
			{`BRANCH, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1};

			{`BX, 4'b0011}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000100000, 2'b00, 4'b0100, 1'b0, 1'b0};
			{`BX, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000100000, 2'b00, 4'b0000, 1'b1, 1'b0};
			{`BX, 4'b0100}: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = reset ? {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1} : {3'b010, 1'b0, 1'b0, 9'b000100000, 2'b00, 4'b0000, 1'b0, 1'b0};
			
			default: {nsel, loadir, incp, TBD, mwriting, nextstate, execb, tsel} = {3'b100, 1'b0, 1'b0, 9'b000000000, 2'b00, 4'b0000, 1'b0, 1'b1};
		endcase
	end
endmodule

module instructionDecoder(IRout, nsel, opcode, op, writenum, readnum, shift, sximm8, sximm5, ALUop, cond);
	input [15:0] IRout;
	input [2:0] nsel;
	output [2:0] opcode, writenum, readnum, cond;
	output [1:0] op, shift, ALUop;
	output [15:0] sximm8, sximm5;
	wire [4:0] imm5 = IRout[4:0];
	wire [7:0] imm8 = IRout[7:0];
	wire [2:0] Rn = IRout[10:8];
	wire [2:0] Rd = IRout[7:5];
	wire [2:0] Rm = IRout[2:0];
	wire [2:0] RMuxout;
	
	assign op = IRout[12:11];
	assign opcode = IRout[15:13];
	assign shift = IRout[4:3];
	assign ALUop = IRout[12:11];
	
	signExtend #(5, 16) SEimm5(imm5, sximm5);
	signExtend #(8, 16) SEimm8(imm8, sximm8);
	
	Mux3 #(3) RMux(Rn, Rd, Rm, nsel, RMuxout);
	
	assign cond = IRout[10:8];
	assign readnum = RMuxout;
	assign writenum = RMuxout;
	
endmodule

module signExtend(in, out);
	parameter n = 5;
	parameter m = 16;
	
	input [n-1:0] in;
	output [m-1:0] out;
	assign out[m-1:n] = {(m-n){in[n-1]}};
	assign out[n-1:0] = in;
	// assign out = {((m-n){in[n-1]}), in};
endmodule

module Mux3(a0, a1, a2, s, out);
	parameter n = 3;
	input [n-1:0] a0, a1, a2, s;
	output [n-1:0] out;
	reg [n-1:0] out;
	
	always @(*) begin
		casex(s)
			3'b1xx: out = a0;
			3'b01x: out = a1;
			3'b001: out = a2;
			default : out = {n{1'bx}};
		endcase
	end
endmodule