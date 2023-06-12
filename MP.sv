module MotionPredict(
    input i_clk,
    input i_rst_n,

    input [7:0] r,
    input [7:0] g,
    input [7:0] b,

    input [7:0] pix_x,   // mean of the first 32 frames with gray scale at x,y
    input [7:0] pix_x2,  // stdev of the first 32 frames with gray scale at x,y


    input i_start, // for start the whole process for many cycles
    input i_valid, // input r,g,b is valid

    output coord_valid, // coord is valid
    output [10:0] o_x, // x coord for require point
    output [10:0] o_y, // y coord for require point

    // 0:x,1:y for up
    output o_valid,  // output up,left,right,down is valid
    output [10:0] up    [1:0],    
    output [10:0] left  [1:0], 
    output [10:0] right [1:0],
    output [10:0] down  [1:0],
    output [9:0] o_h,
    output [9:0] o_s,
    output [9:0] o_v
);
////////////////////////////////////
    localparam WIDTH  = 640;
    localparam HEIGHT = 480;
////////////// state //////////////
    localparam S_IDLE = 0;
    localparam S_READ = 1;
    localparam S_PROC = 2;
    localparam S_OUT  = 3;
///////////////////////////////////////////
    localparam deltaX = 1;
    localparam deltaY = 1;
//////////// white balance param //////////
    localparam thres_r = 255;
    localparam thres_g = 248;
    localparam thres_b = 215;
    localparam max_r = 255;
    localparam max_g = 255;
    localparam max_b = 255;
/////////////// hsv filter /////////////////
    localparam hmax = 150;
    localparam hmin = 60;
    localparam smax = 230;
    localparam smin = 60;
    localparam vmax = 255;
    localparam vmin = 80;
////////////////////////////////////////////
    localparam NOT_FOUND = 11'd2023;
    //please only check LEFT or UP for not found
