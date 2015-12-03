//the top module impolementation for the customizable/ Flexible integer/floating point multiplier/divider.
//
module top_module(in_1, in_2,
		  flag_mult_div, flag_int_fp,
		  clk,
		  out);

parameter EW = 8;			//Parameter stating the width of the exponent in floatin point
parameter MW = 23;			//Parameter stating the width of the mantissa in floatin point
parameter N = EW + MW + 1;		//Parameter stating the width of the input

input logic [N-1:0] in_1, in_2;		//inputs required to perform the required operations
input logic flag_mult_div,		//Flag to select multiplier or divider
	    flag_int_fp;		//Flag to switch between integer or floating point.
output logic [N-1:0] out;		//Output value of required opeation	    
input logic clk;			//Clock pulse for the required operations

logic 	int_mul_en, 			//Enable signals for integer multiplier
	int_div_en,			//Enable signals for integer divider
	fp_mult_en, 			//Enable signals for floating point multiplier
	fp_div_en;			//Enable signals for floating point divider
logic [N-1:0] 	out_im, 		//Output wire from Integer multiplier
		out_id, 		//Output wire from Integer Divider
		out_fpm, 		//Output wire from Floating point multiplier
		out_fpd;		//Output wire from Floating point divider

always_comb begin
unique case ({flag_mult_div, flag_int_fp})	

00:{int_mul_en, int_div_en, fp_mult_en, fp_div_en} <= 4'b1000;	//Case to select integer multiplier
01:{int_mul_en, int_div_en, fp_mult_en, fp_div_en} <= 4'b0010;	//Case to select floating point multiplier
10:{int_mul_en, int_div_en, fp_mult_en, fp_div_en} <= 4'b0100;	//Case to select integer divider
11:{int_mul_en, int_div_en, fp_mult_en, fp_div_en} <= 4'b0001;	//Case to select floating point divider

endcase
end

integer_multiplier #(N)  IM1(in_1, in_2, int_mul_en, out_im);
integer_divider #(N)     ID1(in_1, in_2, int_div_en, out_id);
fp_multiplier #(EW, MW) FPM (in_1, in_2, fp_mult_en, out_fpm);
fp_divider #(EW,MW)	FPD(in_1, in_2, fp_div_en, out_fpd);

assign out = (flag_mult_div == 1'b1)? (flag_int_fp?out_fpd:out_id):(flag_int_fp?out_fpm:out_im);

endmodule
