# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.result import TestError

from pytrivium import Trivium


@cocotb.test()
def test_trivium_engine(dut):
    """Trivium engine test bench
    :param dut: Device Under Test
    """
    OUTPUT_SIZE = 1

    get_bin = lambda x, n: format(x, 'b').zfill(n)

    # Set 6, vector# 3:
    key = [0xfa, 0xa7, 0x54, 0x01, 0xae, 0x5b, 0x08, 0xb5, 0x62, 0x0f]
    iv = [0xc7, 0x60, 0xf9, 0x92, 0x2b, 0xc4, 0x5d, 0xf6, 0x8f, 0x28]

    key_bin = ''.join([get_bin(i, 8) for i in key])
    iv_bin = ''.join([get_bin(i, 8) for i in iv])

    engine_debug = Trivium()
    engine_debug.initialize(key, iv)

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.clk, 10, units='ns').start())

    dut._log.info('Starting Trivium test bench...')

    # Reset du composant
    dut.rst <= 1
    dut.initialization <= 0
    dut.generate_keystream <= 0
    yield Timer(10, units='ns')
    dut.rst <= 0

    dut._log.info(f'Starting Triivum initialization:\n\tkey:{key_bin}\n\tiv :{iv_bin}')
    dut.initialization <= 1
    dut.key <= BinaryValue(key_bin)
    dut.iv <= BinaryValue(iv_bin)

    for _ in range(0, 1152, OUTPUT_SIZE):
        yield Timer(10, units='ns')

    dut._log.info('Initialization ends !')