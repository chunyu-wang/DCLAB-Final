// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	Reset_Delay
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN        :| 07/07/09  :| Initial Revision
// --------------------------------------------------------------------

module	Reset_Delay(i_clk,i_rst_n,o_rst_n0,o_rst_n1,o_rst_n2,o_rst_n3,o_rst_n4);
input		i_clk;
input		i_rst_n;
output reg	o_rst_n0;
output reg	o_rst_n1;
output reg	o_rst_n2;
output reg	o_rst_n3;
output reg	o_rst_n4;

reg	[31:0]	cnt;

always@(posedge i_clk or negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		cnt	<=	0;
		o_rst_n0	<=	0;
		o_rst_n1	<=	0;
		o_rst_n2	<=	0;
		o_rst_n3	<=	0;
		o_rst_n4	<=	0;
	end
	else
	begin
		if(cnt!=32'h01FFFFFF)
		cnt	<=	cnt+1;
		if(cnt>=32'h001FFFFF)
		o_rst_n0	<=	1;
		if(cnt>=32'h002FFFFF)
		o_rst_n1	<=	1;
		if(cnt>=32'h011FFFFF)
		o_rst_n2	<=	1;
		if(cnt>=32'h016FFFFF)
		o_rst_n3	<=	1;
		if(cnt>=32'h01FFFFFF)
		o_rst_n4	<=	1;
	end
end

endmodule