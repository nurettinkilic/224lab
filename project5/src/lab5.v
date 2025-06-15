
// ===== alu.v =====
module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] imm,
    input  [2:0]  alu_op,
    output reg [31:0] result
);
    always @(*) begin
        case (alu_op)
            3'b000: result = 0;
            3'b001: result = 0;
            3'b010: result = a + b;
            3'b011: result = a - b;
            3'b100: result = a << b;
            3'b101: result = a >> b;
            3'b110: result = a + imm;
            3'b111: result = a - imm;
            default: result = 0;
        endcase
    end
endmodule

// ===== instruction_decoder.v =====
module instruction_decoder(
    input clk,
    input reset,
    input control,
    output reg [31:0] instruction
);
    reg [2:0] pc;
    reg [31:0] instr_mem[0:5];

    initial begin
        instr_mem[0] = {3'b110, 5'd10, 5'd0, 19'd10};
        instr_mem[1] = {3'b110, 5'd15, 5'd0, 19'd15};
        instr_mem[2] = {3'b010, 5'd25, 5'd10, 5'd15, 14'd0};
        instr_mem[3] = {3'b111, 5'd20, 5'd25, 19'd5};
        instr_mem[4] = {3'b110, 5'd5, 5'd0, 19'd2};
        instr_mem[5] = {3'b100, 5'd30, 5'd25, 5'd5, 14'd0};
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (control)
            pc <= (pc == 5) ? 0 : pc + 1;
    end

    always @(*) begin
        if (control)
            instruction = instr_mem[pc];
        else
            instruction = 32'b0;
    end
endmodule

// ===== register_file.v =====
module register_file(
    input clk,
    input we,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2
);
    reg [31:0] regs[31:0];
    integer i;

    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];

    always @(posedge clk) begin
        if (we)
            regs[waddr] <= wdata;
    end
endmodule

// ===== top_module.v =====
module lab5(
    input clk,
    input reset,
    input control,
    output [31:0] Result
);
    wire [31:0] instruction;
    reg we;
    wire [2:0] alu_op;
    wire [4:0] rd, rs1, rs2;
    wire [31:0] imm, reg1, reg2, alu_result;

    instruction_decoder decoder(
        .clk(clk),
        .reset(reset),
        .control(control),
        .instruction(instruction)
    );

    assign alu_op = instruction[31:29];
    assign rd     = instruction[28:24];
    assign rs1    = instruction[23:19];
    assign rs2    = instruction[18:14];
    assign imm    = instruction[18:0];

    register_file regfile(
        .clk(clk),
        .we(we),
        .raddr1(rs1),
        .raddr2(rs2),
        .waddr(rd),
        .wdata(alu_result),
        .rdata1(reg1),
        .rdata2(reg2)
    );

    alu myalu(
        .a(reg1),
        .b(reg2),
        .imm(imm),
        .alu_op(alu_op),
        .result(alu_result)
    );

    always @(*) begin
        if (alu_op == 3'b000 || alu_op == 3'b001)
            we = 0;
        else
            we = 1;
    end

    assign Result = alu_result;
endmodule
