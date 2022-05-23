-- LFSR with feedback polynomial -> x^16 + x^14 + x^13 + x^11 + 1 

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
        init_value      : in std_logic_vector(0 to Nbit-1);
        output_bit      : out std_logic;
        current_state   : out std_logic_vector(0 to Nbit-1);
        reset_n         : in std_logic; 
        clk             : in std_logic
    );
end LFSR;

-------------------
--  ARCHITECTURE
-------------------

architecture rtl of LFSR is

    component shift_reg
        generic (
            Nbit        : positive  := 16
        );
        port (
            d_out       : out std_logic;
            seed        : in std_logic_vector(0 to Nbit-1);
            state       : out std_logic_vector(0 to Nbit-1);
            reset_n     : in std_logic; 
            clk         : in std_logic
        );
    end component shift_reg;

begin

    LFSR: shift_reg
        generic map(
            Nbit => 16
        )
        port map(
            clk         =>  clk,
            reset_n     =>  reset_n,
            seed        =>  init_value,
            d_out       =>  output_bit,
            state       =>  current_state
        );

end rtl;