module counter (
    input  clk, rst_n,
    input  timer_en, cnt_en,
    input  tdr0_wr, tdr1_wr,
    input  [31:0] wdata,
    input  [3:0]  byte_en,
    output [63:0] cnt
);
    reg [63:0] r_cnt;
    reg r_timer_en_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_timer_en_d <= 1'b0;
        else        r_timer_en_d <= timer_en;
    end
    wire fall_edge = r_timer_en_d & ~timer_en;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)         r_cnt <= 64'd0;
        else if (fall_edge) r_cnt <= 64'd0;
        else if (tdr0_wr) begin
            if (byte_en[0]) r_cnt[7:0]   <= wdata[7:0];
            if (byte_en[1]) r_cnt[15:8]  <= wdata[15:8];
            if (byte_en[2]) r_cnt[23:16] <= wdata[23:16];
            if (byte_en[3]) r_cnt[31:24] <= wdata[31:24];
        end else if (tdr1_wr) begin
            if (byte_en[0]) r_cnt[39:32] <= wdata[7:0];
            if (byte_en[1]) r_cnt[47:40] <= wdata[15:8];
            if (byte_en[2]) r_cnt[55:48] <= wdata[23:16];
            if (byte_en[3]) r_cnt[63:56] <= wdata[31:24];
        end else if (cnt_en)
            r_cnt <= r_cnt + 64'd1;
    end
    assign cnt = r_cnt;
endmodule