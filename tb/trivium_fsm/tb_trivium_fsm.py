# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.result import TestError


@cocotb.test()
def test_trivium_fsm_1(dut):
    """Ttivium FSM Test Bench
    :param dut: device under test
    """
    dut._log.info("Starting Trivium FSM test bench...")

    # Création d'une clock à 100MHz
    clkthread = cocotb.fork(Clock(dut.clk, 10, units="ns").start())