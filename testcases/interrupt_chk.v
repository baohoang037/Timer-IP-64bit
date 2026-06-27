// interrupt_chk : normal assert, mask via int_en, manual set (int_st independent of int_en),
//                 set-wins-over-clear, write-1-to-clear, write-0 no effect
task run_test;
    integer i;
    begin
        $display("---- interrupt_chk ----");
        // ===== normal mode =====
        apb_write(12'h0C,32'h0000_00FF,4'hF);  // TCMP0=255
        apb_write(12'h10,32'h0000_0000,4'hF);  // TCMP1=0
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h14,32'h0000_0001,4'hF);  // int_en=1
        apb_write(12'h00,32'h0000_0001,4'hF);  // timer_en=1 full speed
        i=0; while (tim_int!==1'b1 && i<400) begin @(negedge clk); i=i+1; end
        check("normal: tim_int asserted", tim_int, 1'b1);
        apb_read(12'h18); check("normal: TISR=1", rdata_o[0], 1'b1);
        // mask: int_en=0 -> tim_int=0, pending bit kept
        apb_write(12'h14,32'h0000_0000,4'hF); check("mask: tim_int=0", tim_int, 1'b0);
        apb_read(12'h18); check("mask: TISR kept=1", rdata_o[0], 1'b1);
        // re-enable -> tim_int asserts again
        apb_write(12'h14,32'h0000_0001,4'hF); check("re-enable: tim_int=1", tim_int, 1'b1);
        // W1C while cnt>cmp -> clears
        apb_write(12'h18,32'h0000_0001,4'hF);
        apb_read(12'h18); check("W1C clears pending", rdata_o[0], 1'b0);
        check("W1C: tim_int=0", tim_int, 1'b0);
        apb_write(12'h00,32'h0000_0000,4'hF);  // stop

        // ===== manual mode (counter stopped, cnt forced via TDR0) =====
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h14,32'h0000_0000,4'hF);  // int_en=0
        apb_write(12'h04,32'h0000_00FF,4'hF);  // cnt=255==cmp
        @(negedge clk);
        check("manual: tim_int=0 (int_en=0)", tim_int, 1'b0);
        apb_read(12'h18); check("manual: TISR=1 regardless int_en", rdata_o[0], 1'b1);
        apb_write(12'h14,32'h0000_0001,4'hF);  // enable
        check("manual: tim_int=1 after enable", tim_int, 1'b1);
        // W1C while match still true -> SET wins, pending kept
        apb_write(12'h18,32'h0000_0001,4'hF);
        apb_read(12'h18); check("manual: set>clr keeps pending", rdata_o[0], 1'b1);
        // move cnt off cmp, then W1C clears
        apb_write(12'h04,32'h0000_00FE,4'hF);
        apb_write(12'h18,32'h0000_0001,4'hF);
        apb_read(12'h18); check("manual: cleared after match=0", rdata_o[0], 1'b0);
        // write 0 to TISR has no effect (re-arm match first)
        apb_write(12'h04,32'h0000_00FF,4'hF); @(negedge clk);
        apb_write(12'h18,32'h0000_0000,4'hF);
        apb_read(12'h18); check("W0 to TISR: no effect", rdata_o[0], 1'b1);
        // cleanup
        apb_write(12'h14,32'h0000_0000,4'hF);
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h0C,32'h0,4'hF); apb_write(12'h10,32'h0,4'hF);
    end
endtask
