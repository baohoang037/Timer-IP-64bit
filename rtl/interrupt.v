module interrupt (
    input  clk, rst_n,
    input  int_en,
    input  [63:0] cnt,
    input  [63:0] cmp,
    input  clr_int,
    output int_st,
    output tim_int
);
    reg r_int_st;
    wire match = (cnt == cmp);
    // int_st (pending bit) is set by hardware on a compare match, INDEPENDENT of int_en.
    // Set (match) has priority over write-1-to-clear (clr_int) when both occur same cycle.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            r_int_st <= 1'b0;
        else if (match)
            r_int_st <= 1'b1;
        else if (clr_int)
            r_int_st <= 1'b0;
    end
    assign int_st  = r_int_st;          // pending bit, not masked by int_en
    assign tim_int = int_en & r_int_st; // output masked by int_en
endmodule
