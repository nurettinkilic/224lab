module main_design (
    input clk,
    input [1:0] opcode,
    input we,
    input [4:0] a1,
    input [4:0] a2,
    input [4:0] a3,
    input [31:0] wd3,
    output [31:0] result
);

    wire [31:0] rd1, rd2;

    RegisterFile rf (
        .CLK(clk),
        .WE3(we),
        .A1(a1),
        .A2(a2),
        .A3(a3),
        .WD3(wd3),
        .RD1(rd1),
        .RD2(rd2)
    );

    ALU alu (
        .opcode(opcode),
        .A(rd1),
        .B(rd2),
        .Result(result)
    );

endmodule


module ALU (
    input [1:0] opcode,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] Result
);
    always @(*) begin
        case (opcode)
            2'b00: Result = A + B;
            2'b01: Result = A - B;
            2'b10: Result = A << B;
            2'b11: Result = A >> B;
            default: Result = 32'b0;
        endcase
    end
endmodule


module RegisterFile (
    input CLK,
    input WE3,
    input [4:0] A1, A2, A3,
    input [31:0] WD3,
    output [31:0] RD1, RD2
);
    reg [31:0] registers [0:31];

    assign RD1 = registers[A1];
    assign RD2 = registers[A2];

    always @(posedge CLK) begin
        if (WE3)
            registers[A3] <= WD3;
    end
endmodule


