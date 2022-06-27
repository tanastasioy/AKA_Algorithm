--
-- Written by Michael Mattioli
--
-- Description: AES ShiftRows operation.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.aes.all;

entity aes_dec_shift_rows is
    port (  state   : in std_logic_vector(127 downto 0);
            result  : out std_logic_vector(127 downto 0));
end aes_dec_shift_rows;

architecture structural of aes_dec_shift_rows is
    signal inverse_shift : std_logic_vector(127 downto 0);
begin
    
    inverse_shift(127 downto 120) <= state(127 downto 120);
    inverse_shift(119 downto 112) <= state(23 downto 16);
    inverse_shift(111 downto 104) <= state(47 downto 40);
    inverse_shift(103 downto 96) <= state(71 downto 64);
    inverse_shift(95 downto 88) <= state(95 downto 88);
    inverse_shift(87 downto 80) <= state(119 downto 112);
    inverse_shift(79 downto 72) <= state(15 downto 8);
    inverse_shift(71 downto 64) <= state(39 downto 32);
    inverse_shift(63 downto 56) <= state(63 downto 56);
    inverse_shift(55 downto 48) <= state(87 downto 80);
    inverse_shift(47 downto 40) <= state(111 downto 104);
    inverse_shift(39 downto 32) <= state(7 downto 0);
    inverse_shift(31 downto 24) <= state(31 downto 24);
    inverse_shift(23 downto 16) <= state(55 downto 48);
    inverse_shift(15 downto 8) <= state(79 downto 72);
    inverse_shift(7 downto 0) <= state(103 downto 96);

    result <= inverse_shift;

end structural;
