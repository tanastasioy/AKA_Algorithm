library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF_1 is
    Port ( D : in STD_LOGIC;
           SI  : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC);
end DFF_1;

architecture Behavioral of DFF_1 is
    signal DFF_D   :  STD_LOGIC;

begin
    ----- Multiplexer Architecture ------
    with SE select
        DFF_D <= D when '1',
                 SI when others;
    ----- DFF Architecture ------
    process(clk,rst)
    begin
        if rst='1' then 
            Q <= '0';
        elsif (clk'event and clk='1') then
            Q <= DFF_D;
        end if;
    end process;
end Behavioral;
