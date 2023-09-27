			-- Top Level Structural Model: MCU
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU IS
	GENERIC ( ALIGNMENT : BOOLEAN := FALSE ); -- WORD/BYTE alignment: FALSE = QUARTUS ; TRUE = ModelSim
	PORT( reset, clock, ena	: IN  STD_LOGIC; 
	-- GPIO
		SW					: IN  STD_LOGIC_VECTOR( 7  DOWNTO 0 );
		KEY					: IN  STD_LOGIC_VECTOR( 2  DOWNTO 0 );
		LEDR				: OUT STD_LOGIC_VECTOR( 7  DOWNTO 0 );
		HEX0, HEX1			: OUT STD_LOGIC_VECTOR( 6  DOWNTO 0 );
		HEX2, HEX3			: OUT STD_LOGIC_VECTOR( 6  DOWNTO 0 );
		HEX4, HEX5			: OUT STD_LOGIC_VECTOR( 6  DOWNTO 0 );
		BT_OUTMOD			: OUT STD_LOGIC ); 
END MCU;

ARCHITECTURE structure OF MCU IS
------------------------------ Components ------------------------------------------
	COMPONENT MIPS IS
		GENERIC ( ALIGNMENT : BOOLEAN); -- WORD/BYTE alignment: FALSE = QUARTUS ; TRUE = ModelSim
		PORT( 
		 reset, clock, ena	: IN 	STD_LOGIC; 
		 INTR 				: IN 	STD_LOGIC; 
		 INTA				: OUT	STD_LOGIC; 
		 GIE				: OUT	STD_LOGIC; 
		 dataBUS			: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
		 addressBUS			: OUT 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );	
		 MemRead_MEM		: OUT 	STD_LOGIC;
		 Memwrite_MEM		: OUT 	STD_LOGIC
		 );
	END COMPONENT;
	
	COMPONENT Decoder IS
		PORT (  input 	  : IN   STD_LOGIC_VECTOR (3 DOWNTO 0);
				output 	  : OUT  STD_LOGIC_VECTOR (6 DOWNTO 0) );
	END COMPONENT;

	COMPONENT GPI IS
	   GENERIC ( N : INTEGER );	
	   PORT( 	
		DATA_IN 	: IN 	STD_LOGIC_VECTOR( N-1 DOWNTO 0 );	
		CS			: IN 	STD_LOGIC;
		A0			: IN 	STD_LOGIC;
		A1			: IN 	STD_LOGIC;
		MemRead 	: IN	STD_LOGIC;
		DATA_OUT 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 ) 
		);
	END COMPONENT;
	
	COMPONENT GPO IS
	   GENERIC ( N : INTEGER );
	   PORT( 
		clock		: IN 	STD_LOGIC;	   
		reset		: IN 	STD_LOGIC;
		DATA_IN 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 );	
		CS			: IN 	STD_LOGIC;
		A0			: IN 	STD_LOGIC;
		A1			: IN 	STD_LOGIC;
		MemWrite 	: IN	STD_LOGIC;
		MemRead		: IN	STD_LOGIC;
		DATA_OUT 	: OUT   STD_LOGIC_VECTOR( N-1 DOWNTO 0 ) 
		);
	END COMPONENT;	
	
	COMPONENT CS_DEC IS
	   PORT( 	
		address 	: IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
		CS			: OUT 	STD_LOGIC_VECTOR( 10 DOWNTO 0 )
		);
	END COMPONENT;

	COMPONENT BTIMER IS
		PORT( reset,clock,ena : IN    STD_LOGIC; 
			  data			  : INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
			  A0 , A1		  : IN 	  STD_LOGIC;
			  CS			  : IN 	  STD_LOGIC_VECTOR( 3  DOWNTO 0 );  
			  MemWrite 		  : IN	  STD_LOGIC;
			  MemRead		  : IN	  STD_LOGIC;
			  BT_INT		  : OUT	  STD_LOGIC;
			  OUTMOD		  : OUT	  STD_LOGIC );
	END COMPONENT;	
	
	COMPONENT INTERRUPT IS
		PORT( reset, clock	: IN    STD_LOGIC; 
			  NMI			: OUT   STD_LOGIC;  
			  GPO_RST		: OUT   STD_LOGIC; 		  
			  data			: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
			  A0 , A1		: IN 	STD_LOGIC;
			  CS			: IN 	STD_LOGIC; 
			  INT_SRC		: IN 	STD_LOGIC_VECTOR( 7  DOWNTO 0 ); 
			  INTR			: OUT	STD_LOGIC;
			  INTA			: IN	STD_LOGIC;
			  GIE			: IN	STD_LOGIC; 		  
			  MemWrite 		: IN	STD_LOGIC;
			  MemRead		: IN	STD_LOGIC );
	END COMPONENT;	
	
------------------------------ Signals ------------------------------------------
-- MIPS
	SIGNAL rst, NMI				: STD_LOGIC;	
	SIGNAL GPO_RST				: STD_LOGIC;	
	SIGNAL dataBUS 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL addressBUS 			: STD_LOGIC_VECTOR( 11 DOWNTO 0 );
	SIGNAL CS 					: STD_LOGIC_VECTOR( 10 DOWNTO 0 );	
	SIGNAL MemRead, MemWrite	: STD_LOGIC;	
	SIGNAL INTR, INTA, GIE   	: STD_LOGIC;	
	SIGNAL INT_SRC				: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL HEX0_DEC, HEX1_DEC	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
	SIGNAL HEX2_DEC, HEX3_DEC	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
	SIGNAL HEX4_DEC, HEX5_DEC	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
	ALIAS  A0    				: STD_LOGIC IS addressBUS(0);	
	ALIAS  A1    				: STD_LOGIC IS addressBUS(1);		
	ALIAS  A2    				: STD_LOGIC IS addressBUS(2);	
	ALIAS  A3    				: STD_LOGIC IS addressBUS(3);	
	ALIAS  A4    				: STD_LOGIC IS addressBUS(4);	
	ALIAS  A5    				: STD_LOGIC IS addressBUS(5);	
	ALIAS  A11    				: STD_LOGIC IS addressBUS(11);			
