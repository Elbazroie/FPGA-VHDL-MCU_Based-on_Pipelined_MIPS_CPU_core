		-- GPI 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY GPI IS
   GENERIC ( N : INTEGER );
   PORT( 	
	DATA_IN 	: IN 	STD_LOGIC_VECTOR( N-1 DOWNTO 0 );	
	CS			: IN 	STD_LOGIC;
	A0			: IN 	STD_LOGIC;
	A1			: IN 	STD_LOGIC;
	MemRead 	: IN	STD_LOGIC;
	DATA_OUT 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 ) 
	);
END GPI;

ARCHITECTURE behavior OF GPI IS

	COMPONENT TriState is
		GENERIC( N: integer; 
				 A: integer );
		PORT (  Dout		: IN 	std_logic_vector(A-1 DOWNTO 0);
				en			: IN 	std_logic;
				Din			: OUT	std_logic_vector(N-1 DOWNTO 0);		
				IOpin		: INOUT std_logic_vector(A-1 DOWNTO 0) );
	END COMPONENT;
	
	SIGNAL  EN 		: STD_LOGIC;
	SIGNAL  REG_OUT : STD_LOGIC_VECTOR( 31  DOWNTO 0 );	
	
BEGIN   
-- enable
	EN <= CS AND MemRead AND A0 AND A1;

-- Zero Padding Select
NONZeroPAD: IF (N = 32) GENERATE 	  				
				REG_OUT <= DATA_IN;
			END GENERATE;
			
ZeroPAD:	IF (N /= 32) GENERATE 	  				
				REG_OUT <= (31 downto N => '0') & DATA_IN(N-1 downto 0);
			END GENERATE;
			
-- TriState	
	TS_GPI: TriState
		GENERIC MAP ( N => N , A => 32)
		PORT MAP (	  Dout	=> REG_OUT,
					  en	=> EN, 
					  Din	=> OPEN,
					  IOpin	=> DATA_OUT );

END behavior;