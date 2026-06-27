// reg_1hot_chk : 0x55/0xAA patterns, verify no bit-bleed between registers
task run_test;
    begin
        $display("---- reg_1hot_chk ----");
        apb_write(12'h0C,32'h5555_5555,4'hF); // TCMP0
        apb_write(12'h10,32'hAAAA_AAAA,4'hF); // TCMP1
        apb_read (12'h0C); check("TCMP0=55555555 (no bleed)", rdata_o,32'h5555_5555);
        apb_read (12'h10); check("TCMP1=AAAAAAAA (no bleed)", rdata_o,32'hAAAA_AAAA);
        apb_write(12'h04,32'hAAAA_AAAA,4'hF); // TDR0
        apb_write(12'h08,32'h5555_5555,4'hF); // TDR1
        apb_read (12'h04); check("TDR0=AAAAAAAA", rdata_o,32'hAAAA_AAAA);
        apb_read (12'h08); check("TDR1=55555555", rdata_o,32'h5555_5555);
        apb_write(12'h0C,32'h0,4'hF); apb_write(12'h10,32'h0,4'hF);
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
    end
endtask
