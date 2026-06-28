`timescale 1ns / 1ps

module AlienBullet(
input clk, a_shoot, reset, refresh_tick, video_on,
input [9:1]alien_alive,
input [9:0] ship_t, ship_b, ship_l, ship_r, hpos, vpos, shields_t,
input [89:0] alien_l, 
input [29:0] alien_b, shields_l,
input [3:0] shooting_pattern,
output alien_bullet_on, collide
    );
    //need parameters for vehicle (alien in thi scase)
    
    parameter ALIEN_SIZE =32;
    parameter Y_ALIEN_T = 40;
    parameter Y_ALIEN_B = 40 + ALIEN_SIZE-1;
    
    parameter SHIP_LENGTH=32;
    parameter SHIP_TOP = 440;
    parameter SHIP_BOTTOM = SHIP_TOP + SHIP_LENGTH-1;
    parameter IDLE =2'b00, SETUP =2'b01, SHOOTING =2'b10, HIT =2'b11;
    
    wire collide, shield_collide_1, shield_collide_2, shield_collide_3, bullet_on, bullet_detect, out_of_bounds;
    wire[29:0] shields_r;
    //initial space ship 
    reg [1:0] shooting_state, next_shooting_state, prev_shooting_state; 
    reg[3:0] shooting_pattern_reg;
    reg bullet_on_reg, bullet_on_prev;
    
    wire [9:0] bullet_t, bullet_r, bullet_l, bullet_b, bullet_v_next;
    reg[9:0] bullet_t_reg, bullet_r_reg, bullet_l_reg, bullet_b_reg, bullet_v_reg, bullet_x_reg, alien_l_sel, alien_b_sel;
    parameter BULLET_SIZE = 8;
    parameter BULLET_VELO = 2;
    
    assign shields_r[29:20] = shields_l[29:20] +10'd32;
    assign shields_r[19:10] = shields_l[19:10] +10'd32;
    assign shields_r[9:0] = shields_l[9:0]+10'd32;
    //wire shot_on, collision;
   
    assign shield_collide_1 = (bullet_b_reg >= shields_t) && ((bullet_r_reg > shields_l[9:0] && bullet_r_reg < shields_r[9:0]) || (bullet_l_reg > shields_l[9:0] && bullet_r_reg < shields_r[9:0]));
    assign shield_collide_2 = (bullet_b_reg >= shields_t) && ((bullet_r_reg > shields_l[19:10] && bullet_r_reg < shields_r[19:10]) || (bullet_l_reg > shields_l[19:10] && bullet_r_reg < shields_r[19:10]));
    assign shield_collide_3 =  (bullet_b_reg >= shields_t) && ((bullet_r_reg > shields_l[29:20] && bullet_r_reg < shields_r[29:20]) || (bullet_l_reg > shields_l[29:20] && bullet_r_reg < shields_r[29:20]));
    
    assign bullet_detect = a_shoot;
    assign out_of_bounds = (bullet_b_reg >=480) ||(shield_collide_1||shield_collide_2||shield_collide_3) ;
    //ship top
    assign collide =(((bullet_b_reg) >= ship_t) && ((bullet_r_reg>=ship_l && bullet_r_reg<=ship_r) || (bullet_l_reg>=ship_l && bullet_l_reg <=ship_r)));
    always@(posedge clk or posedge reset) begin 
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
            shooting_pattern_reg<=shooting_pattern;
            end 
        end 
        
    
    always@(*) begin 
    case(shooting_pattern_reg)
    4'b0001: begin 
    alien_l_sel = alien_l[9:0];
    alien_b_sel = alien_b[9:0];
    end
    4'b0010: begin
    alien_l_sel = alien_l[19:10];
    alien_b_sel = alien_b[9:0];
    end
    4'b0011: begin 
    alien_l_sel = alien_l[29:20];
    alien_b_sel = alien_b[9:0];
    end
    4'b0100: begin 
    alien_l_sel = alien_l[39:30];
    alien_b_sel = alien_b[19:10];
    end
    4'b0101: begin 
    alien_l_sel = alien_l[49:40];
    alien_b_sel = alien_b[19:10];
    end
    4'b0110: begin 
    alien_l_sel = alien_l[59:50];
    alien_b_sel = alien_b[19:10];
    end
    4'b0111: begin 
    alien_l_sel = alien_l[69:60];
    alien_b_sel = alien_b[29:20];
    end
    4'b1000: begin 
    alien_l_sel = alien_l[79:70];
    alien_b_sel = alien_b[29:20];
    end
    4'b1001: begin 
    alien_l_sel = alien_l[89:80];
    alien_b_sel = alien_b[29:20];
    end
    default: begin  
    alien_l_sel = alien_l[19:10];
    alien_b_sel = alien_b[19:10]
    ;end
    endcase
    end 
    //combinational block to determine next shooter state
    always@(*) begin
    case(shooting_state) 
    IDLE: begin 
    if (bullet_on_reg && ~bullet_on_prev && alien_alive[shooting_pattern_reg] && shooting_pattern_reg >= 4'd1 &&
    shooting_pattern_reg <= 4'd9) begin
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
    if (collide||out_of_bounds) begin 
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
    
    always@(posedge clk or posedge reset) begin 
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
                        bullet_v_reg<=alien_b_sel-1;
                        bullet_x_reg<=alien_l_sel+7;
                        //shooting_pattern_reg<=shooting_pattern_reg+1;
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
   
    assign alien_bullet_on = (shooting_state==SHOOTING)? ((hpos >= bullet_l) && (hpos <= bullet_r) && (vpos >= bullet_t) && (vpos <= bullet_b)) :0;
    
    assign bullet_v_next = (shooting_state==SHOOTING) ? (bullet_v_reg+BULLET_VELO) : (9'b000000000);
    
endmodule
