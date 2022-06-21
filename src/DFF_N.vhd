library IEEE;
use IEEE.std_logic_1164.all;

------------------------------------------------
-- Entity declaration
------------------------------------------------
entity DFF_N is
	generic(Nbit : positive := 16);
	port( 
		clk     	: in std_logic;
		reset_n 	: in std_logic; -- async reset
		d_in		: in std_logic_vector(0 to Nbit-1);
		q_out		: out std_logic_vector(0 to Nbit-1)
	);			
end DFF_N;

------------------------------------------------
-- Architecture declaration
------------------------------------------------
architecture beh of DFF_N is

    component DFF
        port (
            clk     : in    std_logic;
            reset_n : in    std_logic;
            d       : in    std_logic;
            q       : out   std_logic
        );
    end component DFF;
	
begin
	GEN: for i in 0 to Nbit-1 generate
		i_DFF: DFF port map(
			clk 	=> clk,
			reset_n => reset_n,
			d		=> d_in(i),
			q		=> q_out(i)
		);
		end generate GEN;
end beh;
    