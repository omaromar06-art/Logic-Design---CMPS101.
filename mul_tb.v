`timescale 1ns / 1ps

// =============================================================
// MULTIPLIER TESTBENCH – CMPS101 Logic Design, Spring 2026
// Tests all 49 combinations: A,B from -3 to +3
// Saves results to mult.txt using $fopen/$fclose
// =============================================================

module mul_tb;

    // DUT signals
    reg  [2:0] A, B;
    wire [4:0] result;
    wire       SF, ZF, EF, OF;

    // Instantiate DUT
    multip dut (
        .A(A), .B(B),
        .result(result),
        .SF(SF), .ZF(ZF), .EF(EF), .OF(OF)
    );

    // File handle & loop variables
    integer mul_file;
    integer ia, ib, res_val;

    // ------------------------------------------------------------------
    // Convert signed integer (-3..3) to 3-bit sign-magnitude
    // ------------------------------------------------------------------
    function [2:0] int_to_sm3;
        input integer val;
        integer a;
        begin
            a = (val < 0) ? -val : val;
            int_to_sm3 = (val < 0) ? {1'b1, a[1:0]} : {1'b0, a[1:0]};
        end
    endfunction

    // ------------------------------------------------------------------
    // Convert 5-bit sign-magnitude result to signed integer for display
    // ------------------------------------------------------------------
    function integer sm5_to_int;
        input [4:0] sm;
        integer mag;
        begin
            mag = sm[3:0];
            sm5_to_int = sm[4] ? -mag : mag;
        end
    endfunction

    // Auto-update decimal result
    always @(result) begin
        res_val = sm5_to_int(result);
    end

    // ------------------------------------------------------------------
    // Main test sequence
    // ------------------------------------------------------------------
    initial begin
        mul_file = $fopen("mult.txt", "w");

        // Write header matching the expected format
        $fdisplay(mul_file, "A       A(bin)  B       B(bin)  Result  R(bin)  SF  ZF  EF  OF");

        for (ia = -3; ia <= 3; ia = ia + 1) begin
            for (ib = -3; ib <= 3; ib = ib + 1) begin
                A = int_to_sm3(ia);
                B = int_to_sm3(ib);
                #10;

                $fdisplay(mul_file, "%2d      %b     %2d      %b      %2d     %b   %b   %b   %b   %b",
                          ia, A, ib, B, res_val, result, SF, ZF, EF, OF);
            end
        end

        $fclose(mul_file);
        $display("mul_tb: DONE  –  mult.txt written with all 49 test cases.");
        $stop;
    end

endmodule