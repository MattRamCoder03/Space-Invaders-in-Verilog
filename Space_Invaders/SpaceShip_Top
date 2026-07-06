`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module SpaceShip_Top(
input clk_100mhz,
input reset,
input right, 
input left,
input shoot,
input a_shoot,
output hsync,
output vsync,
output [11:0] rgb
    );
    
    wire w_video_on, w_tick;
    wire [9:0] w_hpos, w_vpos;
    wire w_right, w_left, w_shoot;
    wire [11:0] w_rgb;
    reg[11:0] rgb_reg;
    
    debouncer move_right(.clk(clk_100mhz), .btn_in(right), .btn_out(w_right));
    debouncer move_left(.clk(clk_100mhz), .btn_in(left), .btn_out(w_left));
    debouncer shoot_btn(.clk(clk_100mhz), .btn_in(shoot), .btn_out(w_shoot));
    // debouncer a_shoot_btn(.clk(clk_100mhz), .btn_in(a_shoot), .btn_out(w_a_shoot));
   
    vga_controller vga(.clk_100mhz(clk_100mhz), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(w_video_on), .hpos(w_hpos), .vpos(w_vpos), .p_tick(w_tick));
    
    
    ship_gen spaceship(.clk(clk_100mhz), .reset(reset),.a_shoot(a_shoot), .shoot(w_shoot),.right(w_right), .left(w_left), .video_on(w_video_on), .hpos(w_hpos), .vpos(w_vpos), .rgb(w_rgb));
    
    always@(posedge clk_100mhz) begin
    if (w_tick)
        rgb_reg<=w_rgb;
    end 
    
    assign rgb= rgb_reg;
    
endmodule
