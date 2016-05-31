//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////

// UART rx state machine

module uart_rxfsm (
             reset_n        ,
             baud_clk_16x   ,

             cfg_rx_enable  ,
             cfg_stop_bit   ,
             cfg_pri_mod    ,

             error_ind      ,

       // FIFO control signal
             fifo_aval      ,
             fifo_wr        ,
             fifo_data      ,

          // Line Interface
             si  
          );


input             reset_n        ; // active low reset signal
input             baud_clk_16x   ; // baud clock-16x

input             cfg_rx_enable  ; // transmit interface enable
input             cfg_stop_bit   ; // stop bit 
                                   // 0 --> 1 stop, 1 --> 2 Stop
input   [1:0]     cfg_pri_mod    ;// Priority Mode
                                   // 2'b00 --> None
                                   // 2'b10 --> Even priority
                                   // 2'b11 --> Odd priority

output [1:0]      error_ind     ; // 2'b00 --> Normal
                                  // 2'b01 --> framing error
                                  // 2'b10 --> parity error
                                  // 2'b11 --> fifo full
//--------------------------------------
//   FIFO control signal
//--------------------------------------
input             fifo_aval      ; // fifo empty
output            fifo_wr        ; // fifo write, assumed no back to back write
output  [7:0]     fifo_data      ; // fifo write data

// Line Interface
input             si             ;  // rxd pin



reg     [7:0]    fifo_data       ; // fifo write data
reg              fifo_wr         ; // fifo write 
reg    [1:0]     error_ind       ; 
reg    [2:0]     cnt             ;
reg    [3:0]     offset          ; // free-running counter from 0 - 15
reg    [3:0]     rxpos           ; // stable rx position
reg    [2:0]     rxstate         ;

parameter idle_st      = 3'b000;
parameter xfr_start    = 3'b001;
parameter xfr_data_st  = 3'b010;
parameter xfr_pri_st   = 3'b011;
parameter xfr_stop_st1 = 3'b100;
parameter xfr_stop_st2 = 3'b101;

wire parity = ^fifo_data;

always @(negedge reset_n or posedge baud_clk_16x) begin
   if(reset_n == 0) begin
      rxstate   <= 3'b0;
      offset    <= 4'b0;
      rxpos     <= 4'b0;
      cnt       <= 3'b0;
      error_ind <= 2'b0;
      fifo_wr   <= 1'b0;
      fifo_data <= 8'h0;
   end
   else begin
      offset     <= offset + 1;
      case(rxstate)
       idle_st   : begin
            if(!si) begin // Start indication
               if(fifo_aval && cfg_rx_enable) begin
                 rxstate   <=   xfr_start;
                 cnt       <=   0;
                 rxpos     <=   offset + 8; // Assign center rxoffset
                 error_ind <= 2'b00;
               end
               else begin
                  error_ind <= 2'b11; // fifo full error indication
               end
            end else begin
               error_ind <= 2'b00; // Reset Error
            end
         end
      xfr_start : begin
            // Make Sure that minimum 8 cycle low is detected
            if(cnt < 7 && si) begin // Start indication
               rxstate <=   idle_st;
            end
            else if(cnt == 7 && !si) begin // Start indication
                rxstate <=   xfr_data_st;
                cnt     <=   0;
            end else begin
              cnt  <= cnt +1;
            end
         end
      xfr_data_st : begin
             if(rxpos == offset) begin
                fifo_data[cnt] <= si;
                cnt            <= cnt+1;
                if(cnt == 7) begin
                   fifo_wr <= 1;
                   if(cfg_pri_mod == 2'b00)  // No Priority
                       rxstate <=   xfr_stop_st1;
                   else rxstate <= xfr_pri_st;  
                end
             end
          end
       xfr_pri_st   : begin
            fifo_wr <= 0;
            if(rxpos == offset) begin
               if(cfg_pri_mod == 2'b10)  begin // even priority
                  if( si != parity)  
                      error_ind <= 2'b10;
               end else if(cfg_pri_mod == 2'b11) begin  // Odd priority
                  if( si != ~(parity)) 
                    error_ind <= 2'b10;
               end 
               rxstate <=   xfr_stop_st1;
            end
         end
       xfr_stop_st1  : begin
          fifo_wr <= 0;
          if(rxpos == offset) begin
             if(si) begin
               if(cfg_stop_bit) // Two Stop bit
                  rxstate <=   xfr_stop_st2;
               else   
                  rxstate <=   idle_st;
             end else begin // Framing error
                error_ind <= 2'b01;
                rxstate   <=   idle_st;
             end
          end
       end
       xfr_stop_st2  : begin
          if(rxpos == offset) begin
             if(si) begin
                rxstate <=   idle_st;
             end else begin // Framing error
                error_ind <= 2'b01;
                rxstate   <=   idle_st;
             end
          end
       end
    endcase
   end
end


endmodule
