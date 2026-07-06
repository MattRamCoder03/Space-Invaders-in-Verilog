`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 

module Shield(
input clk, reset,
input [9:0] hpos, vpos, shield_y_coord, shield_x_coord,
//bit at 0 is from user, bit at 2 is from shield
input [1:0] bullet_collide,
input refresh_tick,
output shield_on
    );
    
    //shield layer is top coordinate, bottom is derived by adding size since y grows downward in coordinate system
    
    wire [4:0] rom_addr,rom_col;
    wire rom_bit;
    reg[31:0] rom_data;
    reg[3:0] shield_up;
    reg[1:0] hit_reg, hit_reg_prev;
    wire [9:0] shield_r, shield_b, shield_t, shield_l;
    parameter SHIELD_SIZE=32;
    parameter max_life = 15;
    
    always@(posedge clk) begin 
        if (refresh_tick) begin 
            hit_reg <= bullet_collide;
            hit_reg_prev<=hit_reg;
        end 
    end 
    
    always@(posedge clk) begin
    if (reset) begin 
        shield_up<=4'b1111;
    end  
        else if (refresh_tick) begin 
            if ((hit_reg>=1) && ~hit_reg_prev) begin 
                shield_up<=shield_up-hit_reg;
            end 
            else begin 
                shield_up<=shield_up;
            end 
        end 
    end 
    
    
    always@(*) begin 
    case(rom_addr)
    5'b00000: begin rom_data = 32'h00FFFF00; end 
    5'b00001: begin rom_data = 32'h00FFFF00; end
    5'b00010: begin rom_data = 32'h00FFFF00; end
    5'b00011: begin rom_data = 32'h00FFFF00; end
    default: rom_data = 32'hFFFFFFFF;
    endcase
    end
    
    //assign life_wire = bullet_collide;
    
    assign rom_addr = vpos[4:0] - shield_y_coord[4:0];
    assign rom_col = hpos[4:0] - shield_x_coord[4:0]; 
    assign rom_bit = rom_data[rom_col];
    
    assign shield_l = shield_x_coord;
    assign shield_t = shield_y_coord;
    assign shield_r = shield_x_coord + SHIELD_SIZE-1;
    assign shield_b = shield_y_coord + SHIELD_SIZE-1;
    
    //add shield_up check later for shield life
    assign shield_on =((hpos >= shield_l) && (hpos <= shield_r) && (vpos >= shield_t) && (vpos <= shield_b) && rom_bit);
    
    
    
endmodule
