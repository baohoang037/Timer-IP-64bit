module counter_control (
    input  clk, rst_n,
    input  timer_en, div_en,
    input  [3:0] div_val,
    input  dbg_mode, halt_reg,
    output cnt_en, halt_ack
);
    wire [8:0] div_amount = 9'd1 << div_val;
    wire [7:0] limit = div_en ? (div_amount[7:0] - 8'd1) : 8'd0;
    wire halt = dbg_mode & halt_reg;
    reg r_halt_ack;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_halt_ack <= 1'b0;
        else        r_halt_ack <= halt;
    end
    assign halt_ack = r_halt_ack;
    reg [7:0] int_cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)                int_cnt <= 8'd0;
        else if (!timer_en)        int_cnt <= 8'd0;
        else if (halt)             int_cnt <= int_cnt;
        else if (int_cnt == limit) int_cnt <= 8'd0;
        else                       int_cnt <= int_cnt + 8'd1;
    end
    assign cnt_en = timer_en & ~halt & (int_cnt == limit);
endmodule
