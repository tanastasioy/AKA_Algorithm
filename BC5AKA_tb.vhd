library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BC5GAKA_tb is
end entity;

architecture test of BC5GAKA_tb is

component BC5GAKA is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   		:	in  unsigned(WIDTH_IN-1 downto 0);   
		IDSN 		:	in  unsigned(WIDTH_IN-1 downto 0);
		auth_suc	:	out std_logic;
		req_fail	:	out std_logic;
		res_fail	:	out std_logic;
		mac_fail	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

CONSTANT WIDTH_IN 	: integer := 128;

CONSTANT clk_period : time := 1 ns; 

Signal R1_in 		: unsigned(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in  	: unsigned(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');

Signal clk 			: std_logic := '0';
Signal auth_suc 	: std_logic := '0';
Signal req_fail 	: std_logic := '0';
Signal mac_fail 	: std_logic := '0';
Signal res_fail 	: std_logic := '0';
Signal reset 		: std_logic := '0';

Begin
	AKA: BC5GAKA 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				R1			=>	R1_in,
				IDSN		=>	IDSN_in,
				auth_suc	=>	auth_suc,
				req_fail	=>	req_fail,
				res_fail	=>	res_fail,
				mac_fail	=>	mac_fail,
				clk			=>	clk,
				reset		=>	reset	
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
	R1_in	<= "01100001111100111010101010111011000011000001010000011100001100011010111000000000101010001110011101110101011011100110101010110101";
	IDSN_in	<= "01110110011111110110101111010101111110101100000001110011100010100000010010111111001010111011010010010011010110100101011100111101";
	wait for 8513 * clk_period;

	wait;

end process;
end;