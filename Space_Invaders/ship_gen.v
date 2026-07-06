`timescale 1ns / 1ps

module ship_gen(
input a_shoot,
input clk,
input reset,
input right,
input left,
input shoot,
input video_on,
input [9:0] hpos, vpos,
output reg [11:0] rgb
    );
    
   wire w_bullet_on;
   

   //wires for next_pos, boundaries, color, and timing status
   parameter ship_color = 12'h0F0;
   
   wire ship_color_on;
   //register for current velo, next velo, and current position
   wire [9:0] ship_l, ship_r, ship_t, ship_b;
   parameter Y_SHIP_T = 440;
   parameter Y_SHIP_B = Y_SHIP_T + SHIP_LENGTH-1;
   parameter SHIP_LENGTH = 16;
   
   parameter ALIEN_CENTER_1 = 320;
   parameter ALIEN_CENTER_2 = 480;
   parameter ALIEN_CENTER_3 = 160;
   
   parameter ALIEN_LAYER_1 = 40;
   parameter ALIEN_LAYER_2 = 120;
   parameter ALIEN_LAYER_3 = 200;
   
   parameter SHIELD_LAYER = 385;
   parameter SHIELD_POS_3 = 305;
   parameter SHIELD_POS_2 = 475;
   parameter SHIELD_POS_1 = 145;
   
   wire [9:0] center_1 = ALIEN_CENTER_1;
   wire [9:0] center_2 = ALIEN_CENTER_2;
   wire [9:0] center_3 = ALIEN_CENTER_3;
   
   wire [9:0] layer_1 = ALIEN_LAYER_1;
   wire [9:0] layer_2 = ALIEN_LAYER_2;
   wire [9:0] layer_3 = ALIEN_LAYER_3;
   
   wire [9:0] shield_layer = SHIELD_LAYER;
   
   wire [9:0] shield_pos_1 = SHIELD_POS_1;
   wire [9:0] shield_pos_2 = SHIELD_POS_2;
   wire [9:0] shield_pos_3 = SHIELD_POS_3;
   
   wire [29:0] w_alien_b;
   
   wire [29:0] w_alien_r1,  w_alien_l1;
   wire [29:0] w_alien_r2,  w_alien_l2;
   wire [29:0] w_alien_r3,  w_alien_l3;
   
   wire [89:0] w_alien_r, w_alien_l;
   
   assign w_alien_r = {w_alien_r3,w_alien_r2,w_alien_r1};
   assign w_alien_l ={w_alien_l3,w_alien_l2,w_alien_l1};
   
   wire[8:0] alien_on_vec;
   
   wire [11:0] alien_color = 12'hF00;
   
   wire w_refresh_tick;
   wire w_shoot;
   wire[3:1] w_shield_on;
   wire[9:1] w_collide;
   wire[6:1] shield_bullet_collide;
   wire a_bullet_on, w_ship_alive;
   wire[9:1] w_alien_alive;

   wire [3:0] w_shooting_pattern;
   
   UserShip user(.clk(clk), .reset(reset), .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(a_collide), .left(left), .right(right), .shoot(shoot), .ship_t(ship_t), .ship_b(ship_b), .ship_r(ship_r), .ship_l(ship_l), .ship_color_on(ship_color_on), .ship_alive(w_ship_alive));
   
   AlienShip alien1(.clk(clk), .reset(reset),  .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[1]), .alien_center(center_1),.alien_layer(layer_1), .alien_on_out(alien_on_vec[0]), .alien_l_reg(w_alien_l1[9:0]), .alien_r_reg(w_alien_r1[9:0]), .alien_b_reg(w_alien_b[9:0]), .alien_t_reg(), .alien_alive(w_alien_alive[1]));
   AlienShip alien2(.clk(clk), .reset(reset),.hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[2]), .alien_center(center_2),.alien_layer(layer_1),  .alien_on_out(alien_on_vec[1]), .alien_l_reg(w_alien_l1[19:10]), .alien_r_reg(w_alien_r1[19:10]), .alien_b_reg(), .alien_t_reg(), .alien_alive(w_alien_alive[2]));
   AlienShip alien3(.clk(clk), .reset(reset),.hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[3]), .alien_center(center_3),.alien_layer(layer_1),  .alien_on_out(alien_on_vec[2]), .alien_l_reg(w_alien_l1[29:20]), .alien_r_reg(w_alien_r1[29:20]), .alien_b_reg(), .alien_t_reg(), .alien_alive(w_alien_alive[3]));
   
   AlienShip alien4(.clk(clk), .reset(reset),  .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[4]), .alien_center(center_1),.alien_layer(layer_2), .alien_on_out(alien_on_vec[3]), .alien_l_reg(w_alien_l2[9:0]), .alien_r_reg(w_alien_r2[9:0]), .alien_b_reg(w_alien_b[19:10]), .alien_t_reg(), .alien_alive(w_alien_alive[4]));
   AlienShip alien5(.clk(clk), .reset(reset), .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[5]), .alien_center(center_2),.alien_layer(layer_2),  .alien_on_out(alien_on_vec[4]), .alien_l_reg(w_alien_l2[19:10]), .alien_r_reg(w_alien_r2[19:10]), .alien_b_reg(), .alien_t_reg(), .alien_alive(w_alien_alive[5]));
   AlienShip alien6(.clk(clk), .reset(reset),.hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[6]), .alien_center(center_3),.alien_layer(layer_2),  .alien_on_out(alien_on_vec[5]), .alien_l_reg(w_alien_l2[29:20]), .alien_r_reg(w_alien_r2[29:20]), .alien_b_reg(), .alien_t_reg(), .alien_alive(w_alien_alive[6]));
   
   AlienShip alien7(.clk(clk), .reset(reset), .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[7]), .alien_center(center_1),.alien_layer(layer_3), .alien_on_out(alien_on_vec[6]), .alien_l_reg(w_alien_l3[9:0]), .alien_r_reg(w_alien_r3[9:0]), .alien_b_reg(w_alien_b[29:20]), .alien_t_reg(),  .alien_alive(w_alien_alive[7]));
   AlienShip alien8(.clk(clk), .reset(reset), .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[8]), .alien_center(center_2),.alien_layer(layer_3),  .alien_on_out(alien_on_vec[7]), .alien_l_reg(w_alien_l3[19:10]), .alien_r_reg(w_alien_r3[19:10]), .alien_b_reg(), .alien_t_reg(),  .alien_alive(w_alien_alive[8]));
   AlienShip alien9(.clk(clk), .reset(reset), .hpos(hpos), .vpos(vpos), .refresh_tick(w_refresh_tick), .collide(w_collide[9]), .alien_center(center_3),.alien_layer(layer_3),  .alien_on_out(alien_on_vec[8]), .alien_l_reg(w_alien_l3[29:20]), .alien_r_reg(w_alien_r3[29:20]), .alien_b_reg(), .alien_t_reg(),  .alien_alive(w_alien_alive[9]));
   
   UserBullet userbullet1(.ship_alive(w_ship_alive), .clk(clk), .reset(reset), .shoot(shoot), .shield_pos({shield_pos_3,shield_pos_2,shield_pos_1}), .shield_layer(shield_layer), .refresh_tick(w_refresh_tick), .video_on(video_on), .shield_collision(shield_bullet_collide[3:1]), .hpos(hpos), .vpos(vpos), .ship_l(ship_l), .alien_r(w_alien_r), .alien_l(w_alien_l), .alien_b(w_alien_b), .alien_t(w_alien_t), .bullet_on(w_bullet_on), .collide(w_collide), .alien_alive(w_alien_alive));
   
   InvaderShooter shiftreg(.clk(clk), .refresh_tick(w_refresh_tick), .reset(reset), .pattern(w_shooting_pattern), .a_shoot(w_shoot));
   
   AlienBullet alienbullet1(.clk(clk), .reset(reset), .refresh_tick(w_refresh_tick), .a_shoot(w_shoot), .video_on(video_on), .hpos(hpos), .vpos(vpos), .collide(a_collide), .shields_t(shield_layer), .shields_l({shield_pos_3,shield_pos_2,shield_pos_1}),.shield_collision(shield_bullet_collide[6:4]), .alien_bullet_on(a_bullet_on), .alien_l(w_alien_l) , .alien_b(w_alien_b), .shooting_pattern(w_shooting_pattern), .ship_l(ship_l), .ship_t(ship_t), .ship_b(ship_b), .ship_r(ship_r), .alien_alive(w_alien_alive));
   
   Shield shield1(.clk(clk),  .refresh_tick(w_refresh_tick), .reset(reset), .hpos(hpos), .vpos(vpos), .shield_x_coord(shield_pos_1), .shield_y_coord(shield_layer), .bullet_collide({shield_bullet_collide[1],shield_bullet_collide[4]}), .shield_on(w_shield_on[1]));
   Shield shield2(.clk(clk),  .refresh_tick(w_refresh_tick), .reset(reset), .hpos(hpos), .vpos(vpos), .shield_x_coord(shield_pos_2), .shield_y_coord(shield_layer), .bullet_collide({shield_bullet_collide[2],shield_bullet_collide[5]}), .shield_on(w_shield_on[2]));
   Shield shield3(.clk(clk), .refresh_tick(w_refresh_tick), .reset(reset), .hpos(hpos), .vpos(vpos), .shield_x_coord(shield_pos_3), .shield_y_coord(shield_layer), .bullet_collide({shield_bullet_collide[3],shield_bullet_collide[6]}), .shield_on(w_shield_on[3])); 
    
    //rgb always block
    always@(*) begin 
    if (~video_on) begin 
            rgb=12'h000;
        end 
    else begin 
        if (ship_color_on) begin 
            rgb=ship_color;
        end 
        else if (alien_on_vec >= 1) begin 
           rgb=alien_color;
         end
         else if (w_bullet_on) begin
            rgb=12'hAAA;
         end 
         else if (a_bullet_on) begin
         rgb=12'hAAA;
         end 
         else if (w_shield_on >=1) begin 
         rgb = 12'h0F0;
         end 
        else begin 
            rgb=12'h111;
        end 
    end 
    end 
    
    assign w_refresh_tick = ((vpos ==481) && hpos==0) ? 1:0;   
    
    //user ship continuous assignments for top,bottom,left, and right positions
    //and then assignments for rgb
    assign ship_t = Y_SHIP_T;
    assign ship_b = Y_SHIP_B;
    
endmodule
