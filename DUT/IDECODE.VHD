						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			register_1_address 		: OUT 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			register_2_address 		: OUT 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			rt_ID					: OUT   STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			rs_ID					: OUT   STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			register_rs_address		: OUT 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			write_register_address  : IN	STD_LOGIC_VECTOR( 4  DOWNTO 0 );			
			PC_plus_4    			: IN	STD_LOGIC_VECTOR( 9  DOWNTO 0 );
			Instruction  			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			regWdata				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
			FWD_OUT_WB	 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegDst 					: IN 	STD_LOGIC;
			ALUSrc 					: IN 	STD_LOGIC;
			MemtoReg 				: IN 	STD_LOGIC;
			RegWrite 				: IN 	STD_LOGIC;
			RegWriteRF 				: IN 	STD_LOGIC;			
			MemRead 				: IN 	STD_LOGIC;
			MemWrite 				: IN 	STD_LOGIC;
			Branch 					: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALU_ctl 				: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			RegDst_out 				: OUT 	STD_LOGIC;
			ALUSrc_out 				: OUT 	STD_LOGIC;
			MemtoReg_out 			: OUT 	STD_LOGIC;
			RegWrite_out 			: OUT 	STD_LOGIC;
			MemRead_out 			: OUT 	STD_LOGIC;
			MemWrite_out 			: OUT 	STD_LOGIC;
			ALU_ctl_out 			: OUT 	STD_LOGIC_VECTOR( 3  DOWNTO 0 );
			Sign_extend  			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Branch_Address 			: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
			MemtoRegWB 				: IN 	STD_LOGIC;		-- WB mux	
			jal,jr,jmp				: IN 	STD_LOGIC;
			ID_EX_ctl_flush			: IN 	STD_LOGIC;	
			Taken					: OUT 	STD_LOGIC;	
			jr_data,jmp_data	    : OUT	STD_LOGIC_VECTOR( 7  DOWNTO 0 );
			TYPE_MEM				: IN 	STD_LOGIC_VECTOR( 7  DOWNTO 0 );
			EPC						: IN    STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
			EPC_out					: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );
			EPC_WB					: IN    STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
			INTR 			 		: IN	STD_LOGIC; 			
			ISR 			 		: IN	STD_LOGIC_VECTOR( 1  DOWNTO 0 ); 
			GIE						: OUT	STD_LOGIC; 			
			clock,reset,ena  		: IN 	STD_LOGIC );
END Idecode;

ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL write_dataID					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL Sign_extend_in				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_1_in				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2_in				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL write_register_address_2		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL write_register_address_3		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
	SIGNAL write_register_address_rs	: STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL Branch_Add					: STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
	SIGNAL RegWriteID					: STD_LOGIC;
	SIGNAL RegDst_in					: STD_LOGIC;
	SIGNAL ALUSrc_in					: STD_LOGIC;
	SIGNAL MemtoReg_in					: STD_LOGIC;
	SIGNAL RegWrite_in					: STD_LOGIC;	
	SIGNAL MemRead_in					: STD_LOGIC;
	SIGNAL MemWrite_in					: STD_LOGIC;	
	SIGNAL ALU_ctl_in					: STD_LOGIC_VECTOR( 3  DOWNTO 0 );
	SIGNAL TKN							: STD_LOGIC;		
	SIGNAL EPC_REG						: STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
	SIGNAL TYPE_MEM_REG					: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL COND_JMP						: STD_LOGIC;			
BEGIN
------------------------------- OUTPUT SIGNALS ------------------------------------
	FWD_OUT_WB  <= write_dataID;
	rt_ID		<= 	write_register_address_2;
	rs_ID		<= 	write_register_address_rs;
	regWdata 	<= write_data;
	Taken 		<= TKN;
------------------------------------ DECODE ---------------------------------------
-- Decode Instruction
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_2 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_rs 	<= Instruction( 25 DOWNTO 21 );	
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
	
-- Read Register 1 Operation
	read_data_1_in <= register_array( CONV_INTEGER( read_register_1_address ) );
	
-- Read Register 2 Operation		 
	read_data_2_in <= register_array( CONV_INTEGER( read_register_2_address ) );
							 
-- Mux to bypass data memory for Rformat instructions
 	write_dataID <= read_data 		 				  WHEN MemtoRegWB = '1' AND ISR = "00" ELSE
					X"00000" & B"00" & EPC_WB & B"00" WHEN ISR = "01" 					   ELSE
 			        ALU_result( 31 DOWNTO 0 );
					
-- Sign Extend 16-bits to 32-bits
	Sign_extend_in <= X"0000" & Instruction_immediate_value WHEN Instruction_immediate_value(15) = '0'	ELSE
					  X"FFFF" & Instruction_immediate_value;
-- REGISTER FILE --					
	PROCESS
	BEGIN
	WAIT UNTIL clock'EVENT AND clock = '0';
		IF reset = '1' THEN
			FOR i IN 0 TO 31 LOOP	-- Initial register values on reset to 0
				register_array(i) <= CONV_STD_LOGIC_VECTOR( 0, 32 );
 			END LOOP;
  		ELSIF RegWriteID = '1' AND write_register_address_3 /= 0 THEN -- Write back to register - don't write to register 0
			  if (ena = '1') then
		      register_array( CONV_INTEGER( write_register_address_3)) <= write_data;
			  end if;
		END IF;		
		IF ISR(0) = '1' THEN 
			register_array(26)(0) <= '0';
		ELSIF jr = '1' AND read_register_1_address = "11011" AND ID_EX_ctl_flush = '0' then
			register_array(26)(0) <= '1';
		END IF;	  
	END PROCESS;
	
