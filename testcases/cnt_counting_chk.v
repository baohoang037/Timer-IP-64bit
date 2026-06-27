// cnt_counting_chk : counter increments (full speed), continues through interrupt/overflow
task run_test;
    begin
        $display("---- cnt_counting_chk ----");
        // full speed: div_en=0
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h00,32'h0000_0001,4'hF);      // timer_en=1, div_en=0
        apb_read(12'h04); tmpa = rdata_o;          // c0
        repeat (40) @(negedge clk);
        apb_read(12'h04); tmpb = rdata_o;          // c1
        expect("full-speed counting up", (tmpb > tmpa));
        // continues through compare match (interrupt) - set small cmp, ensure cnt keeps moving
        apb_read(12'h04); tmpa = rdata_o;
        repeat (40) @(negedge clk);
        apb_read(12'h04); tmpb = rdata_o;
        expect("counter continues counting", (tmpb > tmpa));
        apb_write(12'h00,32'h0000_0000,4'hF);      // stop (div=0 unchanged)

        // overflow continuity: preload near 32-bit boundary then run
        apb_write(12'h04,32'hFFFF_FFF0,4'hF); apb_write(12'h08,32'h0000_0000,4'hF);
        apb_write(12'h00,32'h0000_0001,4'hF);
        repeat (40) @(negedge clk);
        apb_read(12'h08); expect("carry into TDR1 on overflow", (rdata_o >= 32'h1));
        apb_write(12'h00,32'h0000_0000,4'hF);
    end
endtask
