library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RSA_512 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK_AES	:	in unsigned(4*WIDTH_IN-1 downto 0);
		EK	:	out unsigned(4*WIDTH_IN-1 downto 0);
		clk	:	in std_logic;
		reset	:	in std_logic	
	);
end entity;


architecture test of RSA_512 is

component modular_exponentiation is
 	generic(
		WIDTH_IN : integer := 128
	);
	port(	N :	in unsigned(WIDTH_IN-1 downto 0); --Number
		Exp :	in unsigned(WIDTH_IN-1 downto 0); --Exponent
		M :	in unsigned(WIDTH_IN-1 downto 0); --Modulus
		enc_dec:  in std_logic;
		clk :	in std_logic;
		reset :	in std_logic;
		C : 	out unsigned(WIDTH_IN-1 downto 0) --Output
		
	);

end component;

component splitek is
	generic(	
		WIDTH_IN: integer :=128
	);
	port(	input	 : in unsigned(4*WIDTH_IN-1 downto 0); 
		out1 	 : out unsigned(WIDTH_IN-1 downto 0); 
		out2	 : out unsigned(WIDTH_IN-1 downto 0); 
		out3	 : out unsigned(WIDTH_IN-1 downto 0); 
		out4	 : out unsigned(WIDTH_IN-1 downto 0)
	);
end component;

Signal M_in : unsigned(WIDTH_IN-1 downto 0) := "10001111001101011110110011100010000110011010101111100000000100111010111101001011100101010000111011111011011100001001001100111101";
Signal Exp_in : unsigned(WIDTH_IN-1 downto 0) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";

Signal EK_rsa0 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK_rsa1 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK_rsa2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK_rsa3 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Signal EK0 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK1 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK3 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');


Signal enc_dec_in : std_logic := '1';

begin 
	splitit: splitek
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	input	=>	EK_AES,
					out1	=>	EK_rsa0,
					out2	=>	EK_rsa1,
					out3	=>	EK_rsa2,
					out4	=>	EK_rsa3
				);

	dut0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	EK_rsa0,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	EK0
				);

	dut1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	EK_rsa1,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	EK1
				);
	dut2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	EK_rsa2,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	EK2
				);
	dut3: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	EK_rsa3,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	EK3
				);
	EK <= EK0 & EK1 & EK2 & EK3;
end;
