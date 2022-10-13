library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RSA_KSEAF is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK_AES	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		EK	:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		clk	:	in std_logic;
		fin :   out std_logic;
		start :   in std_logic;
		reset	:	in std_logic	
	);
end entity;


architecture test of RSA_KSEAF is

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

Signal EKa : std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');

Signal EK_rsa0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK_rsa1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK_rsa2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal f1,f2,f3,finish: std_logic := '0';

Signal enc_dec_in : std_logic := '1';
    
begin 
        
    EK_rsa0	 <=	"0" & EK_AES(WIDTH_IN-2 downto 0);
	EK_rsa1	 <=	"0" & EK_AES(2*WIDTH_IN-2 downto WIDTH_IN);
	EK_rsa2	 <=	"0" & EK_AES(3*WIDTH_IN-2 downto 2*WIDTH_IN);
	
	dut0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	unsigned(EK_rsa0),
					enc_dec => '1',
					clk	=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f1,
					C	=>	EK0
				);

	dut1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	unsigned(EK_rsa1),
					enc_dec => '1',
					clk	=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f2,
					C	=>	EK1
				);
	dut2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	unsigned(EK_rsa2),
					enc_dec =>	'1',
					clk	=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f3,
					C	=>	EK2
				);
				
	   finish <= f1 and f2 and f3;
	   process(clk)
        begin
            if (clk'event and clk='1') then
                  EK <= EKa;
                  fin <= finish;
            end if;
        end process;
	EKa <= EK_AES(3*WIDTH_IN-1)&EK2(126 downto 0) & EK_AES(2*WIDTH_IN-1)&EK1(126 downto 0) & EK_AES(WIDTH_IN-1)&EK0(126 downto 0) when finish ='1' else (others=>'0');
end;
