TOPLEVEL_LANG ?= vhdl

PWD=$(shell pwd)

TOPLEVEL := trivium_engine
MODULE := tb_$(TOPLEVEL)

VHDL_SOURCES=$(PWD)/../../rtl/vhdl/$(TOPLEVEL).vhd

SIM=ghdl
SIM_ARGS=--vcd=tb_$(TOPLEVEL).vcd
# COMPILE_ARGS=--std=08 --ieee=synopsys
export COCOTB_REDUCED_LOG_FMT=1

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
