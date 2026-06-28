`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 

module Shield(
input clk, reset,
input [9:0] hpos, vpos, shield_y_coord, shield_x_coord,
input refresh_tick,
output shield_on
    );
    
    wire [4:0] rom_addr,rom_col;
    wire rom_bit;
    reg[31:0] rom_data;
    reg[3:0] life;
    wire [9:0] shield_r, shield_b, shield_t, shield_l;
    parameter SHIELD_SIZE=32;
    
    always@(*) begin 
    case(rom_addr)
    5'b00000: begin rom_data = 32'h00FFFF00; end 
    5'b00001: begin rom_data = 32'h00FFFF00; end
    5'b00010: begin rom_data = 32'h00FFFF00; end
    5'b00011: begin rom_data = 32'h00FFFF00; end
    default: rom_data = 32'hFFFFFFFF;
    endcase
    end
    
    assign rom_addr = vpos[4:0] - shield_y_coord[4:0];
    assign rom_col = hpos[4:0] - shield_x_coord[4:0]; 
    assign rom_bit = rom_data[rom_col];
    
    assign shield_l = shield_x_coord;
    assign shield_t = shield_y_coord;
    assign shield_r = shield_x_coord + SHIELD_SIZE-1;
    assign shield_b = shield_y_coord + SHIELD_SIZE-1;
    
    
    assign shield_on = (hpos >= shield_l) && (hpos <= shield_r) && (vpos >= shield_t) && (vpos <= shield_b) && rom_bit;
    
    
    
endmodule
