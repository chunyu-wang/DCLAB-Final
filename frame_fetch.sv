module FrameFetch(
    input i_clk, 
    input i_rst_n, 
    input i_data_1, 
    input i_data_2,
    input i_request,
    output o_sdram_read,
    output o_sram_read,
    output o_vga_r, 
    output o_vga_g, 
    output o_vga_b
)

//RGB10
logic [9:0] r, g, b; 

assign o_read = i_request;

assign o_vga_r = i_data_2[9:0]; 
assign o_vga_g = {i_data_1[14:10], i_data_2[14:10]};
assign o_vga_b = i_data_1[9:0];


endmodule;