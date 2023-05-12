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
    localparam FRON_V     = 11;
    localparam SYNC_V     = 2;
    localparam BACK_V     = 31;
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

    // assign
    assign VGA_R  = (hstate == S_ACTI && vstate == S_ACTI) ? R : 8'd0;
    assign VGA_G  = (hstate == S_ACTI && vstate == S_ACTI) ? G : 8'd0;
    assign VGA_B  = (hstate == S_ACTI && vstate == S_ACTI) ? B : 8'd0;

    assign VGA_HS = hsync;
    assign VGA_VS = vsync;

    assign HORIZON  = ho;
    assign VERTICAL = ve;

    // TODO (unsure the function)
    assign VGA_BLANK_N = (vstate == S_ACTI && hstate == S_ACTI);
    assign VGA_SYNC_N  = 1'b1;

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
                hsync_next = 1'b1;
                if(hcount == FRON_H -1)begin
                    hstate_next = S_SYNC;
                    hcount_next = 10'd0;
                    hsync_next = 1'b0;
                end
                else begin
                    hstate_next = hstate;
                    hcount_next = hcount + 10'd1;
                end
            end
            S_SYNC:begin
                hsync_next = 1'b0;
                if(hcount == SYNC_H -1)begin
                    hstate_next = S_BACK;
                    hcount_next = 10'd0;
                    hsync_next = 1'b1;
                end
                else begin
                    hstate_next = hstate;
                    hcount_next = hcount + 10'd1;
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
                ve_next = ve + 11'd1;
            end
            else begin
                ho_next = 11'd0;
                ve_next = 11'd0;
            end
        end
        else begin
            ho_next = ho;
            ve_next = ve;
        end
    end

    always_ff @( negedge rst_n or negedge clk) begin
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