BEGIN

INT_SRC( 5 DOWNTO 3) <= NOT KEY WHEN ena = '1' ELSE (others=>'0');
-----------------------------------------------------------
-- Syncronious RESET
	SYN_RST:	process(clock)
					begin	
					if rising_edge(clock) then
						rst <= NOT reset;							
					end if;			
				end process;

-- CPU 
	CPU_MIPS:   MIPS
	  	GENERIC MAP ( ALIGNMENT => ALIGNMENT )
		PORT MAP (	reset 		 => NMI,
					clock		 => clock,
					ena			 => ena,
					dataBUS		 => dataBUS,
					addressBUS	 => addressBUS,
					INTR		 =>	INTR,
					INTA		 =>	INTA,
					GIE			 =>	GIE,
					MemRead_MEM	 => MemRead,
					Memwrite_MEM => MemWrite );
-- Chip select Decoder 					
	CS_DECODER: CS_DEC
		PORT MAP (	address	    => ( A11 & A5 & A4 & A3 & A2 ),
					CS			=> CS );				
-- GPIO    
		-- LEDR --
	PORT_LEDR:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		 => clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(0),
					A0			=>  NOT A0,
					A1			=>  NOT A1,					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  LEDR );
		-- HEX0 --					
	PORT_HEX0:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		 => clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(1),
					A0			=>  NOT A0,	
					A1			=>  NOT A1,	
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  HEX0_DEC );						
	HEX0_TO_HEX : Decoder port map( input => HEX0_DEC(3 downto 0) , output => HEX0 );
	
		-- HEX1 --
	PORT_HEX1:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		 => clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(1),
					A0			=>  A0,	
					A1			=>  NOT A1,						
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  HEX1_DEC );
	HEX1_TO_HEX : Decoder port map( input => HEX1_DEC(3 downto 0) , output => HEX1 );
	
		-- HEX2 --					
	PORT_HEX2:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		 => clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(2),
					A0			=>  NOT A0,	
					A1			=>  NOT A1,						
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  HEX2_DEC );
	HEX2_TO_HEX : Decoder port map( input => HEX2_DEC(3 downto 0) , output => HEX2 );
	
		-- HEX3 --	
	PORT_HEX3:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		=>  clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(2),
					A0			=>  A0,	
					A1			=>  NOT A1,						
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  HEX3_DEC );
	HEX3_TO_HEX : Decoder port map( input => HEX3_DEC(3 downto 0) , output => HEX3 );
	
		-- HEX4 --					
	PORT_HEX4:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		=>  clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(3),
					A0			=>  NOT A0,	
					A1			=>  NOT A1,						
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  HEX4_DEC );
	HEX4_TO_HEX : Decoder port map( input => HEX4_DEC(3 downto 0) , output => HEX4 );					
					
		-- HEX5 --					
	PORT_HEX5:  GPO
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock		=> clock,
					reset		=>  GPO_RST,
					DATA_IN 	=>	dataBUS,
					CS			=>	CS(3),
					A0			=>  A0,	
					A1			=>  NOT A1,						
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  HEX5_DEC );
	HEX5_TO_HEX : Decoder port map( input => HEX5_DEC(3 downto 0) , output => HEX5 );	
	
		-- Switches --	
	PORT_SW:  	GPI
	    GENERIC MAP ( N => 8 )
		PORT MAP (	DATA_IN 	=>	SW,
					CS			=>	CS(4),
					A0			=>  NOT A0,
					A1			=>  NOT A1,	
					MemRead 	=>	MemRead,				
					DATA_OUT 	=>  dataBUS );	
					
		-- Keys --	
	PORT_KEYS:  GPI
	    GENERIC MAP ( N => 3 )
		PORT MAP (	DATA_IN 	=>	KEY,
					CS			=>	CS(5),
					A0			=>  NOT A0,
					A1			=>  NOT A1,	
					MemRead 	=>	MemRead,					
					DATA_OUT 	=>  dataBUS );	
					
		-- Basic Timer --						
	B_TIMER:	BTIMER
		PORT MAP (  reset       =>  NMI,
				    clock       =>  clock,
					ena			=>  ena,
					data 		=>  dataBUS,	
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,					
					A0		    =>  A0,
					A1		    =>  A1,					
					CS			=>	CS(9 DOWNTO 6),
					BT_INT		=>	INT_SRC(2),
					OUTMOD		=>	BT_OUTMOD );
					
		-- Interrupt controller --	
	INTERR :	INTERRUPT
		PORT MAP (  reset       =>  rst,
					clock       =>  clock,
					NMI         =>  NMI, 
					GPO_RST		=>  GPO_RST, 
					data	 	=>  dataBUS,
					A0		    =>  A0,
					A1		    =>  A1,					
					CS			=>	CS(10),
					INT_SRC	    =>  "00" & INT_SRC( 5 DOWNTO 2) & "00",
					INTR		=>	INTR,
					INTA		=>	INTA,
					GIE			=>	GIE,
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead );
END structure;
