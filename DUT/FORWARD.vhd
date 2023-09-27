LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY FORWARD IS

	PORT(
        rd_MEM, rd_WB, rs_EX, rt_EX  	 : IN  STD_LOGIC_VECTOR( 4 DOWNTO 0 );		
		RegWrite_EX_MEM, RegWrite_MEM_WB : IN  STD_LOGIC;	
        forwardA_EX, forwardB_EX         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );
END FORWARD;

ARCHITECTURE structure OF FORWARD IS

BEGIN 

forwardA_EX <=  "01" when (rs_EX /="00000" and rs_EX = rd_MEM and RegWrite_EX_MEM = '1')  else  
				"10" when (rs_EX /="00000" and rs_EX = rd_WB  and RegWrite_MEM_WB = '1') 
				and not   (rs_EX /="00000" and rs_EX = rd_MEM and RegWrite_EX_MEM = '1')  else	
				"00";

forwardB_EX <=  "01" when (rt_EX /="00000" and rt_EX = rd_MEM and RegWrite_EX_MEM = '1')  else  
				"10" when (rt_EX /="00000" and rt_EX = rd_WB  and RegWrite_MEM_WB = '1') 
				and not   (rt_EX /="00000" and rt_EX = rd_MEM and RegWrite_EX_MEM = '1')  else	
				"00";						
					
END structure;
