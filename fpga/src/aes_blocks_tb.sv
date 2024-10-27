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
    statein = 128'h40BFABF406EE4D3042CA6B997A5C5816 ;

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

module testbench_addRoundKey  (input logic [127:0] statein,
                            input logic [127:0] roundkey,
                            output logic [127:0] stateout);


// from NIST example
// state in =  6BC1BEE2 2E409F96 E93D7E11 7393172A
// roundkey = 
// expected out = 40BFABF4 06EE4D30 42CA6B99 7A5C5816

addRoundKey dut(statein, roundkey, stateout);
logic clk;
logic [127:0] expected;

initial begin
    expected <= 128'h40BFABF406EE4D3042CA6B997A5C5816;
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    #27;
    if (stateout == expected) $display ("success");
    else $display ("stateout = %h \n expected = %h", stateout, expected);
end
endmodule



////////////////////////////
// keyExpand testbench
////////////////////////////

module testbench_keyExpand  (input logic [127:0] key,
                            output logic [127:0] roundkey);
logic clk;
logic [3:0] round;
logic [127:0] expected;

keyExpand dut(clk, key, round, roundkey);

initial begin
    //find expected key expansion for each round? check indiv?
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    #27;
    for (int round = 0; round <= 10; round++ ) begin
        $display ("round = %d, roundkey = %h", round, roundkey);
        #10;
    end
end
endmodule
