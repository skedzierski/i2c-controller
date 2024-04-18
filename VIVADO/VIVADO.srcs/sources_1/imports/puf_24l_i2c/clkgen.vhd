library ieee;
use ieee.std_logic_1164.all;


entity clkgen is
    port (
      reset          : in  std_logic;
      clk200khz         : in  std_logic;
      clk100khz : out std_logic;
      shifted_100khz : out std_logic);
  end entity;
  
  architecture arch of clkgen is
    signal int1, int2 : std_logic;
  begin

    process(clk200khz, reset) is
    begin
      if (reset = '0') then
        int1 <= '0';
      elsif (clk200khz = '1' and clk200khz'event) then
        int1 <= not int1;
      end if;
      clk100khz <= int1;
    end process;

    process(clk200khz, reset) is
    begin
      if (reset = '0') then
        int2 <= '0';
      elsif (clk200khz = '0' and clk200khz'event) then
        int2 <= not int2;
      end if;
      shifted_100khz <= int2;
    end process;
  end architecture;