// apb_protocol_chk : handshake correctness (pready low when idle / setup, data only in access)
task run_test;
    begin
        $display("---- apb_protocol_chk ----");
        // idle: pready must be 0
        @(negedge clk); expect("pready=0 in idle", (pready===1'b0));
        // SETUP phase: drive psel=1, penable=0 -> pready must still be 0
        @(negedge clk); psel=1; pwrite=1; penable=0; paddr=12'h0C; pwdata=32'hA5A5_5A5A; pstrb=4'hF;
        @(negedge clk); expect("pready=0 in setup", (pready===1'b0));
        // ACCESS phase
        penable=1;
        @(posedge clk); while (pready!==1'b1) @(posedge clk);
        slverr_o=pslverr;
        @(negedge clk); psel=0; penable=0; pwrite=0; pstrb=4'h0;
        // verify the write committed (data only takes effect in access phase)
        apb_read(12'h0C); check("protocol write committed", rdata_o, 32'hA5A5_5A5A);
        // back-to-back to exercise access->setup transition
        apb_write2(12'h0C,32'h0000_0001, 12'h10,32'h0000_0002, 4'hF);
        apb_read (12'h0C); check("b2b TCMP0", rdata_o, 32'h0000_0001);
        apb_read (12'h10); check("b2b TCMP1", rdata_o, 32'h0000_0002);
        apb_write(12'h0C,32'h0,4'hF); apb_write(12'h10,32'h0,4'hF);
    end
endtask
