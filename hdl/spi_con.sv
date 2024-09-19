module spi_con
     #(parameter DATA_WIDTH = 8,
       parameter DATA_CLK_PERIOD = 100
      )
      (input wire   clk_in, //system clock (100 MHz)
       input wire   rst_in, //reset in signal
       input wire   [DATA_WIDTH-1:0] data_in, //data to send
       input wire   trigger_in, //start a transaction
       output logic [DATA_WIDTH-1:0] data_out, //data received!
       output logic data_valid_out, //high when output data is present.
 
       output logic chip_data_out, //(COPI)
       input wire   chip_data_in, //(CIPO)
       output logic chip_clk_out, //(DCLK)
       output logic chip_sel_out // (CS)
      );
  //your code here
  logic [DATA_WIDTH-1:0] stored_data_in; 
  logic [DATA_WIDTH-1:0] stored_data_out;
  localparam COUNT_SIZE = $clog2(DATA_CLK_PERIOD) - 1; 
  localparam MAX_COUNT = DATA_CLK_PERIOD >> 1; 
  logic [COUNT_SIZE-1:0] counter; 
  localparam DATA_COUNT_SIZE = $clog2(DATA_WIDTH); 
  logic [DATA_COUNT_SIZE:0] data_counter; 

  always_ff @(posedge clk_in) begin 
    if(rst_in) begin 
        // data_in <= 0; 
        // trigger_in <= 0; 
        data_out <= 0; 
        data_valid_out <= 0; 
        chip_data_out <= 0; 
        // chip_data_in <= 0; 
        chip_clk_out <= 0; 
        chip_sel_out <= 1; 
        counter <= 0; 
        data_counter <= 0;
        data_valid_out <= 0;  
        stored_data_in <= 0;
        stored_data_out <= 0;
    end else begin 
        if(!data_valid_out) begin
            if(trigger_in) begin 
                stored_data_in <= data_in; 
                chip_sel_out <= 0; 
                chip_data_out <= data_in[DATA_WIDTH-1];
                stored_data_in <= data_in << 1;   
            end else begin
                if(!chip_sel_out) begin 
                    if(counter >= MAX_COUNT - 1) begin //last dclk cycle 
                        counter <= 0;
                        if(chip_clk_out) begin
                            chip_data_out <= stored_data_in[DATA_WIDTH-1];
                            stored_data_in <= stored_data_in << 1;      
                        end else begin 
                            stored_data_out <= {stored_data_out[DATA_WIDTH-2:0], chip_data_in};
                            data_counter <= data_counter + 1;  
                        end 
                        chip_clk_out <= ~chip_clk_out;
                        if(data_counter >= DATA_WIDTH) begin
                            if(chip_clk_out) begin
                                chip_sel_out <= 1; 
                                data_valid_out <= 1; 
                                data_out <= stored_data_out; 
                                data_counter <= 0;
                            end
                        end 
                    end else begin 
                        counter <= counter + 1;
                    end  
                end 
            end 
        end else begin 
            data_valid_out <= 0; 
        end 
    end 
  end 
endmodule