library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.HMACSHA384_ISMAIL.all;

entity hmac_sha384 is
  port (	clk: in std_logic;
  		msg: in std_logic_vector((96*4)-1 downto 0);
  		hashed_code: out std_logic_vector(383 downto 0);
		start : in std_logic
	);
end entity ; -- main

architecture sha_behaviour of hmac_sha384 is
	signal salt : std_logic_vector(383 downto 0) := x"6a09a667f3bcc908bb67ae8584caa73b3c6ef372fe94f82ba54f53fa5f1d36f1510e527fade682d19b05688c2b3e6c1f";
	signal pepper : std_logic_vector(1023 downto 0):= x"E67FF540BA6F5C5B9FEFC68B395EC32843C4FA76355D8183146B0F7B531F2DCE810B3226EFCE3D6BE3F90F0298DBE6AF2FD41AD0B7847D8F8F0E7526CE7A85129EA6B45C3BFB9272B25CD24958C7856DF3A57A6BF748CA22D842EC5C82E09E8FF16EEB2D58DF82B9B73B452BA14D2DBF19016A21BA2E5EB5DADAFC3F921B3F11"; 
begin

p1: process (start) is
	begin

		 	hashed_code <= hmacsha384(salt,pepper,msg);
 end process;
end architecture;
