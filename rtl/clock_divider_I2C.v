`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 07:51:08 PM
// Design Name: 
// Module Name: clock_divider_I2C
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


module clock_divider_I2C(input clock,input reset, output reg scl);
       
          reg [9:0] count; 
          always @(posedge clock or posedge reset) 
          
          begin
          
          if(reset)
          begin
          
          count <= 10'd0;
          scl  <= 1'b0;
          
          end 
          
          else if(count == 10'd4 )
          begin
          
          count <= 10'd0;
          scl<=~scl;
          
          end
          
          else
          
          begin
          
          count <= count +1'b1;
          
          end 
          end 
          
          
          


 
endmodule
