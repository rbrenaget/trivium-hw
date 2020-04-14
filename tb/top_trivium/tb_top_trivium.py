# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
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
def test_trivium_fsm(dut):
    """Top Trivium Test Bench
    :param dut: device under test
    """
    OUTPUT_SIZE = dut.G_OUTPUT_SIZE.value.integer
    DBG_OUTPUT_SIZE = 32
    N_BLOCKS = 2

    get_bin = lambda x, n: format(x, 'b').zfill(n)
    get_hex = lambda x: hex(x)[2:].upper()

    # Set 6, vector# 3:
    key = [0xfa, 0xa7, 0x54, 0x01, 0xae, 0x5b, 0x08, 0xb5, 0x62, 0x0f]
    iv = [0xc7, 0x60, 0xf9, 0x92, 0x2b, 0xc4, 0x5d, 0xf6, 0x8f, 0x28]

    key_bin = ''.join([get_bin(i, 8) for i in key])
    iv_bin = ''.join([get_bin(i, 8) for i in iv])

    engine_debug = Trivium()
    engine_debug.initialize(key, iv)

    n = int((OUTPUT_SIZE/DBG_OUTPUT_SIZE)*N_BLOCKS)
    engine_debug.update(n)
    zi_debug = [swap32(i) for i in engine_debug.finalize()[::-1]]
    zi_debug_bin = ''.join([get_bin(i, DBG_OUTPUT_SIZE) for i in zi_debug])

    dut._log.info('[*] Starting Trivium test bench')

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.TRV_CLK, 10, units='ns').start())

    dut._log.info('\t [*] Start system reset')
    dut.TRV_RST <= 1
    yield Timer(10, units='ns')
    dut.TRV_RST <= 0
    dut._log.info('\t [+] System reset finished')

    dut.TRV_START <= 1
    dut.TRV_PAUSE <= 0
    dut.TRV_KEY <= BinaryValue(key_bin)
    dut.TRV_IV <= BinaryValue(iv_bin)

    yield RisingEdge(dut.s_initialization)
    dut._log.info('\t [*] Process initialization')

    dut.TRV_START <= 0

    yield RisingEdge(dut.s_fsm_generate_keystream)
    dut._log.info('\t [+] Initialization finished')
    dut._log.info('\t [*] Key stream generation')

    yield RisingEdge(dut.TRV_READY)
    dut._log.info('\t [+] Key stream is available')

    zi = []
    for _ in range(n):
        yield RisingEdge(dut.TRV_CLK)
        zi.insert(0, dut.TRV_KEYSTREAM.value.integer)

    dut.TRV_PAUSE <= 1

    yield Timer(200, units='ns')

    dut.TRV_PAUSE <= 0

    yield Timer(200, units='ns')

    dut.TRV_PAUSE <= 1
    
    zi_bin = ''.join([get_bin(i, OUTPUT_SIZE) for i in zi])

    dut._log.info('\t [+] Key stream generation finished')

    dut._log.info('[+] Display cosimulation results (results are represented in big endian):')
    dut._log.info(f' zi bin = {zi_bin}')
    dut._log.info(f' zi hex = {bin_to_hex(zi_bin)}')
    dut._log.info(f'dbg bin = {zi_debug_bin}')
    dut._log.info(f'dbg hex = {bin_to_hex(zi_debug_bin)}')

    if zi_bin != zi_debug_bin:
        raise TestError('Design output do not match with debug version')

    yield Timer(200, units='ns')