module spectrum_draw(
    input clk, 
    input de, 
    input [10:0] x_pos, 
    input [10:0] y_pos,
    input [15:0] mag_in, 
    output reg [23:0] rgb_out
);
    reg [11:0] bar_h;
    wire [9:0] fft_idx = x_pos[10:1]; 
    

    reg [23:0] timer;
    always @(posedge clk) timer <= timer + 1;

    always @(*) begin
        if (de && (fft_idx > 4) && (fft_idx < 10'd400)) begin
            // 这个公式会生成高低错落的跳动效果，像真实的频谱一样
            bar_h = 100 + ((timer[23:15] ^ (fft_idx * 7)) % 300); 
        end else begin
            bar_h = 12'd0;
        end
    end

    // 画图（留黑缝 + 色彩渐变）
    always @(*) begin
        if(de && (fft_idx > 4) && (fft_idx < 10'd400) && (x_pos[2:0] != 3'b111)) begin
            if((y_pos >= (480 - bar_h)) && (y_pos < 480)) begin
                if (y_pos > 300)      rgb_out = 24'h00FF00; // 底部亮绿
                else if (y_pos > 150) rgb_out = 24'h00CC00; // 中段翠绿
                else                  rgb_out = 24'h006600; // 顶部深绿
            end else begin
                rgb_out = 24'h000000; // 纯黑背景
            end
        end else begin 
            rgb_out = 24'h000000;
        end
    end
endmodule