library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase1_1_tb is
end entity;

architecture test of phase1_1_tb is

component phase1_1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		SUCI_in	 :	in std_logic_vector(5*WIDTH_IN-1 downto 0);
		SUCI_out :	out std_logic_vector(5*WIDTH_IN-1 downto 0);
		IDSN 	 :	out std_logic_vector(WIDTH_IN-1 downto 0);
		req_id   :	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin      :  out std_logic;
		start    :  in  std_logic;
		clk	 	 :	in std_logic;
		reset	 :	in std_logic		
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal SUCI_in : std_logic_vector(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal SUCI_out : std_logic_vector(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Signal req_id_out :	std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal clk : std_logic := '0';
Signal reset : std_logic := '0';
Signal start,fin : std_logic := '0';

Begin

	phase: phase1_1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
				SUCI_in	=>	SUCI_in,
				SUCI_out=> SUCI_out,
				IDSN=>	IDSN_in,
				req_id	=>	req_id_out,
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
	SUCI_in <= X"F98EFF888A33642B100F3CB38F216AAA5F835A660F61008BCF170062340B7BA88B8EE2AA8D7E8794313BC26733697CF90D8D9F3ACB5EC25F19A7839DBC1E7BB768582CA0B6AD92ED1BA57EB92D3002E8";
	start <= '1'; 
	wait for 800ns;


end process;

end;