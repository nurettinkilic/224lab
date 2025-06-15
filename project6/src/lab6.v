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

module instruction_decoder(
    input clk,
    input reset,
    input control,
    output reg [31:0] instruction
);
    reg [4:0] pc;
    reg [31:0] instr_mem[0:20];

    initial begin
        // ADDI reg10, reg0, 10
        instr_mem[0] = {3'b110, 5'd10, 5'd0, 19'd10};
        // ADDI reg15, reg0, 15
        instr_mem[1] = {3'b110, 5'd15, 5'd0, 19'd15};
        // ADD reg25, reg10, reg15
        instr_mem[2] = {3'b010, 5'd25, 5'd10, 5'd15, 14'd0};
        // SUBI reg20, reg25, 5
        instr_mem[3] = {3'b111, 5'd20, 5'd25, 19'd5};
        // ADDI reg21, reg0, 2
        instr_mem[4] = {3'b110, 5'd21, 5'd0, 19'd2};
        // J 12 (Jump to address 12)
        instr_mem[5] = {3'b101, 5'd0, 5'd0, 19'd12}; // J: opcode 101
        // SHIFTL reg30, reg7, reg21
        instr_mem[6] = {3'b100, 5'd30, 5'd7, 5'd21, 14'd0};
        // unused
        instr_mem[7] = 32'd0;
        instr_mem[8] = 32'd0;
        instr_mem[9] = 32'd0;
        // ADDI reg4, reg0, 4
        instr_mem[10] = {3'b110, 5'd4, 5'd0, 19'd4};
        // ADD reg5, reg0, reg0
        instr_mem[11] = {3'b010, 5'd5, 5'd0, 5'd0, 14'd0};
        // BEQ reg4, reg5, 7 (if reg4 == reg5 PC = 7)
        instr_mem[12] = {3'b011, 5'd4, 5'd5, 19'd7}; // BEQ: opcode 011
        // ADDI reg6, reg0, 1
        instr_mem[13] = {3'b110, 5'd6, 5'd0, 19'd1};
        // ADDI reg7, reg0, 1
        instr_mem[14] = {3'b110, 5'd7, 5'd0, 19'd1};
        // ADD reg8, reg6, reg7
        instr_mem[15] = {3'b010, 5'd8, 5'd6, 5'd7, 14'd0};
        // ADD reg6, reg7, reg0
        instr_mem[16] = {3'b010, 5'd6, 5'd7, 5'd0, 14'd0};
        // ADD reg7, reg8, reg0
        instr_mem[17] = {3'b010, 5'd7, 5'd8, 5'd0, 14'd0};
        // ADDI reg5, reg5, 1
        instr_mem[18] = {3'b110, 5'd5, 5'd5, 19'd1};
        // J 12 (Jump to address 12)
        instr_mem[19] = {3'b101, 5'd0, 5'd0, 19'd12};
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (control)
            pc <= pc + 1;
    end

    always @(*) begin
        instruction = instr_mem[pc];
    end
endmodule

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

module seven_segment(
    input [3:0] digit,
    output reg [6:0] seg
);
    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0011000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule

module lab6(
    input clk,
    input reset,
    input control,
    output [6:0] seg
);
    wire [31:0] instruction;
    reg we;
    wire [2:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [18:0] imm19;
    wire [31:0] reg1, reg2, alu_result;
    reg [4:0] pc;
    reg [31:0] regfile[0:31];
    reg [31:0] instruction_reg;

    assign opcode = instruction[31:29];
    assign rd     = instruction[28:24];
    assign rs1    = instruction[23:19];
    assign rs2    = instruction[18:14];
    assign imm19  = instruction[18:0];

    // Instantiate instruction decoder
    instruction_decoder decoder(
        .clk(clk),
        .reset(reset),
        .control(control),
        .instruction(instruction)
    );

    // ALU example (can expand per your ALU module)
    assign alu_result = (opcode == 3'b010) ? (regfile[rs1] + regfile[rs2]) : // ADD
                        (opcode == 3'b110) ? (regfile[rs1] + imm19) : // ADDI
                        (opcode == 3'b111) ? (regfile[rs1] - imm19) : // SUBI
                        32'b0;

    // Main control
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            regfile[0] <= 0;
            regfile[4] <= 0;
            regfile[5] <= 0;
            regfile[6] <= 0;
            regfile[7] <= 0;
            regfile[8] <= 0;
            regfile[10] <= 0;
            regfile[15] <= 0;
            regfile[20] <= 0;
            regfile[21] <= 0;
            regfile[25] <= 0;
            regfile[30] <= 0;
        end else if (control) begin
            instruction_reg <= instruction;

            if (opcode == 3'b010) begin // ADD
                regfile[rd] <= regfile[rs1] + regfile[rs2];
                pc <= pc + 1;
            end else if (opcode == 3'b110) begin // ADDI
                regfile[rd] <= regfile[rs1] + imm19;
                pc <= pc + 1;
            end else if (opcode == 3'b111) begin // SUBI
                regfile[rd] <= regfile[rs1] - imm19;
                pc <= pc + 1;
            end else if (opcode == 3'b011) begin // BEQ
                if (regfile[rd] == regfile[rs1])
                    pc <= imm19[4:0]; // Jump to imm as address
                else
                    pc <= pc + 1;
            end else if (opcode == 3'b101) begin // J
                pc <= imm19[4:0];
            end else begin
                pc <= pc + 1;
            end
        end
    end

    // Show reg6 on 7-segment
    wire [3:0] digit = regfile[6][3:0];
    seven_segment seg7 (
        .digit(digit),
        .seg(seg)
    );
endmodule

