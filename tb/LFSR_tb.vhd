library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity LFSR_tb is
end LFSR_tb;

architecture rtl of LFSR_tb is	

    file LFSR_OUTPUT : text is out "LFSR_OUTPUT_STREAM.txt";

    -- Testbench Constants
    constant T_CLK     : time      := 10 ns;
    constant T_RESET   : time      := 4 ns;
    constant Nbit      : positive  := 16;

    -- Testbench Signals
    signal output_bit_tb   : std_logic;
    signal seed_tb         : std_logic_vector(0 to Nbit-1);
    signal seed_load_tb    : std_logic := '0';
    signal state_tb        : std_logic_vector(0 to Nbit-1);
    signal clk_tb          : std_logic := '0'; 
    signal reset_n_tb      : std_logic := '0';
    signal end_sim         : std_logic := '1';

    -- Top level component declaration
    component LFSR
        generic (
            Nbit    : positive  := 16
        );
        port (
            clk         : in std_logic;
            reset_n     : in std_logic;
            seed        : in std_logic_vector(0 to Nbit-1);  
            seed_load   : in std_logic;
            state       : out std_logic_vector(0 to Nbit-1);
            output_bit  : out std_logic
        );
    end component;

    begin
    clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2; 
    reset_n_tb <= '1' after T_RESET;

    -- LFSR instance
    dut: LFSR
    generic map(
        Nbit    => Nbit
    )
    port map (
        clk        => clk_tb,
        reset_n    => reset_n_tb,
        seed       => seed_tb, 
        seed_load  => seed_load_tb,
        state      => state_tb,
        output_bit => output_bit_tb
    );

    stimuli: process(clk_tb, reset_n_tb) 

    variable bit_to_write : line;
    variable t : integer := 0;
    
    begin

        if(reset_n_tb = '0') then
            seed_tb <= "1000000000000001";
            seed_load_tb <= '1'; -- setting the initial value
            t := 0;
        elsif(rising_edge(clk_tb)) then
            seed_load_tb <= '0';
            
            -- When the current state is equal to the initial status (seed) it means that the LFSR will start generating the same output bits
            if(state_tb = seed_tb and t > 2) then
                end_sim <= '0';
            elsif(seed_load_tb = '0' and t >= 2) then
                -- After 2 clock cycles all the registers are ready -> start collecting output bits
                WRITE(bit_to_write, output_bit_tb);
                WRITEline(LFSR_OUTPUT, bit_to_write);  
            end if;

            t := t + 1;
        end if;
    end process;       

end rtl;