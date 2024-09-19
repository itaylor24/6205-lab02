`default_nettype none
module edge_detector
  ( input wire clk_in,
    input wire rst_in,
    input wire btn_output,
    output logic btn_pulse
  );

  logic prev_btn_output; 
  always_ff @(posedge clk_in) begin
    if(rst_in) begin
        prev_btn_output <= 1'b0; 
        btn_pulse <= 1'b0;
    end else begin
        if (btn_output && !prev_btn_output) begin 
            btn_pulse <= 1'b1; 
        end else begin
            btn_pulse <= 1'b0; 
        end  

        prev_btn_output <= btn_output; 

    end
  end
endmodule
`default_nettype wire