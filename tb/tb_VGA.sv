`timescale 1ns/100ps

module tb_VGA;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic clk, rst_n;
	initial clk = 0;
	always #HCLK clk = ~clk;

	logic [7:0] R,G,B,  VGA_R,VGA_G,VGA_B;
	logic [10:0] HORIZON, VERTICAL;
	logic VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;

	VGA vga(
		.clk(clk),
		.rst_n(rst_n),
		.R(R),
		.G(G),
		.B(B),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.HORIZON(HORIZON),
		.VERTICAL(VERTICAL)
	);

	initial begin
		$fsdbDumpfile("VGA.fsdb");
		$fsdbDumpvars;
		
		rst_n = 1;
		#(2*CLK)
		rst_n = 0;
		#(2*CLK)
		rst_n = 1;
		R = 8'd0;G = 8'd0;B = 8'd0;
		#(200*CLK)
		R = 8'd1;G = 8'd1;B = 8'd1;
		#(200*CLK)
		R = 8'd2;G = 8'd2;B = 8'd2;
		#(900000*CLK)
		$finish;
		
	end

endmodule
