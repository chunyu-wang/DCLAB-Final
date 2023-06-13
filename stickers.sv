module sticker(
    input  [10:0] x,
    input  [10:0] y,
    input  [10:0] sticker_pos_x,
    input  [10:0] sticker_pos_y,
    // size > 5
    input  [10:0] size,
    input  [7:0]  color [2:0],
    output [7:0]  rgb [2:0]
);
    // only draw circles
    wire inCircle;
    wire [7:0] transparent [2:0];
    wire [7:0] border [2:0];

    assign transparent[0] = 8'd0;
    assign transparent[1] = 8'd0;
    assign transparent[2] = 8'd0;

    assign border[0] = 8'd1;
    assign border[1] = 8'd1;
    assign border[2] = 8'd1;

    localparam borderSize = 10'd3;

    assign inCircle = ({11'd0,x}-{11'd0,sticker_pos_x})*({11'd0,x}-{11'd0,sticker_pos_x}) +
    ({11'd0,y}-{11'd0,sticker_pos_y})*({11'd0,y}-{11'd0,sticker_pos_y}) 
    <= {12'd0,(size[10:1]-borderSize)}*{12'd0,(size[10:1]-borderSize)};

    assign onCircle = ({11'd0,x}-{11'd0,sticker_pos_x})*({11'd0,x}-{11'd0,sticker_pos_x}) +
    ({11'd0,y}-{11'd0,sticker_pos_y})*({11'd0,y}-{11'd0,sticker_pos_y}) 
    <= {12'd0,(size[10:1])}*{12'd0,(size[10:1])};

    assign rgb = (inCircle) ? color : ((onCircle) ? border : transparent) ;
endmodule


