						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	GENERIC ( ALIGNMENT : BOOLEAN := FALSE );
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	MEM_Rdata			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
        	FWD_OUT_MEM			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			write_reg			: IN	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			write_reg_out		: OUT	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
			ALU_out				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	dataBUS 			: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
			ISR 				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ISR_out 			: OUT	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			EPC					: IN    STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
			EPC_out				: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
	   		MemRead			 	: IN 	STD_LOGIC;
			Memwrite 			: IN 	STD_LOGIC;
			MemtoReg 			: IN 	STD_LOGIC;
			RegWrite 			: IN 	STD_LOGIC;				
			MemtoReg_out 		: OUT 	STD_LOGIC;
			RegWrite_out 		: OUT 	STD_LOGIC;	
            clock,reset,ena		: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
------------------------------- Components ---------------------------------
	COMPONENT TriState is
		GENERIC( N: integer; 
				 A: integer );
		PORT (  Dout		: IN 	std_logic_vector(N-1 DOWNTO 0);
				en			: IN 	std_logic;
				Din			: OUT	std_logic_vector(N-1 DOWNTO 0);		
				IOpin		: INOUT std_logic_vector(A-1 DOWNTO 0) );
	END COMPONENT;

------------------------------- Signals -------------------------------------
SIGNAL write_clock  	 : STD_LOGIC;
SIGNAL DMEM_Write  	 	 : STD_LOGIC;
SIGNAL read_data_SEL 	 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL read_data_in 	 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL address_TS 		 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL address_ALIGNMENT : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
SIGNAL IO, GPI,ISR_ON	 : STD_LOGIC;
ALIAS  A11   			 : STD_LOGIC IS address(11);
ALIAS  A5   			 : STD_LOGIC IS address(5);
ALIAS  A4   			 : STD_LOGIC IS address(4);
ALIAS  A3   			 : STD_LOGIC IS address(3);
ALIAS  A1   			 : STD_LOGIC IS address(1);

BEGIN
------------------------------- OUTPUT SIGNALS ------------------------------
	FWD_OUT_MEM 	<= address;
	MEM_Rdata		<= read_data_in;

------------------------- Data Memory ---------------------------------------
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode  	  		  => "SINGLE_PORT",
		width_a 			   		  => 32,
		widthad_a 			   		  => 12,
		numwords_a 			   		  => 4096,
		width_byteena_a 			  => 1,
		lpm_hint 			   		  => "ENABLE_RUNTIME_MOD = YES, INSTANCE_NAME = Dmem",
		lpm_type 			   		  => "altsyncram",
		outdata_reg_a 		   		  => "UNREGISTERED",
		init_file 			   		  => "C:\Users\elbaz\OneDrive\Pictures\EEG\Y04S02\CPU LAB\Final Project\REAL TIME\RTtest\DATA.hex", 
		intended_device_family 		  => "Cyclone V",
		clock_enable_input_a  		  => "BYPASS",
		clock_enable_output_a   	  => "BYPASS",
		outdata_aclr_a 		   		  => "NONE",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",	
		power_up_uninitialized 		  => "FALSE" )
	PORT MAP (
		wren_a		=> DMEM_Write,
		clock0 		=> write_clock,
		address_a 	=> address_ALIGNMENT,
		data_a 		=> write_data,
		q_a 		=> read_data_in	);
		write_clock <= NOT clock;	-- Load memory address register with write clock
		
		DMEM_Write <= MemWrite WHEN A11 = '0' AND MemWrite = '1' ELSE '0';	
---------------------------------WORD / BYTE Alignment--------------------------------		
	-- QUARTUS
QUARTUS:	IF (ALIGNMENT = FALSE) GENERATE   					
				address_ALIGNMENT <= address_TS( 11 DOWNTO 2 ) & "00";	-- BYTE For QUARTUS	
			END GENERATE;
	
	-- ModelSim
ModelSim:	IF (ALIGNMENT = TRUE) GENERATE 	  				
				address_ALIGNMENT <= "00" & address_TS( 11 DOWNTO 2 );	-- WORD for ModelSim	
			END GENERATE;		
------------------------------------ IO ----------------------------------------------	
	IO  	<= '1' WHEN A11 = '1' AND (MemRead = '1' OR MemWrite = '1') 			  ELSE '0';
	GPI 	<= '1' WHEN IO  = '1' AND A5 = '0' AND A4 = '1'	AND A3 = '0' AND A1 = '0' ELSE '0';
	ISR_ON  <= '1' WHEN ISR(0) = '1' OR ISR(1) = '1' 								  ELSE '0';			
---------------------------------- DataBUS -------------------------------------------
-- TriState: GPI OR GPO
	TS_GPIO: TriState
		GENERIC MAP ( N => 32 , A => 32)
		PORT MAP (	  Dout	=> write_data,
					  en	=> IO AND (NOT GPI) AND (NOT ISR_ON) AND MemWrite,
					  Din	=> OPEN,
					  IOpin	=> dataBUS );
-- TriState: CPU OR IO
	TS_CPU: TriState
		GENERIC MAP ( N => 32 , A => 32)
		PORT MAP (	  Dout	=> read_data_in,
					  en	=> NOT IO,
					  Din	=> read_data_SEL,
					  IOpin	=> dataBUS );
				  
	address_TS <= X"000000" & dataBUS(7 DOWNTO 0) WHEN ( ISR = "10" ) ELSE address;
		
----------------------------- MEM/WB IR---------------------------------------------	
-- Data		
	MEM_IR:	process(clock,reset) 
			begin
				if(reset = '1') then			
					read_data 	  <= (others => '0');			
					write_reg_out <= (others => '0');
					ALU_out       <= (others => '0');
				elsif rising_edge(clock) then
					if (ena = '1') then
						EPC_out 	  <= EPC;
						read_data     <= read_data_SEL;	
						write_reg_out <= write_reg;			
						ALU_out       <= address;
					end if;	
				end if;
			end process;
-- Control
	ctrl_MEM_IR:process(clock,reset)  
				begin
					if(reset = '1') then				
						MemtoReg_out <= '0';							
						RegWrite_out <= '0';						
					elsif rising_edge(clock) then
						if (ena = '1') then
							ISR_out		 <= ISR;						
							MemtoReg_out <= MemtoReg;							
							RegWrite_out <= RegWrite;	
						end if;
					end if;
				end process;
		
END behavior;

