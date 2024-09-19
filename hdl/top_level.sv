`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level(
  input wire clk_100mhz, //100 MHz onboard clock
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [2:0] rgb0, //RGB channels of RGB LED0
  output logic [2:0] rgb1, //RGB channels of RGB LED1
  output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
  output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
  output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
  output logic [6:0] ss1_c, //cathode controls for the segments of lower four digits
  output logic dclk, 
  output logic copi, 
  input wire cipo, 
  output logic cs
  );
 
  //shut up those rgb LEDs for now (active high):
  assign rgb1 = 0; //set to 0.
  assign rgb0 = 0; //set to 0. Change later!!
 
  //have btnd control system reset
  logic sys_rst;
  assign sys_rst = btn[0];
 
  //how many button presses have we seen so far?
  //wire this up to the LED display
  logic [15:0] btn_count; //use me to keep track of counting
  assign led = btn_count;
 
  //downstream/display variables:
  logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
  logic [6:0] ss_c; //used to grab output cathode signal for 7s leds
 
  // debouncer for the button. we wrote this in lecture together.
  //TODO: make a variable for the debounced
  //button output, and feed it into your edge detector
  logic btn_output;
 
  debouncer btn1_db(.clk_in(clk_100mhz),
                    .rst_in(sys_rst),
                    .dirty_in(btn[1]),
                    .clean_out(btn_output));
 
  // this signal should go high for one cycle on the ..
  //rising edge of the (debounced) button output
  logic btn_pulse;
  //TODO: write your edge detector for part 1 of the lab here!
  edge_detector ed(.clk_in(clk_100mhz), 
                  .rst_in(sys_rst),
                  .btn_output(btn_output), 
                  .btn_pulse(btn_pulse));
  //the button-press counter.
  //TODO: finish this during part 1 of the lab
  evt_counter msc(.clk_in(clk_100mhz),
                  .rst_in(sys_rst),
                  .evt_in(btn_pulse),
                  .count_out(btn_count));
 
  //for starters just display button count:
  assign val_to_display = btn_count;
 
  // uncomment seven segment module for part 2!
  
  seven_segment_controller mssc(.clk_in(clk_100mhz),
                               .rst_in(sys_rst),
                               .val_in(val_to_display),
                               .cat_out(ss_c),
                               .an_out({ss0_an, ss1_an}));
  
  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!

  // //NEW CODE TO ADD IN
  // //rgb controller instance (from last week!)
 
  logic [7:0] red, green, blue; //8 bit channels to hold color values
  assign val_to_display = {red, 4'h0, green, 4'h0, blue}; //MUST CHANGE
 
  rgb_controller mrgbc (.clk_in(clk_100mhz),
                        .rst_in(btn[0]),
                        .r_in(red),
                        .g_in(green),
                        .b_in(blue),
                        .r_out(rgb0[0]),
                        .g_out(rgb0[1]),
                        .b_out(rgb0[2]));
 
  parameter ADC_DATA_WIDTH = 17; //MUST CHANGE
  parameter ADC_DATA_CLK_PERIOD = 50; //MUST CHANGE
 
  parameter ADC_READ_PERIOD = 100_000; //read one channel of ADC every millisec
 
  //SPI interface controls
  logic [ADC_DATA_WIDTH-1:0] spi_write_data;
  logic [ADC_DATA_WIDTH-1:0] spi_read_data;
  logic spi_trigger;
  logic spi_read_data_valid;
 
  //built in previous section:
  spi_con
  #(   .DATA_WIDTH(ADC_DATA_WIDTH),
       .DATA_CLK_PERIOD(ADC_DATA_CLK_PERIOD)
   )my_spi_con
   ( .clk_in(clk_100mhz),
     .rst_in(sys_rst),
     .data_in(spi_write_data),
     .trigger_in(spi_trigger),
     .data_out(spi_read_data),
     .data_valid_out(spi_read_data_valid), //high when output data is present.
     .chip_data_out(copi), //(serial dout preferably)
     .chip_data_in(cipo), //(serial din preferably)
     .chip_clk_out(dclk),
     .chip_sel_out(cs)
    );
 
  //counter from week 1. that will count up and we'll use for triggering
  logic [31:0] select_count;
  counter //include your regular counter from week 1 in source!
  select_counter
  (  .clk_in(clk_100mhz),
     .rst_in(sys_rst),
     .period_in(ADC_READ_PERIOD),
     .count_out(select_count)
  );
  //adc_count used for cycling through measuring ADC channel 0, 1, and 2
  logic [1:0] adc_count;
 
  always_ff @(posedge clk_100mhz)begin
    if (spi_read_data_valid)begin//if the SPI has received message back:
      case(adc_count) //update appropriate values based on adc_count
        0: begin 
          red <= spi_read_data[10:0]; 
        end
        1: begin 
          green <= spi_read_data[10:0];
        end  
        2: begin 
          blue <= spi_read_data[10:0];
        end
        default: begin 
          red<=red; 
          green<=green; 
          blue<=blue; 
        end
      endcase
    end
    if (select_count=='d1)begin //once a millisecond select_count==1
      case(adc_count) //look ahead:
        0: begin
          spi_write_data <= {5'b11000, 12'b0}; //MUST CHANGE
        end
        1: begin
          spi_write_data <= {5'b11001, 12'b0}; //MUST CHANGE
        end
        2: begin
          spi_write_data <= {5'b11010, 12'b0}; //MUST CHANGE
        end
        default:begin
          spi_write_data <= 0;
        end
      endcase
      spi_trigger <= 1; //trigger spi transaction (channel read based on case above)
      adc_count <= adc_count==2?0:adc_count + 1; //keep cycle to 0, 1, 2, 0..
    end else begin
      spi_trigger <= 0;
    end
  end
 
endmodule // top_level
 
`default_nettype wire