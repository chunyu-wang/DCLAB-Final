`timescale 1ns/10ps

`define CYCLE 10
`define FRAME_DATA_SRC "tb/pic/pic0/testbench.dat"
`define HSV_DATA_SRC   "tb/pic/pic0/golden.dat"
module testMP(
    
);
    reg clk_25M, clk_50M;
    reg rst_n;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    // wire [9:0] golden_h;
    // wire [9:0] golden_s;
    // wire [9:0] golden_v;

    // wire [9:0] cvt_h;
    // wire [9:0] cvt_s;
    // wire [9:0] cvt_v;

    wire [10:0] x;
    wire [10:0] y;
    wire coord_valid;

    wire [7:0] up, dw, le, ri [1:0];

    logic [7:0] frame [639:0] [479:0] [2:0];
    // logic [9:0] hsv [639:0] [479:0] [2:0];

    assign r = frame[x][y][0];
    assign g = frame[x][y][1];
    assign b = frame[x][y][2];

    // assign golden_h = hsv[x][y][0];
    // assign golden_s = hsv[x][y][1];
    // assign golden_v = hsv[x][y][2];

    // wire h_correct;
    // wire s_correct;
    // wire v_correct;

    // localparam DELTA = 3;

    // assign h_correct = (cvt_h <= golden_h + DELTA) && ( (cvt_h >= golden_h - DELTA) || (golden_h < DELTA && ((10'd360+golden_h-DELTA < cvt_h)||(cvt_h<golden_h+DELTA))));
    // assign s_correct = (cvt_s <= golden_s + DELTA) && ( (cvt_s >= golden_s - DELTA) || (golden_s < DELTA));
    // assign v_correct = (cvt_v <= golden_v + DELTA) && ( (cvt_v >= golden_v - DELTA) || (golden_v < DELTA));
    
    wire f_s, f_e, o_req;
    integer i,j,k;

    MotionPredict mp0(
        .i_clk(clk_25M),
        .i_rst_n(rst_n),
        .r(r),
        .g(g),
        .b(b),

        .frame_start(f_s),
        .frame_end(f_e),

        .i_start(f_s), // for start the whole process for many cycles
        .i_valid(o_req), // input r,g,b is valid

        .pix_x(),
        .pix_x2(),

        .coord_valid(coord_valid), // coord is valid
        .x(x), // x coord for require point
        .y(y), // y coord for require point

        .o_x(),
        .o_y(),

    // 0:x,1:y for up
        .o_valid(),  // output up,left,right,down is valid
        .up(),    
        .left(), 
        .right(),
        .down(),

        .o_h(),
        .o_s(),
        .o_v(),
        .o_filtered()
    );
    
    VGA vga0(
        .clk(clk_25M),
        .rst_n(rst_n),
        .R(r),
        .G(g),
        .B(b),
        .start(1'b1),
        // .VGA_R(),
        // .VGA_G(),
        // .VGA_B(),
        // .VGA_HS(),
        // .VGA_VS(),
        // .VGA_BLANK_N(),
        // .VGA_SYNC_N(),
        .HORIZON(x), // ask the input from parent with horizontal coordinate
        .VERTICAL(y), // ask the input from parent with vertical   coordinate
        .frame_start(f_s),
        .frame_end(f_e),
        .o_request(o_req)
    );

    initial begin
        $fsdbDumpfile("MP2.fsdb");
		$fsdbDumpvars;

        $display("------------------------------------------------------------\n");
        $display("..... START!!! Simulation Start .....\n");
        $display("------------------------------------------------------------\n");

        $readmemb (`FRAME_DATA_SRC, frame);
        // $readmemb (`HSV_DATA_SRC,   hsv);

        clk_25M = 1;
        clk_50M = 1;
        rst_n = 1;
        // for(i=0;i<640;i=i+1)begin
        //     for(j=0;j<480;j=j+1)begin
        //         frame[i][j][0] = (i *255 /640);
        //         frame[i][j][1] = (j *255 /480);
        //         frame[i][j][2] = ((i*i+j*j) * 255)/(640*640+480*480);
        //     end
        // end
    end
    
    always #(`CYCLE*0.5)    clk_50M = ~clk_50M;
    always #(`CYCLE)        clk_25M = ~clk_25M;
    
    initial begin
        #(`CYCLE * 2)rst_n = 0;
        #(`CYCLE * 2)rst_n = 1;
    
        #(`CYCLE * 3200000)
        $display("==============");
        $display("");
        $display("    finish    ");
        $display("");
        $display("==============");
        $finish;
    end
endmodule