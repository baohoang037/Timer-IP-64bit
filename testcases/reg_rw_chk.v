// reg_rw_chk : write/read-back patterns 0 / FFFFFFFF / 55555555 / AAAAAAAA
task run_test;
    begin
        $display("---- reg_rw_chk ----");
        // TCMP0 (full 32-bit RW)
        apb_write(12'h0C,32'h0000_0000,4'hF); apb_read(12'h0C); check("TCMP0=0",        rdata_o,32'h0000_0000);
        apb_write(12'h0C,32'hFFFF_FFFF,4'hF); apb_read(12'h0C); check("TCMP0=FFFFFFFF", rdata_o,32'hFFFF_FFFF);
        apb_write(12'h0C,32'h5555_5555,4'hF); apb_read(12'h0C); check("TCMP0=55555555", rdata_o,32'h5555_5555);
        apb_write(12'h0C,32'hAAAA_AAAA,4'hF); apb_read(12'h0C); check("TCMP0=AAAAAAAA", rdata_o,32'hAAAA_AAAA);
        // TCMP1
        apb_write(12'h10,32'h0000_0000,4'hF); apb_read(12'h10); check("TCMP1=0",        rdata_o,32'h0000_0000);
        apb_write(12'h10,32'hFFFF_FFFF,4'hF); apb_read(12'h10); check("TCMP1=FFFFFFFF", rdata_o,32'hFFFF_FFFF);
        apb_write(12'h10,32'h5555_5555,4'hF); apb_read(12'h10); check("TCMP1=55555555", rdata_o,32'h5555_5555);
        apb_write(12'h10,32'hAAAA_AAAA,4'hF); apb_read(12'h10); check("TCMP1=AAAAAAAA", rdata_o,32'hAAAA_AAAA);
        // TDR0/TDR1 (timer stopped -> cnt holds written value)
        apb_write(12'h04,32'hFFFF_FFFF,4'hF); apb_read(12'h04); check("TDR0=FFFFFFFF", rdata_o,32'hFFFF_FFFF);
        apb_write(12'h04,32'h5555_5555,4'hF); apb_read(12'h04); check("TDR0=55555555", rdata_o,32'h5555_5555);
        apb_write(12'h08,32'hFFFF_FFFF,4'hF); apb_read(12'h08); check("TDR1=FFFFFFFF", rdata_o,32'hFFFF_FFFF);
        apb_write(12'h08,32'hAAAA_AAAA,4'hF); apb_read(12'h08); check("TDR1=AAAAAAAA", rdata_o,32'hAAAA_AAAA);
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
        // TIER bit
        apb_write(12'h14,32'h0000_0001,4'hF); apb_read(12'h14); check("TIER=1", rdata_o,32'h0000_0001);
        apb_write(12'h14,32'h0000_0000,4'hF); apb_read(12'h14); check("TIER=0", rdata_o,32'h0000_0000);
        // THCSR halt_reg bit
        apb_write(12'h1C,32'h0000_0001,4'hF); apb_read(12'h1C); check("THCSR halt_reg=1", rdata_o[0],1'b1);
        apb_write(12'h1C,32'h0000_0000,4'hF); apb_read(12'h1C); check("THCSR halt_reg=0", rdata_o[0],1'b0);
    end
endtask
