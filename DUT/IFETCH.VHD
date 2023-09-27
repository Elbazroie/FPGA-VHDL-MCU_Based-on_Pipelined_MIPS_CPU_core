-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	GENERIC ( ALIGNMENT : BOOLEAN := FALSE );
	PORT(	Instruction 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	Taken 			: IN 	STD_LOGIC;
			PCstall			: IN 	STD_LOGIC;
			IF_ID_stall		: IN 	STD_LOGIC;
			jr,jal,jmp		: IN	STD_LOGIC;
			jr_data,jmp_data: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
      		PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			IF_ID_ctl_flush	: IN 	STD_LOGIC;	
			ISR 			: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			EPC_out			: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
			INTR		    : IN	STD_LOGIC; 			
        	clock,reset,ena : IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL Instruction_IR_in 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL PC, PC_plus_4 	 	: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL Next_PC				: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL Mem_Addr 		 	: STD_LOGIC_VECTOR( 9 DOWNTO 0 );	
	SIGNAL Instruction_F   	 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );					
	SIGNAL PC_plus_4_F 	     	: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL write_clock 	     	: STD_LOGIC;	
BEGIN
------------------------------- OUTPUT SIGNALS ------------------------------------			 			
		PC_out 			<= PC; 			
------------------------- ROM for Instruction Memory ------------------------------
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode 		   => "ROM",
		width_a 	  		   => 32,
		widthad_a 			   => 10,
		numwords_a 			   => 1024,
		width_byteena_a 	   => 1,
		lpm_type 			   => "altsyncram",
		lpm_hint 			   => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = Imem",		
		outdata_reg_a 		   => "UNREGISTERED",
		init_file 			   => "C:\Users\elbaz\OneDrive\Pictures\EEG\Y04S02\CPU LAB\Final Project\REAL TIME\RTtest\PROGRAM.hex",
		intended_device_family => "Cyclone V",
		address_aclr_a   	   => "NONE",
		clock_enable_input_a   => "BYPASS",
		clock_enable_output_a  => "BYPASS",
		outdata_aclr_a		   => "NONE"
	)
	PORT MAP (
		clock0      => write_clock,
		address_a 	=> Mem_Addr, 
		q_a 		=> Instruction_IR_in );
		
		write_clock <= NOT clock;	-- falling edge select	
		
------------------------------- WORD / BYTE Alignment --------------------------------------------		
	-- QUARTUS
QUARTUS:	IF (ALIGNMENT = FALSE) GENERATE   					
				Mem_Addr <= PC;						-- BYTE For QUARTUS		
			END GENERATE;
	
	-- ModelSim
ModelSim:	IF (ALIGNMENT = TRUE) GENERATE 	  				
				Mem_Addr <= "00" & PC(9 DOWNTO 2);	-- WORD for ModelSim
			END GENERATE;	
			
---------------------------------------- PC ------------------------------------------------------			
-- Instructions always start on word address	
	PC(1 DOWNTO 0) <= "00";	
	
-- Adder to increment PC by 4 
	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;	      
	PC_plus_4( 1 DOWNTO 0 )  <= "00";
	
-- Mux for Branch / PC + 4 /  Jump 
	Next_PC  <= X"00" 		WHEN  reset = '1' 			 			   ELSE -- RESET
				Add_result  WHEN  Taken = '1'  		     			   ELSE -- BEQ / BNE		
				jr_data 	WHEN  jr = '1'   			 			   ELSE -- JR
				jmp_data	WHEN  jal = '1' OR jmp = '1' OR ISR = "10" ELSE -- J / JAL
				PC_plus_4( 9 DOWNTO 2 );				
	
-------------------------- output lines to ID -----------------------------------------
 	Instruction_F	<=  (others => '0')	WHEN IF_ID_ctl_flush = '1' OR INTR = '1' OR ISR /= "00" ELSE -- IF/ID Flush Mux
						Instruction_IR_in;								
	PC_plus_4_F     <=  PC_plus_4 - 4	WHEN IF_ID_ctl_flush = '1' OR INTR = '1' OR ISR /= "00" ELSE
						PC_plus_4;	
	
-- PROGRAM COUNTER
	PROCESS 
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF (reset = '1') THEN
				   PC( 9 DOWNTO 2) <= "00000000" ; 
			ELSIF  (PCstall = '0') THEN  -- stall PC
				IF ena = '1' THEN
				   PC( 9 DOWNTO 2 ) <= Next_PC;
			    END IF;
			END IF;
	END PROCESS;
	
---------------------------------------- IF/ID IR ------------------------------------------------				

ID_IR:	process(clock,reset)
		begin
			if(reset = '1' ) then		
				Instruction   	   <= (others => '0');						
				PC_plus_4_out 	   <= (others => '0');	
				EPC_out 	  	   <= (others => '0');
			elsif rising_edge(clock) then
				if (IF_ID_stall = '0') then
					if (ena = '1')  THEN			
						Instruction   <= Instruction_F;						
						PC_plus_4_out <= PC_plus_4_F;	
						EPC_out 	  <= PC( 9 DOWNTO 2 );
					end if;
				end if;
			end if;
		end process;	
END behavior;


