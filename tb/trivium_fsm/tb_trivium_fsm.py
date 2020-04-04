# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.result import TestError


@cocotb.test()
def test_trivium_fsm_1(dut):
    """Ttivium FSM Test Bench
    :param dut: device under test
    """
    dut._log.info("Starting Trivium FSM test bench...")

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.clk, 10, units="ns").start())

    dut.rst <= 1
    yield Timer(10, units="ns")
    dut.rst <= 0

    dut._log.info(f'Current state : S_SLEEP')
    dut.start <= 1
    # Generates 8 blocks of G_OUTPUT_SIZE bits
    dut.n <= BinaryValue(value=8, n_bits=32, bigEndian=False)

    dut._log.info('Current state : S_INIT')
    yield RisingEdge(dut.initialization)
    dut.start <= 0

    dut._log.info('Current state : S_GEN_KEYSTREAM')
    yield RisingEdge(dut.generate_keystream)

    dut._log.info('Current state : S_SLEEP')
    yield RisingEdge(dut.terminate)

    yield Timer(200, units='ns')