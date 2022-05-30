library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sha_256_pkgp1 is
    constant WORD_SZ : natural := 32;
    
    --array types for SHA-256
    type K_DATA is array (0 to 63) of std_logic_vector(WORD_SZ-1 downto 0);
    type M_DATA is array (0 to 15) of std_logic_vector(WORD_SZ-1 downto 0);
    type H_DATA is array (0 to 7) of std_logic_vector(WORD_SZ-1 downto 0);
    
    
    --function definitions
    function ROTR (a : std_logic_vector(WORD_SZ-1 downto 0); n : natural)
                    return std_logic_vector;
    function ROTL (a : std_logic_vector(WORD_SZ-1 downto 0); n : natural)
                    return std_logic_vector;
    function SHR (a : std_logic_vector(WORD_SZ-1 downto 0); n : natural)
                    return std_logic_vector;
    function CH (x : std_logic_vector(WORD_SZ-1 downto 0);
                    y : std_logic_vector(WORD_SZ-1 downto 0);
                    z : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector;
    function MAJ (x : std_logic_vector(WORD_SZ-1 downto 0);
                    y : std_logic_vector(WORD_SZ-1 downto 0);
                    z : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector;
                    
    function SIGMA_UCASE_0 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector;
    function SIGMA_UCASE_1 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector;
    function SIGMA_LCASE_0 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector;
    function SIGMA_LCASE_1 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector;
                    
end package;

package body sha_256_pkgp1 is
    function ROTR (a : std_logic_vector(WORD_SZ-1 downto 0); n : natural)
                    return std_logic_vector is
        --result : std_logic_vector(WORD_SZ-1 downto 0);
    begin
        --signal result : std_logic_vector(WORD_SZ-1 downto 0);
        return (std_logic_vector(shift_right(unsigned(a), n))) or std_logic_vector((shift_left(unsigned(a), (WORD_SZ-n))));
    end function;
    
    function ROTL (a : std_logic_vector(WORD_SZ-1 downto 0); n : natural)
                    return std_logic_vector is
        --result : std_logic_vector(WORD_SZ-1 downto 0);
    begin
        --signal result : std_logic_vector(WORD_SZ-1 downto 0);
        return (std_logic_vector(shift_left(unsigned(a), n))) or std_logic_vector((shift_right(unsigned(a), (WORD_SZ-n))));
    end function;
    
    function SHR (a : std_logic_vector(WORD_SZ-1 downto 0); n : natural)
                    return std_logic_vector is
    begin
        return std_logic_vector(shift_right(unsigned(a), n));
    end function;
    
    function CH (x : std_logic_vector(WORD_SZ-1 downto 0);
                    y : std_logic_vector(WORD_SZ-1 downto 0);
                    z : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector is
    begin
        return (x and y) xor (not(x) and z);
    end function;
    
    function MAJ (x : std_logic_vector(WORD_SZ-1 downto 0);
                    y : std_logic_vector(WORD_SZ-1 downto 0);
                    z : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector is
    begin
        return (x and y) xor (x and z) xor (y and z);
    end function;
    
    function SIGMA_UCASE_0 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 2) xor ROTR(x, 13) xor ROTR(x, 22);
    end function;
    
    function SIGMA_UCASE_1 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 6) xor ROTR(x, 11) xor ROTR(x, 25);
    end function;
    
    function SIGMA_LCASE_0 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 7) xor ROTR(x, 18) xor SHR(x, 3);
    end function;
    
    function SIGMA_LCASE_1 (x : std_logic_vector(WORD_SZ-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 17) xor ROTR(x, 19) xor SHR(x, 10);
    end function;
    
end package body;

