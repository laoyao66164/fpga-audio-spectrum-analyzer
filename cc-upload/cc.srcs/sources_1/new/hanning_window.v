module hanning_window(
    input clk, input rst_n, input valid_in, input signed [15:0] din,
    output reg valid_out, output reg signed [15:0] dout
);
    reg [9:0] win_idx;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            win_idx <= 0; valid_out <= 0; dout <= 0;
        end else begin
            valid_out <= valid_in;
            if(valid_in) begin
                win_idx <= win_idx + 1;
                // 简化版汉宁窗：在中间时乘 1，两端时衰减
                if (win_idx < 256 || win_idx > 768) dout <= din >> 1; 
                else dout <= din;
            end
        end
    end
endmodule