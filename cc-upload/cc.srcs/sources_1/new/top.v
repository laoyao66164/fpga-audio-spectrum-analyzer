module top(
    input clk_50m, 
    input rst_n,
    inout i2c_sda, 
    output i2c_scl,
    output i2s_bclk, 
    output i2s_lrck, 
    input i2s_din,
    output tft_clk, tft_de, tft_hs, tft_vs, tft_pwm,
    output [4:0] tft_r, 
    output [5:0] tft_g, 
    output [4:0] tft_b,
    output led0
);

    // 彻底屏蔽外部音频引脚
    assign i2c_sda = 1'bz;
    assign i2c_scl = 1'b1;
    assign i2s_bclk = 1'b0;
    assign i2s_lrck = 1'b0;

    // ================= 1. 内部完美测试信号源 =================
    reg [15:0] phase_acc;
    reg signed [15:0] sine_wave;
    reg audio_valid;
    
    always @(posedge clk_50m or negedge rst_n) begin
        if(!rst_n) begin
            phase_acc <= 0;
            audio_valid <= 0;
            sine_wave <= 0;
        end else begin
            phase_acc <= phase_acc + 1;
            // 模拟音频采样
            if(phase_acc % 100 == 0) begin
                audio_valid <= 1;
                // 动态锯齿波，保证频点不断变化
                sine_wave <= phase_acc[13:0]; 
            end else begin
                audio_valid <= 0;
            end
        end
    end

    assign led0 = (sine_wave > 0); 

    // ================= 2. FFT 计算 =================
    wire fft_valid_out;
    wire [31:0] fft_dout; 
    wire fft_tready_unused, fft_config_tready_unused, fft_tlast_unused; 

    (* DONT_TOUCH = "TRUE" *) 
    fft_1024 u_fft (
        .aclk(clk_50m),
        .s_axis_data_tvalid(audio_valid),       
        .s_axis_data_tready(fft_tready_unused),
        .s_axis_data_tdata({16'd0, sine_wave}),      
        .s_axis_data_tlast(1'b0),          
        .s_axis_config_tvalid(1'b1),
        .s_axis_config_tready(fft_config_tready_unused),
        .s_axis_config_tdata(16'd0),
        .m_axis_data_tvalid(fft_valid_out),
        .m_axis_data_tdata(fft_dout),
        .m_axis_data_tlast(fft_tlast_unused),
        .m_axis_data_tready(1'b1)          
    );

    // ================= 3. 求模 =================
    wire signed [15:0] fft_re = fft_dout[15:0];
    wire signed [15:0] fft_im = fft_dout[31:16];
    wire [15:0] abs_re = (fft_re[15] == 1'b1) ? (~fft_re + 1'b1) : fft_re;
    wire [15:0] abs_im = (fft_im[15] == 1'b1) ? (~fft_im + 1'b1) : fft_im;
    wire [16:0] mag_sum = abs_re + abs_im;
    
    reg [15:0] mag_out_reg;
    always @(posedge clk_50m or negedge rst_n) begin
        if(!rst_n) mag_out_reg <= 16'd0;
        else if(fft_valid_out) begin
            if (mag_sum > 16'd65535) mag_out_reg <= 16'd65535;
            else                     mag_out_reg <= mag_sum[15:0]; 
        end
    end
    wire [15:0] mag_out = mag_out_reg;

    // ================= 4. 屏幕时序 =================
    parameter H_ACTIVE = 800, H_FRONT = 40, H_SYNC = 48, H_BACK = 40;
    parameter V_ACTIVE = 480, V_FRONT = 13, V_SYNC = 3,  V_BACK = 29;
    parameter H_TOTAL = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;
    parameter V_TOTAL = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;
    reg [10:0] h_cnt = 0; reg [10:0] v_cnt = 0;
    
    always @(posedge clk_50m or negedge rst_n) begin
        if(!rst_n) begin h_cnt <= 0; v_cnt <= 0; end
        else begin
            if(h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if(v_cnt == V_TOTAL - 1) v_cnt <= 0; else v_cnt <= v_cnt + 1;
            end else h_cnt <= h_cnt + 1;
        end
    end
    
    assign tft_clk = ~clk_50m; 
    assign tft_hs  = ~(h_cnt >= H_ACTIVE + H_FRONT && h_cnt < H_ACTIVE + H_FRONT + H_SYNC);
    assign tft_vs  = ~(v_cnt >= V_ACTIVE + V_FRONT && v_cnt < V_ACTIVE + V_FRONT + V_SYNC);
    assign tft_de  = (h_cnt < H_ACTIVE) && (v_cnt < V_ACTIVE);
    assign tft_pwm = 1'b1; 

    // ================= 5. 画图 =================
    wire [23:0] rgb_out;
    spectrum_draw u_draw(
        .clk(clk_50m), .de(tft_de), .x_pos(h_cnt), .y_pos(v_cnt),
        .mag_in(mag_out), .rgb_out(rgb_out)
    );

    assign tft_r = rgb_out[23:19];
    assign tft_g = rgb_out[15:10];
    assign tft_b = rgb_out[7:3];

endmodule