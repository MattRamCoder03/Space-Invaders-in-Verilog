`timescale 1ns / 1ps

module AlienShip(
input clk, reset, collide, video_on, refresh_tick,
input [9:0] hpos, vpos, alien_center, alien_layer,
output alien_on_out, 
output reg alien_alive,
output reg [9:0] alien_l_reg, alien_r_reg, alien_t_reg, alien_b_reg
    );
    
    //invader ship 
    //size 32 by 32
    wire [4:0] alien_addr, alien_col;
    reg[31:0] alien_data;
    wire alien_bit, alien_on, alien_color_on, movement_tick;
    
    wire [9:0] alien_l, alien_r, alien_t, alien_b, h_alien_nxt;
    
    reg[9:0] h_alien_reg, h_velo_next, h_velo_reg, X_ALIEN_MAX, X_ALIEN_MIN;
    
    parameter alien_velo = 1;
    parameter ALIEN_SIZE = 32;
    //parameter Y_ALIEN_T = 40;
    //parameter Y_ALIEN_B = 40 + ALIEN_SIZE-1;
    //parameter XMAX and XMIN
    //reverse velo when XMAX and/or XMIN is reached
    //initialize x_velo at start as +1 (so we are going to the right) 
    reg alien_alive, alien_alive_reg, alien_alive_prev;
    
    parameter alien_color = 12'h00F;
    reg[3:0] movement_reg;
    
    always@(posedge clk or posedge reset) begin 
    if(reset) begin
        movement_reg<=4'b0000;
    end
    else if (refresh_tick) begin 
        movement_reg<=movement_reg+1;
    end 
    end 
    
    assign movement_tick=(movement_reg==4'b1111);
        //resets for both ships, reset to center 
    always@(posedge clk or posedge reset) begin 
        if (reset) begin 
            h_alien_reg<=alien_center;
            h_velo_reg<=10'h001;
        end 
        else begin
            h_alien_reg<=h_alien_nxt;
            h_velo_reg<=h_velo_next;
            X_ALIEN_MAX<=alien_center+80;
            X_ALIEN_MIN<=alien_center-80;
            end 
       // end 
    end 
    
    always@(posedge clk) begin
     if (refresh_tick) begin
            alien_l_reg<=alien_l;
            alien_r_reg<=alien_r;
            alien_t_reg<=alien_t;
            alien_b_reg<=alien_b;
            alien_alive_reg<=~collide;
            alien_alive_prev<=alien_alive_reg;
        end 
    end 
    
    always@(posedge clk or posedge reset) begin
        if (reset) begin 
            alien_alive<=1'b1;
        end 
        else if (refresh_tick) begin 
            if (~alien_alive_reg && alien_alive_prev) begin
                alien_alive<=0;
                //next 4 are test
            end 
            else begin 
                alien_alive<=alien_alive;
            end
        end 
    end 
    
        //always block for alien ship, 5-bits for 32x32 shape
    always@(*) begin 
    case(alien_addr)
        5'b11100: begin alien_data =32'h00FFFF00; end 
        5'b11101: begin alien_data =32'h00FFFF00; end 
        5'b11110: begin alien_data =32'h00FFFF00; end 
        5'b11111: begin alien_data =32'h00FFFF00; end 
        default: begin alien_data =32'hFFFFFFFF; end
    endcase
    end 
    
    always@(*) begin 
        h_velo_next=h_velo_reg;
    if (alien_r > X_ALIEN_MAX) begin 
        h_velo_next = -alien_velo;
        end 
    else if (alien_l < X_ALIEN_MIN) begin 
        h_velo_next = alien_velo;
        end 
    end
        
    assign alien_t = alien_layer;
    assign alien_b = alien_layer+ALIEN_SIZE-1;
    assign alien_l = h_alien_reg;
    assign alien_r = h_alien_reg+ALIEN_SIZE-1;
    
    assign h_alien_nxt = (movement_tick) ?  h_alien_reg+h_velo_reg:h_alien_reg;
    
    assign alien_on = (alien_alive) && ((hpos >= alien_l) && (hpos <= alien_r) && (vpos >= alien_t) && (vpos <= alien_b));
    assign alien_addr = vpos[4:0] - alien_t[4:0];
    assign alien_col = hpos[4:0] - alien_l[4:0];
    assign alien_bit = alien_data[alien_col];
    assign alien_color_on = alien_on & alien_bit;
    
    assign alien_on_out = alien_color_on;
    
endmodule
