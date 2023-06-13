`timescale 1ns/1ps

`define CYCLE 10
`define FRAME_DATA_SRC "tb/pic/pic0/testbench.dat"

module testBackgroundSub(
);
    reg clk, rst_n, valid ;
    reg [10:0] x, x_nxt, y, y_nxt;
    wire [9:0] r, g, b;

    logic [7:0] frame [639:0] [479:0] [2:0];

    wire sram_rd;
    wire sram_wr;
    wire sram_addr;
    wire [15:0] sram_dq;

    assign r = frame[x][y][0];
    assign g = frame[x][y][1];
    assign b = frame[x][y][2];

    always #(`CYCLE*0.5)clk = ~clk;

    BackgroundSub(
        .i_clk(clk), // 100M
        .i_rst_n(rst_n), //DLY_RST_0
        .i_valid(valid), 
        .i_r(r),
        .i_g(g),
        .i_b(b),
        .o_sram_rd(sram_rd),
        .o_sram_wr(sram_wr),
        .o_sram_addr(sram_addr),
        .sram_dq(sram_dq)
    );

    initial begin
        $fsdbDumpfile("BackGroundSub.fsdb");
		$fsdbDumpvars("+all");

        $display("------------------------------------------------------------\n");
        $display("..... START!!! Simulation Start .....\n");
        $display("------------------------------------------------------------\n");

        
        $readmemb (`FRAME_DATA_SRC, frame);

        #(CYCLE * 10000000) $finish;
    end
    reg [31:0] cnt, cnt_nxt;
    assign valid = (cnt[1:0] == 2'd0);
    always_comb begin
        cnt_nxt = cnt + 32'd1;
        if(x == 11'd639)begin
            if(y==11'd479)begin
                y_nxt = 11'd0;
            end
            else begin
                y_nxt = y + 11'd1;
            end
            x_nxt = 11'd0;
        end
        else begin
            y_nxt = y;
            x_nxt = x + 11'd1;
        end
    end
    always_ff @(posedge clk)begin
        if(!rst_n)begin
            x<= 11'd0;
            y<= 11'd0;
            cnt <= 32'd0;
        end
        else begin
            x<=x_nxt;
            y<=y_nxt;
            cnt <= cnt_nxt;
        end
    end
    initial begin
        rst_n = 1;
        #(CYCLE * 1)
        rst_n = 0;
        #(CYCLE * 0)
        rst_n = 1;
    end
endmodule