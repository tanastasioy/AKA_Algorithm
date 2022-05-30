library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sha_512_pkg.all;

entity phase1_1_tb is
end entity;

architecture test of phase1_1_tb is

component phase1_1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		SUCI_in	 :	in unsigned(5*WIDTH_IN-1 downto 0);
		SUCI_out :	out unsigned(5*WIDTH_IN-1 downto 0);
		IDSN 	 :	out unsigned(WIDTH_IN-1 downto 0);
		req_id   :	out unsigned(2*WIDTH_IN-1 downto 0);
		clk	 	 :	in std_logic;
		reset	 :	in std_logic		
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal SUCI_in : unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal SUCI_out : unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Signal req_id_out :	unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal clk : std_logic := '0';
Signal reset : std_logic := '0';

Begin

	phase: phase1_1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
				SUCI_in	=>	SUCI_in,
				SUCI_out=> SUCI_out,
				IDSN=>	IDSN_in,
				req_id	=>	req_id_out,
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
	
	SUCI_in <= "1111100110001110111111111000100010001010001100110110010000101011000100000000111100111100101100111000111100100001011010101010101001011111100000110101101001100110000011110110000100000000100010111100111100010111000000000110001000110100000010110111101110101000100010111000111011100010101010101000110101111110100001111001010000110001001110111100001001100111001100110110100101111100111110010000110110001101100111110011101011001011010111101100001001011111000110011010011110000011100111011011110000011110011110111011011101101000010110000010110010100000101101101010110110010010111011010001101110100101011111101011100100101101001100000000001011101000";
	wait for 8513 * clk_period;

	wait;

end process;

end;