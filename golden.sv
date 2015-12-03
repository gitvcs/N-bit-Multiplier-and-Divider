//Golden Models//
//Integer Multiplication//
parameter n=4;
parameter w=32;
module Golden_imult (input signed [(n-1):0]a,input signed [(n-1):0]b,output signed [((2*n)-1):0] c);
assign c=(a)*(b);
endmodule 

//Integer Division//
module Golden_iDiv (input signed [(n-1):0]dd,input signed [(n-1):0]dv,output signed [(n-1):0] quo,output signed [(n-1):0] rem);
assign rem= dd % dv;
assign quo=dd / dv;
endmodule

//Floating point multiplication//
module Golden_fpMult(input logic [(w-1):0] a,input logic[(w-1):0] b,output logic [(w-1):0] c);
shortreal im1,im2,im3;
real im4,im5,im6;
logic [31:0] im7;
logic [63:0] im8;
assign im1=$bitstoshortreal(a);
assign im2=$bitstoshortreal(b);
assign im4=$bitstoreal(a);
assign im5=$bitstoreal(b);
assign im3=(im1)*(im2);
assign im6=(im4)*(im5);
assign im7=$shortrealtobits(im3);
assign im8=$realtobits(im6);
assign c=(w>32)? im8:im7;
endmodule 

//Floating point Division//
module Golden_fpDiv (input logic [(w-1):0] dd,input logic[(w-1):0] dv,output logic[(w-1):0] dop);
shortreal im1,im2,im3;
real im4,im5,im6;
logic [31:0] im7;
logic [63:0] im8;
assign im1=$bitstoshortreal(dd);
assign im2=$bitstoshortreal(dv);
assign im4=$bitstoreal(dd);
assign im5=$bitstoreal(dv);
assign im3=(im1)/(im2);
assign im6=(im4)/(im5);
assign im7=$shortrealtobits(im3);
assign im8=$realtobits(im6);
assign dop=(w>32)? im8:im7;
endmodule 
