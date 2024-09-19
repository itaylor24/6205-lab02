module rgb_controller(input wire clk_in,
        input wire rst_in,
        input wire [7:0] r_in,
        input wire [7:0] g_in,
        input wire [7:0] b_in,
        output logic r_out,
        output logic g_out,
        output logic b_out
    );

    pwm p_r(.clk_in(clk_in), .rst_in(rst_in), .dc_in(r_in), .sig_out(r_out));
    pwm p_g(.clk_in(clk_in), .rst_in(rst_in), .dc_in(g_in), .sig_out(g_out));
    pwm p_b(.clk_in(clk_in), .rst_in(rst_in), .dc_in(b_in), .sig_out(b_out));

  
endmodule