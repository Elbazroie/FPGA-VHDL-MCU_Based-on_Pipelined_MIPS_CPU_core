		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 			: OUT 	STD_LOGIC;
	ALUSrc 			: OUT 	STD_LOGIC;
	MemtoReg 		: OUT 	STD_LOGIC;
	RegWrite 		: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 		: OUT 	STD_LOGIC;
	Branch 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALU_ctl 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	jal,jr,jmp		: OUT 	STD_LOGIC;
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS
	SIGNAL  R_format, Lw, Sw, Beq, Addi, slt, mov, jmpop, orop 	: STD_LOGIC;
	SIGNAL  shiftl, shiftr, add, sub, andop, xorop, jalop  		: STD_LOGIC;
	SIGNAL  jrop, mul, Bne, Andi, Ori, Xori, lui,	slti		: STD_LOGIC;
BEGIN           
---------------------------- OUTPUT SIGNALS --------------------------------------
	jal <= 	jalop;
	jmp <= 	jmpop;
	jr  <= 	jrop;
	
------------ Code to generate control signals using opcode bits ------------------
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	-- R-type operations
   	shiftl      <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "000000"  ELSE '0';--
   	shiftr      <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "000010"  ELSE '0';--
   	add         <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "100000"  ELSE '0';--
   	sub      	<=  '1'  WHEN  Opcode = "000000" and Function_opcode = "100010"  ELSE '0';--
   	andop       <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "100100"  ELSE '0';--  
   	orop        <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "100101"  ELSE '0';--
	xorop       <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "100110"  ELSE '0';--
   	slt         <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "101010"  ELSE '0';	
   	jrop     	<=  '1'  WHEN  Opcode = "000000" and Function_opcode = "001000"  ELSE '0';--
   	mov         <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "100001"  ELSE '0';--			
	-- Immediate operations
   	mul         <=  '1'  WHEN  Opcode = "011100" and Function_opcode = "000010"  ELSE '0';--	
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';--
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';--
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';--
   	Bne         <=  '1'  WHEN  Opcode = "000101"  ELSE '0';--
   	Addi        <=  '1'  WHEN  Opcode = "001000"  ELSE '0';--	
   	Andi        <=  '1'  WHEN  Opcode = "001100"  ELSE '0';--	
   	Ori         <=  '1'  WHEN  Opcode = "001101"  ELSE '0';--	
   	Xori        <=  '1'  WHEN  Opcode = "001110"  ELSE '0';--		
	lui         <=  '1'  WHEN  Opcode = "001111"  ELSE '0';--
   	slti        <=  '1'  WHEN  Opcode = "001011"  ELSE '0';
	-- jump operation
	jmpop       <=  '1'  WHEN  Opcode = "000010"  ELSE '0';--
	jalop       <=  '1'  WHEN  Opcode = "000011"  ELSE '0';--

---------------------------- Generate ALU control bits --------------------------------------
   	ALU_ctl <=  "0000"  WHEN  (add = '1' or Addi = '1') 					ELSE -- ADD / ADDI
				"0001"  WHEN  (andop = '1' or Andi = '1')  		  			ELSE -- AND / ANDI
				"0010"  WHEN  (orop = '1' or Ori = '1')  	 				ELSE -- OR  / ORI
				"0011"  WHEN  (xorop = '1' or Xori = '1')  		 			ELSE -- XOR	/ XORI			
				"0100"  WHEN  (sub = '1') 									ELSE -- SUB
				"0101"  WHEN  (Beq = '1') 									ELSE -- BEQ						
				"0110"  WHEN  (Bne = '1') 									ELSE -- BNE				
				"0111"  WHEN  (mul = '1')									ELSE -- MUL
				"1000"  WHEN  (sw = '1' or Lw = '1')						ELSE -- SW / LW
				"1001"  WHEN  (lui = '1')									ELSE -- LUI			
				"1010"  WHEN  (shiftl = '1')								ELSE -- SHL	
				"1011"  WHEN  (shiftr = '1')								ELSE -- SHR	
				"1100"  WHEN  (jmpop = '1' or jalop = '1' or jrop = '1')	ELSE -- JMP	/ JAL / JR			
				"1101"  WHEN  (slt = '1' or slti = '1')						ELSE -- SLT	/ SLTI
				"1110"  WHEN  (mov = '1')									ELSE -- MOVE	
				"1111";
	
------------------------------------ CONTROL LINES --------------------------------------------------	
	RegDst    	<=  R_format OR mul;
 	ALUSrc  	<=  Lw OR Sw OR slti OR lui OR Xori OR Ori OR Andi OR Addi; 
	MemtoReg 	<=  Lw; --
  	RegWrite 	<=  (R_format and not (jrop)) OR Lw OR Addi OR Andi OR xori OR ori OR lui OR jalop OR slti OR mul; 
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch(0)   <=  Beq;
	Branch(1)   <=  Bne;

   END behavior;


