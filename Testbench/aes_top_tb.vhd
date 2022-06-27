--
-- Written by Michael Mattioli
--
-- Description: AES top level testbench.
--

library std;
library ieee;
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.aes.all;

entity aes_top_tb is
end aes_top_tb;

architecture behavioral of aes_top_tb is

    component aes_enc is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                enable      : in std_logic;
                key         : in std_logic_vector(127 downto 0);
                input       : in std_logic_vector(127 downto 0);
                output      : out std_logic_vector(127 downto 0);
                complete    : out std_logic);
    end component aes_enc;
        
    component aes_dec is
    port (  clk         : in std_logic; -- Clock.
            rst         : in std_logic; -- Reset.
            enable      : in std_logic; -- Enable.
            key         : in std_logic_vector(127 downto 0); -- Secret key.
            input       : in std_logic_vector(127 downto 0); -- Input (plaintext or ciphertext).
            output      : out std_logic_vector(127 downto 0); -- Output (plaintext or ciphertext).
            complete    : out std_logic); -- Identify when the operation is complete.
    end component;
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal enable,enabled,enablee,enabledd : std_logic := '0';
    signal inverse : std_logic := '0';
    signal key: std_logic_vector(127 downto 0);
    signal input : std_logic_vector(127 downto 0);
    signal output,output1,outputd,outputdt : std_logic_vector(127 downto 0);
    signal complete,complete1,completed,completedt : std_logic;
    
    constant clock_period : time := 10ns;

begin

    --Instantiate the unit under test.
    uut: aes_enc port map ( clk => clk,
                            rst => rst,
                            enable => enablee,
                            key => key,
                            input => input,
                            output => output1,
                            complete => complete1);
    
    uu2: aes_dec port map ( clk => clk,
                            rst => rst,
                            enable => enabled,
                            key => key,
                            input => input,
                            output => outputd,
                            complete => completed);

    -- Apply the clock.
    applied_clock : process
    begin
        wait for clock_period / 2;
        clk <= not clk;
    end process applied_clock;
    
    -- Apply the stimuli.
    stimuli : process
    begin
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        -- Encryption.
        inverse <= '0';
        
        key <= x"2b7e151628aed2a6abf7158809cf4f3c";
        input <= x"00000000000000000000000000000000";
        enable <= '1';
        enablee <= '1';
        wait until complete = '1';
        wait for 1us;
        enable <= '0';
        enablee <= '0';
        
        wait for 1us;
        --assert (output = x"7df76b0c1ab899b33e42f047b91b546f");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        key <= x"2b7e151628aed2a6abf7158809cf4f3c";
        input <= x"ae2d8a571e03ac9c9eb76fac45af8e51";
        enable <= '1';
        enablee <= '1';
        wait until complete = '1';
        wait for 1us;
        enable <= '0';
        enablee <= '0';
        wait for 1us;
        --assert (output = x"f5d3d58503b9699de785895a96fdbaaf");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        key <= x"00000000000000000000000000000000";
        input <= x"f69f2445df4f9b17ad2b417be66c3710";
        enable <= '1';
        enablee <= '1';
        wait until complete = '1';
        wait for 1us;
        enable <= '0';
        enablee <= '0';
        wait for 1us;
        --assert (output = x"664dfe9e123959a00127484f77fbad63");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        key <= x"00000000000000000000000000000000";
        input <= x"00000000000000000000000000000000";
        enable <= '1';
        enablee <= '1';
        wait until complete = '1';
        wait for 1us;
        enable <= '0';
        enablee <= '0';
        wait for 1us;
        --assert (output = x"66e94bd4ef8a2c3b884cfa59ca342b2e");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        -- Decryption.
        inverse <= '1';
        
        key <= x"2b7e151628aed2a6abf7158809cf4f3c";
        input <= x"7df76b0c1ab899b33e42f047b91b546f";
        enabledd <= '1';
        enabled <= '1';
        wait until completedt = '1';
        wait for 1 us;
        enabledd <= '0';
        enabled <= '0';
        
        wait for 1 us;
        --assert (output = x"00000000000000000000000000000000");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        key <= x"2b7e151628aed2a6abf7158809cf4f3c";
        input <= x"f5d3d58503b9699de785895a96fdbaaf";
        enabledd <= '1';
        enabled <= '1';
        wait until completedt = '1';
        wait for 1us;
        enabledd <= '0';
        enabled <= '0';
        wait for 1us;
        --assert (output = x"ae2d8a571e03ac9c9eb76fac45af8e51");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        key <= x"00000000000000000000000000000000";
        input <= x"664dfe9e123959a00127484f77fbad63";
        enabledd <= '1';
        enabled <= '1';
        wait until completedt = '1';
        wait for 1us;
        enabledd <= '0';
        enabled <= '0';
        wait for 1us;
        --assert (output = x"f69f2445df4f9b17ad2b417be66c3710");
        
        rst <= '1';
        wait for clock_period * 2;
        rst <= '0';
        
        key <= x"00000000000000000000000000000000";
        input <= x"66e94bd4ef8a2c3b884cfa59ca342b2e";
        enabledd <= '1';
        enabled <= '1';
        wait until completedt = '1';
        wait for 1us;
        enabledd <= '0';
        enabled <= '0';
        wait for 1us;
        --assert (output = x"00000000000000000000000000000000");
        
        finish(0);
    end process stimuli;

end behavioral;
