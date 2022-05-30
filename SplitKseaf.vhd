
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity splitkseaf is
	generic(	
		WIDTH_IN: integer :=128
	);
	port(	input	 : in unsigned(3*WIDTH_IN-1 downto 0); 
		out1  : out unsigned(WIDTH_IN-1 downto 0); 
		out2	 : out unsigned(WIDTH_IN-1 downto 0); 
		out3	 : out unsigned(WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of splitkseaf is 

begin
	
	out1	 <=	input(WIDTH_IN-1 downto 0);
	out2	 <=	input(2*WIDTH_IN-1 downto WIDTH_IN);
	out3	 <=	input(3*WIDTH_IN-1 downto 2*WIDTH_IN);
	
end behavior;
