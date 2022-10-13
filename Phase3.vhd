library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase3 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	    :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		R2   	    :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	    :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		Res			:	out std_logic_vector(2*WIDTH_IN-1 downto 0);  
		xMAC		:	in  std_logic_vector(2*WIDTH_IN-1 downto 0);
		HN_R		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		fin         :   out std_logic;
		start       :   in  std_logic;
		mac_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture test of phase3 is

constant WORD_SIZE : natural := 32;


component aes_dec is
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

Signal R3_in 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal O_in 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal Mer512 	: std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal O 		: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAFv 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal xRESv 	: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal MAC 		: std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal R3_inv 	: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal hxRES    : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal O_key    : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal KSEAF_key: std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal xRES_key : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal xMAC_key : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal mac_abort_o,abort_mac,finish,starti,fino,finkseaf,finxmac,finxres,finaesdec : std_logic := '0';

Begin
    
    O_key <= x"E67FF540BA6F5C5B9FEFC68B395EC328";
    KSEAF_key <= x"792F423F4528482B4D6251655468576D";
    xRES_key <= x"7A25432A462D4A614E645267556A586E";
    xMAC_key <= x"5166546A576E5A7234753777217A2543";
    hxRes <= xRESv when finish='1' else (others=>'0');
	abort_mac <= mac_abort_o    when finish='1' else '1';
    process(clk)
    begin
        if (clk'event and clk='1') then
               Res <= hxRES;	
               mac_abort <= abort_mac;
               fin <= finish;
        end if;
    end process;
    
	hnr_aes: aes_dec 
		port map(	
				clk			=>	clk,
				rst			=>	reset,
				enable      =>  start,
				complete    => finaesdec,
				key 		=>	R2,
				input	    =>	HN_R,
				output	    =>	R3_inv
		);
		
	R3_in <= R3_inv; 
	
	O_in <= R1 & R2 & R3_in  when finaesdec='1'  else (others=>'0');
	
	O_init: HMACSHA256
	   port map(
	           plaintext   =>  O_in,
	           clock       =>  clk,
	           reset       =>  reset,
	           start       =>  finaesdec,
	           finish      =>  fino,
	           key         =>  O_key,
	           hmacout     =>  O	   
	   );
	   
    Mer512 <= IDSN & O when fino='1' else (others=>'0');
    
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
	           hmacout     =>  MAC	   
	   );
			
	mac_abort_o <= '0' when MAC = xMAC else '1';
	finish    <=  finxres and finxmac and finkseaf;
	
end;













