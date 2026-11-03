module i2c_es8388_cfg(
    input clk, input rst_n, inout sda, output scl
);
    reg [7:0] cfg_addr; reg [7:0] cfg_data; reg start_wr; wire done_wr;
    i2c_master u_i2c_master(
        .clk(clk), .rst_n(rst_n), .sda(sda), .scl(scl), .i2c_addr(7'h10),
        .reg_addr(cfg_addr), .reg_data(cfg_data), .start(start_wr), .done(done_wr)
    );
    reg [1:0] state; reg [5:0] idx;
    reg [15:0] cfg_table [0:20];
    initial begin
        cfg_table[0]  = {8'h00, 8'h80}; cfg_table[1]  = {8'h00, 8'h00}; 
        cfg_table[2]  = {8'h01, 8'h00}; cfg_table[3]  = {8'h02, 8'hF0}; 
        cfg_table[4]  = {8'h04, 8'h00}; cfg_table[5]  = {8'h08, 8'h00}; 
        cfg_table[6]  = {8'h0B, 8'h02}; cfg_table[7]  = {8'h0C, 8'h0C}; 
        cfg_table[8]  = {8'h10, 8'h00}; cfg_table[9]  = {8'h17, 8'h18}; 
        cfg_table[10] = {8'h18, 8'h18}; cfg_table[11] = {8'h27, 8'hB8}; 
        cfg_table[12] = {8'h2B, 8'h80}; cfg_table[13] = {8'h2E, 8'h00}; 
        cfg_table[14] = {8'h2F, 8'h00}; cfg_table[15] = {8'h30, 8'h00}; 
        cfg_table[16] = {8'h31, 8'h00}; cfg_table[17] = {8'h32, 8'h00}; 
        cfg_table[18] = {8'h33, 8'h00}; cfg_table[19] = {8'h34, 8'h00}; 
        cfg_table[20] = {8'h35, 8'h00}; 
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin state <= 0; idx <= 0; start_wr <= 0; end 
        else begin
            case(state)
                0: begin
                    if(idx > 20) begin state <= 0; start_wr <= 0; end
                    else begin cfg_addr <= cfg_table[idx][15:8]; cfg_data <= cfg_table[idx][7:0]; start_wr <= 1; state <= 1; end
                end
                1: begin start_wr <= 0; state <= 2; end
                2: begin if(done_wr) begin idx <= idx + 1; state <= 0; end end
            endcase
        end
    end
endmodule

module i2c_master(
    input clk, input rst_n, inout sda, output reg scl,
    input [6:0] i2c_addr, input [7:0] reg_addr, input [7:0] reg_data,
    input start, output reg done
);
    parameter CNT_MAX = 250;
    reg [7:0] cnt; reg [4:0] state;
    reg sda_out, sda_en; assign sda = sda_en ? sda_out : 1'bz;
    reg [3:0] bit_cnt; reg [7:0] tx_buf;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin cnt <= 0; scl <= 1; sda_out <= 1; sda_en <= 0; state <= 0; bit_cnt <= 0; tx_buf <= 0; done <= 0; end
        else begin
            case(state)
                0: begin done <= 0; if(start) begin state <= 1; cnt <= 0; tx_buf <= {i2c_addr,1'b0}; end end
                1: begin cnt <= cnt + 1; if(cnt < CNT_MAX/2) begin sda_en <= 1; sda_out <= 1; scl <= 1; end else if(cnt < CNT_MAX) sda_out <= 0; else begin cnt <= 0; scl <= 0; bit_cnt <= 7; state <= 2; end end
                2, 4, 6: begin cnt <= cnt + 1; if(cnt == CNT_MAX) begin cnt <= 0; sda_en <= 1; sda_out <= tx_buf[bit_cnt]; scl <= 1; if(bit_cnt == 0) state <= state + 1; else bit_cnt <= bit_cnt - 1; end else if(cnt == CNT_MAX/2) scl <= 0; end
                3, 5, 7: begin cnt <= cnt + 1; sda_en <= 0; if(cnt == CNT_MAX) begin cnt <= 0; scl <= 0; bit_cnt <= 7; if(state == 3) begin tx_buf <= reg_addr; state <= 4; end else if(state == 5) begin tx_buf <= reg_data; state <= 6; end else state <= 8; end else if(cnt == CNT_MAX/2) scl <= 1; end
                8: begin cnt <= cnt + 1; sda_en <= 1; if(cnt < CNT_MAX/2) begin sda_out <= 0; scl <= 1; end else if(cnt < CNT_MAX) sda_out <= 1; else begin state <= 0; done <= 1; end end
            endcase
        end
    end
endmodule