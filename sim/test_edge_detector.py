import cocotb
import os
import random
import sys
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

@cocotb.test()
async def test_a(dut):
    # """cocotb test?"""
    # dut._log.info("Starting...")
    # cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    # await ClockCycles(dut.clk_in, 3)
    # dut._log.info("Holding reset...")
    # dut.rst_in.value = 1
    # dut.evt_in.value = 0
    # await ClockCycles(dut.clk_in, 3)
    # assert dut.count_out.value.integer == 0, "Reset not setting count_out to 0 :/"
    # await  FallingEdge(dut.clk_in)
    # dut._log.info("setting reset to 0")
    # dut.rst_in.value = 0
    # await ClockCycles(dut.clk_in, 3)
    # assert dut.count_out.value.integer == 0, "count_out not holding to 0 even with evt_in=0."
    # await  FallingEdge(dut.clk_in)
    # dut.evt_in.value = 1
    # await ClockCycles(dut.clk_in, 3)
    # await FallingEdge(dut.clk_in)
    # assert dut.count_out.value.integer == 3, "count_out did not increment."
    # await ClockCycles(dut.clk_in, 3)
    # await FallingEdge(dut.clk_in)
    # assert dut.count_out.value.integer == 6, "count_out did not increment."
    # dut.evt_in.value = 0
    # await ClockCycles(dut.clk_in, 3)
    # await FallingEdge(dut.clk_in)
    # assert dut.count_out.value.integer == 6, "count_out did not increment."
    # dut.rst_in.value = 1
    # await ClockCycles(dut.clk_in, 1)
    # await FallingEdge(dut.clk_in)
    # assert dut.count_out.value.integer == 0, "reset failed."
    """cocotb test?"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    await ClockCycles(dut.clk_in, 3)
    dut._log.info("Holding reset...")
    dut.rst_in.value = 1
    dut.btn_output.value = 0
    await ClockCycles(dut.clk_in, 3)
    assert dut.prev_btn_output.value.integer == 0, "Reset not setting prev_btn_output to 0 :/"
    assert dut.btn_pulse.value.integer == 0, "Reset not setting prev_btn_pulse to 0 :/"
    await  FallingEdge(dut.clk_in)
    dut._log.info("setting reset to 0")
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 3)
    assert dut.prev_btn_output.value.integer == 0, "count_out not holding to 0 even with btn_output=0."
    assert dut.btn_pulse.value.integer == 0, "count_out not holding to 0 even with btn_output=0."
    await ClockCycles(dut.clk_in, 5)
    dut.btn_output.value = 1
    await ClockCycles(dut.clk_in, 5)
    dut.btn_output.value = 0
    ...

def edge_detector_runner():
    """Simulate the counter using the Python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "edge_detector.sv"] #grow/modify this as needed.
    build_test_args = ["-Wall"]#,"COCOTB_RESOLVE_X=ZEROS"]
    parameters = {} #!!! nice figured it out.
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="edge_detector",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="edge_detector",
        test_module="test_edge_detector",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    edge_detector_runner()