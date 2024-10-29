// https://csrc.nist.gov/CSRC/media/Projects/Cryptographic-Standards-and-Guidelines/documents/examples/AES_Core128.pdf

////////////////////////////
// subBytes testbench
////////////////////////////

module testbench_subBytes ();//(input logic [127:0] statein,
                            //input logic sben,
                            //output logic [127:0] stateout);


// from NIST example
// state in = 40BFABF4 06EE4D30 42CA6B99 7A5C5816 
// expected out = 090862BF 6F28E304 2C747FEE DA4A6A47

logic [127:0] expected, statein, stateout;
logic sben, clk;

subBytes dut(clk, statein, sben, stateout);


always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    expected <= 128'h090862BF6F28E3042C747FEEDA4A6A47;
    statein <= 128'h40BFABF406EE4D3042CA6B997A5C5816 ;

    sben = 0; #7;
    sben = 1'b1; #27;
    if (stateout == expected) $display ("success");
    else $display ("stateout = %h \n expected = %h", stateout, expected);
end
endmodule

////////////////////////////
// shiftRows testbench
////////////////////////////

module testbench_shiftRows ();


// from NIST example
// state in = 090862BF 6F28E304 2C747FEE DA4A6A47
// expected out = 09287F47 6F746ABF 2C4A6204 DA08E3EE
logic clk, sren;
logic [127:0] expected, statein, stateout;

shiftRows dut(statein, sren, stateout);


initial begin
    statein <= 128'h090862BF6F28E3042C747FEEDA4A6A47;
    expected <= 128'h09287F476F746ABF2C4A6204DA08E3EE;
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    sren = 0; #11;
    sren = 1; #27;
    if (stateout == expected) $display ("success");
    else $display ("stateout = %h \n expected = %h", stateout, expected);
end
endmodule

////////////////////////////
// addRoundKey testbench
////////////////////////////

module testbench_addRoundKey  ();


// from appendix B.1
// state in =  32 43 f6 a8 88 5a 30 8d 31 31 98 a2 e0 37 07 34
// roundkey = 2b 7e 15 16 28 ae d2 a6 ab f7 15 88 09 cf 4f 3c
// expected out = 19 3d e3 be a0 f4 e2 2b 9a c6 8d 2a e9 f8 48 08

logic clk;
logic [127:0] statein, roundkey, stateout, expected;

addRoundKey dut(statein, roundkey, stateout);

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    statein <= 128'h3243f6a8885a308d313198a2e0370734;
    roundkey <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
    expected <= 128'h193de3bea0f4e22b9ac68d2ae9f84808;
    #27;
    if (stateout == expected) $display ("success");
    else $display ("stateout = %h \n expected = %h", stateout, expected);
end
endmodule



////////////////////////////
// keyExpand testbench
////////////////////////////

module testbench_keyExpand  ();

logic clk;
logic [3:0] round;
logic [127:0] expected, prevkey, roundkey;

keyExpand dut(clk, prevkey, round, roundkey);

initial begin
    //find expected key expansion for each round? check indiv?
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    #27;
    round = 0;
    prevkey = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    $display ("round = 0, roundkey = %h", prevkey);
    #17;
    
    for (int i = 1; i <= 10; i++ ) begin
        round = i;
        #17;
        $display ("round = %d, roundkey = %h", i, roundkey);
        prevkey = roundkey;
        
    end
end
endmodule

////////////////////////////
// keyExpand testbench
////////////////////////////

module testbench_controller();

logic clk, reset, load;
logic[127:0] key, roundkey;
logic sren, sben, mcen, arken, outen;

controller mycontr (clk, load, key, inen, sren, sben, mcen, arken, outen, roundkey);

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    key <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
   // reset = 0; #7; reset = 1; #17; reset = 0; #12;
    load = 0; #17; load = 1;
    #1500;
end
endmodule
