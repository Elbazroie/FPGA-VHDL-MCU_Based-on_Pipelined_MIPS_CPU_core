--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY  Execute IS
	PORT(		Read_data_1 	 	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Read_data_2 	 	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_data_2	  	  : IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_data_1	  	  : IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_data_rs	  	  : IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				FWD_MEM			  	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				FWD_WB				  : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				forwardA			  : IN  STD_LOGIC_VECTOR( 1  DOWNTO 0 );
				forwardB			  : IN  STD_LOGIC_VECTOR( 1  DOWNTO 0 );
				rs_EX	  	 		  : OUT STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				rt_EX	  	 		  : OUT STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				des_EX				  : OUT STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_data_mem    	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
				write_reg_address_out : OUT	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				Sign_extend 	  	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				A_data		 	  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
				B_data		 	  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );				
				ALU_ctl 		  	  : IN 	STD_LOGIC_VECTOR( 3  DOWNTO 0 );
				ALUSrc 			  	  : IN 	STD_LOGIC;
				RegDst 			  	  : IN 	STD_LOGIC;
				MemtoReg 		  	  : IN 	STD_LOGIC;
				RegWrite 		 	  : IN 	STD_LOGIC;						
				MemRead 		  	  : IN 	STD_LOGIC;
				MemWrite 		  	  : IN 	STD_LOGIC;		
				MemtoReg_out 	  	  : OUT STD_LOGIC;
				RegWrite_out 	  	  : OUT	STD_LOGIC;						
				MemRead_out 	  	  : OUT	STD_LOGIC;
				MemWrite_out      	  : OUT	STD_LOGIC;			
				Zero_out 		  	  : OUT	STD_LOGIC;
				ALU_Res			  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );				
				ALU_Result_out	  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ISR 				  : IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ISR_out 			  : OUT	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				EPC					  : IN  STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
				EPC_out				  : OUT STD_LOGIC_VECTOR( 7  DOWNTO 0 );
				INTR 			 	  : IN	STD_LOGIC; 							
				clock, reset ,ena	  : IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput, Signinput: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL shamt					: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
SIGNAL write_reg_address 		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
SIGNAL ALU_result 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL MUL		 				: STD_LOGIC_VECTOR( 63 DOWNTO 0 );
SIGNAL Zero				 		: STD_LOGIC;
SIGNAL MemReadISR	 			: STD_LOGIC;
SIGNAL MemtoReg_in				: STD_LOGIC;
SIGNAL RegWrite_in				: STD_LOGIC;	
SIGNAL MemRead_in				: STD_LOGIC;
SIGNAL MemWrite_in				: STD_LOGIC;	

BEGIN
------------------------------- OUTPUT SIGNALS -------------------------
	des_EX 	<= write_reg_address;
	ALU_Res <= ALU_result;
	A_data	<= Ainput;	
	B_data	<= Binput;
------------------------------- ALU ------------------------------------
-- Shift bits
	shamt	<= Sign_extend( 10 DOWNTO 6 );
	
-- Mux for Register Write Address
    write_reg_address <= write_data_1 WHEN RegDst = '1' ELSE
						 write_data_2;
						 
-- ALU input mux
	Binput <= Signinput 						   WHEN ( ALUSrc = '0' )  					   ELSE 
			  X"0000" & Sign_extend( 15 DOWNTO 0 ) WHEN ALU_ctl = "0010" AND ( ALUSrc = '1' )  ELSE -- ORI w/o sign extention
			  Sign_extend( 31 DOWNTO 0 );
					 
-- Connect to FORWARD UNIT					 
	rs_EX	<= write_data_rs;
	rt_EX	<= write_data_2;
	
-- FORWARDING Operation
	-- A
	Ainput		<= 	FWD_MEM  	WHEN ( forwardA = "01" )  ELSE 
					FWD_WB   	WHEN ( forwardA = "10" )  ELSE 
					Read_data_1;
	-- B				
	Signinput	<= 	FWD_MEM  	WHEN ( forwardB = "01" )  ELSE 
					FWD_WB   	WHEN ( forwardB = "10" )  ELSE 
					Read_data_2;	

-- Generate Zero Flag
	Zero <= '1' WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  ) ELSE
			'0';    
	
-- Select ALU output for SLT operations OR ISR routine      
	ALU_result <= X"0000000" & B"000" & ALU_output_mux( 31 ) WHEN ALU_ctl = "1101" ELSE 
				  X"0000" & X"082E" 	 					 WHEN ISR = "10" 	   ELSE -- address = TYPE 
				  ALU_output_mux( 31 DOWNTO 0 );
				  
	MemReadISR <= '1' WHEN ISR = "10" ELSE MemRead_in; -- LW for ISR
				  
