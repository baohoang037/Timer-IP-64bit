module timer_top (
    input  sys_clk, sys_rst_n,
    input  tim_psel, tim_pwrite, tim_penable,
    input  [11:0] tim_paddr,
    input  [31:0] tim_pwdata,
    output [31:0] tim_prdata,
    input  [3:0]  tim_pstrb,
    output tim_pready, tim_pslverr,
    output tim_int,
    input  dbg_mode
);
    wire wr_en, rd_en, wr_err;
    wire [11:0] addr;
    wire [31:0] wdata, rdata;
    wire [3:0]  byte_en;
    wire timer_en, div_en, int_en;
    wire [3:0]  div_val;
    wire [63:0] cmp, cnt;
    wire halt_reg, clr_int, tdr0_wr, tdr1_wr;
    wire cnt_en, int_st, halt_ack;
    apb_slave u_apb_slave (
        .clk(sys_clk), .rst_n(sys_rst_n),
        .psel(tim_psel), .penable(tim_penable), .pwrite(tim_pwrite),
        .paddr(tim_paddr), .pwdata(tim_pwdata), .pstrb(tim_pstrb),
        .prdata(tim_prdata), .pready(tim_pready), .pslverr(tim_pslverr),
        .wr_en(wr_en), .rd_en(rd_en), .addr(addr),
        .wdata(wdata), .byte_en(byte_en), .rdata(rdata), .wr_err(wr_err));
    register u_register (
        .clk(sys_clk), .rst_n(sys_rst_n),
        .wr_en(wr_en), .rd_en(rd_en), .addr(addr),
        .wdata(wdata), .byte_en(byte_en), .rdata(rdata), .wr_err(wr_err),
        .cnt(cnt), .int_st(int_st), .halt_ack(halt_ack),
        .timer_en(timer_en), .div_en(div_en), .div_val(div_val), .int_en(int_en),
        .cmp(cmp), .halt_reg(halt_reg), .clr_int(clr_int),
        .tdr0_wr(tdr0_wr), .tdr1_wr(tdr1_wr));
    counter_control u_counter_control (
        .clk(sys_clk), .rst_n(sys_rst_n),
        .timer_en(timer_en), .div_en(div_en), .div_val(div_val),
        .dbg_mode(dbg_mode), .halt_reg(halt_reg),
        .cnt_en(cnt_en), .halt_ack(halt_ack));
    counter u_counter (
        .clk(sys_clk), .rst_n(sys_rst_n),
        .timer_en(timer_en), .cnt_en(cnt_en),
        .tdr0_wr(tdr0_wr), .tdr1_wr(tdr1_wr),
        .wdata(wdata), .byte_en(byte_en), .cnt(cnt));
    interrupt u_interrupt (
        .clk(sys_clk), .rst_n(sys_rst_n),
        .int_en(int_en), .cnt(cnt), .cmp(cmp),
        .clr_int(clr_int), .int_st(int_st), .tim_int(tim_int));
endmodule
