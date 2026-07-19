`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2026 10:27:42 AM
// Design Name: 
// Module Name: tb_I2C
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


module tb_I2C(
      
    );
    
    
   reg clk; 
   reg rst;
    
    top_i2c dut( .clk(clk),.rst(rst) );
    
       always 
       #5 clk = ~clk;
       
       
       initial 
         begin 
           clk =0;
           rst = 1;
            
           #20
            rst = 0;
           
           
           
           #15000;
           
             $finish;
             
           end 
                                
    
    
    
endmodule
