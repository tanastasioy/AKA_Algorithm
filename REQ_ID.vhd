library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sha_512_pkg.all;
use work.sha_256_pkg.all;

entity req_id_sha is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	SUCI  	 :	in unsigned(5*WIDTH_IN-1 downto 0);
		R1   	 :	in unsigned(WIDTH_IN-1 downto 0);
		IDSN 	 :	in unsigned(WIDTH_IN-1 downto 0);
		IDHN	 :	in unsigned(WIDTH_IN-1 downto 0);
		req_id	 :	out unsigned(2*WIDTH_IN-1 downto 0);
		clk	 :	in std_logic;
		--start_i	 :	in std_logic;
		fin	 :	out std_logic;
		reset	 :	in std_logic		
	);

end entity;

architecture test of req_id_sha is

component merge8w is
	
	generic(WIDTH_IN: integer :=32
	);
	port(	in_1 : in unsigned(WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(WIDTH_IN-1 downto 0); 
		in_4 : in unsigned(5*WIDTH_IN-1 downto 0); 
		merged_out : out unsigned(8*WIDTH_IN-1 downto 0)
	);
end component;

component sha_512_core is
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

component sha_256_core is
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

Signal MSG512 : unsigned(0 to (16 * 64)-1) := (0 to (16 * 64)-1 => '0');
Signal FIN512 : std_logic := '0';
Signal SHA512_out : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal SHA256_out : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal start : std_logic := '0';
Begin
	start <= '0' when to_integer(IDSN)=0 else '1';
	mer: merge8w
		generic map(WIDTH_IN => WIDTH_IN)
		PORT MAP(	in_1	 	=>	IDHN,
				in_2	 	=>	R1,
				in_3	 	=>	IDSN,
				in_4	 	=>	SUCI,
				merged_out 	=>	MSG512
			);
	sha512: sha_512_core 
		generic map(RESET_VALUE		=>	'1' )
    		PORT MAP(	clk		=>	clk,
        			rst		=>	reset,
        			data_ready 	=>	start,
        			n_blocks 	=>	1,
        			msg_block_in	=>	std_logic_vector(MSG512),
       				finished	=>	FIN512,
        			data_out	=>	SHA512_out
    			);
	sha256: sha_256_core
		generic map(RESET_VALUE		=>	'1' )
   		PORT MAP(	clk		=>	clk,
			        rst		=>	reset,
			        data_ready	=>	FIN512,
			        n_blocks	=>	1,
			        msg_block_in	=>	SHA512_out,
			        finished	=>	fin,
			        data_out	=>	SHA256_out
			);
	req_id <= unsigned(SHA256_out);
end;