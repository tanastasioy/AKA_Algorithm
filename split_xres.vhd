

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity split_xres is	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(2*WIDTH_IN-1 downto 0); 
		out1 : out unsigned(WIDTH_IN-1 downto 0);
		out2 : out unsigned(WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of split_xres is 

begin
	out1	<=	in_1(WIDTH_IN-1 downto 0);
	out2	<=	in_1(2*WIDTH_IN-1 downto WIDTH_IN);

	
end;
