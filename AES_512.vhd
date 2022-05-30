library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AES_512 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		KSEAF	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		SUPI	:	in std_logic_vector(WIDTH_IN-1 downto 0);
		xRES	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		EK_AES	:	out unsigned(4*WIDTH_IN-1 downto 0);
		clk	:	in std_logic;
		rst	:	in std_logic	
	);
end entity;


architecture test of AES_512 is

component aes_enc is 
	port (
		clk : in std_logic;
		rst : in std_logic;
		key : in std_logic_vector(127 downto 0);
		plaintext : in std_logic_vector(127 downto 0);
		ciphertext : out std_logic_vector(127 downto 0)
	);
end component;
component splitkseaf is
	generic(	
		WIDTH_IN: integer :=128
	);
	port(	input	: in unsigned(3*WIDTH_IN-1 downto 0); 
		out1	: out unsigned(WIDTH_IN-1 downto 0); 
		out2	: out unsigned(WIDTH_IN-1 downto 0); 
		out3	: out unsigned(WIDTH_IN-1 downto 0) 
	);
end component;

Signal EK_aes0 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK_aes1 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK_aes2 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EK_aes3 : std_logic_vector(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal EKstd : std_logic_vector(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');

Signal Key1 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal Key2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal Key3 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

Signal in1 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal in2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal in3 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

begin 
	
	splitmsg: splitkseaf
		port map( 	input	=>	unsigned(KSEAF),
				out1	=>	in1,
				out2	=>	in2,
				out3	=>	in3
		);
	splitkey: splitkseaf
		port map( 	input	=>	unsigned(xRES),
				out1	=>	Key1,
				out2	=>	Key2,
				out3	=>	Key3
		);	
	ekaes0: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				key		=>	std_logic_vector(Key1),
				plaintext	=>	SUPI,
				ciphertext	=>	EK_aes0
		);
	ekaes1: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				key		=>	std_logic_vector(Key1),
				plaintext	=>	std_logic_vector(in1),
				ciphertext	=>	EK_aes1
		);
	ekaes2: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				key		=>	std_logic_vector(Key2),
				plaintext	=>	std_logic_vector(in2),
				ciphertext	=>	EK_aes2
		);
	ekaes3: aes_enc 
		port map(	clk		=>	clk,
				rst		=>	rst,
				key		=>	std_logic_vector(Key3),
				plaintext	=>	std_logic_vector(in3),
				ciphertext	=>	EK_aes3
		);
	EKstd	<=	EK_aes0 & EK_aes1 & EK_aes2 & EK_aes3;
	EK_AES  <=	unsigned(EKstd);
end;
