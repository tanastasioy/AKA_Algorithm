library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity resid is
	generic (WIDTH_IN : integer := 128
	);
	port(	hxRES	:	in unsigned(2*WIDTH_IN-1 downto 0);
		xMAC	:	in unsigned(3*WIDTH_IN-1 downto 0);
		EK	:	in unsigned(4*WIDTH_IN-1 downto 0);
		res_id	 :	out unsigned(2*WIDTH_IN-1 downto 0);
		clk	 :	in std_logic;
		fin	 :	out std_logic;
		reset	 :	in std_logic		
	);

end entity;

architecture resid_beh of resid is

constant WORD_SIZE : natural := 64;

component merge_res is
	
	generic(WIDTH_IN: integer :=32
	);
	port(	in_1 : in unsigned(2*WIDTH_IN-1 downto 0); 
		in_2 : in unsigned(3*WIDTH_IN-1 downto 0); 
		in_3 : in unsigned(4*WIDTH_IN-1 downto 0); 
		merged_out1 : out unsigned(8*WIDTH_IN-1 downto 0);
		merged_out2 : out unsigned(8*WIDTH_IN-1 downto 0)
	);
end component;

component sha_512_part1 is
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
component sha_512_part2 is
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
component sha_512_part3 is
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

component sha_256_part1 is
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
        --mode_in : in std_logic;S
        finished : out std_logic;
        data_out : out std_logic_vector((WORD_SZ * 8)-1 downto 0) --SHA-256 results in a 256-bit hash value
    );
end component;

Signal MSG512_1 : unsigned(8*WIDTH_IN-1 downto 0) := (8*WIDTH_IN-1 downto 0 => '0');
Signal MSG512_2 : unsigned(8*WIDTH_IN-1 downto 0) := (8*WIDTH_IN-1 downto 0 => '0');
Signal MSG512_3 : std_logic_vector(0 to (16 * WORD_SIZE)-1) := (0 to (16 * WORD_SIZE)-1 => '0');
Signal FIN512_1 : std_logic := '0';
Signal FIN512_2 : std_logic := '0';
Signal FIN512_3 : std_logic := '0';
Signal SHA512_out1 : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal SHA512_out2 : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal SHA512_out3 : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal SHA256_out  : std_logic_vector(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal start1 : std_logic := '0';
Signal start2 : std_logic := '0';
Signal start3 : std_logic := '0';

Begin
	start1 <= '0' when to_integer(MSG512_1)=0 else '1'; 
	start2 <= '0' when to_integer(MSG512_2)=0 else '1'; 
	mer: merge_res
		generic map(WIDTH_IN => WIDTH_IN)
		PORT MAP(	in_1	 	=>	hxRES,
				in_2	 	=>	xMAC,
				in_3	 	=>	EK,
				merged_out1 	=>	MSG512_1,
				merged_out2 	=>	MSG512_2
			);
	--ms1 <= MSG512_1; ms2 <= MSG512_2;
	Asha512: sha_512_part1
		generic map(RESET_VALUE		=>	'1' )
    		PORT MAP(	clk		=>	clk,
        			rst		=>	reset,
        			data_ready 	=>	start1,
        			n_blocks 	=>	1,
        			msg_block_in	=>	std_logic_vector(MSG512_1),
       				finished	=>	FIN512_1,
        			data_out	=>	SHA512_out1
    			);
	sha512_2: sha_512_part2
		generic map(RESET_VALUE		=>	'1' )
    		PORT MAP(	clk		=>	clk,
        			rst		=>	reset,
        			data_ready 	=>	FIN512_1,
        			n_blocks 	=>	1,
        			msg_block_in	=>	std_logic_vector(MSG512_2),
       				finished	=>	FIN512_2,
        			data_out	=>	SHA512_out2
    			);
	start3	<= FIN512_1 and FIN512_2; --st3 <= start3; st1 <= SHA512_out1; st2 <= SHA512_out2;
	MSG512_3 <= SHA512_out1 & SHA512_out2; --mso <= MSG512_3;
	sha512: sha_512_part3
		generic map(RESET_VALUE		=>	'1' )
    		PORT MAP(	clk		=>	clk,
        			rst		=>	reset,
        			data_ready 	=>	FIN512_2,
        			n_blocks 	=>	1,
        			msg_block_in	=>	MSG512_3,
       				finished	=>	FIN512_3,
        			data_out	=>	SHA512_out3
    			);
	sha256: sha_256_part1
		generic map(RESET_VALUE		=>	'1' )
   		PORT MAP(	clk		=>	clk,
			        rst		=>	reset,
			        data_ready	=>	FIN512_3,
			        n_blocks	=>	1,
			        msg_block_in	=>	SHA512_out3,
			        finished	=>	fin,
			        data_out	=>	SHA256_out
			);
	res_id <= unsigned(SHA256_out);
end;