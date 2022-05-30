library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase3 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		Res			:	out unsigned(2*WIDTH_IN-1 downto 0);  
		xMAC		:	in  unsigned(3*WIDTH_IN-1 downto 0);
		HN_R		:	in  unsigned(WIDTH_IN-1 downto 0);
		mac_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture test of phase3 is

constant WORD_SIZE : natural := 32;


component aes_dec is 
	port (
		clk : in std_logic;
		rst : in std_logic;
		dec_key : in std_logic_vector(127 downto 0);
		plaintext : out std_logic_vector(127 downto 0);
		ciphertext : in std_logic_vector(127 downto 0)
	);
end component;

component merge3w is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(3*WIDTH_IN-1 downto 0)
	);
end component;

component merge_512 is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(3*WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(4*WIDTH_IN-1 downto 0)
	);
end component;

component hmac_sha384 is
	port (	clk: in std_logic;
  		msg: in std_logic_vector((96*4)-1 downto 0);
  		hashed_code: out std_logic_vector(383 downto 0);
		start : in std_logic
	);
end component;

component hmac_sha384_xres is
	port (	clk: in std_logic;
  		msg: in std_logic_vector((128*4)-1 downto 0);
  		hashed_code: out std_logic_vector(383 downto 0);
		start : in std_logic
	);
end component;

component hmac_sha384_kseaf is
	port (	clk: in std_logic;
  		msg: in std_logic_vector((128*4)-1 downto 0);
  		hashed_code: out std_logic_vector(383 downto 0);
		start : in std_logic
	);
end component;

component hmac_sha384_xmac is
	port (	clk: in std_logic;
  		msg: in std_logic_vector((128*4)-1 downto 0);
  		hashed_code: out std_logic_vector(383 downto 0);
		start : in std_logic
	);
end component;

component sha_256_core2 is
    generic(
        WORD_SZ : natural := 32;
        RESET_VALUE : std_logic := '0'    --reset enable value
    );
    port(
        clk 		: in  std_logic;
        rst 		: in  std_logic;
        data_ready 	: in  std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        n_blocks 	: in  natural; --N, the number of (padded) message blocks
        msg_block_in 	: in  std_logic_vector(0 to (16 * WORD_SZ)-1);
        --mode_in 	: in  std_logic;
        finished 	: out std_logic;
        data_out 	: out std_logic_vector((WORD_SZ * 8)-1 downto 0) --SHA-256 results in a 256-bit hash value
    );
end component;

Signal IDSN 	: unsigned(WIDTH_IN-1 downto 0) := "01110110011111110110101111010101111110101100000001110011100010100000010010111111001010111011010010010011010110100101011100111101";
Signal R1_in 	: unsigned(WIDTH_IN-1 downto 0) := "01100001111100111010101010111011000011000001010000011100001100011010111000000000101010001110011101110101011011100110101010110101";
Signal R2_in 	: unsigned(WIDTH_IN-1 downto 0) := "01000001111111111010101010111011000000000010100000111000000000110101110000000001010100000000111111101010110111111101010101010101";
Signal R3_in 	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal O_in 	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal Mer512 	: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal xRESR1 	: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal R3_inv 	: std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal O 		: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal KSEAFv 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xRESv 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal MAC 		: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal hxRESstd : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal startO,startK,startsha : std_logic := '0';
Signal fin : std_logic := '0';
Signal finish : std_logic := '0';
Signal mac_abort_o : std_logic := '0';

Begin

	hnr_aes: aes_dec 
		port map(	
				clk			=>	clk,
				rst			=>	reset,
				dec_key		=>	std_logic_vector(R2_in),
				ciphertext	=>	std_logic_vector(HN_R),
				plaintext	=>	R3_inv
		);
		
	R3_in <= unsigned(R3_inv); 
	
	mergeO: merge3w
		generic map(
				WIDTH_IN 	=>	WIDTH_IN)
		port map(	
				in_1		=>	R1_in,
				in_2		=>	R2_in,
				in_3		=>	R3_in,
				merged_out	=>	O_in
		);

	startO <= '0' when to_integer(R3_in)=0 else '1';

	O_init: hmac_sha384 
		port map(	
				clk			=>	clk,
  				msg			=>	std_logic_vector(O_in),
  				hashed_code	=>	O,
				start		=>	startO
		);

	startK <= '0' when to_integer(unsigned(O))=0 else '1';

	merge512: merge_512
		generic map(
				WIDTH_IN 	=>	WIDTH_IN)
		port map(	
				in_1		=>	IDSN,
				in_2		=>	unsigned(O),
				merged_out	=>	Mer512
		);

	KSEAFp: hmac_sha384_kseaf
		port map(	
				clk			=>	clk,
  				msg			=>	std_logic_vector(Mer512),
  				hashed_code	=>	KSEAFv,
				start		=>	startK
		);

	xRESp: hmac_sha384_xres
		port map(	
				clk			=>	clk,
  				msg			=>	std_logic_vector(Mer512),
  				hashed_code	=>	xRESv,
				start		=>	startK
		);

	xMACp: hmac_sha384_xmac
		port map(	
				clk			=>	clk,
  				msg			=>	std_logic_vector(Mer512),
  				hashed_code	=>	MAC,
				start		=>	startK
		);
		
	mac_abort_o <= '0' when MAC = std_logic_vector(xMAC) else '1';
	xRESR1 <= unsigned(xRESv) & R1_in;
	startsha <= '0' when to_integer(unsigned(xRESv))=0 else '1';

	sha256xres: sha_256_core2
		generic map(
					RESET_VALUE		=>	'1' )
   		PORT MAP(	clk				=>	clk,
			        rst				=>	reset,
			        data_ready		=>	startsha,
			        n_blocks		=>	1,
			        msg_block_in	=>	std_logic_vector(xRESR1),
			        finished		=>	fin,
			        data_out		=>	hxRESstd
			);
			
	Res <= unsigned(hxRESstd) when fin ='1';	
	mac_abort <= mac_abort_o when fin = '1';
	
end;













