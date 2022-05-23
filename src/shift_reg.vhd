library IEEE;
use IEEE.std_logic_1164.all;

------------------------
--  ENTITY DECLARATION
------------------------

entity shift_reg is 
    generic (
        Nbit    : positive  := 16
    );
    port (
        d_out       : out std_logic;
        seed        : in std_logic_vector(0 to Nbit-1); -- initial state
        state       : out std_logic_vector(0 to Nbit-1); -- actual state
        reset_n     : in std_logic; 
        clk         : in std_logic
    );
end shift_reg;

------------------
--  ARCHITECTURE
------------------

architecture rtl of shift_reg is

    component dff
        port (
            d       : in    std_logic;
            q       : out   std_logic;
            set     : in    std_logic;
            reset_n : in    std_logic;
            clk     : in    std_logic
        );
    end component dff;

    signal q_s      : std_logic_vector (0 to Nbit-2);
    signal d_out_s  : std_logic;
    signal feedback_bit : std_logic;

begin

    GEN: for i in 0 to Nbit-1 generate
        -- FIRST STAGE
        FIRST: if i = 0 generate
            FF0: dff port map(
                d       => feedback_bit,
                q       => q_s(i),
                set     => seed(i),
                reset_n => reset_n, 
                clk     => clk
            );
        end generate FIRST;
        -- INTERNAL STAGE
        INTERNAL: if i > 0 and i < Nbit-1 generate
            FFI: dff port map (
                d       => q_s(i - 1),
                q       => q_s(i),
                set     => seed(i),
                reset_n => reset_n, 
                clk     => clk
            );
        end generate INTERNAL;
        -- LAST STAGE
        LAST: if i = Nbit-1 generate
            FFN: dff port map(
                d       => q_s(i-1),
                q       => d_out_s,
                set     => seed(i),
                reset_n => reset_n, 
                clk     => clk
            );
        end generate LAST;
    end generate GEN;

    d_out <= d_out_s;
    feedback_bit <= (d_out_s xor q_s(13)) xor q_s(12) xor q_s(10);
    state <= feedback_bit & q_s;

end rtl;