//`define DEBUG 0
import fp_pkg::*;
module fp_multiplier(input fp fp_multiplicand, fp_multiplier, 
		     output fp fp_product);
//parameter MB = 23;	//Number of bits in Mantissa
//parameter EB = 8;	//Number of bits in Exponent
//localparam N = MB+EB+1;	//Local parameter to determine total number of bits in fp
localparam BIAS = 2**(EB-1)-1;

bit denormalized_in, NaN_in, infinity_in, zero_in;

fp temp_product;

logic [EB-1:0] exponent_temp, exp_temp_normal;
logic [(MB+1):0] multiplier_mantissa_normalized, multiplicand_mantissa_normalized;
logic [2*(MB+1)+1:0] product_temp;
logic [EB-1:0] exp_inc_md, exp_inc_mr, exp_renorm, exp_temp_out, exponent_p;
logic [MB-1:0] prod_temp_renorm, prod_final, product_p;
logic [2:0] grs;
logic [2:0] round_bits;
logic exp_inc_normal;

always_comb begin:FLAG_CHECK_INPUTS
if(is_denormal(fp_multiplicand) == 1'b1 || is_denormal(fp_multiplier) == 1'b1)	//Check whether either of the input is denormalized
	denormalized_in <= 1'b1;
else denormalized_in <= 1'b0;

if(is_zero(fp_multiplicand) == 1'b1 || is_zero(fp_multiplier) == 1'b1)		//Check whether either of the input is zero
	zero_in <= 1'b1;
else zero_in <= 1'b0;

if(is_nan(fp_multiplicand) == 1'b1 || is_nan(fp_multiplier) == 1'b1)		//Check whether either of the input is a NaN
	NaN_in <= 1'b1;
else NaN_in <= 1'b0;

if(is_infinity(fp_multiplicand) == 1'b1 || is_infinity(fp_multiplier) == 1'b1)	//Check whether either of the input is infinity
	infinity_in <= 1'b1;
else infinity_in <= 1'b0;

end	//End of FLAG checks

always_comb begin

if (!denormalized_in) begin
	normalizer(fp_multiplicand.mantissa,multiplicand_mantissa_normalized);		//Normalize the multiplicand by concatenating the hidden Jay bit
	normalizer(fp_multiplier.mantissa,multiplier_mantissa_normalized);		//Normalize the multiplier by concatenating the hidden Jay bit
	exponent_temp <= (fp_multiplicand.exponent - BIAS) + (fp_multiplier.exponent - BIAS) + BIAS;	//Obtaining the temporary value of the exponent before multiplication
	`ifdef DEBUG
	$display("Normalization - Normalized");
	`endif
end
else begin
	if(is_denormal(fp_multiplicand) && (!(is_denormal(fp_multiplier)))) begin
		denormalizer(fp_multiplicand.mantissa,exp_inc_md,multiplicand_mantissa_normalized);	//Normalize the multiplicand by concatenating the hidden Jay bit
		normalizer(fp_multiplier.mantissa,multiplier_mantissa_normalized);			//Normalize the multiplier by concatenating the hidden Jay bit
		exponent_temp <= (fp_multiplier.exponent - BIAS);							//Obtaining the temporary value of the exponent before multiplication
		exp_inc_mr = '0;
		`ifdef DEBUG
		$display("Normalization - Multiplicand denormalized");
		`endif

	end
	else if(is_denormal(fp_multiplier) && (!(is_denormal(fp_multiplicand)))) begin
		denormalizer(fp_multiplier.mantissa,exp_inc_mr,multiplier_mantissa_normalized);		//Normalize the multiplier by concatenating the hidden Jay bit
		normalizer(fp_multiplicand.mantissa,multiplicand_mantissa_normalized);			//Normalize the multiplicand by concatenating the hidden Jay bit
		exponent_temp <= (fp_multiplicand.exponent - BIAS);	//Obtaining the temporary value of the exponent before multiplication
		exp_inc_md = '0;
		`ifdef DEBUG
		$display("Normalization - Multiplier denormalized");
	`	endif

	end
	else begin
		denormalizer(fp_multiplier.mantissa,exp_inc_mr,multiplier_mantissa_normalized);		//Normalize the multiplier by concatenating the hidden Jay bit
		denormalizer(fp_multiplicand.mantissa,exp_inc_md, multiplicand_mantissa_normalized);	//Normalize the multiplicand by concatenating the hidden Jay bit
		exponent_temp <= '0;
		`ifdef DEBUG
		$display("Normalization - Both denormalized");
		`endif

	end
end
end

booth_algorithm #(MB+2)								//Instanitaion of Booth's multiplier
		IM(.multiplier(multiplier_mantissa_normalized),
		   .multiplicand(multiplicand_mantissa_normalized),
		   .product(product_temp));
always_comb begin
if (NaN_in || infinity_in) begin
	prod_final = '0;
	exp_temp_normal = '1;
	`ifdef DEBUG
	$display("Either of the operands is zero, output becomes zero");
	`endif
