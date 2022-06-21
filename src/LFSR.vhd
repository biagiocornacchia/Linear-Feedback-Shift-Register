----------------------------------------------------------------------------
-- LFSR with a polynomial feedback equal to x^16 + x^14 + x^13 + x^11 + 1
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

-------------------------
-- Entity declaration
-------------------------
entity LFSR is 
    generic (
        Nbit    : positive  := 16
    );
    port (
        clk         : in std_logic;
        reset_n     : in std_logic; 
        seed        : in std_logic_vector(0 to Nbit-1);     -- Initial state of the LFSR (seed)
        seed_load   : in std_logic;                         -- In order to set the initial value
        state       : out std_logic_vector(0 to Nbit-1);    -- Current state (used for testing)
        output_bit  : out std_logic
    );
end LFSR;

-------------------------------
--  Architecture Declaration
-------------------------------
architecture rtl of LFSR is

    -------------------------------------------------------------------------------------------
    -- D flip-flop used to generate a 16-bit shift register and to generate the seed load reg
    -------------------------------------------------------------------------------------------
    component DFF
        port (
            clk     : in    std_logic;
            reset_n : in    std_logic;
            d       : in    std_logic;
            q       : out   std_logic
        );
    end component DFF;

    --------------------------------------------------------
    -- D flip-flop 16 bit used to contain the initial value
    --------------------------------------------------------
    component DFF_N is
        generic(Nbit : positive := 16);
        port(
            clk     : in std_logic;
            reset_n : in std_logic;
            d_in    : in std_logic_vector(0 to Nbit-1);
            q_out   : out std_logic_vector(0 to Nbit-1)
        );
    end component DFF_N;

    signal seed_load_s  : std_logic;
    signal loaded_seed  : std_logic_vector (0 to Nbit-1);

    signal feedback_bit : std_logic; -- signal used to generate the feedback bit (the bit obtained xoring the 11th, 13th 14th and 16th bit of the current status)

    signal d_in : std_logic_vector (0 to Nbit-1);
    signal q_s  : std_logic_vector (0 to Nbit-2);
    signal output_bit_s : std_logic;

begin

    init_reg : DFF_N
    generic map(Nbit => 16)
    port map(
        clk     =>  clk,
        reset_n =>  reset_n,
        d_in    =>  seed,
        q_out   =>  loaded_seed
    );

    seed_load_reg : DFF
    port map(
        clk     =>  clk,
        reset_n =>  reset_n,
        d       =>  seed_load,
        q       =>  seed_load_s
    );

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

    MUX_1: process(seed_load_s, loaded_seed, q_s, feedback_bit, output_bit_s) 
    begin
        case seed_load_s is
            when '1' => d_in <= loaded_seed(0 to 15);
            when '0' => d_in <= feedback_bit & q_s(0 to Nbit-2);
            when others => d_in <= (others => '0');
        end case;
    end process;

    MUX_2: process(seed_load_s, loaded_seed, q_s, output_bit_s) 
    begin
        case seed_load_s is
            when '1' => feedback_bit <= (loaded_seed(15) xor loaded_seed(13)) xor loaded_seed(12) xor loaded_seed(10);
            when '0' => feedback_bit <= (output_bit_s xor q_s(13)) xor q_s(12) xor q_s(10);
            when others => feedback_bit <= '0';
        end case;
    end process;

    state <= q_s & output_bit_s; -- Updating the current status
    output_bit <= output_bit_s;

end rtl;