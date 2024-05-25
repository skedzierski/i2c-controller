--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
--Date        : Sat May 25 18:59:54 2024
--Host        : DESKTOP-72AA1NQ running 64-bit major release  (build 9200)
--Command     : generate_target design_1.bd
--Design      : design_1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1 is
  port (
    clk : in STD_LOGIC;
    ja : inout STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_1 : entity is "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_1 : entity is "design_1.hwdef";
end design_1;

architecture STRUCTURE of design_1 is
  component design_1_i2c_0_0 is
  port (
    i2c_data : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    clk : in STD_LOGIC;
    btn : in STD_LOGIC;
    rst : in STD_LOGIC
  );
  end component design_1_i2c_0_0;
  component design_1_clk_wiz_0_0 is
  port (
    resetn : in STD_LOGIC;
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component design_1_clk_wiz_0_0;
  component design_1_ila_0_0 is
  port (
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component design_1_ila_0_0;
  component design_1_vio_0_0 is
  port (
    clk : in STD_LOGIC;
    probe_out0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out1 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_vio_0_0;
  signal Net1 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal clk_1 : STD_LOGIC;
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal clk_wiz_0_locked : STD_LOGIC;
  signal vio_0_probe_out0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal vio_0_probe_out1 : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 CLK.CLK CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN design_1_clk, FREQ_HZ 12000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
begin
  clk_1 <= clk;
clk_wiz_0: component design_1_clk_wiz_0_0
     port map (
      clk_in1 => clk_1,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => clk_wiz_0_locked,
      resetn => vio_0_probe_out1(0)
    );
i2c_0: component design_1_i2c_0_0
     port map (
      btn => vio_0_probe_out0(0),
      clk => clk_wiz_0_clk_out1,
      i2c_data(1 downto 0) => ja(1 downto 0),
      rst => clk_wiz_0_locked
    );
ila_0: component design_1_ila_0_0
     port map (
      clk => clk_1,
      probe0(1 downto 0) => B"00"
    );
vio_0: component design_1_vio_0_0
     port map (
      clk => clk_1,
      probe_out0(0) => vio_0_probe_out0(0),
      probe_out1(0) => vio_0_probe_out1(0)
    );
end STRUCTURE;
