library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

--------------------
--     ENTITY
--------------------

entity LFSR_tb is
end LFSR_tb;

-----------------------------------------------------------------------
--      ARCHITECTURE (the internal description of the entity)
-----------------------------------------------------------------------

architecture rtl of LFSR_tb is	

    file LFSR_OUT : text is out "LFSR_out.tv";

    -- CONSTANTS
    constant clk_period     : time      := 10 ns; 
    constant T_RESET        : time      := 25 ns;
    constant Nbit           : positive  := 16;

    -- SIGNALS
    signal init_value_ext       : std_logic_vector(0 to Nbit-1);
    signal current_state_ext    : std_logic_vector(0 to Nbit-1);
    signal output_bit_ext       : std_logic;
    signal clk_tb               : std_logic := '0'; 
    signal reset_n_ext          : std_logic := '0';
    signal end_sim              : std_logic := '1';

    -- Top level component declaration
    component LFSR
        generic (
            Nbit    : positive  := 16
        );
        port (
            clk             : in    std_logic;
            reset_n         : in    std_logic;
            init_value      : in    std_logic_vector(0 to Nbit-1);
            output_bit      : out   std_logic;
            current_state   : out std_logic_vector(0 to Nbit-1)
        );
    end component;

    begin

    clk_tb <= (not(clk_tb) and end_sim) after clk_period / 2; 
    reset_n_ext <= '1' after T_RESET;

    -- Component instance
    dut: LFSR
    generic map(
        Nbit    => Nbit
    )
    port map (
        clk             => clk_tb,
        reset_n         => reset_n_ext,
        init_value      => init_value_ext,
        output_bit      => output_bit_ext,
        current_state   => current_state_ext
    );
    
    stimuli: process(clk_tb, reset_n_ext)
        
        variable line_to_write : line;

    begin
        if(reset_n_ext = '0') then
            init_value_ext <= "0000101011000110";
        elsif(rising_edge(clk_tb)) then

            if(current_state_ext = init_value_ext) then
                end_sim <= '0';
            end if;

            WRITE(line_to_write, output_bit_ext);
            WRITEline(LFSR_OUT, line_to_write);

        end if;
    end process;        
end rtl;