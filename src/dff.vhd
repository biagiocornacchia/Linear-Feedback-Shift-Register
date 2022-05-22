-- D-Type Flip-Flop with Set/Reset in order to set the initial seed in every DFF

library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------
--       ENTITY DECLARATION (the external view of the entity)
--------------------------------------------------------------------

entity dff is
    port (
        clk         : in    std_logic;
        reset_n     : in    std_logic;
        d           : in    std_logic;
        q           : out   std_logic;
        set         : in    std_logic
    );
end dff;

-----------------------------------------------------------------------
--      ARCHITECTURE (the internal description of the entity)
-----------------------------------------------------------------------

architecture rtl of dff is
begin
    dff_proc: process(reset_n, clk)
        begin
            if (reset_n = '0') then
                q <= set;
            elsif (rising_edge(clk)) then
                q <= d;
            end if;
    end process dff_proc;
end rtl;