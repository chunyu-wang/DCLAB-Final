module testVGA(
    input i_clk,
	input i_rst_n,
	
	input i_key_0,
	input i_key_1,
	input i_key_2,

	input i_VGA_CLK,
	output [7:0] o_VGA_R,
	output [7:0] o_VGA_G,
	output [7:0] o_VGA_B,
	output o_VGA_BLANK_N,
	output o_VGA_SYNC_N,

	output o_VGA_HS,
	output o_VGA_VS,
	output [3:0] test
);
	wire [9:0] x, y;

	VGA vga(
		.clk(i_clk),
		.rst_n(i_rst_n),

		.R(pix_R),
		.G(pix_G),
		.B(pix_B),

		.VGA_R(o_VGA_R),
		.VGA_G(o_VGA_G),
		.VGA_B(o_VGA_B),

		.VGA_HS(o_VGA_HS),
		.VGA_VS(o_VGA_VS),

		.VGA_BLANK_N(o_VGA_BLANK_N),
		.VGA_SYNC_N(o_VGA_SYNC_N),

		.HORIZON(x),
		.VERTICAL(y)
	);

	assign test = outtest_r;
	logic [7:0] pix_R, pix_G, pix_B;
	logic [3:0] outtest_r, outtest_w;
	logic [31:0] counter_r, counter_w;


	assign pix_R = ((x>10'd200) && (x<10'd400) && (y>10'd200) && (y<10'd400))? 8'd255 : 8'd0;
	assign pix_G = ((x>10'd200) && (x<10'd400) && (y>10'd200) && (y<10'd400))? 8'd255 : 8'd0;
	assign pix_B = ((x>10'd200) && (x<10'd400) && (y>10'd200) && (y<10'd400))? 8'd255 : 8'd0;


	always_ff @(negedge i_rst_n or posedge i_clk) begin

		if(!i_rst_n)begin
			counter_r <= 32'd0;
			outtest_r <= 4'd0;
		end
		else begin
			counter_r <= counter_w;
			outtest_r <= outtest_w;
		end
		
	end

	always_comb begin
		if(counter_r >= 32'd5000000)begin
			counter_w = 32'd0;
			outtest_w = outtest_r + 4'd1;  
		end
		else begin
			counter_w = counter_r + 32'd1;
			outtest_w = outtest_r;
		end
	end
endmodule
