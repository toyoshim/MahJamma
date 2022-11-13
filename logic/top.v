module MahJammaMatrixController(i_key, i_keyClk, i_matrixEnX, i_matrixPolarity, io_matrixA, io_matrixB);
	input [14:0] i_key;				// Inputs [START, A, B, ..., N], or [START, A, B, ..., I, CHI, PON, KAN, REACH, RON] (follows i_matrixPolarity)
	input [1:0] i_keyClk;			// Data triggers; [1] for [J, K, L, M, N], [0] for [CHI, PON, KAN, REACH, RON]
	input [1:0] i_matrixEnX;		// Matrix mode enables; [1] for A=in/B=ou, [0] for A=out/B=in
	input       i_matrixPolarity;	// Matrix output polarity; 0 for active low, 1 for active high
	inout [3:0] io_matrixA;			// Mahjong matrix [M9, M10, M6, M2]
	inout [5:0] io_matrixB;			// Mahjong matrix [M11, M8, M7, M4, M3, M1]

	reg [9:0] r_key;					// Holds [J, K, L, M, N, CHI, PON, KAN, REACH, RON] (follows i_matrixPolarity)
	
	wire [19:0] w_key;				// Holds [START, A, B, ..., N, CHI, PON, KAN, REACH, RON] (follows i_matrixPolarity)

	wire [3:0] w_matrixA11;			// Matrix A for M11 (follows i_matrixPolarity)
	wire [3:0] w_matrixA8;			// Matrix A for M8 (follows i_matrixPolarity)
	wire [3:0] w_matrixA7;			// Matrix A for M7 (follows i_matrixPolarity)
	wire [3:0] w_matrixA4;			// Matrix A for M4 (follows i_matrixPolarity)
	wire [3:0] w_matrixA3;			// Matrix A for M3 (follows i_matrixPolarity)
	wire [3:0] w_matrixA1;			// Matrix A for M1 (follows i_matrixPolarity)
	wire [5:0] w_selectA;			// Matrix A select signal [M11, M8, M7, M4, M3, M1] in active high
	wire [3:0] w_matrixA;			// Matrix A selected by M11, ... (follows i_matrixPolarity)

	wire [5:0] w_matrixB10;			// Matrix B for M10 (follows i_matrixPolarity)
	wire [5:0] w_matrixB9;			// Matrix B for M9 (follows i_matrixPolarity)
	wire [5:0] w_matrixB6;			// Matrix B for M6 (follows i_matrixPolarity)
	wire [5:0] w_matrixB2;			// Matrix B for M2 (follows i_matrixPolarity)
	wire [3:0] w_selectB;			// Matrix B select signal [M9, M10, M6, M2] in active high
	wire [5:0] w_matrixB;			// Matrix B selected by M9, ... (follows i_matrixPolarity)
	
	assign w_key = { i_key[14:5], r_key };

	assign w_matrixA11 = { w_key[   19], !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity };
	assign w_matrixA8  =   w_key[18:15];
	assign w_matrixA7  =   w_key[14:11];
	assign w_matrixA4  =   w_key[10: 7];
	assign w_matrixA3  =   w_key[ 6: 3];
	assign w_matrixA1  = { w_key[ 2: 0], !i_matrixPolarity };

	assign w_matrixB10 = { !i_matrixPolarity, w_key[2], w_key[6], w_key[10], w_key[14], w_key[18]         };
	assign w_matrixB9  = {          w_key[0], w_key[1], w_key[5], w_key[ 9], w_key[13], w_key[17]         };
	assign w_matrixB6  = { !i_matrixPolarity, w_key[3], w_key[7], w_key[11], w_key[15], w_key[19]         };	
	assign w_matrixB2  = { !i_matrixPolarity, w_key[4], w_key[8], w_key[12], w_key[16], !i_matrixPolarity };

	assign w_selectA = i_matrixPolarity ? io_matrixB : ~io_matrixB;
	assign w_selectB = i_matrixPolarity ? io_matrixA : ~io_matrixA;

	assign w_matrixA = w_selectA[5] ? w_matrixA11 : w_selectA[4] ? w_matrixA8 : w_selectA[3] ? w_matrixA7 : w_selectA[2] ? w_matrixA4 : w_selectA[1] ? w_matrixA3 : w_selectA[0] ? w_matrixA1 : { !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity };
	assign w_matrixB = w_selectB[3] ? w_matrixB9 : w_selectB[2] ? w_matrixB10 : w_selectB[1] ? w_matrixB6 : w_selectB[0] ? w_matrixB2 : { !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity, !i_matrixPolarity };

	assign io_matrixA = i_matrixEnX[0] ? 4'bZZZZ : w_matrixA;
	assign io_matrixB = i_matrixEnX[1] ? 6'bZZZZZZ : w_matrixB;

	always @ (posedge i_keyClk[1]) begin
		r_key[9:5] <= i_key[4:0];
	end

	always @ (posedge i_keyClk[0]) begin
		r_key[4:0] <= i_key[4:0];
	end
endmodule