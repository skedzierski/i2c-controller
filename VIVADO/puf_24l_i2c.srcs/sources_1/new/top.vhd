library ieee;
use ieee.std_logic_1164.all;

use work.i2c_pkg.all;

entity top is
    port(
        ja: inout std_logic_vector;
        clk: inout std_logic
    );
end entity;

architecture rtl of top is

signal s_clk_100mhz, s_rst, s_rst_locked : std_logic;
signal s_sda, s_scl : std_logic;

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  resetn             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

begin 

clk_wiz : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => s_clk_100mhz,
  -- Status and control signals                
   resetn => s_rst,
   locked => s_rst_locked,
   -- Clock in ports
   clk_in1 => clk
 );

end architecture;