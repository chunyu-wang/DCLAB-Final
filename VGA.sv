module VGA(
    input clk,
    input rst_n,
    input [7:0] R,
    input [7:0] G,
    input [7:0] B,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output [10:0] HORIZON, // ask the input from parent with horizontal coordinate
    output [10:0] VERTICAL // ask the input from parent with vertical   coordinate
);
    // param
    localparam WIDTH     = 640;
    localparam HEIGHT    = 480;
    localparam FRAMERATE = 60; 
    localparam ACTI_H     = 640;
    localparam FRON_H     = 16;
    localparam SYNC_H     = 96;
    localparam BACK_H     = 48;
    localparam ACTI_V     = 480;
    localparam FRON_V     = 10;//10 or 11
    localparam SYNC_V     = 2;
    localparam BACK_V     = 33;//33 or 30
    // state
    localparam S_IDLE = 3'd0;
    localparam S_ACTI = 3'd1;
    localparam S_FRON = 3'd2;
    localparam S_SYNC = 3'd3;
    localparam S_BACK = 3'd4;


    // reg
    logic [2:0] hstate, hstate_next;
    logic [2:0] vstate, vstate_next;
    logic [9:0] hcount, hcount_next;
    logic [9:0] vcount, vcount_next;
    logic hsync, hsync_next;
    logic vsync, vsync_next;
    logic [10:0] ho, ho_next; // current pixel horizontal coordinate
    logic [10:0] ve, ve_next; // current pixel vertical   coordinate

    logic [639:0][2:0] row, row_next;

    // assign
    assign VGA_R  = (hstate == S_ACTI && vstate == S_ACTI) ? R : 8'd0;
    assign VGA_G  = (hstate == S_ACTI && vstate == S_ACTI) ? G : 8'd0;
    assign VGA_B  = (hstate == S_ACTI && vstate == S_ACTI) ? B : 8'd0;
    
    // assign VGA_HS = hsync;
    // assign VGA_VS = vsync;
    assign VGA_HS = !(hstate==S_SYNC);
    assign VGA_VS = !(vstate==S_SYNC);

    assign HORIZON  = ho;
    assign VERTICAL = ve;

    // TODO (unsure the function)
    assign VGA_BLANK_N = (vstate == S_ACTI && hstate == S_ACTI);
    assign VGA_SYNC_N  = !(vstate==S_SYNC && hstate==S_SYNC);

    // always comb

    always_comb begin
        // give initial value
        hstate_next = hstate;
        vstate_next = vstate;
        hcount_next = hcount;
        vcount_next = vcount;
        hsync_next  = hsync;
        vsync_next  = vsync;
        ho_next     = ho;
        ve_next     = ve;

        // FSM2
        case (vstate)
            S_ACTI:begin
                vsync_next = 1'b1;
                if(vcount == ACTI_V -1 && hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = S_FRON;
                    vcount_next = 10'd0;
                end
                else if(hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = vstate;
                    vcount_next = vcount + 10'd1;
                end
                else begin
                    vstate_next = vstate;
                    vcount_next = vcount;
                end
            end
            S_FRON:begin
                vsync_next = 1'b1;
                if(vcount == FRON_V -1 && hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = S_SYNC;
                    vcount_next = 10'd0;
                    vsync_next = 1'b0;
                end
                else if(hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = vstate;
                    vcount_next = vcount + 10'd1;
                end
                else begin
                    vstate_next = vstate;
                    vcount_next = vcount;
                end
            end
            S_SYNC:begin
                vsync_next = 1'b0;
                if(vcount == SYNC_V -1 && hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = S_BACK;
                    vcount_next = 10'd0;
                    vsync_next = 1'b1;
                end
                else if(hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = vstate;
                    vcount_next = vcount + 10'd1;
                end
                else begin
                    vstate_next = vstate;
                    vcount_next = vcount;
                end
            end
            S_BACK:begin
                vsync_next = 1'b1;
                if(vcount == BACK_V -1 && hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = S_ACTI;
                    vcount_next = 10'd0;
                end
                else if(hstate == S_BACK && hcount == BACK_H -1)begin
                    vstate_next = vstate;
                    vcount_next = vcount + 10'd1;
                end
                else begin
                    vstate_next = vstate;
                    vcount_next = vcount;
                end
            end 
            default:begin
                vstate_next = S_ACTI;
                vcount_next = 10'd0;
                vsync_next = 1'b1;
            end
        endcase


        // FSM1
        case (hstate)
            S_ACTI:begin
                hsync_next = 1'b1;
                if(hcount == ACTI_H -1)begin
                    hstate_next = S_FRON;
                    hcount_next = 10'd0;
                end
                else begin
                    hstate_next = hstate;
                    hcount_next = hcount + 10'd1;
                end
            end
            S_FRON:begin
                if(hcount == FRON_H -1)begin
                    hstate_next = S_SYNC;
                    hcount_next = 10'd0;
                    hsync_next = 1'b0;
                end
                else begin
                    hstate_next = hstate;
                    hcount_next = hcount + 10'd1;
                    hsync_next = 1'b1;
                end
            end
            S_SYNC:begin
                if(hcount == SYNC_H -1)begin
                    hstate_next = S_BACK;
                    hcount_next = 10'd0;
                    hsync_next = 1'b1;
                end
                else begin
                    hstate_next = hstate;
                    hcount_next = hcount + 10'd1;
                    hsync_next = 1'b0;
                end
            end
            S_BACK:begin
                hsync_next = 1'b1;
                if(hcount == BACK_H -1)begin
                    hstate_next = S_ACTI;
                    hcount_next = 10'd0;
                end
                else begin
                    hstate_next = hstate;
                    hcount_next = hcount + 10'd1;
                end
            end 
            default:begin
                hstate_next = S_ACTI;
                hcount_next = 10'd0;
                hsync_next = 1'b1;
            end
        endcase

        // for pixel coordinate
        if( vstate == S_ACTI && hstate == S_ACTI )begin
            if( ho == WIDTH - 1)begin
                ho_next = 11'd0;
                ve_next = ve;
            end
            else begin
                ho_next = ho + 11'd1;
                ve_next = ve;
            end
        end
        else if( vstate == S_BACK && vcount == BACK_V -1 && hstate == S_BACK && hcount == BACK_H -1)begin
            ve_next = 11'd0;
            ho_next = 11'd0;
        end
        else if( vstate == S_ACTI && hstate == S_BACK && hcount == BACK_H -1)begin
            if(ve == HEIGHT -1)begin
                ho_next = 11'd0;
                ve_next = 11'd0;
            end
            else begin
                ho_next = 11'd0;
                ve_next = ve + 11'd1;
            end
        end
        else begin
            ho_next = ho;
            ve_next = ve;
        end
    end

    always_ff @( negedge rst_n or posedge clk) begin
        if(!rst_n)begin
            hstate <= S_ACTI;
            vstate <= S_ACTI;
            hcount <= 11'd0;
            vcount <= 11'd0;
            hsync  <= 1'b1;
            vsync  <= 1'b1;
            ho     <= 11'd0;
            ve     <= 11'd0;
        end
        else begin
            hstate <= hstate_next;
            vstate <= vstate_next;
            hcount <= hcount_next;
            vcount <= vcount_next;
            hsync  <= hsync_next;
            vsync  <= vsync_next;
            ho     <= ho_next;
            ve     <= ve_next;
        end
    end

endmodule

// module VGA(
//     // DE2_115
//     input  i_rst_n,
//     input  i_clk_25M,
//     output VGA_BLANK_N,
//     output VGA_CLK,
//     output VGA_HS,
//     output VGA_SYNC_N,
//     output VGA_VS,

//     // for Mem_addr_generator
//     output o_show_en,      // 1 when in display time, otherwise 0
//     output [9:0] o_x_cord, // from 0 to 479
//     output [9:0] o_y_cord  // from 0 to 639
// );


//     // Variable definition
//     logic [9:0] x_cnt_r, x_cnt_w;
//     logic [9:0] y_cnt_r, y_cnt_w;
//     logic hsync_r, hsync_w, vsync_r, vsync_w;
//     reg show_en_r, show_en_w;
    
//     // 640*480, refresh rate 60Hz
//     // VGA clock rate 25.175MHz
//     // display as H_BLANK <= x_cnt_r <= H_TOTAL
//     //            y_cnt_r
//     localparam H_FRONT  =   16;
//     localparam H_SYNC   =   96;
//     localparam H_BACK   =   48;
//     localparam H_ACT    =   640;
//     localparam H_BLANK  =   H_FRONT + H_SYNC + H_BACK;         // = 160
//     localparam H_TOTAL  =   H_FRONT + H_SYNC + H_BACK + H_ACT; // = 800
//     localparam V_FRONT  =   10;
//     localparam V_SYNC   =   2;
//     localparam V_BACK   =   33;
//     localparam V_ACT    =   480;
//     localparam V_BLANK  =   V_FRONT + V_SYNC + V_BACK;         // = 45
//     localparam V_TOTAL  =   V_FRONT + V_SYNC + V_BACK + V_ACT; // = 525

//     // Output assignment
//     assign VGA_CLK      =   i_clk_25M;
//     assign VGA_HS       =   hsync_r;
//     assign VGA_VS       =   vsync_r;
//     assign VGA_SYNC_N   =   1'b0;
//     assign VGA_BLANK_N  =   ~((x_cnt_r < H_BLANK) || (y_cnt_r < V_BLANK));
	 
// 	 assign o_show_en = show_en_r;
    
//     // Coordinates
//     always_comb begin
//         if (x_cnt_r == H_TOTAL) begin
//             x_cnt_w = 1;
//         end
//         else begin
//             x_cnt_w = x_cnt_r + 1;
//         end
//     end

//     always_comb begin
//         if (y_cnt_r == V_TOTAL) begin
//             y_cnt_w = 1;
//         end
//         else if (x_cnt_r == H_TOTAL) begin
//             y_cnt_w = y_cnt_r + 1;
//         end
//         else begin
//             y_cnt_w = y_cnt_r;
//         end
//     end

//     // Sync signals
//     always_comb begin
//         if (x_cnt_r == H_FRONT) begin
//             hsync_w = 1'b0;
//         end
//         else if (x_cnt_r == H_FRONT + H_SYNC) begin
//             hsync_w = 1'b1;
//         end
//         else begin
//             hsync_w = hsync_r;
//         end
//     end
    
//     always_comb begin
//         if (y_cnt_r == V_FRONT) begin
//             vsync_w = 1'b0;
//         end
//         else if (y_cnt_r == V_FRONT + V_SYNC) begin
//             vsync_w = 1'b1;                 
//         end
//         else begin
//             vsync_w = vsync_r;
//         end
//     end
    
//     // RGB data
//     always_comb begin
//         if (x_cnt_r < H_BLANK-1 || x_cnt_r > H_TOTAL-1 || y_cnt_r < V_BLANK-1 || y_cnt_r > V_TOTAL-1) begin
//             show_en_w = 0;
//             o_x_cord = 0;
//             o_y_cord = 0;
//         end
//         else begin
//             show_en_w = 1;
//             o_x_cord = y_cnt_r - V_BLANK;
//             o_y_cord = x_cnt_r - H_BLANK;
//         end
//     end

//     // Flip-flop
//     always_ff @(posedge i_clk_25M or negedge i_rst_n) begin
//         if (~i_rst_n) begin
//             x_cnt_r <= 1;   
//             y_cnt_r <= 1;
//             hsync_r <= 1'b1;
//             vsync_r <= 1'b1;
//             show_en_r <= 0;
//         end
//         else begin
//             x_cnt_r <= x_cnt_w;
//             y_cnt_r <= y_cnt_w;
//             hsync_r <= hsync_w;
//             vsync_r <= vsync_w;
//             show_en_r <= show_en_w;
//         end
//     end
// endmodule