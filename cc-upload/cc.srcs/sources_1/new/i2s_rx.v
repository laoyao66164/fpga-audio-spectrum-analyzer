module i2s_rx(
    input sys_clk, input mclk, input rst_n,
    output aud_xclk, output reg aud_bclk, output reg aud_lrck,
    input aud_adcdat, output reg audio_valid, output reg [15:0] audio_data
);
    assign aud_xclk = mclk;
    reg [4:0] bclk_cnt; 
    reg lr_reg; 
    reg [15:0] shift_reg;
    
    always @(posedge mclk or negedge rst_n) begin
        if(!rst_n) begin 
            bclk_cnt <= 0; aud_bclk <= 0; aud_lrck <= 0; lr_reg <= 0; shift_reg <= 0; audio_valid <= 0; audio_data <= 0; 
        end else begin
            bclk_cnt <= bclk_cnt + 1; 
            aud_bclk <= bclk_cnt[0];
            if(bclk_cnt == 31) begin
                bclk_cnt <= 0; lr_reg <= ~lr_reg; aud_lrck <= lr_reg;
                if(lr_reg == 0) begin audio_data <= shift_reg; audio_valid <= 1; end 
                else audio_valid <= 0;
            end
            if(aud_bclk == 1'b1) begin shift_reg <= {shift_reg[14:0], aud_adcdat}; end
        end
    end
endmodule