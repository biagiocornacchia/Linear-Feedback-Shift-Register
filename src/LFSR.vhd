----------------------------------------------------------------------------
-- LFSR with a polynomial feedback equal to x^16 + x^14 + x^13 + x^11 + 1
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

------------------------
--  ENTITY DECLARATION
------------------------

entity LFSR is 
    generic (
        Nbit    : positive  := 16
    );
    port (
        clk         : in std_logic;
        reset_n     : in std_logic; 
        seed        : in std_logic_vector(0 to Nbit-1);     -- Initial state of the LFSR (seed)
        seed_load   : in std_logic;                         -- In order to set the initial value after the reset of the circuit
        state       : out std_logic_vector(0 to Nbit-1);    -- Current state (for debugging)
        output_bit  : out std_logic
    );
end LFSR;

-------------------------------
--  ARCHITECTURE DELCARATION
-------------------------------

architecture rtl of LFSR is

    -- 16 instances of D flip-flop are used to generate a shift register 
    component DFF
        port (
            clk     : in    std_logic;
            reset_n : in    std_logic;
            d       : in    std_logic;
            q       : out   std_logic
        );
    end component DFF;

    signal feedback_bit : std_logic; -- Signal used to generate the feedback bit (the bit obtained xoring the 11th, 13th 14th and 16th bit of the current status)
    signal output_bit_s : std_logic;
    
    signal d_in : std_logic_vector (0 to Nbit-1);
    signal q_s  : std_logic_vector (0 to Nbit-2);

begin

    GEN: for i in 0 to Nbit-1 generate
        -- FIRST STAGE
        FIRST: if i = 0 generate
            FF0: DFF port map(
                d       => d_in(i),
                q       => q_s(i),
                reset_n => reset_n, 
                clk     => clk
            );
        end generate FIRST;
        -- INTERNAL STAGES
        INTERNAL: if i > 0 and i < Nbit-1 generate
            FFI: DFF port map (
                d       => d_in(i),
                q       => q_s(i),
                reset_n => reset_n, 
                clk     => clk
            );
        end generate INTERNAL;
        -- LAST STAGE
        LAST: if i = Nbit-1 generate
            FFN: DFF port map(
                d       => d_in(i),
                q       => output_bit_s,
                reset_n => reset_n, 
                clk     => clk
            );
        end generate LAST;
    end generate GEN;

    -- NOTE:
    -- At first time the feedback bit must be obtained using the seed which is the first state of the LFSR
    d_in <= seed(0 to 15) when seed_load = '1' else feedback_bit & q_s(0 to Nbit-2);

    feedback_bit <= (seed(15) xor seed(13)) xor seed(12) xor seed(10) when seed_load = '1' else (output_bit_s xor q_s(13)) xor q_s(12) xor q_s(10);
    
    state <= d_in;  -- Updating the current status
    output_bit <= output_bit_s;
    
end rtl;