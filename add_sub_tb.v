`timescale 1ns / 1ps

module add_sub_tb;

    // 1 CONNECT DUT SIGNALS
    // =======================
    
    reg  [2:0] A, B;   // inputs (sign-magnitude)
    reg        op;     // 0 = add, 1 = subtract
    wire [3:0] R;      // result
    wire       SF, ZF, EF, OF; // flags

    // Instantiate the design (Device Under Test)
    add_sub dut (
        .A(A), .B(B), .op(op),
        .R(R), .SF(SF), .ZF(ZF), .EF(EF), .OF(OF)
    );

    // =======================
    // 2 FILE HANDLING

    integer add_file, sub_file; // files to store results

    // =======================
    // 3 LOOP VARIABLES
   

    integer ia, ib;   // test values from -3 to 3
    integer res_val;  // result converted to decimal

    // =======================
    // 4 INTEGER → SIGN-MAGNITUDE
    
    // Converts a number (-3 to 3) into 3-bit format:
    // MSB = sign, lower bits = magnitude
    function [2:0] int_to_sm3;
        input integer val;
        integer a;
        begin
            a = (val < 0) ? -val : val; // absolute value
            int_to_sm3 = (val < 0) ? {1'b1, a[1:0]} : {1'b0, a[1:0]};
        end
    endfunction

    // =======================
    // 5 SIGN-MAGNITUDE → INTEGER
  
    
    // Converts result back to normal integer for printing
    function integer sm4_to_int;
        input [3:0] sm;
        integer mag;
        begin
            mag = sm[2:0];              // magnitude
            sm4_to_int = sm[3] ? -mag : mag; // apply sign
        end
    endfunction

    // =======================
    // 6 AUTO UPDATE RESULT

    
    // Whenever R changes, update decimal value
    always @(R) begin
        res_val = sm4_to_int(R);
    end

    // =======================
    // 7 MAIN TEST
    
    initial begin
        
        // Open files
        add_file = $fopen("add.txt", "w");
        sub_file = $fopen("sub.txt", "w");
        
        // Write headers
        $fdisplay(add_file, "A\t B\t    Result\t        SF\tZF\tEF\tOF");
        $fdisplay(sub_file, "A\t B\t    Result\t        SF\tZF\tEF\tOF");

        // =======================
        // TEST ADDITION
        
        op = 1'b0; // addition
        
        for (ia = -3; ia <= 3; ia = ia + 1) begin
            for (ib = -3; ib <= 3; ib = ib + 1) begin
                
                A = int_to_sm3(ia); // convert input A
                B = int_to_sm3(ib); // convert input B
                
                #10; // wait for circuit
                
                // write result to file
                $fdisplay(add_file, "%0d\t %0d\t    %-9d\t    %b\t%b\t%b\t%b",
                          ia, ib, res_val, SF, ZF, EF, OF);
            end
        end

        // =======================
        // TEST SUBTRACTION
        
        op = 1'b1; // subtraction
        
        for (ia = -3; ia <= 3; ia = ia + 1) begin
            for (ib = -3; ib <= 3; ib = ib + 1) begin
                
                A = int_to_sm3(ia);
                B = int_to_sm3(ib);
                
                #10;
                
                $fdisplay(sub_file, "%0d\t %0d\t    %-9d\t    %b\t%b\t%b\t%b",
                          ia, ib, res_val, SF, ZF, EF, OF);
            end
        end

        // Close files
        $fclose(add_file);
        $fclose(sub_file);
        
        $display("DONE: Results saved in add.txt and sub.txt");
        $stop;
    end

endmodule