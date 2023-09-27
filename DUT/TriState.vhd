library ieee;
use ieee.std_logic_1164.all;
-----------------------------------------------------------------
ENTITY TriState is
	generic( N: integer; 
			 A: integer );
	port(   Dout: 	in 		std_logic_vector(A-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(N-1 downto 0);		
			IOpin: 	inout 	std_logic_vector(A-1 downto 0)
	);
end TriState;

architecture comb of TriState is
begin 

	Din 	<= IOpin(N-1 downto 0);
	IOpin	<= Dout when (en='1') else (others => 'Z');
	
end comb;

