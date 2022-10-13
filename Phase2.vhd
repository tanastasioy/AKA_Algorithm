library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase2 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		SUCI		:	in  std_logic_vector(5*WIDTH_IN-1 downto 0);
		req_id  	:	in  std_logic_vector(2*WIDTH_IN-1 downto 0);
		IDSN		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		R3   		:	in  std_logic_vector(WIDTH_IN-1 downto 0);  
		HN_R		:	out std_logic_vector(WIDTH_IN-1 downto 0);
		req_id_o	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		hxRES		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		xMAC		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		KSEAF		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		EK			:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		res_id		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin         :   out std_logic;
		start       :   in  std_logic;
		req_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture test of phase2 is

constant WORD_SIZE : natural := 32;


component RSA_Dec_UIc is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	UIc	:	in  std_logic_vector(4*WIDTH_IN-1 downto 0);
		R1	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		R2	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		SUPI	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		fin     :   out std_logic;
		start   :   in  std_logic;
		clk	    :	in  std_logic;
		reset 	:	in  std_logic		
	);
end component;


component req_id_sha is	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	 :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	 :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDHN	 :	in  std_logic_vector(WIDTH_IN-1 downto 0);
	    SUCI  	 :	in  std_logic_vector(5*WIDTH_IN-1 downto 0);
		req_id	 :	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin      :  out std_logic;
		start    :  in  std_logic;
		clk	     :	in  std_logic;
		reset	 :	in  std_logic		
	);
end component;

component aes_enc is
    port (  clk         : in std_logic; -- Clock.
            rst         : in std_logic; -- Reset.
            enable      : in std_logic; -- Enable.
            key         : in std_logic_vector(127 downto 0); -- Secret key.
            input       : in std_logic_vector(127 downto 0); -- Input (plaintext or ciphertext).
            output      : out std_logic_vector(127 downto 0); -- Output (plaintext or ciphertext).
            complete    : out std_logic); -- Identify when the operation is complete.
end component;

component HMACSHA256 is
    generic (WIDTH_IN : integer := 128
	);
	port(
	     plaintext :   in  std_logic_vector(3*WIDTH_IN-1 downto 0);
	     key       :   in  std_logic_vector(WIDTH_IN-1 downto 0);
	     hmacout   :   out std_logic_vector(2*WIDTH_IN-1 downto 0);
	     start     :   in  std_logic;
	     finish    :   out std_logic;
	     clock     :   in  std_logic;
	     reset     :   in  std_logic
	);
end component;

component AES_KSEAF is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		KSEAF	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		SUPI	:	in std_logic_vector(WIDTH_IN-1 downto 0);
		xRES	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		EK_AES	:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		start   :   in  std_logic;
		fin :   out std_logic;
		clk	:	in std_logic;
		rst	:	in std_logic	
	);
end component;

component RSA_KSEAF is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK_AES	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		EK	    :	out std_logic_vector(3*WIDTH_IN-1 downto 0);	
		fin     :   out std_logic;
		clk	    :	in std_logic;
		start   :   in std_logic;
		reset	:	in std_logic	
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

component SHA_896_256 is
    generic(
        WORD_SZ : natural := 32;
        RESET_VALUE : std_logic := '1'    --reset enable value
    );
    port(
        plaintext : in std_logic_vector(0 to (28*WORD_SZ)-1);
        hash_out  : out std_logic_vector(0 to (8*WORD_SZ)-1); --SHA-256 results in a 256-bit hash value
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        finish    : out std_logic
    );
end component;

Signal SUPI_in	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal SUPI_ina	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R1_in 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R2_in 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal R3_in 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal IDSN_in 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal IDHN_in 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal UIc_in 	: std_logic_vector(4*WIDTH_IN-1 downto 0) := (others=>'0');
Signal O_in 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal Mer512 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xRES 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xxMAC 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xMAC_O 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xMACv 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xhxRES 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xhRES_O 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xEK 		: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK_in	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xEK_O	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xRESR1 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK_AES 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xreq_id 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal res_id_o : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal res_id_v : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal req_id_v : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal req_id_ou: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal HN_Rv 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal HN_R_O 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal O_out	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAFv 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAFo 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xRESv 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xres_id 	: std_logic_vector(7*WIDTH_IN-1 downto 0) := (others=>'0');
Signal hxRESstd : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal O_key    : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAF_key: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal xRES_key : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal xMAC_key : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal abort,abort_req,finish,finrsa,fino,finkseaf,finxres,finxmac,finkeyh,finrsakseaf,finxresr1,finhxres : std_logic := '0';
Signal finresid,startresid,finreqid,finhnr,finaeskseaf: std_logic := '0';

