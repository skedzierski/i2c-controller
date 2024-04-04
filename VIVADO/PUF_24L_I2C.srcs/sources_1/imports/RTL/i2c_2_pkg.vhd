library ieee;
use ieee.std_logic_1164.all;

package i2c_2_pkg is
    type ctr_bits is record
        en: std_logic;
        ien: std_logic;
        mode_sel: std_logic;
        transmit_dir: std_logic;
        ack: std_logic;
        rep_start: std_logic;
        inter_reset: std_logic;
        halt: std_logic;
    end record;

    type sr_bits is record
        tip: std_logic;
        addr_match: std_logic;
        bus_busy: std_logic;
        arb_lost: std_logic;
        time_out: std_logic;
        slave_rw: std_logic;
        irq_pending: std_logic;
        ack_state: std_logic;
    end record;

    constant device_addr: std_logic_vector := X"00";

    function ctr_bits_to_stlv(bits: ctr_bits) return std_logic_vector;
    function stlv_to_ctr_bits(vec: std_logic_vector(7 downto 0)) return ctr_bits;
    function sr_bits_to_stlv(bits: sr_bits) return std_logic_vector;
    function stlv_to_sr_bits(vec: std_logic_vector(7 downto 0)) return sr_bits;

    
end package;

package body i2c_2_pkg is
    function ctr_bits_to_stlv(bits: ctr_bits) return std_logic_vector is
        variable ret_vec: std_logic_vector(7 downto 0);
    begin
        ret_vec(7) := bits.en;
        ret_vec(6) := bits.ien;
        ret_vec(5) := bits.mode_sel;
        ret_vec(4) := bits.transmit_dir;
        ret_vec(3) := bits.ack;
        ret_vec(2) := bits.rep_start;
        ret_vec(1) := bits.inter_reset;
        ret_vec(0) := bits.halt;
        return ret_vec;
    end;

    function stlv_to_ctr_bits(vec: std_logic_vector(7 downto 0)) return ctr_bits is
        variable ret_bits: ctr_bits;
    begin
        ret_bits.en := vec(7);
        ret_bits.ien := vec(6);
        ret_bits.mode_sel := vec(5);
        ret_bits.transmit_dir := vec(4);
        ret_bits.ack := vec(3);
        ret_bits.rep_start := vec(2);
        ret_bits.inter_reset := vec(1);
        ret_bits.halt := vec(0);
        return ret_bits;
    end;

    function sr_bits_to_stlv(bits: sr_bits) return std_logic_vector is
        variable ret_vec: std_logic_vector (7 downto 0);
    begin
        ret_vec(7) := bits.tip;
        ret_vec(6) := bits.addr_match;
        ret_vec(5) := bits.bus_busy;
        ret_vec(4) := bits.arb_lost;
        ret_vec(3) := bits.time_out;
        ret_vec(2) := bits.slave_rw;
        ret_vec(1) := bits.irq_pending;
        ret_vec(0) := bits.ack_state;
        return ret_vec;
    end;
    function stlv_to_sr_bits(vec: std_logic_vector(7 downto 0)) return sr_bits is
        variable ret_bits: sr_bits;
    begin
        ret_bits.tip := vec(7);
        ret_bits.addr_match := vec(6);
        ret_bits.bus_busy := vec(5);
        ret_bits.arb_lost := vec(4);
        ret_bits.time_out := vec(3);
        ret_bits.slave_rw := vec(2);
        ret_bits.irq_pending := vec(1);
        ret_bits.ack_state := vec(0);
        return ret_bits;
    end;

    constant ctr_reg_addr : std_logic_vector(7 downto 0) := X"04";
    constant status_reg_addr : std_logic_vector(7 downto 0) := X"08";
    constant address_reg_addr : std_logic_vector(7 downto 0) := X"0A";
    constant data_transmit_reg_addr : std_logic_vector(7 downto 0) := X"0B"; 

    
end package body;