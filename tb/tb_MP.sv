`timescale 1ns/10ps

`define CYCLE 10
`define FRAME_DATA_SRC "tb/pic/pic0/testbench.dat"
`define HSV_DATA_SRC   "tb/pic/pic0/golden.dat"
module testMP(
    
);
    reg clk;
    reg rst_n;
    reg start;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    wire [9:0] golden_h;
    wire [9:0] golden_s;
    wire [9:0] golden_v;

    wire [9:0] cvt_h;
    wire [9:0] cvt_s;
    wire [9:0] cvt_v;

    wire [10:0] x;
    wire [10:0] y;
    wire coord_valid;

    logic [7:0] frame [639:0] [479:0] [2:0];
    logic [9:0] hsv [639:0] [479:0] [2:0];

    assign r = frame[x][y][0];
    assign g = frame[x][y][1];
    assign b = frame[x][y][2];

    assign golden_h = hsv[x][y][0];
    assign golden_s = hsv[x][y][1];
    assign golden_v = hsv[x][y][2];

    wire h_correct;
    wire s_correct;
    wire v_correct;

    localparam DELTA = 3;

    assign h_correct = (cvt_h <= golden_h + DELTA) && ( (cvt_h >= golden_h - DELTA) || (golden_h < DELTA && ((10'd360+golden_h-DELTA < cvt_h)||(cvt_h<golden_h+DELTA))));
    assign s_correct = (cvt_s <= golden_s + DELTA) && ( (cvt_s >= golden_s - DELTA) || (golden_s < DELTA));
    assign v_correct = (cvt_v <= golden_v + DELTA) && ( (cvt_v >= golden_v - DELTA) || (golden_v < DELTA));
    

    integer i,j,k;

    MotionPredict mp0(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .r(r),
        .g(g),
        .b(b),

        .i_start(start), // for start the whole process for many cycles
        .i_valid(1'b1), // input r,g,b is valid

        .coord_valid(coord_valid), // coord is valid
        .o_x(x), // x coord for require point
        .o_y(y), // y coord for require point

    // 0:x,1:y for up
        .o_valid(),  // output up,left,right,down is valid
        .up(),    
        .left(), 
        .right(),
        .down(),

        .o_h(cvt_h),
        .o_s(cvt_s),
        .o_v(cvt_v)
    );
    

    initial begin
        $fsdbDumpfile("MP.fsdb");
		$fsdbDumpvars;

        $display("------------------------------------------------------------\n");
        $display("..... START!!! Simulation Start .....\n");
        $display("------------------------------------------------------------\n");

        $readmemb (`FRAME_DATA_SRC, frame);
        $readmemb (`HSV_DATA_SRC,   hsv);

        clk = 1;
        rst_n = 1;
        start = 0;
        // for(i=0;i<640;i=i+1)begin
        //     for(j=0;j<480;j=j+1)begin
        //         frame[i][j][0] = (i *255 /640);
        //         frame[i][j][1] = (j *255 /480);
        //         frame[i][j][2] = ((i*i+j*j) * 255)/(640*640+480*480);
        //     end
        // end
    end
    
    always #(`CYCLE*0.5)clk = ~clk;
    always @(negedge coord_valid)begin
        if(h_correct && s_correct && v_correct)begin

        end
        else begin
            if(cvt_h == 11'd1001 || cvt_s == 11'd1001 || cvt_v == 11'd1001)begin
                $display("In x = %11d, y = %11d , cannot get right hsv",x,y);
            end
            else begin
                if(!h_correct)begin
                    $display("In x = %11d , y = %11d , expect h = %10d , get h = %10d",x,y,golden_h,cvt_h);
                end
                if(!s_correct)begin
                    $display("In x = %11d , y = %11d , expect s = %10d , get s = %10d",x,y,golden_s,cvt_s);
                end
                if(!v_correct)begin
                    $display("In x = %11d , y = %11d , expect v = %10d , get v = %10d",x,y,golden_v,cvt_v);
                end
            end
        end
    end
    initial begin
        #(`CYCLE * 2)rst_n = 0;
        #(`CYCLE * 2)rst_n = 1;
        #(`CYCLE * 2)start = 1;
        #(`CYCLE * 2)start = 0;
        #(`CYCLE * 100000)
        $display("==============");
        $display("");
        $display("    finish    ");
        $display("");
        $display("==============");
        $finish;
    end
endmodule