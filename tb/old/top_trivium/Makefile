TOPLEVEL_LANG ?= vhdl

PWD=$(shell pwd)

TOPLEVEL := top_trivium
MODULE := tb_$(TOPLEVEL)

VHDL_SOURCES=$(PWD)/../../rtl/vhdl/old/trivium_package.vhd \
			 $(PWD)/../../rtl/vhdl/old/trivium_fsm.vhd \
			 $(PWD)/../../rtl/vhdl/old/trivium_engine.vhd   \
			 $(PWD)/../../rtl/vhdl/old/$(TOPLEVEL).vhd

SIM=ghdl
SIM_ARGS=--vcd=tb_$(TOPLEVEL).vcd
# COMPILE_ARGS=--std=08 --ieee=synopsys
export COCOTB_REDUCED_LOG_FMT=1

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim