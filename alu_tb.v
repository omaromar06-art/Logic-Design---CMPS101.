`timescale 1ns / 1ps

// =============================================================
// ALU TESTBENCH  –  CMPS101 Logic Design, Spring 2026
// Cairo University, Faculty of Engineering, CCE
//
// Tests all 3 operations through the integrated ALU:
//   S=00 → Addition       (49 cases)
//   S=01 → Subtraction    (49 cases)
//   S=10 → Multiplication (49 cases)
//
// Verifies: R[4:0], SF, ZF, DZF, EF, OF
// Outputs:  Console summary + alu_results.txt
// =============================================================

module alu_tb;

    // =======================
    // 1  DUT SIGNALS
    // =======================
    reg  [2:0] A, B;        // 3-bit sign-magnitude inputs
    reg  [1:0] S;           // S[1]: mul select, S[0]: add/sub select
    wire [4:0] R;           // 5-bit result: R[4]=sign, R[3:0]=magnitude
    wire       SF, ZF, DZF, EF, OF;

    // Instantiate ALU (Device Under Test)
    alu dut (
        .A(A), .B(B), .S(S),
        .R(R),
        .SF(SF), .ZF(ZF), .DZF(DZF), .EF(EF), .OF(OF)
    );

    // =======================
    // 2  COUNTERS & FILE
    // =======================
    integer result_file;
    integer total_tests, pass_count, fail_count;
    integer ia, ib;

    // =======================
    // 3  INTEGER → 3-BIT SIGN-MAGNITUDE
    // =======================
    function [2:0] int_to_sm3;
        input integer val;
        integer abs_val;
        begin
            abs_val    = (val < 0) ? -val : val;
            int_to_sm3 = (val < 0) ? {1'b1, abs_val[1:0]}
                                   : {1'b0, abs_val[1:0]};
        end
    endfunction

    // =======================
    // 4  EXPECTED R[4:0] FROM DECIMAL RESULT
    // =======================
    // Builds the 5-bit sign-magnitude R value
    // For add/sub: R = {sign, 0, mag[2:0]}  (bit 3 is always 0)
    // For mult:    R = {sign, mag[3:0]}
    function [4:0] expected_R_addsub;
        input integer result;
        integer abs_r;
        begin
            abs_r = (result < 0) ? -result : result;
            if (result == 0)
                expected_R_addsub = 5'b00000;
            else if (result < 0)
                expected_R_addsub = {1'b1, 1'b0, abs_r[2:0]};
            else
                expected_R_addsub = {1'b0, 1'b0, abs_r[2:0]};
        end
    endfunction

    function [4:0] expected_R_mult;
        input integer result;
        integer abs_r;
        begin
            abs_r = (result < 0) ? -result : result;
            if (result == 0)
                expected_R_mult = 5'b00000;
            else if (result < 0)
                expected_R_mult = {1'b1, abs_r[3:0]};
            else
                expected_R_mult = {1'b0, abs_r[3:0]};
        end
    endfunction

    // =======================
    // 5  MAIN TEST SEQUENCE
    // =======================
    initial begin

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;

        result_file = $fopen("alu_results.txt", "w");

        $fdisplay(result_file, "============================================================");
        $fdisplay(result_file, "  ALU INTEGRATION TESTBENCH RESULTS");
        $fdisplay(result_file, "  Ports: (A, B, S, R) + (SF, ZF, DZF, EF, OF)");
        $fdisplay(result_file, "  ADD (S=00)  |  SUB (S=01)  |  MUL (S=10)");
        $fdisplay(result_file, "============================================================");
        $fdisplay(result_file, "");

        // ─────────────────────────────────────
        // TEST ADDITION  (S = 2'b00)
        // ─────────────────────────────────────
        S = 2'b00;

        $display("");
        $display("============================================");
        $display("  TESTING ADDITION (S=00)");
        $display("============================================");

        $fdisplay(result_file, "--- ADDITION (S=00) ----------------------------------------");
        $fdisplay(result_file, "  A\t  B\tExpR\tR(got)\tSF ZF DZF EF OF\tResult");

        for (ia = -3; ia <= 3; ia = ia + 1) begin
            for (ib = -3; ib <= 3; ib = ib + 1) begin
                run_test_addsub(ia, ib, ia + ib, "ADD");
            end
        end

        $fdisplay(result_file, "");

        // ─────────────────────────────────────
        // TEST SUBTRACTION  (S = 2'b01)
        // ─────────────────────────────────────
        S = 2'b01;

        $display("");
        $display("============================================");
        $display("  TESTING SUBTRACTION (S=01)");
        $display("============================================");

        $fdisplay(result_file, "--- SUBTRACTION (S=01) -------------------------------------");
        $fdisplay(result_file, "  A\t  B\tExpR\tR(got)\tSF ZF DZF EF OF\tResult");

        for (ia = -3; ia <= 3; ia = ia + 1) begin
            for (ib = -3; ib <= 3; ib = ib + 1) begin
                run_test_addsub(ia, ib, ia - ib, "SUB");
            end
        end

        $fdisplay(result_file, "");

        // ─────────────────────────────────────
        // TEST MULTIPLICATION  (S = 2'b10)
        // ─────────────────────────────────────
        S = 2'b10;

        $display("");
        $display("============================================");
        $display("  TESTING MULTIPLICATION (S=10)");
        $display("============================================");

        $fdisplay(result_file, "--- MULTIPLICATION (S=10) ----------------------------------");
        $fdisplay(result_file, "  A\t  B\tExpR\tR(got)\tSF ZF DZF EF OF\tResult");

        for (ia = -3; ia <= 3; ia = ia + 1) begin
            for (ib = -3; ib <= 3; ib = ib + 1) begin
                run_test_mult(ia, ib, ia * ib, "MUL");
            end
        end

        // ─────────────────────────────────────
        // FINAL SUMMARY
        // ─────────────────────────────────────
        $fdisplay(result_file, "");
        $fdisplay(result_file, "============================================================");
        $fdisplay(result_file, "  TOTAL:  %0d tests  |  PASSED: %0d  |  FAILED: %0d",
                  total_tests, pass_count, fail_count);
        $fdisplay(result_file, "============================================================");

        $display("");
        $display("============================================================");
        $display("  TOTAL:  %0d tests  |  PASSED: %0d  |  FAILED: %0d",
                 total_tests, pass_count, fail_count);
        $display("============================================================");

        if (fail_count == 0)
            $display("  >>> ALL %0d TESTS PASSED <<<", total_tests);
        else
            $display("  >>> %0d TESTS FAILED — see alu_results.txt <<<", fail_count);

        $display("");

        $fclose(result_file);
        $stop;
    end

    // =======================
    // 6  ADD/SUB TEST TASK
    // =======================
    task run_test_addsub;
        input integer a_val, b_val, expected_result;
        input [3*8:1] op_name;

        integer abs_res;
        reg [4:0] exp_R;
        reg     exp_SF, exp_ZF, exp_EF, exp_OF;
        reg     test_pass;

        begin
            A = int_to_sm3(a_val);
            B = int_to_sm3(b_val);
            #10;

            // Expected R for add/sub
            exp_R = expected_R_addsub(expected_result);

            // Expected flags
            abs_res = (expected_result < 0) ? -expected_result : expected_result;
            exp_ZF = (expected_result == 0) ? 1'b1 : 1'b0;
            exp_SF = (expected_result < 0)  ? 1'b1 : 1'b0;
            exp_EF = (abs_res[0] == 1'b0)   ? 1'b1 : 1'b0;
            exp_OF = (abs_res[0] == 1'b1)   ? 1'b1 : 1'b0;

            // Compare
            test_pass = (R   === exp_R)   &&
                        (SF  === exp_SF)  &&
                        (ZF  === exp_ZF)  &&
                        (DZF === 1'b0)    &&
                        (EF  === exp_EF)  &&
                        (OF  === exp_OF);

            total_tests = total_tests + 1;

            if (test_pass) begin
                pass_count = pass_count + 1;
                $fdisplay(result_file,
                    "  %0d\t  %0d\t%b\t%b\t%b  %b   %b   %b  %b\tPASS",
                    a_val, b_val, exp_R, R,
                    SF, ZF, DZF, EF, OF);
            end else begin
                fail_count = fail_count + 1;
                $display("  FAIL: %s  A=%0d  B=%0d  Expected=%0d",
                         op_name, a_val, b_val, expected_result);
                $display("         R  : exp=%b  got=%b %s",
                         exp_R, R, (R !== exp_R) ? "<< MISMATCH" : "");
                $display("         SF : exp=%b  got=%b %s",
                         exp_SF, SF, (SF !== exp_SF) ? "<< MISMATCH" : "");
                $display("         ZF : exp=%b  got=%b %s",
                         exp_ZF, ZF, (ZF !== exp_ZF) ? "<< MISMATCH" : "");
                $display("         DZF: exp=0  got=%b %s",
                         DZF, (DZF !== 1'b0) ? "<< MISMATCH" : "");
                $display("         EF : exp=%b  got=%b %s",
                         exp_EF, EF, (EF !== exp_EF) ? "<< MISMATCH" : "");
                $display("         OF : exp=%b  got=%b %s",
                         exp_OF, OF, (OF !== exp_OF) ? "<< MISMATCH" : "");
                $fdisplay(result_file,
                    "  %0d\t  %0d\t%b\t%b\t%b  %b   %b   %b  %b\t** FAIL **",
                    a_val, b_val, exp_R, R,
                    SF, ZF, DZF, EF, OF);
            end
        end
    endtask

    // =======================
    // 7  MULTIPLICATION TEST TASK
    // =======================
    task run_test_mult;
        input integer a_val, b_val, expected_result;
        input [3*8:1] op_name;

        integer abs_res;
        reg [4:0] exp_R;
        reg     exp_SF, exp_ZF, exp_EF, exp_OF;
        reg     test_pass;

        begin
            A = int_to_sm3(a_val);
            B = int_to_sm3(b_val);
            #10;

            // Expected R for multiplication
            exp_R = expected_R_mult(expected_result);

            // Expected flags
            abs_res = (expected_result < 0) ? -expected_result : expected_result;
            exp_ZF = (expected_result == 0) ? 1'b1 : 1'b0;
            exp_SF = (expected_result < 0)  ? 1'b1 : 1'b0;
            exp_EF = (abs_res[0] == 1'b0)   ? 1'b1 : 1'b0;
            exp_OF = (abs_res[0] == 1'b1)   ? 1'b1 : 1'b0;

            // Compare
            test_pass = (R   === exp_R)   &&
                        (SF  === exp_SF)  &&
                        (ZF  === exp_ZF)  &&
                        (DZF === 1'b0)    &&
                        (EF  === exp_EF)  &&
                        (OF  === exp_OF);

            total_tests = total_tests + 1;

            if (test_pass) begin
                pass_count = pass_count + 1;
                $fdisplay(result_file,
                    "  %0d\t  %0d\t%b\t%b\t%b  %b   %b   %b  %b\tPASS",
                    a_val, b_val, exp_R, R,
                    SF, ZF, DZF, EF, OF);
            end else begin
                fail_count = fail_count + 1;
                $display("  FAIL: %s  A=%0d  B=%0d  Expected=%0d",
                         op_name, a_val, b_val, expected_result);
                $display("         R  : exp=%b  got=%b %s",
                         exp_R, R, (R !== exp_R) ? "<< MISMATCH" : "");
                $display("         SF : exp=%b  got=%b %s",
                         exp_SF, SF, (SF !== exp_SF) ? "<< MISMATCH" : "");
                $display("         ZF : exp=%b  got=%b %s",
                         exp_ZF, ZF, (ZF !== exp_ZF) ? "<< MISMATCH" : "");
                $display("         DZF: exp=0  got=%b %s",
                         DZF, (DZF !== 1'b0) ? "<< MISMATCH" : "");
                $display("         EF : exp=%b  got=%b %s",
                         exp_EF, EF, (EF !== exp_EF) ? "<< MISMATCH" : "");
                $display("         OF : exp=%b  got=%b %s",
                         exp_OF, OF, (OF !== exp_OF) ? "<< MISMATCH" : "");
                $fdisplay(result_file,
                    "  %0d\t  %0d\t%b\t%b\t%b  %b   %b   %b  %b\t** FAIL **",
                    a_val, b_val, exp_R, R,
                    SF, ZF, DZF, EF, OF);
            end
        end
    endtask

endmodule
