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


OUTPUT_SIZE = 32
DBG_OUTPUT_SIZE = 32
N_BLOCKS = 32

get_bin = lambda x, n: format(x, 'b').zfill(n)
get_hex = lambda x: hex(x)[2:].upper()

# Set 6, vector# 3:
key = [0xfa, 0xa7, 0x54, 0x01, 0xae, 0x5b, 0x08, 0xb5, 0x62, 0x0f]
iv = [0xc7, 0x60, 0xf9, 0x92, 0x2b, 0xc4, 0x5d, 0xf6, 0x8f, 0x28]

key_bin = ''.join([get_bin(i, 8) for i in key[::-1]])
iv_bin = ''.join([get_bin(i, 8) for i in iv[::-1]])

engine_debug = Trivium()
engine_debug.initialize(key, iv)

n = int((OUTPUT_SIZE/DBG_OUTPUT_SIZE)*N_BLOCKS)
engine_debug.update(n)
zi_debug = [swap32(i) for i in engine_debug.finalize()[::-1]]
zi_debug_bin = ''.join([get_bin(i, DBG_OUTPUT_SIZE) for i in zi_debug])


@cocotb.test()
def test_trivium_module(dut):
    """Trivium Module Test Bench
    :param dut: device under test
    """
    dut._log.info('[*] Starting Trivium test bench')

    # Instantiate a 100MHz clock
    cocotb.fork(Clock(dut.TRV_CLK, 10, units='ns').start())

    dut._log.info('\t [*] Start system reset')
    dut.TRV_RST <= 1
    yield Timer(10, units='ns')
    dut.TRV_RST <= 0
    dut._log.info('\t [+] System reset finished')

    dut.TRV_START <= 1
    dut.TRV_INTERRUPT <= 0
    dut.TRV_N_BLOCKS <= N_BLOCKS
    dut.TRV_KEY <= BinaryValue(key_bin, bigEndian=True)
    dut.TRV_IV <= BinaryValue(iv_bin, bigEndian=True)

    dut._log.info('\t [*] Process key & iv loading')
    yield RisingEdge(dut.loaded)
    dut._log.info('\t [+] Loaded')
    dut.TRV_START <= 0

    # dut._log.info('\t [*] Process initialization')
    yield RisingEdge(dut.ready)
    # dut._log.info('\t [+] Initialized')

    yield Timer(100, units='ns')

    dut.TRV_INTERRUPT <= 1

    yield Timer(50, units='ns')

    dut.TRV_INTERRUPT <= 0

    yield RisingEdge(dut.TRV_DONE)

    yield Timer(200, units='ns')