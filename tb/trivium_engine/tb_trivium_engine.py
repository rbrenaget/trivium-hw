# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.result import TestError

from pytrivium import Trivium


def bin_to_hex(bs):
    """Convert a bit stream into hexadecimal
    :param bs: the bit stream (list)
    :returns: an hexadecimal string
    """
    bs = ''.join(bs)
    tmp = hex(int(bs, 2))[2:].strip('L')
    pad = ''.join('0' for i in range(len(tmp), len(bs)//4))
    tmp = pad + tmp

    return str(tmp).upper()


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


@cocotb.test()
def test_trivium_engine(dut):
    """Trivium engine test bench
    :param dut: Device Under Test
    """
    OUTPUT_SIZE = dut.G_OUTPUT_SIZE.value.integer
    DBG_OUTPUT_SIZE = 32
    NB_ROT = 32*2 # minimum 32 

    get_bin = lambda x, n: format(x, 'b').zfill(n)
    get_hex = lambda x: hex(x)[2:].upper()

    # Set 6, vector# 3:
    key = [0xfa, 0xa7, 0x54, 0x01, 0xae, 0x5b, 0x08, 0xb5, 0x62, 0x0f]
    iv = [0xc7, 0x60, 0xf9, 0x92, 0x2b, 0xc4, 0x5d, 0xf6, 0x8f, 0x28]

    key_bin = ''.join([get_bin(i, 8) for i in key])
    iv_bin = ''.join([get_bin(i, 8) for i in iv])

    engine_debug = Trivium()
    engine_debug.initialize(key, iv)

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.clk, 10, units='ns').start())

    dut._log.info('Starting Trivium engine test bench...')

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

    dut.initialization <= 0
    dut._log.info('Initialization ends !')

    dut._log.info('Starting key stream generation...')
    yield Timer(10, units='ns')
    dut.generate_keystream <= 1

    n = int((OUTPUT_SIZE/DBG_OUTPUT_SIZE)*(NB_ROT//OUTPUT_SIZE))
    engine_debug.update(n)
    zi_debug = [swap32(i) for i in engine_debug.finalize()[::-1]]

    zi = []
    for _ in range(0, NB_ROT, OUTPUT_SIZE):
        yield Timer(10, units='ns')
        zi.insert(0, dut.zi.value.integer)

    zi_bin = ''.join([get_bin(i, OUTPUT_SIZE) for i in zi])
    zi_debug_bin = ''.join([get_bin(i, DBG_OUTPUT_SIZE) for i in zi_debug])
        
    dut.generate_keystream <= 0
    
    dut._log.info('Key stream generation ends !')

    dut._log.info('Display cosimulation results (results are represented in big endian):')
    dut._log.info(f' zi bin = {zi_bin}')
    dut._log.info(f' zi hex = {bin_to_hex(zi_bin)}')
    dut._log.info(f'dbg bin = {zi_debug_bin}')
    dut._log.info(f'dbg hex = {bin_to_hex(zi_debug_bin)}')

    if zi_bin != zi_debug_bin:
        raise TestError('Design output do not match with debug version')

    yield Timer(100, units='ns')