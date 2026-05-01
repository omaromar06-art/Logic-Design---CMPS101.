`timescale 1ns / 1ps

// =======================
// ALU INTEGRATION MODULE
// =======================
// Ports match CMPS101 spec: (A, B, S, R) + (SF, ZF, DZF, EF, OF)
module alu (
    input  [2:0] A,        // Sign-magnitude input A
    input  [2:0] B,        // Sign-magnitude input B
    input  [1:0] S,        // S[1]: Operation select(multiplication) , S[0]: Add/Sub mode
    output reg [4:0] R,    // 5-bit result: R[4]=sign, R[3:0]=magnitude
    output reg SF,         // Sign flag
    output reg ZF,         // Zero flag
    output DZF,            // Div-by-zero flag (no remainder module, always 0)
    output reg EF,         // Even flag
    output reg OF          // Odd flag
);

    // DZF = 0 (no remainder/division in this team)
    assign DZF = 1'b0;

    // Internal wires for add_sub outputs
    wire [3:0] add_sub_R;
    wire add_sub_SF, add_sub_ZF, add_sub_EF, add_sub_OF;
    
    // Internal wires for multiplier outputs
    wire [4:0] mult_R;
    wire mult_SF, mult_ZF, mult_EF, mult_OF;
    
    // Instantiate add_sub module (from add_sub.v)
    add_sub add_sub_inst (
        .A(A),
        .B(B),
        .op(S[0]),           // S[0]=0 for add, 1 for subtract
        .R(add_sub_R),      // connect el R bel result bta3et add/sub
        .SF(add_sub_SF),
        .ZF(add_sub_ZF),
        .EF(add_sub_EF),
        .OF(add_sub_OF)
    );
    
    // Instantiate multiplier (from mul.v)
    multip mult_inst (
        .A(A),
        .B(B),
        .result(mult_R),       //connect el result b result multiplication
        .SF(mult_SF),          //nafs el kalam lel flags
        .ZF(mult_ZF),
        .EF(mult_EF),
        .OF(mult_OF)
    );
    
    // Selection logic based on S[1] (most significant bit) lw 1 yeb'a multiplication 
    always @(*) begin
        case (S[1])
            1'b0: begin  // Addition(0)  /Subtraction (1)
                // Widen 4-bit add_sub result to 5-bit: {sign, 0, mag[2:0]}
                R = {add_sub_R[3], 1'b0 , add_sub_R[2:0]};
                SF = add_sub_SF;
                ZF = add_sub_ZF;
                EF = add_sub_EF;
                OF = add_sub_OF;
            end
            1'b1: begin  // Multiplication
                R = mult_R;
                SF = mult_SF;
                ZF = mult_ZF;
                EF = mult_EF;
                OF = mult_OF;
            end
            default: begin
                R  = 5'b00000;
                SF = 1'b0;
                ZF = 1'b0;
                EF = 1'b0;
                OF = 1'b0;
            end
        endcase
    end

endmodule