library IEEE;
use IEEE.std_logic_1164.all;

entity DFF_N_tb is			
end DFF_N_tb;

architecture beh of DFF_N_tb is

    -- Testbench Constants
    constant T_CLK     : time      := 100 ns;
    constant Nbit      : positive  := 8;
	
    -- Testbench Signals	
	signal clk_ext     	: std_logic := '0';
	signal d_in_ext    	: std_logic_vector(Nbit-1 downto 0) := (others => '0');
	signal q_out_ext   	: std_logic_vector(Nbit-1 downto 0);
	signal reset_n_ext	: std_logic := '0';
	signal testing  	: boolean := true;
	
    -- Top level component declaration
	component DFF_N is
		generic(Nbit : positive := 8);
		port( 
			clk     : in std_logic;
			reset_n : in std_logic; -- async reset
			d_in	: in std_logic_vector(0 to Nbit-1);
			q_out	: out std_logic_vector(0 to Nbit-1)
		);				
	end component DFF_N;
	
begin
	clk_ext <= not clk_ext after T_CLK/2 when testing else '0';

	dut: DFF_N
	generic map(
		Nbit => Nbit
		)
	port map(
		d_in	=>	d_in_ext,
		q_out	=>	q_out_ext,
		reset_n	=>	reset_n_ext,
		clk		=>	clk_ext
		);

	stimulus: process
		begin
			d_in_ext 	 	<= (others => '1');
			reset_n_ext <= '0';
			wait until rising_edge(clk_ext);
			reset_n_ext <= '1';
			wait until rising_edge(clk_ext);
			d_in_ext 	 	<= "10000001";
			wait until rising_edge(clk_ext);
			d_in_ext 	 	<= "11111111";
			wait until rising_edge(clk_ext);
			reset_n_ext <= '0';
			wait until rising_edge(clk_ext);
			d_in_ext 	 	<= "10111111";
			reset_n_ext <= '1';
			wait until rising_edge(clk_ext);
			testing  <= false;
	end process;
end beh;
    