LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY HAZARD IS
	PORT(
        rs_ID,rt_ID, des_EX,des_MEM	    : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		MemRead_EX, MemRead_MEM         : IN    STD_LOGIC;
		MemRead_WB        				: IN    STD_LOGIC;
		MemWrite_EX       				: IN    STD_LOGIC;
		RegWrite_EX, RegWrite_MEM		: IN    STD_LOGIC;
		Branch 							: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );		
        Taken                   		: IN    STD_LOGIC;
		jal,jr,jmp						: IN 	STD_LOGIC;		
		IF_ID_ctl_flush					: OUT 	STD_LOGIC;			
		ID_EX_ctl_flush					: OUT 	STD_LOGIC;	
		PCstall							: OUT 	STD_LOGIC;
		IF_ID_stall						: OUT 	STD_LOGIC  );
END HAZARD;

ARCHITECTURE structure OF HAZARD IS
BEGIN 
		-- PCstall
PCstall 		<= '1'  when (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX = '1')   or 
							 (rt_ID = des_EX  and rt_ID /= "00000" and MemRead_EX = '1')   or 
							 (rs_ID = des_EX  and rs_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
					         (rt_ID = des_EX  and rt_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
							 (rs_ID = des_MEM and rs_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
							 (rt_ID = des_MEM and rt_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
							 (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX   = '1' and jr  = '1' ) or 
							 (rs_ID = des_MEM and rs_ID /= "00000" and MemRead_MEM  = '1' and jr  = '1' ) or
							 (rs_ID  = "11011" and MemWrite_EX  = '1' and jr  = '1' ) or
							 (MemRead_WB  = '1' and jal = '1')							 
							 
						ELSE '0';
						
		--  IF/ID Stall
IF_ID_stall 	<= '1'  when (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX = '1')   or 
							 (rt_ID = des_EX  and rt_ID /= "00000" and MemRead_EX = '1')   or 
							 (rs_ID = des_EX  and rs_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
					         (rt_ID = des_EX  and rt_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
							 (rs_ID = des_MEM and rs_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
							 (rt_ID = des_MEM and rt_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
							 (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX   = '1' and jr  = '1' ) or 
							 (rs_ID = des_MEM and rs_ID /= "00000" and MemRead_MEM  = '1' and jr  = '1' ) or
							 (rs_ID  = "11011" and MemWrite_EX  = '1' and jr  = '1' ) or
							 (MemRead_WB  = '1' and jal = '1')
						ELSE '0';	
						
		--  Flush ID/EX IR
ID_EX_ctl_flush <= '1'  when (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX = '1')   or 
							 (rt_ID = des_EX  and rt_ID /= "00000" and MemRead_EX = '1')   or 
							 (rs_ID = des_EX  and rs_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
					         (rt_ID = des_EX  and rt_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
							 (rs_ID = des_MEM and rs_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
							 (rt_ID = des_MEM and rt_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
							 (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX   = '1' and jr  = '1' ) or 
							 (rs_ID = des_MEM and rs_ID /= "00000" and MemRead_MEM  = '1' and jr  = '1' ) or
							 (rs_ID  = "11011" and MemWrite_EX  = '1' and jr  = '1' ) or
							 (MemRead_WB  = '1' and jal = '1')
						ELSE '0';	
						
		--  Flush IF/ID IR
IF_ID_ctl_flush <= '1'  when  jmp = '1' or jal = '1' or 
							 ( jr = '1'    and NOT ( (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX   = '1')   or 
													 (rt_ID = des_EX  and rt_ID /= "00000" and MemRead_EX   = '1')   or 
													 (rs_ID = des_EX  and rs_ID /= "00000" and RegWrite_EX  = '1' and Branch /= "00")  or
													 (rt_ID = des_EX  and rt_ID /= "00000" and RegWrite_EX  = '1' and Branch /= "00")  or
													 (rs_ID = des_MEM and rs_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
													 (rt_ID = des_MEM and rt_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
													 (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX   = '1' and jr  = '1' ) or 
													 (rs_ID = des_MEM and rs_ID /= "00000" and MemRead_MEM  = '1' and jr  = '1' ) or
													 (rs_ID  = "11011" and MemWrite_EX  = '1' and jr  = '1' ) or
													 (MemRead_WB  = '1' and jal = '1') ) )
													 
						 or  ( Taken = '1' and NOT ( (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX = '1')   or 
													 (rt_ID = des_EX  and rt_ID /= "00000" and MemRead_EX = '1')   or 
													 (rs_ID = des_EX  and rs_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
													 (rt_ID = des_EX  and rt_ID /= "00000" and RegWrite_EX = '1'  and Branch /= "00")  or
													 (rs_ID = des_MEM and rs_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
													 (rt_ID = des_MEM and rt_ID /= "00000" and RegWrite_MEM = '1' and Branch /= "00")  or 
													 (rs_ID = des_EX  and rs_ID /= "00000" and MemRead_EX   = '1' and jr  = '1' ) or 
													 (rs_ID = des_MEM and rs_ID /= "00000" and MemRead_MEM  = '1' and jr  = '1' ) or
													 (rs_ID  = "11011" and MemWrite_EX  = '1' and jr  = '1' ) or
													 (MemRead_WB  = '1' and jal = '1') ) )
						ELSE '0';
END structure;

