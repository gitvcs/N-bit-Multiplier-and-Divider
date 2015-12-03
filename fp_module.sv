import fp_pkg::*;
module fp_divider(input fp fp_dividend, fp_divisor,
		  output fp fp_quotient);
parameter EB = 8;			//Parameter stating the width of the exponent in floatin point
parameter MB = 23;			//Parameter stating the width of the mantissa in floatin point
localparam N = EB + MB + 1;		//Parameter stating the width of the input
localparam BIAS = 2**(EB-1)-1;	//Parameter to calculate the bias of the exponent.

bit denormalized, NaN, infinity, zero, overflow, underflow;
logic [EB-1:0] exponent_temp;
logic [MB:0] divisor_mantissa_normalized, dividend_mantissa_normalized;
logic [2*MB+2:0] quotient_temp;
logic [2*MB+2:0] divisor_mantissa_temp, dividend_mantissa_temp;
logic [2*MB+2:0] quotient_mantissa_temp, remainder_mantissa_temp;

always_comb begin:FLAG_CHECK_INPUTS
if(is_denormal(fp_dividend) == 1'b1 || is_denormal(fp_divisor) == 1'b1)	//Check whether either of the input is denormalized
	denormalized <= 1'b1;
else denormalized <= 1'b0;

if(is_zero(fp_dividend) == 1'b1 || is_zero(fp_divisor) == 1'b1)		//Check whether either of the input is zero
	zero <= 1'b1;
else zero <= 1'b0;

if(is_nan(fp_dividend) == 1'b1 || is_nan(fp_divisor) == 1'b1)		//Check whether either of the input is a NaN
	NaN <= 1'b1;
else NaN <= 1'b0;

if(is_infinity(fp_dividend) == 1'b1 || is_infinity(fp_divisor) == 1'b1)	//Check whether either of the input is infinty
	infinity <= 1'b1;
else infinity <= 1'b0;

end	//End of FLAG checks

always_comb begin		
exponent_temp <= (fp_dividend.exponent - BIAS) + (fp_divisor.exponent - BIAS) + BIAS;	//Obtaining the temporary value of the exponent before multiplication

if(!is_denormal(fp_dividend)) begin
dividend_mantissa_normalized <= {1'b1, fp_dividend.mantissa};		//Normalize the multiplicand by concatenating the hidden Jay bit
end
else begin
dividend_mantissa_normalized <= {1'b0, fp_dividend.mantissa};		//Normalize the multiplicand by concatenating the hidden Jay bit
end

if(!is_denormal(fp_divisor)) begin
divisor_mantissa_normalized <= {1'b1, fp_divisor.mantissa};		//Normalize the multiplier by concatenating the hidden Jay bit
end
else begin
divisor_mantissa_normalized <= {1'b0, fp_divisor.mantissa};		//Normalize the multiplier by concatenating the hidden Jay bit
end
end

always_comb begin
dividend_mantissa_temp <= {dividend_mantissa_normalized, {(MB+1){1'b0}}};
divisor_mantissa_temp <= {{(MB+1){1'b0}} , divisor_mantissa_normalized};
end

//Instantiate the Divider module for dividing the mantissa.
divider #(.n(2*MB+3)) fpdiv (.dividend_temp(dividend_mantissa_temp), .divisorM(divisor_mantissa_temp),
			    .quotient_1(quotient_mantissa_temp), .remainder_1(remainder_mantissa_temp));

///Rounding and Normalizing testing.
assign fp_quotient.mantissa = quotient_mantissa_temp[MB-1:0];
assign fp_quotient.exponent = exponent_temp;
assign fp_quotient.sign = fp_dividend.sign ^ fp_divisor.sign;

function automatic logic [2*MB+3:0] lzd (input logic [2*MB+3:0] in_1);

endfunction;
endmodule
