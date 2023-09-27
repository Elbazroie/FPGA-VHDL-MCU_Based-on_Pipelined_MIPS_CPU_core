				-- INTERRUPT CONTROLLER
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY INTERRUPT IS
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
END INTERRUPT;

ARCHITECTURE structure OF INTERRUPT IS
------------------------------ Components ------------------------------------------
	COMPONENT GPIO_REG IS
	   GENERIC ( N : INTEGER );
	   PORT( 
		clock		: IN    STD_LOGIC;  	   
	    DATA_IN 	: INOUT STD_LOGIC_VECTOR( 31  DOWNTO 0 );
		CS			: IN 	STD_LOGIC;
		A0			: IN 	STD_LOGIC;
		MemWrite 	: IN	STD_LOGIC;
		MemRead		: IN	STD_LOGIC;		
		DATA_OUT    : IN	STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); 		
		DATA_REG 	: INOUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ) 
		);
	END COMPONENT;
	
------------------------------ Signals --------------------------------------------	
	SIGNAL PEND 			  : STD_LOGIC_VECTOR( 5  DOWNTO 2 );
	SIGNAL PRIORITY 	      : STD_LOGIC_VECTOR( 5  DOWNTO 2 );
	SIGNAL NMI_IRQ, NMI_CLR	  : STD_LOGIC;	
	SIGNAL IE, IE_W, IE_R	  : STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL IE_W_EN, IE_R_EN	  : STD_LOGIC;
	SIGNAL IRQ	 	  		  : STD_LOGIC_VECTOR( 5  DOWNTO 2 );
	SIGNAL IRQ_CLR	 	  	  : STD_LOGIC_VECTOR( 5  DOWNTO 2 );	
	SIGNAL IFG, IFG_W, IFG_R  : STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL IFG_W_EN, IFG_R_EN : STD_LOGIC;	
	SIGNAL ITR, ITR_W, ITR_R  : STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL ITR_W_EN, ITR_R_EN : STD_LOGIC;	
	ALIAS  BT_INT   		  : STD_LOGIC IS INT_SRC(2);	
	ALIAS  KEY		   		  : STD_LOGIC_VECTOR( 2  DOWNTO 0 ) IS INT_SRC(5 DOWNTO 3);		
	
	SIGNAL reset_RE, reset_TR : STD_LOGIC;	
	SIGNAL INTA_RE, INTA_TR   : STD_LOGIC;		
	SIGNAL BT_RE, BT_TR		  : STD_LOGIC;	
	SIGNAL KEY_RE, KEY_TR	  : STD_LOGIC_VECTOR( 2  DOWNTO 0 );	
	SIGNAL IFG_FE, IFG_TR	  : STD_LOGIC_VECTOR( 5  DOWNTO 3 );		
BEGIN    
-- Interrupt pending
INT_GEN:	FOR i in 2 to 5 GENERATE 
				PEND(i) <= IRQ(i) AND IE(i);
			END GENERATE;
			
--Interrupt Request line
	INTR <= '1' WHEN ( ( IFG(0) = '1' OR IFG(1) = '1' OR IFG(2) = '1' OR IFG(3) = '1' OR
					     IFG(4) = '1' OR IFG(5) = '1' OR IFG(6) = '1' OR IFG(7) = '1' ) AND GIE = '1' ) OR NMI_IRQ = '1' ELSE '0';
	NMI  	<= Reset_RE;
	GPO_RST <= Reset_RE;
---------------------------- IRQ FLIP FLOPS --------------------------------
--NMI IRQ Generate
IRQ_NMI :  	PROCESS ( clock, reset_RE, INTA_RE )
			BEGIN								
			IF INTA_RE = '1' THEN
				if PRIORITY <= "0000" THEN			
					NMI_IRQ <= '0';	
				END IF;
			ELSIF rising_edge(clock) THEN
				if reset_RE = '1' THEN					
				NMI_IRQ <= '1';		
				END IF;	
			END IF;
			END PROCESS;		
				
--Basic Timer IRQ Generate
IRQ_BT :  	PROCESS (  INTA_RE, PRIORITY(2), Reset_RE, BT_RE )
			BEGIN								
			IF (INTA_RE = '1' AND PRIORITY(2) = '1') OR Reset_RE = '1' THEN
				IRQ(2) <= '0';													
			ELSIF BT_RE = '1' THEN
				IRQ(2) <= '1';				
			END IF;
			END PROCESS;		
				
