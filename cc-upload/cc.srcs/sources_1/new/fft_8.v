module fft_8(
    input clk,
    input rst_n,
    input signed [15:0] din_0, din_1, din_2, din_3, din_4, din_5, din_6, din_7,
    output reg [15:0] mag_0, mag_1, mag_2, mag_3, mag_4, mag_5, mag_6, mag_7
);
    // 简化版 8点 FFT (仅展示架构逻辑)
    wire signed [16:0] s0, s1, s2, s3, d0, d1, d2, d3;
    assign s0 = din_0 + din_7;
    assign s1 = din_1 + din_6;
    assign s2 = din_2 + din_5;
    assign s3 = din_3 + din_4;
    assign d0 = din_0 - din_7;
    assign d1 = din_1 - din_6;
    assign d2 = din_2 - din_5;
    assign d3 = din_3 - din_4;

    // 蝴蝶运算 (省略了复数乘法，仅做绝对值取模，纯用于显示演示)
    always @(posedge clk) begin
        mag_0 <= (s0 > 0) ? s0 : -s0;
        mag_1 <= (s1 + d1 > 0) ? (s1 + d1) : -(s1 + d1);
        mag_2 <= (s2 + d2 > 0) ? (s2 + d2) : -(s2 + d2);
        mag_3 <= (s3 + d3 > 0) ? (s3 + d3) : -(s3 + d3);
        mag_4 <= (s0 < 0) ? -s0 : s0;
        mag_5 <= (s1 - d1 > 0) ? (s1 - d1) : -(s1 - d1);
        mag_6 <= (s2 - d2 > 0) ? (s2 - d2) : -(s2 - d2);
        mag_7 <= (s3 - d3 > 0) ? (s3 - d3) : -(s3 - d3);
    end
endmodule