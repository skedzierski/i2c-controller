library ieee;
use ieee.std_logic_1164.all;

entity generic_reg is

    generic(
        data_width: natural
    );

    port(
        reset: in std_logic;
        clk: in std_logic;
        data_in: in std_logic_vector (data_width-1 downto 0);
        data_out: out std_logic_vector (data_width-1 downto 0)
    );
end;

architecture rtl of generic_reg is

begin
    process (reset, clk) is

    begin
        if(reset = '0') then
            data_out <= "0";
        elsif (clk'event and clk = '1') then
            data_out <= data_in;
        end if;
    end process;
end;