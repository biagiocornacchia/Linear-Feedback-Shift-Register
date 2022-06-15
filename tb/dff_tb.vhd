library IEEE;
use IEEE.std_logic_1164.all;

entity DFF_tb is
end DFF_tb;

architecture beh of DFF_tb is

    -- Testbench Constants
    constant T_CLK         : time      := 25 ns; 

    -- Top level component declaration
    component DFF is
		port( 
			clk     : in std_logic;
			reset_n : in std_logic;
			d       : in std_logic;
			q       : out std_logic
		);			
	end component DFF;

    -- Testbench signals
	signal clk      	: std_logic := '0';
	signal d_ext    	: std_logic := '1';
	signal q_ext    	: std_logic;
	signal reset_n_ext	: std_logic := '0';
	signal testing  	: boolean := true;

    begin
        -- Clock signal assignment
        clk <= not clk after T_CLK/2 when testing else '0';

        -- Component instance
        dut: DFF
        port map(
            d		=>	d_ext,
            q		=>	q_ext,
            reset_n	=>	reset_n_ext,
            clk		=>	clk
        );
    
        stimulus: process
            begin
                d_ext 	 	<= '0';            
                reset_n_ext <= '1';
                wait for 100 ns;
                d_ext 	 	<= '1';
                wait until rising_edge(clk);
                d_ext 	 	<= '0';
                wait for 130 ns;
                d_ext 	 	<= '1';
                wait for 170 ns;
                d_ext 	 	<= '1';
                wait for 200 ns;
                d_ext 	 	<= '0';
                wait for 230 ns;
                d_ext 	 	<= '1';
                -- test reset
                wait for 320 ns;   
                d_ext 	 	<= '1';             
                reset_n_ext <= '0';
                wait until rising_edge(clk);
                d_ext 	 	<= '1';
                reset_n_ext <= '1';
                wait until rising_edge(clk);
                d_ext 	 	<= '0';
                wait for 500 ns;
                testing  <= false;
        end process;
    end beh;