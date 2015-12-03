module booth_test;
parameter N = 4;

logic [N-1:0] a, b;
logic [2*N-1:0] prod;

booth_algorithm #(N) bam( .multiplier(a), .multiplicand(b), .product(prod));

initial begin
a = 5; b = 4;
#20 a = 5; b = 7;
#30 a = 4; b = -5;
#25 a = -5; b = -2;
end
endmodule
