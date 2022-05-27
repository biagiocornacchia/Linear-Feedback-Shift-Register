library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------
--       ENTITY DECLARATION (the external view of the entity)
--------------------------------------------------------------------

entity DFF is
    port (
        clk         : in    std_logic;
        reset_n     : in    std_logic; -- asynchronous reset
        d           : in    std_logic;
        q           : out   std_logic
    );
end DFF;

-----------------------------------------------------------------------
--      ARCHITECTURE (the internal description of the entity)
-----------------------------------------------------------------------

architecture rtl of DFF is
begin
    dff_proc: process(reset_n, clk)
        begin
            if (reset_n = '0') then
                q <= '0';
            elsif (rising_edge(clk)) then
                q <= d;
            end if;
    end process dff_proc;
end rtl;