module division_by_reciprocation #(
    parameter FRAC_LEN = 28,
    parameter TOTAL_LEN = 32
) (
    input wire  [TOTAL_LEN-1:0] num,
    input wire  [TOTAL_LEN-1:0] den,
    output wire [TOTAL_LEN-1:0] ans_const,
    output wire [TOTAL_LEN-1:0] ans_lin,
    output wire [TOTAL_LEN-1:0] ans_quad
);

// 2 in Q(4,28) format
localparam [TOTAL_LEN-1:0] TWO_Q4_28 = 32'd536870912;

// 4(root3-1) in Q(4,28) format
localparam [TOTAL_LEN-1:0] CONST_C = 32'd786033569 ;

// 48/17 and 32/17 in Q(4,28) format
localparam [TOTAL_LEN-1:0] LIN_C = 32'd757935405 ; 
localparam [TOTAL_LEN-1:0] LIN_B = 32'd505290270 ;

// 256/99, 576/99, and 420/99 in Q(4,28) format
localparam [TOTAL_LEN-1:0] QUAD_A = 32'd694141662  ; 
localparam [TOTAL_LEN-1:0] QUAD_B = 32'd1561818740 ; 
localparam [TOTAL_LEN-1:0] QUAD_C = 32'd1138821578 ;

function [TOTAL_LEN-1:0] mult_q4_28;
    input [TOTAL_LEN-1:0] a;
    input [TOTAL_LEN-1:0] b;
    reg   [2*TOTAL_LEN-1:0] temp;
    begin
        temp = a * b ;
        mult_q4_28 = temp >> FRAC_LEN ; 
    end
endfunction

reg [4:0] msb_pos;
integer i;

always @(*) begin
    msb_pos = 5'd0;
    for (i = 0; i < TOTAL_LEN; i = i + 1) begin
        if (den[i] == 1'b1) begin
            msb_pos = i[4:0];
        end
    end
end

wire signed [5:0] shift_amount;
assign shift_amount = 6'd27 - {1'b0, msb_pos};

wire [TOTAL_LEN-1:0] norm_num;
wire [TOTAL_LEN-1:0] norm_den;

assign norm_num = (shift_amount >= 0) ? (num << shift_amount) : (num >> -shift_amount);
assign norm_den = (shift_amount >= 0) ? (den << shift_amount) : (den >> -shift_amount);

// Linear constrained guess
wire [TOTAL_LEN-1:0] init_guess_c, iter1_c, iter2_c, iter3_c;

assign init_guess_c = CONST_C - (norm_den << 1); 
assign iter1_c = mult_q4_28(init_guess_c, (TWO_Q4_28 - mult_q4_28(norm_den, init_guess_c)));
assign iter2_c = mult_q4_28(iter1_c,      (TWO_Q4_28 - mult_q4_28(norm_den, iter1_c)));
assign iter3_c = mult_q4_28(iter2_c,      (TWO_Q4_28 - mult_q4_28(norm_den, iter2_c)));
assign ans_const = mult_q4_28(iter3_c, norm_num);

// Linear unconstrained guess
wire [TOTAL_LEN-1:0] init_guess_l, iter1_l, iter2_l, iter3_l;

assign init_guess_l = LIN_C - mult_q4_28(LIN_B, norm_den);
assign iter1_l = mult_q4_28(init_guess_l, (TWO_Q4_28 - mult_q4_28(norm_den, init_guess_l)));
assign iter2_l = mult_q4_28(iter1_l,      (TWO_Q4_28 - mult_q4_28(norm_den, iter1_l)));
assign iter3_l = mult_q4_28(iter2_l,      (TWO_Q4_28 - mult_q4_28(norm_den, iter2_l)));
assign ans_lin = mult_q4_28(iter3_l, norm_num);

// Quadratic guess
wire [TOTAL_LEN-1:0] init_guess_q, iter1_q, iter2_q, iter3_q;
wire [TOTAL_LEN-1:0] den_sq;

assign den_sq = mult_q4_28(norm_den, norm_den);
assign init_guess_q = (mult_q4_28(QUAD_A, den_sq) + QUAD_C) - mult_q4_28(QUAD_B, norm_den) ;

assign iter1_q = mult_q4_28(init_guess_q, (TWO_Q4_28 - mult_q4_28(norm_den, init_guess_q)));
assign iter2_q = mult_q4_28(iter1_q,      (TWO_Q4_28 - mult_q4_28(norm_den, iter1_q)));
assign iter3_q = mult_q4_28(iter2_q,      (TWO_Q4_28 - mult_q4_28(norm_den, iter2_q)));
assign ans_quad = mult_q4_28(iter3_q, norm_num);

endmodule