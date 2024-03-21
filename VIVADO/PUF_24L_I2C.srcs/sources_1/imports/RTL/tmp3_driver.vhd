library ieee;
use ieee.std_logic_1164.all;

entity tmp3_driver is
    port(
        data: inout std_logic_vector(15 downto 0);     --data bus
        addr_bus: out std_logic_vector(7 downto 0);   --address bus
        rw: out std_logic;                            --rw=1 - write request
        rst: out std_logic;                           --reset active low
        clk: in std_logic;                            --fpga clock
        as: out std_logic;                            --address on address bus is valid
        ds: out std_logic;                            --data is valid
        irq: in std_logic;                            --transmit/receive done active high
        command: in std_logic;                        --get temperature measurement
        result: out std_logic_vector(15 downto 0);    --received temperature value
        rs: out std_logic                             --temperature valid
    );
end;

architecture rtl of tmp3_driver is

    type T_STATE is (IDLE, START, POINTER_SET, READ, ASSERT_RESULT, STOP);
    signal CURRENT_STATE : T_STATE := IDLE;
    signal NEXT_STATE: T_STATE := IDLE;
    --signal address: std_logic_vector(7 downto 0) := X"48";
    --signal ta_pointer: std_logic_vector(7 downto 0) := X"00";
    signal read_result: std_logic_vector(15 downto 0);
begin
    process(CURRENT_STATE, command, irq, data, read_result) is
    begin
    as <= '0';
    ds <= '0';
    rs <= '0';
    rw <= '0';
    rst <= '0';
    addr_bus <= X"48";
    result <= X"0000";
    data <= X"0000";
    read_result <= X"0000";
    NEXT_STATE <= IDLE;
        case CURRENT_STATE is
            when IDLE =>
                as <= '0';
                ds <= '0';
                rs <= '0';
                rw <= '0';
                rst <= '0';
                addr_bus <= X"48";
                result <= X"0000";
                data <= X"0000";
                read_result <= X"0000";
                if(command = '1') then
                    NEXT_STATE <= START;
                end if;
            when START =>
                as <= '1';
                ds <= '0';
                rs <= '0';
                rw <= '0';
                rst <= '1';
                addr_bus <= X"48";
                result <= X"0000";
                data <= X"0000";
                read_result <= X"0000";
                NEXT_STATE <= POINTER_SET;
            when POINTER_SET =>
                as <= '1';
                ds <= '1';
                rs <= '0';
                rw <= '1';
                rst <= '1';
                addr_bus <= X"48";
                result <= X"0000";
                data <= X"0000";
                read_result <= X"0000";
                if(irq = '1') then
                    ds <= '0';
                    NEXT_STATE <= READ;
                else
                    NEXT_STATE <= POINTER_SET;
                end if;
            when READ =>
                as <= '1';
                ds <= '1';
                rs <= '0';
                rw <= '0';
                rst <= '1';
                addr_bus <= X"48";
                result <= X"0000";
                read_result <= X"0000";
                if(irq = '1') then
                    read_result <= data;
                    ds <= '0';
                    NEXT_STATE <= ASSERT_RESULT;
                else
                    data <= X"0000"; --sus
                    NEXT_STATE <= READ;
                end if;
            when ASSERT_RESULT =>
                as <= '1';
                ds <= '0';
                rs <= '0';
                rw <= '0';
                rst <= '1';
                addr_bus <= X"48";
                data <= X"0000";
                result <= read_result;
                rs <= '1';
                if(command = '0') then
                    NEXT_STATE <= STOP;
                else
                    NEXT_STATE <= ASSERT_RESULT;
                end if;
            when STOP =>
                as <= '0';
                ds <= '0';
                rs <= '0';
                rw <= '0';
                rst <= '1';
                addr_bus <= X"48";
                result <= X"0000";
                data <= X"0000";
                read_result <= X"0000";
                NEXT_STATE <= IDLE;
            when others =>
                rs <= '0';
                as <= '0';
                ds <= '0';
                rst <= '0';
                rw <= '0';
                addr_bus <= X"48";
                result <= X"0000";
                data <= X"0000";
                read_result <= X"0000";
        end case;
    end process;

    process(clk) is
    begin
        if (clk'event and clk = '1') then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;
end;