
module FFT(
input clk,
input rst_n,
input in_valid,
input signed [11:0] din_r,  // real number
input signed [11:0] din_i,  // imag number
output out_valid,
output signed [15:0] dout_r, // real number
output signed [15:0] dout_i  // imag number
); 

reg [5:0]	cnt1_w, cnt1_r;
reg [4:0]	cnt2_w, cnt2_r;
reg [3:0]	cnt3_w, cnt3_r;
reg [2:0]	cnt4_w, cnt4_r;
reg	[1:0]	cnt5_w, cnt5_r;

reg [5:0] cntall_w, cntall_r;	
reg state_w, state_r;

reg signed [15:0]  	real_buf_w	[0:31];
reg signed [15:0]  	real_buf_r  [0:31];
reg	signed [15:0]	imag_buf_w	[0:31];
reg signed [15:0]  	imag_buf_r  [0:31];

reg	[3:0]	i_MUL1_twid_w, i_MUL1_twid_r, i_MUL2_twid_w, i_MUL2_twid_r, i_MUL3_twid_w, i_MUL3_twid_r, i_MUL4_twid_w, i_MUL4_twid_r, i_MUL5_twid_w, i_MUL5_twid_r;

reg out_valid_r, out_valid_w;
reg signed [15:0] dout_r_r, dout_r_w, dout_i_r, dout_i_w;

reg [5:0] tmp_hold;
reg [4:0] tmp, idx;
integer i;

// ==============================================================================================================================
reg  signed [15:0] i_PE1_r_r, i_PE1_r_w, i_PE1_i_r, i_PE1_i_w;
wire signed [15:0] i_PE1_r ,i_PE2_r, i_PE3_r, i_PE4_r, i_PE5_r, i_PE1_i, i_PE2_i, i_PE3_i, i_PE4_i, i_PE5_i;
wire signed [15:0] i_D16_r, i_D8_r, i_D4_r, i_D2_r, i_D1_r, i_D16_i, i_D8_i, i_D4_i, i_D2_i, i_D1_i;
wire signed [15:0] o_PE1_r, o_PE2_r, o_PE3_r, o_PE4_r, o_PE5_r, o_PE1_i, o_PE2_i, o_PE3_i, o_PE4_i, o_PE5_i;
wire signed [15:0] o_D16_r, o_D8_r, o_D4_r, o_D2_r, o_D1_r, o_D16_i, o_D8_i, o_D4_i, o_D2_i, o_D1_i;
wire signed [15:0] o_final_r, o_final_i;

wire 		i_PE1_sel, i_PE2_sel, i_PE3_sel, i_PE4_sel, i_PE5_sel;
wire [3:0]	i_MUL1_twid, i_MUL2_twid, i_MUL3_twid, i_MUL4_twid, i_MUL5_twid;

wire out_valid;
wire signed [15:0] dout_r, dout_i;
// ==============================================================================================================================
assign i_PE1_r = i_PE1_r_r;
assign i_PE1_i = i_PE1_i_r;

assign i_PE1_sel  = (cnt1_r > 6'd16 && cnt1_r <= 6'd32)? 1 : 0;
assign i_PE2_sel  = (cnt2_r > 5'd7  && cnt2_r <= 5'd15)? 1 : 0;
assign i_PE3_sel  = (cnt3_r > 4'd3  && cnt3_r <= 4'd7 )? 1 : 0;
assign i_PE4_sel  = (cnt4_r > 3'd1  && cnt4_r <= 3'd3 )? 1 : 0;
assign i_PE5_sel  = (cnt5_r > 2'd0  && cnt5_r <= 2'd1 )? 1 : 0;

assign i_MUL1_twid = i_MUL1_twid_r;
assign i_MUL2_twid = i_MUL2_twid_r;
assign i_MUL3_twid = i_MUL3_twid_r;
assign i_MUL4_twid = i_MUL4_twid_r;
assign i_MUL5_twid = i_MUL5_twid_r;

assign out_valid = out_valid_r;
assign dout_r = dout_r_r;
assign dout_i = dout_i_r;