///////////////////////////////////////////

    logic [2:0] state, state_nxt;

    logic [10:0] x, x_nxt;
    logic [10:0] y, y_nxt;

    wire [7:0] r_w, g_w, b_w;
    wire [7:0] max, min;
    wire [9:0] h,s,v;
    logic [15:0] temp4;
    logic [7:0] gray;
    logic isBackground;

    logic [10:0] up_x, up_x_nxt, up_y, up_y_nxt;
    logic [10:0] down_x, down_x_nxt, down_y, down_y_t;
    logic [10:0] left_x, left_x_nxt, left_y, left_y_nxt;
    logic [10:0] right_x, right_x_nxt, right_y, right_y_nxt;
    
    genvar mygen;

    always_comb begin
        temp4 = {8'd0,r}<<5 + {8'd0,r}<<2 + {8'd0,r}<<1 +  // * 38
        {8'd0,g}<<6 + {8'd0,g}<<3 + {8'd0,g}<<1 + {8'd0,g} +   // * 75
        {8'd0,b}<<4 - {8'd0,b}; // * 12

        gray = temp4[14:7] + temp4[6]?1'd1:1'd0;

        isBackground = (gray>pix_x) ?
        {8'd0,gray-pix_x}*{8'd0,gray-pix_x} <= pix_x2 :
        {8'd0,pix_x-gray}*{8'd0,pix_x-gray} <= pix_x2 ;
    end
///////////////////////////////////////////

    assign coord_valid = (state == S_READ);
    assign o_x = x;
    assign o_y = y;
    assign o_valid = (state == S_OUT);
    generate
        for (mygen = 0; mygen < 2; mygen = mygen + 1)begin
            assign up[mygen]    = (mygen) ? up_x    : up_y;
            assign down[mygen]  = (mygen) ? down_x  : down_y;
            assign left[mygen]  = (mygen) ? left_x  : left_y;
            assign right[mygen] = (mygen) ? right_x : right_y;
        end
    endgenerate
    assign o_h = h;
    assign o_s = s;
    assign o_v = v;
    // calc filter
    assign r_w = (r > thres_r) ? max_r : (({8'd0,r} * max_r) / thres_r); 
    assign g_w = (g > thres_g) ? max_g : (({8'd0,g} * max_g) / thres_g); 
    assign b_w = (b > thres_b) ? max_b : (({8'd0,b} * max_b) / thres_b); 
    assign max = (r_w > g_w) ? (
        (r_w > b_w) ? r_w : b_w
    ):
    (
        (g_w > b_w) ? g_w : b_w
    );
    assign min = (r_w < g_w) ? (
        (r_w < b_w) ? r_w : b_w
    ):
    (
        (g_w < b_w) ? g_w : b_w
    );
    assign v = max;
    assign s = (max == 8'd0) ? 0 : 10'd255 * (max-min) / max;
    
    wire [15:0] temp1, temp2, temp3;
    assign temp1 = $signed(16'd60) * $signed(g_w-b_w) / $signed({1'b0,max - min});
    assign temp2 = $signed(16'd60) * $signed(b_w-r_w) / $signed({1'b0,max - min});
    assign temp3 = $signed(16'd60) * $signed(r_w-g_w) / $signed({1'b0,max - min});
    assign h = (max == min) ? 10'd0 :
    ((max == r_w && g_w > b_w)  ? temp1[9:0] :
    ((max == r_w && temp1[9:0]==10'd0) ?     10'd0 :
    (max == r_w) ?     10'd360 + temp1[9:0] :
    ((max == g_w) ?     10'd120 + temp2[9:0] :
    10'd240 + temp3[9:0] )));
///////////////////////////////////////////

    always_comb begin
        state_nxt = state;
        x_nxt = x;
        y_nxt = y;

        // r_w = 8'd0; g_w = 8'd0; b_w = 8'd0;
        // max = 8'd0; min = 8'd0;
        // h = 10'd1010; s = 10'd1010; v = 10'd1010;

        up_x_nxt = up_x;
        up_y_nxt = up_y;
        left_x_nxt = left_x;
        left_y_nxt = left_y;
        right_x_nxt = right_x;
        right_y_nxt = right_y;
        down_x_nxt = down_x;
        down_y_nxt = down_y;

        case(state)
            S_IDLE:begin
                state_nxt = (i_start) ? S_READ : state ;
                x_nxt = 11'd0; y_nxt = 11'd0;
            end
            S_READ:begin
                state_nxt = S_PROC;
            end
            S_PROC:begin
                if(!i_valid)begin
                    state_nxt = state;
                end
                else if(isBackground)begin
                    state_nxt = S_READ;
                    if(x + deltaX >= WIDTH)begin
                        x_nxt = 11'd0;
                        if(y + deltaY >= HEIGHT)begin
                            // finish a whole pic
                            y_nxt = 11'd0;
                            state_nxt = S_OUT;
                        end
                        else begin
                            y_nxt = y + deltaY;
                            state_nxt = S_READ;
                        end
                    end
                    else begin
                        x_nxt = x + deltaX ;
                        state_nxt = S_READ;
                    end
                end
                else begin
                    // calc white balance
                    // r_w = (({8'd0,r} * thres_r) / max_r); 
                    // g_w = (({8'd0,g} * thres_g) / max_g); 
                    // b_w = (({8'd0,b} * thres_b) / max_b); 

                    // calc hsv and filter
                    // max = (r_w > g_w) ? (
                    //     (r_w > b_w) ? r_w : b_w
                    // ):
                    // (
                    //     (g_w > b_w) ? g_w : b_w
                    // );
                    // min = (r_w < g_w) ? (
                    //     (r_w < b_w) ? r_w : b_w
                    // ):
                    // (
                    //     (g_w < b_w) ? g_w : b_w
                    // );

                    // v = max;

                    if( v > vmax || v < vmin)begin
                        // v out of filter range
                    end
                    else begin
                        // s = (max == 8'd0) ? 0 : 10'd255 * (max-min) / max;

                        if(s > smax || s < smin)begin
                            // s out of filter range
                        end
                        else begin
                            // h = (max == min) ? 10'd0 :
                            // (max == r_w && g_w > b_w)  ? (16'd60 * (g_w-b_w) / (max - min)) :
                            // (max == r_w) ?     10'd360 - (16'd60 * (b_w-g_w) / (max - min)) :
                            // (max == g_w) ?     10'd120 + (16'd60 * (b_w-r_w) / (max - min)) :
                            // 10'd240 + (16'd60 * (r_w-g_w) / (max - min)) ;
                            if(h > hmax || h < hmin)begin
                                // h out of filter range
                            end
                            else begin
                                // in range of hsv filter
                                if(y < up_y)begin
                                    up_x_nxt = x; up_y_nxt = y;
                                end
                                else begin end
                                if(y >= down_y)begin
                                    down_x_nxt = x; down_y_nxt = y;
                                end
                                else begin end
                                if(x <= left_x)begin
                                    left_x_nxt = x; left_y_nxt = y;
                                end
                                else begin end
                                if(x > right_x)begin
                                    right_x_nxt = x; right_y_nxt = y;
                                end
                                else begin end
                            end
                        end
                    end
                    // next state , next read input
                    
                    if(x + deltaX >= WIDTH)begin
                        x_nxt = 11'd0;
                        if(y + deltaY >= HEIGHT)begin
                            // finish a whole pic
                            y_nxt = 11'd0;
                            state_nxt = S_OUT;
                        end
                        else begin
                            y_nxt = y + deltaY;
                            state_nxt = S_READ;
                        end
                    end
                    else begin
                        x_nxt = x + deltaX ;
                        state_nxt = S_READ;
                    end
                end
            end
            S_OUT:begin
                state_nxt = S_IDLE;
            end
            default:begin
            end
        endcase
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)begin
            state <= S_IDLE;
            x <= 11'd0;
            y <= 11'd0;
            up_x <= NOT_FOUND;
            up_y <= NOT_FOUND;
            left_x <= NOT_FOUND;
            left_y <= NOT_FOUND;
            right_x <= 11'd0;
            right_y <= 11'd0;
            down_x <= 11'd0;
            down_y <= 11'd0;
        end
        else begin
            state <= state_nxt;
            x <= x_nxt;
            y <= y_nxt;
            up_x <= up_x_nxt;
            up_y <= up_y_nxt;
            down_x <= down_x_nxt;
            down_y <= down_y_nxt;
            left_x <= left_x_nxt;
            left_y <= left_y_nxt;
            right_x <= right_x_nxt;
            right_y <= right_y_nxt;
        end
    end
endmodule