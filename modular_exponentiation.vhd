-- Entity name: montgomery_multiplier
-- Author: Stephen Carter
-- Contact: stephen.carter@mail.mcgill.ca
-- Date: March 10th, 2016
-- Description: Performs modular multiplication. See paper for more information. Designed for use with RSA Encryption. 
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity modular_exponentiation is

	generic(WIDTH_IN : integer := 128
	);
	port(	N :	  in unsigned(WIDTH_IN-1 downto 0); --Number
		--Exp :	  in unsigned(WIDTH_IN-1 downto 0); --Exponent
		--M :	  in unsigned(WIDTH_IN-1 downto 0); --Modulus
		enc_dec:  in std_logic;
		finish:  out std_logic;
		start:    in  std_logic;
		clk :	  in std_logic;
		reset :	  in std_logic;
		C : 	  out std_logic_vector(WIDTH_IN-1 downto 0) --Output
	);
end entity;

architecture behavior of modular_exponentiation is 

constant zero : unsigned(WIDTH_IN-1 downto 0) := (others => '0');

--------------------------------------128 bit constants------------------------------------------------
constant K : unsigned (WIDTH_IN-1 downto 0) := X"0646E120BDDCBD8CABCB6A850B11DA1E";
constant M : unsigned (WIDTH_IN-1 downto 0) := X"84478485936A91ACCB802C53877527D1";
constant dec_Exp : unsigned(WIDTH_IN-1 downto 0) := X"2AC591453BC87EB46FDF80E93756B5C1";
constant enc_Exp : unsigned(WIDTH_IN-1 downto 0) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";
-------------------------------------------------------------------------------------------------------

-- Intermidiate signals
signal temp_A1,temp_A2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal temp_B1, temp_B2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal temp_d_ready, temp_d_ready2 : std_logic := '0';
signal temp_M1, temp_M2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal N_in : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

signal latch_in, latch_in2 : std_logic := '0';

signal temp_M : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal temp_C : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');

signal count : integer := 0; 
signal shift_count : integer := 0;
signal temp_N : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
signal P : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
signal P_old : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
signal R : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
signal temp_Exp : unsigned(WIDTH_IN-1 downto 0);
signal temp_mod : unsigned(WIDTH_IN-1 downto 0);

-- FSM states
type STATE_TYPE is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10,done);
signal state: STATE_TYPE := s0;
--signal finish: std_logic:='0';

component montgomery_multiplier
Generic(WIDTH_IN : integer := 8
	);
	Port(	A :	in unsigned(WIDTH_IN-1 downto 0);
		B :	in unsigned(WIDTH_IN-1 downto 0);
		N :	in unsigned(WIDTH_IN-1 downto 0);
		latch : in std_logic;
		clk :	in std_logic;
		reset :	in std_logic;
		data_ready : out std_logic;
		M : 	out unsigned(WIDTH_IN-1 downto 0)
	);
end component;

begin

-- Montgomery Multiplier components

mont_mult_1: montgomery_multiplier
	generic map(WIDTH_IN => WIDTH_IN)
	port map(
		A => temp_A1, 
		B => temp_B1, 
		N => temp_M,
		latch => latch_in, 
		clk => clk, 
		reset => reset,
		data_ready => temp_d_ready, 
		M => temp_M1 
		);

mont_mult_2: montgomery_multiplier
	generic map(WIDTH_IN => WIDTH_IN)
	port map(
		A => temp_A2, 
		B => temp_B2, 
		N => temp_M, 
		latch => latch_in2, 
		clk => clk, 
		reset => reset,
		data_ready => temp_d_ready2,  
		M => temp_M2 
		);		
		
N_in <= N when start='1' else (others=>'0');

C <= std_logic_vector(temp_C) when state=done else (others=>'0');
finish <= '1' when state=done else '0';

sqr_mult : Process(clk, reset, N)

begin

