//Division Module, that is based on Division Algorithm
module divider (dividend_temp,divisorM,
		quotient_1,remainder_1);

parameter n = 32;

input logic[n-1:0] dividend_temp; 
input logic [n-1:0] divisorM; 
output logic [n-1:0] quotient_1;
output logic [n-1:0] remainder_1;

logic [n-1:0] divisorM_1;
logic [n-1:0][n-1:0] aold;		//Intermediate Variables for storing the value of Division\ 
logic [n-1:0][n-1:0] acc_t;		//During the For...Generate Loop
logic [n:0] [2*n-1:0] cpr_t;		//This is the concatenated register, that is generated from concatenation of the \
logic [n-1:0] [2*n-1:0] cpr_tt;		//remainder and the quotient eventually. Until then it is also temporary register for DIVISION

genvar i;

assign divisorM_1 = complement(divisorM);
assign cpr_t[0] = {'0,dividend_temp};	//Initializing the value of the concatenated register

generate 
	for( i=0; i<n; i=i+1) begin
		assign cpr_tt[i] = shifter (cpr_t[i]);
		assign aold[i] = cpr_tt[i][2*n-1:n];
		carrylookahead # (.nbits(n)) add_div (.a(cpr_tt[i][2*n-1:n]),.b(divisorM_1),
						      .sum(acc_t[i][n-1:0]),.cin(1'b0)/*, .cout(xx)*/);
		assign cpr_t[i+1] = (acc_t[i][n-1]) ? {aold[i],cpr_tt[i][n-1:0]} : {acc_t[i][n-1:0],cpr_tt[i][n-1:1],1'b1};
	end
assign remainder_1 = cpr_t[n][2*n-1:n];
assign quotient_1 = cpr_t[n][n-1:0]; 
endgenerate

//Function to left shift the value by 1
function automatic logic [2*n-1:0] shifter (input logic [2*n-1:0] shift_in);
return {{shift_in[2*n-2:0]},{1'b0}};
endfunction 

//Function to perform 2's complement on given input.
function automatic logic [n-1:0] complement (input logic [n-1:0] in);
logic [n-1:0] temp;
return ((in ^ '1) + 1'b1);
endfunction;

endmodule