------------------------------- EXECUTION UNIT ------------------------------------	
	MUL <= std_logic_vector(signed(Ainput) * signed(Binput)); -- Multipication unit

PROCESS ( ALU_ctl, Ainput, Binput, MUL, shamt )
	BEGIN
					-- Select ALU operation					-- OPCODE FOR EACH OPERATION
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0000" 	=>	ALU_output_mux 	<= Ainput + Binput;					-- ADD / ADDI  
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0001" 	=>	ALU_output_mux 	<= Ainput AND Binput; 				-- AND / ANDI
						-- ALU performs ALUresult = A_input OR B_input
        WHEN "0010" 	=>	ALU_output_mux 	<= Ainput OR Binput;				-- OR / ORI 
						-- ALU performs ALUresult = A_input XOR B_input 
 	 	WHEN "0011" 	=>	ALU_output_mux 	<= Ainput xor Binput;				-- XOR / XORI
						-- ALU performs ALUresult = A_input - B_input
 	 	WHEN "0100" 	=>	ALU_output_mux 	<= Ainput - Binput;					-- SUB
						-- ALU performs ALUresult = A_input - B_input
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= Ainput - Binput;					-- BEQ	
						-- ALU performs ALUresult = A_input - B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;					-- BNE					
						--ALU performs ALUresult = A_input * B_input	
 	 	WHEN "0111" 	=>	ALU_output_mux <= MUL(31 DOWNTO 0);					-- MUL
						-- ALU performs ALUresult = SW
 	 	WHEN "1000" 	=>	ALU_output_mux 	<= Ainput + Binput;					-- SW / LW				
						-- ALU performs ALUresult = LUI
 	 	WHEN "1001" 	=>	ALU_output_mux 	<= Binput(15 DOWNTO 0) & X"0000";	-- LUI
						-- ALU performs SHL
 	 	WHEN "1010" 	=>	ALU_output_mux <= std_logic_vector(shift_left(unsigned(Binput), to_integer(unsigned(shamt)))); -- SLL
  						-- ALU performs SHR
 	 	WHEN "1011" 	=>	ALU_output_mux <= std_logic_vector(shift_right(unsigned(Binput), to_integer(unsigned(shamt)))); --SRL
  						-- ALU performs JMP
 	 	WHEN "1100" 	=>	ALU_output_mux <= Ainput;			-- J / JAL / JR
  						-- ALU performs SLT/SLTI
 	 	WHEN "1101" 	=>	ALU_output_mux <= Ainput - Binput;  -- SLT / SLTI
  						-- ALU performs MOVE
 	 	WHEN "1110" 	=>	ALU_output_mux <= Binput;			-- MOVE	
						-- ALU Default
 	 	WHEN OTHERS		=>	ALU_output_mux 	<= X"00000000" ;	-- DEFAULT
  	END CASE;
  END PROCESS;
  
------------------------------- EX/MEM IR ------------------------------------

-- Flush EX/MEM Mux
	MemtoReg_in	 <= MemtoReg 	WHEN INTR = '0' ELSE '0';
	RegWrite_in	 <= RegWrite 	WHEN INTR = '0' ELSE '0';	
	MemRead_in	 <= MemRead     WHEN INTR = '0' ELSE '0';
	MemWrite_in	 <= MemWrite 	WHEN INTR = '0' ELSE '0';
	
-- Data 
	EX_IR:	process(clock,reset)
			begin
				if(reset = '1') then		
					write_reg_address_out <= (others => '0');	
					Zero_out 	  		  <= '0';						
					ALU_result_out 		  <= (others => '0');											
					write_data_mem  	  <= (others => '0');						
				elsif rising_edge(clock) then
					if (ena = '1') then
						EPC_out 	  		  <= EPC;
						write_reg_address_out <= write_reg_address;	
						Zero_out 	   		  <= Zero;						
						ALU_result_out 		  <= ALU_result;											
						write_data_mem  	  <= Signinput;		
					end if;
				end if;
			end process;
-- Control 
	ctrl_EX_IR:	process(clock,reset)
				begin
					if(reset = '1') then			
						MemtoReg_out <= '0';							
						RegWrite_out <= '0';						
						MemRead_out  <= '0';					
						MemWrite_out <= '0';			
					elsif rising_edge(clock) then
						if (ena = '1') then		
							ISR_out		 <= ISR;
							MemtoReg_out <= MemtoReg_in;							
							RegWrite_out <= RegWrite_in;						
							MemRead_out  <= MemReadISR;					
							MemWrite_out <= MemWrite_in;	
						end if;			
					end if;
				end process;
END behavior;