# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.result import TestError

from pytrivium import Trivium


def swap32(x):
    """Swaps 32-bit integer endianness
    :param x: A 32-bit integer
    :type x: int
    :returns: A 32-bit integer with endianess swapped
    :rtype: int
    """
    return (((x << 24) & 0xFF000000) |
            ((x <<  8) & 0x00FF0000) |
            ((x >>  8) & 0x0000FF00) |
            ((x >> 24) & 0x000000FF))


def setup_trivium_debug():
    # Set 6, vector# 3:
    key = [0xfa, 0xa7, 0x54, 0x01, 0xae, 0x5b, 0x08, 0xb5, 0x62, 0x0f]
    iv = [0xc7, 0x60, 0xf9, 0x92, 0x2b, 0xc4, 0x5d, 0xf6, 0x8f, 0x28]

    engine = Trivium()
    engine.initialize(key, iv)

    return engine


@cocotb.test()
def test_1(dut):
    """Test bench of Trvium master AXI streaming interface 
    :param dut: device under test
    """
    # Setup Trivium debugger
    debug = setup_trivium_debug()

    dut._log.info('[*] Starting test bench n°1')

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.M_AXIS_ACLK, 10, units='ns').start())

    dut.M_AXIS_ARESETN <= 0
    yield Timer(10, units='ns')
    dut.M_AXIS_ARESETN <= 1

    yield Timer(10, units='ns')

    dut.M_AXIS_TREADY <= 1
    dut.M_AXIS_TRV_READY <= 1
    dut.M_AXIS_TRV_INIT_START <= 0

    n = 128
    debug.update(n)
    for i in range(n):
        if i == 50:
            dut.M_AXIS_TRV_INIT_START <= 1
        dut.M_AXIS_TRV_KEYSTREAM <= BinaryValue(swap32(debug.keystream[i]))
        yield RisingEdge(dut.M_AXIS_ACLK)
        if i == 50:
            dut.M_AXIS_TRV_INIT_START <= 0

    dut.M_AXIS_TRV_READY <= 0

    yield Timer(1000, units='ns')