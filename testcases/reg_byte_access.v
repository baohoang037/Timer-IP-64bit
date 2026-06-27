// reg_byte_access : per-byte / per-halfword writes via pstrb
task run_test;
    begin
        $display("---- reg_byte_access ----");
        // TCMP0 : build 0xDEADBEEF byte by byte
        apb_write(12'h0C,32'h0000_0000,4'hF);
        apb_write(12'h0C,32'hDEAD_BEEF,4'b0001); apb_read(12'h0C); check("TCMP0 b0",rdata_o,32'h0000_00EF);
        apb_write(12'h0C,32'hDEAD_BEEF,4'b0010); apb_read(12'h0C); check("TCMP0 b1",rdata_o,32'h0000_BEEF);
        apb_write(12'h0C,32'hDEAD_BEEF,4'b0100); apb_read(12'h0C); check("TCMP0 b2",rdata_o,32'h00AD_BEEF);
        apb_write(12'h0C,32'hDEAD_BEEF,4'b1000); apb_read(12'h0C); check("TCMP0 b3",rdata_o,32'hDEAD_BEEF);
        // TCMP1 : halfword writes
        apb_write(12'h10,32'h0000_0000,4'hF);
        apb_write(12'h10,32'h1234_5678,4'b0011); apb_read(12'h10); check("TCMP1 hw0",rdata_o,32'h0000_5678);
        apb_write(12'h10,32'h1234_5678,4'b1100); apb_read(12'h10); check("TCMP1 hw1",rdata_o,32'h1234_5678);
        // TDR0/TDR1 (timer stopped)
        apb_write(12'h04,32'h0,4'hF);
        apb_write(12'h04,32'hCAFE_F00D,4'b0001); apb_write(12'h04,32'hCAFE_F00D,4'b0010);
        apb_write(12'h04,32'hCAFE_F00D,4'b0100); apb_write(12'h04,32'hCAFE_F00D,4'b1000);
        apb_read (12'h04); check("TDR0 byte-merged",rdata_o,32'hCAFE_F00D);
        apb_write(12'h08,32'h0,4'hF);
        apb_write(12'h08,32'h0BAD_C0DE,4'b0011); apb_write(12'h08,32'h0BAD_C0DE,4'b1100);
        apb_read (12'h08); check("TDR1 hw-merged",rdata_o,32'h0BAD_C0DE);
        apb_write(12'h0C,32'h0,4'hF); apb_write(12'h10,32'h0,4'hF);
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
    end
endtask
