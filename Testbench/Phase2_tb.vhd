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
		SUCI		:	in  std_logic_vector(5*WIDTH_IN-1 downto 0);
		req_id  	:	in  std_logic_vector(2*WIDTH_IN-1 downto 0);
		IDSN		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		HN_R		:	out std_logic_vector(WIDTH_IN-1 downto 0);
		req_id_o	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		hxRES		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		xMAC		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		EK			:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		res_id		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin         :   out std_logic;
		start       :   in  std_logic;
		req_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal SUCI_in	 : std_logic_vector(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in	 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal HN_R	 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal req_id : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal req_id_o : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal res_id : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal hxRES : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal EK : std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xMAC :  std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal clk : std_logic := '0';
Signal abort : std_logic := '0';
Signal reset,start,fin : std_logic := '0';

Begin
	ph2: phase2 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				HN_R	=>	HN_R,
				IDSN	=>	IDSN_in,
				hxRES	=>	hxRES,
				xMAC	=>	xMAC,
				EK	=>	EK,
				req_id	=>	req_id,
				req_id_o	=>	req_id_o,
				res_id	=>	res_id,
				SUCI	=>	SUCI_in,
				req_abort	=>	abort,
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
	wait for 20 * clk_period;
	reset <= '0';
	wait for 1 * clk_period;
	start <='1';
	req_id	<= X"fb5179d3f418a27cf8a5e7e410f25f95c40355da78e68a9cb4553461deb21bba";
	SUCI_in <= X"F98EFF888A33642B100F3CB38F216AAA5F835A660F61008BCF170062340B7BA88B8EE2AA8D7E8794313BC26733697CF90D8D9F3ACB5EC25F19A7839DBC1E7BB768582CA0B6AD92ED1BA57EB92D3002E8";
	IDSN_in <= X"767F6BD5FAC0738A04BF2BB4935A573D";
	wait for 100 us;

end process;
end;
