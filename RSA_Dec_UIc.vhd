library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RSA_Dec_UIc is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	UIc :	in unsigned(4*WIDTH_IN-1 downto 0);
		R1   :	out unsigned(WIDTH_IN-1 downto 0);
		R2   :	out unsigned(WIDTH_IN-1 downto 0);
		IDSN :	out unsigned(WIDTH_IN-1 downto 0);
		SUPI :	out unsigned(WIDTH_IN-1 downto 0);
		clk :	  in std_logic;
		reset :	  in std_logic		
	);
end entity;

architecture test of RSA_Dec_UIc is

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
component split is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	UIc	 : in unsigned(4*WIDTH_IN-1 downto 0); 
		SUPI_en	 : out unsigned(WIDTH_IN-1 downto 0); 
		R1_en	 : out unsigned(WIDTH_IN-1 downto 0); 
		R2_en	 : out unsigned(WIDTH_IN-1 downto 0); 
		IDSN_en	 : out unsigned(WIDTH_IN-1 downto 0)
	);
end component;

Signal M_in	: unsigned(WIDTH_IN-1 downto 0) := "10001111001101011110110011100010000110011010101111100000000100111010111101001011100101010000111011111011011100001001001100111101";
Signal Exp_in	: unsigned(WIDTH_IN-1 downto 0) := "01000010101011001010100010001100110110111100011011011001100101010000100001101100011101011101010010101111100011111011111101000001";

Signal enc_dec_in : std_logic := '0';

Signal IDSN_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R1_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R2_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal SUPI_out	 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Begin

mer: split 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	UIc	 	=>	UIc,
					SUPI_en	 	=>	SUPI_out,
					R1_en	 	=>	R1_out,
					R2_en	 	=>	R2_out,
					IDSN_en 	=>	IDSN_out
				);
dut0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	SUPI_out,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	SUPI
				);

dut1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	R1_out,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	R1
				);
dut2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	R2_out,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	R2
				);
dut3: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	N	=> 	IDSN_out,
					Exp 	=> 	Exp_in,
					M 	=> 	M_in,
					enc_dec =>	enc_dec_in,
					clk	=> 	clk,
					reset 	=>	reset,
					C	=>	IDSN
				);
  
end;
