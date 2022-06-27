

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.aes.all;

entity aes_key_schedule is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            enable      : in std_logic;
            key         : in std_logic_vector(127 downto 0);
            round_keys  : out std_logic_vector((128*(rounds+1))-1 downto 0);
            complete    : out std_logic);
end aes_key_schedule;

architecture behavioral of aes_key_schedule is

    -- Round constants.
    type round_constant_words is array (1 to rounds) of std_logic_vector(31 downto 0);
    constant round_constant : round_constant_words := ( x"01000000",
                                                        x"02000000",
                                                        x"04000000",
                                                        x"08000000",
                                                        x"10000000",
                                                        x"20000000",
                                                        x"40000000",
                                                        x"80000000",
                                                        x"1b000000",
                                                        x"36000000");

    -- Round keys split into words (11 round keys with 4 words each = 44 total words).
    type key_words is array (0 to (4*(rounds+1))-1) of std_logic_vector(31 downto 0);
    signal words : key_words := (others=>(others=>'0'));
    
    -- Identify when the key is fully expanded and all of our round keys are ready.
    signal finished : std_logic := '0';
    
    -- Keep track of which word we're working on.
    signal current_word : integer range 0 to key_words'length-1 := 0;
    
    signal count_i :integer :=0;
    signal count_j :integer :=0;
    signal temp_word : std_logic_vector(31 downto 0) := (others=>'0');
    
    type state is ( reset, s0, s1, s2, s3, s4, s5, s6, s7, done );
    signal current_state : state;

begin

    state_machine : process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= reset;
            end if;
                case current_state is
                    when reset =>
                        if (rst='1') then
                            current_state <= reset;
                        elsif enable ='1' then
                            current_state <= s0;
                        end if;
                    when s0 =>
                        if current_word <= 3 then
                            current_state <= s1;
                        else 
                            current_state <= s2;                            
                        end if;
                    when s1 =>
                        if count_i = key_words'length-1 then
                            current_state <= done;
                        else 
                            current_state <= s7;
                        end if;  
                    when s2 =>                        
                        if current_word mod 4 = 0 then
                            current_state <= s3;
                        else 
                            current_state <= s6;
                        end if;    
                    when s3 =>                        
                        current_state <= s4;  
                    when s4 =>                        
                        if count_j <= 2 then
                            current_state <= s4;
                        else 
                            current_state <= s5;
                        end if;     
                    when s5 =>                        
                        current_state <= s6;  
                    when s6 =>
                        if current_word = key_words'length-1 then
                            current_state <= done;
                        else 
                            current_state <= s7;
                        end if;
                    when s7 =>                        
                        current_state <= s0;  
                    when done =>
                    when others =>
                end case;
        end if;
    end process state_machine;
    
    make_round_keys : process(clk, rst)
    begin
        if rising_edge(clk) then
                case current_state is
                    when reset => 
                        current_word <= 0;
                    when s0 =>
                    when s1 =>
                        words(current_word) <= key(127-(current_word*32) downto 96-(current_word*32));         
                    when s2 =>
                        temp_word <= words(current_word-1);
                    when s3 =>
                        temp_word <= temp_word(23 downto 0) & temp_word(31 downto 24);
                    when s4 =>
                        temp_word((8*(count_j+1))-1 downto (8*count_j)) <= normal_sbox(conv_integer(temp_word((8*(count_j+1))-1 downto (8*count_j)+4)), conv_integer(temp_word((8*(count_j+1))-1-4 downto (8*count_j))));  
                        count_j <= count_j +1;     
                    when s5 =>
                        temp_word <= temp_word xor round_constant(current_word/4);
                        count_j<=0;
                    when s6 =>
                        words(current_word) <= words(current_word-4) xor temp_word;
                    when s7 =>
                        current_word <= current_word + 1;         
                    when done =>                       
                    when others =>
                end case;
        end if;
    end process make_round_keys;

    finished <= '1' when current_state=done else '0';

    output_round_keys : for i in 0 to key_words'length-1 generate
        -- When i = 0 => round_keys(1407 downto 1376) <= words(0);
        -- When i = 43 => round_keys(31 downto 0) <= words(43);
        round_keys(((44*32)-1)-(i*32) downto (43*32)-(i*32)) <= words(i);
    end generate output_round_keys;
    
    complete <= finished;

end behavioral;