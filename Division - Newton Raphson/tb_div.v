`timescale 1ns / 1ps

module tb_division_by_reciprocation;

    reg  [31:0] N, D;
    wire [31:0] resc, resl, resq;

    division_by_reciprocation uut (N, D, resc, resl, resq);

    // Variables for analysis
    real res1, res2, res3;
    real expected_val;
    real err1, err2, err3;
    
    // Corrected scale factor for 2^28
    real scale_factor = 268435456.0; 

    initial begin

        run_test(15, 23);
        run_test(10, 79);
        run_test(142, 51);
        run_test(17, 64);
        run_test(100, 127);
        run_test(1, 255);
        run_test(1, 10239) ;

        $finish;
    end

    task run_test;
        input [31:0] num;
        input [31:0] den;
        begin
            N = num ;
            D = den ;
            #10; // Wait for combinational logic to settle

            res1    = $itor(resc) / scale_factor;
            expected_val = $itor(num) / $itor(den);
            err1    = res1 - expected_val;
            if (err1 < 0) err1 = -err1;

            res2    = $itor(resl) / scale_factor;
            err2    = res2 - expected_val;
            if (err2 < 0) err2 = -err2;

            res3    = $itor(resq) / scale_factor;
            err3    = res3 - expected_val;
            if (err3 < 0) err3 = -err3;

            $display("Test: %0d / %0d", num, den);
            $display("  Expected : %1.8f", expected_val);
            $display("  Res Const: %1.8f | Error: %e", res1, err1);
            $display("  Res Lin  : %1.8f | Error: %e", res2, err2);
            $display("  Res Quad : %1.8f | Error: %e", res3, err3);
            $display("---------------------------------------------------------------");
        end
    endtask

endmodule