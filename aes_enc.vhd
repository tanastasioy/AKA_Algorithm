--
-- Written by Michael Mattioli
--
-- Description: AES top level.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.aes.all;

entity aes_enc is
    port (  clk         : in std_logic; -- Clock.
            rst         : in std_logic; -- Reset.
            enable      : in std_logic; -- Enable.
            key         : in std_logic_vector(127 downto 0); -- Secret key.
            input       : in std_logic_vector(127 downto 0); -- Input (plaintext or ciphertext).
            output      : out std_logic_vector(127 downto 0); -- Output (plaintext or ciphertext).
            complete    : out std_logic); -- Identify when the operation is complete.
end aes_enc;

architecture behavioral of aes_enc is

    -- State machine for the top level module.
    type top_state is (idle, generate_keys, encrypt, decrypt,reset,done);
    signal current_state_top : top_state := idle;
    
    -- State machine for each round.
    type round_state is (pre_round, sub_bytes, shift_rows, mix_columns, add_round_key, get_result, intermediary_wait);
    signal current_state_round : round_state := pre_round;
    signal next_state_round : round_state;

    -- ShiftRows operation.
    component aes_enc_shift_rows is
        port (  state   : in std_logic_vector(127 downto 0);
                result  : out std_logic_vector(127 downto 0));
    end component aes_enc_shift_rows;
    
    -- AddRoundKey operation.
    component aes_add_round_key is
        port (  state       : in std_logic_vector(127 downto 0);
                round_key   : in std_logic_vector(127 downto 0);
                result      : out std_logic_vector(127 downto 0));
    end component aes_add_round_key;
    
    -- Key schedule.
    component aes_key_schedule is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                enable      : in std_logic;
                key         : in std_logic_vector(127 downto 0);
                round_keys  : out std_logic_vector((128*(rounds+1))-1 downto 0);
                complete    : out std_logic);
    end component aes_key_schedule;
    
    -- SubBytes operation.
    component aes_enc_sub_bytes is
        port (  state   : in std_logic_vector(127 downto 0);
                result  : out std_logic_vector(127 downto 0));
    end component aes_enc_sub_bytes;
    
    -- MixColumns operation.
    component aes_enc_mix_columns is
        port (  state   : in std_logic_vector(127 downto 0);
                result  : out std_logic_vector(127 downto 0));
    end component aes_enc_mix_columns;

    -- Our round keys.
    type key_array is array (0 to rounds) of std_logic_vector(127 downto 0);
    signal round_keys : key_array;
    signal raw_round_key_output : std_logic_vector((128*(rounds+1))-1 downto 0);

    -- Indicates when the round keys are ready to be split up.
    signal keys_ready : std_logic := '0';
    
    -- Indicates that the keys have been split up into distinct keys.
    signal keys_split: std_logic := '0';
    
    -- What round are we on?
    signal current_round : integer range 0 to rounds;

    -- Indicates when entire operation (encryption or decryption) is complete.
    signal finished : std_logic := '0';
    
    -- Keep track of state throughout operations and rounds.
    signal round_result : std_logic_vector(127 downto 0);
    
    -- Signals for AddRoundKey operation.
    signal add_round_key_state, add_round_key_key, add_round_key_result : std_logic_vector(127 downto 0);
    
    -- Signals for SubBytes operation.
    signal sub_bytes_state, sub_bytes_result : std_logic_vector(127 downto 0);
    
    -- Signals for ShiftRows operation.
    signal shift_rows_state, shift_rows_result : std_logic_vector(127 downto 0);
    
    -- Signals for MixColumns operation.
    signal mix_columns_state, mix_columns_result : std_logic_vector(127 downto 0);
    
    signal count_iter : integer := 0;

