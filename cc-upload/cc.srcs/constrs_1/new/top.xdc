# 时钟和复位
set_property PACKAGE_PIN Y18 [get_ports clk_50m]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50m]
set_property PACKAGE_PIN B21 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# 测试灯
set_property PACKAGE_PIN M22 [get_ports led0]
set_property IOSTANDARD LVCMOS33 [get_ports led0]

# 音频引脚
set_property PACKAGE_PIN M13 [get_ports i2c_scl]
set_property PACKAGE_PIN M16 [get_ports i2c_sda]
set_property PULLUP true [get_ports i2c_sda]
set_property PACKAGE_PIN U20 [get_ports i2s_bclk]
set_property PACKAGE_PIN W20 [get_ports i2s_lrck]
set_property PACKAGE_PIN A20 [get_ports i2s_din]
set_property IOSTANDARD LVCMOS33 [get_ports {i2c_scl i2c_sda i2s_bclk i2s_lrck i2s_din}]

# TFT 屏幕引脚
set_property PACKAGE_PIN AB20 [get_ports tft_clk]
set_property PACKAGE_PIN AB22 [get_ports tft_de]
set_property PACKAGE_PIN V19  [get_ports tft_hs]
set_property PACKAGE_PIN Y19  [get_ports tft_vs]
set_property PACKAGE_PIN AB21 [get_ports tft_pwm]

set_property PACKAGE_PIN N14 [get_ports {tft_r[4]}]
set_property PACKAGE_PIN P16 [get_ports {tft_r[3]}]
set_property PACKAGE_PIN R17 [get_ports {tft_r[2]}]
set_property PACKAGE_PIN N15 [get_ports {tft_r[1]}]
set_property PACKAGE_PIN L6  [get_ports {tft_r[0]}]

set_property PACKAGE_PIN T18 [get_ports {tft_g[5]}]
set_property PACKAGE_PIN N17 [get_ports {tft_g[4]}]
set_property PACKAGE_PIN P17 [get_ports {tft_g[3]}]
set_property PACKAGE_PIN P15 [get_ports {tft_g[2]}]
set_property PACKAGE_PIN R16 [get_ports {tft_g[1]}]
set_property PACKAGE_PIN N13 [get_ports {tft_g[0]}]

set_property PACKAGE_PIN U17 [get_ports {tft_b[4]}]
set_property PACKAGE_PIN U18 [get_ports {tft_b[3]}]
set_property PACKAGE_PIN P14 [get_ports {tft_b[2]}]
set_property PACKAGE_PIN R14 [get_ports {tft_b[1]}]
set_property PACKAGE_PIN R18 [get_ports {tft_b[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {tft_clk tft_de tft_hs tft_vs tft_pwm tft_r[*] tft_g[*] tft_b[*]}]