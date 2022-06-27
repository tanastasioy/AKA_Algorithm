library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity req_id_sha_tb is
end entity;

architecture test of req_id_sha_tb is

component req_id_sha is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	SUCI  	 :	in std_logic_vector(5*WIDTH_IN-1 downto 0);
		R1   	 :	in std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	 :	in std_logic_vector(WIDTH_IN-1 downto 0);
		IDHN	 :	in std_logic_vector(WIDTH_IN-1 downto 0);
		req_id	 :	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin      :  out std_logic;
		start    :  in  std_logic;
		clk	 :	in std_logic;
		reset	 :	in std_logic		
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal SUCI_in : std_logic_vector(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal R1_in : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal IDHN_in : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Signal req_id_out : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal clk : std_logic := '0';
Signal reset_t,start,fin : std_logic := '0';

Begin

	reqid: req_id_sha 
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	SUCI	=>	SUCI_in,
				R1	=>	R1_in,
				IDSN	=>	IDSN_in,
				IDHN	=>	IDHN_in,
				req_id	=>	req_id_out,
				start => start,
				fin => fin,
				clk	=>	clk,
				reset	=>	reset_t	
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

	reset_t <= '1';
	wait for 1 * clk_period;
	reset_t <= '0';
	wait for 1 * clk_period;
	start<='1';
	SUCI_in <= "1111100110001110111111111000100010001010001100110110010000101011000100000000111100111100101100111000111100100001011010101010101001011111100000110101101001100110000011110110000100000000100010111100111100010111000000000110001000110100000010110111101110101000100010111000111011100010101010101000110101111110100001111001010000110001001110111100001001100111001100110110100101111100111110010000110110001101100111110011101011001011010111101100001001011111000110011010011110000011100111011011110000011110011110111011011101101000010110000010110010100000101101101010110110010010111011010001101110100101011111101011100100101101001100000000001011101000";
	R1_in <= "01100001111100111010101010111011000011000001010000011100001100011010111000000000101010001110011101110101011011100110101010110101";
	IDSN_in <= "01110110011111110110101111010101111110101100000001110011100010100000010010111111001010111011010010010011010110100101011100111101";
	IDHN_in <= "11111001100011101111111110001000100010100011001101100100001010110001000000001111001111001011001110001111001000010110101010101010";
	wait for 100 * clk_period;

	wait;

end process;

end;