parameter CAL_FFT = 1'd0;
parameter PASSOUT = 1'd1;

// ===============================================================================
Delay16 D16_r(.clk(clk),.rst_n(rst_n),.D(i_D16_r),.Q(o_D16_r));
Delay16 D16_i(.clk(clk),.rst_n(rst_n),.D(i_D16_i),.Q(o_D16_i));

PE1 PE_1(.i_sel(i_PE1_sel), .i_cnt1(cnt1_r), .i_delay_real(o_D16_r), .i_delay_imag(o_D16_i), .i_sample_real(i_PE1_r), .i_sample_imag(i_PE1_i), 
	.o_delay_real(i_D16_r), .o_delay_imag(i_D16_i), .o_mulunit_real(o_PE1_r), .o_mulunit_imag(o_PE1_i));

Multi_Unit MULTI1(.sel_twid(i_MUL1_twid), .i_real(o_PE1_r), .i_imag(o_PE1_i), .o_real(i_PE2_r), .o_imag(i_PE2_i));


Delay8 D8_r(.clk(clk),.rst_n(rst_n),.D(i_D8_r),.Q(o_D8_r));
Delay8 D8_i(.clk(clk),.rst_n(rst_n),.D(i_D8_i),.Q(o_D8_i));

PE2 PE_2(.i_sel(i_PE2_sel),.i_cnt2(cnt2_r),.i_delay_real(o_D8_r),.i_delay_imag(o_D8_i),.i_sample_real(i_PE2_r),.i_sample_imag(i_PE2_i),
	.o_delay_real(i_D8_r),.o_delay_imag(i_D8_i),.o_mulunit_real(o_PE2_r),.o_mulunit_imag(o_PE2_i));

Multi_Unit MULTI2(.sel_twid(i_MUL2_twid),.i_real(o_PE2_r),.i_imag(o_PE2_i),.o_real(i_PE3_r),.o_imag(i_PE3_i));


Delay4 D4_r(.clk(clk),.rst_n(rst_n),.D(i_D4_r),.Q(o_D4_r));
Delay4 D4_i(.clk(clk),.rst_n(rst_n),.D(i_D4_i),.Q(o_D4_i));

PE3 PE_3(.i_sel(i_PE3_sel),.i_cnt3(cnt3_r),.i_delay_real(o_D4_r),.i_delay_imag(o_D4_i),.i_sample_real(i_PE3_r),.i_sample_imag(i_PE3_i),
	.o_delay_real(i_D4_r),.o_delay_imag(i_D4_i),.o_mulunit_real(o_PE3_r),.o_mulunit_imag(o_PE3_i));

Multi_Unit MULTI3(.sel_twid(i_MUL3_twid),.i_real(o_PE3_r),.i_imag(o_PE3_i),.o_real(i_PE4_r),.o_imag(i_PE4_i));


Delay2 D2_r(.clk(clk),.rst_n(rst_n),.D(i_D2_r),.Q(o_D2_r));
Delay2 D2_i(.clk(clk),.rst_n(rst_n),.D(i_D2_i),.Q(o_D2_i));

PE4 PE_4(.i_sel(i_PE4_sel),.i_cnt4(cnt4_r),.i_delay_real(o_D2_r),.i_delay_imag(o_D2_i),.i_sample_real(i_PE4_r),.i_sample_imag(i_PE4_i),
	.o_delay_real(i_D2_r),.o_delay_imag(i_D2_i),.o_mulunit_real(o_PE4_r),.o_mulunit_imag(o_PE4_i));

Multi_Unit MULTI4(.sel_twid(i_MUL4_twid),.i_real(o_PE4_r),.i_imag(o_PE4_i),.o_real(i_PE5_r),.o_imag(i_PE5_i));


Delay1 D1_r(.clk(clk),.rst_n(rst_n),.D(i_D1_r),.Q(o_D1_r));
Delay1 D1_i(.clk(clk),.rst_n(rst_n),.D(i_D1_i),.Q(o_D1_i));

