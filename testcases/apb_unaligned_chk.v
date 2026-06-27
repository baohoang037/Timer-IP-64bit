// apb_unaligned_chk : unaligned offsets do not match any register (read 0, no corruption)
task run_test;
    begin
        $display("---- apb_unaligned_chk ----");
        apb_write(12'h0C,32'h1234_5678,4'hF);          // valid TCMP0
        apb_write(12'h00D,32'hFFFF_FFFF,4'hF);         // unaligned within TCMP0 range
        apb_write(12'h00E,32'hFFFF_FFFF,4'hF);
        apb_write(12'h00F,32'hFFFF_FFFF,4'hF);
        apb_read (12'h0C); check("TCMP0 intact (unaligned wr)", rdata_o,32'h1234_5678);
        apb_read (12'h00D); check("unaligned 0x00D reads 0", rdata_o,32'h0);
        apb_read (12'h006); check("unaligned 0x006 reads 0", rdata_o,32'h0);
        apb_write(12'h0C,32'h0,4'hF);
    end
endtask
