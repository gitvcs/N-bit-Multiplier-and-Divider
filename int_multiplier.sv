module integer_multiplier #(N = 32) (input [N-1:0] int_multiplicand, int_multiplier, 
				output [N-1:0] int_product);
//Module to implement integer multiplication.

logic [2*N-1:0] product_temp;		//Temporary product store
logic [N-2:0] product_wire;
bit flag_overflow, flag_zero, flag_negative;
booth_algorithm #(N) int_mult (	.multiplier(int_multiplier), 		//Instantiating the Booth multiplier algorithm 
				.multiplicand(int_multiplicand),	//To perform Integer multiplication
				.product(product_temp));

assign flag_zero = check_zero(int_multiplicand) | check_zero(int_multiplier);					//Flag to check whether either of the inputs ia a zero
assign flag_negative = int_multiplicand[N-1] ^ int_multiplier[N-1];						//Flag to set the sign of the product.
assign flag_overflow = ((product_temp[2*N-1 -: N+1] == '0) || (product_temp[2*N-1 -: N+1] == '1))? 1'b0 : 1'b1;	//Flag to indicate the overflow of the product.

always_comb begin
	if(flag_zero) begin
	product_wire[N-2:0] <= '0;
	end
	else begin
	product_wire [N-2:0] <= product_temp[N-2:0];
	end
end
assign int_product[N-2:0] = product_wire;
assign int_product[N-1] = flag_negative ? 1'b1 : 1'b0;

function automatic bit check_zero(input logic [N-1:0] in_1);
return ((in_1 == '0) ? 1'b1 : 1'b0);
endfunction;

endmodule
