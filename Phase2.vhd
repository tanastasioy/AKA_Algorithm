library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase2 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		SUCI		:	in  unsigned(5*WIDTH_IN-1 downto 0);
		req_id  	:	in  unsigned(2*WIDTH_IN-1 downto 0);
		IDSN		:	in  unsigned(WIDTH_IN-1 downto 0);
		HN_R		:	out unsigned(WIDTH_IN-1 downto 0);
		req_id_o	:	out unsigned(2*WIDTH_IN-1 downto 0);
		hxRES		:	out unsigned(2*WIDTH_IN-1 downto 0);
		xMAC		:	out unsigned(3*WIDTH_IN-1 downto 0);
		EK			:	out unsigned(4*WIDTH_IN-1 downto 0);
		res_id		:	out unsigned(2*WIDTH_IN-1 downto 0);
		req_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture test of phase2 is

constant WORD_SIZE : natural := 32;

component split_suci is
	generic(	
		WIDTH_IN: integer :=128
	);
	port(	SUCI	 : in  unsigned(5*WIDTH_IN-1 downto 0); 
		IDHN	 : out unsigned(WIDTH_IN-1 downto 0); 
		UIc	 : out unsigned(4*WIDTH_IN-1 downto 0)
	);
end component;


component RSA_Dec_UIc is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	UIc	:	in  unsigned(4*WIDTH_IN-1 downto 0);
		R1	:	out unsigned(WIDTH_IN-1 downto 0);
		R2	:	out unsigned(WIDTH_IN-1 downto 0);
		IDSN	:	out unsigned(WIDTH_IN-1 downto 0);
		SUPI	:	out unsigned(WIDTH_IN-1 downto 0);
		clk	:	in  std_logic;
		reset 	:	in  std_logic		
	);
end component;


component req_id_sha is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	SUCI  	 :	in  unsigned(5*WIDTH_IN-1 downto 0);
		R1   	 :	in  unsigned(WIDTH_IN-1 downto 0);
		IDSN 	 :	in  unsigned(WIDTH_IN-1 downto 0);
		IDHN	 :	in  unsigned(WIDTH_IN-1 downto 0);
		req_id	 :	out unsigned(2*WIDTH_IN-1 downto 0);
		clk	 :	in  std_logic;
		--start	 :	in  std_logic;
		fin	 :	out std_logic;
		reset	 :	in  std_logic		
	);

end component;

component aes_enc is 
	port (
		clk 		: in  std_logic;
		rst 		: in  std_logic;
		key 		: in  std_logic_vector(127 downto 0);
		plaintext 	: in  std_logic_vector(127 downto 0);
		ciphertext 	: out std_logic_vector(127 downto 0)
	);
end component;

component merge3w is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1		: in  unsigned(WIDTH_IN-1 downto 0); 
		in_2		: in  unsigned(WIDTH_IN-1 downto 0); 
		in_3 		: in  unsigned(WIDTH_IN-1 downto 0); 
		merged_out 	: out unsigned(3*WIDTH_IN-1 downto 0)
	);
end component;

component merge_512 is
	
	generic(WIDTH_IN: integer :=128
	);
	port(	in_1 		: in  unsigned(WIDTH_IN-1 downto 0); 
		in_2 		: in  unsigned(3*WIDTH_IN-1 downto 0); 
		merged_out 	: out unsigned(4*WIDTH_IN-1 downto 0)
	);
end component;

component hmac_sha384 is
	port (	clk		: in  std_logic;
  		msg		: in  std_logic_vector((96*4)-1 downto 0);
  		hashed_code	: out std_logic_vector(383 downto 0);
		start 		: in  std_logic
	);
end component;

component hmac_sha384_xres is
	port (	clk		: in  std_logic;
  		msg		: in  std_logic_vector((128*4)-1 downto 0);
  		hashed_code	: out std_logic_vector(383 downto 0);
		start 		: in  std_logic
	);
end component;

component hmac_sha384_kseaf is
	port (	clk		: in  std_logic;
  		msg		: in  std_logic_vector((128*4)-1 downto 0);
  		hashed_code	: out std_logic_vector(383 downto 0);
		start 		: in  std_logic
	);
end component;

component hmac_sha384_xmac is
	port (	clk		: in  std_logic;
  		msg		: in  std_logic_vector((128*4)-1 downto 0);
  		hashed_code	: out std_logic_vector(383 downto 0);
		start 		: in  std_logic
	);
end component;


component AES_512 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		KSEAF	:	in  std_logic_vector(3*WIDTH_IN-1 downto 0);
		SUPI	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		xRES	:	in  std_logic_vector(3*WIDTH_IN-1 downto 0);
		EK_AES	:	out unsigned(4*WIDTH_IN-1 downto 0);
		clk	:	in  std_logic;
		rst	:	in  std_logic	
	);
end component;

component RSA_512 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK_AES	:	in  unsigned(4*WIDTH_IN-1 downto 0);
		EK	:	out unsigned(4*WIDTH_IN-1 downto 0);
		clk	:	in  std_logic;
		reset	:	in  std_logic	
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

component resid is
	generic (WIDTH_IN : integer := 128
	);
	port(	hxRES	 :	in  unsigned(2*WIDTH_IN-1 downto 0);
		xMAC	 :	in  unsigned(3*WIDTH_IN-1 downto 0);
		EK	 :	in  unsigned(4*WIDTH_IN-1 downto 0);
		res_id	 :	out unsigned(2*WIDTH_IN-1 downto 0);
		fin	 :	out std_logic;
		clk	 :	in  std_logic;
		reset	 :	in  std_logic		
	);
