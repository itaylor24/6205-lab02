module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/isaactaylor/VSCodeProjects/6205labs/lab02/sim_build/spi_con.fst");
    $dumpvars(0, spi_con);
end
endmodule
