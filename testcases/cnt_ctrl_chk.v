// cnt_ctrl_chk : div_en/div_val control the counting rate
task run_test;
    begin
        $display("---- cnt_ctrl_chk ----");
        // sweep div_val 0..8 (timer stopped, legal) -> toggles div_val field
        apb_write(12'h00,32'h0,4'hF);
        // div_val = 0..8
        apb_write(12'h00,{20'h0,4'h0,6'h0,1'b1,1'b0},4'hF); apb_read(12'h00);
        apb_write(12'h00,{20'h0,4'h1,6'h0,1'b1,1'b0},4'hF); apb_read(12'h00);
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b1,1'b0},4'hF); apb_read(12'h00);
        apb_write(12'h00,{20'h0,4'h4,6'h0,1'b1,1'b0},4'hF); apb_read(12'h00);
        apb_write(12'h00,{20'h0,4'h8,6'h0,1'b1,1'b0},4'hF); apb_read(12'h00);
        apb_write(12'h00,32'h0,4'hF);

        // full-speed delta over a window
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h00,32'h0000_0001,4'hF);          // div_en=0
        apb_read(12'h04); tmpa=rdata_o; repeat(64) @(negedge clk); apb_read(12'h04); tmpb=rdata_o;
        tmpa = tmpb - tmpa;                            // delta_full
        apb_write(12'h00,32'h0000_0000,4'hF);

        // divided (div_val=2 -> 1/4 speed) delta over same window
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b1,1'b0},4'hF); // set div first (stopped)
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b1,1'b1},4'hF); // start
        apb_read(12'h04); tmpb=rdata_o; repeat(64) @(negedge clk); apb_read(12'h04);
        tmpb = rdata_o - tmpb;                         // delta_div
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b1,1'b0},4'hF); // stop keep div
        apb_write(12'h00,32'h0,4'hF);
        expect("divided slower than full-speed", (tmpb < tmpa));

        // long count div_val=8 to sweep internal pre-counter full range (toggle closure)
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h00,{20'h0,4'h8,6'h0,1'b1,1'b0},4'hF);
        apb_write(12'h00,{20'h0,4'h8,6'h0,1'b1,1'b1},4'hF);
        repeat (600) @(negedge clk);
        apb_write(12'h00,{20'h0,4'h8,6'h0,1'b1,1'b0},4'hF);
        apb_write(12'h00,32'h0,4'hF);
    end
endtask
