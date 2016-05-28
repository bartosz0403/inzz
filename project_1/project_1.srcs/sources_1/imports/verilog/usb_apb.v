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
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "usb1_defines.v"






module usb_apb

     (  
 
	// Endpoint Interface
	// od amby    write enable 
		ep1_din,  ep1_we, ep1_full,
		ep1_dout, ep1_re, ep1_empty,
	
// AMBA interface
/*		apb_din,  apb_we, apb_full,
		apb_dout, apb_re, apb_empty,
*/
//AMBA global signals
	PCLK,
	PRESETn,
///-------AMBA signals APB ASSERT--------------//
	PSEL,
	PENABLE,
	PADDR,
	PWRITE, // write / read =====>  1/0
	PWDATA, /// ----- dane zapisywane
///________________AMBA signals APB ASSERT__________________//	



	///-----OUT SLAVE ASSIGN -------//
	PREADY,
	PRDATA,  /// ------- dane wyjsciowe read
	///_____________OUT SLAVE ASSIGN ___________//

     );
input wire PCLK;
input wire PRESETn;
//AMBA signals
input wire PSEL;
input wire PENABLE;
input wire [`USB_APB_ADDRESS_WIDTH-1:0] PADDR;
input wire PWRITE;
input wire [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PWDATA;
output wire PREADY;
output reg [`USB_APB_DATA_REGISTER_WIDTH - 1 : 0] PRDATA;







output	[7:0]	ep1_din;
input	[7:0]	ep1_dout;
input	ep1_we, ep1_re;
output		ep1_empty, ep1_full;
/*
input	[7:0]	apb_din;
output	[7:0]	apb_dout;
output		apb_we, apb_re;
input		apb_empty, apb_full;

wire	[7:0]	apb_din;
reg	[7:0]	apb_dout;
reg		apb_we, apb_re;
*/

reg	[7:0]	ep1_din;

reg		ep1_empty, ep1_full;


///---------------- PREADY logic - always 1 (for compatibility with APB3)------///
assign PREADY = 1'b1;
///---------------- PREADY logic - always 1 (for compatibility with APB3)------///




/*

///---------------------STROBE-----------------------------------------------///
reg reg_STROBE;
always @* begin
//`ifndef ASSERTIONS
//    assert (!(PENABLE & !PSEL)) else $error("PENABLE can't be 1 while PSEL is 0");
//`endif
    if((PWRITE & PSEL & PENABLE) | (~PWRITE & PSEL & ~PENABLE)) begin
        reg_STROBE <= 1'b1;
    end else begin
        reg_STROBE <= 1'b0;
    end
end
///---------------------STROBE-----------------------------------------------///




///---------------------------IN DATA - FROM AMBA -------------------------------///
// wejscie danych
// dla kazdego adresu(funkcji) inny tego typu  always
always @(posedge PCLK or negedge PRESETn) begin
    if(PRESETn == 1'b0) begin
       ep1_din <= 0;
    end else begin
        if((PWRITE == 1'b1) && (reg_STROBE == 1'b1) && (PADDR == `USB_APB_PERIOD_REG_ADDR_DF)  && (ep1_re == 1'b1)) begin
           ep1_din <= PWDATA;
           ep1_empty <= 1'b1;
        end
    end
end
///---------------------------IN DATA - FROM AMBA -------------------------------///

///---------------------------OUT DATA - TO ENDPOINT ----------------------------///

always @(posedge PCLK or negedge PRESETn) begin
    if(PRESETn == 1'b0) begin
        PRDATA <= {`USB_APB_DATA_REGISTER_WIDTH{1'b0}};
    end else begin
        if((PWRITE == 1'b0) && (reg_STROBE == 1'b1) && (PADDR == `USB_APB_CTRL_REG_ADDR_DF) && (ep1_we == 1'b1)) begin
        
        
        
        
    PRDATA <= ep1_dout;
  ep1_full <= 1'b1;

        
		end
	end
end

///---------------------------OUT DATA - TO ENDPOINT ----------------------------///


*/
always @(posedge PCLK or negedge PRESETn) begin
 ep1_empty <= 1'b0;
    PRDATA <= ep1_dout;
 ep1_din <= PWDATA;
   ep1_full <= 1'b0;
end


/*

always @(posedge clk) begin
ep1_din = apb_din;
apb_dout = ep1_dout;
apb_we = ep1_we;
apb_re = ep1_re;
ep1_empty = apb_empty;
ep1_full = apb_full;

end*/

endmodule
