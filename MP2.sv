module MotionPredict(
    input i_clk,
    input i_rst_n,

    input [7:0] r,
    input [7:0] g,
    input [7:0] b,

    input [10:0] x,
    input [10:0] y,

    input frame_start,
    input frame_end,

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
    output [9:0] o_v,

    output o_filtered
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

    localparam NOISE_THRESHOLD = 32'd1024;
    //please only check LEFT or UP for not found
///////////////////////////////////////////

    logic [2:0] state, state_nxt;

    wire [7:0] r_w, g_w, b_w;
    wire [7:0] max, min;
    wire [9:0] h,s,v;
    logic [15:0] temp4;
    logic [7:0] gray;
    logic isBackground;

    logic [10:0] up_x, up_x_nxt, up_y, up_y_nxt;
    logic [10:0] down_x, down_x_nxt, down_y, down_y_nxt;
    logic [10:0] left_x, left_x_nxt, left_y, left_y_nxt;
    logic [10:0] right_x, right_x_nxt, right_y, right_y_nxt;
    
    genvar mygen;

    always_comb begin
        temp4 = ({8'd0,r}<<5) + ({8'd0,r}<<2) + ({8'd0,r}<<1) +  // * 38
        ({8'd0,g}<<6) + ({8'd0,g}<<3) + ({8'd0,g}<<1) + {8'd0,g} +   // * 75
        ({8'd0,b}<<4) - {8'd0,b}; // * 12

        gray = temp4[14:7] + temp4[6]?1'd1:1'd0;

        isBackground = 1'b0;
    end
///////////////////////////////////////////

    assign coord_valid = (state == S_PROC);

    assign o_valid = (state == S_OUT);
    generate
        for (mygen = 0; mygen < 2; mygen = mygen + 1)begin : genwires
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


    assign o_filtered = 
    (x < 11'd640) && (y < 11'd640) &&
    (h >= hmin) && (h <= hmax) &&
    (s >= smin) && (s <= smax) &&
    (v >= vmin) && (v <= vmax);

    logic [31:0] x_cm, x_cm_nxt;
    logic [31:0] y_cm, y_cm_nxt;
    logic [31:0] pix_cnt, pix_cnt_nxt;
    
    wire [31:0] x_cm_div, y_cm_div;
    assign x_cm_div = (pix_cnt == 32'd0) ? 32'd0 : x_cm / pix_cnt;
    assign y_cm_div = (pix_cnt == 32'd0) ? 32'd0 : y_cm / pix_cnt;
///////////////////////////////////////////

    always_comb begin
        state_nxt = state;

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

        x_cm_nxt = x_cm;
        y_cm_nxt = y_cm;
        pix_cnt_nxt = pix_cnt;

        case(state)
            S_IDLE:begin
                state_nxt = (i_start) ? S_PROC : state ;
                x_cm_nxt = 32'd0; y_cm_nxt = 32'd0; pix_cnt_nxt = 32'd0;
                left_x_nxt = 11'd2023;
                left_y_nxt = 11'd2023;
                up_x_nxt = 11'd2023;
                up_y_nxt = 11'd2023;
                down_x_nxt = 11'd2023;
                down_y_nxt = 11'd2023;
                right_x_nxt = 11'd2023;
                right_y_nxt = 11'd2023;
            end
            S_PROC:begin
                if(i_valid && o_filtered)begin
                    x_cm_nxt = x_cm + {21'd0, x};
                    y_cm_nxt = y_cm + {21'd0, y};
                    pix_cnt_nxt = pix_cnt + 32'd1;
                end

                if(frame_end)begin
                    // finish a whole pic
                    state_nxt = S_OUT;
                    if(pix_cnt > NOISE_THRESHOLD) begin
                        left_x_nxt = x_cm / pix_cnt;
                        down_x_nxt = x_cm / pix_cnt;
                        right_x_nxt = x_cm / pix_cnt;
                        up_x_nxt = x_cm / pix_cnt;

                        left_y_nxt = y_cm / pix_cnt;
                        down_y_nxt = y_cm / pix_cnt;
                        right_y_nxt = y_cm / pix_cnt;
                        up_y_nxt = y_cm / pix_cnt;
                    end
                    else begin
                        left_x_nxt = NOT_FOUND;
                        down_x_nxt = NOT_FOUND;
                        right_x_nxt = NOT_FOUND;
                        up_x_nxt = NOT_FOUND;

                        left_y_nxt = NOT_FOUND;
                        down_y_nxt = NOT_FOUND;
                        right_y_nxt = NOT_FOUND;
                        up_y_nxt = NOT_FOUND;
                    end
                end
                else begin
                    state_nxt = S_PROC;
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
            up_x <= NOT_FOUND;
            up_y <= NOT_FOUND;
            left_x <= NOT_FOUND;
            left_y <= NOT_FOUND;
            right_x <= 11'd0;
            right_y <= 11'd0;
            down_x <= 11'd0;
            down_y <= 11'd0;
            x_cm <= 32'd0;
            y_cm <= 32'd0;
            pix_cnt <= 32'd0;

        end
        else begin
            state <= state_nxt;
            up_x <= up_x_nxt;
            up_y <= up_y_nxt;
            down_x <= down_x_nxt;
            down_y <= down_y_nxt;
            left_x <= left_x_nxt;
            left_y <= left_y_nxt;
            right_x <= right_x_nxt;
            right_y <= right_y_nxt;
            x_cm <= x_cm_nxt;
            y_cm <= y_cm_nxt;
            pix_cnt <= pix_cnt_nxt;
        end
    end
endmodule