--KEY0 IRQ Generate
IRQ_KEY0 :  PROCESS ( Reset_RE, KEY_RE(0), IFG_FE(3) )
			BEGIN				
			IF IFG_FE(3) = '1' OR Reset_RE = '1' THEN
				IRQ(3) <= '0';						
			ELSIF KEY_RE(0) = '1' THEN
				IRQ(3) <= '1';
			END IF;
			END PROCESS;			
								
--KEY1 IRQ Generate			
IRQ_KEY1 :  PROCESS ( Reset_RE, KEY_RE(1), IFG_FE(4) )
			BEGIN				
			IF IFG_FE(4) = '1' OR Reset_RE = '1' THEN
				IRQ(4) <= '0';						
			ELSIF KEY_RE(1) = '1' THEN
				IRQ(4) <= '1';
			END IF;
			END PROCESS;			
				
--KEY2 IRQ Generate			
IRQ_KEY2 :  PROCESS ( Reset_RE, KEY_RE(2), IFG_FE(5) )
			BEGIN				
			IF IFG_FE(5) = '1' OR Reset_RE = '1' THEN
				IRQ(5) <= '0';						
			ELSIF KEY_RE(2) = '1' THEN
				IRQ(5) <= '1';
			END IF;
			END PROCESS;			

----------------------- D-FF for Rising edge Detection -------------------------------
-- RST rising edge
	RST_RE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if Reset_RE = '0' then
		  reset_TR <= reset;		  			-- Delay input by 1 clock
		  reset_RE <= reset and (not reset_TR);	-- Detect rising edge
		else 
		  reset_RE <= '0';
		end if;
	  end if;
	end process;	
-- INTA rising edge
	INTA_RE_DETECT : process (clock)
	begin
	  if falling_edge(clock) then
		if Reset_RE = '0' then
		  INTA_TR <= INTA;		  			-- Delay input by 1 clock
		  INTA_RE <= INTA and (not INTA_TR);	-- Detect rising edge
		else 
		  INTA_RE <= '0';
		end if;
	  end if;
	end process;
-- BT flag rising edge
	BT_RE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if BT_RE = '0' then
		  BT_TR <= BT_INT;		  			-- Delay input by 1 clock
		  BT_RE <= BT_INT and (not BT_TR);	-- Detect rising edge
		else 
		  BT_RE <= '0';
		end if;
	  end if;
	end process;	
-- KEY0 rising edge
	KEY0_RE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if KEY_RE(0) = '0' then
		  KEY_TR(0) <= KEY(0);		  			-- Delay input by 1 clock
		  KEY_RE(0) <= KEY(0) and (not KEY_TR(0));	-- Detect rising edge	  
		else 
		  KEY_RE(0) <= '0';
		end if;
	  end if;
	end process;	
-- KEY1 rising edge
	KEY1_RE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if KEY_RE(1) = '0' then
		  KEY_TR(1) <= KEY(1);		  			-- Delay input by 1 clock
		  KEY_RE(1) <= KEY(1) and (not KEY_TR(1));	-- Detect rising edge	  
		else 
		  KEY_RE(1) <= '0';
		end if;
	  end if;
	end process;
-- KEY2 rising edge
	KEY2_RE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if KEY_RE(2) = '0' then
		  KEY_TR(2) <= KEY(2);		  			-- Delay input by 1 clock
		  KEY_RE(2) <= KEY(2) and (not KEY_TR(2));	-- Detect rising edge	  
		else 
		  KEY_RE(2) <= '0';
		end if;
	  end if;
	end process;	
-- KEY0 Flag falling edge
	IFG3_FE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if IFG_FE(3) = '0' then
		  IFG_TR(3) <= not IFG(3);		  			-- Delay input by 1 clock
		  IFG_FE(3) <= not IFG(3) and (not IFG_TR(3));	-- Detect falling edge	  
		else 
		  IFG_FE(3) <= '0';
		end if;
	  end if;
	end process;	
-- KEY1 Flag falling edge
	IFG4_FE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if IFG_FE(4) = '0' then
		  IFG_TR(4) <= not IFG(4);		  			-- Delay input by 1 clock
		  IFG_FE(4) <= not IFG(4) and (not IFG_TR(4));	-- Detect falling edge	  
		else 
		  IFG_FE(4) <= '0';
		end if;
	  end if;
	end process;
