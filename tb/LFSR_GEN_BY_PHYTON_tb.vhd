library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity LFSR_PYTHON_tb is
end LFSR_PYTHON_tb;

architecture rtl of LFSR_PYTHON_tb is	

    file LFSR_OUTPUT : text is out "LFSR_OUTPUT_STREAM.txt";
    file LFSR_INPUT : text is in "LFSR_SEED.txt";

    -- Testbench Constants
    constant T_CLK    : time      := 10 ns;
    constant T_RESET  : time      := 20 ns;
    constant Nbit     : positive  := 16;

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
    --reset_n_tb <= '1' after T_RESET;

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
    variable new_seed : line;
    variable initial_value : std_logic_vector(0 to Nbit-1);
    variable number_of_seeds : natural := 0;
    
    begin

        if(reset_n_tb = '0') then

            -- Reading a seed from the file
            readline(LFSR_INPUT, new_seed);
            read(new_seed, initial_value);

            seed_tb <= initial_value;
            reset_n_tb <= '1';
            seed_load_tb <= '1';

        elsif(rising_edge(clk_tb)) then
            seed_load_tb <= '0';

            -- When the current state is equal to the initial status (seed) it means that the LFSR will start generating the same output bits
            if(state_tb = seed_tb and seed_load_tb = '0') then
                number_of_seeds := number_of_seeds + 1;
                reset_n_tb <= '0';
            end if;

            if(number_of_seeds = 3) then
                report "Closing file..";
                file_close(LFSR_OUTPUT);
                file_close(LFSR_INPUT);
                end_sim <= '0';
            end if;

            if(seed_load_tb = '0') then
                WRITE(bit_to_write, output_bit_tb);
                WRITEline(LFSR_OUTPUT, bit_to_write);  
            end if;
        end if;

    end process;       

end rtl;