if reset = '1' then
	count <= 0;
	shift_count <= 0;
	temp_N <= (others => '0');
	P <= (others => '0');
	R <= (others => '0');
	temp_Exp <= (others => '0');
	temp_mod <= (others => '0');	
	temp_M <= (others => '0');

	state <= s0;
	
elsif rising_edge(clk) then

case state is 
	
	-- Check if there are new inputs available 
	when s0 =>
	--(M = zero) OR (Exp = zero) OR
	if((N_in = zero)) OR ((temp_M = M)  AND (temp_N = N_in)) then
		state <= s0;
	else
		  temp_mod <= M;
		  state <= s1;
	end if;

	-- If MSB of modulus is not 1 then shift it left until a 1 is found and count how many times it was shifted
	when s1 =>
	
	if(temp_mod(WIDTH_IN-1) = '1')then			
		
		if(enc_dec = '1')then
			temp_Exp <= enc_Exp;
		else
			temp_Exp <= dec_Exp;
		end if;
		--temp_Exp <= Exp;
		temp_M <= M;
		temp_N <= N_in;
		state <= s2;
	else
		temp_mod <= (shift_left(temp_mod,natural(1)));
		shift_count <= shift_count + 1;
		state <= s1;
	end if;

	-- Compute initial value of P and R	
	when s2 => 
	
	if(unsigned(K) > zero)then
		temp_A1 <= unsigned(K);
		temp_B1 <= temp_N;
	
		temp_A2 <= unsigned(K);
		temp_B2 <= to_unsigned(1,WIDTH_IN);	
	
		latch_in <= '1';
		latch_in2 <= '1';
		
		if(temp_d_ready = '0') AND (temp_d_ready2 = '0')then
			state <= s3;
		end if;
	else
		state <= s2;
	end if;

	-- Assign the results of the computations
	when s3 =>
	latch_in <= '0';
	latch_in2 <= '0';
	
	if((temp_d_ready = '1') AND (temp_d_ready2 = '1')) then
		P_old <= temp_M1;
		R <= temp_M2;
		state <= s4;
	end if; 

	-- Check Listing 1 in report. This operation is inside the for loop and it is always performed
	when s4 =>
		temp_A1 <= P_old;
		temp_B1 <= P_old;
		latch_in <= '1';

		if(temp_d_ready = '0')then
			state <= s5;
		end if;

	-- If LSB of the exponent is 1 then compute R, else go to state 8
	when s5 =>
	latch_in <= '0';
	
	if(temp_d_ready = '1')then
		P <= temp_M1;
		if(temp_Exp(0) = '1')then
			state <= s6;
		else
			state <= s8;
		end if;
	end if;

	when s6 => 
		temp_A2 <= R;
		temp_B2 <= P_old;
		latch_in2 <= '1';

		if(temp_d_ready2 = '0')then
			state <= s7;
		end if;
		
	when s7 =>
		latch_in2 <= '0';
		if(temp_d_ready2 = '1') then
			R <= temp_M2;
			state <= s8;
		end if;
	
	-- If the statement is true, it means that we have checked all bits in the exponent or exponent is zero and we compute the output
	when s8 =>
		if (count = (WIDTH_IN-1)-shift_count) OR (temp_Exp = zero) then
			temp_A1 <= to_unsigned(1,WIDTH_IN);
			temp_B1 <= R;			
			state <= s9;
			
		else    -- if the statement is false, then we shift the exponent right and increment count
			temp_Exp <= (shift_right(temp_Exp, natural(1)));
			P_old <= P;
			count <= count + 1;
			state <= s4;
		end if;	
	
	when s9 =>
		
		latch_in <= '1';
		if(temp_d_ready ='0')then
			state <= s10;
		end if;

	when s10 =>
		latch_in <= '0';
		if(temp_d_ready = '1') then
			temp_C <= temp_M1;
			temp_Exp <= (others => '0');
			count <= 0;
			shift_count <= 0;
			P <= (others => '0');
			R <= (others => '0');
			temp_mod <= (others => '0');		
			state <= done;
		end if;
	when done =>
	
	end case;
end if;		

end process sqr_mult;
 
end behavior;  