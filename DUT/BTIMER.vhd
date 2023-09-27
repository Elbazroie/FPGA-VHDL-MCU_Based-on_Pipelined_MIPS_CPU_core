				-- Basic Timer Peripheral
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BTIMER IS
	PORT( reset,clock,ena : IN    STD_LOGIC; 
     	  data			  : INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
	      A0 , A1		  : IN 	  STD_LOGIC;
		  CS			  : IN 	  STD_LOGIC_VECTOR( 3  DOWNTO 0 );  
		  MemWrite 		  : IN	  STD_LOGIC;
		  MemRead		  : IN	  STD_LOGIC;
		  BT_INT		  : OUT	  STD_LOGIC;
		  OUTMOD		  : OUT	  STD_LOGIC );
END BTIMER;

ARCHITECTURE structure OF BTIMER IS

	COMPONENT GPIO_REG IS
	   GENERIC ( N : INTEGER );
	   PORT( 	
	    clock		: IN 	STD_LOGIC;
	    DATA_IN 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 );
		CS			: IN 	STD_LOGIC;
		A0			: IN 	STD_LOGIC;
		MemWrite 	: IN	STD_LOGIC;
		MemRead		: IN	STD_LOGIC;		
		DATA_OUT    : IN	STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); 		
		DATA_REG 	: INOUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ) 
		);
	END COMPONENT;	

-----------------------------------------------------------------------------------	
--BTCCR		
	SIGNAL BTCCR1, BTCCR0 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL BTCCR1_W, BTCCR0_W 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCCR1_R, BTCCR0_R 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL BTCCR1_W_EN, BTCCR0_W_EN : STD_LOGIC;	
	SIGNAL BTCCR1_R_EN, BTCCR0_R_EN : STD_LOGIC;		
	SIGNAL BTCL0, BTCL1	 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL OUT_SIGNAL				: STD_LOGIC;	
--BTCNT		
	SIGNAL BTCNT 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCNT_W 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL BTCNT_R	 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL BTCNT_W_EN		: STD_LOGIC;
	SIGNAL BTCNT_R_EN		: STD_LOGIC;			
	SIGNAL Q_SEL			: STD_LOGIC;
	
--BTCTL	
	SIGNAL BTCTL 	  		: STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
	SIGNAL BTCTL_W 	  		: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL BTCTL_R 	  		: STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
	SIGNAL BTCTL_W_EN		: STD_LOGIC;
	SIGNAL BTCTL_R_EN		: STD_LOGIC;	
	ALIAS  BTIP	  			: STD_LOGIC_VECTOR( 2  DOWNTO 0 ) IS BTCTL( 2 DOWNTO 0);	
	ALIAS  BTSSEL	  		: STD_LOGIC_VECTOR( 1  DOWNTO 0 ) IS BTCTL( 4 DOWNTO 3);
	ALIAS  BTHOLD			: STD_LOGIC IS BTCTL(5);		
	ALIAS  BTOUTEN			: STD_LOGIC IS BTCTL(6);
-- CLOCK	
	SIGNAL Divider 	 		: STD_LOGIC_VECTOR( 2  DOWNTO 0 );	
	SIGNAL CLK				: STD_LOGIC;	
	ALIAS  clock_2    		: STD_LOGIC IS Divider(0);		
	ALIAS  clock_4    		: STD_LOGIC IS Divider(1);	
	ALIAS  clock_8    		: STD_LOGIC IS Divider(2);
	
BEGIN   
-- Clock Divider
	clk_DIV:    PROCESS(clock, reset)
				BEGIN	
					if reset = '1' then
						Divider <= (others => '0');					
					ELSIF rising_edge(clock) THEN
						Divider <= Divider + 1;
					END IF;
				END PROCESS;

-- OUTPUT Unit
	OUT_UNIT:   PROCESS(reset, BTCNT )
				BEGIN	
					if reset = '1' then
						OUT_SIGNAL <= '1';				
					ELSIF BTOUTEN = '1' THEN						
						IF (BTCL0 = BTCNT) THEN
							OUT_SIGNAL <= '1';
						ELSIF (BTCL1 = BTCNT) THEN	
							OUT_SIGNAL <= NOT OUT_SIGNAL;
						END IF;		
					END IF;								
				END PROCESS;	
				
	OUTMOD 	   <= OUT_SIGNAL;
---------------------------- OUTPUT Compare Latches --------------------------------
-- BTCL0 Latch				
	BTCL0_LAT:	PROCESS(CS, BTCCR0)
				BEGIN	
					IF (CS(2) = '1' AND A0 = '0' AND A1 = '0' AND MemWrite = '1') THEN
						BTCL0 <= BTCCR0;
					END IF;
				END PROCESS;
-- BTCL1 Latch	
	BTCL1_LAT:	PROCESS(BTCCR1)
				BEGIN			
					IF (CS(3) = '1' AND A0 = '0' AND A1 = '0' AND MemWrite = '1') THEN				
						BTCL1 <= BTCCR1;
					END IF;
				END PROCESS;
			
---------------------------- BASIC TIMER REGISTERS --------------------------------

