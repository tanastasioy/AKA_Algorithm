library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AES_KSEAF is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		KSEAF	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		SUPI	:	in std_logic_vector(WIDTH_IN-1 downto 0);
		xRES	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		EK_AES	:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		start   :   in  std_logic;
		fin     :   out std_logic;
		clk	:	in std_logic;
		rst	:	in std_logic	
	);
end entity;


architecture test of AES_KSEAF is

component aes_enc is
    port (  clk         : in std_logic; -- Clock.
            rst         : in std_logic; -- Reset.
            enable      : in std_logic; -- Enable.
            key         : in std_logic_vector(127 downto 0); -- Secret key.
            input       : in std_logic_vector(127 downto 0); -- Input (plaintext or ciphertext).
            output      : out std_logic_vector(127 downto 0); -- Output (plaintext or ciphertext).
            complete    : out std_logic); -- Identify when the operation is complete.
end component;

Signal EK_aes0 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK_aes1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EK_aes2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal EKstd : std_logic_vector(3*WIDTH_IN-1 downto 0) := (others=>'0');

Signal Key1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal Key2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');

Signal in1 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal in2 : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0');
Signal done,done1,done2,done3: std_logic := '0';

begin 
	
	Key1 <=	xRES(WIDTH_IN-1 downto 0);
	Key2 <=	xRES(2*WIDTH_IN-1 downto WIDTH_IN);
	
	in1 <=	KSEAF(WIDTH_IN-1 downto 0);
	in2 <=	KSEAF(2*WIDTH_IN-1 downto WIDTH_IN);
	
	ekaes0: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				enable  =>  start,
				key		=>	Key1,
				complete=>  done1,
				input	=>	SUPI,
				output	=>	EK_aes0
		);
	ekaes1: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				enable  =>  start,
				key		=>	Key1,
				complete =>  done2,
				input	=>	in1,
				output	=>	EK_aes1
		);
	ekaes2: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				enable  =>  start,
				key		=>	Key2,
				complete =>  done3,
				input	=>	in2,
				output	=>	EK_aes2
		);
		
    process(clk)
        begin
            if (clk'event and clk='1') then
                  EK_AES  <=	EKstd;	
                  fin <= done;
            end if;
        end process;
    done <= done1 and done2 and done3;
    EKstd	<=	EK_aes2 & EK_aes1 & EK_aes0 when done='1' else (others=>'0');
	
end;
