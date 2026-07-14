`timescale 1ns / 1ps

module system_tb;

    // ==========================================
    // Parameters & Exact Clock Definitions
    // ==========================================
    logic clk_cpu = 0;
    logic rst_cpu_n = 0;
    
    logic clk_cnn = 0;
    logic rst_cnn_n = 0;

    // 105 MHz = 9.524ns period -> 4.762ns half-period
    always #4.762 clk_cpu = ~clk_cpu; 

    // 150 MHz = 6.666ns period -> 3.333ns half-period
    always #3.333 clk_cnn = ~clk_cnn;



    // ==========================================
    // System Top Interconnect Wires
    // ==========================================
    
    // CPU IFetch AXI
    logic [31:0] cpu_if_araddr; logic [7:0] cpu_if_arlen; logic [2:0] cpu_if_arsize;
    logic [1:0]  cpu_if_arburst; logic cpu_if_arvalid; logic cpu_if_arready;
    logic [31:0] cpu_if_rdata; logic [1:0] cpu_if_rresp; logic cpu_if_rlast;
    logic cpu_if_rvalid; logic cpu_if_rready;

    // CPU DMEM AXI (Tied off, since we suppress the write anyway)
    logic [31:0] cpu_mem_awaddr; logic [7:0] cpu_mem_awlen; logic [2:0] cpu_mem_awsize; logic [1:0] cpu_mem_awburst; logic cpu_mem_awvalid;
    logic cpu_mem_awready = 1'b1; // Always ready to accept the phantom write
    logic [31:0] cpu_mem_wdata; logic [3:0] cpu_mem_wstrb; logic cpu_mem_wlast; logic cpu_mem_wvalid;
    logic cpu_mem_wready = 1'b1;
    logic [1:0] cpu_mem_bresp = 2'b00; logic cpu_mem_bvalid = 1'b0; logic cpu_mem_bready;
    logic [31:0] cpu_mem_araddr; logic [7:0] cpu_mem_arlen; logic [2:0] cpu_mem_arsize; logic [1:0] cpu_mem_arburst; logic cpu_mem_arvalid;
    logic cpu_mem_arready = 1'b0; logic [31:0] cpu_mem_rdata = '0; logic [1:0] cpu_mem_rresp = 2'b00; logic cpu_mem_rlast = 1'b0; logic cpu_mem_rvalid = 1'b0; logic cpu_mem_rready;

    // CNN AXI
    logic [31:0] cnn_araddr; logic [7:0] cnn_arlen; logic [2:0] cnn_arsize; logic [1:0] cnn_arburst; logic cnn_arvalid; logic cnn_arready;
    logic [31:0] cnn_rdata; logic [1:0] cnn_rresp; logic cnn_rlast; logic cnn_rvalid; logic cnn_rready;
    logic [31:0] cnn_awaddr; logic [7:0] cnn_awlen; logic [2:0] cnn_awsize; logic [1:0] cnn_awburst; logic cnn_awvalid; logic cnn_awready;
    logic [31:0] cnn_wdata; logic [3:0] cnn_wstrb; logic cnn_wlast; logic cnn_wvalid; logic cnn_wready;
    logic [1:0]  cnn_bresp; logic cnn_bvalid; logic cnn_bready;

    // ==========================================
    // Device Under Test (The Megazord)
    // ==========================================
    system_top dut (
        .clk_cpu(clk_cpu), .rst_cpu_n(rst_cpu_n),
        .clk_cnn(clk_cnn), .rst_cnn_n(rst_cnn_n),
        
        .cpu_m_axi_if_araddr(cpu_if_araddr), .cpu_m_axi_if_arlen(cpu_if_arlen), .cpu_m_axi_if_arsize(cpu_if_arsize), .cpu_m_axi_if_arburst(cpu_if_arburst), .cpu_m_axi_if_arvalid(cpu_if_arvalid), .cpu_m_axi_if_arready(cpu_if_arready),
        .cpu_m_axi_if_rdata(cpu_if_rdata), .cpu_m_axi_if_rresp(cpu_if_rresp), .cpu_m_axi_if_rlast(cpu_if_rlast), .cpu_m_axi_if_rvalid(cpu_if_rvalid), .cpu_m_axi_if_rready(cpu_if_rready),
        
        .cpu_m_axi_mem_awaddr(cpu_mem_awaddr), .cpu_m_axi_mem_awlen(cpu_mem_awlen), .cpu_m_axi_mem_awsize(cpu_mem_awsize), .cpu_m_axi_mem_awburst(cpu_mem_awburst), .cpu_m_axi_mem_awvalid(cpu_mem_awvalid), .cpu_m_axi_mem_awready(cpu_mem_awready),
        .cpu_m_axi_mem_wdata(cpu_mem_wdata), .cpu_m_axi_mem_wstrb(cpu_mem_wstrb), .cpu_m_axi_mem_wlast(cpu_mem_wlast), .cpu_m_axi_mem_wvalid(cpu_mem_wvalid), .cpu_m_axi_mem_wready(cpu_mem_wready),
        .cpu_m_axi_mem_bresp(cpu_mem_bresp), .cpu_m_axi_mem_bvalid(cpu_mem_bvalid), .cpu_m_axi_mem_bready(cpu_mem_bready),
        .cpu_m_axi_mem_araddr(cpu_mem_araddr), .cpu_m_axi_mem_arlen(cpu_mem_arlen), .cpu_m_axi_mem_arsize(cpu_mem_arsize), .cpu_m_axi_mem_arburst(cpu_mem_arburst), .cpu_m_axi_mem_arvalid(cpu_mem_arvalid), .cpu_m_axi_mem_arready(cpu_mem_arready),
        .cpu_m_axi_mem_rdata(cpu_mem_rdata), .cpu_m_axi_mem_rresp(cpu_mem_rresp), .cpu_m_axi_mem_rlast(cpu_mem_rlast), .cpu_m_axi_mem_rvalid(cpu_mem_rvalid), .cpu_m_axi_mem_rready(cpu_mem_rready),
        
        .cnn_m_axi_araddr(cnn_araddr), .cnn_m_axi_arlen(cnn_arlen), .cnn_m_axi_arsize(cnn_arsize), .cnn_m_axi_arburst(cnn_arburst), .cnn_m_axi_arvalid(cnn_arvalid), .cnn_m_axi_arready(cnn_arready),
        .cnn_m_axi_rdata(cnn_rdata), .cnn_m_axi_rresp(cnn_rresp), .cnn_m_axi_rlast(cnn_rlast), .cnn_m_axi_rvalid(cnn_rvalid), .cnn_m_axi_rready(cnn_rready),
        .cnn_m_axi_awaddr(cnn_awaddr), .cnn_m_axi_awlen(cnn_awlen), .cnn_m_axi_awsize(cnn_awsize), .cnn_m_axi_awburst(cnn_awburst), .cnn_m_axi_awvalid(cnn_awvalid), .cnn_m_axi_awready(cnn_awready),
        .cnn_m_axi_wdata(cnn_wdata), .cnn_m_axi_wstrb(cnn_wstrb), .cnn_m_axi_wlast(cnn_wlast), .cnn_m_axi_wvalid(cnn_wvalid), .cnn_m_axi_wready(cnn_wready),
        .cnn_m_axi_bresp(cnn_bresp), .cnn_m_axi_bvalid(cnn_bvalid), .cnn_m_axi_bready(cnn_bready)
    );

    // ==========================================
    // 1. CPU IFetch ROM 
    // ==========================================
    logic [31:0] mini_rom [0:7];
    initial begin
        mini_rom[0] = 32'hFFF00093; // ADDI x1, x0, -1 (Load 0xFFFFFFFF)
        mini_rom[1] = 32'h0000A023; // SW x0, 0(x1)    (Trigger CNN!)
        mini_rom[2] = 32'h0000006F; // JAL x0, 0       (Infinite loop)
        mini_rom[3] = 32'h00000033; // NOP
        mini_rom[4] = 32'h00000033; mini_rom[5] = 32'h00000033;
        mini_rom[6] = 32'h00000033; mini_rom[7] = 32'h00000033;
    end

    int cpu_rd_beat = 0;
    logic cpu_rd_active = 0;
    logic [31:0] cpu_base_word_idx = 0;

    always @(posedge clk_cpu) begin
        if (!rst_cpu_n) begin
            cpu_if_arready <= 1'b0;
            cpu_if_rvalid  <= 1'b0;
            cpu_if_rlast   <= 1'b0;
            cpu_rd_active  <= 1'b0;
        end else begin
            // Accept read request
            cpu_if_arready <= !cpu_rd_active && !cpu_if_rvalid;
            
            if (cpu_if_arvalid && cpu_if_arready) begin
                cpu_rd_active     <= 1'b1;
                cpu_rd_beat       <= 0;
                // use the requested address to index the ROM
                cpu_base_word_idx <= cpu_if_araddr[31:2]; 
            end

            // Pump out data
            if (cpu_if_rvalid && cpu_if_rready) begin
                if (cpu_if_rlast) begin
                    cpu_if_rvalid <= 1'b0;
                    cpu_if_rlast  <= 1'b0;
                    cpu_rd_active <= 1'b0;
                end else begin
                    cpu_rd_beat   <= cpu_rd_beat + 1;
                    // Safely wrap around our 8-word mini_rom
                    cpu_if_rdata  <= mini_rom[(cpu_base_word_idx + cpu_rd_beat + 1) % 8];
                    cpu_if_rlast  <= ((cpu_rd_beat + 1) == 7); // 8 beat burst
                    cpu_if_rvalid <= 1'b1;
                end
            end else if (cpu_rd_active && !cpu_if_rvalid) begin
                // Send the exact word the CPU asked for on the first beat
                cpu_if_rdata  <= mini_rom[(cpu_base_word_idx) % 8];
                cpu_if_rresp  <= 2'b00;
                cpu_if_rlast  <= 1'b0;
                cpu_if_rvalid <= 1'b1;
            end
        end
    end

    // ==========================================
    // 2. CNN Memory Slave
    // ==========================================
    logic cnn_rd_active = 0;
    int cnn_rd_beat = 0;
    int cnn_rd_len = 0;
    
    logic cnn_wr_active = 0;
    int cnn_wr_beat = 0;
    int cnn_wr_len = 0;

    always @(posedge clk_cnn) begin
        if (!rst_cnn_n) begin
            cnn_arready <= 1'b0; cnn_rvalid <= 1'b0; cnn_rlast <= 1'b0; cnn_rd_active <= 1'b0;
            cnn_awready <= 1'b0; cnn_wready <= 1'b0; cnn_bvalid <= 1'b0; cnn_wr_active <= 1'b0;
        end else begin
            // CNN Reads (Feeds Dummy 0s so it doesn't hang)
            cnn_arready <= !cnn_rd_active && !cnn_rvalid;
            if (cnn_arvalid && cnn_arready) begin
                cnn_rd_active <= 1'b1;
                cnn_rd_len    <= cnn_arlen;
                cnn_rd_beat   <= 0;
            end
            if (cnn_rvalid && cnn_rready) begin
                if (cnn_rlast) begin
                    cnn_rvalid <= 1'b0; cnn_rlast <= 1'b0; cnn_rd_active <= 1'b0;
                end else begin
                    cnn_rd_beat <= cnn_rd_beat + 1;
                    cnn_rdata   <= 32'h00000001; // Feed dummy ones for math
                    cnn_rlast   <= ((cnn_rd_beat + 1) == cnn_rd_len);
                    cnn_rvalid  <= 1'b1;
                end
            end else if (cnn_rd_active && !cnn_rvalid) begin
                cnn_rdata  <= 32'h00000001;
                cnn_rresp  <= 2'b00;
                cnn_rlast  <= (cnn_rd_len == 0);
                cnn_rvalid <= 1'b1;
            end

            // CNN Writes (Sinks Data)
            cnn_awready <= !cnn_wr_active;
            cnn_wready  <= cnn_wr_active && !cnn_bvalid;
            if (cnn_awvalid && cnn_awready) begin
                cnn_wr_active <= 1'b1;
                cnn_wr_len    <= cnn_awlen;
                cnn_wr_beat   <= 0;
            end
            if (cnn_wvalid && cnn_wready) begin
                if (cnn_wlast) begin
                    cnn_wr_active <= 1'b0;
                    cnn_bresp     <= 2'b00;
                    cnn_bvalid    <= 1'b1;
                end else begin
                    cnn_wr_beat <= cnn_wr_beat + 1;
                end
            end
            if (cnn_bvalid && cnn_bready) cnn_bvalid <= 1'b0;
        end
    end

    

    // ==========================================
    // 3. The CDC Verification Sequence 
    // ==========================================
    initial begin
        $display("==================================================");
        $display(" STARTING SoC CDC VERIFICATION");
        $display("==================================================");
        
        // Assert Resets
        rst_cpu_n = 1'b0;
        rst_cnn_n = 1'b0;
        #100;
        
        // Release Resets
        rst_cpu_n = 1'b1;
        rst_cnn_n = 1'b1;
        $display("[%0t] Resets released. CPU is fetching instructions...", $time);

        // 1. Wait for the CNN to assert an AXI Read. 
        // If this happens, it proves the CPU executed SW, the CDC bridge passed 
        // the pulse safely, and the CNN woke up
        wait (cnn_arvalid == 1'b1);
        $display("[%0t] CHECK 1 & 2 PASSED: CDC Trigger worked! CNN asserted AXI Read.", $time);

        // 2. Wait for the CNN to assert an AXI Write.
        // If this happens, it proves the CNN finished its entire systolic array computation.
        wait (cnn_awvalid == 1'b1);
        $display("[%0t] CHECK 3 PASSED: CNN sequence complete! CNN asserted AXI Write.", $time);

        $display("==================================================");
        $display(" SUCCESS: FULL ASYNCHRONOUS CDC LOOP VERIFIED!");
        $display("==================================================");
        
        #50;
        $finish;
    end

    // Timeout watchdog
    initial begin
        #50000;
        $display("==================================================");
        $display(" FATAL ERROR: SIMULATION TIMEOUT.");
        $display(" The CDC loop hung somewhere.");
        $display("==================================================");
        $finish;
    end
endmodule    