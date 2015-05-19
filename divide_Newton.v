/*******************************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________

--Module Name:divide_Newton
--Project Name:
--Chinese Description:
	牛顿除法
--English Description:
	Newtonian division
--Version:VERA.1.0.0
--Data modified:
--author:Young-吴明
--E-mail: wmy367@Gmail.com
--Data created:2013-7-30 16:30:30
________________________________________________________
********************************************************/
`timescale 1ns/1ps
module divide_Newton #(
parameter	DSIZE = 24,
			PN = 6									//control precision 越大精度越小
)(
	input					clock,
	input					rst,
	
	input [DSIZE-1:0]		N,
	input [DSIZE-1:0]		D,
	input					enable,
	
	output[DSIZE+DSIZE-1:0]	Q,
	output reg[5:0]			EXP,
	output reg				VALID,
	output reg				RDY
);

reg	[DSIZE-1:0]			fN;
reg [DSIZE-1:0]			fD;
reg	[4:0]				eN,eD;
reg	[DSIZE+DSIZE-1:0]	ans;

always@(N)begin
	int2float(N, eN, fN);		//dividend
end 
always@(D)begin
	int2float(D, eD, fD);		//divisor
end 

wire[DSIZE-1:0]		dataa;
reg [DSIZE-1:0]		datab;
reg	[DSIZE-1:0]		x,t,f;
assign				dataa	= f;
wire[2*DSIZE-1:0]	result;
localparam	S0 = 0,S1 = 1,S2 = 2,S3 = 3,
			S4 = 4,S5 = 5,S6 = 6,S7 = 7,
			S8 = 8,S9 = 9,S10= 10;

always@(posedge clock,posedge rst)begin:STATE
reg	[3:0]			state;
reg	[4:0]			En,Ed;
reg	[4:0]			count;
	if(rst)begin
		state	<= 0;
		count	<= 0;
		VALID	<= 0;
		RDY		<= 0;
		x		<= 0;
		t		<= 0;
	end else begin
		case(state)
		S0:begin
			if(enable)	state	<= S1;
			else		state	<= S0;
			Ed		<= eD;
			En		<= eN;
			EXP		<= eD-eN;
			x		<= fN;
			t		<= fD;
			count	<= 0;
			VALID	<= 0;
			RDY		<= !enable;
		end
		S1:begin
			state	<= S2;
			RDY		<= 0;
			datab	<= t;
			f		<= (1'b1<<DSIZE) - t;//TOW - t		the step could be put in pipeline
		end
		S2:begin
			state	<= S3;
			datab	<= x;
		end
		S3:begin
			state	<= S4;
		end
		S4:begin
			state	<= S5;
		end
		S5:begin
			state	<= S6;
		end
		S6:begin
			state	<= S8;
		end
		S7:begin
			state	<= S8;
		end
		S8:begin
			state	<= S9;
//			t		<= result>>(DSIZE-1);
			t		<= result[46:23];
		end
		S9:begin
//			x		<= result>>(DSIZE-1);
			x		<= result[46:23];
			f		<= (1'b1<<DSIZE) - t;//TOW - t		the step could be put in pipeline
			datab	<= t;
			count	<= count + 1'b1;
			RDY		<= 0;
			ans		<= result;
			EXP		<= Ed-En;
			if(count == 16 | t[DSIZE-1:PN] == 1'b1<<(DSIZE-PN-1) | t[DSIZE-1:PN] == ~(1'b1<<(DSIZE-PN-1)) )begin
					state	<= S10;
					VALID	<= 1;
			end else begin
				 	state	<= S2;
				 	VALID	<= 0;
			end
		end
		S10:begin
			state	<= S0;
			ans		<= result;
			EXP		<= Ed-En;
			VALID	<= 0;
			RDY		<= 1'b1;
		end
		default:;
		endcase
end end
/*******************end division******************/
assign	Q	= ans;

wire[23:0]	multa;
wire[23:0]	multb;

assign		multa	= {{(24-DSIZE){1'b0}},dataa};
assign		multb	= {{(24-DSIZE){1'b0}},datab};

multiplier mult(					//乘法器延时5个周期
	.clock		(clock),
	.clken		(1'b1),
	.aclr		(rst),
	.dataa		(multa),
	.datab		(multb),
	.result		(result)
);

task int2float;
input	[DSIZE-1:0]	INT;
output	[4:0]		E;
output	[DSIZE-1:0]	F;
begin
	casex(INT)	//
		{    1'b1,			{(DSIZE - 1){1'bx}} }:begin	F = INT		;E = 0;end
	//	{ {1{1'b0}},1'b1,	{(DSIZE - 2){1'bx}} }:begin	F = INT	<< 1;E = 1;end
		{ {1{1'b0}},1'b1,	{(DSIZE - 2){1'bx}} }:begin	F = INT	<< 1;E = 1;end
		{ {2{1'b0}},1'b1,	{(DSIZE - 3){1'bx}} }:begin	F = INT	<< 2;E = 2;end
		{ {3{1'b0}},1'b1,	{(DSIZE - 4){1'bx}} }:begin	F = INT	<< 3;E = 3;end
		{ {4{1'b0}},1'b1,	{(DSIZE - 5){1'bx}} }:begin	F = INT	<< 4;E = 4;end
		{ {5{1'b0}},1'b1,	{(DSIZE - 6){1'bx}} }:begin	F = INT	<< 5;E = 5;end
		{ {6{1'b0}},1'b1,	{(DSIZE - 7){1'bx}} }:begin	F = INT	<< 6;E = 6;end
		{ {7{1'b0}},1'b1,	{(DSIZE - 8){1'bx}} }:begin	F = INT	<< 7;E = 7;end
		{ {8{1'b0}},1'b1,	{(DSIZE - 9){1'bx}} }:begin	F = INT	<< 8;E = 8;end
		{ {9{1'b0}},1'b1,	{(DSIZE -10){1'bx}} }:begin	F = INT	<< 9;E = 9;end
		{{10{1'b0}},1'b1,	{(DSIZE -11){1'bx}} }:begin	F = INT	<<10;E =10;end
		{{11{1'b0}},1'b1,	{(DSIZE -12){1'bx}} }:begin	F = INT	<<11;E =11;end
		{{12{1'b0}},1'b1,	{(DSIZE -13){1'bx}} }:begin	F = INT	<<12;E =12;end
		{{13{1'b0}},1'b1,	{(DSIZE -14){1'bx}} }:begin	F = INT	<<13;E =13;end
		{{14{1'b0}},1'b1,	{(DSIZE -15){1'bx}} }:begin	F = INT	<<14;E =14;end
		{{15{1'b0}},1'b1,	{(DSIZE -16){1'bx}} }:begin	F = INT	<<15;E =15;end
		{{16{1'b0}},1'b1,	{(DSIZE -17){1'bx}} }:begin	F = INT	<<16;E =16;end
		{{17{1'b0}},1'b1					   }:begin	F = INT	<<17;E =17;end
		default:begin									F = INT	<<17;E =17;end
	endcase
end
endtask

endmodule
