`include "config.svh"

module top
# (
  parameter clk_mhz = 50,
            w_key   = 4,
            w_sw    = 8,
            w_led   = 8,
            w_digit = 8,
            w_gpio  = 20
)
(
  input                        clk,
  input                        rst,

  // Keys, switches, LEDs

  input        [w_key   - 1:0] key,
  input        [w_sw    - 1:0] sw,
  output logic [w_led   - 1:0] led,

  // A dynamic seven-segment display

  output logic [          7:0] abcdefgh,
  output logic [w_digit - 1:0] digit,

  // VGA

  output logic                 vsync,
  output logic                 hsync,
  output logic [          3:0] red,
  output logic [          3:0] green,
  output logic [          3:0] blue,

  // General-purpose Input/Output

  inout  logic [w_gpio  - 1:0] gpio
);

  //--------------------------------------------------------------------------

  // assign led      = '0;
  // assign abcdefgh = '0;
  // assign digit    = '0;
     assign vsync    = '0;
     assign hsync    = '0;
     assign red      = '0;
     assign green    = '0;
     assign blue     = '0;

  //--------------------------------------------------------------------------

  wire [1:0] in  = { key [1], key [0] };

  //--------------------------------------------------------------------------

  // Implementation 1: tedious

  wire [3:0] dec0;

  assign dec0 [0] = ~ in [1] & ~ in [0];
  assign dec0 [1] = ~ in [1] &   in [0];
  assign dec0 [2] =   in [1] & ~ in [0];
  assign dec0 [3] =   in [1] &   in [0];

  // Implementation 2: case

  logic [3:0] dec1;

  always_comb
    case (in)
    2'b00: dec1 = 4'b0001;
    2'b01: dec1 = 4'b0010;
    2'b10: dec1 = 4'b0100;
    2'b11: dec1 = 4'b1000;
    endcase

  // Implementation 3: shift

  wire [3:0] dec2 = 4'b0001 << in;

  // Implementation 4: index

  logic [3:0] dec3;

  always_comb
  begin
    dec3 = '0;
    dec3 [in] = 1'b1;
  end

  //--------------------------------------------------------------------------

  assign led      = w_led'   ({ dec0, dec1, dec2, dec3 });
  assign abcdefgh = key [2] ? { dec0, dec1 } : { dec2, dec3 };
  assign digit    = w_digit' ({ dec0, dec1, dec2, dec3 });

endmodule
