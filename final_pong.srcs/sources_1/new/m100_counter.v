`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 04:32:20 PM
// Design Name: 
// Module Name: m100_counter
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


module m100_counter(
    input clk,
    input reset,
    input d_inc, d_clr, d_inc_2,
    output [3:0] dig0, dig1, dig0_2, dig1_2,
    output [11:0] total
    );
    
    // signal declaration
    reg [3:0] r_dig0  , r_dig1  , dig0_next  , dig1_next;
    reg [3:0] r_dig0_2, r_dig1_2, dig0_next_2, dig1_next_2;
    reg [11:0] r_total, total_next;
    reg [11:0] counter, counter_next;
    reg [11:0] r,r_next,r_2,r_next_2;
    
    // register control
    always @(posedge clk or posedge reset)
        if(reset) begin
            r_dig1 <= 0;
            r_dig0 <= 0;
            r_dig1_2 <= 0;
            r_dig0_2 <= 0;
            r_total <= 0;
            r<=0;
            r_2<=0;
            counter <= 0;
        end
        
        else begin
            r_dig1   <= dig1_next;
            r_dig0   <= dig0_next;
            r_dig1_2 <= dig1_next_2;
            r_dig0_2 <= dig0_next_2;
            r_total  <= total_next;
            counter <= counter_next;
            r<=r_next;
            r_2<=r_next_2;
        end
    
    // next state logic
    always @(d_inc or d_clr or d_inc_2) begin
        dig0_next   = r_dig0;
        dig1_next   = r_dig1;
        dig0_next_2 = r_dig0_2;
        dig1_next_2 = r_dig1_2;
        total_next  = r_total;
        counter_next = counter;
        r_next=r;
        r_next_2=r_2;
        
        if(d_clr) begin
            dig0_next   = 0;
            dig1_next   = 0;
            dig0_next_2 = 0;
            dig1_next_2 = 0;
            total_next  = 0;
            counter_next= 0;
            r_next=0;
            r_next_2=0;
        end 
        else if(d_inc) begin
            total_next = r_total + 1;
            r_next=r+1;
            if(r_dig0 == 9) begin
                dig0_next = 0;
                
                if(r_dig1 == 9)
                    dig1_next = 0;
                else
                    dig1_next = r_dig1 + 1;
            end
        
            else    // dig0 != 9
                dig0_next = r_dig0 + 1;
        end
        else if(d_inc_2) begin
            counter_next = counter_next + 1;
            if(counter == 12'h27D + 12'h021) begin
                r_next_2=r_2+1;
                total_next = r_total + 1;
                counter_next = 0;
                if(r_dig0_2 == 9) begin
                    dig0_next_2 = 0;
                    
                    if(r_dig1_2 == 9)
                        dig1_next_2 = 0;
                    else
                        dig1_next_2 = r_dig1_2 + 1;
                end
            
                else    // dig0 != 9
                    dig0_next_2 = r_dig0_2 + 1;
            end             
        end         
    end
    
    // output
    assign dig0   = r_dig0;
    assign dig1   = r_dig1;
    assign dig0_2 = r_dig0_2;
    assign dig1_2 = r_dig1_2;
//    assign dig0   = (r/3)%10;
//    assign dig1   = (r/30)%10;
//    assign dig0_2 = (r_2/3)%10;
//    assign dig1_2 = (r_2/30)%10;
    assign total  = r_total;
    
endmodule
