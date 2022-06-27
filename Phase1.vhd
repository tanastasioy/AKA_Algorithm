library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		SUCI 	:	out std_logic_vector(5*WIDTH_IN-1 downto 0);
		SUPI 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		remain 	:	out std_logic_vector(3 downto 0);
		fin     :   out std_logic;
        start   :   in std_logic;
		clk 	:	in  std_logic;
		reset 	:	in  std_logic		
	);
end entity;

architecture test of phase1 is

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

Signal C_out0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out3 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal N_in0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal N_in1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal N_in2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal N_in3 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal RSA_c : std_logic_vector(3 downto 0) := (others=>'0');

Signal RSA512 : std_logic_vector(4*WIDTH_IN-1 downto 0) := (others=>'0');
Signal R2 : std_logic_vector(WIDTH_IN-1 downto 0) := X"41FFAABB002838035C01500FEADFD555";
Signal IDHN : std_logic_vector(WIDTH_IN-1 downto 0) := X"F98EFF888A33642B100F3CB38F216AAA";
Signal SUPI_STR : std_logic_vector(WIDTH_IN-1 downto 0) := X"4897AC0667E5CBD185CD03C5AE862E27";
Signal SUCI_out 	: std_logic_vector(5*WIDTH_IN-1 downto 0) := (others=>'0');

Signal f1,f2,f3,f4,finish: std_logic := '0';

begin
                
        N_in0 <= "0" & SUPI_STR(WIDTH_IN-2 downto 0) when start<='1' else (others=>'0');
        N_in1 <= "0" & R1(WIDTH_IN-2 downto 0)   when start<='1' else (others=>'0');
        N_in2 <= "0" & R2(WIDTH_IN-2 downto 0)   when start<='1' else (others=>'0');
        N_in3 <= "0" & IDSN(WIDTH_IN-2 downto 0) when start<='1' else (others=>'0');
        
        RSA_c <= SUPI_STR(127) & R1(127) & R2(127) & IDSN(127) when finish='1' else (others=>'0');
        
        process(clk,reset)
        begin
            if (clk'event and clk='1') then                
                SUCI <= SUCI_out;
                fin <= finish;
                remain <= RSA_c;
            end if;
        end process;
    
		rsa0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(N_in0), --SUPI
					enc_dec =>	'1',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f1,
					C		=>	C_out0
				);

		rsa1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(N_in1), --R1
					enc_dec =>	'1',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f2,
					C		=>	C_out1
				);
				
		rsa2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(N_in2), --R2 
					enc_dec =>	'1',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f3,
					C		=>	C_out2
				);
				
		rsa3: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(N_in3), --IDSN_in
					enc_dec =>	'1',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f4,
					C		=>	C_out3
				);
	   finish <= f1 and f2 and f3 and f4;
	   RSA512 <= C_out0&C_out1&C_out2&C_out3;
	   SUCI_out <= 	IDHN & RSA512 when finish='1' else (others=>'0');	
	   SUPI <= SUPI_STR when finish='1' else (others=>'0');	
end architecture;
