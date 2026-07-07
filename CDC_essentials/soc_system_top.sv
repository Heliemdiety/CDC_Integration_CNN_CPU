`timescale 1ns / 1ps

module system_top (
    // Independent Clock Domains
    input  logic        clk_cpu,
    input  logic        rst_cpu_n,
    
    input  logic        clk_cnn,
    input  logic        rst_cnn_n,

    // =========================================================================
    // CPU AXI4 MASTER 0: INSTRUCTION CACHE BUS
    // =========================================================================
    output logic [31:0] cpu_m_axi_if_araddr,
    output logic [7:0]  cpu_m_axi_if_arlen,
    output logic [2:0]  cpu_m_axi_if_arsize,
    output logic [1:0]  cpu_m_axi_if_arburst,
    output logic        cpu_m_axi_if_arvalid,
    input  logic        cpu_m_axi_if_arready,
    input  logic [31:0] cpu_m_axi_if_rdata,
    input  logic [1:0]  cpu_m_axi_if_rresp,
    input  logic        cpu_m_axi_if_rlast,
    input  logic        cpu_m_axi_if_rvalid,
    output logic        cpu_m_axi_if_rready,

    // =========================================================================
    // CPU AXI4 MASTER 1: DATA CACHE BUS
    // =========================================================================
    output logic [31:0] cpu_m_axi_mem_awaddr,
    output logic [7:0]  cpu_m_axi_mem_awlen,
    output logic [2:0]  cpu_m_axi_mem_awsize,
    output logic [1:0]  cpu_m_axi_mem_awburst,
    output logic        cpu_m_axi_mem_awvalid,
    input  logic        cpu_m_axi_mem_awready,
    output logic [31:0] cpu_m_axi_mem_wdata,
    output logic [3:0]  cpu_m_axi_mem_wstrb,
    output logic        cpu_m_axi_mem_wlast,
    output logic        cpu_m_axi_mem_wvalid,
    input  logic        cpu_m_axi_mem_wready,
    input  logic [1:0]  cpu_m_axi_mem_bresp,
    input  logic        cpu_m_axi_mem_bvalid,
    output logic        cpu_m_axi_mem_bready,
    output logic [31:0] cpu_m_axi_mem_araddr,
    output logic [7:0]  cpu_m_axi_mem_arlen,
    output logic [2:0]  cpu_m_axi_mem_arsize,
    output logic [1:0]  cpu_m_axi_mem_arburst,
    output logic        cpu_m_axi_mem_arvalid,
    input  logic        cpu_m_axi_mem_arready,
    input  logic [31:0] cpu_m_axi_mem_rdata,
    input  logic [1:0]  cpu_m_axi_mem_rresp,
    input  logic        cpu_m_axi_mem_rlast,
    input  logic        cpu_m_axi_mem_rvalid,
    output logic        cpu_m_axi_mem_rready,

    // =========================================================================
    // CNN AXI4 MASTER: MEMORY BUS
    // =========================================================================
    output logic [31:0] cnn_m_axi_araddr,
    output logic [7:0]  cnn_m_axi_arlen,
    output logic [2:0]  cnn_m_axi_arsize,
    output logic [1:0]  cnn_m_axi_arburst,
    output logic        cnn_m_axi_arvalid,
    input  logic        cnn_m_axi_arready,
    input  logic [31:0] cnn_m_axi_rdata,
    input  logic [1:0]  cnn_m_axi_rresp,
    input  logic        cnn_m_axi_rlast,
    input  logic        cnn_m_axi_rvalid,
    output logic        cnn_m_axi_rready,
    output logic [31:0] cnn_m_axi_awaddr,
    output logic [7:0]  cnn_m_axi_awlen,
    output logic [2:0]  cnn_m_axi_awsize,
    output logic [1:0]  cnn_m_axi_awburst,
    output logic        cnn_m_axi_awvalid,
    input  logic        cnn_m_axi_awready,
    output logic [31:0] cnn_m_axi_wdata,
    output logic [3:0]  cnn_m_axi_wstrb,
    output logic        cnn_m_axi_wlast,
    output logic        cnn_m_axi_wvalid,
    input  logic        cnn_m_axi_wready,
    input  logic [1:0]  cnn_m_axi_bresp,
    input  logic        cnn_m_axi_bvalid,
    output logic        cnn_m_axi_bready
);

    // ==========================================
    // Internal Routing Wires
    // ==========================================
    logic cpu_start_cmd_raw; 
    logic cnn_done_raw;      
    logic cnn_start_safe;
    logic cpu_interrupt_safe;

    // Tie off the CNN's manual CPU CSR bus since the layer_sequencer drives it internally
    // (Or route them to top if you plan to drive them from TB, but 0 is safe here)
    logic        cnn_cpu_wr_en = 1'b0;
    logic [7:0]  cnn_cpu_wr_addr = 8'd0;
    logic [31:0] cnn_cpu_wr_data = 32'd0;
    logic        cnn_cpu_rd_en = 1'b0;
    logic [7:0]  cnn_cpu_rd_addr = 8'd0;
    logic [31:0] cnn_cpu_rd_data; // Unconnected output

    // ==========================================
    // The CDC Bridge (Toggle Synchronizer)
    // ==========================================
    universal_cdc_bridge u_cdc (
        .cpu_clk          (clk_cpu),
        .cpu_rst_n        (rst_cpu_n),
        .cpu_start_cmd    (cpu_start_cmd_raw),
        .cpu_cnn_done_int (cpu_interrupt_safe),

        .cnn_clk          (clk_cnn),
        .cnn_rst_n        (rst_cnn_n),
        .cnn_start_safe   (cnn_start_safe),
        .cnn_core_done    (cnn_done_raw)
    );

    // ==========================================
    // The CPU Core
    // ==========================================
    riscv_core_top u_cpu (
        .clk                 (clk_cpu),
        .rst_n               (rst_cpu_n),
        
        // Instruction Bus
        .m_axi_if_araddr     (cpu_m_axi_if_araddr),
        .m_axi_if_arlen      (cpu_m_axi_if_arlen),
        .m_axi_if_arsize     (cpu_m_axi_if_arsize),
        .m_axi_if_arburst    (cpu_m_axi_if_arburst),
        .m_axi_if_arvalid    (cpu_m_axi_if_arvalid),
        .m_axi_if_arready    (cpu_m_axi_if_arready),
        .m_axi_if_rdata      (cpu_m_axi_if_rdata),
        .m_axi_if_rresp      (cpu_m_axi_if_rresp),
        .m_axi_if_rlast      (cpu_m_axi_if_rlast),
        .m_axi_if_rvalid     (cpu_m_axi_if_rvalid),
        .m_axi_if_rready     (cpu_m_axi_if_rready),

        // Data Bus
        .m_axi_mem_awaddr    (cpu_m_axi_mem_awaddr),
        .m_axi_mem_awlen     (cpu_m_axi_mem_awlen),
        .m_axi_mem_awsize    (cpu_m_axi_mem_awsize),
        .m_axi_mem_awburst   (cpu_m_axi_mem_awburst),
        .m_axi_mem_awvalid   (cpu_m_axi_mem_awvalid),
        .m_axi_mem_awready   (cpu_m_axi_mem_awready),
        .m_axi_mem_wdata     (cpu_m_axi_mem_wdata),
        .m_axi_mem_wstrb     (cpu_m_axi_mem_wstrb),
        .m_axi_mem_wlast     (cpu_m_axi_mem_wlast),
        .m_axi_mem_wvalid    (cpu_m_axi_mem_wvalid),
        .m_axi_mem_wready    (cpu_m_axi_mem_wready),
        .m_axi_mem_bresp     (cpu_m_axi_mem_bresp),
        .m_axi_mem_bvalid    (cpu_m_axi_mem_bvalid),
        .m_axi_mem_bready    (cpu_m_axi_mem_bready),
        .m_axi_mem_araddr    (cpu_m_axi_mem_araddr),
        .m_axi_mem_arlen     (cpu_m_axi_mem_arlen),
        .m_axi_mem_arsize    (cpu_m_axi_mem_arsize),
        .m_axi_mem_arburst   (cpu_m_axi_mem_arburst),
        .m_axi_mem_arvalid   (cpu_m_axi_mem_arvalid),
        .m_axi_mem_arready   (cpu_m_axi_mem_arready),
        .m_axi_mem_rdata     (cpu_m_axi_mem_rdata),
        .m_axi_mem_rresp     (cpu_m_axi_mem_rresp),
        .m_axi_mem_rlast     (cpu_m_axi_mem_rlast),
        .m_axi_mem_rvalid    (cpu_m_axi_mem_rvalid),
        .m_axi_mem_rready    (cpu_m_axi_mem_rready),

        // CDC
        .cnn_start_cmd       (cpu_start_cmd_raw),
        .ext_interrupt       (cpu_interrupt_safe)
    );

    // ==========================================
    // The CNN Accelerator
    // ==========================================
    cnn_top #(
        .AXI_ADDR_WIDTH(32),
        .AXI_DATA_WIDTH(32),
        .BRAM_ADDR_WIDTH(10)
    ) u_cnn (
        .clk             (clk_cnn),
        .rst_n           (rst_cnn_n),
        
        // CSR Bus (Tied off for now)
        .cpu_wr_en       (cnn_cpu_wr_en),
        .cpu_wr_addr     (cnn_cpu_wr_addr),
        .cpu_wr_data     (cnn_cpu_wr_data),
        .cpu_rd_en       (cnn_cpu_rd_en),
        .cpu_rd_addr     (cnn_cpu_rd_addr),
        .cpu_rd_data     (cnn_cpu_rd_data),
        
        // Sequencer Triggers
        .seq_start       (cnn_start_safe),
        .seq_done        (cnn_done_raw),
        .core_busy       (),
        .core_done       (),

        // AXI Bus
        .m_axi_araddr    (cnn_m_axi_araddr),
        .m_axi_arlen     (cnn_m_axi_arlen),
        .m_axi_arsize    (cnn_m_axi_arsize),
        .m_axi_arburst   (cnn_m_axi_arburst),
        .m_axi_arvalid   (cnn_m_axi_arvalid),
        .m_axi_arready   (cnn_m_axi_arready),
        .m_axi_rdata     (cnn_m_axi_rdata),
        .m_axi_rresp     (cnn_m_axi_rresp),
        .m_axi_rlast     (cnn_m_axi_rlast),
        .m_axi_rvalid    (cnn_m_axi_rvalid),
        .m_axi_rready    (cnn_m_axi_rready),
        .m_axi_awaddr    (cnn_m_axi_awaddr),
        .m_axi_awlen     (cnn_m_axi_awlen),
        .m_axi_awsize    (cnn_m_axi_awsize),
        .m_axi_awburst   (cnn_m_axi_awburst),
        .m_axi_awvalid   (cnn_m_axi_awvalid),
        .m_axi_awready   (cnn_m_axi_awready),
        .m_axi_wdata     (cnn_m_axi_wdata),
        .m_axi_wstrb     (cnn_m_axi_wstrb),
        .m_axi_wlast     (cnn_m_axi_wlast),
        .m_axi_wvalid    (cnn_m_axi_wvalid),
        .m_axi_wready    (cnn_m_axi_wready),
        .m_axi_bresp     (cnn_m_axi_bresp),
        .m_axi_bvalid    (cnn_m_axi_bvalid),
        .m_axi_bready    (cnn_m_axi_bready)
    );

endmodule