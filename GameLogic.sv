module GameLogic(
    input i_clk,
    input i_rst_n,
    input predict_valid,
    input enter_game,
    input start,
    input FrameStart,
    input ThisFrameEnd,
    input [10:0] left  [1:0],
    input [10:0] right [1:0],
    input [10:0] up    [1:0],
    input [10:0] down  [1:0],
    input x,
    input y,

    output [7:0] rgb [2:0]
);
    parameter S_IDLE  = 3'd0;
    parameter S_INIT  = 3'd1;    // background image init
    parameter S_START = 3'd2;    // show the start bg
    parameter S_GAME  = 3'd3;
    parameter S_RESULT= 3'd4;

    parameter S_


    logic [31:0] frame_cnt, frame_cnt_nxt;
    logic [31:0] cnt, cnt_nxt;
    logic [1:0] life, life_nxt;
    logic [2:0] Ball_number,Ball_number_next; // 0~4
    logic [20:0] score, score_nxt;

    logic [10:0] Ball_x [3:0]; // 8 balls
    logic [10:0] Ball_y [3:0]; // 8 balls
    logic [10:0] Ball_x_nxt [2:0]; // 8 balls
    logic [10:0] Ball_y_nxt [2:0]; // 8 balls

    logic [5:0] Ball_vx [2:0]; // 8 balls
    logic [5:0] Ball_vy [2:0]; // 8 balls
    logic [5:0] Ball_vx_nxt [2:0]; // 8 balls
    logic [5:0] Ball_vy_nxt [2:0]; // 8 balls

    logic gameenter, gameenter_nxt;
    logic gamestart, gamestart_nxt;

    parameter Ball_ax = 0;
    parameter Ball_ay = 1;

    logic [2:0] state, state_nxt;

    logic [10:0] prev_x [1:0];
    logic [10:0] prev_y [1:0];
    logic [10:0] prev_x_nxt [1:0];
    logic [10:0] prev_y_nxt [1:0];

    logic [10:0] this_x, this_y;

    logic [2:0] gameState, gameState_nxt;

    // assign vga pattern

    always_comb begin
        case (state)
            S_IDLE:begin
                gameenter_nxt = (enter_game) ? 1'b1 : gameenter ;
                if(gameenter && ThisFrameEnd)begin
                    state_nxt = S_START;
                end
                else begin
                    state_nxt = state;
                end
            end
            S_START:begin
                // game start combinational vga
                gamestart_nxt = (start) ? 1'b1 : gamestart;
                if(gamestart && ThisFrameEnd)begin
                    state_nxt = S_GAME;
                end
                else begin
                    state_nxt = state;
                end
            end
            S_GAME:begin
                if(predict_valid)begin
                    if(left[0] == 11'd2023)begin
                        // not found in this frame
                        this_x = prev_x[0] << 1 - prev_x[1]; 
                        this_y = prev_y[0] << 1 - prev_y[1]; 
                    end
                    else begin
                        //found in this frame
                        this_x = (({left[0]} + {right[0]})>>1 + ({down[0]} + {up[0]}) >>1) >>1;
                        this_y = (({left[1]} + {right[1]})>>1 + ({down[1]} + {up[1]}) >>1) >>1;
                    end
                    prev_x_nxt[0] = prev_x[1];
                    prev_x_nxt[1] = this_x;
                    prev_y_nxt[0] = prev_y[1];
                    prev_y_nxt[1] = this_y;

                    // test ball cut

                    // up date new ball pos

                    // check gen new ball

                    // ball out of screen -> minus life

                    // frame count ++
                end
            end
            S_RESULT:begin
                // show result screen

                // if game start go to S_START
            end
        endcase
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)begin
            cnt <= 32'd0;
        end
        else begin
            cnt <= cnt_nxt
        end
    end
endmodule


module sticker(
    input  [10:0] x,
    input  [10:0] y,
    input  [10:0] sticker_pos_x,
    input  [10:0] sticker_pos_y,
    input  [10:0] size,
    input  [7:0]  color [2:0],
    output [7:0]  rgb [2:0]
);
    // only draw circles
    wire inCircle;
    wire [7:0] transparent [2:0];

    assign transparent[0] = 8'd0;
    assign transparent[1] = 8'd0;
    assign transparent[2] = 8'd0;

    assign inCircle = ({11'd0,x}-{11'd0,sticker_pos_x})*({11'd0,x}-{11'd0,sticker_pos_x}) +
    ({11'd0,y}-{11'd0,sticker_pos_y})*({11'd0,y}-{11'd0,sticker_pos_y}) 
    <= {12'd0,size[10:1]}*{12'd0,size[10:1]};

    assign rgb = (inCircle) ? color : transparent ;
endmodule


module RandomNumberGen(
    input  i_clk,
    input  i_rst_n,
    output [199:0] i_data
);

    reg [199:0] data_next;
    integer i;
    always_comb begin
        for(i=199;i>2;i=i-1)begin
            data_next[i] = data[i]^data[i-3];
        end
        data_next[2] = data[2]^data[199];
        data_next[1] = data[1]^data[198];
        data_next[0] = data[0]^data[197];
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)begin
            data <= {50{4'hf}}
        end
        else begin
            data <= data_next;
        end
    end
endmodule