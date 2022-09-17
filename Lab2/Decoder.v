`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module Decoder(
    input [3:0] Rd,
    input [1:0] Op,
    input [5:0] Funct,
    output PCS,
    output RegW,
    output MemW,
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    output NoWrite,
    output reg [1:0] ALUControl,
    output reg [1:0] FlagW
    );
    
    wire [1:0] ALUOp ;
    reg [9:0] controls ;
    //<extra signals, if any>
    wire Branch;
    
    //PC Logic
    assign PCS = ((Rd == 15) & RegW) | Branch;
    
    //Main Decoder
    assign Branch = Op[1];
    assign ALUOp = Op;
    
    assign RegW = (Op[0])? Funct[0]:~Op[1];
    assign MemW = (Op[0])? ~Funct[0]:0;
    assign MemtoReg = Op[0];
    assign ALUSrc = !(Op | Funct[5]]);
    assign ImmSrc = Op[1:0];
    assign RegSrc = Op[0:1];
    assign NoWrite = (Funct[4:0] == 5'b10101);
    
    //ALU Decoder
    always @(*)
    begin
    	if (ALUOp == 2'b00)
    	begin
    		case (Funct[4:1])
    			4'b0100:
    			begin
    				ALUControl <= 2'b00;
    				FlagW <= (Funct[0])? 2'b11:2'b00;
    			end
    			4'b0010:
    			begin
    				ALUControl <= 2'b01;
    				FlagW <= (Funct[0])? 2'b11:2'b00;
    			end
    			4'b000:
    			begin
    				ALUControl <= 2'b10;
    				FlagW <= (Funct[0])? 2'b10:2'b00;
    			end
    			4'b1100:
    			begin
    				ALUControl <= 2'b11;
    				FlagW <= (Funct[0])? 2'b10:2'b00;
    			end
    		endcase
    	end
    	else if (ALUOp == 2'b01)
    	begin
    		ALUControl <= !Funct[3];
    		FlagW <= 2'b00;
    	end
    	else if (ALUOp == 2'b10)
    	begin
    		ALUControl <= 2'b00;
    		FlagW <= 2'b00;
    	end
    end
endmodule




