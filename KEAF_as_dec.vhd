library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RSA_KEAF_dec is
	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK   	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		EK_AES	:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		remain  :	in std_logic_vector(2 downto 0);
		clk	    :	in std_logic;
		fin     :   out std_logic;
		start   :   in std_logic;
		reset	:	in std_logic	
	);
end RSA_KEAF_dec;

architecture Behavioral of RSA_KEAF_dec is

component modular_exponentiation is

	generic(WIDTH_IN : integer := 128
	);
	port(	N :	  in unsigned(WIDTH_IN-1 downto 0); --Number
		enc_dec:  in std_logic;
		finish:   out std_logic;
		start:    in std_logic;
		clk :	  in std_logic;
		reset :	  in std_logic;
		C : 	  out std_logic_vector(WIDTH_IN-1 downto 0) --Output
	);
end component;

CONSTANT clk_period : time := 1 ns;

Signal EKa : std_logic_vector(3*WIDTH_IN-1 downto 0) := (others => '0');
Signal EK_rsa0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal EK_rsa1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal EK_rsa2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');

Signal C_out0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal EK0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal EK1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal EK2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');

Signal f1,f2,f3,f4,finish: std_logic := '0';

begin

        EK_rsa0	 <=	EK(WIDTH_IN-1 downto 0);
        EK_rsa1	 <=	EK(2*WIDTH_IN-1 downto WIDTH_IN);
        EK_rsa2	 <=	EK(3*WIDTH_IN-1 downto 2*WIDTH_IN);
	
	dut0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	unsigned(EK_rsa0),
					enc_dec => '0',
					clk	=> 	clk,
					reset 	=>	reset,
				    start   =>  start,
					finish  =>  f1,
					C	=>	C_out0 --EK0
				);
    EK0 <= remain(0) & C_out0(126 downto 0);    
	dut1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	unsigned(EK_rsa1),
					enc_dec => '0',
					clk	=> 	clk,
					reset 	=>	reset,
				    start   =>  start,
					finish  =>  f2,
					C	=>	C_out1 --EK1
				);
    EK1 <= remain(1) & C_out1(126 downto 0);    
	dut2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	unsigned(EK_rsa2),
					enc_dec =>	'0',
					clk	=> 	clk,
					reset 	=>	reset,
				    start   =>  start,
					finish  =>  f3,
					C	=>	 C_out2 --EK2
				);
    EK2 <= remain(2) & C_out2(126 downto 0);    
				
	   finish <= f1 and f2 and f3;
	   process(clk)
        begin
            if (clk'event and clk='1') then
                  EK_AES <= EKa;
                  fin <= finish;
            end if;
        end process;
	EKa <= EK2 & EK1 & EK0 when finish ='1' else (others=>'0');

end Behavioral;
