		-- GPIO Registers
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY GPIO_REG IS
   GENERIC ( N : INTEGER );
   PORT( 	
    clock		: IN 	STD_LOGIC;
	DATA_IN 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 );	
	CS			: IN 	STD_LOGIC;
	A0			: IN 	STD_LOGIC;
	MemWrite 	: IN	STD_LOGIC;
	MemRead 	: IN	STD_LOGIC;	
	DATA_OUT    : IN	STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); 
	DATA_REG 	: INOUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ) 
	);
END GPIO_REG;

ARCHITECTURE behavior OF GPIO_REG IS

	COMPONENT TriState is
		GENERIC( N: integer; 
				 A: integer );
		PORT (  Dout		: IN 	std_logic_vector(A-1 DOWNTO 0);
				en			: IN 	std_logic;
				Din			: OUT	std_logic_vector(N-1 DOWNTO 0);		
				IOpin		: INOUT std_logic_vector(A-1 DOWNTO 0) );
	END COMPONENT;
	
	SIGNAL Write_EN, Read_EN    : STD_LOGIC;	
	SIGNAL Latch_IN, Latch_OUT 	: STD_LOGIC_VECTOR( N-1 DOWNTO 0 );	
	SIGNAL REG_OUT 				: STD_LOGIC_VECTOR( 31  DOWNTO 0 );	
			
BEGIN  
-- enable
	Read_EN     <= CS AND MemRead  AND A0;
	Write_EN    <= CS AND MemWrite AND A0;
				
-- D-Latch					
	Latch_OUT 	<= Latch_IN WHEN (Write_EN = '1') ELSE Latch_OUT;
		
-- Zero Padding Select
NONZeroPAD: IF (N = 32) GENERATE 	  				
				REG_OUT <= DATA_OUT;
			END GENERATE;
			
ZeroPAD:	IF (N /= 32) GENERATE 	  				
				REG_OUT <= (31 downto N => '0') & DATA_OUT(N-1 downto 0);
			END GENERATE;
	
-- TriState: READ	
	TS_GPO_R: 	TriState
		GENERIC MAP ( N => N , A => 32)
		PORT MAP (	  Dout	=> REG_OUT,
					  en	=> Read_EN, 
					  Din	=> Latch_IN,
					  IOpin	=> DATA_IN );		
-- TriState: WRITE
	TS_GPO_W:   TriState
		GENERIC MAP ( N => N , A => N)
		PORT MAP (	  Dout	=> Latch_OUT,
					  en	=> Write_EN, 
					  Din	=> OPEN,
					  IOpin	=> DATA_REG );					
END behavior;