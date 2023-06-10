`timescale 1ns/10ps

`define CYCLE 10

module testMP(
    
);
    reg clk;
    reg rst_n;
    reg start;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    wire [10:0] x;
    wire [10:0] y;

    logic [7:0] frame [639:0] [479:0] [2:0];
    assign r = frame[x][y][0];
    assign g = frame[x][y][1];
    assign b = frame[x][y][2];

    integer i,j,k;

    MotionPredict mp0(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .r(r),
        .g(g),
        .b(b),

        .i_start(start), // for start the whole process for many cycles
        .i_valid(1), // input r,g,b is valid

        .coord_valid(1), // coord is valid
        .o_x(x), // x coord for require point
        .o_y(y), // y coord for require point

    // 0:x,1:y for up
        .o_valid(),  // output up,left,right,down is valid
        .up(),    
        .left(), 
        .right(),
        .down()
    );
    

    initial begin
        $fsdbDumpfile("MP.fsdb");
		$fsdbDumpvars;

        clk = 1;
        rst_n = 1;
        start = 0;
        for(i=0;i<640;i=i+1)begin
            for(j=0;j<480;j=j+1)begin
                frame[i][j][0] = (i *255 /640);
                frame[i][j][1] = (j *255 /480);
                frame[i][j][2] = ((i*i+j*j) * 255)/(640*640+480*480);
            end
        end
    end
    
    always #(`CYCLE*0.5)clk = ~clk;

    initial begin
        #(`CYCLE * 2)rst_n = 0;
        #(`CYCLE * 2)rst_n = 1;
        #(`CYCLE * 2)start = 1;
        #(`CYCLE * 2)start = 0;
        #(`CYCLE * 1000000)
        $display("==============");
        $display("");
        $display("    finish    ");
        $display("");
        $display("==============");
        $finish;
    end
endmodule