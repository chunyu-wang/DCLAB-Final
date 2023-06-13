// Read pixel value and upgrade sram wb_data
module BackgroundSub(
    input i_clk, // 100M
    input i_rst_n, //DLY_RST_0
    input i_valid, 
    input [9:0] i_r,
    input [9:0] i_g,
    input [9:0] i_b,
    output o_sram_rd,
    output o_sram_wr,
    output [19:0] o_sram_addr,
    inout [15:0] sram_dq
);

localparam H_MAX = 11'd640;
localparam V_MAX = 11'd480;
localparam S_IDLE = 3'd0, S_FETCH1 = 3'd1, S_FETCH2 = 3'd2, S_WB1 = 3'd3, S_WB2 = 3'd4;
logic [2:0] state, state_next;
logic [10:0] h_cnt, v_cnt, h_cnt_next, v_cnt_next;
logic [12:0] sum;
logic [13:0] sum_updated;
logic [20:0] sum_square;
logic [21:0] sum_square_updated;
logic [15:0] sum_square_carry, sum_square_carry_next;
//mean -> 8 sqaure -> 16  mean*32frame -> 13
// sum -> 12 sum_2 -> 20
//TODO: mean and stdev

logic init_done, init_done_next;
logic [21:0] addr;
logic [17:0] gray_tmp;
logic [7:0] gray, gray_next;
logic [15:0] wb_data ,wb_data_next;



 //+ temp4[9]?1'd1:1'd0; //TODO:check overflow
assign o_sram_rd = (state == S_FETCH1) || (state == S_FETCH2); // sync with vga fetch
assign o_sram_wr = (state == S_WB1) || (state == S_WB2);
assign o_sram_addr = addr;

assign sram_dq = ((state == S_WB1) || (state == S_WB2)) ? wb_data:16'dz;
/*
1 2 3 4 5 6 7 8         SRAM
  1  2  3  4  5  6  7  8       BG_SUB
  F1 F2 W1 W2 F1
     sm sq
  R  R  W  W  R  R
  1           2             D5M
     1           2           DRAM
*/

always_comb begin:MemoryRDWR
    state_next = state;
    h_cnt_next = h_cnt;
    v_cnt_next = v_cnt;
    init_done_next = init_done;
    sum_square_carry_next = 16'd0;
    gray_next = gray;
    
    sum = 0;
    sum_square = 0;
    gray_tmp = 18'd0;
    sum_updated = 0;
    sum_square_updated = 0;

    
    case (state)
        S_FETCH1: begin //fetch rgb from dram, mean and square from sram
            addr = (h_cnt+v_cnt*10'd640)<<1; //TODO:check width
            if(i_valid) begin
                state_next = S_FETCH2;
                gray_tmp =  ({8'd0,i_r}<<5) + ({8'd0,i_r}<<2) + ({8'd0,i_r}<<1) +  // * 38
                        ({8'd0,i_g}<<6) + ({8'd0,i_g}<<3) + ({8'd0,i_g}<<1) + ({8'd0,i_g}) +   // * 75
                        ({8'd0,i_b}<<4) - ({8'd0,i_b});
                gray_next = gray_tmp[16:9]; //new grayscale
            end 
            else begin
                state_next = state;
            end
            
        end
        S_FETCH2: begin
            state_next = S_WB1;
            addr = ((h_cnt+v_cnt*10'd640)<<1) + 1'd1; //TODO:check width
            
            if(!init_done) begin
                sum = 13'd0;
                sum_square = 22'd0;
            end //first cycle, dont need to fetch from sram
            else begin
                sum = {sram_dq[11:0], 1'b0};
                sum_square  = {{16{1'b0}}, sram_dq[15:12], 1'b0}; // low 5 bits
                /* 4 3 2 1 0 */
                /*           */
            end
            sum_updated = sum + gray;
            sum_square_updated = sum_square + gray*gray;
            sum_square_carry_next = sum_square_updated[20:5];
            wb_data_next = {sum_square_updated[4:1] ,sum_updated[12:1]};
        end
        S_WB1: begin
            state_next = S_WB2;
            addr = (h_cnt+v_cnt*10'd640)<<1; //TODO:check width
            
            // hi 16bits
            if(!init_done) begin
                wb_data_next = sum_square_carry[15:5];
            end 
            else begin
                wb_data_next = sum_square_carry + sram_dq[15:0];
            end
        end
        S_WB2: begin
            state_next = S_FETCH1;
            addr = ((h_cnt+v_cnt*H_MAX)<<1) + 1'd1; //TODO:check width
            if(h_cnt == H_MAX - 1'd1) begind
                h_cnt_next = 11'd0;
                if(v_cnt == V_MAX - 1'd1) begin
                    v_cnt_next = 11'd0;
                    init_done_next = 1; // a full frame recorded
                end
                else begin
                    v_cnt_next = v_cnt_next + 11'd1;
                end
            end
            else begin
                h_cnt_next = h_cnt + 11'd1;
            end

        end
        default: begin
        end
    endcase
end

always_ff @( posedge i_clk, negedge i_rst_n ) begin : Compute
    if(!i_rst_n) begin
        state <= S_FETCH1;
        h_cnt <= 11'd0;
        v_cnt <= 11'd0;
        init_done <= 0;
        sum_square_carry <= 16'd0;
        wb_data <= 16'd0;
        gray <= 8'd0;
    end
    else begin
        state <= state_next;
        h_cnt <= h_cnt_next;
        v_cnt <= v_cnt_next;
        sum_square_carry <= sum_square_carry_next;
        wb_data <= wb_data_next;
        gray <= gray_next;
    end
end

endmodule