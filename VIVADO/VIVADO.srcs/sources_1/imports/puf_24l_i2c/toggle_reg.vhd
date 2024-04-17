library ieee;
use ieee.std_logic_1164.all;

entity toggle_reg is
port(
    d: in std_logic;
    clk: in std_logic;
    q: inout std_logic
);
end entity;

architecture rtl of toggle_reg is
    signal s_d, next_s_d: std_logic;
begin

    xor_process: process(d, clk, q) is
    begin
        next_s_d <= q xor d;
        q <= s_d;
    end process;

    d_latch: process(clk) is
    begin
        if rising_edge(clk) then
            s_d <= next_s_d;
        end if;
    end process;
end architecture;
