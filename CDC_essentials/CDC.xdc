# CPU Clock (105 MHz = 9.524 ns period)
create_clock -period 15.524 -name clk_cpu [get_ports clk_cpu]

# CNN Clock (150 MHz = 6.666 ns period)
create_clock -period 15.666 -name clk_cnn [get_ports clk_cnn]


set_clock_groups -asynchronous -group [get_clocks clk_cpu] -group [get_clocks clk_cnn]