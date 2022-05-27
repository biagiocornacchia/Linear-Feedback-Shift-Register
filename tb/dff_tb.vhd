library IEEE;
use IEEE.std_logic_1164.all;

entity DFF_tb is
end DFF_tb;

architecture rtl of DFF_tb is

    -- Testbench Constants
    constant T_CLK   : time    := 10 ns;
	constant T_RESET : time    := 25 ns;

    -- Testbench Signals
    signal clk_tb       : std_logic := '0'; 
    signal reset_n_tb   : std_logic := '0';
    signal d_tb         : std_logic := '1';
    signal q_tb         : std_logic;
    signal end_sim      : std_logic := '1'; 

    -- Top level component declaration
    component DFF
        port (
            clk         : in    std_logic;
            reset_n     : in    std_logic;
            d           : in    std_logic;
            q           : out   std_logic
        );  
    end component;

    begin

    clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2; 
    reset_n_tb <= '1' after T_RESET;

    -- D Flip-Flop instance
    dut: DFF
    port map (
        clk     =>  clk_tb,
        reset_n =>  reset_n_tb,
        d       =>  d_tb,
        q       =>  q_tb
    );

	stimuli: process(clk_tb, reset_n_tb)
		variable t : integer := 0;
	begin
		if(reset_n_tb = '0') then
			d_tb <= '0';
			t := 0;
		elsif(rising_edge(clk_tb)) then
			case(t) is   
				when 1  => d_tb    <= '0';
				when 2  => d_tb    <= '1';
				when 3  => d_tb    <= '0';
				when 5  => d_tb    <= '1';
				when 7  => d_tb    <= '1';
                when 9  => d_tb    <= '0';
				when 10 => end_sim <= '0'; -- stop simulation
				when others => null;
			end case;
			
			t := t + 1; 
		end if;
	end process;

end rtl;