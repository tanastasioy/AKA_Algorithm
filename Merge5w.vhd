library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity merge5w is
	
	generic(WIDTH_IN: integer :=32
	);
	port(	in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(4*WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(5*WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of merge5w is 

begin
	
	merged_out <= in_1 & in_2;
	
end behavior;
