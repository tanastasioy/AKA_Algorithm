library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BC5GAKA is
	
	generic (WIDTH_IN : integer := 128 
	);
	port(	
		R1      	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		IDSN     	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
        start       :   in std_logic;
		auth_suc	:	out std_logic;
		req_fail	:	out std_logic;
		res_fail	:	out std_logic;
		mac_fail	:	out std_logic;
		complete    :   out std_logic;
		KSEAF_SUPI  :   out std_logic;
		clk		    :	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture beh of BC5GAKA is

component phase1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1  	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		SUCI	:	out std_logic_vector(5*WIDTH_IN-1 downto 0);
		SUPI 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		remain 	:	out std_logic_vector(3 downto 0);
		fin     :   out std_logic;
        start   :   in std_logic;
		clk 	:	in std_logic;
		reset 	:	in std_logic		
	);
end component;

component phase1_1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	 :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN_in  :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		SUCI_in	 :	in  std_logic_vector(5*WIDTH_IN-1 downto 0);
		SUCI_out :	out std_logic_vector(5*WIDTH_IN-1 downto 0);
		IDSN 	 :	out std_logic_vector(WIDTH_IN-1 downto 0);
		req_id   :	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin      :  out std_logic;
        start   :   in std_logic;
		clk	 	 :	in  std_logic;
		reset	 :	in  std_logic		
	);

end component;

component phase2 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(		
		SUCI		:	in  std_logic_vector(5*WIDTH_IN-1 downto 0);
		req_id  	:	in  std_logic_vector(2*WIDTH_IN-1 downto 0);
		IDSN		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		HN_R		:	out std_logic_vector(WIDTH_IN-1 downto 0);
		req_id_o	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		hxRES		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		xMAC		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		KSEAF		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		EK			:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		res_id		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		remainuic   :	in  std_logic_vector(3 downto 0);
		remainek    :	out std_logic_vector(2 downto 0);
		fin         :   out std_logic;
		start       :   in  std_logic;
		req_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end component;

component phase3 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	    :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		IDSN 	    :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		Res			:	out std_logic_vector(2*WIDTH_IN-1 downto 0);  
		xMAC		:	in  std_logic_vector(2*WIDTH_IN-1 downto 0);
		HN_R		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		fin         :   out std_logic;
		start       :   in  std_logic;
		mac_abort	:	out std_logic;
		clk			:	in  std_logic;
		reset		:	in  std_logic	
	);
end  component;

component phase4 is
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1   	:	in  std_logic_vector(WIDTH_IN-1 downto 0);   
		EK   	:	in std_logic_vector(3*WIDTH_IN-1 downto 0);
		hxRes  	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		Res   	:	in std_logic_vector(2*WIDTH_IN-1 downto 0);
		KSEAF  	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		SUPI	:	out std_logic_vector(WIDTH_IN-1 downto 0);
		remain  :	in std_logic_vector(2 downto 0);
		clk	    :	in std_logic;
		abort   :   out std_logic;
		start   :   in std_logic;
		fin     :   out std_logic;
		reset	:	in std_logic	
	);
end component;

--Signal R1 	    : std_logic_vector(WIDTH_IN-1 downto 0) ;
--Signal IDSN 	: std_logic_vector(WIDTH_IN-1 downto 0) ;

Signal SUCI_UE 	: std_logic_vector(5*WIDTH_IN-1 downto 0) ;
Signal SUPIp1 	: std_logic_vector(WIDTH_IN-1 downto 0) ;

Signal IDSN_str : std_logic_vector(WIDTH_IN-1 downto 0);
Signal SUCI_SN 	: std_logic_vector(5*WIDTH_IN-1 downto 0);
Signal req_id_SN: std_logic_vector(2*WIDTH_IN-1 downto 0);

Signal HN_Rx	: std_logic_vector(WIDTH_IN-1 downto 0);
Signal hxRESx 	: std_logic_vector(2*WIDTH_IN-1 downto 0);
Signal xMACx 	: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal EK 		: std_logic_vector(3*WIDTH_IN-1 downto 0) ;
Signal res_id_HN: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal req_id_HN: std_logic_vector(2*WIDTH_IN-1 downto 0) ;

