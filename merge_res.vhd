
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity merge_res is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(2*WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(3*WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(4*WIDTH_IN-1 downto 0); 
		merged_out1 : out unsigned(8*WIDTH_IN-1 downto 0);
		merged_out2 : out unsigned(8*WIDTH_IN-1 downto 0)
	);
end entity;

architecture behavior of merge_res is

component split_xres is	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(2*WIDTH_IN-1 downto 0); 
		out1 : out unsigned(WIDTH_IN-1 downto 0);
		out2 : out unsigned(WIDTH_IN-1 downto 0)
	);
end component;

signal out_1: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal out_2: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

begin
	spl_xres: split_xres
		port map (	in_1  =>  in_1,
				out1 =>  out_1,
				out2 =>  out_2
			);
	merged_out1 <= out_1 & in_2 & in_3;
	merged_out2 <= out_2 & in_2 & in_3;
	
end behavior;
