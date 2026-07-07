`timescale 1ns / 1ps

module universal_cdc_bridge (
    input  logic cpu_clk, cpu_rst_n,
    input  logic cpu_start_cmd,     // 1-cycle pulse from CPU MMIO
    output logic cpu_cnn_done_int,  // 1-cycle pulse to CPU Interrupt

    input  logic cnn_clk, cnn_rst_n,
    output logic cnn_start_safe,    // 1-cycle pulse to CNN core_start
    input  logic cnn_core_done      // 1-cycle pulse from CNN
);

    
    // BRIDGE 1: CPU START -> CNN (Slow to Fast)
    logic cpu_toggle;
    always_ff @(posedge cpu_clk or negedge cpu_rst_n) begin
        if (!cpu_rst_n) cpu_toggle <= 1'b0;
        else if (cpu_start_cmd) cpu_toggle <= ~cpu_toggle; 
    end

    (* ASYNC_REG = "TRUE" *) logic start_sync_0, start_sync_1;
    logic start_sync_2;
    always_ff @(posedge cnn_clk or negedge cnn_rst_n) begin
        if (!cnn_rst_n) {start_sync_0, start_sync_1, start_sync_2} <= 3'b0;
        else begin
            start_sync_0 <= cpu_toggle;
            start_sync_1 <= start_sync_0;
            start_sync_2 <= start_sync_1;
        end
    end
    assign cnn_start_safe = (start_sync_1 ^ start_sync_2);

    
    // BRIDGE 2: CNN DONE -> CPU (Fast to Slow)
    logic cnn_toggle;
    always_ff @(posedge cnn_clk or negedge cnn_rst_n) begin
        if (!cnn_rst_n) cnn_toggle <= 1'b0;
        else if (cnn_core_done) cnn_toggle <= ~cnn_toggle; 
    end

    (* ASYNC_REG = "TRUE" *) logic done_sync_0, done_sync_1;
    logic done_sync_2;
    always_ff @(posedge cpu_clk or negedge cpu_rst_n) begin
        if (!cpu_rst_n) {done_sync_0, done_sync_1, done_sync_2} <= 3'b0;
        else begin
            done_sync_0 <= cnn_toggle;
            done_sync_1 <= done_sync_0;
            done_sync_2 <= done_sync_1;
        end
    end
    assign cpu_cnn_done_int = (done_sync_1 ^ done_sync_2);

endmodule