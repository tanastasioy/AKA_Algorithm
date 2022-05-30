library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	:	in  unsigned(WIDTH_IN-1 downto 0);
		IDSN 	:	in  unsigned(WIDTH_IN-1 downto 0);
		SUCI 	:	out unsigned(5*WIDTH_IN-1 downto 0);
		clk 	:	in  std_logic;
		reset 	:	in  std_logic		
	);
end entity;

architecture test of phase1 is

component modular_exponentiation is
 	generic(
		WIDTH_IN : integer := 64
	);
	port(	
		N 		:	in  unsigned(WIDTH_IN-1 downto 0); --Number
		Exp 	:	in  unsigned(WIDTH_IN-1 downto 0); --Exponent
		M 		:	in  unsigned(WIDTH_IN-1 downto 0); --Modulus
		enc_dec	:  	in  std_logic;
		clk 	:	in  std_logic;
		reset 	:	in  std_logic;
		C 		:	out unsigned(WIDTH_IN-1 downto 0) --Output
		
	);

end component;
component merge4w is
	
	generic(WIDTH_IN: integer :=32
	);
	port(	
		in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(WIDTH_IN-1 downto 0); 
		in_4 : in unsigned(WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(4*WIDTH_IN-1 downto 0)
	);
end component;
component merge5w is
	
	generic(WIDTH_IN: integer :=32
	);
	port(	
		in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(4*WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(5*WIDTH_IN-1 downto 0)
	);
end component;

CONSTANT clk_period : time := 1 ns;

Signal M_in : unsigned(WIDTH_IN-1 downto 0) := "10001111001101011110110011100010000110011010101111100000000100111010111101001011100101010000111011111011011100001001001100111101";
Signal Exp_in : unsigned(WIDTH_IN-1 downto 0) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";

Signal enc_dec_in : std_logic := '1';

Signal C_out0 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal C_out1 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal C_out2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal C_out3 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Signal RSA512 : unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal R2 : unsigned(WIDTH_IN-1 downto 0) := "01000001111111111010101010111011000000000010100000111000000000110101110000000001010100000000111111101010110111111101010101010101";
Signal IDHN : unsigned(WIDTH_IN-1 downto 0) := "11111001100011101111111110001000100010100011001101100100001010110001000000001111001111001011001110001111001000010110101010101010";
Signal SUPI : unsigned(WIDTH_IN-1 downto 0) := "01001000100101111010110000000110011001111110010111001011110100011000010111001101000000111100010110101110100001100010111000100111";
Signal SUCI_out 	: unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');

begin

		rsa0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	SUPI,
					Exp 	=> 	Exp_in,
					M 		=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk		=> 	clk,
					reset 	=>	reset,
					C		=>	C_out0
				);

		rsa1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	R1,
					Exp 	=> 	Exp_in,
					M 		=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk		=> 	clk,
					reset 	=>	reset,
					C		=>	C_out1
				);
				
		rsa2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	R2,
					Exp 	=> 	Exp_in,
					M 		=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk		=> 	clk,
					reset 	=>	reset,
					C		=>	C_out2
				);
				
		rsa3: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	IDSN,
					Exp 	=> 	Exp_in,
					M 		=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk		=> 	clk,
					reset 	=>	reset,
					C		=>	C_out3
				);
				
		mer: merge4w
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					in_1	 	=>	C_out0,
					in_2	 	=>	C_out1,
					in_3	 	=>	C_out2,
					in_4	 	=>	C_out3,
					merged_out 	=>	RSA512
				);
				
		mer2: merge5w 
			generic map(WIDTH_IN=> WIDTH_IN)
			PORT MAP(	
					in_1 		=>	IDHN,
					in_2 		=>	RSA512,
					merged_out 	=>	SUCI_out
				);
				
		SUCI <= SUCI_out when to_integer(RSA512) /= 0;

end architecture;
