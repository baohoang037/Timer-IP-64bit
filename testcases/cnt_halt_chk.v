// cnt_halt_chk : halt freezes counter only when dbg_mode & halt_reg
task run_test;
    begin
        $display("---- cnt_halt_chk ----");
        // dbg_mode=0 : halt_reg has no effect, halt_ack stays 0
        dbg_mode = 1'b0;
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h00,32'h0000_0001,4'hF);          // run full speed
        apb_write(12'h1C,32'h0000_0001,4'hF);          // halt_reg=1 but dbg_mode=0
        repeat (6) @(negedge clk);
        apb_read(12'h1C); expect("halt_ack=0 when dbg_mode=0", (rdata_o[1]===1'b0));
        apb_read(12'h04); tmpa=rdata_o; repeat(10) @(negedge clk); apb_read(12'h04);
        expect("counter runs when dbg_mode=0", (rdata_o > tmpa));
        apb_write(12'h1C,32'h0000_0000,4'hF);
        apb_write(12'h00,32'h0000_0000,4'hF);

        // dbg_mode=1 : halt_reg=1 freezes the counter, halt_ack=1
        dbg_mode = 1'b1;
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h00,32'h0000_0001,4'hF);          // run
        repeat (6) @(negedge clk);
        apb_write(12'h1C,32'h0000_0001,4'hF);          // halt_reg=1
        repeat (4) @(negedge clk);
        apb_read(12'h1C); expect("halt_ack=1 when halted", (rdata_o[1]===1'b1));
        apb_read(12'h04); tmpa=rdata_o; repeat(10) @(negedge clk); apb_read(12'h04);
        expect("counter frozen while halted", (rdata_o === tmpa));
        // release halt -> resumes
        apb_write(12'h1C,32'h0000_0000,4'hF);
        repeat (3) @(negedge clk);
        apb_read(12'h04); tmpa=rdata_o; repeat(10) @(negedge clk); apb_read(12'h04);
        expect("counter resumes after halt clear", (rdata_o > tmpa));
        apb_write(12'h00,32'h0000_0000,4'hF);
        dbg_mode = 1'b0;
    end
endtask
