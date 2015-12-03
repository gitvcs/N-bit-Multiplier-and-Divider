module booth_algorithm( multiplier, multiplicand,
						product);
parameter N = 32;	//Parameter for width of the multiplier

input logic [N-1:0] multiplier, multiplicand;
output logic [2*N-1:0] product;

logic [2*N:0] multiplicandN, complementN;
logic [N:0][1:0] booth_case;			//the select wires for for...generate loop
logic [N:0][2*N:0] pr_temp;			//Product registry temporaries for for...generate loop 

assign multiplicandN = {multiplicand[N-1:0],{(N+1){1'b0}}};	//Generate a temporary registry to hold the multiplier
assign complementN = complement(multiplicand);			//Temporary register to hold complement value of multiplier
assign pr_temp[0] = {{N{0}},multiplier,1'b0};			//Initial assignment of product register before the loop starts
genvar i;

generate
	for(i = 0; i < N ; i=i+1)begin
	assign booth_case[i] = pr_temp[i][1:0];
	booth_multiplier #(N) bm1 (.in_a(pr_temp[i]), .in_b(multiplicandN), .in_c(complementN), .out(pr_temp[i+1]), .choice(booth_case[i]));
	end
	assign product = pr_temp[N][2*N:1];
endgenerate

//Function implementation to calculate the value of a complement of a given input.
function automatic logic [2*N:0]complement([N-1:0]in_num);
return({((in_num ^ '1) + 1'b1),{(N+1){1'b0}}});
endfunction

endmodule 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module booth_multiplier (in_a, in_b, in_c, out, choice);
parameter N = 4;

input logic [2*N:0] in_a, in_b, in_c;
input logic [1:0] choice;
output logic [2*N:0] out;

logic [2*N:0] adder_in1, adder_in2, adder_sum, shifter_out;
logic x,y;		//Dummy logic values for carry lookahead adder's carry in and carry out

always_comb begin
	case(choice)

	2'b00:begin
	adder_in1 <= in_a; adder_in2 <= '0;
	out <= shifter_out; end

	2'b01:begin
	adder_in1 <= in_a; adder_in2 <= in_b;
	out <= shifter_out; end

	2'b10:begin
	adder_in1 <= in_a; adder_in2 <= in_c;
	out <= shifter_out; end

	2'b11:begin
	adder_in1 <= in_a; adder_in2 <= '0;
	out <= shifter_out; end
	
	endcase
end
assign y = 1'b0;	//Dummy value assigning to the carry look ahead adder's carry in

carrylookahead #(2*N+1) cla(.a(adder_in1), .b(adder_in2), .cin(y), .cout(x), .sum(adder_sum));

assign shifter_out = shifter(adder_sum);
//Function implementation for a one bit arithmetic left shifter
function automatic logic [2*N:0] shifter ([2*N:0]in);
return({in[2*N],in[2*N:1]});
endfunction

endmodule


 
