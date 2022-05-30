library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase2_tb is
end entity;

architecture test of phase2_tb is

component phase2 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(		
		--
		O 		:	out  unsigned(3*WIDTH_IN-1 downto 0);
		--
		SUCI		:	in  unsigned(5*WIDTH_IN-1 downto 0);
		req_id  	:	in  unsigned(2*WIDTH_IN-1 downto 0);
		IDSN		:	in  unsigned(WIDTH_IN-1 downto 0);
		HN_R		:	out unsigned(WIDTH_IN-1 downto 0);
		req_id_o	:	out unsigned(2*WIDTH_IN-1 downto 0);
		hxRES		:	out unsigned(2*WIDTH_IN-1 downto 0);
		xMAC		:	out unsigned(3*WIDTH_IN-1 downto 0);
		EK			:	out unsigned(4*WIDTH_IN-1 downto 0);
		res_id		:	out unsigned(2*WIDTH_IN-1 downto 0);
		req_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal SUCI_in	 : unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
--Signal R1_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal HN_R	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
--Signal SUPI_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
--Signal IDHN_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal req_id : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal req_id_o : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal res_id : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal O :  unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal RES :  unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal hxRES : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal EK : unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal xMAC :  unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');

Signal clk : std_logic := '0';
Signal abort : std_logic := '0';
Signal reset_t : std_logic := '0';

Begin
	ph2: phase2 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	--SUPI	=>	SUPI_out,
				--R1	=>	R1_out,
				HN_R	=>	HN_R,
				IDSN	=>	IDSN_in,
				--IDHN	=>	IDHN_out,
				O	=>	O,
				--RES	=>	RES,
				hxRES	=>	hxRES,
				xMAC	=>	xMAC,
				EK	=>	EK,
				req_id	=>	req_id,
				req_id_o	=>	req_id_o,
				res_id	=>	res_id,
				SUCI	=>	SUCI_in,
				req_abort	=>	abort,
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
	req_id	<= "0011110000010111110101010001010111001101001101111101101111001000010111010100101101100101011011011111011101110110110110100011101001111011010011001011111110010001101110110011010010101000100101000001011101000000000100001110001101011011110101010010101111010100";
	SUCI_in <= "1111100110001110111111111000100010001010001100110110010000101011000100000000111100111100101100111000111100100001011010101010101001011111100000110101101001100110000011110110000100000000100010111100111100010111000000000110001000110100000010110111101110101000100010111000111011100010101010101000110101111110100001111001010000110001001110111100001001100111001100110110100101111100111110010000110110001101100111110011101011001011010111101100001001011111000110011010011110000011100111011011110000011110011110111011011101101000010110000010110010100000101101101010110110010010111011010001101110100101011111101011100100101101001100000000001011101000";
	IDSN_in <= "01110110011111110110101111010101111110101100000001110011100010100000010010111111001010111011010010010011010110100101011100111101";
	wait for 8513 * clk_period;

	wait;

end process;
end;
