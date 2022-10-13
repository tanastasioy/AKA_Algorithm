library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BC5GAKA is
	
	generic (WIDTH_IN : integer := 128 
	);
	port(	
		R1       	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		R2       	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		R3       	:	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		IDSN    	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
        start       :   in  std_logic;
		auth_suc	:	out std_logic;
		req_fail	:	out std_logic;
		res_fail	:	out std_logic;
		mac_fail	:	out std_logic;
		complete    :   out std_logic;
		KSEAF_SUPI  :   out std_logic;
		clk  	    :	in  std_logic;
		reset		:	in  std_logic	
	);
end entity;

architecture beh of BC5GAKA is

component phase1 is
	
	generic (WIDTH_IN : integer := 128
	);
	port(	
		R1  	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		R2      :	in  std_logic_vector(WIDTH_IN-1 downto 0);    
		IDSN	:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		SUCI	:	out std_logic_vector(5*WIDTH_IN-1 downto 0);
		SUPI 	:	out std_logic_vector(WIDTH_IN-1 downto 0);
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
		IDSN     :	in  std_logic_vector(WIDTH_IN-1 downto 0);
		SUCI	 :	in  std_logic_vector(5*WIDTH_IN-1 downto 0);
		req_id   :	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		fin      :  out std_logic;
        start    :  in  std_logic;
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
		R3   		:	in  std_logic_vector(WIDTH_IN-1 downto 0);
		HN_R		:	out std_logic_vector(WIDTH_IN-1 downto 0);
		req_id_o	:	out std_logic_vector(2*WIDTH_IN-1 downto 0);---
		hxRES		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		xMAC		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		KSEAF		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
		EK			:	out std_logic_vector(3*WIDTH_IN-1 downto 0);
		res_id		:	out std_logic_vector(2*WIDTH_IN-1 downto 0);
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
		R2   	    :	in  std_logic_vector(WIDTH_IN-1 downto 0);   
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
		clk	    :	in std_logic;
		abort   :   out std_logic;
		start   :   in std_logic;
		fin     :   out std_logic;
		reset	:	in std_logic	
	);
end component;

