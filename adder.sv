module fulladder (input a, input b, input cin,output sum,output cout);

assign sum = a ^ b ^ cin;
assign cout = ((a & b) | (b & cin) | (cin & a));

endmodule

module carrylookahead(a,b,cin,cout,sum);
parameter nbits = 6;
input logic [nbits-1:0] a,b;
input logic cin;
output logic cout;
output logic [nbits-1:0] sum;

wire logic [nbits:0] cgen;
wire logic [nbits-1:0] g,p;

wire logic [nbits-1:0] sumwir;
wire logic [nbits-1:0] coutwir;

assign cgen[0] = cin;
genvar i;
generate 
for ( i = 0;i < nbits ;i++) begin 
assign g[i] = a[i] & b[i];
assign p[i] = a[i] ^ b[i];
assign cgen[i+1] = g[i] | (p[i] & cgen[i]);
fulladder i0 (a[i], b[i], cgen[i], sumwir[i], coutwir[i]);

end 
assign sum = sumwir;

assign cout = cgen [nbits];

endgenerate 


endmodule
