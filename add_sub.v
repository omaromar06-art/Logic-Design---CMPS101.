`timescale 1ns / 1ps

module add_sub(
    input  [2:0] A,   // A[2]=sign, A[1:0]=magnitude
    input  [2:0] B,   // B[2]=sign, B[1:0]=magnitude
    input        op,  // 0 = A + B, 1 = A - B
    output [3:0] R,   // R[3]=sign, R[2:0]=magnitude
    output       SF,  // Sign flag (1 if negative)
    output       ZF,  // Zero flag (1 if result = 0)
    output       EF,  // Even flag
    output       OF   // Odd flag
);

// =======================
// 1 SIGN HANDLING
// =======================

// If op=1 (subtract), flip sign of B
wire sB_eff;
xor G1(sB_eff, B[2], op);

// ctrl decides operation:
// ctrl = 0 → same sign → ADD
// ctrl = 1 → different sign → SUBTRACT
wire ctrl;
xor G2(ctrl, A[2], sB_eff);

// =======================
// 2 PREPARE B FOR ADDER
// =======================

// If ctrl=1 → invert B bits (2's complement step)
wire B0d, B1d;
xor G3(B0d, B[0], ctrl);
xor G4(B1d, B[1], ctrl);

// =======================
// 3 ADDITION (2 FULL ADDERS)
// =======================

// First bit addition (LSB)
wire sum0, c1;
full_adder FA1(.a(A[0]), .b(B0d), .cin(ctrl), .sum(sum0), .cout(c1));

// Second bit addition
wire sum1, c2;
full_adder FA2(.a(A[1]), .b(B1d), .cin(c1), .sum(sum1), .cout(c2));

// =======================
// 4 BORROW DETECTION
// =======================

// If subtracting AND no carry → borrow happened
wire n_c2, borrow;
not G5(n_c2, c2);
and G6(borrow, ctrl, n_c2);

// =======================
// 5 FINAL MAGNITUDE FIX
// =======================

// LSB stays the same
wire mag0;
assign mag0 = sum0;

// If borrow happened, fix MSB
wire borrow_sum0, mag1;
and G7(borrow_sum0, borrow, sum0);
xor G8(mag1, sum1, borrow_sum0);

// Carry only valid when adding (not subtracting)
wire mag2, n_ctrl;
not G9(n_ctrl, ctrl);
and G10(mag2, c2, n_ctrl);

// =======================
// 6 RESULT SIGN
// =======================

// If no borrow → result sign = A sign
// If borrow → result sign = B sign (after op effect)
wire n_borrow, term1, term2, sign_raw;
not G11(n_borrow, borrow);
and G12(term1, n_borrow, A[2]);
and G13(term2, borrow, sB_eff);
or  G14(sign_raw, term1, term2);

// If result = 0 → force sign = 0
wire mag_any, sign_out;
or  G15(mag_any, mag0, mag1, mag2);
and G16(sign_out, sign_raw, mag_any);

// =======================
// 7 OUTPUT + FLAGS
// =======================

// Pack final result
assign R = {sign_out, mag2, mag1, mag0};

// Flags
assign ZF = ~mag_any;        // 1 if result = 0
assign SF = sign_out & ~ZF;  // 1 if negative (but not zero)
assign EF = ~mag0;           // even → LSB = 0
assign OF =  mag0;           // odd  → LSB = 1

endmodule