-- KEY2 Flag falling edge
	IFG5_FE_DETECT : process (clock)
	begin
	  if rising_edge(clock) then
		if IFG_FE(5) = '0' then
		  IFG_TR(5) <= not IFG(5);		  			-- Delay input by 1 clock
		  IFG_FE(5) <= not IFG(5) and (not IFG_TR(5));	-- Detect falling edge	  
		else 
		  IFG_FE(5) <= '0';
		end if;
	  end if;
	end process;
	
---------------------------- INTERRUPT CONTROLLER REGISTERS --------------------------------
-- IE Register
	PORT_IE		: GPIO_REG
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,
					CS			=>	CS,
					A0			=>  (NOT A0 AND NOT A1),					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  IE_R,
					DATA_REG	=>  IE_W );
					
	IE_REG:		PROCESS( Reset_RE , clock )
				BEGIN			
				if Reset_RE = '1' then
					IE <= X"00";	
				ELSIF rising_edge(clock) THEN	
					IF IE_W_EN = '1' THEN
						IE <= IE_W;	
					END IF;
				END IF;	
				END PROCESS;
				
	IE_R 	<= IE WHEN (IE_R_EN = '1') ELSE (others => '0');
	IE_W_EN <= CS AND (NOT A0 AND NOT A1) AND MemWrite;
	IE_R_EN <= CS AND (NOT A0 AND NOT A1) AND MemRead;					
					
-- IFG Register
	PORT_IFG	: GPIO_REG
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,
					CS			=>	CS,
					A0			=>  (A0 AND NOT A1),					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead,
					DATA_OUT 	=>  IFG_R,
					DATA_REG 	=>  IFG_W );	

	IFG_REG:	PROCESS( Reset_RE , clock )
				BEGIN			
				if Reset_RE = '1' then
					IFG <= X"00";	
				ELSIF falling_edge(clock) THEN	-- FALLING TO AVOID GIE - FLAG ISSUE When jr $k1
					IF IFG_W_EN = '1' THEN
						IFG <= IFG_W;	
					ELSE
						IFG <= "00" & PEND & "00";					
					END IF;
				END IF;	
				END PROCESS;
				
	IFG_R 	 <= IFG WHEN (IFG_R_EN = '1') ELSE (others => '0');
	IFG_W_EN <= CS AND (A0 AND NOT A1) AND MemWrite;
	IFG_R_EN <= CS AND (A0 AND NOT A1) AND MemRead;				
					
-- TYPE Register
	PORT_TYPE:  GPIO_REG
		GENERIC MAP ( N => 8 )
		PORT MAP (	clock 		=>	clock,
					DATA_IN 	=>	data,
					CS			=>	CS,
					A0			=>  (NOT A0 AND A1),					
					MemWrite 	=>	MemWrite,
					MemRead		=>  MemRead OR (NOT INTA),
					DATA_OUT 	=>  ITR_R,
					DATA_REG 	=>  ITR_W );
				
	ITR_R 	 <= ITR WHEN (ITR_R_EN = '1') ELSE (others => '0');
	ITR_W_EN <= CS AND (NOT A0 AND A1) AND MemWrite;
	ITR_R_EN <= CS AND (NOT A0 AND A1) AND MemRead;				
					
		-- PRIORITY ENCODER	 --
	ITR_REG :  PROCESS ( clock )
				BEGIN
				IF rising_edge(clock) THEN	
					IF ITR_W_EN = '1' THEN
						ITR <= ITR_W;	
					ELSE	
						IF IFG(2) = '1' THEN
							ITR	<=  X"10";
							PRIORITY <= "0001";
						ELSIF IFG(3) = '1' THEN
							ITR	<=  X"14";
							PRIORITY <= "0010";
						ELSIF IFG(4) = '1' THEN
							ITR	<=  X"18";	
							PRIORITY <= "0100";							
						ELSIF IFG(5) = '1' THEN
							ITR	<=  X"1C";
							PRIORITY <= "1000";						
						ELSE
							ITR	<=  X"00";
							PRIORITY <= "0000";
						END IF;
					END IF;
				END IF;
				END PROCESS;								
END structure;