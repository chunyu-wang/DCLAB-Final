module sdram_wrapper(
    input         avm_rst,
    input         avm_clk,
    output  [24:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam  ADDR_BASE = 25'h0;
logic read, write;
logic read_next, write_next;

logic [24:0] addr, addr_next;

assign avm_read = read;
assign avm_write = write;
always_comb begin 
    addr_next <= addr + 1'h1;
    wri
end


always_ff @(posedge avm_clk or negedge avm_rst) begin
    if(!avm_rst) begin
        read <= 0'b0;
        write <= 0'b0;        
        addr <= 25'h0;
    end
    else begin
        addr <= addr_next;
        
    end
end


endmodule









endmodule