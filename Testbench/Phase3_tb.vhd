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
		Res			:	out std_logic_vector(2*WIDTH_IN-1 downto 0);  
		xMAC		:	in  std_logic_vector(2*WIDTH_IN-1 downto 0);
		HN_R		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		fin         :   out std_logic;
		start       :   in  std_logic;
		mac_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal HN_R	: std_logic_vector(WIDTH_IN-1 downto 0) ;
Signal Res 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal xMAC	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal clk 	: std_logic := '0';
Signal mac_abort 	: std_logic := '0';
Signal reset,start,fin 	: std_logic := '0';

Begin
	ph2: phase3 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				HN_R	=>	HN_R,
				Res	=>	Res,
				xMAC	=>	xMAC,
				mac_abort	=>	mac_abort,
				start   => start,
				fin     => fin,
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
	start<='1';
	HN_R	<= X"1C6C00006C3F24357201F8E77FB1BAD0";
	xMAC	<= X"19298e1ad74878633c37a5ba97ccfc19014c3f25cde5bab03f1bb35f85c8e437";
	wait for 8513 * clk_period;

	wait;

end process;
end;
