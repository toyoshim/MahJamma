module MahJammaMatrixController(i_keyInX, i_keyClk, i_matrixEnX, i_matrixPolarity, io_matrixA, io_matrixB);
	input [9:0] i_keyInX;			// Inputs [START, A, B, ..., I], or [J, K, ..., CHI, PON, KAN, REACH, PON]
	input [1:0] i_keyClk;			// Data triggers; [1] for [START, ...], [0] for [J, ...]
	input [1:0] i_matrixEnX;		// Matrix mode enables; [1] for A=in/B=ou, [0] for A=out/B=in
	input       i_matrixPolarity;	// Matrix output polarity; 0 for active low, 1 for active high
	inout [3:0] io_matrixA;			// Mahjong matrix [M9, M10, M6, M2]
	inout [5:0] io_matrixB;			// Mahjong matrix [M11, M8, M7, M4, M3, M1]

	reg [19:0] r_keyX;				// Holds [START, A, B, ..., N, CHI, PON, KAN, REACH, RON]

	wire [3:0] w_matrixA11X;		// Matrix A for M11
	wire [3:0] w_matrixA8X;			// Matrix A for M8
	wire [3:0] w_matrixA7X;			// Matrix A for M7
	wire [3:0] w_matrixA4X;			// Matrix A for M4
	wire [3:0] w_matrixA3X;			// Matrix A for M3
	wire [3:0] w_matrixA1X;			// Matrix A for M1
	wire [5:0] w_selectA;			// Matrix A select signal [M11, M8, M7, M4, M3, M1] in active high
	wire [3:0] w_matrixAX;        // Matrix A selected by M11, ...

	wire [5:0] w_matrixB10X;      // Matrix B for M10
	wire [5:0] w_matrixB9X;       // Matrix B for M9
	wire [5:0] w_matrixB6X;       // Matrix B for M6
	wire [5:0] w_matrixB2X;       // Matrix B for M2
	wire [3:0] w_selectB;			// Matrix B select signal [M9, M10, M6, M2] in active high
	wire [5:0] w_matrixBX;        // Matrix B selected by M9, ...

	assign w_matrixA11X = { r_keyX[   19], 3'b111 };
	assign w_matrixA8X  =   r_keyX[18:15];
	assign w_matrixA7X  =   r_keyX[14:11];
	assign w_matrixA4X  =   r_keyX[10: 7];
	assign w_matrixA3X  =   r_keyX[ 6: 3];
	assign w_matrixA1X  = { r_keyX[ 2: 0], 1'b1 };

	assign w_matrixB10X = {      1'b1, r_keyX[2], r_keyX[6], r_keyX[10], r_keyX[14], r_keyX[18] };
	assign w_matrixB9X  = { r_keyX[0], r_keyX[1], r_keyX[5], r_keyX[ 9], r_keyX[13], r_keyX[17] };
	assign w_matrixB6X  = {      1'b1, r_keyX[3], r_keyX[7], r_keyX[11], r_keyX[15], r_keyX[19] };	
	assign w_matrixB2X  = {      1'b1, r_keyX[4], r_keyX[8], r_keyX[12], r_keyX[16],       1'b1 };

	assign w_selectA = i_matrixPolarity ? io_matrixB : ~io_matrixB;
	assign w_selectB = i_matrixPolarity ? io_matrixA : ~io_matrixA;

	assign w_matrixAX = w_selectA[5] ? w_matrixA11X : w_selectA[4] ? w_matrixA8X : w_selectA[3] ? w_matrixA7X : w_selectA[2] ? w_matrixA4X : w_selectA[1] ? w_matrixA3X : w_selectA[0] ? w_matrixA1X : 4'b1111;
	assign w_matrixBX = w_selectB[3] ? w_matrixB9X : w_selectB[2] ? w_matrixB10X : w_selectB[1] ? w_matrixB6X : w_selectB[0] ? w_matrixB2X : 6'b111111;

	assign io_matrixA = i_matrixEnX[0] ? 4'bZZZZ : i_matrixPolarity ? ~w_matrixAX : w_matrixAX;
	assign io_matrixB = i_matrixEnX[1] ? 6'bZZZZZZ : i_matrixPolarity ? ~w_matrixBX : w_matrixBX;

	always @ (posedge i_keyClk[1]) begin
		r_keyX[19:10] <= i_keyInX;
	end

	always @ (posedge i_keyClk[0]) begin
		r_keyX[9:0] <= i_keyInX;
	end
endmodule