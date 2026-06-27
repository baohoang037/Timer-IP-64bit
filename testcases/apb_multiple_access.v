// apb_multiple_access : back-to-back (no idle) write/read transactions
task run_test;
    begin
        $display("---- apb_multiple_access ----");
        apb_write2(12'h0C,32'h1111_2222, 12'h10,32'h3333_4444, 4'hF); // 2 writes back-to-back
        apb_read2 (12'h0C, 12'h10);
        check("multi-wr TCMP0", rdata_o, 32'h1111_2222);
        check("multi-wr TCMP1", rdata_o2,32'h3333_4444);
        apb_write2(12'h04,32'hABCD_0001, 12'h08,32'hABCD_0002, 4'hF);
        apb_read2 (12'h04, 12'h08);
        check("multi-rd TDR0", rdata_o, 32'hABCD_0001);
        check("multi-rd TDR1", rdata_o2,32'hABCD_0002);
        apb_write(12'h0C,32'h0,4'hF); apb_write(12'h10,32'h0,4'hF);
        apb_write(12'h04,32'h0,4'hF); apb_write(12'h08,32'h0,4'hF);
    end
endtask
