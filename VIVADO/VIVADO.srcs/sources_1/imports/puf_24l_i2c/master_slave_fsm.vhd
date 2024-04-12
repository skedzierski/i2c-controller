library ieee;
use ieee.std_logic_1164.all;
use work.i2c_2_pkg.all;

entity master_slave_fsm is
    port(
        clk: in std_logic;
        rst: in std_logic;
        scl: in std_logic;
        sda: inout std_logic;
        control_reg: in ctr_bits;
        status_reg: out sr_bits;
        addr_reg: in std_logic_vector(7 downto 0);
        data_transmit_reg: in std_logic_vector(7 downto 0);
        data_receive_reg: out std_logic_vector(7 downto 0);
        ack_receive: out std_logic
    );
end entity;

architecture rtl of master_slave_fsm is
    
    type T_STATE is (IDLE, HEADER, ACK_HEADER, RCV_DATA, ACK_DATA, XMIT_DATA, WAIT_ACK, STOP);
    signal current_state, next_state: T_STATE;

    signal bit_cnt: natural;
    signal begin_cnt: std_logic;
    signal falling_sda, rising_scl: std_logic;
    
    impure function detect_start return boolean is
    begin
        return falling_sda = '1' and scl = '1';
    end function;

    impure function detect_stop return boolean is
    begin
        return rising_scl = '1' and sda = '1';
    end function;
    
    signal rx_shift_enable, tx_shift_enable: std_logic;
    signal rx_data, next_data_receive: std_logic_vector(8 downto 0); 
    signal tx_data: std_logic_vector(7 downto 0);
    
    impure function addr_match return boolean is
    begin
        return rx_data = addr_reg;
    end function;
    
    signal s_irq, count_done: std_logic;
begin

    sda_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk, 
        rst => rst,
        sig => sda,
        o_falling_edge => falling_sda
    );

    scl_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk,
        rst => rst,
        sig => scl,
        o_rising_edge => rising_scl
    );
    
    state_register: process(clk, rst) is
    begin
        if rst = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
            data_receive_reg <= next_data_receive(7 downto 0);
        end if;
    end process;

    rx_reg: entity work.rx_shift_register(rtl)
    generic map(9)
    port map(
        clk => scl,
        rst => rst,
        shift_enable => rx_shift_enable,
        serial_data => sda,
        parallel_data => rx_data
    );

    tx_reg: entity work.tx_shift_register(rtl)
    generic map(9)
    port map(
        clk => scl,
        rst => rst,
        shift_enable => tx_shift_enable,
        serial_data => sda,
        parallel_data => tx_data & control_reg.ack
    );

    count_to8: entity work.generic_counter(rtl)
    generic map (
        4
    )
    port map (
        clk => clk,
        rst => rst,
        preload => X"8",
        o_cnt => count_done
    );

    fsm: process(
                 clk,
                 rst,
                 scl,
                 sda)
    is
    begin
        next_state <= IDLE;
        rx_shift_enable <= '0';
        tx_shift_enable <= '0';
        ack_receive <= '0';
        begin_cnt <= '0';
        next_data_receive <= (others => '0'); 
        tx_data <= X"00";

        if control_reg.en = '1' then
            status_reg <= stlv_to_sr_bits(X"00");
            case current_state is
            when IDLE =>
                    if rst = '0' then
                        next_state <= IDLE;
                    end if;

                    if detect_start then 
                        next_state <= HEADER;
                    end if;

                when HEADER =>
                    begin_cnt <= '1';
                    if count_done = '0' then
                        rx_shift_enable <= '1';
                        next_state <= HEADER;
                    elsif count_done = '1' then
                        rx_shift_enable <= '0';
                        status_reg.tip <= '1';
                        next_state <= ACK_HEADER;
                    end if;
                
                when ACK_HEADER =>
                    if control_reg.mode_sel = '1' and control_reg.transmit_dir = '0' and sda = '0' then --master receive
                        next_state <= RCV_DATA;
                    elsif control_reg.mode_sel = '0' and control_reg.transmit_dir = '0' and addr_match then -- slave receive
                        status_reg.addr_match <= '1';
                        next_state <= RCV_DATA;
                        ack_receive <= '1';
                    elsif control_reg.mode_sel = '1' and control_reg.transmit_dir = '1' and sda = '0' then -- master xmit
                        next_state <= XMIT_DATA;
                    elsif control_reg.mode_sel = '0' and control_reg.transmit_dir = '1' and addr_match then -- slave xmit
                        next_state <= XMIT_DATA;
                        ack_receive <= '1';
                    end if;
                
                when RCV_DATA =>
                    begin_cnt <= '1';
                    rx_shift_enable <= '1';
                    if count_done = '1' then
                        rx_shift_enable <= '0';
                        next_data_receive <= rx_data;
                        next_state <= ACK_DATA;
                    elsif detect_stop then
                        next_state <= STOP;
                        rx_shift_enable <= '0';
                    else
                        next_state <= RCV_DATA;
                        rx_shift_enable <= '0';
                    end if;

                when XMIT_DATA => 
                    begin_cnt <= '1';
                    tx_data <= data_transmit_reg;
                    tx_shift_enable <= '1';
                    if count_done = '1' then
                        next_state <= WAIT_ACK;
                        bit_cnt <= 0;
                        tx_shift_enable <= '0';
                    elsif detect_stop then
                        next_state <= STOP;
                    end if;

                when ACK_DATA =>
                    next_state <= RCV_DATA;
                
                when WAIT_ACK =>
                    if sda = '0' then
                        next_state <= XMIT_DATA;
                    else
                        status_reg.tip <= '1';
                        next_state <= STOP;
                    end if;

                when STOP =>
                    next_state <= IDLE;
            end case;
        end if;
    end process;

end architecture;
