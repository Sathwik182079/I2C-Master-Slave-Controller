`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2026 05:50:01 PM
// Design Name: 
// Module Name: top_i2c
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// s
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module top_i2c(
      input clk,
      input rst
    );
    
    
    
   wire scl;
   tri1 sda;
   
   
   
   i2c_master master( .clk(clk),.rst(rst),.sda(sda),.scl(scl));
   i2c_slave  slave ( .scl(scl),.rst(rst),.sda(sda));
   
   
        
endmodule