PE5 PE_5(.i_sel(i_PE5_sel),.i_cnt5(cnt5_r),.i_delay_real(o_D1_r),.i_delay_imag(o_D1_i),.i_sample_real(i_PE5_r),.i_sample_imag(i_PE5_i),
	.o_delay_real(i_D1_r),.o_delay_imag(i_D1_i),.o_mulunit_real(o_PE5_r),.o_mulunit_imag(o_PE5_i));

Multi_Unit MULTI5(.sel_twid(i_MUL5_twid),.i_real(o_PE5_r),.i_imag(o_PE5_i),.o_real(o_final_r),.o_imag(o_final_i));

// =======================================================================================================================================
// ===================== Control Unit ========================
// Combinational Logic
always @(*) begin
	// Avoiding Latches
	i_MUL1_twid_w = i_MUL1_twid_r;
	i_MUL2_twid_w = i_MUL2_twid_r;
	i_MUL3_twid_w = i_MUL3_twid_r;
	i_MUL4_twid_w = i_MUL4_twid_r;
	i_MUL5_twid_w = i_MUL5_twid_r;
	cnt1_w = cnt1_r;
	cnt2_w = cnt2_r;
	cnt3_w = cnt3_r;
	cnt4_w = cnt4_r;
	cnt5_w = cnt5_r;
	cntall_w = cntall_r;
	dout_r_w = dout_r_r;
	dout_i_w = dout_i_r;
	i_PE1_r_w = i_PE1_r_r;
	i_PE1_i_w = i_PE1_i_r;
	out_valid_w = out_valid_r;

	for(i=0; i<32; i=i+1) begin
		real_buf_w[i] = real_buf_r[i];
		imag_buf_w[i] = imag_buf_r[i];
	end

	case(state_r)
		CAL_FFT: begin
			i_PE1_r_w = (in_valid)? din_r : 0;
			i_PE1_i_w = (in_valid)? din_i : 0;

			state_w = (cntall_r == 6'd63)? PASSOUT : state_r;
			
			cntall_w = (in_valid || cntall_r > 0)? (cntall_r + 1) : cntall_r;

			cnt1_w = (in_valid || cntall_r > 0)? (cnt1_r + 1) : cnt1_r;
			cnt2_w = (cnt2_r == 5'd15)? 5'd0 : (((cnt1_r > 6'd16 && cnt2_r < 5'd15) || (!in_valid && cntall_r >= 6'd32))? (cnt2_r + 1) : cnt2_r);  
			cnt3_w = (cnt3_r == 4'd7 )? 4'd0 : (((cnt2_r > 5'd7  && cnt3_r < 4'd7 ) || (!in_valid && cntall_r >= 6'd32))? (cnt3_r + 1) : cnt3_r);
			cnt4_w = (cnt4_r == 3'd3 )? 3'd0 : (((cnt3_r > 4'd3  && cnt4_r < 3'd3 ) || (!in_valid && cntall_r >= 6'd32))? (cnt4_r + 1) : cnt4_r);
			cnt5_w = (cnt5_r == 2'd1 )? 2'd0 : (((cnt4_r > 3'd1  && cnt5_r < 2'd1 ) || (!in_valid && cntall_r >= 6'd32))? (cnt5_r + 1) : cnt5_r);

			i_MUL1_twid_w = (cnt1_r > 6'd32 && cnt1_r <= 6'd48)? (i_MUL1_twid_r + 1) : 4'd0;
			i_MUL2_twid_w = (cnt2_r < 5'd8  && cntall_r >= 6'd32 )? (i_MUL2_twid_r + 2) : 4'd0;
			i_MUL3_twid_w = (cnt3_r < 4'd4  && cntall_r >= 6'd32 )? (i_MUL3_twid_r + 4) : 4'd0;
			i_MUL4_twid_w = (cnt4_r < 3'd2  && cntall_r >= 6'd32 )? (i_MUL4_twid_r + 8) : 4'd0;
			i_MUL5_twid_w = 4'd0;

			out_valid_w = (cntall_r == 6'd32 || cntall_r == 6'd48)? 1 : 0;
			dout_r_w = o_final_r;
			dout_i_w = o_final_i;

			// Barrel Shifter
			tmp_hold = (cntall_r > 6'd32)? (cntall_r - 6'd32) : 6'd0; 
			tmp = tmp_hold[4:0];
			for(i=0; i<5; i=i+1) begin
				idx[i] = tmp[4-i];
			end
			real_buf_w[idx] = (cntall_r > 6'd32)? o_final_r : real_buf_r[idx];
			imag_buf_w[idx] = (cntall_r > 6'd32)? o_final_i : imag_buf_r[idx];
		end

		PASSOUT: begin
			state_w = state_r;
			cntall_w = cntall_r + 1;
			out_valid_w = (cntall_r <= 6'd29)? 1'b1 : 1'b0;

			tmp_hold = cntall_r + 6'd2;
			tmp = tmp_hold[4:0];
			dout_r_w = real_buf_r[tmp];
			dout_i_w = imag_buf_r[tmp];
		end
		default: begin
			state_w = state_r;
		end
	endcase
end


// Sequential Logic
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		i_PE1_r_r <= 0;
		i_PE1_i_r <= 0;
		state_r <= 0;
		
		cnt1_r <= 0;
		cnt2_r <= 0;
		cnt3_r <= 0;
		cnt4_r <= 0;
		cnt5_r <= 0;
		cntall_r <= 0;

		out_valid_r <= 0;
		dout_r_r <= 0;
		dout_i_r <= 0;

		i_MUL1_twid_r <= 0;
		i_MUL2_twid_r <= 0;
		i_MUL3_twid_r <= 0;
		i_MUL4_twid_r <= 0;
		i_MUL5_twid_r <= 0;

		for(i=0; i<32; i=i+1) begin
			real_buf_r[i] <= 0;
			imag_buf_r[i] <= 0;
		end
	end
	else begin
		i_PE1_r_r <= i_PE1_r_w;
		i_PE1_i_r <= i_PE1_i_w;
		state_r <= state_w;
		
		cnt1_r <= cnt1_w;
		cnt2_r <= cnt2_w;
		cnt3_r <= cnt3_w;
		cnt4_r <= cnt4_w;
		cnt5_r <= cnt5_w;
		cntall_r <= cntall_w;

		out_valid_r <= out_valid_w;
		dout_r_r <= dout_r_w;
		dout_i_r <= dout_i_w;
	
		i_MUL1_twid_r <= i_MUL1_twid_w;
		i_MUL2_twid_r <= i_MUL2_twid_w;
		i_MUL3_twid_r <= i_MUL3_twid_w;
		i_MUL4_twid_r <= i_MUL4_twid_w;
		i_MUL5_twid_r <= i_MUL5_twid_w;

		for(i=0; i<32; i=i+1) begin
			real_buf_r[i] <= real_buf_w[i];
			imag_buf_r[i] <= imag_buf_w[i];
		end
	end
end

endmodule

// ======================== Delay Modules ============================
module Delay1(
	input 	clk,
	input 	rst_n,
	input	signed	[15:0]	D,
	output 	signed	[15:0]	Q
);
	reg signed [15:0] Q;

	always@(posedge clk) begin
		if(!rst_n) begin
			Q <= {16{1'b0}};
		end
		else begin
			Q <= D;
		end
	end
endmodule

module Delay2(
	input 	clk, 
	input 	rst_n,
	input 	signed	[15:0] 	D,
	output 	signed 	[15:0]	Q
);
	
	wire  signed	[15:0] 	D_w;
	
	Delay1 D1_1(.clk(clk), .rst_n(rst_n), .D(D), .Q(D_w));
	Delay1 D1_2(.clk(clk), .rst_n(rst_n), .D(D_w), .Q(Q));
endmodule

module Delay4(
	input 	clk,
	input 	rst_n, 
	input 	signed 	[15:0] 	D,
	output 	signed	[15:0] 	Q
);
	
	wire signed	[15:0]	D_w;

	Delay2 D2_1(.clk(clk), .rst_n(rst_n), .D(D), .Q(D_w));
	Delay2 D2_2(.clk(clk), .rst_n(rst_n), .D(D_w), .Q(Q));
endmodule

module Delay8(
	input 	clk,
	input 	rst_n, 
	input 	signed 	[15:0] 	D,
	output 	signed	[15:0] 	Q
);
	
	wire signed	[15:0]	D_w;

	Delay4 D4_1(.clk(clk), .rst_n(rst_n), .D(D), .Q(D_w));
	Delay4 D4_2(.clk(clk), .rst_n(rst_n), .D(D_w), .Q(Q));
endmodule

module Delay16(
	input 	clk,
	input 	rst_n, 
	input 	signed 	[15:0] 	D,
	output 	signed	[15:0] 	Q
);

	wire signed	[15:0]	D_w;

	Delay8 D8_1(.clk(clk), .rst_n(rst_n), .D(D), .Q(D_w));
	Delay8 D8_2(.clk(clk), .rst_n(rst_n), .D(D_w), .Q(Q));
endmodule


// ========================== Butterfly ================================
module Bf_Unit(
	input 	signed	[15:0]	a_real,
	input	signed	[15:0]	a_imag,
	input	signed	[15:0]	b_real,
	input	signed	[15:0]	b_imag,
	output	signed	[16:0]	c_real,
	output	signed	[16:0]	c_imag,
	output	signed	[16:0]	d_real,
	output	signed	[16:0]	d_imag
);

	reg signed [16:0] c_real, c_imag, d_real, d_imag;

	always@(*) begin
		c_real = a_real + b_real;
		d_real = a_real - b_real;
		c_imag = a_imag + b_imag;
		d_imag = a_imag - b_imag;
	end	
endmodule

// ========================= Multiply Unit ==============================
module Multi_Unit(
	input	[3:0]	sel_twid,
	input	signed	[15:0]	i_real,
	input	signed	[15:0]	i_imag,
	output	signed	[15:0]	o_real,
	output	signed	[15:0]	o_imag
);
	parameter signed twid_r_1  = 8'b01111101; // 0.9808
	parameter signed twid_r_2  = 8'b01110110; // 0.9239
	parameter signed twid_r_3  = 8'b01101010; // 0.8315
	parameter signed twid_r_4  = 8'b01011010; // 0.7071
	parameter signed twid_r_5  = 8'b01000111; // 0.5556
	parameter signed twid_r_6  = 8'b00110000; // 0.3827
	parameter signed twid_r_7  = 8'b00011000; // 0.1951
	parameter signed twid_r_8  = 8'b00000000; // 0.0000
	parameter signed twid_r_9  = 8'b11100111; // -0.1951
	parameter signed twid_r_10 = 8'b11001111; // -0.3827
	parameter signed twid_r_11 = 8'b10111000; // -0.5556
	parameter signed twid_r_12 = 8'b10100101; // -0.7071
	parameter signed twid_r_13 = 8'b10010101; // -0.8315
	parameter signed twid_r_14 = 8'b10001001; // -0.9239
	parameter signed twid_r_15 = 8'b10000010; // -0.9808

	parameter signed twid_i_1  = 8'b11100111; // -0.1951
	parameter signed twid_i_2  = 8'b11001111; // -0.3827
	parameter signed twid_i_3  = 8'b10111000; // -0.5556
	parameter signed twid_i_4  = 8'b10100101; // -0.7071
	parameter signed twid_i_5  = 8'b10010101; // -0.8315
	parameter signed twid_i_6  = 8'b10001001; // -0.9239
	parameter signed twid_i_7  = 8'b10000010; // -0.9808
	parameter signed twid_i_8  = 8'b10000000; // -1.0000
	parameter signed twid_i_9  = 8'b10000010; // -0.9808
	parameter signed twid_i_10 = 8'b10001001; // -0.9239
	parameter signed twid_i_11 = 8'b10010101; // -0.8315
	parameter signed twid_i_12 = 8'b10100101; // -0.7071
	parameter signed twid_i_13 = 8'b10111000; // -0.5556
	parameter signed twid_i_14 = 8'b11001111; // -0.3827
	parameter signed twid_i_15 = 8'b11100111; // -0.1951

	reg signed [23:0] mul_buf_real; 
	reg signed [23:0] mul_buf_imag;

	wire signed [15:0] o_real, o_imag;

	assign o_real = (sel_twid == 0)? mul_buf_real[15:0] : mul_buf_real[22:7];
	assign o_imag = (sel_twid == 0)? mul_buf_imag[15:0] : mul_buf_imag[22:7];

	always@(*) begin
		case(sel_twid)
			0: begin
				mul_buf_real = i_real;
				mul_buf_imag = i_imag;
			end
			1: begin
				mul_buf_real = i_real * twid_r_1 - i_imag * twid_i_1;
				mul_buf_imag = i_real * twid_i_1 + i_imag * twid_r_1;
				
			end
			2: begin
				mul_buf_real = i_real * twid_r_2 - i_imag * twid_i_2;
				mul_buf_imag = i_real * twid_i_2 + i_imag * twid_r_2;
			end
			3: begin
				mul_buf_real = i_real * twid_r_3 - i_imag * twid_i_3;
				mul_buf_imag = i_real * twid_i_3 + i_imag * twid_r_3;
			end
			4: begin
				mul_buf_real = i_real * twid_r_4 - i_imag * twid_i_4;
				mul_buf_imag = i_real * twid_i_4 + i_imag * twid_r_4;
			end
			5: begin
				mul_buf_real = i_real * twid_r_5 - i_imag * twid_i_5;
				mul_buf_imag = i_real * twid_i_5 + i_imag * twid_r_5;
			end
			6: begin
				mul_buf_real = i_real * twid_r_6 - i_imag * twid_i_6;
				mul_buf_imag = i_real * twid_i_6 + i_imag * twid_r_6;
			end
			7: begin
				mul_buf_real = i_real * twid_r_7 - i_imag * twid_i_7;
				mul_buf_imag = i_real * twid_i_7 + i_imag * twid_r_7;
			end
			8: begin
				mul_buf_real = i_real * twid_r_8 - i_imag * twid_i_8;
				mul_buf_imag = i_real * twid_i_8 + i_imag * twid_r_8;
			end
			9: begin
				mul_buf_real = i_real * twid_r_9 - i_imag * twid_i_9;
				mul_buf_imag = i_real * twid_i_9 + i_imag * twid_r_9;
			end
			10: begin
				mul_buf_real = i_real * twid_r_10 - i_imag * twid_i_10;
				mul_buf_imag = i_real * twid_i_10 + i_imag * twid_r_10;
			end
			11: begin
				mul_buf_real = i_real * twid_r_11 - i_imag * twid_i_11;
				mul_buf_imag = i_real * twid_i_11 + i_imag * twid_r_11;
			end
			12: begin
				mul_buf_real = i_real * twid_r_12 - i_imag * twid_i_12;
				mul_buf_imag = i_real * twid_i_12 + i_imag * twid_r_12;
			end
			13: begin
				mul_buf_real = i_real * twid_r_13 - i_imag * twid_i_13;
				mul_buf_imag = i_real * twid_i_13 + i_imag * twid_r_13;
			end
			14: begin
				mul_buf_real = i_real * twid_r_14 - i_imag * twid_i_14;
				mul_buf_imag = i_real * twid_i_14 + i_imag * twid_r_14;
			end
			15: begin
				mul_buf_real = i_real * twid_r_15 - i_imag * twid_i_15;
				mul_buf_imag = i_real * twid_i_15 + i_imag * twid_r_15;
			end
			default: begin
				mul_buf_real = i_real;
				mul_buf_imag = i_imag;
			end
		endcase	
	end
endmodule

// ====================== Processing Element ========================
module PE1(
	input			i_sel,
	input 			[5:0]	i_cnt1,
	input	signed	[15:0]	i_delay_real,
	input	signed	[15:0]	i_delay_imag,
	input	signed	[15:0]	i_sample_real,
	input	signed	[15:0]	i_sample_imag,

	output	signed	[15:0]	o_delay_real,
	output	signed	[15:0]	o_delay_imag,
	output	signed	[15:0]	o_mulunit_real,
	output	signed	[15:0]	o_mulunit_imag
);

	reg signed [15:0] o_delay_real, o_delay_imag, o_mulunit_real, o_mulunit_imag;

	wire signed [16:0] o_bf_c_real, o_bf_c_imag, o_bf_d_real, o_bf_d_imag;

	Bf_Unit Butterfly_1(.a_real(i_delay_real),
						.a_imag(i_delay_imag),
						.b_real(i_sample_real),
						.b_imag(i_sample_imag),
						.c_real(o_bf_c_real),
						.c_imag(o_bf_c_imag),
						.d_real(o_bf_d_real),
						.d_imag(o_bf_d_imag));
	always@(*) begin
		case(i_sel)
			0: begin
				if(i_cnt1 > 6'd32) begin
					o_delay_real = 0;
					o_delay_imag = 0;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end 
				else begin
					o_delay_real = i_sample_real;
					o_delay_imag = i_sample_imag;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end
			end
			1: begin
				o_delay_real = o_bf_d_real[15:0];
				o_delay_imag = o_bf_d_imag[15:0];
				o_mulunit_real = o_bf_c_real[15:0];
				o_mulunit_imag = o_bf_c_imag[15:0];
			end
		endcase	
	end
endmodule

module PE2(
	input			i_sel,
	input 			[4:0]	i_cnt2,
	input	signed	[15:0]	i_delay_real,
	input	signed	[15:0]	i_delay_imag,
	input	signed	[15:0]	i_sample_real,
	input	signed	[15:0]	i_sample_imag,

	output	signed	[15:0]	o_delay_real,
	output	signed	[15:0]	o_delay_imag,
	output	signed	[15:0]	o_mulunit_real,
	output	signed	[15:0]	o_mulunit_imag
);

	reg signed [15:0] o_delay_real, o_delay_imag, o_mulunit_real, o_mulunit_imag;

	wire signed [16:0] o_bf_c_real, o_bf_c_imag, o_bf_d_real, o_bf_d_imag;
	
	Bf_Unit Butterfly_2(.a_real(i_delay_real),
						.a_imag(i_delay_imag),
						.b_real(i_sample_real),
						.b_imag(i_sample_imag),
						.c_real(o_bf_c_real),
						.c_imag(o_bf_c_imag),
						.d_real(o_bf_d_real),
						.d_imag(o_bf_d_imag));

	always@(*) begin
		case(i_sel)
			0: begin
				if(i_cnt2 > 5'd16) begin
					o_delay_real = 0;
					o_delay_imag = 0;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end 
				else begin
					o_delay_real = i_sample_real;
					o_delay_imag = i_sample_imag;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end
			end
			1: begin
				o_delay_real = o_bf_d_real[15:0];
				o_delay_imag = o_bf_d_imag[15:0];
				o_mulunit_real = o_bf_c_real[15:0];
				o_mulunit_imag = o_bf_c_imag[15:0];
			end
		endcase
	end
endmodule

module PE3(
	input			i_sel,
	input 			[3:0]	i_cnt3,
	input	signed	[15:0]	i_delay_real,
	input	signed	[15:0]	i_delay_imag,
	input	signed	[15:0]	i_sample_real,
	input	signed	[15:0]	i_sample_imag,

	output	signed	[15:0]	o_delay_real,
	output	signed	[15:0]	o_delay_imag,
	output	signed	[15:0]	o_mulunit_real,
	output	signed	[15:0]	o_mulunit_imag
);

	reg signed [15:0] o_delay_real, o_delay_imag, o_mulunit_real, o_mulunit_imag;

	wire signed [16:0] o_bf_c_real, o_bf_c_imag, o_bf_d_real, o_bf_d_imag;

	Bf_Unit Butterfly_3(.a_real(i_delay_real),
						.a_imag(i_delay_imag),
						.b_real(i_sample_real),
						.b_imag(i_sample_imag),
						.c_real(o_bf_c_real),
						.c_imag(o_bf_c_imag),
						.d_real(o_bf_d_real),
						.d_imag(o_bf_d_imag));

	always@(*) begin
		case(i_sel)
			0: begin
				if(i_cnt3 > 4'd8) begin
					o_delay_real = 0;
					o_delay_imag = 0;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end 
				else begin
					o_delay_real = i_sample_real;
					o_delay_imag = i_sample_imag;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end
			end
			1: begin
				o_delay_real = o_bf_d_real[15:0];
				o_delay_imag = o_bf_d_imag[15:0];
				o_mulunit_real = o_bf_c_real[15:0];
				o_mulunit_imag = o_bf_c_imag[15:0];
			end
		endcase
	end
endmodule

module PE4(
	input			i_sel,
	input 			[2:0]	i_cnt4,
	input	signed	[15:0]	i_delay_real,
	input	signed	[15:0]	i_delay_imag,
	input	signed	[15:0]	i_sample_real,
	input	signed	[15:0]	i_sample_imag,

	output	signed	[15:0]	o_delay_real,
	output	signed	[15:0]	o_delay_imag,
	output	signed	[15:0]	o_mulunit_real,
	output	signed	[15:0]	o_mulunit_imag
);

	reg signed [15:0] o_delay_real, o_delay_imag, o_mulunit_real, o_mulunit_imag;

	wire signed [16:0] o_bf_c_real, o_bf_c_imag, o_bf_d_real, o_bf_d_imag;

	Bf_Unit Butterfly_4(.a_real(i_delay_real),
						.a_imag(i_delay_imag),
						.b_real(i_sample_real),
						.b_imag(i_sample_imag),
						.c_real(o_bf_c_real),
						.c_imag(o_bf_c_imag),
						.d_real(o_bf_d_real),
						.d_imag(o_bf_d_imag));

	always@(*) begin
		case(i_sel)
			0: begin
				if(i_cnt4 > 3'd4) begin
					o_delay_real = 0;
					o_delay_imag = 0;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end 
				else begin
					o_delay_real = i_sample_real;
					o_delay_imag = i_sample_imag;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end
			end
			1: begin
				o_delay_real = o_bf_d_real[15:0];
				o_delay_imag = o_bf_d_imag[15:0];
				o_mulunit_real = o_bf_c_real[15:0];
				o_mulunit_imag = o_bf_c_imag[15:0];
			end
		endcase
	end
endmodule

module PE5(
	input			i_sel,
	input 			[1:0]	i_cnt5,
	input	signed	[15:0]	i_delay_real,
	input	signed	[15:0]	i_delay_imag,
	input	signed	[15:0]	i_sample_real,
	input	signed	[15:0]	i_sample_imag,

	output	signed	[15:0]	o_delay_real,
	output	signed	[15:0]	o_delay_imag,
	output	signed	[15:0]	o_mulunit_real,
	output	signed	[15:0]	o_mulunit_imag
);

	reg signed [15:0] o_delay_real, o_delay_imag, o_mulunit_real, o_mulunit_imag;

	wire signed [16:0] o_bf_c_real, o_bf_c_imag, o_bf_d_real, o_bf_d_imag;

	Bf_Unit Butterfly_5(.a_real(i_delay_real),
						.a_imag(i_delay_imag),
						.b_real(i_sample_real),
						.b_imag(i_sample_imag),
						.c_real(o_bf_c_real),
						.c_imag(o_bf_c_imag),
						.d_real(o_bf_d_real),
						.d_imag(o_bf_d_imag));

	always@(*) begin
		case(i_sel)
			0: begin
				if(i_cnt5 > 2'd2) begin
					o_delay_real = 0;
					o_delay_imag = 0;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end 
				else begin
					o_delay_real = i_sample_real;
					o_delay_imag = i_sample_imag;
					o_mulunit_real = i_delay_real;
					o_mulunit_imag = i_delay_imag;
				end
			end
			1: begin
				o_delay_real = o_bf_d_real[15:0];
				o_delay_imag = o_bf_d_imag[15:0];
				o_mulunit_real = o_bf_c_real[15:0];
				o_mulunit_imag = o_bf_c_imag[15:0];
			end
		endcase
	end
endmodule

