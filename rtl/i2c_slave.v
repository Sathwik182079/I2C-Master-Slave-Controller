`timescale 1ns / 1ps

module i2c_slave(
        input scl,input rst, inout sda
    );
    parameter my_addr = 8'b10010000;
    parameter idle = 4'd0;
    parameter r_addr = 4'd1;
    parameter check_addr=4'd2;
    parameter send_ack=4'd3;
    parameter r_data =4'd4;
    parameter stop =4'd5;
    parameter wait_data = 4'd6;
    parameter hold_ack = 4'd7;
    parameter send_data = 4'd8;
    parameter read_data = 4'd9;
    parameter master_send_nack = 4'd10;
    parameter wait_data2 =4'd11;
    parameter stop_wait = 4'd12;
    parameter hold_ack2 = 4'd13;
    
    reg [3:0]  present_state;
    reg [3:0]  next_state;
    reg [7:0]  shift_reg;
    reg rw_bit ;
    reg [3:0]  bit_count;
    reg [7:0]  rd_data;
    reg[7:0] rx_data;
    reg [7:0] tx_data;
    reg[7:0]  rx_byte1;
    reg [7:0] rx_byte2;
    reg sda_drive;
    reg sda_out;
    reg ack_count;
    reg [1:0] byte_count;
    
    // ==========================================
    // ROBUST START DETECTOR (Toggle Synchronizer)
    // ==========================================
    reg start_flag;
    reg start_flag_sync;
    wire start_detect = (start_flag != start_flag_sync);

    assign sda =(sda_drive) ? sda_out : 1'bz;
      
      
      
      
    // 1. Asynchronously flip the flag on a valid Start condition
    always @(negedge sda or posedge rst )
    
     begin 
     
        if(rst) 
            start_flag <= 1'b0;
            
        else if(scl == 1'b1 && (present_state == idle || 
                                present_state == stop_wait || 
                                present_state == wait_data || 
                                present_state == wait_data2)) begin 
            start_flag <= ~start_flag; // Toggle the flag
            
            $display(">>> SLAVE DETECTED START / REPEATED START <<<");
        end
    end
      
      
      
    // 2. Synchronously catch the flag and advance the FSM
    always @(posedge scl or posedge rst) 
    
    begin
    
        if(rst)
         begin
            present_state <= idle;
            start_flag_sync <= 1'b0;
        end 
        
        else
        
         begin
            if (start_detect) 
                start_flag_sync <= start_flag; // Acknowledge the start, clearing detection
            present_state <= next_state;
        end
    end
    
    
    
       
    always @(*) 
    
    begin 
        if (start_detect) 
        
        begin 
            next_state = r_addr; // Force FSM to address reading immediately
        end
        
         else 
         
         begin
         
            next_state = present_state;
            
            case(present_state)
                idle:
                
                    if(start_detect) 
                    next_state = r_addr;
                    
                    else
                    
                     next_state = idle;
                                   
                r_addr:
                    if(bit_count == 0) 
                    next_state = check_addr ;
                    
                    else
                     next_state = r_addr;
                                 
                check_addr:
                    if(shift_reg[7:1] == my_addr[7:1])
                     next_state = send_ack;
                     
                    else next_state = stop;
                                
                send_ack:
                    next_state = hold_ack;
                               
                send_data:
                    if(bit_count ==0)
                     next_state = stop ;
                     
                    else
                     next_state = send_data;
                
                hold_ack:
                    if(rw_bit == 1'b1) 
                    next_state = send_data; 
                    
                    else if(byte_count == 2) 
                    next_state = hold_ack2; 
                    
                    else next_state = wait_data; 
                            
                hold_ack2:
                    next_state = stop;
                     
                wait_data:
                    next_state = wait_data2;
                          
                wait_data2:
                    next_state = r_data ;
                     
                r_data:
                    if(bit_count== 0) 
                    next_state = send_ack;
                    
                    else next_state = r_data;
                                     
                stop:
                    next_state = stop_wait;
                
                stop_wait:
                    if(sda==1'b1) 
                    next_state = idle;
                    
                    else 
                    next_state = stop_wait;
                       
                       
                default:
                    next_state = idle;
            endcase 
        end
    end 
                    
                    
                    
    // 3. Reset data registers synchronously when a start is detected
    always @(negedge scl or posedge rst ) begin 
        if(rst)
         begin 
         
            shift_reg <= 8'b0;
            bit_count <= 4'd8;
            rd_data   <= 8'b0;
            sda_drive <= 1'b0;
            sda_out <= 1'b1;
            rx_byte1 <= 8'b0;
            rx_byte2 <= 8'b0;
            tx_data <= 8'hA5;
            byte_count <= 2'b0;
        end 
        
        else 
        
        begin 
            if (start_detect) begin 
                bit_count <= 4'd8;
                shift_reg <= 8'd0;
                sda_drive <= 1'b0;
                byte_count <= 2'b0;
            end 
            
            else 
            
            case (present_state)
                idle:
                begin 
                    sda_drive <= 1'b0;
                    shift_reg <= 8'd0;
                    bit_count <= 4'd8;
                end
                         
                r_addr:
                begin 
                    if(bit_count != 0) begin 
                        shift_reg <= {shift_reg[6:0],sda};
                        bit_count <= bit_count -1;
                    end 
                end
                                      
                check_addr:
                begin
                    rw_bit <= shift_reg[0];
                end
                     
                send_data:
                begin 
                    if(tx_data[7] ==1'b0) 
                    begin 
                    
                        sda_drive <= 1'b1;
                        sda_out <= 1'b0 ; 
                        
                    end
                    
                     else 
                     sda_drive <= 1'b0;
                                      
                    if(bit_count != 0 )
                     begin 
                        tx_data <= tx_data <<1;
                        bit_count <= bit_count -1;
                    end 
                end 
                        
                          
                send_ack:
                begin 
                    sda_drive <= 1'b1;
                    sda_out   <= 1'b0;
                    bit_count <= 4'd8;
                    rd_data <= 8'b0;
                    if(rw_bit) tx_data<=8'hA5;
                end
                        
                wait_data:
                
                begin 
                    sda_drive <= 1'b0;
                    sda_out <= 1'b1;
                end 
                          
                wait_data2: sda_drive <= 1'b0;
                             
                hold_ack:
                
                begin 
                    sda_drive <= 1'b1;
                    sda_out <= 1'b0;
                end
                
                hold_ack2:
                
                begin 
                    sda_drive <= 1'b1;
                    sda_out <= 1'b0;
                end
                          
                r_data:
                
                begin
                    sda_drive <= 1'b0;
                    rd_data <= {rd_data[6:0], sda};
                    
                    if(bit_count!=0) 
                    
                    begin
                        bit_count <= bit_count-1;
                        if(bit_count == 1) 
                        
                        begin
                            byte_count <= byte_count +1;
                            if(byte_count ==0)
                             rx_byte1 <= {rd_data[6:0], sda};
                             
                            else if(byte_count ==1) 
                            
                            rx_byte2 <= {rd_data[6:0], sda};
                        end
                    end
                end
                           
                stop:
                begin 
                    sda_drive <= 1'b0;
                    shift_reg <= 8'd0;
                    bit_count <= 4'd8;
                    byte_count <= 0;
                    rd_data <=8'b0;
                    rw_bit <= 1'b0;
                    ack_count <=1'b0;
                end  
            endcase      
        end
    end
endmodule
