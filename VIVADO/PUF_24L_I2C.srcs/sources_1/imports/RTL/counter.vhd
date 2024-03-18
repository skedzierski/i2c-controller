library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity generic_counter is
generic(
    counter_width: natural
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
    begin
        if (rst = '0') then
            current_val <= X"0000"; -- natural
            o_cnt <= '0';
        elsif (clk'event and clk = '1') then
            current_val <= std_logic_vector(unsigned(current_val) + 1);
            if (current_val = preload) then
                o_cnt <= '1';
                current_val <= X"0000";
            else
                o_cnt <= '0';
            end if;
        end if;
    end process;
end;