Signal Resx 	: std_logic_vector(2*WIDTH_IN-1 downto 0) ;

Signal KSEAFp4: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal KSEAFp2: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal SUPIp4   : std_logic_vector(WIDTH_IN-1 downto 0) ;

Signal remain3b : std_logic_vector(3 downto 0) := (others=>'0');
Signal remain2b : std_logic_vector(2 downto 0) := (others=>'0');
Signal mac_abort: std_logic := '0';
Signal res_abort: std_logic := '0';
Signal req_abort: std_logic := '0';
Signal auth: std_logic := '0';
Signal KSEAFSUPI,KSEAFSUPIl: std_logic := '0';
Signal finph1,finph11,finph2,finph3,finph4: std_logic := '0';

Signal req_fail_ila,mac_fail_ila,res_fail_ila,auth_ila,complete_ila: std_logic_vector(0 downto 0) := "0";
Signal req_fail1,mac_fail1,res_fail1,auth1,complete1: std_logic_vector(0 downto 0) := "0";

begin
	
	SN_UE: phase1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
				R1	=>	R1,
				IDSN	=>	IDSN,
				SUCI	=>	SUCI_UE,
				SUPI    =>  SUPIp1,
				remain  =>  remain3b,
				fin     =>  finph1,
				start   =>  start,
				clk	    =>	clk,
				reset	=>	reset	
			);			
			
	UE_SN: phase1_1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
		        R1      =>  R1,
		        IDSN_in   =>  IDSN,
				SUCI_in		=>	SUCI_UE,
				SUCI_out	=>	SUCI_SN,	
				IDSN	    =>	IDSN_str,		
				req_id	    =>	req_id_SN,	
				start       =>  finph1,	
				fin         =>  finph11,	
				clk	        =>	clk,
				reset	    =>	reset	
			);	
	
	SN_HN: phase2 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				HN_R	=>	HN_Rx,
				IDSN	=>	IDSN,		
				hxRES	=>	hxRESx,
				xMAC	=>	xMACx,
				KSEAF   =>  KSEAFp2,
				EK	=>	EK,
				req_id	=>	req_id_SN,		
				req_id_o	=>	req_id_HN,
				res_id	=>	res_id_HN,
				SUCI	=>	SUCI_SN,   	
				remainuic => remain3b,
				remainek => remain2b,		
				req_abort	=>	req_abort,
				start   => finph11,
				fin     => finph2,
				clk	=>	clk,
				reset	=>	reset	
			);
	
	HN_UE: phase3
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
		        R1      =>  R1,
		        IDSN    =>  IDSN,
				HN_R	=>	HN_Rx,
				Res	=>	Resx,
				xMAC	=>	xMACx,
				mac_abort	=>	mac_abort,
				start   => finph2,
				fin     => finph3,
				clk	=>	clk,
				reset	=>	reset	 
			);
	 UE2SN: phase4
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
		        R1      =>  R1,
		        EK      =>  EK,
		        hxRes    =>  hxRESx,
				Res	=>	Resx,
				KSEAF	=>	KSEAFp4,
				SUPI	=>	SUPIp4,
				remain  => remain2b,
				abort     => res_abort,
				start   => finph3,
				fin     =>finph4,
				clk	=>	clk,
				reset	=>	reset	
			);
		
	process(clk)
        begin
            if (clk'event and clk='1') then
                   mac_fail <= mac_abort;
	               req_fail <= req_abort;
	               res_fail <= res_abort;	
	               auth_suc <= auth;
	               complete <= finph4;
	               KSEAF_SUPI <= KSEAFSUPIl;
	              
            end if;
     end process;
    
	auth <= '0' when ( mac_abort or req_abort or res_abort ) = '1' else '1';	
	KSEAFSUPI <= '1' when (KSEAFp2 = KSEAFp4 and SUPIp1 = SUPIp4) else '0';
	KSEAFSUPIl <= KSEAFSUPI when finph4='1' else '0';
	
end;