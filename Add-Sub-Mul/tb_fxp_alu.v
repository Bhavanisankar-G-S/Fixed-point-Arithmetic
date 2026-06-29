`timescale 1ns/1ps

module tb_fxp_alu ;

    parameter N = 240 ;
    parameter Q1 = 3, Q2 = 5 ;
    parameter FRAC1 = 14, FRAC2 = 12 ;
    parameter WIDTH = Q1 + FRAC1 ;

    parameter Q_MAX = (Q1 > Q2) ? Q1 : Q2 ;
    parameter FRAC_MAX = (FRAC1 > FRAC2) ? FRAC1 : FRAC2 ;
    parameter WIDTH_ALIGNED = Q_MAX + FRAC_MAX ;
    

    integer i ;
    integer f_add, f_sub, f_mul, f_mul_eff ;

    reg signed [WIDTH-1:0] op1_mem [0:N-1] ;
    reg signed [WIDTH-1:0] op2_mem [0:N-1] ;
    reg signed [WIDTH-1:0] op1, op2 ;

    wire signed [WIDTH_ALIGNED-1:0]   op_add ;
    wire signed [WIDTH_ALIGNED-1:0]   op_sub ;
    wire signed [2*WIDTH_ALIGNED-1:0] op_mul ;
    wire signed [Q_MAX+FRAC_MAX-1:0] mul_eff ;

    fxp_alu #(Q1, Q2, FRAC1, FRAC2, WIDTH_ALIGNED) uut(op1, op2, op_add, op_sub, op_mul, mul_eff) ;

    initial begin
        $readmemb("files/op1_bin.txt", op1_mem) ;
        $readmemb("files/op2_bin.txt", op2_mem) ;

        f_add = $fopen("files/add_outputs.txt", "w") ;
        f_sub = $fopen("files/sub_outputs.txt", "w") ;
        f_mul = $fopen("files/mul_outputs.txt", "w") ;
        f_mul_eff = $fopen("files/mul_eff_outputs.txt", "w") ;

        for ( i = 0 ; i < N ; i += 1 ) begin
            op1 = op1_mem[i] ;
            op2 = op2_mem[i] ; # 1 ;

            $fwrite(f_add, "%d\n", op_add) ;
            $fwrite(f_sub, "%d\n", op_sub) ;
            $fwrite(f_mul, "%d\n", op_mul) ;
            $fwrite(f_mul_eff, "%d\n", mul_eff) ;
        end

        $fclose(f_add) ;
        $fclose(f_sub) ;
        $fclose(f_mul) ;
        $fclose(f_mul_eff) ;
        $finish ;

    end


endmodule