begin

    key_generator : aes_key_schedule port map ( clk => clk,
                                                rst => rst,
                                                enable => enable,
                                                key => key,
                                                round_keys => raw_round_key_output,
                                                complete => keys_ready);
                                                
    operation_add_round_key : aes_add_round_key port map (  state => add_round_key_state,
                                                            round_key => add_round_key_key,
                                                            result => add_round_key_result);
                                                            
    operation_sub_bytes : aes_enc_sub_bytes port map (  state => sub_bytes_state,
                                                    result => sub_bytes_result);
                                                    
    operation_shift_rows : aes_enc_shift_rows port map (state => shift_rows_state,
                                                    result => shift_rows_result);
                                                    
    operation_mix_columns : aes_enc_mix_columns port map (  state => mix_columns_state,
                                                        result => mix_columns_result);

    state_machine_top : process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state_top <= reset;
            end if;
                case current_state_top is
                    when reset =>
                        if (rst='1') then
                            current_state_top <= reset;
                        else
                            current_state_top <= idle;
                        end if;
                    when idle =>
                        if enable = '1' and finished = '0' then
                            current_state_top <= generate_keys;
                        end if;
                    when generate_keys =>
                        if keys_split = '1' then
                            current_state_top <= encrypt;
                        end if;  
                    when encrypt =>                        
                        if finished ='1' then
                            current_state_top <= done;
                        end if;                     
                    when done =>
                    when others =>
                end case;
        end if;
    end process state_machine_top;

    generate_round_keys : process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                keys_split <= '0';
            elsif current_state_top = generate_keys then
                if keys_ready = '1' then
                    for i in 0 to round_keys'length-1 loop
                        round_keys(i) <= raw_round_key_output(((11*128)-1)-(i*128) downto (10*128)-(i*128));
                    end loop;
                    keys_split <= '1';
                end if;
            end if;
        end if;
    end process generate_round_keys;
    
    round_counter : process(clk, rst)
    begin
        if rising_edge(clk) then
                case current_state_top is
                    when reset => 
                        output <= (others=>'0');
                        complete <= '0';
                        current_round <= 0;
                    when idle =>
                        current_round <= 0;
                    when encrypt =>
                        if current_state_round = get_result then
                            current_round <= current_round + 1;
                        end if;         
                    when done =>
                        output <= round_result;
                        complete <= finished;
                    when others =>
                end case;
        end if;
    end process round_counter;
    
    encrypt_or_decrypt : process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state_round <= pre_round;
                finished <= '0';
            elsif current_state_top = encrypt then
                count_iter <= current_round;
                case current_state_round is
                    when intermediary_wait =>
                        current_state_round <= next_state_round;
                    when pre_round =>
                        next_state_round <= add_round_key;
                        current_state_round <= intermediary_wait;
                    when sub_bytes =>
                        sub_bytes_state <= round_result;
                        next_state_round <= shift_rows;
                        current_state_round <= intermediary_wait;
                    when shift_rows =>
                        shift_rows_state <= sub_bytes_result;
                        if count_iter = rounds then
                            next_state_round <= add_round_key;
                        elsif count_iter < rounds then
                            next_state_round <= mix_columns;
                        end if;
                        current_state_round <= intermediary_wait;
                    when mix_columns =>
                        mix_columns_state <= shift_rows_result;
                        next_state_round <= add_round_key;
                        current_state_round <= intermediary_wait;
                    when add_round_key =>
                        if count_iter = 0 then
                            add_round_key_state <= input;
                        elsif count_iter = rounds then
                            add_round_key_state <= shift_rows_result;
                        elsif count_iter < rounds then
                            add_round_key_state <= mix_columns_result;
                        end if;
                        add_round_key_key <= round_keys(count_iter);
                        next_state_round <= get_result;
                        current_state_round <= intermediary_wait;
                    when get_result =>
                        round_result <= add_round_key_result;
                        if current_round = rounds then
                            finished <= '1';                   
                        else
                            next_state_round <= sub_bytes;
                            current_state_round <= intermediary_wait;
                        end if;
                    when others =>
                end case;
            end if;
        end if;
    end process encrypt_or_decrypt;

    

end behavioral;
