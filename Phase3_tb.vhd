library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase3_tb is
end entity;

architecture test of phase3_tb is

component phase3 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		Res			:	out unsigned(2*WIDTH_IN-1 downto 0);  
		xMAC		:	in  unsigned(3*WIDTH_IN-1 downto 0);
		HN_R		:	in  unsigned(WIDTH_IN-1 downto 0);
		mac_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal HN_R	: unsigned(WIDTH_IN-1 downto 0) ;
Signal Res 	: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal xMAC	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal clk 	: std_logic := '0';
Signal mac_abort 	: std_logic := '0';
Signal reset 	: std_logic := '0';

Begin
	ph2: phase3 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				HN_R	=>	HN_R,
				Res	=>	Res,
				xMAC	=>	xMAC,
				mac_abort	=>	mac_abort,
				clk	=>	clk,
				reset	=>	reset	
			);
-- process for clock
clk_process : Process
Begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

stim_process: process
Begin

	reset <= '1';
	wait for 1 * clk_period;
	reset <= '0';
	wait for 1 * clk_period;
	HN_R	<= "00011100011011000000000000000000011011000011111100100100001101010111001000000001111110001110011101111111101100011011101011010000";
	xMAC	<= "001011011001110111100001001001100001111010100101100101001110001001111110111110111110100101000011101011111011001101110011000101010000000000000011001011100011000100101001011111011100010000000101011010001110001110001110101110001000101000000110000000101100100101010001110000000110010111010110010100111100101110001110110001111001101110110111011110111110001011010001001000110111100000010100";
	wait for 8513 * clk_period;

	wait;

end process;
end;
