module register (
    input  clk, rst_n,
    input  wr_en, rd_en,
    input  [11:0] addr,
    input  [31:0] wdata,
    input  [3:0]  byte_en,
    output reg [31:0] rdata,
    output wr_err,
    input  [63:0] cnt,
    input  int_st, halt_ack,
    output timer_en, div_en,
    output [3:0]  div_val,
    output int_en,
    output [63:0] cmp,
    output halt_reg, clr_int,
    output tdr0_wr, tdr1_wr
);
    reg r_timer_en, r_div_en;
    reg [3:0] r_div_val;
    reg r_int_en;
    reg [31:0] r_tcmp0, r_tcmp1;
    reg r_halt_reg;
    wire sel_tcr   = (addr == 12'h000);
    wire sel_tdr0  = (addr == 12'h004);
    wire sel_tdr1  = (addr == 12'h008);
    wire sel_tcmp0 = (addr == 12'h00C);
    wire sel_tcmp1 = (addr == 12'h010);
    wire sel_tier  = (addr == 12'h014);
    wire sel_tisr  = (addr == 12'h018);
    wire sel_thcsr = (addr == 12'h01C);
    wire div_val_bad   = byte_en[1] & (wdata[11:8] > 4'd8);
    wire div_en_chg    = byte_en[0] & (wdata[1] != r_div_en);
    wire div_val_chg   = byte_en[1] & (wdata[11:8] != r_div_val);
    wire chg_while_run = r_timer_en & (div_en_chg | div_val_chg);
    wire tcr_err       = sel_tcr & (div_val_bad | chg_while_run);
    assign wr_err    = wr_en & tcr_err;
    wire wr_ok_tcr   = wr_en & sel_tcr & ~wr_err;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_timer_en <= 1'b0; r_div_en <= 1'b0; r_div_val <= 4'd1;
        end else if (wr_ok_tcr) begin
            if (byte_en[0]) begin r_timer_en <= wdata[0]; r_div_en <= wdata[1]; end
            if (byte_en[1]) r_div_val <= wdata[11:8];
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_tcmp0 <= 32'hFFFF_FFFF;
        else if (wr_en & sel_tcmp0) begin
            if (byte_en[0]) r_tcmp0[7:0]   <= wdata[7:0];
            if (byte_en[1]) r_tcmp0[15:8]  <= wdata[15:8];
            if (byte_en[2]) r_tcmp0[23:16] <= wdata[23:16];
            if (byte_en[3]) r_tcmp0[31:24] <= wdata[31:24];
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_tcmp1 <= 32'hFFFF_FFFF;
        else if (wr_en & sel_tcmp1) begin
            if (byte_en[0]) r_tcmp1[7:0]   <= wdata[7:0];
            if (byte_en[1]) r_tcmp1[15:8]  <= wdata[15:8];
            if (byte_en[2]) r_tcmp1[23:16] <= wdata[23:16];
            if (byte_en[3]) r_tcmp1[31:24] <= wdata[31:24];
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_int_en <= 1'b0;
        else if (wr_en & sel_tier & byte_en[0]) r_int_en <= wdata[0];
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_halt_reg <= 1'b0;
        else if (wr_en & sel_thcsr & byte_en[0]) r_halt_reg <= wdata[0];
    end
    assign clr_int = wr_en & sel_tisr & byte_en[0] & wdata[0];
    assign tdr0_wr = wr_en & sel_tdr0;
    assign tdr1_wr = wr_en & sel_tdr1;
    always @(*) begin
        rdata = 32'h0;
        if (rd_en) begin
            case (addr)
                12'h000: rdata = {20'h0, r_div_val, 6'h0, r_div_en, r_timer_en};
                12'h004: rdata = cnt[31:0];
                12'h008: rdata = cnt[63:32];
                12'h00C: rdata = r_tcmp0;
                12'h010: rdata = r_tcmp1;
                12'h014: rdata = {31'h0, r_int_en};
                12'h018: rdata = {31'h0, int_st};
                12'h01C: rdata = {30'h0, halt_ack, r_halt_reg};
                default:  rdata = 32'h0;
            endcase
        end
    end
    assign timer_en = r_timer_en; assign div_en = r_div_en;
    assign div_val = r_div_val;   assign int_en = r_int_en;
    assign cmp = {r_tcmp1, r_tcmp0}; assign halt_reg = r_halt_reg;
endmodule