// https://csrc.nist.gov/CSRC/media/Projects/Cryptographic-Standards-and-Guidelines/documents/examples/AES_Core128.pdf

////////////////////////////
// subBytes testbench
////////////////////////////

module testbench_subBytes (input logic [127:0] statein,
                            input logic sben,
                            output logic [127:0] stateout);


// from NIST example
// state in = 40BFABF4 06EE4D30 42CA6B99 7A5C5816 
// expected out = 090862BF 6F28E304 2C747FEE DA4A6A47

shiftRows dut(statein, sren, stateout);

initial begin
    expected <= 16'h090862BF6F28E3042C747FEEDA4A6A47;
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    sben = 1; #27;
    if (stateout == expected) $display ("success");
    else $display ("stateout = %h \n expected = %h", stateout, expected);
end
endmodule

////////////////////////////
// shiftRows testbench
////////////////////////////

module testbench_shiftRows  (input logic [127:0] statein,
                            input logic sren,
                            output logic [127:0] stateout);


// from NIST example
// state in = 090862BF 6F28E304 2C747FEE DA4A6A47
// expected out = 09287F47 6F746ABF 2C4A6204 DA08E3EE

shiftRows dut(statein, sren, stateout);

initial begin
    expected <= 16'h09287F476F746ABF2C4A6204DA08E3EE;
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
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

initial begin
    expected <= 16'h40BFABF406EE4D3042CA6B997A5C5816;
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

logic [3:0] round;
keyExpand dut(key, round, roundkey);

initial begin
    expectedR0 = 16'h
end

always begin
    clk = 1'b0; #5;
    clk = 1'b1; #5;
end

initial begin
    #27;
    for (int i = 0; i <= 10; i++ ) begin
        $display ("round = %d, roundkey = %h", round, roundKey);
        #10;
    end
end
endmodule