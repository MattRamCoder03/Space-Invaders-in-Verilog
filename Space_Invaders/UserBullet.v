`timescale 1ns / 1ps

module UserBullet(
input clk, shoot, reset, ship_alive, refresh_tick, video_on,
input[9:1] alien_alive,
input [9:0] alien_t, hpos, vpos, ship_l, shield_layer,
input [29:0] alien_b, shield_pos,
input [89:0] alien_l, alien_r, 
output bullet_on,
output [9:1] collide,
output [3:1] shield_collision
    );
    
    parameter SHIP_LENGTH=32;
    parameter SHIP_TOP = 440;
    parameter SHIP_BOTTOM = SHIP_TOP + SHIP_LENGTH-1;
    
    //initial space ship 
    reg [1:0] shooting_state, next_shooting_state, prev_shooting_state; 
    
    //wire shot_on, collision;
    reg bullet_on_reg, bullet_on_prev, ship_alive_reg;
    parameter IDLE =2'b00, SETUP =2'b01, SHOOTING =2'b10, HIT =2'b11;
    
    wire bullet_on, bullet_detect, collide_1, collide_2, collide_3, collide_4;
    wire shield_col_1, shield_col_2, shield_col_3;
    wire [9:0] bullet_t, bullet_r, bullet_l, bullet_b, ship_t, bullet_v_next;
    reg[9:0] bullet_t_reg, bullet_r_reg, bullet_l_reg, bullet_b_reg, bullet_v_reg, bullet_x_reg;
    parameter BULLET_SIZE = 8;
    parameter BULLET_VELO = 2;
    
    assign bullet_detect = shoot;
    assign ship_t = SHIP_TOP;
    // collide is on when hit condition occurs 
    //assign collide = (bullet_t_reg <= alien_b) && (((bullet_r_reg >= alien_l) && (bullet_r_reg <= alien_r)) || ((bullet_l_reg <= alien_r) && (bullet_l_reg >= alien_l)));
    //assign collide = bullet_t <= alien_b;
    assign collide_1 = (bullet_r_reg >= alien_l[9:0]) && alien_alive[1] && ((bullet_r_reg <= alien_r[9:0]) || (bullet_l_reg <= alien_r[9:0]) && (bullet_l_reg >= alien_l[9:0]));
    assign collide_2 = (bullet_r_reg >= alien_l[19:10]) && alien_alive[2] &&((bullet_r_reg <= alien_r[19:10]) || (bullet_l_reg <= alien_r[19:10]) && (bullet_l_reg >= alien_l[19:10]));
    assign collide_3 = (bullet_r_reg >= alien_l[29:20]) && alien_alive[3] &&((bullet_r_reg <= alien_r[29:20]) || (bullet_l_reg <= alien_r[29:20]) && (bullet_l_reg >= alien_l[29:20]));
    
    assign collide_4 = (bullet_r_reg >= alien_l[39:30]) && alien_alive[4] && ((bullet_r_reg <= alien_r[39:30]) || (bullet_l_reg <= alien_r[39:30]) && (bullet_l_reg >= alien_l[39:30]));
    assign collide_5 = (bullet_r_reg >= alien_l[49:40]) && alien_alive[5] &&((bullet_r_reg <= alien_r[49:40]) || (bullet_l_reg <= alien_r[49:40]) && (bullet_l_reg >= alien_l[49:40]));
    assign collide_6 = (bullet_r_reg >= alien_l[59:50]) && alien_alive[6] &&((bullet_r_reg <= alien_r[59:50]) || (bullet_l_reg <= alien_r[59:50]) && (bullet_l_reg >= alien_l[59:50]));
    
    assign collide_7 = (bullet_r_reg >= alien_l[69:60]) && alien_alive[7] &&((bullet_r_reg <= alien_r[69:60]) || (bullet_l_reg <= alien_r[69:60]) && (bullet_l_reg >= alien_l[69:60]));
    assign collide_8 = (bullet_r_reg >= alien_l[79:70]) && alien_alive[8] &&((bullet_r_reg <= alien_r[79:70]) || (bullet_l_reg <= alien_r[79:70]) && (bullet_l_reg >= alien_l[79:70]));
    assign collide_9 = (bullet_r_reg >= alien_l[89:80]) && alien_alive[9] &&((bullet_r_reg <= alien_r[89:80]) || (bullet_l_reg <= alien_r[89:80]) && (bullet_l_reg >= alien_l[89:80]));
    
    assign collide_y = (bullet_t_reg <= 10);
    
    // assign shield_col_1 = (bullet_t_reg <= (shield_layer+10'd32)) && (((bullet_r_reg >= shield_pos[9:0] && bullet_r_reg <= (shield_pos[9:0]+10'd32))||((bullet_l_reg >= shield_pos[9:0] && bullet_l_reg <=(shield_pos[9:0]10'd32)));
    assign shield_col_1 = (bullet_t_reg <= shield_layer+10'd32) && ((bullet_r_reg >= shield_pos[9:0] && (bullet_r_reg <= shield_pos[9:0]+10'd32)) || (bullet_l_reg >= shield_pos[9:0] && (bullet_l_reg <= shield_pos[9:0]+10'd32)));
    assign shield_col_2 = (bullet_t_reg <= shield_layer+10'd32) && ((bullet_r_reg >= shield_pos[19:10] && (bullet_r_reg <= shield_pos[19:10]+10'd32)) || (bullet_l_reg >= shield_pos[19:10] && (bullet_l_reg <= shield_pos[19:10]+10'd32)));
    assign shield_col_3 = (bullet_t_reg <= shield_layer+10'd32) && ((bullet_r_reg >= shield_pos[29:20] && (bullet_r_reg <= shield_pos[29:20]+10'd32)) || (bullet_l_reg >= shield_pos[29:20] && (bullet_l_reg <= shield_pos[29:20]+10'd32)));
    
    assign shield_collision = {shield_col_3,shield_col_2,shield_col_1};
    
    assign collide[1] = (bullet_t_reg <= alien_b[9:0]) && (collide_1);
    assign collide[2] = (bullet_t_reg <= alien_b[9:0]) && (collide_2);
    assign collide[3] = (bullet_t_reg <= alien_b[9:0]) && (collide_3);
    
    assign collide[4] = (bullet_t_reg <= alien_b[19:10]) && (collide_4);
    assign collide[5] = (bullet_t_reg <= alien_b[19:10]) && (collide_5);
    assign collide[6] = (bullet_t_reg <= alien_b[19:10]) && (collide_6);
    
    assign collide[7] = (bullet_t_reg <= alien_b[29:20]) && (collide_7);
    assign collide[8] = (bullet_t_reg <= alien_b[29:20]) && (collide_8);
    assign collide[9] = (bullet_t_reg <= alien_b[29:20]) && (collide_9);
    
    assign collide_alien = collide >= 1;
    
    always@(posedge clk) begin 
        if (reset) begin 
            shooting_state<=IDLE;
            prev_shooting_state<=shooting_state;
            bullet_on_prev<=1'b0;
            bullet_on_reg<=1'b0;
        end 
        else  if (refresh_tick) begin
            bullet_on_prev<=bullet_on_reg;
            bullet_on_reg<=bullet_detect;
            shooting_state<=next_shooting_state;
            prev_shooting_state<=shooting_state;
            bullet_t_reg<=bullet_t;
            bullet_r_reg<=bullet_r;
            bullet_b_reg<=bullet_b;
            bullet_l_reg<=bullet_l;
            ship_alive_reg<=ship_alive;
            end 
        end 
    
    //combinational block to determine next shooter state
    always@(*) begin
    case(shooting_state) 
    IDLE: begin 
    if (bullet_on_reg && ~bullet_on_prev && ship_alive_reg) begin
            next_shooting_state = SETUP;
        end 
        else begin
            next_shooting_state = IDLE;
        end 
    end 
    SETUP: begin
        next_shooting_state = SHOOTING;
    end 
    SHOOTING: begin
    if (collide_alien || collide_y || (shield_collision >= 1)) begin 
        next_shooting_state = HIT;
    end 
    else begin 
        next_shooting_state = SHOOTING;
    end 
    end 
    HIT: begin 
        next_shooting_state = IDLE;
    end 
    endcase
    end 
    
    always@(posedge clk) begin 
        if (reset) begin
            bullet_v_reg<=0;
            bullet_x_reg<=0;
            end 
        else begin
            if (refresh_tick) begin
                case(shooting_state) 
                    IDLE: begin 
                        bullet_v_reg<=0;
                        bullet_x_reg<=0;
                    end
                    SETUP: begin
                        bullet_v_reg<=ship_t-1;
                        bullet_x_reg<=ship_l+4;
                    end 
                    SHOOTING: begin  
                        bullet_v_reg<=bullet_v_next;
                        bullet_x_reg<=bullet_x_reg;
                    end 
                    HIT: begin
                        bullet_v_reg<=0; 
                        bullet_x_reg<=0;
                    end 
            endcase
            end 
        end 
    end 
  
    assign bullet_b = (shooting_state==SHOOTING||shooting_state==SETUP)? (bullet_v_reg) : (0);
    assign bullet_l = (shooting_state==SHOOTING||shooting_state==SETUP)? (bullet_x_reg) : (0);
    assign bullet_t = (shooting_state==SHOOTING||shooting_state==SETUP)? (bullet_v_reg-BULLET_SIZE+1) : (0);
    assign bullet_r = (shooting_state==SHOOTING||shooting_state==SETUP)? (bullet_x_reg+BULLET_SIZE-1) : (0);
   
    assign bullet_on = (shooting_state==SHOOTING)? ((hpos >= bullet_l) && (hpos <= bullet_r) && (vpos >= bullet_t) && (vpos <= bullet_b)) :0;
    
    assign bullet_v_next = (shooting_state==SHOOTING) ? (bullet_v_reg-BULLET_VELO) : (9'b000000000);
    
endmodule
