module project1 (
    input [7:0] in,
    output reg [7:0] out
);

    always @* begin
        if (in[7] == 1) begin
            out = ~(in) + 1;
        end else begin
            out = in;
        end
    end

endmodule