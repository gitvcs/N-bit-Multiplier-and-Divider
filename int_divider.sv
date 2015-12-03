//Module to implement the Integer Divider. With the inputs as Dividend and the outputs as Divider
module integer_divider (int_dividend, int_divisor,
			int_quotient, int_remainder);
parameter n = 32; 

input logic [n-1:0] int_dividend;
input logic [n-1:0] int_divisor;
output logic [n-1:0] int_quotient;
output logic [n-1:0] int_remainder;

//Declaration of temporary registers/ variables 
logic [n-1:0] quotient_out;
logic [n-1:0] remainder_out;

logic [n-1:0] dividend_temp;
logic [n-1:0] divisor_temp;
logic [n-1:0] remainder_wire, quotient_wire;
bit rq, rc;							//Flags to indicate whether the inputs are negative/positive
bit zero_flag, NaN_flag, underflow_flag;		//Flags to check the state of input and output values.

assign rq = int_dividend[n-1] ^ int_divisor [n-1]; 		//Set this flag if both numerator and the denominator are negative. This is used to set the sign of the quotient.
assign rc = (int_dividend[n-1] == 1) ? 1:0; 			//Set this flag if numerator is negative, This is used to set the sign of the remainder

assign zero_flag = check_zero(int_dividend);
assign NaN_flag = check_NaN(int_divisor);

assign dividend_temp = (int_dividend[n-1] ==1) ? (complement(int_dividend)) : (int_dividend);	//If the dividend is negative, complement it. Assign it to a temporary variable.
assign divisor_temp = (int_divisor[n-1] == 1) ? (complement(int_divisor)) : (int_divisor);	//If the divisor is negative, then complement it. Assign it to a temporary variable.

divider  #(.n(n)) itt0 (.dividend_temp(dividend_temp),.divisorM(divisor_temp),				//Instantiate the divider module to perform the actual division.
			.quotient_1(quotient_out),.remainder_1(remainder_out));
always_comb begin

if(zero_flag) begin
	quotient_wire <= '0;
	remainder_wire <= '0;
end
else if(NaN_flag) begin
	quotient_wire <= '1;
	remainder_wire <= '1;
end
else begin
	quotient_wire <= (rq) ? (complement(quotient_out)) : quotient_out ;		//Use the rq flag to set the sign of the quotient
	remainder_wire <= (rc) ? (complement(remainder_out)): remainder_out  ; 		//Use the rc flag to set the sign of the remainder
end
end

assign int_quotient = quotient_wire;
assign int_remainder = remainder_wire;
assign underflow_flag = check_underflow(quotient_wire);

//Function to perform 2's complement on given input.
function automatic logic [n-1:0] complement (input logic [n-1:0] in);
logic [n-1:0] temp;
return ((in ^ '1) + 1'b1);
endfunction;

function automatic bit check_zero(input logic [n-1:0] in_1);
return ((in_1 == '0) ? 1'b1 : 1'b0)/*flag_temp*/;
endfunction;

function automatic bit check_NaN(input logic [n-1:0] in_1);
return ((in_1 == '0) ? 1'b1 : 1'b0)/*flag_temp1*/;
endfunction;

function automatic bit check_underflow(input logic [n-1:0] in_1);
return ((in_1 == '0) ? 1'b1 : 1'b0)/*flag_temp1*/;
endfunction;
endmodule
