`timescale 1ns / 1ps

module UserShip(
input clk,
input left, right, shoot,
input reset,
input collide,
input refresh_tick,
input [9:0] hpos, vpos, ship_t, ship_b,
output ship_color_on,
output reg ship_alive,
output [9:0] ship_l, ship_r
    );
    
   
   wire [3:0] rom_addr, rom_col;
   reg[15:0] rom_data;
   wire rom_bit;
   //wires for next_pos, boundaries, color, and timing status

   wire ship_on;
   //register for current velo, next velo, and current position
   wire [9:0] ship_l, ship_r, ship_t, ship_b;
   reg[9:0] ship_l_reg, ship_b_reg, ship_r_reg, ship_t_reg;
   
   reg[9:0] h_ship_reg, h_ship_nxt;
   parameter ship_velo = 1;
   parameter Y_SHIP_T = 440;
   parameter Y_SHIP_B = Y_SHIP_T + SHIP_LENGTH-1;
   parameter SHIP_LENGTH = 16;
   
   reg ship_alive_reg, ship_alive_prev;
    
        //resets for ship register
   always@(posedge clk or posedge reset) begin 
    if (reset) begin 
            h_ship_reg<=320;
        end 
        else begin 
            h_ship_reg<=h_ship_nxt;
        end 
    end 
    
    always@(posedge clk) begin 
    if (refresh_tick) begin 
            ship_t_reg<=ship_t;
            ship_b_reg<=ship_b;
            ship_l_reg<=ship_l;
            ship_r_reg<=ship_r;
            ship_alive_reg<=~collide;
            ship_alive_prev<=ship_alive_reg;
        end 
     end 
    
    //always block for user alive 
    always@(posedge clk or posedge reset) begin 
    if (reset) begin 
        ship_alive<=1'b1;
    end 
    else if (refresh_tick) begin 
        if (~ship_alive_reg && ship_alive_prev) begin 
        ship_alive<=1'b0;
        end 
        else begin 
        ship_alive<=ship_alive;
        end 
        end 
    end 
    //always block for user ship 4-bits for 16x16 pixelated shape
    always@(*) begin
        case(rom_addr)
        4'b0000: begin rom_data = 16'h0FF0; end 
        4'b0001: begin rom_data = 16'h0FF0; end 
        4'b0010: begin rom_data = 16'h0FF0; end 
        4'b0011: begin rom_data = 16'h0FF0; end 
        4'b0100: begin rom_data = 16'h0FF0; end 
        4'b0101: begin rom_data = 16'h0FF0; end 
        4'b0110: begin rom_data = 16'h0FF0; end 
        4'b0111: begin rom_data = 16'h0FF0; end 
        4'b1000: begin rom_data = 16'hFFFF; end 
        4'b1001: begin rom_data = 16'hFFFF; end 
        4'b1010: begin rom_data = 16'hFFFF; end 
        4'b1011: begin rom_data = 16'hFFFF; end 
        4'b1100: begin rom_data = 16'hFFFF; end 
        4'b1101: begin rom_data = 16'hFFFF; end 
        4'b1110: begin rom_data = 16'hFFFF; end 
        4'b1111: begin rom_data = 16'hFFFF; end
        default: begin rom_data = 16'h0000; end
        endcase
    end 
    //ship position always block
    always@(*) begin 
        h_ship_nxt=h_ship_reg;
        if (refresh_tick) begin 
            if (left && (ship_l >= ship_velo)) begin
                h_ship_nxt = h_ship_reg - ship_velo;
        end 
            else if (right && (ship_r <= 635 - ship_velo)) begin
                h_ship_nxt = h_ship_reg + ship_velo;
            end 
        end 
    end 
    
    assign ship_l = h_ship_reg;
    assign ship_r = h_ship_reg + SHIP_LENGTH-1;
    
    assign ship_on = ship_alive && ((hpos >= ship_l) && (hpos <= ship_r) && (vpos >= Y_SHIP_T) && (vpos <= Y_SHIP_B));
    assign rom_addr = vpos[3:0]- ship_t[3:0];
    assign rom_col = hpos[3:0] - ship_l[3:0];
    assign rom_bit = rom_data[rom_col]; 
    assign ship_color_on = ship_on & rom_bit;
    
endmodule
