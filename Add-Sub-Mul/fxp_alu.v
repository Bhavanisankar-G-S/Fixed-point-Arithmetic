// W - Width of the fixed-point number
// FRAC - No of fractional bits
module align_frac #(
    parameter W_IN = 17,
    parameter W_OUT = 19,
    parameter FRAC_IN = 14,
    parameter FRAC_OUT = 14
) (
    input  signed [W_IN-1:0] in,
    output signed [W_OUT-1:0] out
);

wire signed [W_OUT-1:0] temp ;
assign temp = in ;

parameter SHIFT = FRAC_OUT - FRAC_IN ;
assign out = (SHIFT > 0) ? (temp << SHIFT) : ((SHIFT) ? (temp >>> (-SHIFT)) : temp) ;

endmodule

// Module to perform fixed-point addition
module fxp_add #(
    parameter WIDTH = 17
) (
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] out
);
    
    assign out = a + b ;

endmodule

// Module to perform fixed-point subtraction
module fxp_sub #(
    parameter WIDTH = 17
) (
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] out
);
    
    assign out = a - b ;

endmodule

// Module to perform fixed-point multiplication
module fxp_mul #(
    parameter WIDTH = 17
) (
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output signed [2*WIDTH-1:0] out
);

   assign out = a * b ;

endmodule

module fxp_alu #(
    parameter Q_IN1 = 3,
    parameter Q_IN2 = 5,
    parameter FRAC_IN1 = 14,
    parameter FRAC_IN2 = 12,
    parameter WIDTH = 19
) (
    input  signed [Q_IN1+FRAC_IN1-1:0] op1,
    input  signed [Q_IN2+FRAC_IN2-1:0] op2,
    output signed [WIDTH-1:0] op_add,
    output signed [WIDTH-1:0] op_sub,
    output signed [2*WIDTH-1:0] op_mul,
    output signed [Q_MAX+FRAC_MAX-1:0] mul_eff
);
    
    parameter Q_MAX = ( Q_IN1 > Q_IN2 ) ? Q_IN1 : Q_IN2 ;
    parameter FRAC_MAX = ( FRAC_IN1 > FRAC_IN2 ) ? FRAC_IN1 : FRAC_IN2 ;
    parameter W_ALIGNED = Q_MAX + FRAC_MAX ;
    parameter W_IN = Q_IN1 + FRAC_IN1 ;

    wire signed [W_ALIGNED-1:0] op1_aligned, op2_aligned ;

    align_frac #(W_IN, W_ALIGNED, FRAC_IN1, FRAC_MAX) OP1(op1, op1_aligned) ;
    align_frac #(W_IN, W_ALIGNED, FRAC_IN2, FRAC_MAX) OP2(op2, op2_aligned) ;

    // fxp_add #(W_ALIGNED) addition(op1_aligned, op2_aligned, op_add) ;
    // fxp_sub #(W_ALIGNED) subtraction(op1_aligned, op2_aligned, op_sub) ;
    // fxp_mul #(W_ALIGNED) multiplication(op1_aligned, op2_aligned, op_mul) ;
    
    adder_subtractor #(W_ALIGNED) adder(op1_aligned, op2_aligned, 1'b0, 1'b0, op_add) ;
    adder_subtractor #(W_ALIGNED) subtractor(op1_aligned, op2_aligned, 1'b1, 1'b1, op_sub) ;
    multiplier       #(W_ALIGNED) multiply(op1_aligned, op2_aligned, op_mul) ;
    assign mul_eff = op_mul >>> FRAC_MAX ;

endmodule

module adder_subtractor #(
    parameter WIDTH = 17
)(
    input signed [WIDTH-1:0] a,
    input signed [WIDTH-1:0] b,
    input cin,
    input ctrl,
    output reg signed [WIDTH-1:0] sum
    // output cout
) ;

    wire signed [WIDTH-1:0] b_transformed = b ^ {WIDTH{ctrl}} ;
    reg  signed [WIDTH-1:0] carry ;
    integer i ;
    always @(*) begin
        sum[0] = a[0] ^ b_transformed[0] ^ cin ;
        carry[0] = ( a[0] & b_transformed[0] ) | ( b_transformed[0] & cin ) | ( a[0] & cin ) ;
        
        for ( i = 1 ; i < WIDTH ; i += 1 ) begin
            sum[i] = a[i] ^ b_transformed[i] ^ carry[i-1] ;
            carry[i] = ( a[i] & b_transformed[i] ) | ( b_transformed[i] & carry[i-1] ) | ( a[i] & carry[i-1] ) ;
        end
    end
    
    // assign cout = carry[WIDTH-1] ;
endmodule ;

module multiplier #(
    parameter WIDTH = 17
)(
    input signed [WIDTH-1:0] a,
    input signed [WIDTH-1:0] b,
    output reg signed [2*WIDTH-1:0] out
) ;

    reg signed [WIDTH-1:0] a_temp ;
    reg signed [WIDTH-1:0] b_temp ;
    reg sign ;
    reg signed [WIDTH:0] q ;
    integer i ;
    always @(*) begin
    	
    	a_temp = (a[WIDTH-1]) ? -a : a ;
    	b_temp = (b[WIDTH-1]) ? -b : b ;
    	sign = a[WIDTH-1] ^ b[WIDTH-1] ;
    	
        q = 0 ;
        for ( i = 0 ; i < WIDTH ; i += 1 ) begin
            q = (a_temp[0]) ? (q + {1'b0, b_temp}) : q ;
            {q, a_temp} = {1'b0, q, a_temp[WIDTH-1:1]} ;
        end
        out = (sign) ? -{q[WIDTH-1:0], a_temp} : {q[WIDTH-1:0], a_temp};
    end

endmodule ;
