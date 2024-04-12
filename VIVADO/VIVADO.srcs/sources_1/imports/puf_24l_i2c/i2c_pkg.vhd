package i2c_pkg is
    type SCL_STATE is (IDLE, START, SCL_LOW_EDGE, SCL_LOW, SCL_HI_EDGE, SCL_HI, STOP_WAIT);
end package;