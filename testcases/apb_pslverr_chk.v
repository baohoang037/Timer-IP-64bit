// apb_pslverr_chk : illegal accesses assert pslverr
task run_test;
    begin
        $display("---- apb_pslverr_chk ----");
        // normal write : no pslverr
        apb_write(12'h0C,32'h0000_0001,4'hF); expect("no pslverr on legal write", (slverr_o===1'b0));
        // illegal div_val (>8) -> pslverr, write rejected
        apb_write(12'h00,{20'h0,4'hF,6'h0,1'b0,1'b0},4'hF); expect("pslverr illegal div_val", (slverr_o===1'b1));
        apb_read (12'h00); check("TCR unchanged after illegal div", rdata_o, 32'h0000_0100);
        // change div while running -> pslverr
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b1,1'b1},4'hF); // start div_val=2 (legal)
        apb_write(12'h00,{20'h0,4'h3,6'h0,1'b1,1'b1},4'hF); expect("pslverr div_val-chg-run", (slverr_o===1'b1));
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b0,1'b1},4'hF); expect("pslverr div_en-chg-run", (slverr_o===1'b1));
        apb_write(12'h00,{20'h0,4'h2,6'h0,1'b1,1'b0},4'hF); // stop (keep div)
        apb_write(12'h00,32'h0,4'hF);
        apb_write(12'h0C,32'h0,4'hF);
    end
endtask
