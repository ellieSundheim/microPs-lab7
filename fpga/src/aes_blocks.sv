//////////////////////////////
// subBytes
//////////////////////////////

module subBytes (input logic clk,
                input logic [127:0] statein,
                input logic sben,
                output logic [127:0] stateout);

    logic [31:0] w0, w1, w2, w3;
    logic [31:0] w0p, w1p, w2p, w3p;

    assign {w0, w1, w2, w3} = statein ;

	sboxWord_sync sw0(w0, clk, w0p);
    sboxWord_sync sw1(w1, clk, w1p);
	sboxWord_sync sw2(w2, clk, w2p);
	sboxWord_sync sw3(w3, clk, w3p);

    always_ff @(posedge clk) begin
        if (sben) stateout <= {w0p, w1p, w2p, w3p};
        else stateout <= statein;
    end
    endmodule


/////////////////////////////
// shiftRows
//   The key and message are 128-bit values packed into an array of 16 bytes as
//   shown below
//        [127:120] [95:88] [63:56] [31:24]     S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
/////////////////////////////

module shiftRows   (input logic [127:0] statein,
                    input logic sren,
                    output logic [127:0] stateout);
    logic [7:0] s00, s01, s02, s03, s10, s11, s12, s13, s20, s21, s22, s23, s30, s31, s32, s33;
    assign {s00, s10, s20, s30, s01, s11, s21, s31, s02, s12, s22, s32, s03, s13, s23, s33} = statein;

    always_comb begin
        if (sren) begin
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

module addRoundKey(input logic [127:0] statein,
                    input logic [127:0] roundkey,
                    output logic [127:0] stateout );
    logic [31:0] w1, w2, w3, w4;
    logic [31:0] w1p, w2p, w3p, w4p;
    logic [31:0] rk1, rk2, rk3, rk4;

    assign {w1, w2, w3, w4} = statein;
    assign {rk1, rk2, rk3, rk4} = roundkey;

    always_comb begin
        w1p = w1 ^ rk1;
        w2p = w2 ^ rk2;
        w3p = w3 ^ rk3;
        w4p = w4 ^ rk4;
        stateout = {w1p, w2p, w3p, w4p};
    end
endmodule



////////////////////////////
// keyexpansion
////////////////////////////
module keyExpand(input logic clk,
				input logic [127:0] prevkey,
                input logic [3:0] round,
                output logic [127:0] roundkey);

        logic[31:0] w0, w1, w2, w3, w4, w5, w6, w7, Rcon, rotWord, subWord;

        assign {w0,w1,w2,w3} = prevkey;
        // rotWord([a0, a1, a2,a3]) = [a1, a2, a3, a0]
		assign rotWord = {w3[23:16], w3[15:8], w3[7:0], w3[31:24]};

		sboxWord_sync mySBM0(rotWord, clk, subWord);
        

        // every subsequent word is generated recursively from the preceding word w[i-1] and the word Nk = 4 positions earlier w[i-4]
        // Nk = 4 (just a constant)
        // for round 0, i just use the key
        always_comb begin
            if ((round == 4'b1111) | (round == 4'b0000)) roundkey = prevkey;
            else begin
                // determine Rcon[j]
                if (round <= 8) Rcon = {16'b1 << (round-1), 24'h000000};
                else if (round == 9) Rcon = 32'h1b000000;
                else if (round == 10) Rcon = 32'h36000000;
                

                // calculate mod 4 word
                // above, do rotWord
                // subWord(rotWord) gets done by sync module outside the always comb but we use it here
                w4 = w0 ^ subWord ^ Rcon;

                // calculate all the in between words
                w5 = w1 ^ w4;
                w6 = w2 ^ w5;
                w7 = w3 ^ w6;

                // smush them back into a round key
                roundkey = {w4, w5, w6, w7};
            end
        end

endmodule

///////////////////////////////////
// controller
//////////////////////////////////
module controller( input logic clk, load, 
                   input logic[127:0] key,
                   output logic inen, sren, sben, mcen, arken, outen,
                   output logic[127:0] roundkey,
                   output logic done);

    logic [127:0] prevkey;
    logic [3:0] round;
    logic [1:0] counter;

    // key expansion
    keyExpand myKE(clk, prevkey, round, roundkey);

    typedef enum {idle, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, complete, error} statetype;
    statetype state, nextstate;

    // state register
    always_ff @(posedge clk) begin
        if (load) begin 
            counter <= 0;
            prevkey <= key;
            state <= idle;
            round <= -1;
        end
        else begin
            state <= nextstate;
            if (state != nextstate) begin 
                counter <= 0;
                prevkey <= roundkey;
                round <= round + 1;
            end
            else counter <= counter + 1;
            
        end

    end

    // next state logic (handled in flop logic)
    always_comb begin
    case (state)
        idle: if (!load) nextstate = r0; else nextstate = state;
        r0: if (counter == 3) nextstate = r1; else nextstate = state;
        r1: if (counter == 3) nextstate = r2; else nextstate = state;
        r2: if (counter == 3) nextstate = r3; else nextstate = state;
        r3: if (counter == 3) nextstate = r4; else nextstate = state;
        r4: if (counter == 3) nextstate = r5; else nextstate = state;
        r5: if (counter == 3) nextstate = r6; else nextstate = state;
        r6: if (counter == 3) nextstate = r7; else nextstate = state;
        r7: if (counter == 3) nextstate = r8; else nextstate = state;
        r8: if (counter == 3) nextstate = r9; else nextstate = state;
        r9: if (counter == 3) nextstate = r10; else nextstate = state;
        r10: if (counter == 3) nextstate = complete; else nextstate = state;
        complete:  nextstate = state;
        error: nextstate = error;
        default: nextstate = error;
        endcase
    end


    // output logic
    assign inen = (round > 0);
    assign sben = ((round > 0) && (round <= 10));
    assign sren = ((round > 0) && (round <= 10));
    assign mcen = ((round > 0) && (round < 10));
    assign arken = (round > -1);
    assign outen = (counter == 3);
    assign done = (state == complete);

    

endmodule
