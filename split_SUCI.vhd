library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity split_suci is
	generic(	
		WIDTH_IN: integer :=128
	);
	port(	SUCI	 : in unsigned(5*WIDTH_IN-1 downto 0); 
		IDHN	 : out unsigned(WIDTH_IN-1 downto 0); 
		UIc	 : out unsigned(4*WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of split_suci is 

begin
	
	IDHN	 <=	SUCI(5*WIDTH_IN-1 downto 4*WIDTH_IN);
	UIc	 <=	SUCI(4*WIDTH_IN-1 downto 0);
	
end;
