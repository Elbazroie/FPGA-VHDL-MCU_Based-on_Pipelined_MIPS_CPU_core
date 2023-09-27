		-- GPO
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY GPO IS
   GENERIC ( N : INTEGER );
   PORT( 
    clock		: IN 	STD_LOGIC;
   	reset		: IN 	STD_LOGIC;
	DATA_IN 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 );	
	CS			: IN 	STD_LOGIC;
	A0			: IN 	STD_LOGIC;
	A1			: IN 	STD_LOGIC;
	MemWrite 	: IN	STD_LOGIC;
	MemRead 	: IN	STD_LOGIC;	
	DATA_OUT 	: OUT   STD_LOGIC_VECTOR( N-1 DOWNTO 0 ) 
	);
END GPO;

ARCHITECTURE behavior OF GPO IS

	COMPONENT TriState is
		GENERIC( N: integer; 
				 A: integer );
		PORT (  Dout		: IN 	std_logic_vector(A-1 DOWNTO 0);
				en			: IN 	std_logic;
				Din			: OUT	std_logic_vector(N-1 DOWNTO 0);		
				IOpin		: INOUT std_logic_vector(A-1 DOWNTO 0) );
	END COMPONENT;

	SIGNAL Latch_EN, Tri_EN 	: STD_LOGIC;
	SIGNAL Latch_IN, Latch_OUT 	: STD_LOGIC_VECTOR( N-1 DOWNTO 0 );	
	SIGNAL REG_OUT 				: STD_LOGIC_VECTOR( 31  DOWNTO 0 );		
	
BEGIN  
-- enable
	Tri_EN 	 <=   CS AND MemRead  AND A0 AND A1;
	Latch_EN <= ( CS AND MemWrite AND A0 AND A1);
	
-- TriState	
	TS_GPO: TriState
		GENERIC MAP ( N => N , A => 32)
		PORT MAP (	  Dout	=> REG_OUT,
					  en	=> Tri_EN, 
					  Din	=> Latch_IN,
					  IOpin	=> DATA_IN );
-- Zero Padding Select
NONZero_PAD:IF (N = 32) GENERATE 	  				
				REG_OUT <= Latch_OUT;
			END GENERATE;
			
Zero_PAD:	IF (N /= 32) GENERATE 	  				
				REG_OUT <= (31 downto N => '0') & Latch_OUT(N-1 downto 0);
			END GENERATE;

LATCH:  PROCESS( reset , clock )
		BEGIN			
		if reset = '1' then
			Latch_OUT <= (others => '0');
		ELSIF falling_edge(clock) THEN
			IF Latch_EN = '1' THEN
				Latch_OUT <= Latch_IN;					
			END IF;
		END IF;	
		END PROCESS;

-- OUTPUT	
	DATA_OUT <= Latch_OUT(N-1 DOWNTO 0);	
	
END behavior;