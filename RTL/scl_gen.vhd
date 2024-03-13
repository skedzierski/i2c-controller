library ieee;
use ieee.std_logic_1164.all;

entity scl_gen is

port(
    fpga_clk: in std_logic;
    rst: in std_logic;
    gen_start: in std_logic;
    gen_stop: in std_logic;
    o_scl: out std_logic
);

end entity;

architecture rtl of scl_gen is

    type T_STATE is (IDLE, START, SCL_LOW_EDGE, SCL_LOW, SCL_HI_EDGE, SCL_HI, STOP_WAIT);
    signal CURRENT_STATE, NEXT_STATE: T_STATE;
    signal rep_start: std_logic;
    signal start_hold, low_cnt, high_cnt, tbuf: std_logic_vector(0 to 15);
    signal clk_cnt: std_logic_vector(0 to 31);
begin
    
    o_scl <= '1';
    rep_start <= '0';
    start_hold <= "500";
    low_cnt <= "500";
    high_cnt <= "500";
    tbuf <= "500";
    process(fpga_clk) is
    begin
        CURRENT_STATE <= IDLE;
        NEXT_STATE <= IDLE;
        case CURRENT_STATE is
            when IDLE =>
                if(rst = '0') then
                    NEXT_STATE <= IDLE;
                elsif (gen_start = '1') then
                    clk_cnt <= "0";
                    NEXT_STATE <= START;
                else
                    NEXT_STATE <= IDLE;
                end if;

            when START => --SDA should be pulled low in this state
                if (clk_cnt = start_hold) then
                    NEXT_STATE <= SCL_LOW_EDGE;
                else
                    NEXT_STATE <= START;
                end if;

            when SCL_LOW_EDGE =>
                o_scl <= '0';
                clk_cnt <= "0";
                NEXT_STATE <= SCL_LOW;

            when SCL_LOW =>
                if(clk_cnt = low_cnt) then
                    NEXT_STATE <= SCL_HI_EDGE;
                else 
                    NEXT_STATE <= SCL_LOW;
                end if;

            when SCL_HI_EDGE =>
                o_scl <= '1';
                clk_cnt <= "0";
                NEXT_STATE <= SCL_HI;

            when SCL_HI =>
                if(clk_cnt = high_cnt) then
                    NEXT_STATE <= SCL_LOW_EDGE;
                else 
                    NEXT_STATE <= SCL_HI;
                end if;
                if (rep_start = '1' AND clk_cnt = high_cnt/2) then
                    NEXT_STATE <= START;
                end if;
                if(gen_stop = '1' AND clk_cnt = high_cnt/2) then
                    clk_cnt <= "0";
                    NEXT_STATE <= STOP_WAIT;
                end if;

            when STOP_WAIT =>
                if(clk_cnt = tbuf) then
                    NEXT_STATE <= IDLE;
                end if;
        end case;
    end process;

    process(fpga_clk) is
    begin
        CURRENT_STATE <= NEXT_STATE;
        clk_cnt <= clk_cnt + 1;
    end process;
end architecture;