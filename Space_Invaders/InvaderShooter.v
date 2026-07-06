`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 06/26/2026 05:29:20 PM
// Design Name: 
// Module Name: InvaderShooter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module InvaderShooter(
input clk,
input refresh_tick,
input reset,
output reg [3:0] pattern,
output a_shoot
    );
    
    reg [5:0] shooting_reg;
    
    always@(posedge clk or posedge reset) begin 
        if (reset) begin 
        shooting_reg<=0;
        pattern <= 4'b1001;
        end 
    else if (refresh_tick)begin 
            shooting_reg<=shooting_reg+1;
        end 
        else begin 
            pattern<={pattern[2:0], (pattern[2] ^ pattern[3])};
        end 
    end 
    
    
    assign a_shoot =  (shooting_reg >= 30 && shooting_reg <=60) ? 1 : 0;
    
endmodule
