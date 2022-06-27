library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RSA_Dec_UIc_tb is
end entity;

architecture test of RSA_Dec_UIc_tb is

component RSA_Dec_UIc is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
	    UIc     :	in  std_logic_vector(4*WIDTH_IN-1 downto 0);
		R1  	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		R2   	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		SUPI 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		fin     :   out std_logic;
		start   :   in  std_logic;
		clk 	:	in  std_logic;
		reset 	:	in  std_logic		
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal IDSN_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R1_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R2_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal SUPI_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal UIc_in	 : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');

Signal clk : std_logic := '0';
Signal reset_t : std_logic := '0';
Signal start,fin : std_logic := '0';


Begin

RSA_Dec: RSA_Dec_UIc 
		generic map (WIDTH_IN => WIDTH_IN)
	port map(
			UIc	=>	UIc_in,
			R1	=>	R1_out,
			R2	=>	R2_out,
			IDSN	=>	IDSN_out,
			SUPI	=>	SUPI_out,
		    start   => start,
			fin     => fin,
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
	
	UIc_in <= "01011111100000110101101001100110000011110110000100000000100010111100111100010111000000000110001000110100000010110111101110101000100010111000111011100010101010101000110101111110100001111001010000110001001110111100001001100111001100110110100101111100111110010000110110001101100111110011101011001011010111101100001001011111000110011010011110000011100111011011110000011110011110111011011101101000010110000010110010100000101101101010110110010010111011010001101110100101011111101011100100101101001100000000001011101000";
	start <='1';
	wait for 8513 * clk_period;

	wait;

end process;
end;
