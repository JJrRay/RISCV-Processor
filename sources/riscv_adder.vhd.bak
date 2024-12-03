-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     riscv_adder.vhd
-- Author   Théo Dupuis  <theo.dupuis@polymtl.ca>
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	adder with ripple-carry
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	-----------------------------------------------------------------------
	-- Description 	Half-adder 
	-----------------------------------------------------------------------
entity half_adder is
port (
  a,b     : in     std_logic;
  sum,carry   : out     std_logic
);
end entity half_adder;

architecture beh1 of half_adder is

begin
-- combinatorial adder
  	sum <= a XOR b;
	carry <= a AND b;
end beh1;


	-----------------------------------------------------------------------
	-- Description 	adder with ripple-carry
	-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_adder is
  generic (
    N : positive := 32
  );
  port (
    i_a    : in  std_logic_vector(N-1 downto 0);
    i_b    : in  std_logic_vector(N-1 downto 0);
    i_sign : in  std_logic; -- inputs are unsigned(0) or signed(1) integers
    i_sub  : in  std_logic; -- adder performs addition(0) or substraction(1)
    o_sum  : out std_logic_vector(N downto 0)
  );
end entity riscv_adder;

architecture beh2 of riscv_adder is
--------------------------------------
--------- COMPLETE FROM HERE ---------
    component half_adder is
        port (
           	a,b     : in     std_logic;
  		sum, carry   : out     std_logic

        );
    end component;

-- declaration de signals
signal extend_a : std_logic_vector(N downto 0);
signal extend_b : std_logic_vector(N downto 0);
signal complement_b : std_logic_vector(N downto 0);

signal low_a : std_logic_vector(N  downto 0);
signal low_b : std_logic_vector(N downto 0);

signal carry_high : std_logic_vector(N downto 0);
signal carry_low : std_logic_vector(N downto 0);


begin
-- Sign extend
	extend_a(N-1 downto 0) <= i_a;
	extend_a(N) <= i_a(N-1) when i_sign = '1' else '0' ;

	extend_b(N-1 downto 0) <= i_b;
	extend_b(N) <= i_b(N-1) when i_sign = '1' else '0' ;

-- 2'complement

	complement_b <= std_logic_vector(not(signed(extend_b))+1) when i_sub= '1' else extend_b;
carry_high(0)<='0';
carry_low(0)<='0';
low_b(0)<='0';
-- adder
	gen_adder:for i in 0 to N generate 

		first_adder: half_adder port map (a=>extend_a(0),
 					 	 b=>extend_b(0),
 					 	 sum=>o_sum(0),
 					 	 carry => low_a(0));

		generic_adder : if (i > 0 and i <= N)  generate
	
			adder_high: half_adder port map (a=>extend_a(i),
					     	    b=>extend_b(i),
					            sum=>low_b(i),
					            carry => carry_high(i));

			adder_low : half_adder port map(a => low_a(i-1),
					        	b => low_b(i),
					        	sum => o_sum(i),
					        	carry => carry_low(i));

			low_a(i) <= carry_high(i) or carry_low(i);

		end generate generic_adder;
	end generate gen_adder;

end architecture beh2;
