library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Test_Vectors is
    generic (WIDTH_IN : integer := 128 
        );
        port(	
            R1       	:	out std_logic_vector(WIDTH_IN-1 downto 0);    
            R2       	:	out std_logic_vector(WIDTH_IN-1 downto 0);    
            R3       	:	out std_logic_vector(WIDTH_IN-1 downto 0);    
            IDSN    	:	out std_logic_vector(WIDTH_IN-1 downto 0);
            start       :   out std_logic;
            enable      :   in  std_logic;
            complete    :   in  std_logic;
            clk			:	in  std_logic;
            reset		:	out std_logic	
        );
end Test_Vectors;

architecture Behavioral of Test_Vectors is

type test_vector is array (0 to 6) of std_logic_vector(WIDTH_IN-1 downto 0);
Signal R1_vec	: test_vector := (X"61F3AABB0C141C31AE00A8E7756E6AB5",X"A1F3A1010C141C31AE00A8E7756E6AB5",X"51A3BBF8AC141631AE29A8E7756E6AB5",X"65F3A32B0C141C31AE00A8E7756E6AB5",
                                  X"11F1A1A10C141C31AE19A8E7756E6A15",X"81A181F81A891631AE9048E7456E6AB5",X"D1A3B1F8AC141631AE21A8E7756E6AB5");
Signal R2_vec	: test_vector := (X"41F3AABB0C141C31AE00A8E7756E6AB5",X"21F3A1010C141C31AE00A8E7756E6AB5",X"f1A3BBF8AC141631AE29A8E7756E6AB5",X"15F3A32B0C141C31AE00A8E7756E6AB5",
                                  X"a1F1A1A10C141C31AE19A8E7756E6A15",X"d1A181F81A891631AE9048E7456E6AB5",X"D1A3B1F8AC141631AE21A8E7756E6AB5");
Signal IDSN_vec	: test_vector := (X"767F6BD5FAC0738A04BF2BB4935A573D",X"F57F6BD2FAC0738A04B12BB4935A573D",X"467F6BD5FAC1538A04B320B4935A573D",X"1C6C060A6C3F24357201F8E77FB1BAD0",
                                  X"757F61A2FAC3738A04312BB4935A5731",X"467F3542F91A7395A42F2BC4935A5732",X"C67F6BD5F1C1138A04B320B4935A573D");
Signal R3_vec   : test_vector := (X"5D93AABB6C171C362E00A8E8956E6F85",X"ffb0e5a9429f9667a935f6512b4a698f",X"0f7717ae2e0858dcf3723b3df49e174d",X"5288ba48f1176bad22f7696978890de0",
                                  X"e5324e68f30e0c143dcb00f50b43ffb6",X"1859e864ff89a3daa66e01a65383b79b",X"18d53c275a783c85068e9791b750af30");
type test_vector_fsm is (idle, rst, test, done);
signal current_state, next_state : test_vector_fsm;

Signal iter : natural := 0;
begin
    --current state logic
    process(clk)
    begin
        if(clk'event and clk='1') then 
            current_state <= next_state;
        end if;
    end process;
    
    process(current_state, enable,complete)
    --Variable iter : natural range 0 to 6;
    begin
        iter <= iter;
        case current_state is
            when idle =>
                iter <= 0;
                R1 <= (others => '0');
                R2 <= (others => '0');
                R3 <= (others => '0');
                IDSN <= (others => '0');
                reset <= '0'; 
                start <= '0'; 
                if(enable='1') then
                    next_state <= rst;
                else
                    next_state <= idle;
                end if;
            when rst =>            
                reset <= '1'; 
                start <= '0'; 
                next_state <= test;
            when test =>
                R1 <= R1_vec(iter);
                R2 <= R2_vec(iter);
                R3 <= R3_vec(iter);
                IDSN <= IDSN_vec(iter);
                reset <= '0'; 
                start <= '1'; 
                if (complete='1') then
                    if (iter = 6) then
                        next_state <= done;
                    else
                        iter <= iter + 1;
                        next_state <= test;
                    end if;
                else
                    next_state <= test;
                end if;
            when done =>  
            when others =>                               
        end case;
    end process;


end Behavioral;