-- connect GIE	
	GIE <= register_array(26)(0) ;					

-------------------------------------- Branch / JUMP ---------------------------------------
-- Comperator for branch operation
	PROCESS (read_data_1_in, read_data_2_in, Branch)
	BEGIN
		IF Branch = "01" then
			IF read_data_1_in = read_data_2_in THEN
				TKN <= '1';
			ELSE 
				TKN <= '0';			
			END IF;					
		ELSIF Branch = "10" then
			IF read_data_1_in /= read_data_2_in THEN	
				TKN <= '1';
			ELSE 
				TKN <= '0';					
			END IF;	
		ELSE	
			TKN <= '0';		
		END IF;
	END PROCESS;	

-- Adder to compute Branch Address					
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend_in( 7 DOWNTO 0 ) ;
	Branch_Address <= Branch_Add;
	
-- jump and link WB mux:					
 	write_data <= X"00000" & B"00" & PC_plus_4 WHEN (jal  = '1' and ISR = "00" and MemtoRegWB ='0' ) ELSE -- BECAUSE WRITING IS IN THE END OF THE PERIOD
				  write_dataID;	
-- jump and link RA($31) Reg mux:					  
	write_register_address_3 <= CONV_STD_LOGIC_VECTOR( 31, 5 ) WHEN (jal  = '1' and ISR = "00" and MemtoRegWB ='0' ) ELSE 
								CONV_STD_LOGIC_VECTOR( 27, 5 ) WHEN ( ISR = "01" ) 									 ELSE 
							    write_register_address;	
-- jump and link Write EN mux:								
	RegWriteID <= '1' WHEN (jal = '1' OR ISR = "01") ELSE
				  RegWriteRF;	
				  
-- jump / jal address:		  
	jmp_data <= TYPE_MEM_REG WHEN ISR = "10" ELSE
				Instruction( 7 DOWNTO 0 );
	
-- Jump register address:
	jr_data	 <= read_data_1_in( 9 DOWNTO 2 ); 
	
	EPC_REG  <= EPC_REG WHEN COND_JMP = '1' 													 ELSE 
				read_data_1_in( 9 DOWNTO 2 ) WHEN jr = '1' AND read_register_1_address = "11011" ELSE
				EPC;
				
	COND_REG:	process(clock)
				begin
				if rising_edge(clock) then
					IF jr = '1' OR jmp = '1' OR jal = '1' OR TKN = '1' THEN
						COND_JMP <= '1';
					ELSE
						COND_JMP <= '0';						
					end if;
				end if;
				end process;
				
	TYPE_REG:	process(clock)
				begin
				if rising_edge(clock) then
					if (ena = '1') then
						TYPE_MEM_REG <= TYPE_MEM;
					end if;
				end if;
				end process;
----------------------------- ID/EX IR---------------------------------------------	
-- Flush ID/EX Mux
	RegDst_in	 <= RegDst   WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE '0';
	ALUSrc_in	 <= ALUSrc   WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE '0';
	MemtoReg_in	 <= MemtoReg WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE '0';
	RegWrite_in	 <= RegWrite WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE '0';	
	MemRead_in	 <= MemRead  WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE '0';
	MemWrite_in	 <= MemWrite WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE '0';
	ALU_ctl_in	 <= ALU_ctl  WHEN ID_EX_ctl_flush = '0' AND INTR = '0' ELSE (others => '0');	
	
-- Data	
	ID_IR:	process(clock,reset)
			begin
				if(reset = '1') then		
					read_data_1   	    <= (others => '0');	
					read_data_2 	    <= (others => '0');						
					register_1_address  <= (others => '0');							
					register_2_address  <= (others => '0');					
					Sign_extend  	    <= (others => '0');					
					register_rs_address <= (others => '0');	
				elsif rising_edge(clock) then
					if (ena = '1') then
						EPC_out 	 	   <= EPC_REG;
						read_data_1   	   <= read_data_1_in;	
						read_data_2 	   <= read_data_2_in;						
						register_1_address <= write_register_address_1;							
						register_2_address <= write_register_address_2;					
						Sign_extend  	   <= Sign_extend_in;					
						register_rs_address<= write_register_address_rs;			
					end if;
				end if;
			end process;
-- Control
	ctrl_ID_IR:	process(clock,reset)
				begin
					if(reset = '1' ) then			
						RegDst_out   <= '0';	
						ALUSrc_out 	 <= '0';						
						MemtoReg_out <= '0';							
						RegWrite_out <= '0';						
						MemRead_out  <= '0';					
						MemWrite_out <= '0';	
						ALU_ctl_out  <= (others => '0');
					elsif rising_edge(clock) then
						if (ena = '1') then
							RegDst_out   <= RegDst_in;	
							ALUSrc_out 	 <= ALUSrc_in;						
							MemtoReg_out <= MemtoReg_in;							
							RegWrite_out <= RegWrite_in;						
							MemRead_out  <= MemRead_in;					
							MemWrite_out <= MemWrite_in;		
							ALU_ctl_out  <= ALU_ctl_in;
						end if;
					end if;
				end process;
END behavior;


