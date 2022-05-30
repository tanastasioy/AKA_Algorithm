library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BC5GAKA is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   		:	in  unsigned(WIDTH_IN-1 downto 0);   
		IDSN 		:	in  unsigned(WIDTH_IN-1 downto 0);
		auth_suc	:	out std_logic;
		req_fail	:	out std_logic;
		res_fail	:	out std_logic;
		mac_fail	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture beh of BC5GAKA is

component phase1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1  	:	in  unsigned(WIDTH_IN-1 downto 0);
		IDSN	:	in  unsigned(WIDTH_IN-1 downto 0);
		SUCI	:	out unsigned(5*WIDTH_IN-1 downto 0);
		clk 	:	in std_logic;
		reset 	:	in std_logic		
	);
end component;

component phase1_1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		SUCI_in	 :	in  unsigned(5*WIDTH_IN-1 downto 0);
		SUCI_out :	out unsigned(5*WIDTH_IN-1 downto 0);
		IDSN 	 :	out unsigned(WIDTH_IN-1 downto 0);
		req_id   :	out unsigned(2*WIDTH_IN-1 downto 0);
		clk	 	 :	in  std_logic;
		reset	 :	in  std_logic		
	);

end component;

component phase2 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(		
		SUCI		:	in  unsigned(5*WIDTH_IN-1 downto 0);
		req_id  	:	in  unsigned(2*WIDTH_IN-1 downto 0);
		IDSN		:	in  unsigned(WIDTH_IN-1 downto 0);
		HN_R		:	out unsigned(WIDTH_IN-1 downto 0);
		req_id_o	:	out unsigned(2*WIDTH_IN-1 downto 0);
		hxRES		:	out unsigned(2*WIDTH_IN-1 downto 0);
		xMAC		:	out unsigned(3*WIDTH_IN-1 downto 0);
		EK			:	out unsigned(4*WIDTH_IN-1 downto 0);
		res_id		:	out unsigned(2*WIDTH_IN-1 downto 0);
		req_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

component phase3 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		Res			:	out unsigned(2*WIDTH_IN-1 downto 0);  
		xMAC		:	in  unsigned(3*WIDTH_IN-1 downto 0);
		HN_R		:	in  unsigned(WIDTH_IN-1 downto 0);
		mac_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end  component;

--Signal R1_in 	: unsigned(WIDTH_IN-1 downto 0) := "01100001111100111010101010111011000011000001010000011100001100011010111000000000101010001110011101110101011011100110101010110101";
--Signal IDSN_in : unsigned(WIDTH_IN-1 downto 0) := "01110110011111110110101111010101111110101100000001110011100010100000010010111111001010111011010010010011010110100101011100111101";

Signal SUCI_UE 	: unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');

Signal IDSN_str : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal SUCI_SN 	: unsigned(5*WIDTH_IN-1 downto 0) := (5*WIDTH_IN-1 downto 0 => '0');
Signal req_id_SN: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal HN_Rx	: unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
Signal hxRESx 	: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal xMACx 	: unsigned(3*WIDTH_IN-1 downto 0) := (3*WIDTH_IN-1 downto 0 => '0');
Signal EK 		: unsigned(4*WIDTH_IN-1 downto 0) := (4*WIDTH_IN-1 downto 0 => '0');
Signal res_id_HN: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');
Signal req_id_HN: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal Resx 	: unsigned(2*WIDTH_IN-1 downto 0) := (2*WIDTH_IN-1 downto 0 => '0');

Signal mac_abort: std_logic := '0';
Signal res_abort: std_logic := '0';
Signal req_abort: std_logic := '0';

begin
	
	SN_UE: phase1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
				R1	=>	R1,
				IDSN	=>	IDSN,
				SUCI	=>	SUCI_UE,
				clk	=>	clk,
				reset	=>	reset	
			);			
			
	UE_SN: phase1_1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
				SUCI_in		=>	SUCI_UE,
				SUCI_out	=>	SUCI_SN,	
				IDSN	=>	IDSN_str,		
				req_id	=>	req_id_SN,		
				clk	=>	clk,
				reset	=>	reset	
			);	
	
	SN_HN: phase2 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				HN_R	=>	HN_Rx,
				IDSN	=>	IDSN_str,		
				hxRES	=>	hxRESx,
				xMAC	=>	xMACx,
				EK	=>	EK,
				req_id	=>	req_id_SN,		
				req_id_o	=>	req_id_HN,
				res_id	=>	res_id_HN,
				SUCI	=>	SUCI_SN,   			
				req_abort	=>	req_abort,
				clk	=>	clk,
				reset	=>	reset	
			);
	
	HN_UE: phase3
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				HN_R	=>	HN_Rx,
				Res	=>	Resx,
				xMAC	=>	xMACx,
				mac_abort	=>	mac_abort,
				clk	=>	clk,
				reset	=>	reset	
			);
			
	mac_fail <= mac_abort;
	req_fail <= req_abort;
	res_abort <= '0' when Resx = hxRESx else '1'; 
	res_fail <= req_abort;	
	
	auth_suc <= '0' when ( mac_abort or req_abort or res_abort ) = '1' else '1';
	
end;