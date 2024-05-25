library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
use work.i2c_pkg.all;

entity scl_gen is

port(
    fpga_clk: in std_logic;
    rst: in std_logic;
    gen_start: in std_logic;
    rep_start: in std_logic;
    gen_stop: in std_logic;
    o_scl: out std_logic;
    clk100khz: out std_logic
);

end entity;

architecture rtl of scl_gen is
    signal CURRENT_STATE : SCL_STATE := IDLE;
    signal NEXT_STATE: SCL_STATE;
    signal counter_reset: std_logic;
    signal overflow_500, overflow_250: std_logic;
    signal clk200khz: std_logic;
begin
    count_500: entity work.generic_counter(rtl)
        generic map(counter_width => 8, edge_sel => POS)
        port map(
            clk => fpga_clk,
            rst => counter_reset,
            preload => X"FA", -- 500 decimal
            o_cnt => overflow_500
        );

    count_250: entity work.generic_counter(rtl)
        generic map(counter_width => 8, edge_sel => POS)
        port map(
            clk => fpga_clk,
            rst => counter_reset,
            preload => X"7D", -- 250 decimal
            o_cnt => overflow_250
        );
    
    
    clkgen_0: entity work.clkgen(arch)
    port map(
        clk200khz => clk200khz,
        reset => rst,
        shifted_100khz => o_scl,
        clk100khz => clk100khz
    );
    
    process(fpga_clk, rst, gen_start, gen_stop, CURRENT_STATE, overflow_500, overflow_250, rep_start) is
    begin
        counter_reset <= '1';
        clk200khz <= '1';
        NEXT_STATE <= IDLE;
        case CURRENT_STATE is
            when IDLE =>
                if(rst = '0') then
                    NEXT_STATE <= IDLE;
                    counter_reset <= '0';
                elsif (gen_start = '1') then
                    --clk_cnt <= 0;
                    counter_reset <= '1';
                    NEXT_STATE <= START;
                else
                    counter_reset <= '0';
                    NEXT_STATE <= IDLE;
                end if;

            when START => --SDA should be pulled low in this state
                if (overflow_500 = '1') then
                    NEXT_STATE <= SCL_LOW_EDGE;
                else
                    NEXT_STATE <= START;
                end if;

            when SCL_LOW_EDGE =>
                clk200khz <= '0';
                --clk_cnt <= 0;
                NEXT_STATE <= SCL_LOW;

            when SCL_LOW =>
                clk200khz <= '0';
                if(overflow_500 = '1') then
                    NEXT_STATE <= SCL_HI_EDGE;
                else 
                    NEXT_STATE <= SCL_LOW;
                end if;

            when SCL_HI_EDGE =>
                clk200khz <= '1';
                --clk_cnt <= 0;
                NEXT_STATE <= SCL_HI;

            when SCL_HI =>
                clk200khz <= '1';
                if(overflow_500 = '1') then
                    NEXT_STATE <= SCL_LOW_EDGE;
                elsif (rep_start = '1' AND overflow_250 = '1') then
                    NEXT_STATE <= START;
                elsif(gen_stop = '1' AND overflow_250 = '1') then
                    --clk_cnt <= 0;
                    NEXT_STATE <= STOP_WAIT;
                else
                    NEXT_STATE <= SCL_HI;
                end if;

            when STOP_WAIT =>
                if(overflow_500 = '1') then
                    NEXT_STATE <= IDLE;
                end if;
        end case;
    end process;

    process(fpga_clk) is
    begin
        if (fpga_clk'event and fpga_clk = '1') then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;
end architecture;
