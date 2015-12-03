//Package to define a floating point number.
package fp_pkg;
parameter MB = 23;	//Number of bits in Mantissa
parameter EB = 8;	//Number of bits in Exponent
localparam N = MB+EB+1;	//Local parameter to determine total number of bits in fp

typedef struct packed{	//Structure typedef for floating point operation
	logic sign;
	logic [EB-1:0]exponent;
	logic [MB-1:0] mantissa;} fp;

function automatic is_denormal(fp in);	//Function to determine whether given floatin point number is denormalized
	if(in.exponent == '0 && in.mantissa != 0) begin $display("Input is Denormalized\n"); return (1); end
	else return (0);
endfunction

function automatic is_nan(fp in);		//Function to determine whether given floatin point number is Not a Number
	if(in.exponent == '1) begin $display("Input is Not a Number\n"); return (1); end
	else return (0);
endfunction

function automatic is_infinity(fp in);		//Function to determine whether given floatin point number is infinty
	if(in.exponent == '1 && in.mantissa == '1) begin $display("Input is Infinty\n"); return (1); end
	else return (0);
endfunction

function automatic is_zero(fp in);	//Function to determine whether given floatin point number is zero
	if(in.exponent == '0 && in.mantissa == '0) begin $display("Input is Zero\n"); return (1); end
	else return (0);
endfunction

function automatic overflow(fp in);	//Function to determine whether given floatin point number has overflowed
	if(in.exponent == '1-1'b1 && in.mantissa == '1) begin $display("Given fp has overflowed\n"); return (1); end
	else return(0);
endfunction

function automatic underflow(fp in);	//Function to determine whether given floatin point number has underflowed
	if(in.exponent == '0 && in.mantissa == '0) begin $display("Given fp has underflowed\n"); return (1); end
	else return(0);
endfunction

endpackage
