library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
    port(
        clk: in std_logic;
        ja: inout std_logic_vector(1 downto 0);
        led: out std_logic_vector(3 downto 0);
        temperature_o: out std_logic_vector(15 downto 0)
    );

end;


architecture rtl of top is
        
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

--COMPONENT ila_0
--    PORT (
--	clk : IN STD_LOGIC;
--	probe0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
--);
--END COMPONENT  ;

COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) 
  );
END COMPONENT;


        -- Clocking wizard
        signal s_locked, s_clk, s_resetn : std_logic;

        -- ILA
        --signal s_probe0 : std_logic_vector(1 downto 0);

        -- VIO
        signal s_probe_out0, s_i2c_data: std_logic_vector(1 downto 0);
        signal s_btn : std_logic;
        
            -- ATTRIBUTE DECLARATION --
ATTRIBUTE MARK_DEBUG : STRING;
ATTRIBUTE MARK_DEBUG OF ja : SIGNAL IS "true";
ATTRIBUTE MARK_DEBUG OF s_i2c_data : SIGNAL IS "true";
ATTRIBUTE MARK_DEBUG OF led : SIGNAL IS "true";
ATTRIBUTE MARK_DEBUG of temperature_o : SIGNAL IS "true";
--ATTRIBUTE MARK_DEBUG OF pio1 : SIGNAL IS "true";
--ATTRIBUTE MARK_DEBUG OF pio2 : SIGNAL IS "true";
--ATTRIBUTE MARK_DEBUG OF pio3 : SIGNAL IS "true";
--ATTRIBUTE MARK_DEBUG OF pio4 : SIGNAL IS "true";
--ATTRIBUTE MARK_DEBUG OF pio : SIGNAL IS "true";
        

begin

ja(0) <= 'Z' when s_i2c_data(0) = '1' else '0';
ja(1) <= 'Z' when s_i2c_data(1) = '1' else '0';

led(0) <= s_resetn;
led(1) <= s_locked;
led(2) <= s_btn;
led(3) <= '1';

pll : clk_wiz_0
    port map ( 
   -- Clock out ports  
    clk_out1 => s_clk,
   -- Status and control signals                
    resetn => s_resetn,
    locked => s_locked,
    -- Clock in ports
    clk_in1 => clk
  );


  vio : vio_0
  PORT MAP (
    clk => clk,
    probe_out0 => s_probe_out0
  );
  s_probe_out0(0) <= s_resetn;
  s_probe_out0(1) <= s_btn;

i2c_0: entity work.i2c(rtl)
port map
    (
        scl_o => s_i2c_data(0),
        sda_o => s_i2c_data(1),
        scl_i => ja(0),
        sda_i => ja(1),
        --i2c_ila => s_probe0,
        clk => s_clk,
        btn => s_btn,
        rst => s_locked,
        temperature_o => temperature_o
    );

end architecture;