`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 04:32:20 PM
// Design Name: 
// Module Name: pong_top
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


module pong_top(
    input clk,              // 100MHz
    input reset,            // btnR
    input [1:0] btn,        // btnD, btnU
    output hsync,           // to VGA Connector
    output vsync,           // to VGA Connector
    output [11:0] rgb,       // to DAC, to VGA Connector
    output wire RsTx, //uart
    input wire RsRx, //uart
    output [6:0] seg,
    output dp,
    output [3:0] an
    );
    
    // state declarations for 4 states
    parameter newgame = 2'b00;
    parameter play    = 2'b01;
    parameter newball = 2'b10;
    parameter over    = 2'b11;
           
        
    // signal declaration
    reg [1:0] state_reg, state_next;
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick, graph_on, hit, miss;
    wire [4:0] text_on;
    wire [11:0] graph_rgb, text_rgb;
    reg [11:0] rgb_reg, rgb_next;
    wire [3:0] dig0, dig1, dig0_2, dig1_2;
    reg gra_still, d_inc, d_clr, timer_start;
    wire timer_tick, timer_up;
    reg [7:0] ball_reg, ball_next;
    wire [7:0] data_out;
    wire received;
    wire [1:0] press;
    wire [1:0] press_2;
    wire hit_2,miss_2;
    reg last_rec;
    reg d_inc_2;
    wire [11:0] total;
    reg [7:0] ball_reg_2, ball_next_2;
    wire [9:0] pos;
    wire [3:0] sc;
    
    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    wire [3:0] num3,num2,num1,num0;
    assign num3 = pos[9:8];
    assign num2 = pos[7:4]; //1
    assign num1 = pos[3:0]; //2
    assign num0 = 0; //3

    
    wire targetClk;
    wire [18:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<18;c=c+1) begin
        clockDiv fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    clockDiv fdivTarget(targetClk,tclk[18]);
    
    
    // Module Instantiations
    uart uart(clk,RsRx,RsTx,data_out,received,press,press_2);
    quad7Seg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,targetClk);
    
    vga_controller vga_unit(
        .clk_100MHz(clk),
        .reset(reset),
        .video_on(w_vid_on),
        .hsync(hsync),
        .vsync(vsync),
        .p_tick(w_p_tick),
        .x(w_x),
        .y(w_y));
    
    pong_text text_unit(
        .clk(clk),
        .x(w_x),
        .y(w_y),
        .dig0(dig0),
        .dig1(dig1),
        .dig0_2(dig0_2),
        .dig1_2(dig1_2),
        .ball(ball_reg),
        .ball_2(ball_reg_2),
        .text_on(text_on),
        .text_rgb(text_rgb));
        
    pong_graph graph_unit(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .gra_still(gra_still),
        .video_on(w_vid_on),
        .x(w_x),
        .y(w_y),
        .graph_on(graph_on),
        .hit(hit),
        .miss(miss),
        .hit_2(hit_2),
        .miss_2(miss_2),
        .graph_rgb(graph_rgb),
        .pos(pos),
        .sc(sc),
        .char(data_out),
        .received(received),
        .press(press),
        .press_2(press_2),
        .total(total));
    
    // 60 Hz tick when screen is refreshed
    assign timer_tick = (w_x == 0) && (w_y == 0);
    timer timer_unit(
        .clk(clk),
        .reset(reset),
        .timer_tick(timer_tick),
        .timer_start(timer_start),
        .timer_up(timer_up));
    
    m100_counter counter_unit(
        .clk(clk),
        .reset(reset),
        .d_inc(d_inc),
        .d_clr(d_clr),
        .d_inc_2(d_inc_2),
        .dig0(dig0),
        .dig1(dig1),
        .dig0_2(dig0_2),
        .dig1_2(dig1_2),
        .total(total)
        );
       
    
    // FSMD state and registers
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state_reg <= newgame;
            ball_reg <= 0;
            ball_reg_2 <= 0;
            rgb_reg <= 0;
//            sc <= 0;
        end
    
        else begin
            state_reg <= state_next;
            ball_reg <= ball_next;
            ball_reg_2 <= ball_next_2;
            if(w_p_tick)
                rgb_reg <= rgb_next;
            last_rec <= received;
//            sc <= sc_next;
        end
    end
    
    // FSMD next state logic
    always @* begin
        gra_still = 1'b1;
        timer_start = 1'b0;
        d_inc = 1'b0;
        d_inc_2 = 1'b0;
        d_clr = 1'b0;
        state_next = state_reg;
        ball_next = ball_reg;
        ball_next_2 = ball_reg_2;
//        sc_next = sc;
        
        case(state_reg)
            newgame: begin
                ball_next =   8'b00000101;          // three balls
                ball_next_2 = 8'b00000101;          // three balls
                d_clr = 1'b1;               // clear score
                
                if((~last_rec & received)&&(data_out <= 8'h7A && data_out >= 8'h41)) begin      // button pressed
                    state_next = play;
//                    ball_next_2 = ball_reg_2 - 1;    
                end
            end
            
            play: begin
                gra_still = 1'b0;   // animated screen
                
                if(hit) begin
                    d_inc = 1'b1;   // increment score
//                    sc_next = sc + 1;
                end
                else if(hit_2) begin
                    d_inc_2 = 1'b1;   // increment score
//                    sc_next = sc + 1;
                end
                else if(miss_2) begin
                    if(ball_reg_2 == 1)
                        state_next = over;
                    
                    else
                        state_next = newball;
                    
                    timer_start = 1'b1;     // 2 sec timer
                    ball_next_2 = ball_reg_2 - 1;
                end
                else if(miss) begin
                    if(ball_reg == 1)
                        state_next = over;
                    
                    else
                        state_next = newball;
                    
                    timer_start = 1'b1;     // 2 sec timer
                    ball_next = ball_reg - 1;
                end
                
            end
            
            newball: // wait for 2 sec and until button pressed
            if(timer_up && ((~last_rec & received)&&(data_out <= 8'h7A && data_out >= 8'h41)))
                state_next = play;
                
            over:   // wait 2 sec to display game over
                if(timer_up)
                    state_next = newgame;
        endcase          
    end
    
    // rgb multiplexing
    always @*
        if(~w_vid_on)
            rgb_next = 12'h000; // blank
        
        else
//            if(text_on[3] || ((state_reg == newgame) && text_on[1]) || ((state_reg == over) && text_on[0]))
            if(text_on[4] || text_on[3] || ((state_reg == over) && text_on[0]))
                rgb_next = text_rgb;    // colors in pong_text
            
            else if(graph_on)
                rgb_next = graph_rgb;   // colors in graph_text
                
//            else if(text_on[2])
//                rgb_next = text_rgb;    // colors in pong_text
                
            else
                rgb_next = 12'hFFD;     // aqua background
    
    // output
    assign rgb = rgb_reg;
    
endmodule
