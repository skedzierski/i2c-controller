library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 

use work.i2c_pkg.edge;

entity generic_counter is
generic(
    counter_width: natural;
    edge_sel: edge
);

port(
    clk: in std_logic;
    rst: in std_logic;
    preload: in std_logic_vector(counter_width-1 downto 0);
    o_cnt: out std_logic
);

end;

architecture rtl of generic_counter is
    signal current_val : std_logic_vector(counter_width-1 downto 0);
begin
    process(clk, rst) is
        variable edge_as_logic : std_logic;
    begin
        if edge_sel = NEG then
            edge_as_logic := '0';
        else
            edge_as_logic := '1';
        end if;
        if (rst = '0') then
            current_val <= (others => '0'); -- natural
            o_cnt <= '0';
        elsif (clk'event and clk = edge_as_logic) then
            current_val <= std_logic_vector(unsigned(current_val) + 1);
            if (current_val = preload) then
                o_cnt <= '1';
                current_val <= (others => '0');
            else
                o_cnt <= '0';
            end if;
        end if;
    end process;
end;