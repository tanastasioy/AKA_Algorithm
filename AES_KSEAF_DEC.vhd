library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AES_KSEAF_DEC is

	generic (WIDTH_IN : integer := 128
	);
	port(	
		EK_AES	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		xRES	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		SUPI	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		KSEAF	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		start   :   in std_logic;
		fin     :   out std_logic;
		clk	:	in std_logic;
		rst	:	in std_logic	
	);
end entity;

architecture beh of AES_KSEAF_DEC is

component aes_dec is
    port (  clk         : in std_logic; -- Clock.
            rst         : in std_logic; -- Reset.
            enable      : in std_logic; -- Enable.
            key         : in std_logic_vector(127 downto 0); -- Secret key.
            input       : in std_logic_vector(127 downto 0); -- Input (plaintext or ciphertext).
            output      : out std_logic_vector(127 downto 0); -- Output (plaintext or ciphertext).
            complete    : out std_logic); -- Identify when the operation is complete.
end component;

Signal KSEAF_O  : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others => '0');
Signal SUPI_dec : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal SUPI_O : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal KSEAF0W  : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');
Signal KSEAFW2W : std_logic_vector(WIDTH_IN-1 downto 0) := (others => '0');

Signal Key1,Key2 : std_logic_vector(127 downto 0) := (others => '0');
Signal plaintext : std_logic_vector(127 downto 0) := (others => '0');
Signal plaintext1 : std_logic_vector(127 downto 0) := (others => '0');

Signal in1,in2,in3 : std_logic_vector(127 downto 0) := (others => '0');
Signal donedec1,donedec2,donedec3,done : std_logic := '0';


begin

    dec_inst1 : component aes_dec
		port map(
			clk        => clk,
			rst        => rst,
			enable =>start,
			key    => Key2,
			input => in3,
			output  => KSEAFW2W,
			complete       => donedec1
		);
		dec_inst2 : component aes_dec
		port map(
			clk        => clk,
			rst        => rst,
			enable =>start,
			key    => Key1,
			input => in2,
			output  => KSEAF0W,
			complete       => donedec2
		);
		dec_inst3 : component aes_dec
		port map(
			clk        => clk,
			rst        => rst,
			enable =>start,
			key    => Key1,
			input => in1,
			output  => SUPI_dec,
			complete       => donedec3
		);
    
    Key1 <=	xRES(WIDTH_IN-1 downto 0);
	Key2 <=	xRES(2*WIDTH_IN-1 downto WIDTH_IN);
	
	in1 <=	EK_AES(WIDTH_IN-1 downto 0);
	in2 <=	EK_AES(2*WIDTH_IN-1 downto WIDTH_IN);
	in3 <=	EK_AES(3*WIDTH_IN-1 downto 2*WIDTH_IN);	
	
    process(clk)
        begin
            if (clk'event and clk='1') then
                KSEAF  <=	KSEAF_O;	
                SUPI<=SUPI_O;
                fin <=done;
            end if;
        end process;
    done <= donedec1 and donedec2 and donedec3;
    SUPI_O <= SUPI_dec when done='1' else (others=>'0');
    KSEAF_O	<=	 KSEAFW2W & KSEAF0W when done='1' else (others=>'0');	

end;