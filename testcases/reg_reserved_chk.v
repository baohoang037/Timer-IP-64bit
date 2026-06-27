// reg_reserved_chk : reserved offsets read back 0, no pslverr, no corruption
task run_test;
    begin
        $display("---- reg_reserved_chk ----");
        apb_write(12'h020,32'hFFFF_FFFF,4'hF); apb_read(12'h020); check("rsvd 0x020 reads 0", rdata_o,32'h0);
        apb_write(12'h050,32'hFFFF_FFFF,4'hF); apb_read(12'h050); check("rsvd 0x050 reads 0", rdata_o,32'h0);
        apb_write(12'h3FC,32'hFFFF_FFFF,4'hF); apb_read(12'h3FC); check("rsvd 0x3FC reads 0", rdata_o,32'h0);
        // a valid register must be untouched by reserved writes
        apb_write(12'h0C,32'h1234_5678,4'hF);
        apb_write(12'h100,32'hFFFF_FFFF,4'hF);
        apb_read (12'h0C); check("TCMP0 intact after rsvd write", rdata_o,32'h1234_5678);
        apb_write(12'h0C,32'h0,4'hF);
    end
endtask
