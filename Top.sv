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
	wire [10:0] x, y;

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

// 	VGA(
//     // DE2_115
//     .i_rst_n(i_rst_n),
//     .i_clk_25M(i_clk),
//     .VGA_BLANK_N(o_VGA_BLANK_N),
//     .VGA_HS(o_VGA_HS),
//     .VGA_SYNC_N(o_VGA_SYNC_N),
//     .VGA_VS(o_VGA_VS),

//     // for Mem_addr_generator
//     .o_show_en(1),      // 1 when in display time, otherwise 0
//     .o_x_cord(x), // from 0 to 479
//     .o_y_cord(y)  // from 0 to 639
// );

	assign test = 15;
	logic [7:0] pix_R, pix_G, pix_B;
	logic [3:0] outtest_r, outtest_w;
	logic [31:0] counter_r, counter_w;

	logic [10:0] cx, cy, cx_next, cy_next;
	logic [10:0] dcx, dcy, dcx_next, dcy_next;

	logic [639:0][479:0][2:0][7:0] pixmap;

	assign pix_R = ((x-cx)*(x-cx)+(y-cy)*(y-cy)<700)?0:200;
	assign pix_G = ((x-cx)*(x-cx)+(y-cy)*(y-cy)<700)?0:255;
	assign pix_B = ((x-cx)*(x-cx)+(y-cy)*(y-cy)<700)?255:200;
	// assign o_VGA_R = (x==200||y==200)?255:0;
	// assign o_VGA_G = (x==200||y==200)?255:0;
	// assign o_VGA_B = (x==200||y==200)?255:0;
	
	always_ff @(negedge i_rst_n or posedge i_clk) begin
		if(!i_rst_n)begin
			cx        <= 11'd320;
			cy        <= 11'd240;
			dcx       <= 11'd1;
			dcy       <= 11'd1;
			counter_r <= 0;
		end
		else begin
			cx        <= cx_next;
			cy        <= cy_next;
			dcx        <= dcx_next;
			dcy        <= dcy_next;
			counter_r <= counter_w;
		end
		
	end

	always_comb begin
		cx_next = cx;cy_next=cy;dcx_next=dcx;dcy_next=dcy;
		if(counter_r == 32'd1258749)begin
			counter_w = 0;
			if(cx==30)begin
				dcx_next = 1;
			end
			else if(cx==610)begin
				dcx_next = 2;
			end
			else begin
				dcx_next = dcx;
			end

			if(cy==30)begin
				dcy_next = 1;
			end
			else if(cy==450)begin
				dcy_next = 2;
			end
			else begin
				dcy_next = dcy;
			end
			cx_next = (dcx==1)?cx+1:cx-1;
			cy_next = (dcy==1)?cy+1:cy-1;
		end
		else begin
			counter_w = counter_r + 1;
		end
	end
endmodule
