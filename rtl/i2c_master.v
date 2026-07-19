`timescale 1ns / 1ps

module i2c_master(
        input clk,input rst,inout  sda,output  scl
    );
    
    
     parameter idle =  5'b0000;
     parameter start =  5'b0001;
     parameter send_addr = 5'b0010;
     parameter release_sda = 5'b0011;
     parameter wait_ack = 5'b0100;
     parameter send_data=5'b0101;
     parameter stop = 5'b0110;  
     parameter loaddata = 5'b0111;
     parameter loaddata2 = 5'd8;
     parameter release_sda_data= 5'd9;
     parameter wait_ack_data = 5'd10;
     parameter stop_prepare = 5'd11;
     parameter stop_release = 5'd12;
     parameter read_data = 5'd13;
     parameter send_nack = 5'd14;
     parameter idle_hold = 5'd15;
     parameter wait_ack_hold = 5'd16;
     parameter idle_hold2=5'd17;
     parameter rep_start_prepare = 5'd18; // NEW: Repeated Start State
   
   
     parameter slave_addr = 8'b10010000;
     parameter slave_addr_wr = 8'b10010000;
     parameter slave_addr_rd = 8'b10010001;
     parameter databyte1 = 8'h55;
     parameter databyte2 = 8'hAA;
     
     
     reg second_byte;
     reg ack_data_ok;
     reg rw_mode;
     reg transaction_done; 
     reg next_sda_drive;
     reg next_sda_out;
     
     
     reg [4:0]  present_state;
     reg [4:0]  next_state;
     reg [7:0]  shift_reg;
     reg [3:0]  bit_count; 
     reg        tx_bit;
     wire       scl_clk; 
     reg        sda_drive;
     reg        sda_out;
     reg[7:0]   rx_data;
     
     
     
     assign sda = (sda_drive) ? sda_out : 1'bz;
     assign scl =scl_clk;
     
     
     
     clock_divider_I2C uut(.clock(clk),.reset(rst),.scl(scl_clk) );
     
     
     
     
     always @(posedge scl_clk or posedge rst )
     begin 
       if(rst) begin 
         present_state <= idle;
         second_byte <=1'b0;
         ack_data_ok <= 1'b0;
       end else begin  
          if (present_state != next_state)
              $display("Master state  %0d -> %0d ", present_state ,next_state);
          present_state<= next_state;
       end
      end    
      
      
      

      always @(*)
      
       begin 
       
         
            idle:
         
              if(transaction_done) next_state = idle; 
              else next_state = start;
              
              
             start:
         
               next_state = send_addr;
               
               
             send_addr :

              if(bit_count==0) next_state = release_sda;
              else next_state = send_addr ;
              
              
              release_sda :
         
              next_state = wait_ack_hold;
              
              
         wait_ack_hold :
         
              next_state = wait_ack;
              
              
           wait_ack :
         
          begin  
          
          if(sda == 1'b0)
          begin 
            if(rw_mode == 1'b0) 
            next_state =loaddata;
            
            else 
            next_state = read_data;
            
           end
           
            else
            next_state = stop ;
           end 
           
           
         read_data:
         
             if(bit_count == 0) 
             next_state = send_nack;
             
             else next_state = read_data;
                 
                 
         send_nack: 
         
             next_state = stop_prepare;
                 
                 
         loaddata: 
         
             next_state = send_data;
             
         loaddata2:
         
             next_state = send_data;
               
         send_data :
         
             if(bit_count==0) 
             next_state = release_sda_data;
             
             else 
             next_state =send_data;
         
         
         release_sda_data:
         
             next_state = wait_ack_data;
               
         wait_ack_data :  
          
         begin 
             if(sda == 1'b0)
              begin 
              
                 if(second_byte==0)
                 
                    next_state = loaddata2;
                 else 
                    // NEW: Jump to Repeated Start instead of Stop!
                    next_state = rep_start_prepare ; 
             end else 
                 next_state = wait_ack_data;
         end 
         
         
         rep_start_prepare: 
         // NEW: Link back to Start
             next_state = start;
                       
         stop_prepare:
         
             next_state = stop_release;
         stop_release :
         
             next_state = idle_hold ;
         idle_hold:
         
             next_state= idle_hold2;
         idle_hold2:
         
             next_state =idle;
         stop:
         
             next_state = idle;
         default:
         
             next_state = idle;
      endcase
      end
          
          
          
          
          
      always @(posedge scl_clk or posedge rst)
      
      begin 
      
         if(rst) 
         begin
           shift_reg <= 8'b0;
           bit_count <= 4'b0;
           tx_bit <= 1'b0;
           sda_drive  <=1'b0;
           rw_mode <=1'b0;
           transaction_done <= 1'b0;
         end 
         
         else 
         begin 
            case(present_state)
              start:
                  begin
                  
                     if(rw_mode)
                     begin                                                                         
                        shift_reg <= slave_addr_rd;
                        $display("loading read  address  = %h", slave_addr_rd);
                     end
                     
                      else 
                      begin
                        shift_reg <= slave_addr_wr;
                        $display("loading write address  = %h", slave_addr_wr);
                     end
                     bit_count <= 4'd8;
                     sda_drive <=1'b1;
                     sda_out   <= 1'b0;  
                  end 
             
             
               send_addr: 
                   begin 
                   
                     if(shift_reg[7] == 1'b0) 
                     
                     begin 
                       sda_drive <= 1'b1;
                       sda_out   <= 1'b0;
                      end 
                      
                      
                      else 
                      sda_drive <= 1'b0;
                     tx_bit <= shift_reg[7];
                     
                     if(bit_count != 0)
                      begin 
                          shift_reg <= shift_reg<<1;
                          bit_count <= bit_count-1;
                     end
                   end  
                   
               release_sda : 
                           sda_drive<=1'b0;
               
               
               release_sda_data: 
                               sda_drive<=1'b0;
                        
               wait_ack_data:
                   begin 
                   
                        sda_drive<=1'b0;
                        if(sda ==1'b0) ack_data_ok <=1'b1;
                        
                   end 
                      
               wait_ack:
                   if(sda == 1'b0 && rw_mode) 
                   
                   begin 
                   
                        bit_count <= 4'd8;
                        rx_data<= 8'd0;
                        
                   end 
                      
               read_data :
                   begin  
                        sda_drive <= 1'b0;
                        rx_data <= {rx_data[6:0],sda};
                        
                        if(bit_count !=0) 
                        begin
                            bit_count <= bit_count - 1;
                            if (bit_count == 1)
                                $display(">>> MASTER SUCCESSFULLY READ DATA: %h <<<", {rx_data[6:0],sda});
                        end
                   end
                             
                             
               send_nack: 
                   begin
                        sda_drive <= 1'b0; 
                   end
                      
               loaddata :
                   begin
                         ack_data_ok<=1'b0;
                         shift_reg <= databyte1;
                         bit_count <= 4'd8;
                         second_byte <=1'b0;
                   end   
                      
                      
               loaddata2 :
                   begin  
                         ack_data_ok<=1'b0;
                         shift_reg <= databyte2;
                         bit_count <= 4'd8;
                         second_byte <=1'b1;
                   end   
            
            
               send_data:
               
                   begin 
                   
                     if(shift_reg[7] == 1'b0)
                     
                      begin 
                       sda_drive <= 1'b1;
                       sda_out   <= 1'b0;
                      end 
                      
                      else 
                        sda_drive <= 1'b0;
                      
                     tx_bit <= shift_reg[7];
                     
                     if(bit_count != 0)
                      begin 
                          shift_reg <= shift_reg<<1;
                          bit_count <= bit_count-1;
                        end
                   end           
                  
               rep_start_prepare: // NEW: Setup Repeated Start
               
                  begin 
                     sda_drive <= 1'b0; // Release SDA High
                     rw_mode <= 1'b1;   // Automatically switch to Read Mode!
                     
                     $display(">>> MASTER: INITIATING REPEATED START <<<");
                     
                  end
                  
               stop_prepare :
               
                  begin 
                  
                     sda_drive <= 1'b1;
                     sda_out <= 1'b0;
                     
                  end
                  
               stop_release:
               
                  begin  
                  
                      sda_drive <= 1'b0;
                      transaction_done <= 1'b1; 
                      
                  end 
                      
               stop : sda_drive <=1'b0;
            endcase      
         end  
      end   
endmodule
