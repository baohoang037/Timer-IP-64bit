`timescale 1ns/1ps
module test_bench;
    reg clk,rst_n,psel,pwrite,penable;
    reg [11:0] paddr;
    reg [31:0] pwdata;
    reg [3:0] pstrb;
    wire [31:0] prdata;
    wire pready,pslverr,tim_int;
    reg dbg_mode;
    integer error_cnt;
    reg [31:0] rdata_o, rdata_o2;
    reg slverr_o;
    reg [63:0] tmpa, tmpb;

    timer_top dut (
        .sys_clk(clk),.sys_rst_n(rst_n),.tim_psel(psel),.tim_pwrite(pwrite),
        .tim_penable(penable),.tim_paddr(paddr),.tim_pwdata(pwdata),.tim_prdata(prdata),
        .tim_pstrb(pstrb),.tim_pready(pready),.tim_pslverr(pslverr),.tim_int(tim_int),
        .dbg_mode(dbg_mode)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- APB single WRITE ----------------
    task apb_write;
        input [11:0] a; input [31:0] d; input [3:0] s;
        begin
            @(negedge clk); psel=1; pwrite=1; penable=0; paddr=a; pwdata=d; pstrb=s;
            @(negedge clk); penable=1;
            @(posedge clk); while (pready!==1'b1) @(posedge clk);
            slverr_o = pslverr;
            @(negedge clk); psel=0; penable=0; pwrite=0; pstrb=4'h0;
        end
    endtask

    // ---------------- APB single READ ----------------
    task apb_read;
        input [11:0] a;
        begin
            @(negedge clk); psel=1; pwrite=0; penable=0; paddr=a; pstrb=4'hF;
            @(negedge clk); penable=1;
            @(posedge clk); while (pready!==1'b1) @(posedge clk);
            rdata_o = prdata; slverr_o = pslverr;
            @(negedge clk); psel=0; penable=0;
        end
    endtask

    // ------------- APB back-to-back 2 WRITES (no idle, exercises FSM access->setup) -------------
    task apb_write2;
        input [11:0] a0; input [31:0] d0; input [11:0] a1; input [31:0] d1; input [3:0] s;
        begin
            @(negedge clk); psel=1; pwrite=1; penable=0; paddr=a0; pwdata=d0; pstrb=s;
            @(negedge clk); penable=1;
            @(posedge clk); while (pready!==1'b1) @(posedge clk); slverr_o=pslverr;
            @(negedge clk); penable=0; paddr=a1; pwdata=d1;        // setup txn1, psel stays high
            @(negedge clk); penable=1;
            @(posedge clk); while (pready!==1'b1) @(posedge clk); slverr_o=pslverr;
            @(negedge clk); psel=0; penable=0; pwrite=0; pstrb=4'h0;
        end
    endtask

    // ------------- APB back-to-back 2 READS -------------
    task apb_read2;
        input [11:0] a0; input [11:0] a1;
        begin
            @(negedge clk); psel=1; pwrite=0; penable=0; paddr=a0; pstrb=4'hF;
            @(negedge clk); penable=1;
            @(posedge clk); while (pready!==1'b1) @(posedge clk); rdata_o=prdata;
            @(negedge clk); penable=0; paddr=a1;
            @(negedge clk); penable=1;
            @(posedge clk); while (pready!==1'b1) @(posedge clk); rdata_o2=prdata;
            @(negedge clk); psel=0; penable=0;
        end
    endtask

    // ---------------- checkers ----------------
    task check;        // exact equality
        input [8*64:1] name; input [63:0] act; input [63:0] exp;
        begin
            if (act === exp) $display("PASS %0s", name);
            else begin $display("FAIL %0s : got=0x%h exp=0x%h", name, act, exp); error_cnt=error_cnt+1; end
        end
    endtask

    task expect;       // boolean condition
        input [8*64:1] name; input cond;
        begin
            if (cond===1'b1) $display("PASS %0s", name);
            else begin $display("FAIL %0s", name); error_cnt=error_cnt+1; end
        end
    endtask

    `include "run_test.v"

    initial begin
        error_cnt=0; rst_n=0; psel=0; pwrite=0; penable=0;
        paddr=12'h0; pwdata=32'h0; pstrb=4'hF; dbg_mode=0;
        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        repeat (2) @(negedge clk);
        run_test;
        repeat (5) @(negedge clk);
        if (error_cnt==0) $display("========TEST PASSED=========");
        else              $display("========TEST FAILED =========");
        $finish;
    end

    initial begin #200000; $display("TIMEOUT"); $finish; end
endmodule