module sticker_heart(
    input  [10:0] x,
    input  [10:0] y,
    input  [10:0] sticker_pos_x,
    input  [10:0] sticker_pos_y,
    // size should >= than 4
    // 2^size = width
    // input  [5:0] size,
    output [7:0]  rgb [2:0]
);
    localparam RANGE = 3;
    // only draw hearts
    wire [7:0] bitmap [15:0][15:0][2:0] ;
    wire [7:0] EMPTY [2:0];
    wire [7:0] RED   [2:0];
    wire [7:0] WHITE [2:0];
    wire [7:0] BLACK [2:0];
    // EMPTY
    assign EMPTY[0] = 8'd0;assign EMPTY[1] = 8'd0;assign EMPTY[2] = 8'd0;
    // RED
    assign RED[0] = 8'd255;assign RED[1] = 8'd1;assign RED[2] = 8'd1;
    // WHITE
    assign WHITE[0] = 8'd255;assign WHITE[1] = 8'd255;assign WHITE[2] = 8'd255;
    // BLACK
    assign BLACK[0] = 8'd1;assign BLACK[1] = 8'd1;assign BLACK[2] = 8'd1;

    wire [10:0] delta_x, delta_y;
    wire [3:0] index_high, index_low;

    localparam size = 5;

    assign delta_x = x - sticker_pos_x + (11'd1 << (size-6'd1));
    assign delta_y = y - sticker_pos_y + (11'd1 << (size-6'd1));

    assign index_high = size - 6'd1;
    assign index_low  = size - 6'd4;
    // BITMAP    
        assign bitmap[0][0] = EMPTY;
    assign bitmap[0][1] = EMPTY;
    assign bitmap[0][2] = EMPTY;
    assign bitmap[0][3] = EMPTY;
    assign bitmap[0][4] = EMPTY;
    assign bitmap[0][5] = EMPTY;
    assign bitmap[0][6] = EMPTY;
    assign bitmap[0][7] = EMPTY;
    assign bitmap[0][8] = EMPTY;
    assign bitmap[0][9] = EMPTY;
    assign bitmap[0][10] = EMPTY;
    assign bitmap[0][11] = EMPTY;
    assign bitmap[0][12] = EMPTY;
    assign bitmap[0][13] = EMPTY;
    assign bitmap[0][14] = EMPTY;
    assign bitmap[0][15] = EMPTY;
    assign bitmap[1][0] = EMPTY;
    assign bitmap[1][1] = EMPTY;
    assign bitmap[1][2] = EMPTY;
    assign bitmap[1][3] = EMPTY;
    assign bitmap[1][4] = EMPTY;
    assign bitmap[1][5] = EMPTY;
    assign bitmap[1][6] = EMPTY;
    assign bitmap[1][7] = EMPTY;
    assign bitmap[1][8] = EMPTY;
    assign bitmap[1][9] = EMPTY;
    assign bitmap[1][10] = EMPTY;
    assign bitmap[1][11] = EMPTY;
    assign bitmap[1][12] = EMPTY;
    assign bitmap[1][13] = EMPTY;
    assign bitmap[1][14] = EMPTY;
    assign bitmap[1][15] = EMPTY;
    assign bitmap[2][0] = EMPTY;
    assign bitmap[2][1] = EMPTY;
    assign bitmap[2][2] = BLACK;
    assign bitmap[2][3] = BLACK;
    assign bitmap[2][4] = BLACK;
    assign bitmap[2][5] = BLACK;
    assign bitmap[2][6] = BLACK;
    assign bitmap[2][7] = EMPTY;
    assign bitmap[2][8] = EMPTY;
    assign bitmap[2][9] = BLACK;
    assign bitmap[2][10] = BLACK;
    assign bitmap[2][11] = BLACK;
    assign bitmap[2][12] = BLACK;
    assign bitmap[2][13] = BLACK;
    assign bitmap[2][14] = EMPTY;
    assign bitmap[2][15] = EMPTY;
    assign bitmap[3][0] = EMPTY;
    assign bitmap[3][1] = BLACK;
    assign bitmap[3][2] = BLACK;
    assign bitmap[3][3] = RED;
    assign bitmap[3][4] = RED;
    assign bitmap[3][5] = RED;
    assign bitmap[3][6] = BLACK;
    assign bitmap[3][7] = BLACK;
    assign bitmap[3][8] = BLACK;
    assign bitmap[3][9] = BLACK;
    assign bitmap[3][10] = RED;
    assign bitmap[3][11] = RED;
    assign bitmap[3][12] = RED;
    assign bitmap[3][13] = BLACK;
    assign bitmap[3][14] = BLACK;
    assign bitmap[3][15] = EMPTY;
    assign bitmap[4][0] = BLACK;
    assign bitmap[4][1] = BLACK;
    assign bitmap[4][2] = RED;
    assign bitmap[4][3] = WHITE;
    assign bitmap[4][4] = WHITE;
    assign bitmap[4][5] = RED;
    assign bitmap[4][6] = RED;
    assign bitmap[4][7] = BLACK;
    assign bitmap[4][8] = BLACK;
    assign bitmap[4][9] = RED;
    assign bitmap[4][10] = RED;
    assign bitmap[4][11] = RED;
    assign bitmap[4][12] = RED;
    assign bitmap[4][13] = RED;
    assign bitmap[4][14] = BLACK;
    assign bitmap[4][15] = BLACK;
    assign bitmap[5][0] = BLACK;
    assign bitmap[5][1] = BLACK;
    assign bitmap[5][2] = RED;
    assign bitmap[5][3] = WHITE;
    assign bitmap[5][4] = RED;
    assign bitmap[5][5] = RED;
    assign bitmap[5][6] = RED;
    assign bitmap[5][7] = RED;
    assign bitmap[5][8] = RED;
    assign bitmap[5][9] = RED;
    assign bitmap[5][10] = RED;
    assign bitmap[5][11] = RED;
    assign bitmap[5][12] = RED;
    assign bitmap[5][13] = RED;
    assign bitmap[5][14] = BLACK;
    assign bitmap[5][15] = BLACK;
    assign bitmap[6][0] = BLACK;
    assign bitmap[6][1] = BLACK;
    assign bitmap[6][2] = RED;
    assign bitmap[6][3] = RED;
    assign bitmap[6][4] = RED;
    assign bitmap[6][5] = RED;
    assign bitmap[6][6] = RED;
    assign bitmap[6][7] = RED;
    assign bitmap[6][8] = RED;
    assign bitmap[6][9] = RED;
    assign bitmap[6][10] = RED;
    assign bitmap[6][11] = RED;
    assign bitmap[6][12] = RED;
    assign bitmap[6][13] = RED;
    assign bitmap[6][14] = BLACK;
    assign bitmap[6][15] = BLACK;
    assign bitmap[7][0] = BLACK;
    assign bitmap[7][1] = BLACK;
    assign bitmap[7][2] = RED;
    assign bitmap[7][3] = RED;
    assign bitmap[7][4] = RED;
    assign bitmap[7][5] = RED;
    assign bitmap[7][6] = RED;
    assign bitmap[7][7] = RED;
    assign bitmap[7][8] = RED;
    assign bitmap[7][9] = RED;
    assign bitmap[7][10] = RED;
    assign bitmap[7][11] = RED;
    assign bitmap[7][12] = RED;
    assign bitmap[7][13] = RED;
    assign bitmap[7][14] = BLACK;
    assign bitmap[7][15] = BLACK;
    assign bitmap[8][0] = EMPTY;
    assign bitmap[8][1] = BLACK;
    assign bitmap[8][2] = BLACK;
    assign bitmap[8][3] = RED;
    assign bitmap[8][4] = RED;
    assign bitmap[8][5] = RED;
    assign bitmap[8][6] = RED;
    assign bitmap[8][7] = RED;
    assign bitmap[8][8] = RED;
    assign bitmap[8][9] = RED;
    assign bitmap[8][10] = RED;
    assign bitmap[8][11] = RED;
    assign bitmap[8][12] = RED;
    assign bitmap[8][13] = BLACK;
    assign bitmap[8][14] = BLACK;
    assign bitmap[8][15] = EMPTY;
    assign bitmap[9][0] = EMPTY;
    assign bitmap[9][1] = EMPTY;
    assign bitmap[9][2] = BLACK;
    assign bitmap[9][3] = BLACK;
    assign bitmap[9][4] = RED;
    assign bitmap[9][5] = RED;
    assign bitmap[9][6] = RED;
    assign bitmap[9][7] = RED;
    assign bitmap[9][8] = RED;
    assign bitmap[9][9] = RED;
    assign bitmap[9][10] = RED;
    assign bitmap[9][11] = RED;
    assign bitmap[9][12] = BLACK;
    assign bitmap[9][13] = BLACK;
    assign bitmap[9][14] = EMPTY;
    assign bitmap[9][15] = EMPTY;
    assign bitmap[10][0] = EMPTY;
    assign bitmap[10][1] = EMPTY;
    assign bitmap[10][2] = EMPTY;
    assign bitmap[10][3] = BLACK;
    assign bitmap[10][4] = BLACK;
    assign bitmap[10][5] = RED;
    assign bitmap[10][6] = RED;
    assign bitmap[10][7] = RED;
    assign bitmap[10][8] = RED;
    assign bitmap[10][9] = RED;
    assign bitmap[10][10] = RED;
    assign bitmap[10][11] = BLACK;
    assign bitmap[10][12] = BLACK;
    assign bitmap[10][13] = EMPTY;
    assign bitmap[10][14] = EMPTY;
    assign bitmap[10][15] = EMPTY;
    assign bitmap[11][0] = EMPTY;
    assign bitmap[11][1] = EMPTY;
    assign bitmap[11][2] = EMPTY;
    assign bitmap[11][3] = EMPTY;
    assign bitmap[11][4] = BLACK;
    assign bitmap[11][5] = BLACK;
    assign bitmap[11][6] = RED;
    assign bitmap[11][7] = RED;
    assign bitmap[11][8] = RED;
    assign bitmap[11][9] = RED;
    assign bitmap[11][10] = BLACK;
    assign bitmap[11][11] = BLACK;
    assign bitmap[11][12] = EMPTY;
    assign bitmap[11][13] = EMPTY;
    assign bitmap[11][14] = EMPTY;
    assign bitmap[11][15] = EMPTY;
    assign bitmap[12][0] = EMPTY;
    assign bitmap[12][1] = EMPTY;
    assign bitmap[12][2] = EMPTY;
    assign bitmap[12][3] = EMPTY;
    assign bitmap[12][4] = EMPTY;
    assign bitmap[12][5] = BLACK;
    assign bitmap[12][6] = BLACK;
    assign bitmap[12][7] = RED;
    assign bitmap[12][8] = RED;
    assign bitmap[12][9] = BLACK;
    assign bitmap[12][10] = BLACK;
    assign bitmap[12][11] = EMPTY;
    assign bitmap[12][12] = EMPTY;
    assign bitmap[12][13] = EMPTY;
    assign bitmap[12][14] = EMPTY;
    assign bitmap[12][15] = EMPTY;
    assign bitmap[13][0] = EMPTY;
    assign bitmap[13][1] = EMPTY;
    assign bitmap[13][2] = EMPTY;
    assign bitmap[13][3] = EMPTY;
    assign bitmap[13][4] = EMPTY;
    assign bitmap[13][5] = EMPTY;
    assign bitmap[13][6] = BLACK;
    assign bitmap[13][7] = BLACK;
    assign bitmap[13][8] = BLACK;
    assign bitmap[13][9] = BLACK;
    assign bitmap[13][10] = EMPTY;
    assign bitmap[13][11] = EMPTY;
    assign bitmap[13][12] = EMPTY;
    assign bitmap[13][13] = EMPTY;
    assign bitmap[13][14] = EMPTY;
    assign bitmap[13][15] = EMPTY;
    assign bitmap[14][0] = EMPTY;
    assign bitmap[14][1] = EMPTY;
    assign bitmap[14][2] = EMPTY;
    assign bitmap[14][3] = EMPTY;
    assign bitmap[14][4] = EMPTY;
    assign bitmap[14][5] = EMPTY;
    assign bitmap[14][6] = EMPTY;
    assign bitmap[14][7] = EMPTY;
    assign bitmap[14][8] = EMPTY;
    assign bitmap[14][9] = EMPTY;
    assign bitmap[14][10] = EMPTY;
    assign bitmap[14][11] = EMPTY;
    assign bitmap[14][12] = EMPTY;
    assign bitmap[14][13] = EMPTY;
    assign bitmap[14][14] = EMPTY;
    assign bitmap[14][15] = EMPTY;
    assign bitmap[15][0] = EMPTY;
    assign bitmap[15][1] = EMPTY;
    assign bitmap[15][2] = EMPTY;
    assign bitmap[15][3] = EMPTY;
    assign bitmap[15][4] = EMPTY;
    assign bitmap[15][5] = EMPTY;
    assign bitmap[15][6] = EMPTY;
    assign bitmap[15][7] = EMPTY;
    assign bitmap[15][8] = EMPTY;
    assign bitmap[15][9] = EMPTY;
    assign bitmap[15][10] = EMPTY;
    assign bitmap[15][11] = EMPTY;
    assign bitmap[15][12] = EMPTY;
    assign bitmap[15][13] = EMPTY;
    assign bitmap[15][14] = EMPTY;
    assign bitmap[15][15] = EMPTY;

    wire [5:0] hi , lo;
    assign hi = delta_y[size-1:size-4];
    assign lo = delta_x[size-1:size-4];
    wire [7:0] block [15:0] [2:0] ;
    assign block = bitmap[hi];
    // parameter lo = 4;
    assign rgb = (delta_x < (11'd1 << size) && delta_y < (11'd1 << size)) ?
    block[lo] :
    EMPTY;
endmodule