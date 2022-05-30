library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.HMACSHA384_ISMAIL.all;

entity hmac_sha384_xmac is
  port (	clk: in std_logic;
  		msg: in std_logic_vector((128*4)-1 downto 0);
  		hashed_code: out std_logic_vector(383 downto 0);
		start : in std_logic
	);
end entity ; -- main

architecture sha_behaviour of hmac_sha384_xmac is
	signal salt : std_logic_vector(383 downto 0) := x"6a09a667f3bcc908bb67ae8584caa73b3c6ef372fe94f82ba54f53fa5f1d36f1510e527fade682d19b05688c2b3e6c1f";
	signal pepper : std_logic_vector(1023 downto 0):= x"5166546A576E5A7234753777217A25432A462D4A614E645267556B58703273357638792F413F4428472B4B6250655368566D597133743677397A244326462948404D635166546A576E5A7234753778214125442A472D4B614E645267556B58703273357638792F423F4528482B4D6251655368566D597133743677397A244326"; 

begin
	
	p1: process (start) is
	begin
 		hashed_code <= hmacsha384(salt,pepper,msg);
	end process;
end architecture;
