library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SHA_tb is
--    generic (WIDTH_IN : integer := 128
--	);
--	port(
--	     key1       :   in  unsigned(WIDTH_IN-1 downto 0);
--	     cout   :   out unsigned(2*WIDTH_IN-1 downto 0);
--	     clock     :   in  std_logic;
--	     reset     :   in  std_logic
--	);
end SHA_tb;

architecture Behavioral of SHA_tb is

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
component  SHA_512_256 is
    generic(
        WORD_SZ : natural := 32;
        RESET_VALUE : std_logic := '1'    --reset enable value
    );
    port(
        plaintext : in std_logic_vector(0 to (16*WORD_SZ)-1);
        hash_out  : out std_logic_vector(0 to (8*WORD_SZ)-1); --SHA-256 results in a 256-bit hash value
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        finish    : out std_logic
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
component SHA_1024_256 is
    generic(
        WORD_SZ : natural := 32;
        RESET_VALUE : std_logic := '1'    --reset enable value
    );
    port(
        plaintext : in std_logic_vector(0 to (32*WORD_SZ)-1);
        hash_out  : out std_logic_vector(0 to (8*WORD_SZ)-1); --SHA-256 results in a 256-bit hash value
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        finish    : out std_logic
    );
end component;

CONSTANT WIDTH_IN : integer := 128;

CONSTANT clk_period : time := 1 ns;

Signal msg  : std_logic_vector(4*WIDTH_IN-1 downto 0):= (4*WIDTH_IN-1 downto 0 => '0');
Signal key  : std_logic_vector(WIDTH_IN-1 downto 0):= "01100001111100111010101010111011000011000001010000011100001100011010111000000000101010001110011101110101011011100110101010110101";
Signal msg2  : std_logic_vector(4*WIDTH_IN-1 downto 0):= (4*WIDTH_IN-1 downto 0 => '0');
Signal msg1  : std_logic_vector(3*WIDTH_IN-1 downto 0):= (3*WIDTH_IN-1 downto 0 => '0');
Signal msg3  : std_logic_vector(7*WIDTH_IN-1 downto 0):= (7*WIDTH_IN-1 downto 0 => '0');
Signal msg4  : std_logic_vector(8*WIDTH_IN-1 downto 0):= (8*WIDTH_IN-1 downto 0 => '0');
Signal msg5  : std_logic_vector(4*WIDTH_IN-1 downto 0):= (4*WIDTH_IN-1 downto 0 => '0');
Signal outp : std_logic_vector(2*WIDTH_IN-1 downto 0):= (2*WIDTH_IN-1 downto 0 => '0');
Signal outp5 : std_logic_vector(2*WIDTH_IN-1 downto 0):= (2*WIDTH_IN-1 downto 0 => '0');
Signal outp2 : std_logic_vector(2*WIDTH_IN-1 downto 0):= (2*WIDTH_IN-1 downto 0 => '0');
Signal outp4 : std_logic_vector(2*WIDTH_IN-1 downto 0):= (2*WIDTH_IN-1 downto 0 => '0');
Signal outp3 : std_logic_vector(2*WIDTH_IN-1 downto 0):= (2*WIDTH_IN-1 downto 0 => '0');
Signal clock : std_logic := '0';
Signal reset,start,fin1024,fin512,fin896,fin384,finhmac : std_logic := '0';

begin
    uut: SHA_384_256
		port map(	
		        plaintext =>std_logic_vector(msg1),
		        hash_out=>outp,
		        start  => start,
		        finish=> fin384,
				clk	=>	clock,
				rst	=>	reset
		);
	utt2: SHA_512_256
	   port map(
	           plaintext=>std_logic_vector(msg2),
	           clk=> clock,
	           rst=>reset,
	           start=>start,
	           finish=>fin512,
	           hash_out=> outp2
	           );
	 utt3: SHA_1024_256
	   port map(
	           plaintext=>std_logic_vector(msg4),
	           clk=> clock,
	           start=>start,
	           finish=>fin1024,
	           rst=>reset,
	           hash_out=> outp3
	           );
	 uut4: SHA_896_256
	   port map(
	           plaintext=>std_logic_vector(msg3),
	           clk=> clock,
	           rst=>reset,
	           start=>start,
	           finish=> fin896,
	           hash_out=> outp4
	           );
	 uut5: HMACSHA256
	   port map(
	           plaintext => std_logic_vector(msg1),
	           clock=> clock,
	           reset=>reset,
	           key=>key,
	           start=> start,
	           finish=> finhmac,
	           hmacout=> outp5	   
	   );
-- process for clock
clk_process : Process
Begin
	clock <= '0';
	wait for clk_period/2;
	clock <= '1';
	wait for clk_period/2;
end process;

stim_process: process
Begin
	reset <= '1';
	wait for 1 * clk_period;
	reset <= '0';
	wait for 1 * clk_period;
	msg1<= X"852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A2";
	msg2<= X"852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A261F3AABB0C141C31AE00A8E7756E6AB5";
	msg3<= X"852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A261F3AABB0C141C31AE00A8E7756E6AB5852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A2";
	msg4<= X"852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A261F3AABB0C141C31AE00A8E7756E6AB5852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A261F3AABB0C141C31AE00A8E7756E6AB5";
	msg5<= X"852221F5D4CAA115D6802A1365D87F4857876F00DFA2D038C067CF88402B0EFEA5774615EEF70D55EF6E5C226C4EF6A261F3AABB0C141C31AE00A8E7756E6AB5";
	start<='1';
	wait;
	
end process;
end Behavioral;