Begin

    R3_in <= R3 when start='1' else (others=>'0');
    O_key <= x"E67FF540BA6F5C5B9FEFC68B395EC328" when start='1' else (others=>'0');
    KSEAF_key <= x"792F423F4528482B4D6251655468576D" when start='1' else (others=>'0');
    xRES_key <= x"7A25432A462D4A614E645267556A586E" when start='1' else (others=>'0');
    xMAC_key <= x"5166546A576E5A7234753777217A2543" when start='1' else (others=>'0');    
    
    res_id_v  <= res_id_o when finish='1' else (others=>'0');
    HN_R_O    <= HN_Rv    when finish='1' else (others=>'0');
    req_id_ou <= req_id_v when finish='1' else (others=>'0');
    xMAC_O    <= xxMAC    when finish='1' else (others=>'0');
    xhRES_O   <= xhxRES   when finish='1' else (others=>'0');
	xEK_O     <= xEK      when finish='1' else (others=>'0');
	KSEAFo     <= KSEAFv  when finish='1' else (others=>'0');
	abort_req <= abort    when finish='1' else '1';
    
	process(clk)
    begin
        if (clk'event and clk='1') then
               res_id   <= res_id_v;
	           xMAC     <= xMAC_O;
	           HN_R     <= HN_R_O;
	           hxRES    <= xhRES_O;
	           EK       <= xEK_O;
	           KSEAF    <= KSEAFo;
	           req_abort<= abort_req;
	           req_id_o <= req_id_ou;
	           fin <= finish; 
        end if;
    end process;
    
	IDHN_in	 <=	SUCI(WIDTH_IN-1 downto 0) when start='1' else (others=>'0');
	UIc_in	 <=	SUCI(5*WIDTH_IN-1 downto WIDTH_IN) when start='1' else (others=>'0');

	RSA_Dec: RSA_Dec_UIc 
		generic map (WIDTH_IN => WIDTH_IN)
		port map(
				UIc	=>	UIc_in,
				R1	=>	R1_in,
				R2	=>	R2_in,
				IDSN	=>	IDSN_in,
				SUPI	=>	SUPI_in,
				fin     =>  finrsa,
				start   =>  start,
				clk	    =>	clk,
				reset	=>	reset
			);
	
	reqid: req_id_sha 
		generic map(WIDTH_IN => WIDTH_IN)--
		port map(	
		        SUCI  	 =>	SUCI,
				R1   	 =>	R1_in,
				IDSN 	 =>	IDSN,
				IDHN	 =>	IDHN_in,
				req_id	 =>	xreq_id,
				start    => finrsa,
				fin      => finreqid,
				clk	 =>	clk,
				reset	 =>	reset
		);
		
	abort <= '0' when xreq_id = req_id else '1'; 
	req_id_v <= xreq_id when  abort = '0' else (others=>'0');
	
	hnr_aes: aes_enc 
		port map(	
		        clk		=>	clk,
				rst		=>	reset,
				enable  =>  finrsa,
				complete=>  finhnr,
				key		=>	R2_in,
				input	=>	R3_in,
				output	=>	HN_Rv
		);
	O_in <= R1_in & R2_in & R3_in  when finrsa='1'  else (others=>'0');
	
	O_init: HMACSHA256
	   port map(
	           plaintext   =>  O_in,
	           clock       =>  clk,
	           reset       =>  reset,
	           start       =>  finrsa,
	           finish      =>  fino,
	           key         =>  O_key,
	           hmacout     =>  O_out	   
	   );
	   
    Mer512 <= IDSN_in & O_out when fino='1'  else (others=>'0');
    
	KSEAFp: HMACSHA256
	   port map(
	           plaintext   =>  Mer512,
	           clock       =>  clk,
	           reset       =>  reset,
	           start       =>  fino,
	           finish      =>  finkseaf,
	           key         =>  KSEAF_key,
	           hmacout     =>  KSEAFv	   
	   );
		

	xRESp: HMACSHA256
	   port map(
	           plaintext   =>  Mer512,
	           clock       =>  clk,
	           reset       =>  reset,
	           start       =>  fino,
	           finish      =>  finxres,
	           key         =>  xRES_key,
	           hmacout     =>  xRESv	   
	   );
		
	xMACp: HMACSHA256
	   port map(
	           plaintext   =>  Mer512,
	           clock       =>  clk,
	           reset       =>  reset,
	           start       =>  fino,
	           finish      =>  finxmac,
	           key         =>  xMAC_key,
	           hmacout     =>  xMACv	   
	   );
	   
	finkeyh <= finxres and finkseaf and finxmac;
	xRES <= xRESv when finkeyh='1' else (others=>'0');
	xxMAC <= xMACv when finkeyh='1' else (others=>'0');
    SUPI_ina <= SUPI_in when finkeyh='1' else (others=>'0');
    
	ekaes: AES_KSEAF 
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	
		        clk	      	=>	clk,
				rst		    =>	reset,
				start       =>  finkeyh,
				fin         =>  finaeskseaf,
				xRES		=>	xRESv,
				KSEAF		=>	KSEAFv,
				SUPI		=>	SUPI_ina,
				EK_AES		=>	EK_AES
		);
	EK_in <= EK_AES when finaeskseaf='1' else (others=>'0');
	ekrsa: RSA_KSEAF 	
		generic map(WIDTH_IN => WIDTH_IN)
		port map(	EK_AES		=>	EK_in,
				EK		=>	xEK,
				clk		=>	clk,
				fin     =>  finrsakseaf,
				start   =>  finaeskseaf,
				reset	=>	reset
		);
		
	finxresr1 <= finrsa and finxres;
	xRESR1 <= xRES & R1_in when finxresr1='1' else (others=>'0');
	
	sha256xres: SHA_384_256
		PORT MAP(	
					clk			=>	clk,
        			rst			=>	reset,
        			start           =>  finxresr1,
        			finish          =>  finhxres,
        			plaintext       =>	xRESR1,
        			hash_out	    =>	hxRESstd
    			);
			
	xhxRES <= hxRESstd when finhxres='1'  else (others=>'0');
	startresid <= finhxres and finxmac and finrsakseaf;
	
	xres_id <= xhxRES & xxMAC & xEK when startresid='1'  else (others=>'0');
	residf: SHA_896_256 
		Port Map (	
					clk			=>	clk,
        			rst			=>	reset,
        			start           =>  startresid,
        			finish          =>  finresid,
        			plaintext       =>	xres_id,
        			hash_out	    =>	res_id_o
    			);
	finish    <=  finresid and finhnr and finreqid;	
end;