library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF_384 is
    Port ( D : in STD_LOGIC_VECTOR (383 downto 0);
           SI  : in STD_LOGIC_VECTOR (383 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           SE  : in STD_LOGIC;
            Q : out STD_LOGIC_VECTOR (383 downto 0));
end DFF_384;

architecture Behavioral of DFF_384 is
    signal DFF_D   :  STD_LOGIC_VECTOR (383 downto 0);

begin
    ----- Multiplexer Architecture ------
    with SE select
        DFF_D <= D when '1',
                 SI when others;
    ----- DFF Architecture ------
    process(clk,rst)
    begin
        if rst='1' then 
            Q <= (others=>'0');
        elsif (clk'event and clk='1') then
            Q <= DFF_D;
        end if;
    end process;
end Behavioral;
