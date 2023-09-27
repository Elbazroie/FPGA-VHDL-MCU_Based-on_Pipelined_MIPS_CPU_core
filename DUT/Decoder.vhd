LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY Decoder IS
  PORT (  input 	  : IN   STD_LOGIC_VECTOR (3 DOWNTO 0);
		  output 	  : OUT  STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
END Decoder;

------------- complete the fmax Architecture code --------------
ARCHITECTURE struct OF Decoder IS 
	BEGIN
	-------------- HEX Decoder ---------------
	WITH input select
		output  <= "1000000" WHEN "0000", -- '0'
				   "1111001" WHEN "0001", -- '1'
				   "0100100" WHEN "0010", -- '2' 
				   "0110000" WHEN "0011", -- '3' 
				   "0011001" WHEN "0100", -- '4' 
				   "0010010" WHEN "0101", -- '5' 
				   "0000010" WHEN "0110", -- '6'
				   "1111000" WHEN "0111", -- '7'
				   "0000000" WHEN "1000", -- '8'
				   "0010000" WHEN "1001", -- '9'
				   "0001000" WHEN "1010", -- 'A'
				   "0000011" WHEN "1011", -- 'b'
				   "1000110" WHEN "1100", -- 'C'
				   "0100001" WHEN "1101", -- 'd' 
				   "0000110" WHEN "1110", -- 'E'
				   "0001110" WHEN "1111", -- 'F'
				   "0111111" WHEN others; -- '-'
END struct;