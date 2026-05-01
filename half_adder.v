`timescale 1ns / 1ps

module half_adder(
    input  a, b,
    output sum, cout
);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule
