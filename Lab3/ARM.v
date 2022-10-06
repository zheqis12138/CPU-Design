`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: ARM
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: ARM Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified. The implementation can be modified
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

//-- R15 is not stored
//-- Save waveform file and add it to the project
//-- Reset and launch simulation if you add interal signals to the waveform window

module ARM(
    input CLK,
    input RESET,
    //input Interrupt,  // for optional future use
    input [31:0] Instr,
    input [31:0] ReadData,
    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
    );
    
    // RegFile signals
    //wire CLK ;
    wire WE3 ;
    wire [3:0] A1 ;
    wire [3:0] A2 ;
    wire [3:0] A3 ;
    wire [31:0] WD3 ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
    wire [31:0] RD2 ;
    
    // Extend Module signals
    wire [1:0] ImmSrc ;
    wire [23:0] InstrImm ;
    wire [31:0] ExtImm ;
    
    // Decoder signals
    wire [3:0] Rd ;
    wire [1:0] Op ;
    wire [5:0] Funct ;
    //wire PCS ;
    //wire RegW ;
    //wire MemW ;
    wire MemtoReg ;
    wire ALUSrc ;
    //wire [1:0] ImmSrc ;
    wire [1:0] RegSrc ;
    //wire NoWrite ;
    //wire [1:0] ALUControl ;
    //wire [1:0] FlagW ;
    
    // CondLogic signals
    //wire CLK ;
    wire PCS ;
    wire RegW ;
    wire NoWrite ;
    wire MemW ;
    wire [1:0] FlagW ;
    wire [3:0] Cond ;
    //wire [3:0] ALUFlags,
    wire PCSrc ;
    wire RegWrite ; 
    //wire MemWrite
       
    // Shifter signals
    wire [1:0] Sh ;
    wire [4:0] Shamt5 ;
    wire [31:0] ShIn ;
    wire [31:0] ShOut ;
    
    // ALU signals
    wire [31:0] Src_A ;
    wire [31:0] Src_B ;
    wire [1:0] ALUControl ;
    wire [31:0] ALUResult ;
    wire [3:0] ALUFlags ;
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    wire WE_PC ;    
    wire [31:0] PC_IN ;
    //wire [31:0] PC ; 
        
    // Other internal signals here
    wire [31:0] PCPlus4 ;
    wire [31:0] PCPlus8 ;
    wire [31:0] Result ;

    // MCycle signals
    wire Start;
    wire [1:0] MCycleOp;
    wire [31:0] Operand1;
    wire [31:0] Operand2;
    reg [31:0] Result1;
    reg [31:0] Result2;
    reg Busy;
    
    // datapath connections here
    assign WE_PC = Busy ? 0 : 1; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
    
    // increments PC
    assign PC_IN = PCSrc ? Result : PCPlus4 ; 
    assign PCPlus4 = PC + 4 ;
    assign PCPlus8 = PCPlus4 + 4 ;

    // inputs for RegFile
    assign WE3 = RegWrite ;
    assign A1 = RegSrc[0] ? 4'b1111 : Instr[19:16] ;
    assign A2 = RegSrc[1] ? Instr[15:12] : Instr[3:0] ;
    assign A3 = Instr[15:12] ;
    assign Result = MemtoReg ? ReadData : ALUResult ; 
    assign WD3 = Result ;
    assign R15 = PCPlus8 ;
    assign WriteData = RD2;
    
    // inputs for Extend
    // assign ImmSrc = is the output of CondLogic, so maybe no need to assign?
    assign InstrImm = Instr[23:0] ;

    // inputs for Decoder
    assign Rd = Instr[15:12] ;
    assign Funct = Instr[25:20] ;
    assign Op = Instr[27:26] ;
   

    // inputs for CondLogic
    // assign PCS = (Rd == 15 & RegW) || (Op == 2'b10); // written by instr or branch
    // assign RegW = ; 
    // assign NoWrite = ;
    // assign MemW = ;
    // assign FlagW = ;
    assign Cond = Instr[31:28] ;
    // assign ALUFlags = ;

    // inputs for shifter, refer to chapter 4 slides
    assign Sh = Instr[6:5] ;
    assign Shamt5 = Instr[11:7] ;
    assign ShIn = RD2 ;

    // inputs for ALU
    assign Src_A = RD1 ;
    assign Src_B = ALUSrc? ExtImm : ShOut ;

    // input for MCycle
    assign Operand1 = RD1 ;
    assign Operand2 = ALUSrc? ExtImm : ShOut ;

    // Select result from two ALUS
    assign ALUResult = start ? Result1 : ALUResult;

    // inputs for ProgramCounter, already declared above

    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE3,
                    A1,
                    A2,
                    A3,
                    WD3,
                    R15,
                    RD1,
                    RD2     
                );
                
    // Instantiate Extend Module
    Extend Extend1(
                    ImmSrc,
                    InstrImm,
                    ExtImm
                );
                
    // Instantiate Decoder
    Decoder Decoder1(
                    Rd,
                    Op,
                    Funct,
                    PCS,
                    RegW,
                    MemW,
                    MemtoReg,
                    ALUSrc,
                    ImmSrc,
                    RegSrc,
                    NoWrite,
                    ALUControl,
                    FlagW
                );
                                
    // Instantiate CondLogic
    CondLogic CondLogic1(
                    CLK,
                    PCS,
                    RegW,
                    NoWrite,
                    MemW,
                    FlagW,
                    Cond,
                    ALUFlags,
                    PCSrc,
                    RegWrite,
                    MemWrite
                );
                
    // Instantiate Shifter        
    Shifter Shifter1(
                    Sh,
                    Shamt5,
                    ShIn,
                    ShOut
                );
                
    // Instantiate ALU        
    ALU ALU1(
                    Src_A,
                    Src_B,
                    ALUControl,
                    ALUResult,
                    ALUFlags
                );                
                
    // MCycle for multiplication and division
    MCycle MCycle1(
                    CLK,
                    RESET,
                    Start,
                    MCycleOp,
                    Operand1,
                    Operand2,
                    Result1,
                    Result2,
                    Busy
                );          


    // Instantiate ProgramCounter    
    ProgramCounter ProgramCounter1(
                    CLK,
                    RESET,
                    WE_PC,    
                    PC_IN,
                    PC  
                );     
             
endmodule
