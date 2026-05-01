module multip
(
    input [2:0] A,
    input [2:0] B,
    output reg [4:0] result,
    output reg SF, ZF, EF, OF // Flags must be reg to be assigned in always block
);

    // Internal wires for logic
    reg [3:0] result_mag;
    reg result_sign;

    always @(*) begin
        // 1. Calculate Magnitude (Maps to 4 ANDs and 2 Half Adders)
        result_mag = A[1:0] * B[1:0];
        
        // 2. Calculate Sign (Maps to 1 XOR)
        result_sign = A[2] ^ B[2];

        // 3. Assemble Final Result
        // If magnitude is 0, we force sign to 0 to avoid "-0"
        if (result_mag == 4'b0000) begin
            result = 5'b00000;
        end else begin
            result = {result_sign, result_mag}; // Concatenation
        end

        // 4. Flags Logic
        SF = result[4];                 // Sign Flag
        ZF = (result_mag == 4'b0000);   // Zero Flag (4-input NOR)
        EF = (result_mag[0] == 1'b0);   // Even Flag (NOT LSB)
        OF = (result_mag[0] == 1'b1);   // Odd Flag (Direct LSB)
    end

endmodule