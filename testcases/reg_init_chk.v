// reg_init_chk : check reset value of all registers
task run_test;
    begin
        $display("---- reg_init_chk ----");
        apb_read(12'h00); check("TCR  reset=0x100",   rdata_o, 32'h0000_0100);
        apb_read(12'h04); check("TDR0 reset=0",       rdata_o, 32'h0000_0000);
        apb_read(12'h08); check("TDR1 reset=0",       rdata_o, 32'h0000_0000);
        apb_read(12'h0C); check("TCMP0 reset=FFFFFFFF",rdata_o, 32'hFFFF_FFFF);
        apb_read(12'h10); check("TCMP1 reset=FFFFFFFF",rdata_o, 32'hFFFF_FFFF);
        apb_read(12'h14); check("TIER reset=0",       rdata_o, 32'h0000_0000);
        apb_read(12'h18); check("TISR reset=0",       rdata_o, 32'h0000_0000);
        apb_read(12'h1C); check("THCSR reset=0",      rdata_o, 32'h0000_0000);
    end
endtask
