library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase4 is
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	:	in  std_logic_vector(WIDTH_IN-1 downto 0);   
		EK   	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		hxRes  	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		Res   	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		KSEAF  	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		SUPI	:	out std_logic_vector(WIDTH_IN-1 downto 0);		
		clk	    :	in std_logic;
		fin     :   out std_logic;
		start   :   in std_logic;
		abort   :   out std_logic;
		reset	:	in std_logic	
	);
end phase4;

architecture Behavioral of phase4 is

component RSA_KEAF_dec is
	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK   	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		EK_AES	:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		clk	    :	in std_logic;
		fin     :   out std_logic;
		start   :   in  std_logic;
		reset	:	in std_logic	
	);
end component;

component AES_KSEAF_DEC is

	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK_AES	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		xRES	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		SUPI	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		KSEAF	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		start   :   in std_logic;
		fin     :   out std_logic;
		clk	:	in std_logic;
		rst	:	in std_logic	
	);
end component;

component SHA_384_256 is
    generic(
        WORD_SZ : natural := 32;
        RESET_VALUE : std_logic := '1'    --reset enable value
    );
    port(
        plaintext : in std_logic_vector(0 to (12*WORD_SZ)-1);
        hash_out  : out std_logic_vector(0 to (8*WORD_SZ)-1); --SHA-256 results in a 256-bit hash value
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        finish    : out std_logic
    );
end component;

Signal R1_in : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAF_O  : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others => '0');
Signal SUPI_O   : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');

Signal xRESR1 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal hxRESR1 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAFv  : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others => '0');
Signal SUPI_out : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal EK_AES : std_logic_vector(3*WIDTH_IN-1 downto 0) := (others => '0');
Signal EK_in : std_logic_vector(3*WIDTH_IN-1 downto 0) := (others => '0');

Signal finrsakseaf,res_abort,abort_res,finaesdec,finhxres: std_logic := '0';

begin

    EK_in <= EK when start<='1' else (others=>'0');    
    R1_in <= R1 when start='1' else (others=>'0');
	ekrsa: RSA_KEAF_dec 	
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	EK_AES		=>	EK_AES,
				EK		=>	EK_in,
				clk		=>	clk,
				fin     =>  finrsakseaf,
				start   =>  start,
				reset	=>	reset
		);
    ekaes: AES_KSEAF_DEC 
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	
		        clk	      	=>	clk,
				rst		    =>	reset,
				xRES		=>	Res,
				start       =>  finrsakseaf,
				fin         =>  finaesdec,
				KSEAF		=>	KSEAFv,
				SUPI		=>	SUPI_out,
				EK_AES		=>	EK_AES
		);
    
	xRESR1 <= Res & R1_in when start='1' else (others=>'0');
	
	sha256xres: SHA_384_256
		PORT MAP(	
					clk			=>	clk,
        			rst			=>	reset,
        			start           =>  start,
        			finish          =>  finhxres,
        			plaintext       =>	xRESR1,
        			hash_out	    =>	hxRESR1
    			);
	res_abort <= '0' when hxRESR1 = hxRES else '1'; 
    process(clk)
        begin
            if (clk'event and clk='1') then
                   abort<=abort_res;
                   KSEAF<=KSEAF_O;
                   SUPI<=SUPI_O;
                   fin<= finaesdec;
            end if;
     end process;
     KSEAF_O <= KSEAFv when finaesdec='1' else (others=>'0');
     SUPI_O <= SUPI_out when finaesdec='1' else (others=>'0');
	 abort_res <= res_abort when finaesdec='1' else '1';
     
end Behavioral;
