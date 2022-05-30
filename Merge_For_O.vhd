library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity merge3w is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(3*WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of merge3w is 

begin
	
	merged_out <= in_1 & in_2 & in_3;
	
end behavior;
