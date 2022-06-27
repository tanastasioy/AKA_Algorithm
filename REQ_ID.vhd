library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity req_id_sha is
	
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

end entity;

architecture test of req_id_sha is

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

Signal MSG1024 : std_logic_vector(8*WIDTH_IN-1 downto 0) := (others=>'0');
Signal SHA256_out : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal SHA256_O : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');
Signal fin256: std_logic := '0';

Begin  
	MSG1024 <= IDHN & R1 & IDSN & SUCI when start='1' else (others=>'0');
    SHA256_O <= SHA256_out when fin256='1' else (others=>'0');
	xreq_id_sha: SHA_1024_256
   		PORT MAP(	
					clk			=>	clk,
			        rst			=>	reset,
        			start           =>  start,
        			finish          =>  fin256,
			        plaintext       =>	MSG1024,
			        hash_out	    =>	SHA256_out
			);
	process(clk)
    begin
        if (clk'event and clk='1') then
              req_id <= SHA256_O;
	          fin <= fin256;
        end if;
    end process;
end;