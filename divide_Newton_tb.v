/*******************************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________

--Module Name:
--Project Name:
--Chinese Description:
	
--English Description:
	
--Version:VERA.1.0.0
--Data modified:
--author:Young-吴明
--E-mail: wmy367@Gmail.com
--Data created:
________________________________________________________
********************************************************/
`timescale 1ns/1ps
module	divide_Newton_tb;

reg			clock	= 0;
reg			rst		= 0;
always #10 clock	= ~clock;
initial begin
	rst		= 0;
	repeat(2) @(posedge clock);
	rst	= 1;
	repeat(2) @(posedge clock);
	rst	= 0;
end

reg	[23:0]		dividend	= 0;
reg [23:0]		divisor		= 0;
wire[47:0]		QUO;
wire[5:0]		EXP;
wire			RDY,VALID;

always@(posedge clock)begin
	if(RDY)begin
		dividend	= $random%(2**23);
		divisor		= $random%(2**23);
	end else begin
		dividend	= dividend;
		divisor		= divisor;
end end
	


divide_Newton #(
	.DSIZE 	(24),
	.PN		(6)									//control precision 越大精度越小
)divide_Newton_inst(
	.clock		(clock),
	.rst		(rst),
	
	.N			(dividend),
	.D			(divisor),
	.enable		(1'b1),
	
	.Q			(QUO),
	.EXP		(EXP),
	.VALID		(VALID),
	.RDY		(RDY)
);

endmodule
