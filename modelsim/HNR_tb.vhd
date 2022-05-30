library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity aes_enc_tb is
end aes_enc_tb;

architecture behavioral of aes_enc_tb is

component aes_enc is
	port(
		clk : in std_logic;
		rst : in std_logic;
		key : in std_logic_vector(127 downto 0);
		plaintext : in std_logic_vector(127 downto 0);
		ciphertext : out std_logic_vector(127 downto 0)
	);
end component;
	
CONSTANT WIDTH_IN : integer := 128;

Signal R2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R3 	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal HN_R 	: std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

CONSTANT clk_period : time := 1 ns;
Signal clk : std_logic := '0';
Signal reset : std_logic := '0';
	
Begin

	phasehnr: aes_enc
		port map(	
				ciphertext=> HN_R,
				key=>	std_logic_vector(R2),
				plaintext	=>	std_logic_vector(R3),
				clk	=>	clk,
				rst	=>	reset	
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
	
	R2 <= "01000001111111111010101010111011000000000010100000111000000000110101110000000001010100000000111111101010110111111101010101010101";
	R3 <= "01011101100100111010101010111011011011000001011100011100001101100010111000000000101010001110100010010101011011100110111110000101";
wait for 8513 * clk_period;

	wait;

end process;

end;
