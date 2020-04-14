# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.result import TestError


@cocotb.test()
def test_trivium_fsm(dut):
    """Trivium FSM Test Bench
    :param dut: device under test
    """
    dut._log.info("Starting Trivium FSM test bench...")

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.clk, 10, units="ns").start())

    dut.rst <= 1
    yield Timer(10, units="ns")
    dut.rst <= 0

    dut._log.info('Current state : S_IDLE')
    dut.start <= 1
    dut.pause <= 0

    dut._log.info('Current state : S_INIT')
    yield RisingEdge(dut.initialization)
    dut.start <= 0

    dut._log.info('Current state : S_GEN_KEYSTREAM')
    yield RisingEdge(dut.generate_keystream)

    # Wait 100 ns (generate 10 blocks of keystream)
    yield Timer(100, units='ns')

    dut.pause <= 1
    dut._log.info('Current state : S_PAUSE')
    yield Timer(200, units='ns')
    dut.pause <= 0

    dut._log.info('Current state : S_GEN_KEYSTREAM')
    # Wait 150 ns (generate 15 blocks of keystream)
    yield Timer(150, units='ns')

    yield Timer(500, units='ns')
