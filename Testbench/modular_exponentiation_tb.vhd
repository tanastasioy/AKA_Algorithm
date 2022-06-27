library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity modular_exponentiation_tb is
end entity;

architecture test of modular_exponentiation_tb is

component modular_exponentiation is

	generic(WIDTH_IN : integer := 128
	);
	port(	N :	  in unsigned(WIDTH_IN-1 downto 0); --Number
		--Exp :	  in unsigned(WIDTH_IN-1 downto 0); --Exponent
		--M :	  in unsigned(WIDTH_IN-1 downto 0); --Modulus
		enc_dec:  in std_logic;
		finish  :  out std_logic;
		start:    in  std_logic;
		clk :	  in std_logic;
		reset :	  in std_logic;
		C : 	  out unsigned(WIDTH_IN-1 downto 0) --Output
	);
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal M_in : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal N_in,N_in1,NTEST1,NTEST2,NTEST3,NTEST4 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal Exp_in : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal latch_in : std_logic := '0';

Signal clk : std_logic := '0';
Signal reset_t : std_logic := '0';
Signal enc_dec_in : std_logic := '1';
Signal f1,f2,f3,f4 : std_logic := '0';
Signal starte,startd : std_logic := '0';

Signal C_out1,C_out2,C_out3,C_out4,COUTTEST1,COUTTEST2,COUTTEST3,COUTTEST4 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');


Begin
-- device under test
dut: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	N_in,
					--Exp 	=> 	Exp_in,
					--M 	=> 	M_in,
					enc_dec =>      '1',
					finish => f1,
					start => starte,
					clk	=> 	clk,
					reset 	=>	reset_t,
					C	=>	C_out1
				);

dut1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	N_in1,
					--Exp 	=> 	Exp_in,
					--M 	=> 	M_in,
					enc_dec =>      '0',
					finish => f2,
					start=> startd,
					clk	=> 	clk,
					reset 	=>	reset_t,
					C	=>	C_out2
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
	NTEST1 <= X"9ce5f9bffe3a7f2e4aa3119156eed972"; 
	wait for 1 * clk_period;
	N_in <= "0" & NTEST1(126 downto 0); starte<='1';
	wait for 5 us; 
	N_in1 <= C_out1; startd<='1';
	wait for 30 us; startd<='0';starte<='0';
	COUTTEST1<= NTEST1(127 downto 127) & C_out2(126 DOWNTO 0);
	wait for 1us;
	reset_t <= '1';
	wait for 1 * clk_period;
	reset_t <= '0';
	wait for 1 * clk_period;
	NTEST2 <= X"ace5f9bffe3a7f2e4aa3119156eed972";	
	wait for 1 * clk_period;
	N_in <= "0" & NTEST2(126 downto 0); starte<='1';
	wait for 5 us;
	N_in1 <= C_out1; startd<='1';
	wait for 30 us; startd<='0';starte<='0';	
	COUTTEST2<= NTEST2(127 downto 127) & C_out2(126 DOWNTO 0);	
	wait for 1us;
    reset_t <= '1';
	wait for 1 * clk_period;
	reset_t <= '0';
	wait for 1 * clk_period;
	NTEST3 <= X"4897AC0667E5CBD185CD03C5AE862E27";
	wait for 1 * clk_period;
	N_in <= "0" & NTEST3(126 downto 0); starte<='1';
	wait for 5 us;
	N_in1 <= C_out1; startd<='1';
	wait for 30 us; startd<='0';starte<='0';
	COUTTEST3<= NTEST3(127 downto 127) & C_out2(126 DOWNTO 0);	
	wait for 1us;
    reset_t <= '1';
	wait for 1 * clk_period;
	reset_t <= '0';
	wait for 1 * clk_period;
	NTEST4 <= X"61F3AABB0C141C31AE00A8E7756E6AB5";
	wait for 1 * clk_period;
	N_in <= "0" & NTEST4(126 downto 0); starte<='1';
	wait for 5 us;
	N_in1 <= C_out1; startd<='1';
	wait for 30 us; startd<='0';starte<='0';
	COUTTEST4<= NTEST4(127 downto 127) & C_out2(126 DOWNTO 0);	
	wait for 1us;
	wait;
	
end process;
end;