end
else if(zero_in) begin
	prod_final = '0;
	exp_temp_normal = '1;
	`ifdef DEBUG
	$display("Either of the operands is zero, output becomes zero");
	`endif
end
else begin
if(!denormalized_in) begin
	//renormalize the normalized numbers.
	 renormalizer_normal(product_temp, prod_temp_renorm, grs, exp_inc_normal);
	 ieee_rndg(prod_temp_renorm, grs, round_bits, fp_product.sign, prod_final);
	 exp_temp_normal <= exponent_temp + exp_inc_normal;
	`ifdef DEBUG
	$display("Normalization - Renormal Normal");
	`endif

end
else begin
	//Renormalize the denormalized numbers.
	renormalize_denorm(product_temp, exp_inc_mr, exp_inc_md, exponent_temp, 
					   prod_temp_renorm, exp_inc_normal, grs, exp_temp_out);
	ieee_rndg(prod_temp_renorm, grs, round_bits, fp_product.sign, prod_final);
	if(!exp_temp_out) exp_temp_normal <= '0;
	else exp_temp_normal <= exp_temp_out - (BIAS - 1) + exp_inc_normal + BIAS;
	`ifdef DEBUG
	$display("Normalization - Renormal denormal");
	`endif

end
end
end

always_comb begin
temp_product.sign = 1'b0;
temp_product.mantissa = prod_final;
temp_product.exponent = exp_temp_normal;

if(is_nan(temp_product) || is_infinity(temp_product)) begin
	product_p <= '0;
	exponent_p <= '1;
end
else if(is_zero(temp_product))begin
	product_p <= '0;
	exponent_p <= '0;	
end
else if(overflow(temp_product)) begin
	product_p <= '1;
	exponent_p <= '1;
end
else if(underflow(temp_product)) begin
	product_p <= '0;
	exponent_p <= '0;
end
else begin
	product_p <= prod_final;
	exponent_p <= exp_temp_normal;
end
end

assign fp_product.mantissa = product_p;//prod_final;//product_temp[2*MB+1] ? product_temp[2*MB -: MB] : product_temp[2*MB-1 -: MB];
assign fp_product.sign = fp_multiplicand.sign ^ fp_multiplier.sign;
assign fp_product.exponent = exponent_p;//exp_temp_normal;//product_temp[2*MB+1] ? exponent_temp + 1'b1 : exponent_temp;

