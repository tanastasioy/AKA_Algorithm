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
		R1_input   	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		IDSN_input 	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
        start_in    :   in  std_logic_vector(0 downto 0);
		auth_suc	:	out std_logic;
		req_fail	:	out std_logic;
		res_fail	:	out std_logic;
		mac_fail	:	out std_logic;
		complete    :   out std_logic;
		KSEAF_SUPI  :   out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

CONSTANT WIDTH_IN 	: integer := 128;

CONSTANT clk_period : time := 3.3333333333333 ns; 

Signal R1_in 		: std_logic_vector(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in  	: std_logic_vector(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');

Signal start		: std_logic_vector(0 downto 0) := "0";
Signal clk 			: std_logic := '0';
Signal auth_suc 	: std_logic := '0';
Signal req_fail 	: std_logic := '0';
Signal mac_fail 	: std_logic := '0';
Signal res_fail 	: std_logic := '0';
Signal reset 		: std_logic := '0';
Signal KSEAF_SUPI	: std_logic := '0';
Signal complete     : std_logic := '0';

Begin
	AKA: BC5GAKA 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				R1_input	=>	R1_in,
				IDSN_input	=>	IDSN_in,
				start_in       =>  start,
				auth_suc	=>	auth_suc,
				req_fail	=>	req_fail,
				res_fail	=>	res_fail,
				mac_fail	=>	mac_fail,
				complete    =>  complete,
				KSEAF_SUPI  => KSEAF_SUPI,
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
	start<="1";
	R1_in	<= X"A1F3A1010C141C31AE00A8E7756E6AB5";
	IDSN_in	<= X"F57F6BD2FAC0738A04B12BB4935A573D";
	wait until complete='1';
	wait for 50 us ;
	reset <= '1';	
	start<="0";
	wait for 1 us;
	reset <= '0';
	wait for 1 * clk_period;
	start<="1";
	R1_in	<= X"51A3BBF8AC141631AE29A8E7756E6AB5";
	IDSN_in	<= X"467F6BD5FAC1538A04B320B4935A573D";
	wait until complete='1';
    wait for 50 us ;
	reset <= '1';	
	start<="0";
	wait for 1 us;
	reset <= '0';
	wait for 1 * clk_period;
	start<="1";
	R1_in	<= X"65F3A32B0C141C31AE00A8E7756E6AB5";
	IDSN_in	<= X"1C6C060A6C3F24357201F8E77FB1BAD0";
	wait until complete='1';
	wait for 50 us ;
	reset <= '1';
	start<="0";
	wait for 1 us;
	reset <= '0';
	wait for 1 * clk_period;
	start<="1";
	R1_in	<= X"11F1A1A10C141C31AE19A8E7756E6A15";
	IDSN_in	<= X"757F61A2FAC3738A04312BB4935A5731";
	wait until complete='1';
	wait for 50 us ;
	reset <= '1';	
	start<="0";
	wait for 1 us;
	reset <= '0';
	wait for 1 * clk_period;
	start<="1";
	R1_in	<= X"81A181F81A891631AE9048E7456E6AB5";
	IDSN_in	<= X"467F3542F91A7395A42F2BC4935A5732";
	wait until complete='1';
    wait for 50 us ;
	reset <= '1';	
	start<="0";
	wait for 1 us;
	reset <= '0';
	wait for 1 * clk_period;
	start<="1";
	R1_in	<= X"D1A3B1F8AC141631AE21A8E7756E6AB5";
	IDSN_in	<= X"C67F6BD5F1C1138A04B320B4935A573D";
	wait until complete='1';
	wait for 50 us ;
	
	wait;
	
end process;
end;