-- BTCTL Register	
	PORT_BTCTL: GPIO_REG
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,
					CS			=>	CS(0),
					A0			=>  NOT A0 AND NOT A1,					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT    =>  BTCTL_R,
					DATA_REG 	=>  BTCTL_W );
				
	BTCTL_W_EN <= CS(0) AND (NOT A0 AND NOT A1) AND MemWrite;
	BTCTL_R_EN <= CS(0) AND (NOT A0 AND NOT A1) AND MemRead;
	BTCTL_R    <= BTCTL WHEN (BTCTL_R_EN = '1') ELSE (others => '0');
	
	BTCTL_SEL:  PROCESS( reset , clock )
				BEGIN			
				if reset = '1' then
					BTCTL  <= X"20";					
				ELSIF rising_edge(clock) THEN
					IF  BTCTL_W_EN = '1' THEN
						BTCTL <= BTCTL_W;					
					ELSE		
						IF    BTIP = "001" THEN
							Q_SEL <= BTCNT(3);	
						ELSIF BTIP = "010" THEN
							Q_SEL <= BTCNT(7);		
						ELSIF BTIP = "011" THEN
							Q_SEL <= BTCNT(11);	
						ELSIF BTIP = "100" THEN
							Q_SEL <= BTCNT(15);	
						ELSIF BTIP = "101" THEN
							Q_SEL <= BTCNT(19);	
						ELSIF BTIP = "110" THEN
							Q_SEL <= BTCNT(23);	
						ELSIF BTIP = "111" THEN
							Q_SEL <= BTCNT(25);							
						ELSE
							Q_SEL <= BTCNT(0);	
						END IF;	
					END IF;	
				END IF;	
				END PROCESS;			

	WITH BTSSEL SELECT				
	CLK <=	clock_2 WHEN  "01",
			clock_4 WHEN  "10",
			clock_8 WHEN  "11",
			clock   WHEN  OTHERS;
-------------------------------------------------------------------					
-- BTCNT Register
	PORT_BTCNT  :GPIO_REG
		GENERIC MAP ( N => 32 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,
					CS			=>	CS(1),
					A0			=>  NOT A0 AND NOT A1,					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,	
					DATA_OUT    =>  BTCNT_R,				
					DATA_REG 	=>  BTCNT_W );
					
	BTCNT_W_EN <= CS(1) AND (NOT A0 AND NOT A1) AND MemWrite;
	BTCNT_R_EN <= CS(1) AND (NOT A0 AND NOT A1) AND MemRead;
	BTCNT_R    <= BTCNT WHEN (BTCNT_R_EN = '1') ELSE (others => '0');
	
	BTCNT_REG:  PROCESS( reset, CLK )
				BEGIN			
				if reset = '1' then
					BTCNT  <= (others => '0');						
				ELSIF rising_edge(CLK) THEN
					IF ena = '1' THEN
						IF  BTCNT_W_EN = '1' THEN
							BTCNT <= BTCNT_W;						
						ELSE	
							IF BTHOLD = '0' THEN
								BTCNT  <= BTCNT + 1;												
								IF Q_SEL = '1' THEN
									BTCNT  <= (others => '0');
								END IF;			
							END IF;	
						END IF;
					END IF;	
				END IF;	
				END PROCESS;			
-- BT FLAG	
	BT_FLAG:    PROCESS(reset, clock, Q_SEL )
				BEGIN			
				if reset = '1' then
					BT_INT <= '0';					
				ELSIF rising_edge(clock) THEN		
					IF BTHOLD = '0' THEN
						BT_INT <= '0';						
						IF Q_SEL = '1' THEN
							BT_INT <= '1';								
						END IF;							
					END IF;	
				END IF;	
				END PROCESS;				
				
-----------------------------------------------------------------------------		
-- BTCCR0 Register	
	PORT_BTCCR0:GPIO_REG
		GENERIC MAP ( N => 32 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,		
					CS			=>	CS(2),
					A0			=>  NOT A0 AND NOT A1,					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT    =>  BTCCR0_R,							
					DATA_REG 	=>  BTCCR0_W );

	BTCCR0_RST: PROCESS( reset, clock )
				BEGIN			
				if reset = '1' then
					BTCCR0 <= X"00000000";
				ELSIF rising_edge(clock) THEN	
					IF BTCCR0_W_EN = '1' THEN
						BTCCR0 <= BTCCR0_W;						
					END IF;	
				END IF;	
				END PROCESS;

	BTCCR0_W_EN <= CS(2) AND (NOT A0 AND NOT A1) AND MemWrite;
	BTCCR0_R_EN <= CS(2) AND (NOT A0 AND NOT A1) AND MemRead;	
	BTCCR0_R    <= BTCCR0 WHEN (BTCCR0_R_EN = '1') ELSE (others => '0');

-- BTCCR1 Register
	PORT_BTCCR1:GPIO_REG
		GENERIC MAP ( N => 32 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,		
					CS			=>	CS(3),
					A0			=>  NOT A0 AND NOT A1,					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT    =>  BTCCR1_R,						
					DATA_REG 	=>  BTCCR1_W );	
					
	BTCCR1_RST: PROCESS( reset , clock )
				BEGIN			
				if reset = '1' then
					BTCCR1 <= X"00000000";	
				ELSIF rising_edge(clock) THEN	
					IF BTCCR1_W_EN = '1' THEN
						BTCCR1   <= BTCCR1_W;	
					END IF;
				END IF;	
				END PROCESS;
				
	BTCCR1_W_EN <= CS(3) AND (NOT A0 AND NOT A1) AND MemWrite;
	BTCCR1_R_EN <= CS(3) AND (NOT A0 AND NOT A1) AND MemRead;	
	BTCCR1_R    <= BTCCR1 WHEN (BTCCR1_R_EN = '1') ELSE (others => '0');
	
END structure;