task automatic normalizer (input logic[MB-1:0] in_normal, output logic[MB+1:0] out_normal);
out_normal = {2'b01, in_normal};
endtask;

task automatic denormalizer (input logic [MB-1:0] in_denormal, output logic [EB-1:0] exp_vary, output logic [MB:0] out_denormal);
logic [MB:0][MB-1:0] temp_in;
int t;
temp_in[0][MB-1:0] = '0;
temp_in[0][MB-1] = 1'b1;
begin:DENORMAL
for ( t=0; t <MB; t++) begin 
	if((in_denormal & temp_in[t]) == temp_in[t]) begin
	exp_vary = t;
	disable DENORMAL;
	end

	else begin
 	temp_in[t+1] = temp_in[t] >> 1;
	end
`ifdef DEBUG
$display("Denormalizer Task %d %x %x",t, temp_in[t], in_denormal);
`endif
end
end
out_denormal = in_denormal << exp_vary;
endtask;

task automatic renormalize_denorm (input logic [2*(MB+1)+1:0]in_product, input bit[EB-1:0] exp_vary_mr, exp_vary_md,
				   input bit [EB-1:0]exponent_temp, output logic [MB-1:0] prod_mantissa,
				   output logic exp_inc_normal , output logic[2:0] grs, output logic [EB-1:0] exp_temp_out);


logic [MB-1:0] prod_temp, prod_temp1;
logic [EB-1:0] exp_temp, if_exp;

if(in_product[2*(MB)] == 1'b1) begin
	`ifdef DEBUG
	$display("Denormal if 1");
	`endif
	exp_inc_normal = 1'b1;
	prod_temp = in_product[2*MB -: MB];
	if(in_product[(((2*MB)-(MB-1))-3):0] > 1)
	grs[0] = 1'b1;
	else grs[0] = 1'b0;
	grs[2:1] = in_product[(((2*MB)-(MB-1))-1):(((2*MB)-(MB-1))-2)];
end
else begin
	`ifdef DEBUG
	$display("Denormal else 1");
	`endif
	exp_inc_normal = 1'b0;
	prod_temp = in_product[2*MB-1 -: MB];
	if(in_product[(((2*MB)-(MB-1))-3):0] > 1)
	grs[0] = 1'b1;
	else grs[0] = 1'b0;
	grs[2:1] = in_product[(((2*MB)-(MB-1))-1):(((2*MB)-(MB-1))-2)];
end
	exp_temp = exp_vary_mr + exp_vary_md;
	prod_temp1 = prod_temp >> exp_temp; 
	if_exp = exponent_temp - exp_temp;
	`ifdef DEBUG
	$write("exp_temp = %x, prod_temp1 = %x, prod_temp = %x\n", exp_temp, prod_temp1, prod_temp);
	`endif
if(if_exp[EB-1]) begin
	`ifdef DEBUG
	$display("denormal if 2");
	`endif
	exp_temp_out = 0;
	prod_mantissa = prod_temp1 << exponent_temp;
end
else begin
	`ifdef DEBUG
	$display("denormal else 2");
	`endif
	prod_mantissa = prod_temp1 << exp_temp;
	exp_temp_out = exponent_temp - exp_temp;
end

endtask;

task automatic renormalizer_normal(input logic [((2*MB)+1):0] imr1,
				   output logic[(MB-1):0] imr2,output logic [2:0] imgrs,
				   output logic exp_inc_normal );
automatic logic [(MB-1):0] im1;
begin
unique if (imr1[((2*MB)+1)]== 1'b1)
begin
exp_inc_normal = 1'b1;
im1=imr1[(2*MB):((2*MB)-(MB-1))];			//For single precision 46 to 24//
	if (imr1[(((2*MB)-(MB-1))-3):0]>1) 
	imgrs[0]=1'b1;
	else imgrs[0] = 1'b0;
	imgrs[2:1]=imr1[(((2*MB)-(MB-1	))-1):(((2*MB)-(MB-1))-2)];
end
else begin
exp_inc_normal = 1'b0;	
im1=imr1[((2*MB)-1):(((2*MB)-1)-(MB-1))];		//For single precision 45 to 23//
	if (imr1[((((2*MB)-1)-(MB-1))-3):0]>1) 
	imgrs[0]=1'b1;
	else 
	imgrs[0] = 1'b0;
	imgrs[2:1]=imr1[((((2*MB)-1)-(MB-1))-1):(((2*MB)-(MB-1))-2)];
	
end
end 
`ifdef DEBUG
$display("renormal normal, im1 = %x", im1);
`endif
imr2 = im1;
endtask;

//Task for Rounding//
task automatic ieee_rndg (input logic[(MB-1):0] imr2,input logic [2:0] grs,input bit [2:0] frc_rnd,input logic sign,
			  output logic [(MB-1):0] rnd_op);
automatic logic [(MB-1):0] im2;
begin
im2=imr2+0;
if(frc_rnd[2] == 1'b0) begin
//Infinite Precision Rounding with GRS
unique if (grs<=3) //When 0xx i.e., <1/2 ULP //
	im2=im2+0; // Round Down //
else if (grs>4) //When 1xx i.e., >1/2 ULP //
	im2++;//Round Up//
else if (grs==4) //When 100i.e., =1/2 ULP //
	//Round even//
	begin
	if (im2[(MB-1)]==1'b1)
	im2++; // >= 0.5:up//
	else 
	im2=im2+0; // < 0.5:down //
end
end
else begin
//Force Rounding with input port values //
//For Positive sign//
unique if ((frc_rnd==2'b00) && (sign==1'b0))
	im2=im2+0;
else if ((frc_rnd==2'b01) && (sign==1'b0))
	im2=im2+0;
else if ((frc_rnd==2'b10) && (sign==1'b0))
	im2++;
else if ((frc_rnd==2'b11) && (sign==1'b0))
	//round even// 
	begin
	if (im2[(MB-1)]==1'b1)
	im2++; // >= 0.5:up//
	else 
	im2=im2+0; // < 0.5:down //
end
//For Negative sign//
unique if ((frc_rnd==2'b00) && (sign==1'b1))
	im2++;
else if ((frc_rnd==2'b01) && (sign==1'b1))
	im2=im2+0;
else if ((frc_rnd==2'b10) && (sign==1'b1))
	im2++;
else if ((frc_rnd==2'b11) && (sign==1'b1))
	//round even//
	begin
	if (im2[(MB-1)]==1'b1)
	im2++; // >= 0.5:up//
	else 
	im2=im2+0; // < 0.5:down //
end
end
rnd_op=im2+0;
end
endtask 

endmodule 

module fpm_tb;

logic [31:0] a,b,out;
fp_multiplier fpm (a,b,out);
initial begin
#5 a = 32'h00005555; b = 32'h40a33333;	//out == 0001b330
#10 a = 32'h3000ffff ; b = 32'h7f7fffff;//out == 7000fffe;
#15 a = 32'h2EBEF4DA ; b = 32'h17EDDEBD;//out == 07316ed3;
#20 a = 32'hAEBAD45A ; b = 32'h576DDEBD;//out == c6ad9925;
#25 a = 32'hBEBA5442 ; b = 32'h5F6CDABD;//out == deac64e2;
#30 a = 32'h0000B4CA; b = 32'h00001EB5;//out == underflow;
#20 a = 32'h00441EB5; b = 32'h0094B4CA;//out == underflow;
#20 a = 32'h006D5EBD; b = 32'h029690DA;//out == underflow;
end
endmodule
