`include "stickers.sv"

module GameLogic(
    input i_clk,
    input i_rst_n,
    input predict_valid,
    input enter_game,
    input start,
    input ThisFrameEnd,
    input [10:0] left  [1:0],
    input [10:0] right [1:0],
    input [10:0] up    [1:0],
    input [10:0] down  [1:0],
    input [10:0] x,
    input [10:0] y,
    input [7:0] i_rgb [2:0],
    output [7:0] o_rgb [2:0]
);
    parameter S_IDLE  = 3'd0;
    parameter S_INIT  = 3'd1;    // background image init
    parameter S_START = 3'd2;    // show the start bg
    parameter S_GAME  = 3'd3;
    parameter S_RESULT= 3'd4;

    integer i,j,k;


    logic [31:0] frame_cnt, frame_cnt_nxt;
    logic [31:0] cnt, cnt_nxt;
    logic [1:0] life, life_nxt;
    reg [3:0] Ball_number [3:0];
    logic [3:0] Ball_number_nxt [3:0]; // 0~4
    logic [20:0] score, score_nxt;

    logic [10:0] Ball_x [3:0]; // 4 balls
    logic [10:0] Ball_y [3:0]; // 4 balls
    logic [10:0] Ball_x_nxt [3:0]; // 4 balls
    logic [10:0] Ball_y_nxt [3:0]; // 4 balls

    logic [10:0] Ball_vx [3:0]; // 4 balls
    logic [10:0] Ball_vy [3:0]; // 4 balls
    logic [10:0] Ball_vx_nxt [3:0]; // 4 balls
    logic [10:0] Ball_vy_nxt [3:0]; // 4 balls

    parameter BallSize = 22'd625; // 30^2

    logic gameenter, gameenter_nxt;
    logic gamestart, gamestart_nxt;

    parameter Ball_ax = 0;
    parameter Ball_ay = 1;

    logic [2:0] state, state_nxt;

    logic [10:0] prev_x [1:0];
    logic [10:0] prev_y [1:0];
    logic [10:0] prev_x_nxt [1:0];
    logic [10:0] prev_y_nxt [1:0];

    wire [10:0] this_x, this_y;

    wire [3:0] first_ball_index, first_ball_num;

    logic [31:0] prev_gen_frame,prev_gen_frame_nxt;

    wire [7:0] sticker_rgb [3:0][2:0];
    wire [7:0] life_rgb [2:0][2:0];
    wire [7:0] hit_rgb [2:0];

    logic [7:0] COLOR_white [2:0];
    assign COLOR_white[0] = 8'd255;assign COLOR_white[1] = 8'd255;assign COLOR_white[2] = 8'd255;
    
    logic [7:0] COLOR_red [2:0];
    assign COLOR_red[0] = 8'd255;assign COLOR_red[1] = 8'd1;assign COLOR_red[2] = 8'd1;

    logic [7:0] COLOR_green [2:0];
    assign COLOR_green[0] = 8'd1;assign COLOR_green[1] = 8'd255;assign COLOR_green[2] = 8'd1;
    
    assign first_ball_num = (Ball_number[0]>4'd3)? 4'd0 :
    (Ball_number[1]>4'd3)? 4'd1 :
    (Ball_number[2]>4'd3)? 4'd2 :
    (Ball_number[3]>4'd3)? 4'd3 :
    4'd4;
    assign first_ball_index = first_ball_num;

    
    assign this_x = //(left[0] == 11'd2023) ? prev_x[1] << 1 - prev_x[0] : 
    (  ((left[0] + right[0])>>1) + ((down[0] + up[0]) >>1)) >>1;
    assign this_y = //(left[0] == 11'd2023) ? prev_y[1] << 1 - prev_y[0] :
    (  ((left[1] + right[1])>>1) + ((down[1] + up[1]) >>1)) >>1;
        
    genvar  myGenvar;
    generate
        
        for(myGenvar=0;myGenvar<4;myGenvar=myGenvar+1)begin : ballSticker
            sticker stickers(
                .x(x),
                .y(y),
                .sticker_pos_x(Ball_x[myGenvar]),
                .sticker_pos_y(Ball_y[myGenvar]),
                .size(11'd50),
                .color(COLOR_white),
                .rgb(sticker_rgb[myGenvar])
            );
        end
    endgenerate

    generate
        for(myGenvar=0;myGenvar<3;myGenvar=myGenvar+1)begin: lifeSticker
            sticker_heart stickers_heart(
                .x(x),
                .y(y),
                .sticker_pos_x(11'd615 - myGenvar*11'd45),
                .sticker_pos_y(11'd60),
                // .size(6'd5),
                // .size_1(6'd4),
                // .size_4(6'd1),
                .rgb(life_rgb[myGenvar])
            );
        end
    endgenerate

    sticker yourHit(
        .x(x),
        .y(y),
        .sticker_pos_x(this_x),
        .sticker_pos_y(this_y),
        .size(30),
        .color(COLOR_green),
        .rgb(hit_rgb)
    );

    logic [199:0] random_bits;

    RandomNumberGen rd0(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .data(random_bits)
    );

    logic [7:0] rgb [2:0];
    assign o_rgb = rgb;

    always_comb begin
        rgb = // UI please draw here
        (state==S_GAME)? (
        (hit_rgb[0]>8'd0) ? hit_rgb : 
        (life > 0 && life_rgb[0][0] > 8'd0) ? life_rgb[0] :
        (life > 1 && life_rgb[1][0] > 8'd0) ? life_rgb[1] :
        (life > 2 && life_rgb[2][0] > 8'd0) ? life_rgb[2] :
        (Ball_number[0] < 4'd4 && sticker_rgb[Ball_number[0]][0] > 8'd0) ? sticker_rgb[Ball_number[0]] :
        (Ball_number[1] < 4'd4 && sticker_rgb[Ball_number[1]][0] > 8'd0) ? sticker_rgb[Ball_number[1]] :
        (Ball_number[2] < 4'd4 && sticker_rgb[Ball_number[2]][0] > 8'd0) ? sticker_rgb[Ball_number[2]] :
        (Ball_number[3] < 4'd4 && sticker_rgb[Ball_number[3]][0] > 8'd0) ? sticker_rgb[Ball_number[3]] :
        i_rgb ): COLOR_red;

    end

    integer myint,myint2;
    // game logic
    always_comb begin
        cnt_nxt = cnt;
        frame_cnt_nxt = frame_cnt;
        state_nxt = state;
        prev_gen_frame_nxt = prev_gen_frame;
        for(myint2=0;myint2<4;myint2=myint2+1)begin
            Ball_number_nxt[myint2] = Ball_number[myint2];
            Ball_x_nxt[myint2] = Ball_x[myint2];
            Ball_y_nxt[myint2] = Ball_y[myint2];
            Ball_vx_nxt[myint2] = Ball_vx[myint2];
            Ball_vy_nxt[myint2] = Ball_vy[myint2];
        end
        life_nxt = life;
        prev_x_nxt = prev_x;
        prev_y_nxt = prev_y;
        gamestart_nxt = gamestart;
        gameenter_nxt = gameenter;
        score_nxt     = score;
                        
        for(i=0;i<0;i=i+1)begin end
        for(j=0;j<0;j=j+1)begin end
        case (state)
            S_IDLE:begin
                gameenter_nxt = (enter_game) ? 1'b1 : gameenter ;
                if(gameenter && ThisFrameEnd)begin
                    state_nxt = S_START;
                    gamestart_nxt = 1'b0;
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
                    life_nxt = 2'd3;
                    score_nxt = 21'd0;
                    for(myint2=0;myint2<4;myint2=myint2+1)begin
                        Ball_number_nxt[myint2] = 4'd4;
                        Ball_x_nxt[myint2] = 11'd0;
                        Ball_y_nxt[myint2] = 11'd0;
                        Ball_vx_nxt[myint2] = 11'd0;
                        Ball_vy_nxt[myint2] = 11'd0;
                    end
                    prev_x_nxt[0] = 11'd0;
                    prev_x_nxt[1] = 11'd0;
                    prev_y_nxt[0] = 11'd0;
                    prev_y_nxt[1] = 11'd0;
                    frame_cnt_nxt = 32'd0;
                    prev_gen_frame_nxt = 32'd0;
                end
                else begin
                    state_nxt = state;
                end
            end
            S_GAME:begin
                if(predict_valid)begin
                    if(left[0] == 11'd2023)begin
                        // not found in this frame
                        // this_x = prev_x[1] << 1 - prev_x[0]; 
                        // this_y = prev_y[1] << 1 - prev_y[0]; 
                        prev_x_nxt[0] = prev_x[1];
                        prev_x_nxt[1] = this_x;
                        prev_y_nxt[0] = prev_y[1];
                        prev_y_nxt[1] = this_y;
                    end
                    else begin
                        //found in this frame
                        // this_x = (({left[0]} + {right[0]})>>1 + ({down[0]} + {up[0]}) >>1) >>1;
                        // this_y = (({left[1]} + {right[1]})>>1 + ({down[1]} + {up[1]}) >>1) >>1;
                        prev_x_nxt[0] = prev_x[1];
                        prev_x_nxt[1] = this_x;
                        prev_y_nxt[0] = prev_y[1];
                        prev_y_nxt[1] = this_y;
                    end
                    // up date new ball pos
                    for(j=0;j<4;j=j+1)begin
                        //Ball_x_nxt[j] =  (Ball_number[i]==j) ? Ball_x[j]  + {Ball_vx[j][10],Ball_vx[j][10:1]} : Ball_x[j] ;
                        Ball_x_nxt[j] = (j == Ball_number[0] || j == Ball_number[1] || j == Ball_number[2] || j == Ball_number[3]) ?
                        Ball_x[j] + {Ball_vx[j][10],Ball_vx[j][10:1]} : Ball_x[j];

                        Ball_y_nxt[j] = (j == Ball_number[0] || j == Ball_number[1] || j == Ball_number[2] || j == Ball_number[3]) ?
                        Ball_y[j] + {Ball_vy[j][10],Ball_vy[j][10:1]} : Ball_y[j];
                        
                        Ball_vx_nxt[j] = Ball_vx[j] ;
                        
                        Ball_vy_nxt[j] = (j == Ball_number[0] || j == Ball_number[1] || j == Ball_number[2] || j == Ball_number[3]) ?
                        Ball_vy[j] + 11'd1 : Ball_vy[j] ;
                    end

                    // test ball cut
                    for(i=0;i<4;i=i+1)begin
                        if(Ball_number[i]<4'd4)begin
                            if({{11{Ball_x[Ball_number[i]]<this_x}},(Ball_x[Ball_number[i]]-this_x)}*{{11{Ball_x[Ball_number[i]]<this_x}},(Ball_x[Ball_number[i]]-this_x)}+
                            {{11{Ball_y[Ball_number[i]]<this_y}},(Ball_y[Ball_number[i]]-this_y)}*{{11{Ball_y[Ball_number[i]]<this_y}},(Ball_y[Ball_number[i]]-this_y)}
                            <= BallSize) begin
                                //in circle, remove circle
                                for(j=0;j<4;j=j+1)begin
                                    Ball_number_nxt[j] = (i==j) ? 4'd5 : Ball_number[j];
                                end
                                // update score
                                score_nxt = score + 21'd1;
                            end
                            else begin
                                //not in circle
                                
                                // ball out of screen -> minus life
                                if(Ball_y[Ball_number[i]] > 11'd480)begin
                                    for(j=0;j<4;j=j+1)begin
                                        Ball_number_nxt[j] = (i==j) ? 4'd4 : Ball_number[j];
                                    end
                                    life_nxt = life - 2'd1;
                                end
                                else begin
                                end
                            end
                        end
                        else begin
                        end
                    end
                    
                    // check gen new ball
                    if(first_ball_num != 4'd4 && (frame_cnt - prev_gen_frame > 32'd30))begin
                        for(i=0;i<4;i=i+1)begin
                            // generate in fixed position and velocity
                            Ball_number_nxt[i] = (i==first_ball_num) ? first_ball_index : Ball_number_nxt[i];
                            Ball_x_nxt[i] = (i==first_ball_index) ? 11'd102 : Ball_x_nxt[i];
                            Ball_y_nxt[i] = (i==first_ball_index) ? 11'd479 : Ball_y_nxt[i];
                            Ball_vx_nxt[i] = (i==first_ball_index) ? 11'd6             : Ball_vx_nxt[i];
                            Ball_vy_nxt[i] = (i==first_ball_index) ? 11'd0 - 11'd34 : Ball_vy_nxt[i];
                        end
                        prev_gen_frame_nxt = frame_cnt;
                    end
                    // check game end

                    if(frame_cnt == 32'd10800 || life == 2'd0)begin  // 3min or die
                        state_nxt = S_RESULT;
                    end
                    else begin
                        state_nxt = S_GAME;
                    end
                    
                    // frame count ++
                    frame_cnt_nxt = frame_cnt + 32'd1;
                end
                else begin
                end
            end
            S_RESULT:begin
                // show result screen

                // if game start go to S_START
                gamestart_nxt = (start) ? 1'b1 : gamestart;
                if(gamestart && ThisFrameEnd)begin
                    state_nxt = S_GAME;
                    life_nxt = 2'd3;
                    score_nxt = 21'd0;
                    for(myint2=0;myint2<4;myint2=myint2+1)begin
                        Ball_number_nxt[myint2] = 4'd4;
                        Ball_x_nxt[myint2] = 11'd0;
                        Ball_y_nxt[myint2] = 11'd0;
                        Ball_vx_nxt[myint2] = 11'd0;
                        Ball_vy_nxt[myint2] = 11'd0;
                    end
                    prev_x_nxt[0] = 11'd0;
                    prev_x_nxt[1] = 11'd0;
                    prev_y_nxt[0] = 11'd0;
                    prev_y_nxt[1] = 11'd0;
                    frame_cnt_nxt = 32'd0;
                    prev_gen_frame_nxt = 32'd0;
                end
                else begin
                    state_nxt = state;
                end
            end
            default:begin
            end
        endcase
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)begin
            cnt <= 32'd0;
            frame_cnt <= 32'd0;
            state <= 3'd0;
            prev_gen_frame <= 32'd0;
            
            for(myint=0;myint<4;myint=myint+1)begin
                Ball_number[myint] <= 4'd4;
                Ball_x[myint] <= 11'd0;
                Ball_y[myint] <= 11'd0;
                Ball_vx[myint] <= 11'd0;
                Ball_vy[myint] <= 11'd0;
            end
            
            life <= 2'd0;
            prev_x[0] <= 11'd0;
            prev_y[0] <= 11'd0;
            prev_x[1] <= 11'd0;
            prev_y[1] <= 11'd0;
            gamestart <= 1'd0;
            gameenter <= 1'd0;
            score <= 21'd0;
        end
        else begin
            cnt <= cnt_nxt;
            frame_cnt <= frame_cnt_nxt;
            state <= state_nxt;
            for(myint=0;myint<4;myint=myint+1)begin
                Ball_number[myint] <= Ball_number_nxt[myint];
                Ball_x[myint]      <= Ball_x_nxt[myint];
                Ball_y[myint]      <= Ball_y_nxt[myint];
                Ball_vx[myint]     <= Ball_vx_nxt[myint];
                Ball_vy[myint]     <= Ball_vy_nxt[myint];
            end
            prev_gen_frame <= prev_gen_frame_nxt;
            life <= life_nxt;
            prev_x <= prev_x_nxt;
            prev_y <= prev_y_nxt;
            gamestart <= gamestart_nxt;
            gameenter <= gameenter_nxt;
            score <= score_nxt;

        end
    end





endmodule



module RandomNumberGen(
    input  i_clk,
    input  i_rst_n,
    output reg [199:0] data
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

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)begin
            data <= {50{4'hf}};
        end
        else begin
            data <= data_next;
        end
    end
endmodule