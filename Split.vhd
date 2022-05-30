library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity split is
	generic(	
		WIDTH_IN: integer :=128
	);
	port(	UIc	 : in unsigned(4*WIDTH_IN-1 downto 0); 
		SUPI_en	 : out unsigned(WIDTH_IN-1 downto 0); 
		R1_en	 : out unsigned(WIDTH_IN-1 downto 0); 
		R2_en	 : out unsigned(WIDTH_IN-1 downto 0); 
		IDSN_en	 : out unsigned(WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of split is 

begin
	
	SUPI_en	 <=	UIc(4*WIDTH_IN-1 downto 3*WIDTH_IN);
	R1_en	 <=	UIc(3*WIDTH_IN-1 downto 2*WIDTH_IN);
	R2_en	 <=	UIc(2*WIDTH_IN-1 downto WIDTH_IN);
	IDSN_en  <=	UIc(WIDTH_IN-1 downto 0);
	
end behavior;