component DFF_128 is
    Port ( D : in STD_LOGIC_VECTOR (127 downto 0);
           SI  : in STD_LOGIC_VECTOR (127 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC_VECTOR (127 downto 0));
end component;
component DFF_256 is
    Port ( D : in STD_LOGIC_VECTOR (255 downto 0);
           SI  : in STD_LOGIC_VECTOR (255 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC_VECTOR (255 downto 0));
end component;
component DFF_384 is
    Port ( D : in STD_LOGIC_VECTOR (383 downto 0);
           SI  : in STD_LOGIC_VECTOR (383 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC_VECTOR (383 downto 0));
end component;
component DFF_640 is
    Port ( D : in STD_LOGIC_VECTOR (639 downto 0);
           SI  : in STD_LOGIC_VECTOR (639 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC_VECTOR (639 downto 0) );
end component;
component DFF_1 is
    Port ( D : in STD_LOGIC;
           SI  : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC);
end component;

Signal SUCI_UE 	: std_logic_vector(5*WIDTH_IN-1 downto 0) ;
Signal SUPI_UE 	: std_logic_vector(WIDTH_IN-1 downto 0) ;
Signal req_id_SN: std_logic_vector(2*WIDTH_IN-1 downto 0);

Signal HN_Rx	: std_logic_vector(WIDTH_IN-1 downto 0);
Signal hxRESx 	: std_logic_vector(2*WIDTH_IN-1 downto 0);
Signal xMACx 	: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal EK 		: std_logic_vector(3*WIDTH_IN-1 downto 0) ;
Signal res_id_HN: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal req_id_HN: std_logic_vector(2*WIDTH_IN-1 downto 0) ;

Signal Resx 	: std_logic_vector(2*WIDTH_IN-1 downto 0) ;

Signal SUPIp4 : std_logic_vector(WIDTH_IN-1 downto 0) ;
Signal KSEAFp4: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal KSEAFp2: std_logic_vector(2*WIDTH_IN-1 downto 0) ;

Signal mac_abort: std_logic := '0';
Signal res_abort: std_logic := '0';
Signal req_abort: std_logic := '0';
Signal auth: std_logic := '0';
Signal rst: std_logic := '0';

Signal R1_fsm_p2: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal R1_fsm_p3: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal R2_fsm_p2: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal R2_fsm_p3: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal R3_fsm_p2: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal IDSN_fsm_p2: std_logic_vector(WIDTH_IN-1 downto 0)  := (others=>'0');
Signal IDSN_fsm_p3: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal SUCI_fsm_p2 	: std_logic_vector(5*WIDTH_IN-1 downto 0)   := (others=>'0');
Signal req_id_fsm_p2: std_logic_vector(2*WIDTH_IN-1 downto 0)  := (others=>'0');
Signal HN_Rx_fsm_p3	: std_logic_vector(WIDTH_IN-1 downto 0) ;
Signal hxRESx_fsm_p4: std_logic_vector(2*WIDTH_IN-1 downto 0) ;
Signal xMACx_fsm_p3	: std_logic_vector(2*WIDTH_IN-1 downto 0)  ;
Signal EK_fsm_p4	: std_logic_vector(3*WIDTH_IN-1 downto 0)  ;
Signal SUPI_fsm_p2 	: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal SUPI_fsm_p3 	: std_logic_vector(WIDTH_IN-1 downto 0)  ;
Signal KSEAF_fsm_p3: std_logic_vector(2*WIDTH_IN-1 downto 0)  ;
Signal req_abort_fsm: std_logic := '0';

Signal KSEAFSUPI,KSEAFSUPIl: std_logic := '0';
Signal finph1,finph11,finph2,finph3,finph4: std_logic := '0';
Signal scan: std_logic := '0';

type top_module_fsm is (rst_all, idle, phase1_start, collect_data, reset_phase,reset1,reset2,reset3,reset4, phase2_start);
signal current_state, next_state : top_module_fsm;
Signal start_module : std_logic_vector(1 downto 0) := (others=>'0');
begin
	SN_UE: phase1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
				R1	=>	R1,
				R2	=>	R2,
				IDSN	=>	IDSN,
				SUCI	=>	SUCI_UE,
				SUPI    =>  SUPI_UE,
				fin     =>  finph1,
				start   =>  start_module(0),
				clk	    =>	clk,
				reset	=>	rst	
			);			
	
	UE_SN: phase1_1
		generic map (WIDTH_IN => WIDTH_IN
			)
		port map(	
		        R1      =>  R1,
		        IDSN    =>  IDSN,
				SUCI		=>	SUCI_UE,		
				req_id	    =>	req_id_SN,	
				start       =>  finph1,	
				fin         =>  finph11,	
				clk	        =>	clk,
				reset	    =>	rst	
			);	
	D0:DFF_128 port map ( D => R1, Q => R1_fsm_p2, SI => R1_fsm_p2, SE => scan,  clk => clk, rst => reset);
	D1:DFF_128 port map( D => R2, Q => R2_fsm_p2, SI => R2_fsm_p2, SE => scan,  clk => clk, rst => reset);
	D2:DFF_128 port map ( D => SUPI_UE, Q => SUPI_fsm_p2, SI => SUPI_fsm_p2, SE => scan,  clk => clk, rst => reset);
	D21:DFF_128 port map( D => R3, Q => R3_fsm_p2, SI => R3_fsm_p2, SE => scan,  clk => clk, rst => reset);
	
	D3:DFF_640 port map ( D => SUCI_UE, Q => SUCI_fsm_p2, SI => SUCI_fsm_p2, SE => scan,  clk => clk, rst => reset);
	D4:DFF_128 port map ( D => IDSN, Q => IDSN_fsm_p2, SI => IDSN_fsm_p2, SE => scan,  clk => clk, rst => reset);
	D5:DFF_256 port map ( D => req_id_SN, Q => req_id_fsm_p2, SI => req_id_fsm_p2, SE => scan,  clk => clk, rst => reset);
	   
	SN_HN: phase2 	
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
				IDSN	=>	IDSN_fsm_p2,	
				req_id	=>	req_id_fsm_p2,	
				SUCI	=>	SUCI_fsm_p2,   
				HN_R	=>	HN_Rx,	
				R3  	=>	R3_fsm_p2,	
				hxRES	=>	hxRESx,
				xMAC	=>	xMACx,
				KSEAF   =>  KSEAFp2,
				EK	=>	EK,	
				req_id_o	=>	req_id_HN,
				res_id	=>	res_id_HN,	
				req_abort	=>	req_abort,
				start   => start_module(1),
				fin     => finph2,
				clk	=>	clk,
				reset	=>	rst	
			);
			
	D7:DFF_128 port map ( D => IDSN_fsm_p2, Q => IDSN_fsm_p3, SI => IDSN_fsm_p3, SE => scan,  clk => clk, rst => reset);
	D8:DFF_128 port map ( D => R1_fsm_p2, Q => R1_fsm_p3, SI => R1_fsm_p3, SE => scan,  clk => clk, rst => reset);
	D81:DFF_128 port map( D => R2_fsm_p2, Q => R2_fsm_p3, SI => R2_fsm_p3, SE => scan,  clk => clk, rst => reset);
	D9:DFF_256 port map ( D => xMACx, Q => xMACx_fsm_p3, SI => xMACx_fsm_p3, SE => scan,  clk => clk, rst => reset);
	D10:DFF_128 port map( D => HN_Rx, Q => HN_Rx_fsm_p3, SI => HN_Rx_fsm_p3, SE => scan,  clk => clk, rst => reset);
	D11:DFF_1 port map  ( D => req_abort, Q => req_abort_fsm, SI => req_abort_fsm, SE => scan,  clk => clk, rst => reset);
	D12:DFF_384 port map( D => EK, Q => EK_fsm_p4, SI => EK_fsm_p4, SE => scan,  clk => clk, rst => reset);
	D13:DFF_256 port map( D => hxRESx, Q => hxRESx_fsm_p4, SI => hxRESx_fsm_p4, SE => scan,  clk => clk, rst => reset);
	D15:DFF_128 port map( D => SUPI_fsm_p2, Q => SUPI_fsm_p3, SI => SUPI_fsm_p3, SE => scan,  clk => clk, rst => reset);
	D16:DFF_256 port map( D => KSEAFp2, Q => KSEAF_fsm_p3, SI => KSEAF_fsm_p3, SE => scan,  clk => clk, rst => reset);
	
	HN_UE: phase3
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
		        R1      =>  R1_fsm_p3,
		        R2      =>  R2_fsm_p3,
		        IDSN    =>  IDSN_fsm_p3,
				HN_R	=>	HN_Rx_fsm_p3,
				xMAC	=>	xMACx_fsm_p3,
				Res	=>	Resx,
				mac_abort	=>	mac_abort,
				start   => start_module(1),
				fin     => finph3,
				clk	=>	clk,
				reset	=>	rst	 
			);
	 UE2SN: phase4
		generic map (WIDTH_IN => WIDTH_IN)
		port map(	
		        R1      =>  R1_fsm_p3,
		        EK      =>  EK_fsm_p4, 
		        hxRes    =>  hxRESx_fsm_p4,
				Res	=>	Resx,
				KSEAF	=>	KSEAFp4,
				SUPI	=>	SUPIp4,
				abort     => res_abort,
				start   => finph3,
				fin     =>finph4,
				clk	=>	clk,
				reset	=>	rst	
			);
		
	process(clk)
        begin
            if (clk'event and clk='1') then
                   mac_fail <= mac_abort;
	               req_fail <= req_abort;
	               res_fail <= res_abort;	
	               auth_suc <= auth;
	               complete <= scan;
	               KSEAF_SUPI <= KSEAFSUPIl;
	              
            end if;
     end process;
     
	auth <= '0' when ( mac_abort or req_abort_fsm or res_abort ) = '1' else '1';	
	KSEAFSUPI <= '1' when (KSEAF_fsm_p3 = KSEAFp4 and SUPI_fsm_p3 = SUPIp4) else '0';
	KSEAFSUPIl <= KSEAFSUPI when scan='1' else '0';
	
	--current state logic
    process(clk, reset)
    begin
        if(reset='1') then
            current_state <= rst_all;
        elsif(clk'event and clk='1') then
            current_state <= next_state;
        end if;
    end process;
	--phase1_start, collect_data, reset_phase, phase2_start, 
	--next state logic
    process(current_state, reset, start, finph11, finph2)
    begin
        case current_state is
            when rst_all =>
                rst <= '1'; scan<='0'; start_module<= "00";  
                if(reset='1') then
                    next_state <= rst_all;
                else 
                    next_state <= idle;
                end if;
            when idle =>
                rst <= '0'; scan<='0'; start_module<= "00";  
                if(start='1') then
                    next_state <= phase1_start;
                else
                    next_state <= idle;
                end if;
            when phase1_start =>
                start_module<= "01"; rst <= '0'; scan<='0';  
                if (finph11='1') then
                    next_state <= collect_data;
                else
                    next_state <= phase1_start;
                end if;
            when collect_data =>  
                rst <= '0'; scan<='1'; start_module<= "00"; 
                next_state <= reset_phase;
            when reset_phase =>
                scan<='0'; rst <= '0'; start_module<= "00"; 
                next_state <= reset1;
            when reset1 =>  next_state <= reset2; rst <= '1';scan<='0';  start_module<= "00"; 
            when reset2 =>  next_state <= reset3; rst <= '1';scan<='0';  start_module<= "00"; 
            when reset3 =>  next_state <= reset4; rst <= '1';scan<='0';  start_module<= "00"; 
            when reset4 =>  next_state <= phase2_start; rst <= '0'; scan<='0'; start_module<= "00";  
            when phase2_start =>
                scan<='0'; rst <= '0'; start_module<= "11"; 
                if (finph2 ='1') then
                    next_state <= collect_data;
                else
                    next_state <= phase2_start;
                end if;
            when others =>                               
        end case;
    end process;
	
end;