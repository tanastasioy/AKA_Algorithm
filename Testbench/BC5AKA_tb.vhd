library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BC5GAKA_tb is
end entity;

architecture test of BC5GAKA_tb is

component BC5GAKA is
	
	generic (WIDTH_IN : integer := 128 
	);
	port(	
		R1       	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		R3       	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		IDSN    	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
        start       :   in  std_logic;
		auth_suc	:	out std_logic;
		req_fail	:	out std_logic;
		res_fail	:	out std_logic;
		mac_fail	:	out std_logic;
		complete    :   out std_logic;
		KSEAF_SUPI  :   out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

component Test_Vectors is
    generic (WIDTH_IN : integer := 128 
        );
        port(	
            R1       	:	out std_logic_vector(WIDTH_IN-1 downto 0);    
            R3       	:	out std_logic_vector(WIDTH_IN-1 downto 0);    
            IDSN    	:	out std_logic_vector(WIDTH_IN-1 downto 0);
            start       :   out std_logic;
            enable      :   in  std_logic;
            complete    :   in  std_logic;
            clk			:	in  std_logic;
            reset		:	out std_logic	
        );
end component;

CONSTANT WIDTH_IN 	: integer := 128;

CONSTANT clk_period : time := 1 ns; 

Signal R1_in 		: std_logic_vector(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');
Signal R3_in 		: std_logic_vector(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');
Signal IDSN_in  	: std_logic_vector(WIDTH_IN-1 downto 0)  := (WIDTH_IN-1 downto 0 => '0');

Signal start		: std_logic := '0';
Signal clk 			: std_logic := '0';
Signal auth_suc 	: std_logic := '0';
Signal req_fail 	: std_logic := '0';
Signal mac_fail 	: std_logic := '0';
Signal res_fail 	: std_logic := '0';
Signal reset 		: std_logic := '0';
Signal KSEAF_SUPI	: std_logic := '0';
Signal complete     : std_logic;
Signal enable       : std_logic := '0';

Begin
	AKA: BC5GAKA 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				R1      	=>	R1_in,
				R3      	=>	R3_in,
				IDSN    	=>	IDSN_in,
				start       =>  start,
				auth_suc	=>	auth_suc,
				req_fail	=>	req_fail,
				res_fail	=>	res_fail,
				mac_fail	=>	mac_fail,
				complete    =>  complete,
				KSEAF_SUPI  =>  KSEAF_SUPI,
				clk			=>	clk,
				reset		=>	reset	
			);
	TEST_Vec: Test_Vectors 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				R1      	=>	R1_in,
				R3      	=>	R3_in,
				IDSN    	=>	IDSN_in,
				start       =>  start,
				enable      =>  enable,				
				complete    =>  complete,
				clk			=>	clk,
				reset		=>	reset	
			);
    -- process for clock
    clk_process : Process
    Begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    --process for enable
    enable_process : Process
    Begin
        wait for 5*clk_period;
        enable <= '1';
        wait;        
    end process;
	
end;
