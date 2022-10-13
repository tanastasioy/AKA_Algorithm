library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RSA_Dec_UIc is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
	    UIc     :	in  std_logic_vector(4*WIDTH_IN-1 downto 0);
		R1  	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		R2   	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		SUPI 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		fin     :   out std_logic;
		start   :   in  std_logic;
		clk 	:	in  std_logic;
		reset 	:	in  std_logic		
	);
end entity;

architecture test of RSA_Dec_UIc is

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

Signal IDSN_in	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R1_in	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R2_in	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal SUPI_in	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal IDSN_in1	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R1_in1	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R2_in1	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal SUPI_in1	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal IDSN_O	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R1_O 	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R2_O 	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal SUPI_O	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal IDSN_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R1_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R2_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal SUPI_out	 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal C_out0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal C_out3 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal f1,f2,f3,f4,finish: std_logic  := '0';

Begin

    SUPI_in  <=	"0" & UIc(4*WIDTH_IN-2 downto 3*WIDTH_IN);
    R1_in	 <=	"0" & UIc(3*WIDTH_IN-2 downto 2*WIDTH_IN);
    R2_in	 <=	"0" & UIc(2*WIDTH_IN-2 downto WIDTH_IN);
    IDSN_in  <=	"0" & UIc(WIDTH_IN-2 downto 0);		
    SUPI_O   <= SUPI_out when finish='1' else (others=>'0');
    R1_O	 <=	R1_out when finish='1' else (others=>'0');
    R2_O	 <=	R2_out when finish='1' else (others=>'0');
    IDSN_O   <= IDSN_out when finish='1' else (others=>'0');	
    
	process(clk)
        begin
            if (clk'event and clk='1') then
                  SUPI <=	SUPI_O;
                  R1	 <=	R1_O;
                  R2	 <=	R2_O;
                  IDSN <=	IDSN_O;		
                  fin <= finish;
            end if;
        end process;
dut0: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(SUPI_in),
					enc_dec =>	'0',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f1,
					C		=>	C_out0 --SUPI_out
				);
    SUPI_out <= UIc(4*WIDTH_IN-1) & C_out0(126 downto 0);
dut1: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(R1_in),
					enc_dec =>	'0',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f2,
					C		=>	C_out1 --R1_out
				);	
    R1_out <= UIc(3*WIDTH_IN-1) & C_out1(126 downto 0);
dut2: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(R2_in),
					enc_dec =>	'0',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f3,
					C		=>	C_out2 --R2_out
				);
    R2_out <= UIc(2*WIDTH_IN-1) & C_out2(126 downto 0);				
dut3: modular_exponentiation 
			generic map(WIDTH_IN => WIDTH_IN)
			PORT MAP(	
					N		=> 	unsigned(IDSN_in),
					enc_dec =>	'0',
					clk		=> 	clk,
					reset 	=>	reset,
					start   =>  start,
					finish  =>  f4,
					C		=>	C_out3 --IDSN_out
				);
    IDSN_out <= UIc(WIDTH_IN-1) & C_out3(126 downto 0);  
	   finish <= f1 and f2 and f3 and f4;
end;
