
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity merge8w is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(WIDTH_IN-1 downto 0); 
		in_4 : in unsigned(5*WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(8*WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of merge8w is 

begin
	
	merged_out <= in_1 & in_2 & in_3 & in_4;
	
end behavior;
