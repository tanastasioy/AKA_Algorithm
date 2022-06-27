library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HMACSHA256 is
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
end HMACSHA256;

architecture Behavioral of HMACSHA256 is

component  SHA_384_256 is
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

component SHA_512_256 is
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

Signal ipad : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal opad : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal Si,So     : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal Km1   : std_logic_vector(4*WIDTH_IN-1 downto 0) := (others=>'0');
Signal Km2   : std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');
Signal result1   : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal result2   : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal hmac_output   : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal fin512,fin384:std_logic := '0';

begin
    ipad <= X"36363636363636363636363636363636";
    opad <= X"5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C";

    A512: SHA_512_256
	   port map(
	           plaintext   =>  Km1,
	           hash_out     =>  result1,
		       start       =>  start,
		       finish      =>  fin512,  
			   clk	   =>  clock,
			   rst	   =>  reset
	           );

    A384: SHA_384_256
		port map(	
		        plaintext =>  Km2,
		        hash_out   =>  result2,
		        start     =>  fin512,
		        finish    =>  fin384,   
				clk	  =>  clock,
				rst	  =>  reset
		);
	
	Si  <=  key xor ipad;
    So  <=  key xor opad;
    
    Km1 <=  Si  &   plaintext;
    Km2 <=  So  &   result1;
    
    hmac_output <= result2 when fin384='1' else (others=>'0');
    process(clock)
    begin
        if (clock'event and clock='1') then
            hmacout <=  hmac_output;
	        finish <= fin384;
        end if;
    end process;

end Behavioral;
