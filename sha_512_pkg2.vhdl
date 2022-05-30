library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sha_512_pkg2 is
    constant WORD_SIZE : natural := 64; --SHA-512 uses 64-bit words
    
    --array types for SHA-512
    type K_DATA is array (0 to 79) of std_logic_vector(WORD_SIZE-1 downto 0);
    type M_DATA is array (0 to 15) of std_logic_vector(WORD_SIZE-1 downto 0);
    type H_DATA is array (0 to 7) of std_logic_vector(WORD_SIZE-1 downto 0);
    
    --Message blocks, the padded message should be a multiple of 512 bits,
    signal M : M_DATA;
    
    --function definitions
    function ROTR (a : std_logic_vector(WORD_SIZE-1 downto 0); n : natural)
                    return std_logic_vector;
    function ROTL (a : std_logic_vector(WORD_SIZE-1 downto 0); n : natural)
                    return std_logic_vector;
    function SHR (a : std_logic_vector(WORD_SIZE-1 downto 0); n : natural)
                    return std_logic_vector;
    function CH (x : std_logic_vector(WORD_SIZE-1 downto 0);
                    y : std_logic_vector(WORD_SIZE-1 downto 0);
                    z : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector;
    function MAJ (x : std_logic_vector(WORD_SIZE-1 downto 0);
                    y : std_logic_vector(WORD_SIZE-1 downto 0);
                    z : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector;
                    
    function SIGMA_UCASE_0 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector;
    function SIGMA_UCASE_1 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector;
    function SIGMA_LCASE_0 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector;
    function SIGMA_LCASE_1 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector;
                    
end package;

package body sha_512_pkg2 is
    function ROTR (a : std_logic_vector(WORD_SIZE-1 downto 0); n : natural)
                    return std_logic_vector is
        --result : std_logic_vector(WORD_SIZE-1 downto 0);
    begin
        --signal result : std_logic_vector(WORD_SIZE-1 downto 0);
        return (std_logic_vector(shift_right(unsigned(a), n))) or std_logic_vector((shift_left(unsigned(a), (WORD_SIZE-n))));
    end function;
    
    function ROTL (a : std_logic_vector(WORD_SIZE-1 downto 0); n : natural)
                    return std_logic_vector is
        --result : std_logic_vector(WORD_SIZE-1 downto 0);
    begin
        --signal result : std_logic_vector(WORD_SIZE-1 downto 0);
        return (std_logic_vector(shift_left(unsigned(a), n))) or std_logic_vector((shift_right(unsigned(a), (WORD_SIZE-n))));
    end function;
    
    function SHR (a : std_logic_vector(WORD_SIZE-1 downto 0); n : natural)
                    return std_logic_vector is
    begin
        return std_logic_vector(shift_right(unsigned(a), n));
    end function;
    
    function CH (x : std_logic_vector(WORD_SIZE-1 downto 0);
                    y : std_logic_vector(WORD_SIZE-1 downto 0);
                    z : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        return (x and y) xor (not(x) and z);
    end function;
    
    function MAJ (x : std_logic_vector(WORD_SIZE-1 downto 0);
                    y : std_logic_vector(WORD_SIZE-1 downto 0);
                    z : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        return (x and y) xor (x and z) xor (y and z);
    end function;
    
    function SIGMA_UCASE_0 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 28) xor ROTR(x, 34) xor ROTR(x, 39);
    end function;
    
    function SIGMA_UCASE_1 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 14) xor ROTR(x, 18) xor ROTR(x, 41);
    end function;
    
    function SIGMA_LCASE_0 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 1) xor ROTR(x, 8) xor SHR(x, 7);
    end function;
    
    function SIGMA_LCASE_1 (x : std_logic_vector(WORD_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        return ROTR(x, 19) xor ROTR(x, 61) xor SHR(x, 6);
    end function;
    
end package body;

