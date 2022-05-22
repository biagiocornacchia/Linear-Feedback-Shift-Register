library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

--------------------
--     ENTITY
--------------------

entity shift_reg_tb is
end shift_reg_tb;

-----------------------------------------------------------------------
--      ARCHITECTURE (the internal description of the entity)
-----------------------------------------------------------------------

architecture rtl of shift_reg_tb is	

    file SHIFT_REG_OUT : text is out "shift_reg_out.tv";

    -- CONSTANTS
    constant clk_period     : time      := 10 ns;
    constant T_RESET        : time      := 20 ns;
    constant Nbit           : positive  := 16;

    -- SIGNALS
    signal d_in_ext         : std_logic := '0';
    signal d_out_ext        : std_logic;
    signal seed_ext         : std_logic_vector(0 to Nbit-1);
    signal state_ext        : std_logic_vector(0 to Nbit-1);
    signal feedback_bit_ext         : std_logic;
    signal clk              : std_logic := '0'; 
    signal reset_n_ext      : std_logic := '0';
    signal end_sim          : std_logic := '1';

    -- Top level component declaration
    component shift_reg
        generic (
            Nbit    : positive  := 16
        );
        port (
            d_in    : in std_logic;
            d_out   : out std_logic;
            seed    : in std_logic_vector(0 to Nbit-1);
            state   : out std_logic_vector(0 to Nbit-1);
            feedback_bit    : inout std_logic;
            reset_n : in std_logic; 
            clk     : in std_logic
        );
    end component;

    begin
    clk <= (not(clk) and end_sim) after clk_period / 2; 
    reset_n_ext <= '1' after T_RESET;

    -- Component instance
    dut: shift_reg
    generic map(
        Nbit    => Nbit
    )
    port map (
        d_in      =>  d_in_ext,
        d_out     =>  d_out_ext,
        seed      =>  seed_ext,
        state     =>  state_ext,
        feedback_bit      =>  feedback_bit_ext,
        clk       =>  clk,
        reset_n   =>  reset_n_ext
    );

    stimuli: process(clk, reset_n_ext) -- process used to make the testbench signals change synchronously with the rising edge of the clock
        variable t : integer := 0; -- variable used to count the clock cycle after the reset
        variable BUF : line;
    begin
        if(reset_n_ext = '0') then
            seed_ext <= "0000101011000110";
            t := 0;
        elsif(rising_edge(clk)) then

            if(state_ext = seed_ext) then
                end_sim <= '0';
            end if;
        
            WRITE(BUF, feedback_bit_ext);
            WRITEline(SHIFT_REG_OUT, BUF);    
                            
            t := t + 1;
        end if;
    end process;       
end rtl;