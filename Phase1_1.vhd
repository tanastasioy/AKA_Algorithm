library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sha_512_pkg.all;

entity phase1_1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		SUCI_in	 :	in unsigned(5*WIDTH_IN-1 downto 0);
		SUCI_out :	out unsigned(5*WIDTH_IN-1 downto 0);
		IDSN 	 :	out unsigned(WIDTH_IN-1 downto 0);
		req_id   :	out unsigned(2*WIDTH_IN-1 downto 0);
		clk	 	 :	in std_logic;
		reset	 :	in std_logic		
	);

end entity;

architecture test of phase1_1 is

component merge8w is
	
	generic(WIDTH_IN: integer :=32
	);
	port(	
		in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(WIDTH_IN-1 downto 0); 
		in_4 : in unsigned(5*WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(8*WIDTH_IN-1 downto 0)
	);
end component;

component sha_512_corep1 is
    generic(
		WORD_SIZE : natural := 64;
        RESET_VALUE : std_logic := '0'    --reset enable value
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        data_ready : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        n_blocks : in natural; --N, the number of (padded) message blocks
        msg_block_in : in std_logic_vector(0 to (16 * WORD_SIZE)-1);
        --mode_in : in std_logic;
        finished : out std_logic;
        data_out : out std_logic_vector((WORD_SIZE * 8)-1 downto 0) --SHA-512 results in a 512-bit hash value
    );
end component;

component sha_256_corep1 is
    generic(
		WORD_SZ : natural := 32;
        RESET_VALUE : std_logic := '0'    --reset enable value
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        data_ready : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        n_blocks : in natural; --N, the number of (padded) message blocks
        msg_block_in : in std_logic_vector(0 to (16 * WORD_SZ)-1);
        --mode_in : in std_logic;
        finished : out std_logic;
        data_out : out std_logic_vector((WORD_SZ * 8)-1 downto 0) --SHA-256 results in a 256-bit hash value
    );
end component;

Signal MSG512 : unsigned(0 to (16 * WORD_SIZE)-1) := (0 to (16 * WORD_SIZE)-1 => '0');
Signal FIN512 : std_logic := '0';
Signal SHA512_out : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal SHA256_out : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
--Signal req_id 	 : unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal req_id_ch : unsigned(2*WIDTH_IN-1 downto 0) := "0011110000010111110101010001010111001101001101111101101111001000010111010100101101100101011011011111011101110110110110100011101001111011010011001011111110010001101110110011010010101000100101000001011101000000000100001110001101011011110101010010101111010100";

Signal R1 	: unsigned(WIDTH_IN-1 downto 0) := "01100001111100111010101010111011000011000001010000011100001100011010111000000000101010001110011101110101011011100110101010110101";
Signal IDSN_strd : unsigned(WIDTH_IN-1 downto 0) := "01110110011111110110101111010101111110101100000001110011100010100000010010111111001010111011010010010011010110100101011100111101";
Signal IDHN : unsigned(WIDTH_IN-1 downto 0) := "11111001100011101111111110001000100010100011001101100100001010110001000000001111001111001011001110001111001000010110101010101010";

Signal SUCI : unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal start : std_logic := '0';
Signal fin 	 : std_logic := '0';

Begin
	
	mer: merge8w
		generic map(WIDTH_IN => WIDTH_IN)
		PORT MAP(	
				in_1	 	=>	IDHN,
				in_2	 	=>	R1,
				in_3	 	=>	IDSN_strd,
				in_4	 	=>	SUCI_in,
				merged_out 	=>	MSG512
			);
			
	SUCI <= SUCI_in;
	start <= '0' when to_integer(SUCI)=0 else '1';
	
	sha512: sha_512_corep1
		generic map(RESET_VALUE		=>	'1' )
    		PORT MAP(	
					clk			=>	clk,
        			rst			=>	reset,
        			data_ready 	=>	start,
        			n_blocks 	=>	1,
        			msg_block_in=>	std_logic_vector(MSG512),
       				finished	=>	FIN512,
        			data_out	=>	SHA512_out
    			);
				
	sha256: sha_256_corep1
		generic map(RESET_VALUE		=>	'1' )
   		PORT MAP(	
					clk			=>	clk,
			        rst			=>	reset,
			        data_ready	=>	FIN512,
			        n_blocks	=>	1,
			        msg_block_in=>	SHA512_out,
			        finished	=>	fin,
			        data_out	=>	SHA256_out
			);
			
	req_id <= unsigned(SHA256_out) when fin ='1';
	SUCI_out <= SUCI_in when fin ='1';
	IDSN <= IDSN_strd when fin ='1';

end;
