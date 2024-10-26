//////////////////////////////
// subBytes
//////////////////////////////

module subBytes (input logic [127:0] statein,
                input logic sben,
                output logic [127:0] stateout);

    logic [7:0] s00, s01, s02, s03, s10, s11, s12, s13, s20, s21, s22, s23, s30, s31, s32, s33;
    logic [7:0] s00p, s01p, s02p, s03p, s10p, s11p, s12p, s13p, s20p, s21p, s22p, s23p, s30p, s31p, s32p, s33p;

    {s00, s01, s02, s03, s10, s11, s12, s13, s20, s21, s22, s23, s30, s31, s32, s33} = statein;

    always_comb begin
        if sben begin
            s00p = sbox(s00);
            s01p = sbox(s01);
            s02p = sbox(s02);
            s03p = sbox(s03);

            s10p = sbox(s10);
            s11p = sbox(s11);
            s12p = sbox(s12);
            s13p = sbox(s13);

            s20p = sbox(s20);
            s21p = sbox(s21);
            s22p = sbox(s22);
            s23p = sbox(s23);

            s30p = sbox(s30);
            s31p = sbox(s31);
            s32p = sbox(s32);
            s33p = sbox(s33);

            {s00p, s01p, s02p, s03p, s10p, s11p, s12p, s13p, s20p, s21p, s22p, s23p, s30p, s31p, s32p, s33p} = stateout;
        end
        else stateout = statein;
    end
    endmodule


/////////////////////////////
// shiftRows
/////////////////////////////

module shiftRows   (input logic [127:0] statein,
                    input logic sren,
                    output logic [127:0] stateout);
    logic [7:0] s00, s01, s02, s03, s10, s11, s12, s13, s20, s21, s22, s23, s30, s31, s32, s33;
    {s00, s01, s02, s03, s10, s11, s12, s13, s20, s21, s22, s23, s30, s31, s32, s33} = statein;

    always_comb begin
        if sren begin
            stateout[127:96] = {s00, s11, s22, s33};
            stateout[95:64] = {s01, s12, s23, s30};
            stateout[63:32] = {s02, s13, s20, s31};
            stateout[31:0] = {s03, s10, s21, s32};
        end
        else stateout = statein;
    end
endmodule


/////////////////////////////
// module addRoundKey
/////////////////////////////

module addRoundKey
                    (input logic [127:0] statein,
                    input logic [127:0] roundkey,
                    output logic [128:0] stateout );
    logic [31:0] w1, w2, w3, w4;
    logic [31:0] w1p, w2p, w3p, w4p;
    logic [31:0] rk1, rk2, rk3, rk4;

    {w1, w2, w3, w4} = statein;

    always_comb begin
        w1p = w1 ^ rk1;
        w2p = w2 ^ rk2;
        w3p = w3 ^ rk3;
        w4p = w4 ^ rk4;
        {w1p, w2p, w3p, w4p} = stateout;
    end
endmodule
