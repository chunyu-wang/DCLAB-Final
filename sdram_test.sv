module MYdFF(
    input i_clk, 
    input i_rst_n, 
    input [15:0] d,
    output reg [15:0] q 
);


	always_ff @(posedge i_clk, negedge i_rst_n) begin
		 if(!i_rst_n) begin
			  q <= 16'd0;
		 end
		 else begin 
			  if(q==16'd0)begin q <= d;end
		 end
	end
endmodule