end component;

Signal SUPI_in	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R1_in 	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R2_in 	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal R3_in 	: unsigned(WIDTH_IN-1 downto 0) := "01011101100100111010101010111011011011000001011100011100001101100010111000000000101010001110100010010101011011100110111110000101";
Signal IDSN_in 	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal IDHN_in 	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal UIc_in 	: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal SUCI_in	: unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal O_in 	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal Oo 		: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal Mer512 	: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal KSEAF 	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xRES 	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xxMAC 	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xhxRES 	: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal xEK 		: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal xRESR1 	: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal EK_AES 	: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal xreq_id 	: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal res_id_o : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal req_id_v : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal HN_Rv 	: std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal O_out	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal KSEAFv 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xRESv 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal xMACv 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal hxRESstd : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal startO, startK,startsha : std_logic := '0';
Signal fin 	: std_logic := '0';
Signal finish 	: std_logic := '0';
Signal abort 	: std_logic := '0';

Begin
	
	spsuci: split_suci 
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	SUCI	=>	SUCI,
				IDHN	=>	IDHN_in,
				UIc	=>	UIc_in
			);

	RSA_Dec: RSA_Dec_UIc 
		generic map (WIDTH_IN => WIDTH_IN)
		port map(
				UIc	=>	UIc_in,
				R1	=>	R1_in,
				R2	=>	R2_in,
				IDSN	=>	IDSN_in,
				SUPI	=>	SUPI_in,
				clk	=>	clk,
				reset	=>	reset
			);
			
	reqid: req_id_sha 
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	SUCI  	 =>	SUCI,
				R1   	 =>	R1_in,
				IDSN 	 =>	IDSN_in,
				IDHN	 =>	IDHN_in,
				req_id	 =>	xreq_id,
				clk	 =>	clk,
				--start	 =>	start,
				fin	 =>	fin,
				reset	 =>	reset
		);
		
	abort <= '0' when xreq_id = req_id else '1'; 
	req_id_v <= req_id when  abort = '0';
	
	hnr_aes: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	reset,
				key		=>	std_logic_vector(R2_in),
				plaintext	=>	std_logic_vector(R3_in),
				ciphertext	=>	HN_Rv
		);
	
	mergeO: merge3w
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	in_1		=>	R1_in,
				in_2		=>	R2_in,
				in_3		=>	R3_in,
				merged_out	=>	O_in
		);
		
	startO <= '0' when to_integer(R2_in)=0 else '1';
	
	O_init: hmac_sha384 
		port map(	clk		=>	clk,
  				msg		=>	std_logic_vector(O_in),
  				hashed_code	=>	O_out,
				start		=>	startO
		);
		
	Oo<= unsigned(O_out);
	startK <= '0' when to_integer(Oo)=0 else '1';

	merge512: merge_512
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	in_1		=>	IDSN_in,
				in_2		=>	unsigned(O_out),
				merged_out	=>	Mer512
		);

	KSEAFp: hmac_sha384_kseaf
		port map(	clk		=>	clk,
  				msg		=>	std_logic_vector(Mer512),
  				hashed_code	=>	KSEAFv,
				start		=>	startK
		);
		
	KSEAF <= unsigned(KSEAFv);

	xRESp: hmac_sha384_xres
		port map(	clk		=>	clk,
  				msg		=>	std_logic_vector(Mer512),
  				hashed_code	=>	xRESv,
				start		=>	startK
		);
		
	xRES <= unsigned(xRESv);

	xMACp: hmac_sha384_xmac
		port map(	clk		=>	clk,
  				msg		=>	std_logic_vector(Mer512),
  				hashed_code	=>	xMACv,
				start		=>	startK
		);
		
	xxMAC <= unsigned(xMACv);

	ekaes: AES_512 
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	clk		=>	clk,
				rst		=>	reset,
				xRES		=>	xRESv,
				KSEAF		=>	KSEAFv,
				SUPI		=>	std_logic_vector(SUPI_in),
				EK_AES		=>	EK_AES
		);
		
	ekrsa: RSA_512 	
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	EK_AES		=>	EK_AES,
				EK		=>	xEK,
				clk		=>	clk,
				reset		=>	reset
		);
		
	xRESR1 <= xRES & R1_in;
	startsha <= '0' when to_integer(xRES)=0 else '1';
	
	sha256xres: sha_256_core2
		generic map(RESET_VALUE		=>	'1' )
   		PORT MAP(	clk		=>	clk,
			        rst		=>	reset,
			        data_ready	=>	startsha,
			        n_blocks	=>	1,
			        msg_block_in	=>	std_logic_vector(xRESR1),
			        finished	=>	fin,
			        data_out	=>	hxRESstd
			);
			
	xhxRES <= unsigned(hxRESstd);
	
	residf: resid 
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	hxRES		=>	xhxRES,
				xMAC		=>	xxMAC,
				EK		=>	xEK,
				res_id		=>	res_id,
				clk		=>	clk,
				fin		=>	finish,
				reset		=>	reset
		);	
		
	res_id <= res_id_o when finish='1';
	xMAC <= unsigned(xMACv) when finish='1';
	HN_R <= unsigned(HN_Rv) when finish='1';
	hxRES <= unsigned(hxRESstd) when finish ='1';
	EK <= xEK when finish ='1';
	req_abort <= abort when finish ='1';
	req_id_o <= req_id_v when finish = '1';
	
end;