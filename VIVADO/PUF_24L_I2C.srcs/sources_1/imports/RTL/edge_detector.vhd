library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port(
        clk: in std_logic;
        rst: in std_logic;
        sig: in std_logic;
        o_rising_edge: out std_logic;
        o_falling_edge: out std_logic
    );
end entity;

architecture rtl of edge_detector
is
    signal reg1, reg2: std_logic;
begin
    
    process(clk, rst, sig, reg1, reg2) is begin
        if reg1 = '0' and reg2 = '1' then
            o_rising_edge <= '0';
            o_falling_edge <= '1';
        elsif reg1 = '1' and reg2 = '0' then
            o_rising_edge <= '1';
            o_falling_edge <= '0';
        else
            o_rising_edge <= '0';
            o_falling_edge <= '0';
        end if;
    end process;

    process(clk, rst) is
    begin
        if(rst = '0') then reg1 <= '0';
        elsif rising_edge(clk) then
            reg1 <= sig;
        end if;
    end process;

    process(clk, rst) is
    begin
        if(rst = '0') then reg2 <= '0';
        elsif rising_edge(clk) then
            reg2 <= reg1;
        end if;
    end process;

end architecture;